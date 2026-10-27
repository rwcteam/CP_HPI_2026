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
	Utils.log("userId >>>> " + userId);
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId >>>> " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key >>>> " + custKey);
	
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
	String paymentMethod = request.getParameter("paymentMethod");
	if (paymentMethod == null || paymentMethod.trim().equals("")) 
		paymentMethod="";

	String bankName = request.getParameter("bankList");
	if (bankName == null || bankName.trim().equals("")) 
		bankName="";

	String bankList="";
	String filePath = getServletContext().getRealPath("/eTechLogix.properties");
	
	FileReader reader=new FileReader(filePath);  
    Properties prop=new Properties();  
    prop.load(reader);    
    String url=prop.getProperty("AgilityUrl");
    String loginUrl = url+"Session/Login";
	
	JSONObject childBody=new JSONObject();
	childBody.put("LoginID", "API");
	childBody.put("Password", "~Zrwcetech123");
	JSONObject mainBody=new JSONObject();
	mainBody.put("request", childBody);
    
	StringBuffer bankListBuffer=new StringBuffer();
	bankListBuffer.append("<option value=''>--Select --</option>");
	if(paymentMethod.equalsIgnoreCase("ach")){
		
		JSONObject jsonObject=new JSONObject();
		jsonObject.put("CustomerID", customerId);
		jsonObject.put("ShiptoSequence", 1);
		jsonObject.put("BilltoSequence", 1);
		
		JSONArray dtCustomerRequestArray = new JSONArray();
		dtCustomerRequestArray.add(jsonObject);
		
		JSONObject dtCustomerRequest=new JSONObject();
		dtCustomerRequest.put("dtCustomerRequest", dtCustomerRequestArray.toString());
		
		JSONObject dsCustomerRequest=new JSONObject();
		dsCustomerRequest.put("dsCustomerRequest", dtCustomerRequest);
		
		JSONObject customerACHBankListJSON=new JSONObject();
		customerACHBankListJSON.put("CustomerACHBankListJSON",dsCustomerRequest);

		JSONObject requestObject=new JSONObject();
		requestObject.put("request",customerACHBankListJSON);
		Utils.log("ACH Bank List Request Object :: " + requestObject);
		
		ApiCall apiCallObj = new ApiCall();
		JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
		if(loginRespObj != null){
			Utils.log("Login Response >>>> "+loginRespObj);
			JSONObject loginResp = (JSONObject)loginRespObj.get("response");
			String contextId = loginResp.get("SessionContextId").toString();
			Utils.log("Context Id >>>> "+contextId);
			String systemId = loginResp.get("InitialBranch").toString();
			Utils.log("System Id >>>> "+systemId);
		
			String bankListUrl = url+"AccountsReceivable/CustomerACHBankList";
			Utils.log("bankListUrl :: " + bankListUrl);
	    	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObject,bankListUrl,contextId,systemId);
			if(responseObj != null){
		    	Utils.log("ACH Bank List Response :: "+responseObj);
		    	JSONObject res = (JSONObject)responseObj.get("response");
		    	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
		    		JSONObject customerACHBankListJSONResponse = (JSONObject)res.get("CustomerACHBankListJSONResponse");
		    		if(customerACHBankListJSONResponse != null){
		        		JSONObject dsACHBankAccountResponse = (JSONObject)customerACHBankListJSONResponse.get("dsACHBankAccountResponse");
		        		if(dsACHBankAccountResponse != null){
		        			JSONArray dtACHBankAccountResponseArray = (JSONArray)dsACHBankAccountResponse.get("dtACHBankAccountResponse");
		        			if(dtACHBankAccountResponseArray != null){
		        	    		for(int i=0;i<dtACHBankAccountResponseArray.size();i++){
		        	    			JSONObject obj = (JSONObject)dtACHBankAccountResponseArray.get(i);
		        	    			bankListBuffer.append("<option value='"+obj.get("BankGUID").toString()+"'>"+obj.get("BankName").toString() +" : "+obj.get("BankAcctName").toString()+" : "+obj.get("TruncatedAccountNumber").toString()+"</option>");
		        	    		}
		        			}
		        		}
		    		}
		    	}
			}
		
		}
	}
	else if(paymentMethod.equalsIgnoreCase("creditcard")){

		JSONObject jsonObject=new JSONObject();
		jsonObject.put("CustomerID", customerId);
		jsonObject.put("ShiptoSequence", 1);
		
		JSONArray dtCustomerShiptoArray = new JSONArray();
		dtCustomerShiptoArray.add(jsonObject);
		
		JSONObject dtCustomerShipto=new JSONObject();
		dtCustomerShipto.put("dtCustomerShipto", dtCustomerShiptoArray.toString());
		
		JSONObject dsCustomerShipto=new JSONObject();
		dsCustomerShipto.put("dsCustomerShipto", dtCustomerShipto);
		
		JSONObject CustomerJSON=new JSONObject();
		CustomerJSON.put("CustomerJSON",dsCustomerShipto);

		JSONObject requestObject=new JSONObject();
		requestObject.put("request",CustomerJSON);
		
		Utils.log("CC Bank List Request Object :: " + requestObject);
		
		ApiCall apiCallObj = new ApiCall();
		JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
		if(loginRespObj != null){
			Utils.log("Login Response >>>> "+loginRespObj);
			JSONObject loginResp = (JSONObject)loginRespObj.get("response");
			String contextId = loginResp.get("SessionContextId").toString();
			Utils.log("Context Id >>>> "+contextId);
			String systemId = loginResp.get("InitialBranch").toString();
			Utils.log("System Id >>>> "+systemId);
		
			String creditCardUrl = url+"AccountsReceivable/SavedCreditCardList";
			Utils.log("creditCardUrl :: " + creditCardUrl);
		
	    	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObject,creditCardUrl,contextId,systemId);
	    	Utils.log("CC Bank List Response :: " + responseObj);
	    	JSONObject res = (JSONObject)responseObj.get("response");
	    	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	    		JSONObject savedCreditCardListJSONResponse = (JSONObject)res.get("SavedCreditCardListJSONResponse");
	    		if(savedCreditCardListJSONResponse != null){
	    			JSONObject dsSavedCreditCardResponse = (JSONObject)savedCreditCardListJSONResponse.get("dsSavedCreditCardResponse");
	    			if(dsSavedCreditCardResponse != null){
	    				JSONArray dtSavedCreditCardResponseArray = (JSONArray)dsSavedCreditCardResponse.get("dtSavedCreditCardResponse");
	    				if(dtSavedCreditCardResponseArray != null){
	    		    		for(int i=0;i<dtSavedCreditCardResponseArray.size();i++){
	    		    			JSONObject obj = (JSONObject)dtSavedCreditCardResponseArray.get(i);
	    		    			bankListBuffer.append("<option value='"+obj.get("PaymentAccountID").toString()+"'>"+obj.get("TruncatedCardNumber").toString() +" : "+obj.get("BillingName").toString()+"</option>");
	    		    		}
	    				}
	    			}
	    		}
	    	}
		}
    	
	}
	bankList=bankListBuffer.toString();
	
	double openAmountTotal=0;
	List<HashMap<String, String>> listData = getOpenInvoiceData(custKey,paymentMethod,allowDiscountOnCCPayment,allowDiscountAchPay);
	//Utils.log("step 16 :: " );
	if(listData != null && listData.size()>0){ 
		for(int i=0;i<listData.size();i++){
			HashMap map=(HashMap)listData.get(i);
			openAmountTotal=openAmountTotal+Double.parseDouble(map.get("openAmt").toString()); 
		}
	}
	//Utils.log("step 17 openAmountTotal :: "+openAmountTotal );
	
	List<HashMap<String, String>> apiInvoiceList = getOpenInvoiceListWithAPI(customerId,paymentMethod,allowDiscountOnCCPayment,allowDiscountAchPay);
	
	String maxStatementDate = getMaxStatementDate(customerId);
	//Utils.log("Max Statement Date :: " + maxStatementDate);
	
	List<HashMap<String, String>> pastPaymentList = getPastPaymentData(custKey.trim().toString());
%>

<style type="text/css">
    html,
	body {
		height: 100%;
	    margin: 0;
	    display: flex;
	    flex-direction: column;
	}
</style>

<!-- HEADER-->
<%@ include file="A_CP_Header.jsp" %>
<!-- END HEADER-->

<div class="page-wrapper">
    <div class="page-content--bgf7">
        <section class="py-4">
            <div class="container-fluid">
                <div class="row mb-2 justify-content-between">
                    <div class="col-md-12 d-sm-flex justify-content-between align-items-center mb-3">
                        <!-- <h6 class="mb-3 mb-sm-0 text-uppercase"><img src="NewPortalAssets/assets/images/icons/payment.png" width="40px" class="mr-2" alt="" /> Payments</h6> -->
						<h6 class="mb-3 mb-sm-0 text-uppercase"></h6>
                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center text-sm-nowrap"><%=userNameHeader%></h6>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                    	<div class="d-flex justify-content-center align-items-center">
	  						<div id="HeaderMsg" style="text-align: center; color: red;"></div>
	  					</div>
                    	
                        <ul class="nav nav-pills mb-3 border-bottom flex-nowrap overflow-auto" id="payments-tab" role="tablist">
                            <li class="nav-item">
                                <a class="nav-link active rounded-0 text-nowrap" data-target="#Payments"><img src="NewPortalAssets/assets/images/icons/payment.png" width="25px" class="mr-2" alt="" />Payment</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link rounded-0 text-nowrap" data-target="#PastPayments"><img src="NewPortalAssets/assets/images/icons/past-payment.png" width="22px" class="mr-2" alt="" /> Past Payment</a>
                            </li>
                        </ul>

                        <div class="tab-content" id="payments-tabContent">
                            <div class="tab-pane active" id="Payments">
                                <div class="row mb-3">
                                    <div class="col-xl-4 col-lg-5 col-md-6">
                                        <div class="form-group w-100">
                                            <label class="d-block text-nowrap mr-3">Payment Method</label>
                                            <select class="form-control form-control-sm" name="paymentMethod" id="paymentMethod" onchange="getBankList()" required>
												<%if(paymentMethod.equalsIgnoreCase("ach")){%>
													<option value="ach" selected>ACH</option>
												<%}else if(paymentMethod.equalsIgnoreCase("creditcard")){%>
													<option value="creditcard" selected>CREDIT CARD</option>
												<%}else{%>
													<option value="" selected>select</option>
												<%}%>
												<option value="ach">ACH</option>
												<%if(allowAuthorized.equalsIgnoreCase("Y")){%>
													<option value="creditcard">CREDIT CARD</option>
					   							<%}%>
                                            </select>
                                            <div class="invalid-feedback">Please Select Payment Method.</div>
                                        </div>
                                    </div>
                                    <div class="col-xl-8 col-lg-7 col-md-6 mb-3">
                                        <label class="text-nowrap mr-3 d-none d-md-block" style="visibility:display;">Bank</label>
                                        <select class="form-control form-control-sm" name="bankList" id="bankList" required>
											<%=bankList %>                                        
										</select>
										<div class="invalid-feedback">Please Select Bank.</div>
                                    </div>  
                                    <div class="col-xl-3 col-lg-3 col-md-12">
                                        <div class="form-group w-100">
                                            <label class="d-block text-nowrap mr-3">Select Payment Invoices</label>
                                            <select class="form-control form-control-sm" name="paymentInvoices" id="paymentInvoices" onchange="checkInvoices()" required>
												<%if(paymentMethod.equals("") || bankName.equals("")){ %>
													<option value="" selected>select</option>
												<%}%>
												<option value="all">ALL</option>
												<option value="laststatementinvoices">LAST STATEMENT INVOICES</option>
                                            </select>
                                            <div class="invalid-feedback">Please select payment invoices</div>
					</div>
                                    </div>                                  
                                    <div class="col-xl-4 col-lg-5 col-md-12" id="ccDiv">
                                        <div class="row">
                                            <div class="col-xl-6 col-lg-6 col-md-6">
                                                <div class="form-group w-100 mb-2">
                                                    <label class="d-block">CC Surcharge Fees %</label>
                                                    <input type="text" class="form-control form-control-sm" name="ccSurchargeFeesPercent" id="ccSurchargeFeesPercent" value="<%=ccSurchargeFeesPercent %>" placeholder="CC Surcharge Fee. Percent">
                                                </div>
                                                <div class="invalid-feedback">Please Enter Surcharge Fees %</div>
                                            </div>
                                            <div class="col-xl-6 col-lg-6 col-md-6">
                                                <div class="form-group w-100">
                                                    <label class="d-block mr-3">CC Surcharge Fees</label>
                                                    <input type="text" class="form-control form-control-sm" name="ccSurchargeFees" id="ccSurchargeFees" placeholder="CC Surcharge Fee. Amount" readonly="">
                                                </div>
                                                <div class="invalid-feedback">Please Enter Surcharge Fees</div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-xl-3 col-lg-4 col-md-12">
										<div class="form-group w-100">
	                                        <label class="d-block">Total Amount</label>
			                            	<input type="text" class="form-control form-control-sm" name="totalPaymentAmount" id="totalPaymentAmount" placeholder="Total Amount" readonly="">
    									</div>
    									<div class="invalid-feedback">Please Enter Total Amount</div>
                                    </div>
                                    <div class="col-xl-2 col-lg-4 col-md-12">
                                    	<label class="d-block" style="visibility:hidden">Make Payment</label>
                                    	<button type="button" class="btn btn-danger btn-sm" data-toggle="modal" onClick="popupForMakePayment()"><i class="icon-payments"></i> Make Payment</button>
                                    </div>

                                </div>
                                <div class="table-responsive">
                                    <table id="InvoicePaymentTable"
                                        class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                        role="grid" width="100%" aria-describedby="datatable-example_info">
                                        <thead>
                                            <tr>
                                                <th align="center"></th>
                                                <th align="center" style="display:none;"></th>
                                                <th align="left">Invoice#</th>
                                                <th align="left">Tran#</th>
                                                <th align="left">Date</th>
                                                <th align="left">Name</th>
                                                <th align="left">Ship to</th>
                                                <th align="left">Cust Po</th>
                                                <th align="right">Invoice Amt</th>
                                                <th align="right">Open Amt</th>
                                                <th align="right">Discount Amt</th>
                                                <th align="center">Date</th>
                                                <th align="center">Due Date</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        	<%
												if(apiInvoiceList != null && apiInvoiceList.size()>0){ 
													for(int i=0;i<apiInvoiceList.size();i++){
														HashMap map=(HashMap)apiInvoiceList.get(i);
											%>
												<tr class="tr-shadow">
													<td style="text-align: center;"><input type="checkbox" name="paymentCheckBox<%=i%>" id="paymentCheckBox<%=i%>" class="rowCheck" data-rownum="row<%=i%>" onclick="calculateTotal(this,'<%=map.get("refNumSysId")%>','<%=map.get("refNum")%>','<%=map.get("soId")%>','<%=map.get("shipmentNum")%>','<%=map.get("openAmt")%>','<%=map.get("discountAmountOpen")%>','<%=map.get("discountDate")%>','<%=i%>')"></td>
													<td align="center" style="display:none;"><%=map.get("refNumSysId")%></td>
													<td style="text-align: left;" nowrap><%=map.get("refNum")%></td>
													<td style="text-align: left;" nowrap><%=map.get("soId")%>-<%=map.get("shipmentNum")%></td>
													<td style="text-align: left;" nowrap><%=map.get("invoiceDate")%></td>
													<td style="text-align: left;"><%=map.get("custName")%></td>
													<td style="text-align: left;"><%=map.get("shipTo")%></td>
													<td style="text-align: left;"><%=map.get("custPo")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("amount").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("openAmt").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(Utils.removeNull(map.get("discountAmountOpen").toString())))%></td>
													<td style="text-align: center;" nowrap><%=map.get("discountDate")%></td>
													<td style="text-align: center;" nowrap><%=map.get("dueDate")%></td>
												</tr>
											<%}}else{%>
		                                       	<tr>
		                                       		<td align="center"></td>
		                                      		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"><div style="width:200px">Data Does Not Exist</div></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                        </tr>
		                                 	<%}%>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="tab-pane" id="PastPayments">
                                <div class="table-responsive">
                                    <table id="PastPaymentTable"
                                        class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                        role="grid" width="100%" aria-describedby="datatable-example_info">
                                        <thead>
                                            <tr>
                                                <th align="left">Payment#</th>
                                                <th align="left">Payment Date</th>
                                                <th align="right" class="text-right">Payment Amount</th>
                                                <th align="left">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
	                                    	<%
												if(pastPaymentList != null && pastPaymentList.size()>0){ 
													for(int i=0;i<pastPaymentList.size();i++){
														HashMap map=(HashMap)pastPaymentList.get(i);
											%>
                                            <tr>
                                                <td><%=map.get("paymentId")%></td>
                                                <td><%=map.get("paymentDate")%></td>
                                                <td align="right">$<%=df.format(Double.parseDouble(map.get("paymentAmount").toString()))%></td>
                                                <td>
                                                    <button type="button" class="btn btn-outline-danger btn-sm mx-1" title="View"
                                                        data-toggle="modal" onclick="viewDetails('<%=map.get("paymentId")%>')"><i
                                                            class="icon-visible fs-1"></i> View</button>
                                                    <a href="#" class="btn btn-outline-danger btn-sm mx-1"><i
                                                            class="icon-download"></i> XLS</a>
                                                </td>
                                            </tr>
                                         <%}}else{%>
		                                       	<tr>
		                                       		<td align="center"></td>
		                                       		<td align="center"></td>
		                                       		<td align="center"><div style="width:200px">Data Does Not Exist</div></td>
		                                       		<td align="center"></td>
		                                        </tr>
		                                 	<%}%>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</div>

<div class="modal" id="PaymentModal" data-backdrop="static" tabindex="-1" role="dialog"
    aria-labelledby="PaymentModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
                <h5 class="modal-title" id="PaymentModalTitle"><img src="NewPortalAssets/assets/images/icons/payment.png" width="30px" alt="">
                    Make Payment</h5>
                <button type="button" onclick="closeModal()" class="close small opacity-100 text-dark" data-dismiss="modal" aria-label="Close"><i class="icon-close-flat small"></i></button>
            </div>
            <div class="modal-body">
		<p style="color: green; font-weight: bold;" id="errorMsg"></p>
		<div class="card rounded-0 border-0 w-100 mb-4">
                    <div class="card-body p-0">
                        <div class="d-xl-flex justify-content-between mb-3">
                            <input type="hidden" name="modalBankGUID" id="modalBankGUID">
                            <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Total Amount</h6>
                            <p class="m-0 text-xl-right" id="modalTotalPaymentAmount"></p>
                            <!-- <input type="text" name="modalTotalPaymentAmount" id="modalTotalPaymentAmount" class="form-control" readonly> -->
                        </div>
                        <div class="d-xl-flex justify-content-between mb-0">
                            <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Total Discount</h6>
                            <p class="m-0 text-xl-right" id="modalTotalDiscountAmount"></p>
                            <!-- <input type="text" name="modalTotalDiscountAmount" id="modalTotalDiscountAmount" class="form-control" readonly> -->
                        </div>
                        <div class="text-right">                          
                        	<button class="btn btn-danger mt-4" onclick="payNow()" id="payNowBtn"><i class="icon-paynow"></i> Pay Now</button>
                        </div>
                    </div>
                </div>
                <table id="modalInvoiceTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                    role="grid" width="100%" aria-describedby="datatable-example_info">
                    <thead>
                        <tr>
                            <th align="left">INVOICE#</th>
                            <th align="right" class="text-right">Open Amount</th>
                            <th align="right" class="text-right">Discount Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>

            </div>
        </div>
    </div>
</div>

<div class="modal" id="DetailsTableModal" data-backdrop="static" tabindex="-1" role="dialog"
    aria-labelledby="DetailsTableModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
                <h5 class="modal-title" id="DetailsTableModalTitle"><img src="NewPortalAssets/assets/images/icons/past-payment.png" width="30px"
                        alt=""> </h5>
                <button type="button" class="close small opacity-100 text-dark" data-dismiss="modal"
                    aria-label="Close"><i class="icon-close-flat small"></i></button>
            </div>
            <div class="modal-body">
                <table id="DetailsTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                    role="grid" width="100%" aria-describedby="datatable-example_info">
                    <thead>
                        <tr>
                            <th align="left">INVOICE#</th>
                            <th align="left" class="text-left">Invoice Date</th>
                            <th align="right" class="text-right">Payment Amount</th>
                            <th align="right" class="text-right">Discount Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- START FOOTER-->
<%@ include file="A_CP_Footer.jsp" %>
<!-- END FOOTER-->
	
	<script type="text/javascript">
	
		var customerId=<%=customerId%>;
	    var orderId,shipmentId;
		var id,today ;
		var allowDiscountOnCCPayment = '<%=allowDiscountOnCCPayment%>';
		var ccSurchargeFeesPercent = '<%=ccSurchargeFeesPercent%>';
		var allowDiscountAchPay = '<%=allowDiscountAchPay%>';
		
		var invoiceTotalAmount=0;
		var discountTotalAmount=0;
		let rowNumArray=[];
		var systemIdArray=[];
		var invoiceNoArray=[];
		var invoiceNoForModalArray=[];
		var openAmountArray=[];
  		var disAmountArray=[];
		var openAmountArrayForPayment=[];
  		var disAmountArrayForPayment=[];
  		var datatableLength=[];
  		var maxStatementDate='<%=maxStatementDate%>';
  		
  		var paymentSuccess = false;
  		
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

			$('#InvoicePaymentTable').DataTable({
				'pageLength': 25,
				'dom': 'Blfrtip',
			    'buttons': [
			            /*'copy', 'csv', 'excel'*/
			            /* 'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5' */
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
				columnDefs: [
					{ type: 'date', targets: [4, 11, 12] }
				],
				'bDestroy': true,
				'paging': true,
				//'stateSave': true,
				'scrollY': "60vh",
				'scrollX': true,
				'paging': true
			});
			
			
			$('#PastPaymentTable').DataTable({
				'pageLength': 25,
				'dom': 'Blfrtip',
			    'buttons': [
			            /*'copy', 'csv', 'excel'*/
			            /* 'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5' */
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
				columnDefs: [
					{ type: 'date', targets: [1] }
				],
				'bDestroy': true,
				'paging': true,
				//'stateSave': true,
				'scrollY': "60vh",
				'scrollX': true,
				'paging': true
			});

			$('#modalInvoiceTable').DataTable({
				'pageLength': 25,
				'dom': 'Blfrtip',
			    'buttons': [
			    ],
				'bDestroy': true,
				'scrollY': "50vh",
				'scrollX': true,
				'paging': true 
			});

			/* $('body').click(function (event){
				closeModal();
			}); */
			
			var paymentMethod = document.getElementById('paymentMethod').value;
			if(paymentMethod=="creditcard")
				$("#ccDiv").show();
			else if(paymentMethod=="ach" || paymentMethod=="")
				$("#ccDiv").hide();
			
	        $(".nav-link").click(function () {
	            // remove active class from all tabs
	            $(".nav-link").removeClass("active");
	            // add active class to clicked tab
	            $(this).addClass("active");

	            // hide all content
	            $(".tab-pane").removeClass("active");
	            // show the targeted content
	            var target = $(this).data("target");
	            $(target).addClass("active");
	        });

	        $('.dataTables_filter input').attr('placeholder', 'Search items...');
		}); 	

		function calculateTotal(el,systemId,refNum,soId,shipmentNum,openAmt,discountAmount,discountDate,i){
			//debugger;
			let rowNum = $(el).data('rownum');
	   		var oTable = $('#InvoicePaymentTable').dataTable();

			var paymentMethod = $('#paymentMethod').val();
			var bankGUID = $('#bankList').val();

			$('#paymentMethod, #bankList, #paymentInvoices').removeClass('is-invalid');
			if (!paymentMethod || paymentMethod.trim() === "") {
				oTable.$('input[type="checkbox"]').prop('checked', false);
			    $('#paymentMethod').addClass('is-invalid').focus();
			    return false;
			}
			else if (!bankGUID || bankGUID.trim() === "") {
				oTable.$('input[type="checkbox"]').prop('checked', false);
			    $('#bankList').addClass('is-invalid').focus();
			    return false;
			}
			else{
    			var discountAmountOpen=0;
    			var disDate = new Date(discountDate);
    		    var mm=disDate.getMonth()+1;
    			if(parseInt(mm)<10)
    				mm='0'+mm;
    			
    			var dd=disDate.getDate();
    			if(parseInt(dd)<10)
    				dd='0'+dd;
    			
    			var dDate = mm + '-' + (dd) + '-' + disDate.getFullYear();

    			var currentDate = new Date(today);
    			var ddDate = new Date(dDate);
    			
    			if(ddDate < currentDate && allowDiscountAchPay == "Y")
    				discountAmountOpen=discountAmount;
    			else if(ddDate < currentDate)
    				discountAmountOpen=0;
    			else
    				discountAmountOpen=discountAmount;
    				
    			//var checkbox = document.getElementById('paymentCheckBox'+i).checked;
    			//const isChecked = $("#paymentCheckBox"+i).is(":checked");
    			const isChecked = el.checked;
    			if(isChecked){
    				rowNumArray.push(rowNum);
    				systemIdArray.push(systemId);
    				invoiceNoArray.push(refNum);
    				invoiceNoForModalArray.push(soId+"-"+shipmentNum);
    				openAmountArray.push(openAmt);
    				disAmountArray.push(discountAmountOpen);
    				openAmountArrayForPayment.push(openAmt);
    				disAmountArrayForPayment.push(discountAmountOpen);
    				
    				let finalAmt=parseFloat(openAmt)-parseFloat(discountAmountOpen);
    				invoiceTotalAmount=invoiceTotalAmount+finalAmt;
    				discountTotalAmount=discountTotalAmount+parseFloat(discountAmountOpen);
    			}
    			else{
    				//var index=openAmountArray.indexOf(openAmt);
    				let index = rowNumArray.indexOf(rowNum);
    				if(index > -1){
    					rowNumArray.splice(index, 1);
    					systemIdArray.splice(index,1);
    			  		invoiceNoArray.splice(index,1);
    					invoiceNoForModalArray.splice(index,1);
    			  		openAmountArray.splice(index,1);
    			  		disAmountArray.splice(index,1);
    			  		openAmountArrayForPayment.splice(index,1);
    			  		disAmountArrayForPayment.splice(index,1);
    				}				
    				
    				let finalAmt=parseFloat(openAmt)-parseFloat(discountAmountOpen);
    				invoiceTotalAmount=invoiceTotalAmount-finalAmt;
    				discountTotalAmount=discountTotalAmount-parseFloat(discountAmountOpen);
    			}
    			
    			var paymentMethod = document.getElementById('paymentMethod').value;
    			if(paymentMethod=="creditcard"){
    				var ccSurchargeFees=invoiceTotalAmount*ccSurchargeFeesPercent/100;
    				//invoiceTotalAmount=invoiceTotalAmount+ccSurchargeFees;
    				$('#ccSurchargeFees').val(ccSurchargeFees.toFixed(2));
    				$('#totalPaymentAmount').val(invoiceTotalAmount.toFixed(2));
    			}
    			else{
    				$('#totalPaymentAmount').val(invoiceTotalAmount.toFixed(2));
    			}
        	}

	   	 	console.log("RowNum Array >>>> ", rowNumArray);
	   	    console.log("SystemId Array >>>> ", systemIdArray);
	   	 	console.log("InvoiceNo Array >>>> ", invoiceNoArray);
	   	    console.log("InvoiceNo For Modal Array >>>> ", invoiceNoForModalArray);
	   	 	console.log("OpenAmount Array >>>> ", openAmountArray);
	   	 	console.log("DisAmount Array >>>> ", disAmountArray);
	   	 	console.log("OpenAmount Array >>>> ", openAmountArrayForPayment);
	   	 	console.log("DisAmount Array For Payment >>>> ", disAmountArrayForPayment);
		}
		
		
		function getBankList(){
			var paymentMethod = $('#paymentMethod').val();
			$('#paymentMethod, #bankList, #paymentInvoices').removeClass('is-invalid');
			if (!paymentMethod || paymentMethod.trim() === "") {
			    $('#paymentMethod').addClass('is-invalid').focus();
			    return false;
			}
			else{
				window.location = "../customerPortal/A_CP_InvoicePayment.jsp?pageName=InvoicePayment&paymentMethod="+paymentMethod+"&allowDiscountOnCCPayment="+allowDiscountOnCCPayment;	 			

				/* $.ajax({
					url:"../customerPortal/A_CP_InvoicePaymentAction.jsp?param=BankList&paymentMethod="+paymentMethod,
	 			 	type : "POST",
	 				dataType: "text",
	 				success: function (response) {
	 					$('#bankList').html(response);
	 				},
	 			 	failure: function (response) {
	 			    }
	 			}); */
			}
		}

        function popupForMakePayment(){ 
        	debugger;
        	//$('#payNowBtn').prop('disabled', false);
        	$('#payNowBtn').show();
			var paymentMethod = document.getElementById('paymentMethod').value;
			var bankGUID = document.getElementById('bankList').value;
			var totalPaymentAmount = document.getElementById('totalPaymentAmount').value;

			$('#paymentMethod, #bankList, #paymentInvoices').removeClass('is-invalid');
			if(paymentMethod == "" || paymentMethod == null) {
				$('#paymentMethod').addClass("is-invalid").focus();
				window.location.reload();
				return false;
			}
        		else if(bankGUID == "" || bankGUID == null) {
        			$('#bankList').addClass("is-invalid").focus();
				return false;
			}
			/*else if(totalPaymentAmount == "" || totalPaymentAmount == null) {
				$('#totalPaymentAmount').addClass("is-invalid").focus();
				return false;
			}*/
			else if($('.rowCheck:checked').length === 0) {
				$('#HeaderMsg').html("Please select at least one invoice.");
		        return false;
		    }
			else{
    	  		$('#errorMsg').empty();
    	    	$('#modalTotalPaymentAmount').text('');
	    	    $('#modalTotalDiscountAmount').text('');
    	    	
    		    let nf = new Intl.NumberFormat('en-US');
    	    	$('#modalTotalPaymentAmount').text('$ '+nf.format(totalPaymentAmount));
	    	    $('#modalTotalDiscountAmount').text('$ '+nf.format(discountTotalAmount.toFixed(2)));
    		    document.getElementById('modalBankGUID').value=bankGUID;
				
    	   		$('#modalInvoiceTable').find('tbody').detach();
    	    	$('#modalInvoiceTable').append($('<tbody>'));
    	    	var row = "";
    	    	for (var i = 0; i < invoiceNoForModalArray.length; i++) {
					row = '<tr>'+
				  				'<td align="center">'+ invoiceNoForModalArray[i] +'</td>'+ 
								'<td align="right">$'+ nf.format(openAmountArray[i]) +'</td>'+
								'<td align="right">$'+ nf.format(disAmountArray[i]) +'</td>'+
					   		'</tr>';
					   		
					$('#modalInvoiceTable').append(row);
    	    	}
				
    	    	$('#modalInvoiceTable').DataTable({
    				'pageLength': 10,
    				'dom': 'Blfrtip',
    		    	'buttons': [
    		            //'copy', 'csv', 'excel'
    		        	],
    				'bDestroy': true
    			});

    	    	$('#PaymentModal').modal('show');
			}
        }

	   	function closeModal() {
	   		//debugger;
	   		$('#HeaderMsg').html('');
	   		$('#PaymentModal').modal('hide');
	   		
	   		if (paymentSuccess) {
	   			window.location.reload();
	   			var oTable = $('#InvoicePaymentTable').dataTable();
	   			oTable.$('input[type="checkbox"]').prop('checked', false);
		   		rowNumArray=[];
		   		systemIdArray=[];
				invoiceNoArray=[];
				invoiceNoForModalArray=[];
				openAmountArray=[];
		  		disAmountArray=[];
				openAmountArrayForPayment=[];
		  		disAmountArrayForPayment=[];
		  		datatableLength=[];
				invoiceTotalAmount=0;
				discountTotalAmount=0;
				$('#ccSurchargeFeesPercent, #ccSurchargeFees, #totalPaymentAmount').val('');
	   	    }
		}

	   	
		function payNow(){
			debugger;
			var oTable = $('#InvoicePaymentTable').dataTable();
			var parameters;
	  		$('#payNowBtn').hide();
			//$('.overLay').show();
			var totalPaymentAmount = document.getElementById('totalPaymentAmount').value;
			var totalDiscountAmount = document.getElementById('modalTotalDiscountAmount').value;
			var paymentMethod = document.getElementById('paymentMethod').value;
			var ccSurchargeFeesPercent = document.getElementById('ccSurchargeFeesPercent').value;
			//var bankGUID = document.getElementById('bankList').value;
			//var bankGUID ="23354792df0ba951-9ba8-49bc-b414-3ea8e0d82356";
			var bankGUID = document.getElementById('modalBankGUID').value;
			if(paymentMethod == "ach"){
				parameters="param=MakePayment&paymentMethod="+paymentMethod+"&totalPaymentAmount="+totalPaymentAmount+
							"&totalDiscountAmount="+discountTotalAmount+"&bankGUID="+bankGUID+"&systemIdArray="+systemIdArray+
							"&invoiceNoArray="+invoiceNoArray+"&openAmountArray="+openAmountArrayForPayment+"&disAmountArray="+disAmountArrayForPayment;
			}
			else{
				parameters="param=MakePayment&paymentMethod="+paymentMethod+"&totalPaymentAmount="+totalPaymentAmount+
							"&totalDiscountAmount="+discountTotalAmount+"&bankGUID="+bankGUID+"&systemIdArray="+systemIdArray+
							"&invoiceNoArray="+invoiceNoArray+"&openAmountArray="+openAmountArrayForPayment+"&disAmountArray="+disAmountArrayForPayment+"&ccSurchargeFeesPercent="+ccSurchargeFeesPercent;
			} 
			
			$.ajax({
 			 	url: "../customerPortal/A_CP_InvoicePaymentAction.jsp",
 				type : "POST",
 				dataType: "text",
 				data: parameters,
				beforeSend: function() {
					$('.overLay').show();
				},
 				success: function (response) {
					$('#errorMsg').html(response);
					paymentSuccess = true;

					rowNumArray=[];
					systemIdArray=[];
					invoiceNoArray=[];
					invoiceNoForModalArray=[];
					openAmountArray=[];
			  		disAmountArray=[];
					openAmountArrayForPayment=[];
			  		disAmountArrayForPayment=[];
			  		datatableLength=[];
					invoiceTotalAmount=0;
					discountTotalAmount=0;
					$('#ccSurchargeFeesPercent, #ccSurchargeFees, #totalPaymentAmount').val('');
					oTable.$('input[type="checkbox"]').prop('checked', false);
 				},
				error: function(error) {
					console.error(xhr.responseText);
		            alert("Payment failed. Please try again.");
				},
				complete: function() {
					$('.overLay').hide();
				}
 			});
		}
		
		function checkInvoices(){
			//debugger;
			var paymentMethod = $('#paymentMethod').val();
			var bankGUID = $('#bankList').val();
			
			$('#paymentMethod, #bankList, #paymentInvoices').removeClass('is-invalid');
			if (!paymentMethod || paymentMethod.trim() === "") {
			    $('#paymentMethod').addClass('is-invalid').focus();
			    return false;
			}
			else if (!bankGUID || bankGUID.trim() === "") {
			    $('#bankList').addClass('is-invalid').focus();
			    return false;
			}
			else{ 
				
				rowNumArray=[];
				systemIdArray=[];
				invoiceNoArray=[];
				invoiceNoForModalArray=[];
				openAmountArray=[];
		  		disAmountArray=[];
				openAmountArrayForPayment=[];
		  		disAmountArrayForPayment=[];
		  		datatableLength=[];
				invoiceTotalAmount=0;
				discountTotalAmount=0;
	
				var paymentInvoices = document.getElementById('paymentInvoices').value;
				var gridTable = document.getElementById("InvoicePaymentTable");
				var oTable = $('#InvoicePaymentTable').dataTable();
				datatableLength = oTable.fnGetData();
	
				if(paymentInvoices == "" || paymentInvoices == null) {
					$('#paymentInvoices').addClass('is-invalid').focus();
					
					rowNumArray=[];
					systemIdArray=[];
					invoiceNoArray=[];
					invoiceNoForModalArray=[];
					openAmountArray=[];
			  		disAmountArray=[];
					openAmountArrayForPayment=[];
			  		disAmountArrayForPayment=[];
					invoiceTotalAmount=0;
					discountTotalAmount=0;
					$('#ccSurchargeFeesPercent, #ccSurchargeFees, #totalPaymentAmount').val('');
					
					for(i=0; i<datatableLength.length; i++){
						oTable.$("#paymentCheckBox"+i).prop("checked", false);
					}
					
					//location.reload();
					return false;
				}
				else if(paymentInvoices=="all"){
					for(i=0; i<datatableLength.length; i++){
						oTable.$("#paymentCheckBox"+i).prop("checked", false);
					}
					
					for(i=0; i<datatableLength.length; i++){
				        //oTable.$("input[type='checkbox']").attr('checked', $(this.checked)); 
				        oTable.$("#paymentCheckBox"+i).prop("checked", true);
				        calculateValues(i);
					}
				}
				else if(paymentInvoices=="laststatementinvoices"){
					for(i=0; i<datatableLength.length; i++){
						oTable.$("#paymentCheckBox"+i).prop("checked", false);
					}
	
			  		var lastDateOfPreviousMonth = new Date();
			  		lastDateOfPreviousMonth.setDate(0);
					
					var satementMaxDate = new Date(maxStatementDate);
					
					var mm=satementMaxDate.getMonth()+1;
					if(parseInt(mm)<10)
						mm='0'+mm;
					
					var dd=satementMaxDate.getDate();
					if(parseInt(dd)<10)
						dd='0'+dd;
					
					var stmtDate = mm + '-' + (dd) + '-' + satementMaxDate.getFullYear();
					var stmtMaxDate = new Date(stmtDate);
					
					var gridTable = new DataTable('#InvoicePaymentTable');
					for(i=0; i<datatableLength.length; i++){
						var row = gridTable.row(i);
						var invoiceDate=row.cell(i,4).data();
	
						var qqq = new Date(invoiceDate);
						var mmm = qqq.getMonth()+1;
						var ddd = qqq.getDay();
						var yyy = qqq.getFullYear();
						var iDate = new Date(mmm,ddd,yyy);
	
						var invDate = new Date(invoiceDate);
					    var invMonth=invDate.getMonth()+1;
						if(parseInt(invMonth)<10)
							invMonth='0'+invMonth;
						
						var invDays=invDate.getDate();
						if(parseInt(invDays)<10)
							invDays='0'+invDays;
						
						var invBeforeDate = invMonth + '-' + (invDays) + '-' + invDate.getFullYear();
						var invoiceFinalDate = new Date(invBeforeDate);
						
						var q = new Date(satementMaxDate);
						var m = q.getMonth()+1;
						var d = q.getDay();
						var y = q.getFullYear();
						var sDate = new Date(m,d,y);
	
					    //if (qqq <= satementMaxDate) {
					    if (qqq <= lastDateOfPreviousMonth){
					    	oTable.$("#paymentCheckBox"+i).prop("checked", true);
							calculateValues(i);
	    				}
					}
				}
					
				var paymentMethod = document.getElementById('paymentMethod').value;
				if(paymentMethod=="creditcard"){
					var ccSurchargeFees=invoiceTotalAmount*ccSurchargeFeesPercent/100;
					//invoiceTotalAmount=invoiceTotalAmount+ccSurchargeFees;
					$('#ccSurchargeFees').val(ccSurchargeFees.toFixed(2));
					$('#totalPaymentAmount').val(invoiceTotalAmount.toFixed(2));
				}else{ 
					$('#totalPaymentAmount').val(invoiceTotalAmount.toFixed(2));
				}
			}
				
	   	 	console.log("RowNum Array >>>> ", rowNumArray);
	   	    console.log("SystemId Array >>>> ", systemIdArray);
	   	 	console.log("InvoiceNo Array >>>> ", invoiceNoArray);
	   	    console.log("InvoiceNo For Modal Array >>>> ", invoiceNoForModalArray);
	   	 	console.log("OpenAmount Array >>>> ", openAmountArray);
	   	 	console.log("DisAmount Array >>>> ", disAmountArray);
	   	 	console.log("OpenAmount Array >>>> ", openAmountArrayForPayment);
	   	 	console.log("DisAmount Array For Payment >>>> ", disAmountArrayForPayment);
        }
			
		function calculateValues(i){
			//debugger;
			var rowNum;
			var systemId;
			var invoiceNo,invoiceNoForModal;
			var openAmount=0;
			var discountAmount=0;
			var discountAmountOpen=0;
			var discountDate;

			var table = new DataTable('#InvoicePaymentTable');
			var row = table.row(':eq('+i+')');
			var data = row.data();
			var rowNode = table.row(i).node();
			rowNum = $(rowNode).find('.rowCheck').data('rownum');
		    systemId=data[1];
		    invoiceNo=data[2];
		    invoiceNoForModal=data[3];
		    openAmount=data[9].replace(",","");
		    discountAmount=data[10].replace(",","");
		    discountDate=data[11];
		    
			var disDate = new Date(discountDate);
		    var mm=disDate.getMonth()+1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=disDate.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			
			var dDate = mm + '-' + (dd) + '-' + disDate.getFullYear();

			var currentDate = new Date(today);
			var ddDate = new Date(dDate);
			
			if(ddDate < currentDate && allowDiscountAchPay == "Y")
				discountAmountOpen=discountAmount;
			else if(ddDate < currentDate)
				discountAmountOpen=0;
			else
				discountAmountOpen=discountAmount;

		    rowNumArray.push(rowNum);
			systemIdArray.push(systemId);
			invoiceNoArray.push(invoiceNo);
			invoiceNoForModalArray.push(invoiceNoForModal);
			openAmountArray.push(openAmount);
			disAmountArray.push(discountAmountOpen);
			openAmountArrayForPayment.push(openAmount.replace(",",""));
			disAmountArrayForPayment.push(discountAmountOpen.toString().replace(",",""));
		    
			let finalAmt=parseFloat(openAmount)-parseFloat(discountAmountOpen);
			invoiceTotalAmount=invoiceTotalAmount+finalAmt;
			discountTotalAmount=discountTotalAmount+parseFloat(discountAmountOpen);
		}
		
		
		function getPaymentPage(){
			window.location = "../customerPortal/A_CP_InvoicePayment.jsp?pageName=InvoicePayment";	 			
		}

		function getPastPaymentPage(){
			window.location = "../customerPortal/A_CP_PastPayment.jsp?pageName=InvoicePayment";	 			
		}
		
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}
		
		
		function viewDetails(paymentId){
	       	debugger;
	   		$('#DetailsTable').find('tbody').detach();
	    	$('#DetailsTable').append($('<tbody>'));
			//$("#loader").show();
           	let nf = new Intl.NumberFormat('en-US');
            $.ajax({
				url : "../customerPortal/A_CP_PastPaymentAction.jsp?param=GetDetails&paymentId="+paymentId,
	    		type : 'POST',
	    		dataType : 'json',
	    		contentType : 'application/json',
	            success: function(response) {
	            	//$("#loader").hide();
	    		    var data = response.ChildTableList;
	    		    var childDataTable = "";
	    		    if(data.length != 0){
	    		    	$.each(data, function (key, row) {
		    		    	let paymentAmt=parseFloat(row.paymentAmount).toFixed(2);
			    			let discountAmt=parseFloat(row.discountAmount).toFixed(2);
			    			var formattedPaymentAmount = paymentAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
			    			var formattedDiscountAmount = discountAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
		    		    	childDataTable = '<tr class="no-click">'+
												'<td align="left">'+row.refNum+'</td>'+
		    									'<td align="left" class="text-left">'+row.invoiceDate+'</td>'+
		    									'<td align="right" class="text-right">'+addCommas(formattedPaymentAmount)+'</td>'+
		    									'<td align="right" class="text-right">'+addCommas(formattedDiscountAmount)+'</td>'+
		    								'</tr>';
		    		    	$('#DetailsTable').append(childDataTable);
	    		    	});
	    			}
	    			$('#DetailsTable').DataTable({
	    				'pageLength': 25,
	    				'dom': 'Blfrtip',
	    			    'buttons': [
	    			            /*'copy', 'csv', 'excel'*/
	    			            /* 'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5' */
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
	    				'paging': true,
	    				//'stateSave': true,
	    				'scrollY': "60vh",
	    				'scrollX': true,
	    				'paging': true 
	    			});

           		},
	            error: function() {
	            	//$("#loader").hide();
				}
	   		});
	    	$('#DetailsTableModal').modal('show');
		}
		
		function addCommas(nStr){
		    nStr += '';
		    var x = nStr.split('.');
		    var x1 = x[0];
		    var x2 = x.length > 1 ? '.' + x[1] : '';
		    var rgx = /(\d+)(\d{3})/;
		    while (rgx.test(x1)) {
		        x1 = x1.replace(rgx, '$1' + ',' + '$2');
		    }
		    return x1 + x2;
		}
		
		
		function check(){
			var allcheck = document.PaymentForm.checkAll;
			if(allcheck.checked == true){
			for(i=0; i<document.PaymentForm.elements.length; i++){
				var table = document.getElementsByTagName("input"); 
					if(document.PaymentForm.elements[i].type=="checkbox" && document.PaymentForm.elements[i].name!="checkAll"){
						document.PaymentForm.elements[i].checked=true;
					}
				}
			}
			else{
				for(i=0; i<document.PaymentForm.elements.length; i++){
					var table = document.getElementsByTagName("input"); 
					if(document.PaymentForm.elements[i].type=="checkbox" && document.PaymentForm.elements[i].name != "checkAll" ){
						document.PaymentForm.elements[i].checked=false;
					}
				}
			}
		}
		
	</script>

<%!

	public ArrayList<HashMap<String, String>> getOpenInvoiceData(String custKey,String paymentMethod,String allowDiscountOnCCPayment,
															String allowDiscountAchPay){	
		String sqlQuery="",filterString = "",orderNo="",shipmentNo="",invoiceFilePath="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct ar.REF_NUM_SYSID,ar.REF_NUM, "
							+" case when to_char(ar.tran_id)='0' then ar.ref_num else to_char(ar.tran_id)  end  as so_id, "
							+" ar.shipment_num,ao.REF_DATE as invoice_date, "
							+" sa.cust_name, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as ship_to, sh.CUST_PO, "
							+" ar.ref_type, ar.amount,ar.open_amt,ar.DISCOUNT_AMOUNT,ar.DISCOUNT_AMOUNT_OPEN, ar.DISCOUNT_DATE, ar.due_date "
							+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa, aropen ao " 
							+" where ar.TRAN_ID=sh.so_id(+) "
							+" and ar.TRAN_ID=sa.TRAN_ID(+) "
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
				            +" and ar.open_amt=ao.open_amt "
							+" and ar.open_amt!=0 " 
							+" and ar.ref_type in ('IN','CM','DM','FC','CI','CA') and ar.cust_key='"+custKey+"' "
							+" order by ao.REF_DATE ";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector refNumSysIdVector = new Vector();
			Vector refNumVector = new Vector();
			Vector soIdVector = new Vector();
			Vector shipmentNumVector = new Vector();
			Vector invoiceDateVector = new Vector();
			Vector custNameVector = new Vector();
			Vector shipToVector = new Vector();
			Vector custPoVector = new Vector();
			Vector refTypeVector = new Vector();
			Vector amountVector = new Vector();
			Vector openAmtVector = new Vector();
			Vector discountAmountVector = new Vector();
			Vector discountAmountOpenVector = new Vector();
			Vector discountDateVector = new Vector();
			Vector dueDateVector = new Vector();
			if (ht != null && ht.size() > 0) {
				refNumSysIdVector = (Vector)ht.get("REF_NUM_SYSID");
				refNumVector = (Vector)ht.get("REF_NUM");
				soIdVector = (Vector)ht.get("SO_ID");
				shipmentNumVector = (Vector)ht.get("SHIPMENT_NUM");
				invoiceDateVector = (Vector)ht.get("INVOICE_DATE");
				custNameVector = (Vector)ht.get("CUST_NAME");
				shipToVector = (Vector)ht.get("SHIP_TO");
				custPoVector = (Vector)ht.get("CUST_PO");
				refTypeVector = (Vector)ht.get("REF_TYPE");
				amountVector = (Vector)ht.get("AMOUNT");
				openAmtVector = (Vector)ht.get("OPEN_AMT");
				discountAmountVector = (Vector)ht.get("DISCOUNT_AMOUNT");
				discountAmountOpenVector = (Vector)ht.get("DISCOUNT_AMOUNT_OPEN");
				discountDateVector = (Vector)ht.get("DISCOUNT_DATE");
				dueDateVector = (Vector)ht.get("DUE_DATE");
			}
	        if (refNumSysIdVector.size() > 0) {
	        	for (int i = 0; i < refNumSysIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("refNumSysId", refNumSysIdVector.get(i).toString());
	        		temp.put("refNum", refNumVector.get(i).toString());
	        		temp.put("soId", soIdVector.get(i).toString());
					temp.put("shipmentNum", shipmentNumVector.get(i).toString());
					temp.put("invoiceDate", invoiceDateVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("shipTo", shipToVector.get(i).toString());
					temp.put("custPo", custPoVector.get(i).toString());
					temp.put("refType", refTypeVector.get(i).toString());
					temp.put("amount", amountVector.get(i).toString());
					temp.put("openAmt", openAmtVector.get(i).toString());
					temp.put("discountAmount", discountAmountVector.get(i).toString());
					
 					if(!discountDateVector.get(i).toString().trim().equals("") && discountDateVector.get(i).toString().trim()!=null){
 						//Utils.log("step 1 "+refNumVector.get(i).toString());
 						SimpleDateFormat sdf=new SimpleDateFormat("MM-dd-yyyy");
 						//Utils.log("step 2 ");
 						Date date=new Date();
 						//Utils.log("step 3 ");

						String currentDateString=sdf.format(date);
 						//Utils.log("step 4 currentDateString : "+currentDateString);

						Date discountDate = sdf.parse(discountDateVector.get(i).toString().trim());
						//Utils.log("step 5 discountDate : "+discountDate);
						Date currentDate = sdf.parse(currentDateString);
						//Utils.log("step 6 : "+currentDate);
						
						int result = discountDate.compareTo(currentDate);
						//Utils.log("step 7 result : "+result);
						if(result<0 && allowDiscountAchPay.equalsIgnoreCase("Y")){
							//Utils.log("step 8 temp : "+discountAmountOpenVector.get(i).toString());
							temp.put("discountAmountOpen", discountAmountOpenVector.get(i).toString());
							//Utils.log("step 9 temp : "+discountAmountOpenVector.get(i).toString());
						}
						else if(result<0 && allowDiscountAchPay.equalsIgnoreCase("N")){
							//Utils.log("step 10 temp : ");
							temp.put("discountAmountOpen", "0");
							//Utils.log("step 11 temp : ");
						}
						else if(paymentMethod.equalsIgnoreCase("creditcard") && allowDiscountOnCCPayment.equalsIgnoreCase("N")){
							//Utils.log("step 12 temp : ");
							temp.put("discountAmountOpen", "0");
							//Utils.log("step 13 temp : ");
						}
						else{
							//Utils.log("step 14 temp : "+discountAmountOpenVector.get(i).toString());
							temp.put("discountAmountOpen", discountAmountOpenVector.get(i).toString());
							//Utils.log("step 15 temp : "+discountAmountOpenVector.get(i).toString());
						}
					}
 					else{
 						temp.put("discountAmountOpen", "0");
 					}
					
					temp.put("discountDate", discountDateVector.get(i).toString());
					temp.put("dueDate", dueDateVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}


	public ArrayList<HashMap<String, String>> getOpenInvoiceListWithAPI(String customerId,String paymentMethod,String allowDiscountOnCCPayment,String allowDiscountAchPay) {	
		String sqlQuery="",filterString = "",orderNo="",shipmentNo="",invoiceFilePath="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du=new DistUtils();
			FileReader reader=new FileReader("eTechLogix.properties");  
		    Properties prop=new Properties();  
		    prop.load(reader);    
		    String url=prop.getProperty("AgilityUrl");
			
			JSONObject childBody=new JSONObject();
			childBody.put("LoginID", "API");
			childBody.put("Password", "~Zrwcetech123");
			JSONObject mainBody=new JSONObject();
			mainBody.put("request", childBody);
			String loginUrl = url+"Session/Login";

			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				Utils.log("Login Response >>>> "+loginRespObj);
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				Utils.log("Context Id >>>> "+contextId);
				String systemId = loginResp.get("InitialBranch").toString();
				//String systemId = "0302PHX";
				Utils.log("System Id >>>> "+systemId);

			    JSONObject jsonObj=new JSONObject();
				jsonObj.put("CustomerID", customerId);
				JSONObject requestObject=new JSONObject();
				requestObject.put("request", jsonObj);
				Utils.log("Invoice List Request Object >>>> " + requestObject);
				
				String invoicesListUrl = url+"AccountsReceivable/BalancesList";
				Utils.log("Invoices List Url :: " + invoicesListUrl);
		    	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObject,invoicesListUrl,contextId,systemId);
		    	if(responseObj != null){
			    	JSONObject res = (JSONObject)responseObj.get("response");
			    	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
			    		JSONObject balanceResponse = (JSONObject)res.get("BalanceResponse");
			    		if(balanceResponse != null){
			        		JSONObject dsARBalanceResponse = (JSONObject)balanceResponse.get("dsARBalanceResponse");
			        		if(dsARBalanceResponse != null){
			        			JSONArray dtARBalanceHeaderResponseArray = (JSONArray)dsARBalanceResponse.get("dtARBalanceHeaderResponse");
			        			if(dtARBalanceHeaderResponseArray != null){
			        	    		for(int i=0;i<dtARBalanceHeaderResponseArray.size();i++){
			        	    			JSONObject headerObj = (JSONObject)dtARBalanceHeaderResponseArray.get(i);
		        		        		JSONArray dtARBalanceDetailResponseArray = (JSONArray)headerObj.get("dtARBalanceDetailResponse");
					        			if(dtARBalanceDetailResponseArray != null){
					        	    		for(int j=0;j<dtARBalanceDetailResponseArray.size();j++){
					        	    			JSONObject detailObj = (JSONObject)dtARBalanceDetailResponseArray.get(j);
				        		        		String invoiceNo=detailObj.get("InvoiceNumber").toString().trim();
				        		        		String finalInvoiceNo = invoiceNo.substring(0,3);
				        		        		if(!finalInvoiceNo.equalsIgnoreCase("DP-") && !finalInvoiceNo.equalsIgnoreCase("DM-")){
						        	    			temp=new HashMap<String, String>();
					        		        		SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
					        		        		SimpleDateFormat sdf=new SimpleDateFormat("MM-dd-yyyy");

						        	    			temp.put("refNumSysId", Utils.removeNull(detailObj.get("InvoiceBranchID")+""));
						        	    			temp.put("refNum", Utils.removeNull(detailObj.get("InvoiceNumber")+""));
					        		        		temp.put("soId", Utils.removeNull(detailObj.get("TransactionID")+""));
					        						temp.put("shipmentNum", Utils.removeNull(detailObj.get("ShipmentNumber")+""));
					        						
					        	 					if(!Utils.removeNull(detailObj.get("InvoiceDate").toString().trim()).equals("") 
					        	 							&& !Utils.removeNull(detailObj.get("InvoiceDate").toString().trim()).equals("0")
					        	 							&& Utils.removeNull(detailObj.get("InvoiceDate")+"").trim()!=null){
						        						Date invoiceDate = dt.parse(Utils.removeNull(detailObj.get("InvoiceDate").toString().trim()));
						        						temp.put("invoiceDate", sdf.format(invoiceDate));
					        	 					}
					        	 					else{
					        	 						temp.put("invoiceDate", "");
					        	 					}
					        	 					
						        					temp.put("custName", Utils.removeNull(detailObj.get("ShipToName")+""));
					        						temp.put("shipTo", Utils.removeNull(detailObj.get("ShipToAddress1")+"")+" "+Utils.removeNull(detailObj.get("ShipToCity")+"")+" "+
					        											Utils.removeNull(detailObj.get("ShipToState")+"")+" "+Utils.removeNull(detailObj.get("ShipToZip")+""));
					        						temp.put("custPo", Utils.removeNull(detailObj.get("CustomerPO")+""));
					        						//temp.put("refType", obj.get("").toString());
					        						temp.put("amount", Utils.removeNull(detailObj.get("InvoiceTotal")+""));
					        						temp.put("openAmt", Utils.removeNull(detailObj.get("InvoiceBalance")+""));
					        						temp.put("discountAmount", Utils.removeNull(detailObj.get("TermsDiscountAmount")+""));
					        						
					        	 					if(!Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()).equals("") 
					        	 							&& !Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()).equals("0")
					        	 							&& Utils.removeNull(detailObj.get("TermsDiscountDate")+"").trim()!=null){
					        	 						Date date=new Date();
					        							String currentDateString=sdf.format(date);
					        							
					        							Date discountDateStr = dt.parse(Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()));
					        							String discountDateString=sdf.format(discountDateStr);
					        							Date discountDate = sdf.parse(discountDateString);
					        							Date currentDate = sdf.parse(currentDateString);
					        							
					        							String discountAmountOpen="";
					        							if(allowDiscountAchPay.equalsIgnoreCase("Y")){
						        							String discountAmountOpenQuery = " select DISCOUNT_AMOUNT_OPEN from aropendt where REF_NUM='"+Utils.removeNull(detailObj.get("InvoiceNumber")+"")+"' ";
															discountAmountOpen=Utils.removeNull(du.getFieldInfoPro2(discountAmountOpenQuery));
					        							}
					        							else{
					        								discountAmountOpen=Utils.removeNull(detailObj.get("TermsDiscountAmount")+"");
					        							}

					        							int result = discountDate.compareTo(currentDate);
					        							if(result<0 && allowDiscountAchPay.equalsIgnoreCase("Y")){
					        								temp.put("discountAmountOpen", discountAmountOpen);
					        							}
					        							else if(result<0 && allowDiscountAchPay.equalsIgnoreCase("N")){
					        								temp.put("discountAmountOpen", "0");
					        							}
					        							else if(paymentMethod.equalsIgnoreCase("creditcard") && allowDiscountOnCCPayment.equalsIgnoreCase("N")){
					        								temp.put("discountAmountOpen", "0");
					        							}
					        							else{
					        								temp.put("discountAmountOpen", discountAmountOpen);
					        							}
					        						}
					        	 					else{
					        	 						temp.put("discountAmountOpen", "0");
					        	 					}

					        	 					if(!Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()).equals("") 
					        	 							&& !Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()).equals("0")
					        	 							&& Utils.removeNull(detailObj.get("TermsDiscountDate")+"").trim()!=null){
						        						Date discountDate = dt.parse(Utils.removeNull(detailObj.get("TermsDiscountDate").toString().trim()));
						        						temp.put("discountDate", sdf.format(discountDate));
					        	 					}
					        	 					else{
					        	 						temp.put("discountDate", "");
					        	 					}
					        	 					
					        	 					if(!Utils.removeNull(detailObj.get("InvoiceDueDate").toString().trim()).equals("") 
					        	 							&& !Utils.removeNull(detailObj.get("InvoiceDueDate").toString().trim()).equals("0")
					        	 							&& Utils.removeNull(detailObj.get("InvoiceDueDate")+"").trim()!=null){
							        					Date dueDate = dt.parse(Utils.removeNull(detailObj.get("InvoiceDueDate").toString().trim()));
						        	 					temp.put("dueDate", sdf.format(dueDate));
					        	 					}
					        	 					else{
					        	 						temp.put("dueDate", "");
					        	 					}
					        	 					
					        	 					listData.add(temp);				        		        			
				        		        		}
					        	    		}
					        			}
		        						
			        	    		}
			        			}
			        		}
			    		}
			    	}
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}

	
	String getMaxStatementDate(String customerId){
		String maxStatementDate="";
		try{
			DistUtils du=new DistUtils();
			maxStatementDate = Utils.removeNull(du.getFieldInfo(" select max(STATEMENT_DATE) as STATEMENT_DATE from DMSI_CUSTOMER_STATEMENTS where ACCNO='"+customerId+"' "));
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}
		return maxStatementDate;

	}
	
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

	
	public ArrayList<HashMap<String, String>> getPastPaymentData(String custKey) {	
		String sqlQuery="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select PAYMENT_ID_NUM,PAYMENT_DATE,PAYMENT_AMOUNT,PAYMENT_METHOD "
						+" from ARCASH "
						+" where CREATED_BY='API' and REF_TYPE='CA' and TRANS_CODE='CA' " 
						+" and PAYMENT_DATE>=sysdate-365 and cust_key='"+custKey+"' ";
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector paymentIdVector = new Vector();
			Vector paymentDateVector = new Vector();
			Vector paymentAmountVector = new Vector();
			Vector paymentMethodVector = new Vector();
			if (ht != null && ht.size() > 0) {
				paymentIdVector = (Vector) ht.get("PAYMENT_ID_NUM");
				paymentDateVector = (Vector) ht.get("PAYMENT_DATE");
				paymentAmountVector = (Vector) ht.get("PAYMENT_AMOUNT");
				paymentMethodVector = (Vector) ht.get("PAYMENT_METHOD");
			}
	        if (paymentIdVector.size() > 0) {
	        	for (int i = 0; i < paymentIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("paymentId", paymentIdVector.get(i).toString());
					temp.put("paymentDate", paymentDateVector.get(i).toString());
					temp.put("paymentAmount", paymentAmountVector.get(i).toString());
					temp.put("paymentMethod", paymentMethodVector.get(i).toString());
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
