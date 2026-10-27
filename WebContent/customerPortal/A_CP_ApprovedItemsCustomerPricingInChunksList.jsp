<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.io.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>
<%-- <%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %> --%>

<% 
	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();

	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}
	String userId = (String)session.getAttribute("userId");
	Utils.log("userId :: " + userId);
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);
	
	HashMap<String, String> userDetailsMap = getUserDetails(customerId.trim());
	String allowAuthorized = Utils.removeNull(userDetailsMap.get("allowAuthorized").toString());
	Utils.log("allowAuthorized :: " + allowAuthorized);
	String allowDiscountOnCCPayment = Utils.removeNull(userDetailsMap.get("allowDiscountOnCCPayment").toString());
	Utils.log("allowDiscountOnCCPayment :: " + allowDiscountOnCCPayment);
	String ccSurchargeFeesPercent = Utils.removeNull(userDetailsMap.get("ccSurchargeFeesPercent").toString());
	Utils.log("ccSurchargeFeesPercent :: " + ccSurchargeFeesPercent);
	String allowDiscountAchPay = Utils.removeNull(userDetailsMap.get("allowDiscountAchPay").toString());
	Utils.log("allowDiscountAchPay :: " + allowDiscountAchPay);

	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");

	FileReader reader=new FileReader("eTechLogix.properties");  
    Properties prop=new Properties();  
    prop.load(reader);    
	//String url=prop.getProperty("AgilityUrl");
    String url="https://api-1362-1.dmsi.com/AgilityPublic/rest/";
    String loginUrl = url+"Session/Login";
	
	JSONObject childBody=new JSONObject();
	childBody.put("LoginID", "API");
	childBody.put("Password", "~Zrwcetech123");
	JSONObject mainBody=new JSONObject();
	mainBody.put("request", childBody);
		
	ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
	HashMap<String, String> temp = null;

	ApiCall apiCallObj = new ApiCall();
	JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
	if(loginRespObj != null){
		Utils.log("Login Response >>>> "+loginRespObj);
		JSONObject loginResp = (JSONObject)loginRespObj.get("response");
		String contextId = loginResp.get("SessionContextId").toString();
		Utils.log("Context Id >>>> "+contextId);
		String systemId = loginResp.get("InitialBranch").toString();
		Utils.log("System Id >>>> "+systemId);

		JSONObject firstObj=new JSONObject();
		firstObj.put("CustomerID", customerId);
		firstObj.put("RecordFetchLimit", 200);
		firstObj.put("ItemGroupMajor", "08TA");
		firstObj.put("ItemGroupMinor", "");
		
		JSONArray dtCustomerPricingRequestArray = new JSONArray();
		dtCustomerPricingRequestArray.add(firstObj);
		
		JSONObject dtCustomerPricingRequestObject=new JSONObject();
		dtCustomerPricingRequestObject.put("dtCustomerPricingRequest", dtCustomerPricingRequestArray.toString());

		JSONObject dsCustomerPricingRequestObject = new JSONObject();
		dsCustomerPricingRequestObject.put("dsCustomerPricingRequest", dtCustomerPricingRequestObject);

		JSONObject customerPricingRequestJSONObject = new JSONObject();
		customerPricingRequestJSONObject.put("CustomerPricingRequestJSON", dsCustomerPricingRequestObject);
		
		JSONObject requestObject=new JSONObject();
		requestObject.put("request",customerPricingRequestJSONObject);
		Utils.log("ItemCustomerPricingList Request Object :: " + requestObject);
			
		String approvedItemsCustomerPricingInChunksListUrl = url+"Pricing/ApprovedItemsCustomerPricingInChunksList";
		Utils.log("approvedItemsCustomerPricingInChunksListUrl :: " + approvedItemsCustomerPricingInChunksListUrl);
	    JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObject,approvedItemsCustomerPricingInChunksListUrl,contextId,systemId);
		if(responseObj != null){
		    Utils.log("ApprovedItemsCustomerPricingInChunksList Response :: "+responseObj);
		    JSONObject res = (JSONObject)responseObj.get("response");
		    if(res != null){
			    if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
			    	JSONObject customerPricingResponse = (JSONObject)res.get("CustomerPricingResponse");
			    	if(customerPricingResponse != null){
			       		JSONObject dsApprvdItemCustPricingResponse = (JSONObject)customerPricingResponse.get("dsApprvdItemCustPricingResponse");
			       		if(dsApprvdItemCustPricingResponse != null){
			       			JSONArray dtApprvdItemPriceAndQtyResponseArray = (JSONArray)dsApprvdItemCustPricingResponse.get("dtApprvdItemPriceAndQtyResponse");
			       			if(dtApprvdItemPriceAndQtyResponseArray != null){
			       				Utils.log("dtApprvdItemPriceAndQtyResponseArray :: "+dtApprvdItemPriceAndQtyResponseArray.size());
			       	    		for(int i=0;i<dtApprvdItemPriceAndQtyResponseArray.size();i++){
			       	    			JSONObject obj = (JSONObject)dtApprvdItemPriceAndQtyResponseArray.get(i);
			       	    			temp=new HashMap<String, String>();
	        		        		temp.put("itemCode", Utils.removeNull(obj.get("ItemCode").toString()));
	        		        		temp.put("itemDescription", Utils.removeNull(obj.get("ItemDescription").toString()));
	        		        		temp.put("itemSize", Utils.removeNull(obj.get("ItemSize").toString()));
	        		        		temp.put("netPrice", Double.toString(Utils.parseDouble(obj.get("GrossPrice").toString())));
	        						temp.put("priceUOM", obj.get("PriceUOM").toString());
	        						listData.add(temp);
			       	    		}
			       			}
			       		}
			    	}
			    }
		    }
		}
	}
%>

	<style type="text/css">
		.overLay{
			background:rgba(0,0,0,0.5); 
			position:fixed; 
			width:100%; 
			height:100%; 
			left:0; 
			right:0; 
			bottom:0; 
			top:0; 
			z-index:9999;
		}
		
		.loading-img{
			background-image: url(NewPortalAssets/assets/images/ajax-loader.gif) no-repeat; 
			margin: -24px 0 0 -24px; 
			position: absolute; 
			left: 50%; 
			top: 50%; 
			z-index: 10; 
			width: 48px; 
			height: 48px;
		}
	</style>

	<!-- HEADER-->
    	<%@ include file="A_CP_Header.jsp" %>
    <!-- END HEADER-->


    <div class="page-wrapper">
		<div class="overLay" style="display:none;"><div class="loading-img"><img src="NewPortalAssets/assets/images/ajax-loader.gif"></div></div>
        
        <!-- PAGE CONTENT-->
        <div class="page-content--bgf7">

            <!-- WELCOME-->
            <section class="welcome p-t-10">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-6">
                            <h3 class="title-5 m-b-35"><img src="NewPortalAssets/assets/images/dollar.png" width="18px" height="18px"/>&nbsp;Pricing List </h3>
                        </div>
                    </div>
                    <div class="row">
                    	<div class="col-md-12">
                    		<hr class="line-seprate">
                    	</div>
                    </div>
                </div>
            </section>
            <!-- END WELCOME-->


            <!-- DATA TABLE-->
            <section class="p-t-20">
                <!-- <div class="container-fluid"> -->
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive" id="table-div" >
	                                <table id="ItemCustomerPricingListTable" class="table table-striped table-hover table-grid tab-Table FINdatatableStyle" role="grid" aria-describedby="datatable-example_info" style="font-size:12px;font-family: Verdana; width: 100%; ">
	                                    <thead>
	                                        <tr>
	                                            <th style="text-align: left;" nowrap>ITEM#</th>
	                                            <th style="text-align: left;" nowrap>ITEM DESC</th>
	                                            <th style="text-align: left;" nowrap>ITEM SIZE</th>
	                                            <th style="text-align: right;" nowrap>PRICE</th>
	                                            <th style="text-align: right;" nowrap>UOM</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<%
												if(listData != null && listData.size()>0){ 
													for(int i=0;i<listData.size();i++){
														HashMap map=(HashMap)listData.get(i);
											%>
												<tr class="tr-shadow">
													<td style="text-align: left;"><%=map.get("itemCode")%></td>
													<td style="text-align: left;"><%=map.get("itemDescription")%></td>
													<td style="text-align: left;"><%=map.get("itemSize")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("netPrice").toString()))%></td>
													<td style="text-align: right;"><%=map.get("priceUOM").toString()%></td>
												</tr>
											<%}}%>
	                                    </tbody>
									</table>
	                            </div>
                        	</div>
                        
                        </div>
                    </div>
                </div>
            </section>
            <!-- END DATA TABLE-->

        </div>
    </div>

	
	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->
	
	<script type="text/javascript">
	
	 	var today;
		$(document).ready(function(){
	  		debugger;
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			today = mm + '-' + (dd) + '-' + now.getFullYear();
			
			$('#datepicker1,#datepicker2').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				maxDate: "0",
			});

			$('#ItemCustomerPricingListTable').DataTable({
				'pageLength': 25,
				"aaSorting": [[ 1, "asc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            'copy', 'csv', 'excel'
			            /* 'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5' */
			        ]
				/* 'bDestroy': true,
				'paging': true,
				'stateSave': true */
			});
			
		}); 	

		
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}
		
	</script>


<%!
	public HashMap<String,String> getUserDetails(String customerId){
		String query="";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query="select DISTINCT FIRSTNAME,MIDDLENAME,LASTNAME,ADDRESS,STATE,CITY,ZIP,PHONE,EMAILID,ALLOWAUTHORIZED,"
					+"ALLOWDISCOUNTONCCPAYMENT,CCSURCHARGEFEESPERCENT,ALLOWDISCOUNTACHPAY from ETECHUSER where DEPTID='"+customerId.trim()+"' ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector firstNameVector = new Vector();
			Vector middleNameVector = new Vector();
			Vector lastNameVector = new Vector();
			Vector addressVector = new Vector();
			Vector stateVector = new Vector();
			Vector cityVector = new Vector();
			Vector zipVector = new Vector();
			Vector phoneVector = new Vector();
			Vector emailIdVector = new Vector();
			Vector allowAuthorizedVector = new Vector();
			Vector allowDiscountOnCCPaymentVector = new Vector();
			Vector ccSurchargeFeesPercentVector = new Vector();
			Vector allowDiscountAchPayVector = new Vector();
			if (ht != null && ht.size() != 0) {
				firstNameVector = (Vector) ht.get("FIRSTNAME");
				middleNameVector = (Vector) ht.get("MIDDLENAME");
				lastNameVector = (Vector) ht.get("LASTNAME");
				addressVector = (Vector) ht.get("ADDRESS");
				stateVector = (Vector) ht.get("STATE");
				cityVector = (Vector) ht.get("CITY");
				zipVector = (Vector) ht.get("ZIP");
				phoneVector = (Vector) ht.get("PHONE");
				emailIdVector = (Vector) ht.get("EMAILID");
				allowAuthorizedVector = (Vector) ht.get("ALLOWAUTHORIZED");
				allowDiscountOnCCPaymentVector = (Vector) ht.get("ALLOWDISCOUNTONCCPAYMENT");
				ccSurchargeFeesPercentVector = (Vector) ht.get("CCSURCHARGEFEESPERCENT");
				allowDiscountAchPayVector = (Vector) ht.get("ALLOWDISCOUNTACHPAY");
			}
	        if (allowAuthorizedVector.size() > 0) {
	        	for (int i = 0; i < allowAuthorizedVector.size(); i++) {  
	    			temp=new HashMap<String, String>();
	        		temp.put("firstName", firstNameVector.get(i).toString());
	        		temp.put("middleName", middleNameVector.get(i).toString());
	        		temp.put("lastName", lastNameVector.get(i).toString());
	        		temp.put("address", addressVector.get(i).toString());
	        		temp.put("state", stateVector.get(i).toString());
	        		temp.put("city", cityVector.get(i).toString());
	        		temp.put("zip", zipVector.get(i).toString());
	        		temp.put("phone", phoneVector.get(i).toString());
	        		temp.put("emailId", emailIdVector.get(i).toString());
	    			temp.put("allowAuthorized", allowAuthorizedVector.get(i).toString());
					temp.put("allowDiscountOnCCPayment", allowDiscountOnCCPaymentVector.get(i).toString());
					temp.put("ccSurchargeFeesPercent", ccSurchargeFeesPercentVector.get(i).toString());
					temp.put("allowDiscountAchPay", allowDiscountAchPayVector.get(i).toString());
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}

		
%>
