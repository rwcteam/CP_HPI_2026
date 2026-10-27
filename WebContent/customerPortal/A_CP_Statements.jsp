<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>


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
	
	String yearValue = request.getParameter("year");
	
	if(yearValue==null || yearValue.equals("")){
	    SimpleDateFormat formatter = new SimpleDateFormat("MM-dd-yyyy");  
	    Date date = new Date();
	    yearValue = String.valueOf(Integer.parseInt(new SimpleDateFormat("yyyy").format(date)));	  
	}
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	
	String year="";
	ArrayList<HashMap<String, String>> yearList = getYearList();
	for (int i=0; i< yearList.size();i++){
		HashMap mapData = (HashMap)yearList.get(i);
		if(!mapData.get("statementYear").toString().equalsIgnoreCase("NA")){
			year+="<option value='"+mapData.get("statementYear")+"'>"+mapData.get("statementYear")+"</option>";
		}
	}

	List<HashMap<String, String>> listData = getStatementsList(customerId,yearValue);

%>

	<style>
	    html,
	    body {
	        height: 100%;
	        margin: 0;
	        display: flex;
	        flex-direction: column;
	    }
	</style>


    <!-- START HEADER-->
	<%@ include file="A_CP_Header.jsp" %>
    <!-- END HEADER-->

	<div class="page-wrapper">
	    <div class="page-content--bgf7">
	        <section class="py-4">
	            <div class="container">
	                <div class="row mb-2 justify-content-between">
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 mb-3">
	                        <h6 class="mb-4 text-uppercase"><img src="NewPortalAssets/assets/images/icons/statements.png" width="40px" alt="" /> Statements</h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
	                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
	                    </div>
	                </div>
	                <div class="row">
	                    <div class="col-md-3 mb-3">
	                        <form name="StatementsForm" id="StatementsForm" action="" method="post" class="align-items-center d-flex">
		                        <label class="text-nowrap m-0 mr-2">Filter:</label>
		                        <select name="year" id="year" class="form-control form-control-sm">
		                            <%if(yearValue==null || yearValue.equals("")){%>
										<option value="" selected="">Filter By Year</option>
									<%}else{%>
										<option value="<%=yearValue%>" selected><%=yearValue%></option>
									<%}%>
									<%=year%>
		                        </select>
		                        <button type="button" class="btn btn-danger btn-sm ml-2" onclick="getDataByYear()">Filter</button>
	                    	</form>
	                    </div>
	                    
	                    <div class="col-md-12">
	                        <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive">
	                                <table id="StatementsTable"
	                                    class="table border border-top-0 table-grid tab-Table" role="grid"
	                                    width="100%" aria-describedby="datatable-example_info">
	                                    <thead>
	                                        <tr>
		                                        <th style="text-align: center;" width="2%">Download</th>
		                                        <th style="text-align: left;" width="4%">Statements Date</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
	                                        <%
	                                        	if(listData != null && listData.size()>0){
													for(int i=0;i<listData.size();i++){
														HashMap map=(HashMap)listData.get(i);
											%>
		                                        <tr>
	                                        		<td align="center"><a href="javascript:getStatementsPdfList('<%=map.get("awsUrl")%>')" class="btn btn-outline-danger btn-sm"><i class="icon-download"></i> PDF</a></td>
													<td align="left"><%=map.get("statementDate")%></td>
		                                        </tr>
	                                        <%}}else{%>
	                                        	<tr>
	                                        		<td align="center"></td>
	                                        		<td align="center"><div style="width:200px">Data Does Not Exist</div></td>
		                                        </tr>
	                                        <%}%>
	                                    </tbody>
	                                </table>
	                            </div>
	                        </div>
	                    </div>
	                </div>
	            </div>
	        </section>
	    </div>
	</div>

	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->


	<script type="text/javascript">

		var orderId,shipmentId;
		var id,today ;
		var fromDate = '${requestScope.fromDate}';
		var toDate = '${requestScope.toDate}';
	
		$(document).ready(function(){
	  		//debugger;
	
	  		//hideDateFilter();
	  		
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

			
			$('#StatementsTable').DataTable({
				'pageLength': 25,
				//"aaSorting": [[ 2, "desc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            	{
			                    extend: 'copyHtml5',
			                    text: '<i class="icon-copy text-white mr-1"></i> Copy'
		                	},
			                {
		        	            extend: 'csvHtml5',
		                	    text: '<i class="icon-download text-white mr-1"></i> CSV'
			                },
			                {
			                    extend: 'excelHtml5',
		        	            text: '<i class="icon-download text-white mr-1"></i> XLS'
		                	}
			        ],
				'bDestroy': true,
				'scrollY': "55vh",
				'scrollX': true,
				'paging': true,
				'scrollCollapse': true
			});
			
		    $('a').click(function(){
		        $('a').removeClass("active");
		        $(this).addClass("active");
		    });
			
		    $('.dataTables_filter input').attr('placeholder', 'Search items...');

		}); 	
	

		/* window.onload = function() {
			submitForm();
		}; */
	  	
 		/* function applyFilterForTodayData(){
			window.location = "../customerPortal/CustomerDeliveryAction.jsp";
		} */
		
	   	function getStatementsPdfList(awsUrl){
	   		debugger;
	   		$.ajax({
			 	url:"../customerPortal/A_CP_OpenInvoicesAction.jsp?param=GetStatementsPdf&awsUrl="+awsUrl,
				type : "POST",
				dataType: "text",
				success: function (response) {
					window.open(response.toString(), "_blank");
				},
			 	failure: function (response) {
			    }
			});
	   	}
	   	
		function getDataByYear(){
			debugger;
			var year = document.getElementById('year').value;
			if(year == "" || year == null ){
				alert("Please select year");
				return false;
			}
			else{
				document.StatementsForm.action="../customerPortal/A_CP_Statements.jsp?pageName=Statements&year="+year;
				document.StatementsForm.submit();	        
			}
		}
	   	
		/* function exit2(){
			parent.location='/index.htm?actionCode=Logout';
		} */
	
		/* function exit2(){
			parent.location='/login?actionCode=Logout';
		} */

		
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}

		
	</script>


<%!

	public ArrayList<HashMap<String, String>> getStatementsList(String customerId,String yearValue){
		String query="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			if(yearValue==null || yearValue.equals(""))
				filterString=" where ACCNO='"+customerId+"' ";
			else
				filterString=" where ACCNO='"+customerId+"' and extract(YEAR from STATEMENT_DATE) = "+yearValue+" ";
			
			DistUtils du = new DistUtils();
			//query=" select ACCNO, AWSURL, STATEMENT_DATE from DMSI_CUSTOMER_STATEMENTS " + filterString + " order by STATEMENT_DATE";
			query=" SELECT ACCNO,AWSURL,STATEMENT_DATE "
					+" FROM ( "
						    +" SELECT t.*,ROW_NUMBER() OVER (PARTITION BY STATEMENT_DATE ORDER BY STATEMENT_DATE) AS rn "
						    +" FROM DMSI_CUSTOMER_STATEMENTS t "+filterString +") "
						+" WHERE rn = 1 ";
			Utils.log("Statements Query >>>> "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector accNoVector = new Vector();
			Vector awsUrlVector = new Vector();
			Vector statementDateVector = new Vector();
			if (ht != null && ht.size() != 0) {
				accNoVector = (Vector) ht.get("ACCNO");
				awsUrlVector = (Vector) ht.get("AWSURL");
				statementDateVector = (Vector) ht.get("STATEMENT_DATE");
			}
	        if (accNoVector.size() > 0) {
	        	for (int i = 0; i < accNoVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("accNo", accNoVector.get(i).toString());
	        		temp.put("awsUrl", awsUrlVector.get(i).toString());
	        		temp.put("statementDate", statementDateVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

	public ArrayList<HashMap<String, String>> getYearList() {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select DISTINCT NVL(TO_CHAR(extract(YEAR from STATEMENT_DATE)),'NA') as STATEMENT_DATE from DMSI_CUSTOMER_STATEMENTS order by STATEMENT_DATE desc";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector statementDateVector = new Vector();
			if (ht != null && ht.size() != 0) {
				statementDateVector = (Vector) ht.get("STATEMENT_DATE");
			}
	        if (statementDateVector.size() > 0) {
	        	for (int i = 0; i < statementDateVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("statementYear", statementDateVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}


%>
