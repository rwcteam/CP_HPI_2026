<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>

<%@page import="javax.ws.rs.core.MediaType" %>
<%@page import="java.net.URL" %>
<%@page import="java.net.HttpURLConnection" %>
<%@page import="java.security.cert.CertificateException" %>
<%@page import="java.security.cert.X509Certificate" %>

<%@page import="javax.net.ssl.HostnameVerifier" %>
<%@page import="javax.net.ssl.HttpsURLConnection" %>
<%@page import="javax.net.ssl.SSLContext" %>
<%@page import="javax.net.ssl.SSLSession" %>
<%@page import="javax.net.ssl.TrustManager" %>
<%@page import="javax.net.ssl.X509TrustManager" %>

<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>
<%-- <%@page import="org.json.*" %>
<%@page import="jakarta.servlet.http.Part"%>
<%@page import="jakarta.servlet.annotation.MultipartConfig"%> --%>


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
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId >>>> " + customerId);
	
	HashMap<String, String> userDetailsMap = getUserDetails(customerId.trim());
	String customerFirstName=Utils.removeNull(userDetailsMap.get("firstName").toString());
	String customerLastName=Utils.removeNull(userDetailsMap.get("lastName").toString());
	String customerEmailId=Utils.removeNull(userDetailsMap.get("emailId").toString());
	String allowDiscountOnCCPayment = Utils.removeNull(userDetailsMap.get("allowDiscountOnCCPayment").toString());
	Utils.log("allowDiscountOnCCPayment >>>> " + allowDiscountOnCCPayment);
	String allowDiscountAchPay = Utils.removeNull(userDetailsMap.get("allowDiscountAchPay").toString());
	Utils.log("allowDiscountAchPay >>>> " + allowDiscountAchPay);
	
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	FileReader reader=new FileReader("eTechLogix.properties");  
    Properties prop=new Properties();  
    prop.load(reader);    
    String url=prop.getProperty("AgilityUrl");
    String loginUrl = url+"Session/Login";
    
	String param=request.getParameter("param");
	Utils.log("Param  >>>> " + param);
	
	JSONObject childBody=new JSONObject();
	childBody.put("LoginID", "API");
	childBody.put("Password", "~Zrwcetech123");
	JSONObject mainBody=new JSONObject();
	mainBody.put("request", childBody);
	
	if(param.equalsIgnoreCase("BankList")){
		try {
			String output="";
			String paymentMethod = request.getParameter("paymentMethod");
			
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
				
				Utils.log("ACH Bank List Request Object >>>> " + requestObject);
				JSONObject loginRespObj = getContextId(loginUrl,mainBody);
				if(loginRespObj != null){
					JSONObject loginResp = (JSONObject)loginRespObj.get("response");
					String contextId = loginResp.get("SessionContextId").toString();
					Utils.log("Context Id >>>> "+contextId);
					String systemId = loginResp.get("InitialBranch").toString();
					Utils.log("System Id >>>> "+systemId);

					String bankListUrl = url+"AccountsReceivable/CustomerACHBankList";
		        	JSONObject responseObj = agilityPublicAccountsReceivableService(bankListUrl,requestObject,contextId,systemId);
		        	if(responseObj != null){
			        	Utils.log("ACH Bank List Response >>>> "+responseObj);
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
			            	    			bankListBuffer.append("<option value=\""+obj.get("BankGUID").toString()+"\">"+obj.get("BankName").toString() +" : "+obj.get("BankAcctName").toString()+" : "+obj.get("TruncatedAccountNumber").toString()+" </option>");
			            	    		}
			            			}
			            		}
			        		}
			        	}
		        	}
				
				}
			}
			else{
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
				
				Utils.log("CC Bank List Request Object >>>> " + requestObject);
				JSONObject loginRespObj = getContextId(loginUrl,mainBody);
				if(loginRespObj != null){
					JSONObject loginResp = (JSONObject)loginRespObj.get("response");
					String contextId = loginResp.get("SessionContextId").toString();
					Utils.log("Context Id >>>> "+contextId);
					String systemId = loginResp.get("InitialBranch").toString();
					Utils.log("System Id >>>> "+systemId);
				
					String creditCardUrl = url+"AccountsReceivable/SavedCreditCardList";
		        	JSONObject responseObj = agilityPublicAccountsReceivableService(creditCardUrl,requestObject,contextId,systemId);
		        	if(responseObj != null){
			        	Utils.log("CC Bank List Response >>>> "+responseObj);
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
			        		    			bankListBuffer.append("<option value=\""+obj.get("PaymentAccountID").toString()+"\">"+obj.get("TruncatedCardNumber").toString() +" : "+obj.get("BillingName").toString()+" </option>");
			        		    		}
			        				}
			        			}
			        		}
			        	}
		        	}
				}
			}
			output=bankListBuffer.toString();
        	
        	out.print(output);
        	out.close();

		}
		catch (Exception e) {
			e.getMessage();
		}
	}
	else if(param.equalsIgnoreCase("MakePayment")){
		try {
			String paymentMethod = request.getParameter("paymentMethod");
			String totalPaymentAmount = request.getParameter("totalPaymentAmount");
			String totalDiscountAmount = request.getParameter("totalDiscountAmount");
			String bankGUID = request.getParameter("bankGUID");
			String systemIdArray = request.getParameter("systemIdArray");
			String invoiceNoArray = request.getParameter("invoiceNoArray");
			String openAmountArray = request.getParameter("openAmountArray");
			String disAmountArray = request.getParameter("disAmountArray");
			
			String[] systemIdArrayData = systemIdArray.split(",");
			String[] invoiceNoArrayData = invoiceNoArray.split(",");
			String[] openAmountArrayData = openAmountArray.split(",");
			String[] disAmountArrayData = disAmountArray.split(",");

			if(paymentMethod.equalsIgnoreCase("ach")){
				String message="",invoicePaymentStatus="";
				
				JSONObject jsonObject=new JSONObject();
				jsonObject.put("CustomerID", customerId);
				jsonObject.put("ShiptoSequence", 1);
				jsonObject.put("BilltoSequence", 1);
				jsonObject.put("BankGUID", bankGUID);
				jsonObject.put("AmountTendered", Double.parseDouble(totalPaymentAmount));
				jsonObject.put("PaymentDate", "");

				JSONArray dtCashReceiptsPaymentRequestArray = new JSONArray();
				dtCashReceiptsPaymentRequestArray.add(jsonObject);
				
				JSONObject dtCashReceiptsPaymentRequest=new JSONObject();
				dtCashReceiptsPaymentRequest.put("dtCashReceiptsPaymentRequest", dtCashReceiptsPaymentRequestArray.toString());
				
				JSONObject dsCashReceiptsPaymentRequest=new JSONObject();
				dsCashReceiptsPaymentRequest.put("dsCashReceiptsPaymentRequest", dtCashReceiptsPaymentRequest);
				
				JSONObject cashReceiptsPaymentJSON=new JSONObject();
				cashReceiptsPaymentJSON.put("CashReceiptsPaymentJSON",dsCashReceiptsPaymentRequest);

				JSONObject requestObject=new JSONObject();
				requestObject.put("request",cashReceiptsPaymentJSON);
				Utils.log("ACH Request Object >>>> " + requestObject);

				double totalInvoiceOpenAmount=0;
				Utils.log("openAmountArrayData.length >>>> " + openAmountArrayData.length);
				for(int i=0; i<openAmountArrayData.length; i++){
					double dd=Double.parseDouble(openAmountArrayData[i])-Double.parseDouble(disAmountArrayData[i]);
					totalInvoiceOpenAmount = totalInvoiceOpenAmount + dd;
				}
				
				String formattetotalInvoiceOpenAmount = String.format("%.2f", totalInvoiceOpenAmount);
				
				Utils.log("TotalPaymentAmount >>>> " + totalPaymentAmount);
				Utils.log("TotalInvoiceOpenAmount >>>> " + formattetotalInvoiceOpenAmount);
				
				if(Double.parseDouble(totalPaymentAmount) == Double.parseDouble(formattetotalInvoiceOpenAmount)){
					JSONObject loginRespObj = getContextId(loginUrl,mainBody);
					if(loginRespObj != null){
						JSONObject loginResp = (JSONObject)loginRespObj.get("response");
						String contextId = loginResp.get("SessionContextId").toString();
						Utils.log("Context Id >>>> "+contextId);
						String systemId = loginResp.get("InitialBranch").toString();
						Utils.log("System Id >>>> "+systemId);
						
						String cashReceiptsACHPaymentUrl = url+"AccountsReceivable/CashReceiptsACHPayment";
			        	JSONObject responseObj = agilityPublicAccountsReceivableService(cashReceiptsACHPaymentUrl,requestObject,contextId,systemId);
			        	Utils.log("ACH Response >>>> "+responseObj);
			        	JSONObject res = (JSONObject)responseObj.get("response");
			        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
			        		JSONObject cashReceiptsPaymentJSONResponse = (JSONObject)res.get("CashReceiptsPaymentJSONResponse");
			        		if(cashReceiptsPaymentJSONResponse != null){
			        			JSONObject dsARInvoiceResponse = (JSONObject)cashReceiptsPaymentJSONResponse.get("dsARInvoiceResponse");
			        			if(dsARInvoiceResponse != null){
			        				JSONArray dtARInvoiceResponseArray = (JSONArray)dsARInvoiceResponse.get("dtARInvoiceResponse");
			        				if(dtARInvoiceResponseArray != null){
			        	        		for(int j=0;j<dtARInvoiceResponseArray.size();j++){
			        	        			JSONObject obj = (JSONObject)dtARInvoiceResponseArray.get(j);
			        	        			Utils.log("InvoiceNumber : "+obj.get("InvoiceNumber").toString());
			        	        			Utils.log("AmountTendered : "+obj.get("AmountTendered").toString());
			        	        			Utils.log("PaymentID : "+obj.get("PaymentID").toString());

			        	        			String status = insertCashReceiptsACHPaymentResponse(obj.get("InvoiceNumber").toString(),obj.get("AmountTendered").toString(),obj.get("PaymentID").toString(),customerId);
			        	        			invoicePaymentStatus = invoicePaymentAPI(customerId,systemIdArrayData,invoiceNoArrayData,openAmountArrayData,disAmountArrayData,obj.get("InvoiceNumber").toString(),obj.get("AmountTendered").toString(),paymentMethod,allowDiscountOnCCPayment,contextId,systemId,obj.get("PaymentID").toString());
			        					
			        						SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");  
			        						Date transactionDate = new Date();

			        						String row="",invoiceNo="",paymentAmount="",discountTakenAmount="";
			        	        			if(invoicePaymentStatus.equalsIgnoreCase("success")){
				        						List<HashMap<String, String>> listData = getDmsiApiInvPayResponseData(obj.get("PaymentID").toString());
				        						if(listData != null && listData.size()>0){ 
				        							for(int k=0;k<listData.size();k++){
				        								HashMap map=(HashMap)listData.get(k);
				        								String invNo=map.get("invoiceNo").toString().trim().substring(0,2);
				        								if(invNo.equalsIgnoreCase("CA") || map.get("invoiceType").toString().trim().equalsIgnoreCase("Credit Memo"))
				        									row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+map.get("invoiceNo")+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">-$"+df.format(Double.parseDouble(map.get("paymentAmount").toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("discountAmount").toString()))+"</td></tr>";
				        								else			        										
			        										row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+map.get("invoiceNo")+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("paymentAmount").toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("discountAmount").toString()))+"</td></tr>";
				        							}
				        						}
			        	        			}
			        	        			else{
			        							for(int k=0;k<invoiceNoArrayData.length;k++){
			        								row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+invoiceNoArrayData[k].trim().toString()+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(openAmountArrayData[k].trim().toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(disAmountArrayData[k].trim().toString()))+"</td></tr>";
			        							}
			        	        			}
			        	        			
				        					String from = "RWC Customer Service Portal <portal@rwc.org>";
				        					String to = customerEmailId;
				        					//String sendCC = "";
				        					String sendCC = "it@rwc.org,jvillanueva@henryproducts.com";
				        					String sendBCC = "";
				        					String subject = "";
				        					String tag = "Invitation";
				        					String htmlBody = "";
				        					String textBody = "Hello";
				        					String replyTo = "";
				        					String messageStream = "outbound";
				        						
				        					subject="Your Payment Has Been Successfully Processed";
				        					htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
				        									"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
				        										"<tr><td><table height=\"100\" width=\"100%\">"+
				        													"<tr><td><b>"+customerFirstName+"&nbsp;"+customerLastName+",</b></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td><b> Your recent payment has been successfully processed.</b></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Transaction Details:</b></td></tr>"+
				        													"<tr><td><ul style=\"list-style-type: none;\"><li><b> Amount : &nbsp;</b>$"+df.format(Double.parseDouble(totalPaymentAmount))+"</li>"+
				        																"<li><b> Transaction ID : </b>&nbsp;"+obj.get("PaymentID").toString()+"</li>"+
				        																"<li><b> Date : </b>&nbsp;"+sdf.format(transactionDate)+"</li>"+
				        													"</ul></td></tr>"+	
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td>Payment Details</td></tr>"+
				        													"<tr><td><table border=\"0\" style=\"border: .5px solid #f0f0f5\">"+
				        															"<tr><td align=\"left\" style=\"border: .5px solid #f0f5f5\"><b>Invoice#</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Payment Amt</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Discount Amt</b></td></tr>"+
				        															row+
				        														"</table></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td>This email serves as your official receipt. We recommend saving this email for your records. Should you require any further assistance or have any questions regarding your payment, please do not hesitate to reach out to our customer support team.</td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><ul style=\"list-style-type: none;\"><li><b> credit@rwc.org </b></li>"+
				        																"<li><b> 602.258.3794 x1207 </b></li>"+
				        													"</ul></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Thank you for your prompt payment. We appreciate your continued patronage. </b></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Warm regards,</b></td></tr>"+
				        												  	"<tr><td><b> RWC Building Products Customer Service</b></td></tr>"+
				        												"</table></td></tr>"+
				        									"</table></BODY></html>";

				        					JSONObject mailResObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
				        					Utils.log("Response :"+mailResObj);
				        					if(Integer.parseInt(mailResObj.get("ErrorCode").toString()) == 0) {
				        						Utils.log("Message : "+mailResObj.get("Message")+"");
				        						message="Your payment has been successfully processed. A confirmation email has been sent to your inbox.";
				        					}else{
				        						message="Unable to process your request. Please try after some time.";
				        					}
			        	        			
				        					if(!invoicePaymentStatus.equalsIgnoreCase("success")){
				        						String sentTo="bree@rwc.org,a.gonzalez@rwc.org,g.moreno@rwc.org";
				        						subject="Re: Payment# "+obj.get("PaymentID").toString()+" Not Applied as Requested";
				        						htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
				        										"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
				        											"<tr><td><table height=\"100\" width=\"100%\">"+
				        														"<tr><td><b>Hi AR Team,</b></td></tr>"+
				        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        														"<tr><td>We have received a payment from <b>"+customerFirstName+"&nbsp;"+customerLastName+"</b> in the amount of <b>$"+df.format(Double.parseDouble(totalPaymentAmount))+"</b> with the payment ID</td></tr>"+
				        														"<tr><td><b>"+obj.get("PaymentID").toString()+"</b>. However, this payment has not been applied to any specific invoice due to the following error: </td></tr>"+
				        														"<tr><td><b>"+invoicePaymentStatus+"</b>.</td></tr>"+
				        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        														"<tr><td>Below are the selected invoices for this payment:</td></tr>"+
				        														"<tr><td><table border=\"0\" style=\"border: .5px solid #f0f0f5\">"+
				        																"<tr><td align=\"left\" style=\"border: .5px solid #f0f5f5\"><b>Invoice#</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Payment Amt</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Discount Amt</b></td></tr>"+
				        																row+
				        															"</table></td></tr>"+
				        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        														"<tr><td>Could you please resolve the issue and apply the payment accordingly? </td></tr>"+
				        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        														"<tr><td>Thank you for your assistance</td></tr>"+
				        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        													"</table></td></tr>"+
				        										"</table></BODY></html>";

				        						JSONObject mailResObjForError = sendMail(from,sentTo,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
				        						Utils.log("Response :"+mailResObjForError);
				        						if(Integer.parseInt(mailResObjForError.get("ErrorCode").toString()) == 0) {
				        							Utils.log("Message : "+mailResObjForError.get("Message")+"");
				        							message="Your payment has been successfully processed. A confirmation email has been sent to your inbox.";
				        						}else{
				        							message="Unable to process your request. Please try after some time.";
				        						}
				        					}

			        	        		}
			        				}
			        			}
			        		}
			        	}
			        	else{
			        		message=res.get("MessageText").toString();
			        	}
					}
				}
	        	else{
	        		message="Total Payment Amount and Invoice Total Amount are not equal";
	        	}
			response.setContentType("text/html");
		        response.getWriter().print(message.toString());
		    	out.flush();
			//out.print(message.toString());
	        	//out.close();

			}
			else if(paymentMethod.equalsIgnoreCase("creditcard")){
				String message="",invoicePaymentStatus="";
				String ccSurchargeFeesPercent = request.getParameter("ccSurchargeFeesPercent");
				
				JSONObject jsonObject=new JSONObject();
				jsonObject.put("CustomerID", customerId);
				jsonObject.put("ShiptoSequence", 1);
				jsonObject.put("BilltoSequence", 1);
				jsonObject.put("PaymentAccountID", bankGUID);
				jsonObject.put("AllowTokenDelete", false);
				jsonObject.put("AmountTendered", Double.parseDouble(totalPaymentAmount));
				jsonObject.put("PaymentDate", "");
				jsonObject.put("Surcharge", Double.parseDouble(ccSurchargeFeesPercent));
				jsonObject.put("SurchargeBasis", "Percent");
				jsonObject.put("UseAgilitySurcharge", false);

				JSONArray dtCashReceiptsPaymentRequestArray = new JSONArray();
				dtCashReceiptsPaymentRequestArray.add(jsonObject);
				
				JSONObject dtCashReceiptsPaymentRequest=new JSONObject();
				dtCashReceiptsPaymentRequest.put("dtCashReceiptsPaymentRequest", dtCashReceiptsPaymentRequestArray.toString());
				
				JSONObject dsCashReceiptsPaymentRequest=new JSONObject();
				dsCashReceiptsPaymentRequest.put("dsCashReceiptsPaymentRequest", dtCashReceiptsPaymentRequest);
				
				JSONObject cashReceiptsPaymentJSON=new JSONObject();
				cashReceiptsPaymentJSON.put("CashReceiptsPaymentJSON",dsCashReceiptsPaymentRequest);

				JSONObject requestObject=new JSONObject();
				requestObject.put("request",cashReceiptsPaymentJSON);
				
				Utils.log("CC Request Object :: " + requestObject);

				double totalInvoiceOpenAmount=0;
				for(int i=0; i<openAmountArrayData.length; i++){
					double dd=Double.parseDouble(openAmountArrayData[i])-Double.parseDouble(disAmountArrayData[i]);
					totalInvoiceOpenAmount = totalInvoiceOpenAmount + dd;
				}
				
				String formattetotalInvoiceOpenAmount = String.format("%.2f", totalInvoiceOpenAmount);
				
				Utils.log("TotalPaymentAmount >>>> " + totalPaymentAmount);
				Utils.log("TotalInvoiceOpenAmount >>>> " + formattetotalInvoiceOpenAmount);
				
				if(Double.parseDouble(totalPaymentAmount) == Double.parseDouble(formattetotalInvoiceOpenAmount)){
					JSONObject loginRespObj = getContextId(loginUrl,mainBody);
					if(loginRespObj != null){
						JSONObject loginResp = (JSONObject)loginRespObj.get("response");
						String contextId = loginResp.get("SessionContextId").toString();
						Utils.log("Context Id >>>> "+contextId);
						String systemId = loginResp.get("InitialBranch").toString();
						Utils.log("System Id >>>> "+systemId);
					
						String cashReceiptsCCTokenPaymentUrl = url+"AccountsReceivable/CashReceiptsCCTokenPayment";
						JSONObject responseObj = agilityPublicAccountsReceivableService(cashReceiptsCCTokenPaymentUrl,requestObject,contextId,systemId);
			        	Utils.log("CC Response >>>> "+responseObj);
			        	JSONObject res = (JSONObject)responseObj.get("response");
			        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
			        		JSONObject cashReceiptsPaymentJSONResponse = (JSONObject)res.get("CashReceiptsPaymentJSONResponse");
			        		if(cashReceiptsPaymentJSONResponse != null){
				        		JSONObject dsARInvoiceResponse = (JSONObject)cashReceiptsPaymentJSONResponse.get("dsARInvoiceResponse");
				        		if(dsARInvoiceResponse != null){
					        		JSONArray dtARInvoiceResponseArray = (JSONArray)dsARInvoiceResponse.get("dtARInvoiceResponse");
					        		if(dtARInvoiceResponseArray != null){
						        		for(int i=0;i<dtARInvoiceResponseArray.size();i++){
						        			JSONObject obj = (JSONObject)dtARInvoiceResponseArray.get(i);
						        			Utils.log("InvoiceNumber : "+obj.get("InvoiceNumber").toString());
						        			Utils.log("AmountTendered : "+obj.get("AmountTendered").toString());
						        			Utils.log("Surcharge : "+obj.get("Surcharge").toString());
						        			Utils.log("ApprovedAmount : "+obj.get("ApprovedAmount").toString());
						        			Utils.log("PaymentID : "+obj.get("PaymentID").toString());
		
						        			JSONArray dtARReceiptResponseArray = (JSONArray)obj.get("dtARReceiptResponse");
						        			if(dtARReceiptResponseArray != null){
								        		for(int j=0;j<dtARReceiptResponseArray.size();j++){
								        			JSONObject dtARReceiptResponseObj = (JSONObject)dtARReceiptResponseArray.get(j);
								        			
								        			String cashReceiptsCCTokenPaymentStatus = insertCashReceiptsCCTokenPaymentResponse(obj.get("InvoiceNumber").toString(),obj.get("AmountTendered").toString(),obj.get("Surcharge").toString(),obj.get("ApprovedAmount").toString(),obj.get("PaymentID").toString(),
								        					dtARReceiptResponseObj.get("MerchantName").toString(),dtARReceiptResponseObj.get("MerchantAddress1").toString(),dtARReceiptResponseObj.get("MerchantAddress2").toString(),dtARReceiptResponseObj.get("MerchantCity").toString(),dtARReceiptResponseObj.get("MerchantState").toString(),
								        					dtARReceiptResponseObj.get("MerchantZIP").toString(),dtARReceiptResponseObj.get("TransactionAmount").toString(),dtARReceiptResponseObj.get("TransactionDate").toString(),dtARReceiptResponseObj.get("AccountNumber").toString(),dtARReceiptResponseObj.get("AuthorizationCode").toString(),
								        					dtARReceiptResponseObj.get("ApplicationID").toString(),dtARReceiptResponseObj.get("SurchargeAmount").toString(),dtARReceiptResponseObj.get("SurchargeDescriptor").toString(),dtARReceiptResponseObj.get("CardNetworkName").toString(),
								        					dtARReceiptResponseObj.get("ApplicationLabel").toString(),dtARReceiptResponseObj.get("TerminalID").toString(),dtARReceiptResponseObj.get("CardholderName").toString(),dtARReceiptResponseObj.get("SalesTaxAmount").toString(),
								        					dtARReceiptResponseObj.get("TransactionType").toString(),dtARReceiptResponseObj.get("EntryMode").toString(),dtARReceiptResponseObj.get("ApprovalNumber").toString(),dtARReceiptResponseObj.get("HostResponse").toString(),customerId);
		
								        			invoicePaymentStatus = invoicePaymentAPI(customerId,systemIdArrayData,invoiceNoArrayData,openAmountArrayData,disAmountArrayData,obj.get("InvoiceNumber").toString(),obj.get("AmountTendered").toString(),paymentMethod,allowDiscountOnCCPayment,contextId,systemId,obj.get("PaymentID").toString());
						        				
					        						SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");  
					        						Date transactionDate = new Date();

					        						String row="",invoiceNo="",paymentAmount="",discountTakenAmount="";
					        	        			if(invoicePaymentStatus.equalsIgnoreCase("success")){
						        						List<HashMap<String, String>> listData = getDmsiApiInvPayResponseData(obj.get("PaymentID").toString());
						        						if(listData != null && listData.size()>0){ 
						        							for(int k=0;k<listData.size();k++){
						        								HashMap map=(HashMap)listData.get(k);
						        								String invNo=map.get("invoiceNo").toString().trim().substring(0,2);
						        								if(invNo.equalsIgnoreCase("CA") || map.get("invoiceType").toString().trim().equalsIgnoreCase("Credit Memo"))
						        									row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+map.get("invoiceNo")+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">-$"+df.format(Double.parseDouble(map.get("paymentAmount").toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("discountAmount").toString()))+"</td></tr>";
						        								else			        										
					        										row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+map.get("invoiceNo")+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("paymentAmount").toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(map.get("discountAmount").toString()))+"</td></tr>";
						        							}
						        						}
					        	        			}
					        	        			else{
					        							for(int k=0;k<invoiceNoArrayData.length;k++){
					        								row+="<tr><td width=\"160\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+invoiceNoArrayData[k].trim().toString()+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(openAmountArrayData[k].trim().toString()))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble(disAmountArrayData[k].trim().toString()))+"</td></tr>";
					        							}
					        	        			}

					        						String from = "RWC Customer Service Portal <portal@rwc.org>";
					        						String to = customerEmailId;
					        						//String sendCC = "";
					        						String sendCC = "it@rwc.org,jvillanueva@henryproducts.com";
					        						String sendBCC = "";
					        						String subject = "";
					        						String tag = "Invitation";
					        						String htmlBody = "";
					        						String textBody = "Hello";
					        						String replyTo = "";
					        						String messageStream = "outbound";
					        						
					        						subject="Your Payment Has Been Successfully Processed";
						        					htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
				        									"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
				        										"<tr><td><table height=\"100\" width=\"100%\">"+
				        													"<tr><td><b>"+customerFirstName+"&nbsp;"+customerLastName+",</b></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td></td></tr>"+
				        													"<tr><td><b> Your recent payment has been successfully processed.</b></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Transaction Details:</b></td></tr>"+
				        													"<tr><td><ul style=\"list-style-type: none;\"><li><b> Amount : &nbsp;</b>$"+df.format(Double.parseDouble(totalPaymentAmount))+"</li>"+
				        																"<li><b> CC Fees : </b>&nbsp;"+df.format(Double.parseDouble(ccSurchargeFeesPercent))+"</li>"+	
				        																"<li><b> Transaction ID : </b>&nbsp;"+obj.get("PaymentID").toString()+"</li>"+
				        																"<li><b> Date : </b>&nbsp;"+sdf.format(transactionDate)+"</li>"+
				        													"</ul></td></tr>"+	
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td>Payment Details</td></tr>"+
				        													"<tr><td><table border=\"0\" style=\"border: .5px solid #f0f0f5\">"+
				        															"<tr><td align=\"left\" style=\"border: .5px solid #f0f5f5\"><b>Invoice#</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Payment Amt</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Discount Amt</b></td></tr>"+
				        															row+
				        														"</table></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td>This email serves as your official receipt. We recommend saving this email for your records. Should you require any further assistance or have any questions regarding your payment, please do not hesitate to reach out to our customer support team.</td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><ul style=\"list-style-type: none;\"><li><b> credit@rwc.org </b></li>"+
				        																"<li><b> 602.258.3794 x1207 </b></li>"+
				        													"</ul></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Thank you for your prompt payment. We appreciate your continued patronage. </b></td></tr>"+
				        													"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
				        													"<tr><td><b> Warm regards,</b></td></tr>"+
				        												  	"<tr><td><b> RWC Building Products Customer Service</b></td></tr>"+
				        												"</table></td></tr>"+
				        									"</table></BODY></html>";

					        						JSONObject mailResObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
					        						Utils.log("Response :"+mailResObj);
					        						if(Integer.parseInt(mailResObj.get("ErrorCode").toString()) == 0) {
					        							Utils.log("Message : "+mailResObj.get("Message")+"");
					        							message="Your payment has been successfully processed. A confirmation email has been sent to your inbox.";
					        						}else{
					        							message="Unable to process your request. Please try after some time.";
					        						}
								        		
						        					if(!invoicePaymentStatus.equalsIgnoreCase("success")){
						        						String sentTo = "bree@rwc.org,a.gonzalez@rwc.org,g.moreno@rwc.org";
						        						subject="Re: Payment# "+obj.get("PaymentID").toString()+" Not Applied as Requested";
						        						htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
						        										"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
						        											"<tr><td><table height=\"100\" width=\"100%\">"+
						        														"<tr><td><b>Hi AR Team,</b></td></tr>"+
						        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
						        														"<tr><td>We have received a payment from <b>"+customerFirstName+"&nbsp;"+customerLastName+"</b> in the amount of <b>$"+df.format(Double.parseDouble(totalPaymentAmount))+"</b> with the payment ID</td></tr>"+
						        														"<tr><td><b>"+obj.get("PaymentID").toString()+"</b>. However, this payment has not been applied to any specific invoice due to the following error: </td></tr>"+
						        														"<tr><td><b>"+invoicePaymentStatus+"</b>.</td></tr>"+
						        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
						        														"<tr><td>Below are the selected invoices for this payment:</td></tr>"+
						        														"<tr><td><table border=\"0\" style=\"border: .5px solid #f0f0f5\">"+
						        																"<tr><td align=\"left\" style=\"border: .5px solid #f0f5f5\"><b>Invoice#</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Payment Amt</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Discount Amt</b></td></tr>"+
						        																row+
						        															"</table></td></tr>"+
						        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
						        														"<tr><td>Could you please resolve the issue and apply the payment accordingly? </td></tr>"+
						        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
						        														"<tr><td>Thank you for your assistance</td></tr>"+
						        														"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
						        													"</table></td></tr>"+
						        										"</table></BODY></html>";

						        						JSONObject mailResObjForError = sendMail(from,sentTo,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
						        						Utils.log("Response :"+mailResObjForError);
						        						if(Integer.parseInt(mailResObjForError.get("ErrorCode").toString()) == 0) {
						        							Utils.log("Message : "+mailResObjForError.get("Message")+"");
						        							message="Your payment has been successfully processed. A confirmation email has been sent to your inbox.";
						        						}else{
						        							message="Unable to process your request. Please try after some time.";
						        						}
						        					}
								        		
								        		
								        		}
						        			}
						        		}
					        		}
			        			}
			        		}
			        	}
			        	else{
			        		message=res.get("MessageText").toString();
			        	}
					}
				}
	        	else{
	        		message="Total Payment Amount and Invoice Total Amount are not equal";
	        	}
			response.setContentType("text/html");
		        response.getWriter().print(message.toString());
		    	out.flush();
			}
		}
		catch (Exception e) {
			e.getMessage();
		}
	}

%>

<%!

	public String invoicePaymentAPI(String customerId,String[] systemIdArrayData,String[] invoiceNoArrayData,String[] openAmountArrayData,String[] disAmountArrayData,
						String invoiceNumber,String amountTendered,String paymentMethod,String allowDiscountOnCCPayment,String contextId, String systemId,String paymentId)
	{
		String message="",shipToSequence="1",billToSequence="1",invoiceBalance="0";
		try{

			String s = insertDmsiApiInvPaySelectedBatchUpdate(customerId,systemIdArrayData,invoiceNoArrayData,openAmountArrayData,disAmountArrayData,shipToSequence,billToSequence,
									amountTendered,invoiceBalance,paymentId,paymentMethod,allowDiscountOnCCPayment);
			
			
			FileReader reader=new FileReader("eTechLogix.properties");  
	    	Properties prop=new Properties();  
	    	prop.load(reader);    
	    	String url=prop.getProperty("AgilityUrl");
			String invoicePaymentUrl =url+"AccountsReceivable/InvoicePayment";
			
			JSONArray dtInvoiceRequestArray = new JSONArray();
			JSONArray dtPaymentRequestArray = new JSONArray();
			JSONObject jsonObj=new JSONObject();
			jsonObj.put("BranchID", systemId);
			jsonObj.put("InvoiceNumber", invoiceNumber);
			jsonObj.put("PaymentAmount", Double.parseDouble(amountTendered));
			dtPaymentRequestArray.add(jsonObj);
			
			for(int i=0; i<invoiceNoArrayData.length; i++){
				if(Double.parseDouble(openAmountArrayData[i])>0){

					double paymentAmt=0;
					if(paymentMethod.equalsIgnoreCase("creditcard") && allowDiscountOnCCPayment.equalsIgnoreCase("N"))
						paymentAmt=Double.parseDouble(openAmountArrayData[i]);
					else 
						paymentAmt=Double.parseDouble(openAmountArrayData[i])-Double.parseDouble(disAmountArrayData[i]);					
						
					JSONObject jsonObject=new JSONObject();
					jsonObject.put("BranchID", systemIdArrayData[i]);
					jsonObject.put("InvoiceNumber", invoiceNoArrayData[i]);
					//jsonObject.put("PaymentAmount", Double.parseDouble(openAmountArrayData[i]));
					jsonObject.put("PaymentAmount", paymentAmt);
					jsonObject.put("DiscountAmount", Double.parseDouble(disAmountArrayData[i]));
					jsonObject.put("Remark", "PRT");
					dtInvoiceRequestArray.add(jsonObject);
				}
				//Payment request for -ve invoices
				else{
					JSONObject jsonObject=new JSONObject();
					jsonObject.put("BranchID", systemIdArrayData[i]);
					jsonObject.put("InvoiceNumber", invoiceNoArrayData[i]);
					jsonObject.put("PaymentAmount", Double.parseDouble(openAmountArrayData[i]));
					dtPaymentRequestArray.add(jsonObject);
				}

			}

			JSONObject jsonObjTwo=new JSONObject();
			jsonObjTwo.put("CustomerID", customerId);
			jsonObjTwo.put("PaymentDate", "");
			jsonObjTwo.put("dtInvoiceRequest", dtInvoiceRequestArray.toString());
			jsonObjTwo.put("dtPaymentRequest", dtPaymentRequestArray.toString());
			
			JSONArray dtCustomerRequestArray = new JSONArray();
			dtCustomerRequestArray.add(jsonObjTwo);
			
			JSONObject dtCustomerRequest=new JSONObject();
			dtCustomerRequest.put("dtCustomerRequest", dtCustomerRequestArray.toString());
			
			JSONObject dsInvoicePaymentRequest=new JSONObject();
			dsInvoicePaymentRequest.put("dsInvoicePaymentRequest", dtCustomerRequest);
			
			JSONObject InvoicePaymentJSON=new JSONObject();
			InvoicePaymentJSON.put("InvoicePaymentJSON",dsInvoicePaymentRequest);
		
			JSONObject requestObject=new JSONObject();
			requestObject.put("request",InvoicePaymentJSON);
			
			Utils.log("InvoicePayment Request Object >>>> " + requestObject);

			JSONObject respObj = agilityPublicAccountsReceivableService(invoicePaymentUrl,requestObject,contextId,systemId);
	    	Utils.log("InvoicePayment Response : "+respObj);
	    	JSONObject invoicePaymentResponse = (JSONObject)respObj.get("response");
	    	String errorCode=invoicePaymentResponse.get("ReturnCode").toString().trim();
	    	String returnCode=invoicePaymentResponse.get("ReturnCode").toString().trim();
	    	message=invoicePaymentResponse.get("MessageText").toString().trim();
	    	if(Integer.parseInt(returnCode) == 0){
	    		JSONObject invoicePaymentJSONResponse = (JSONObject)invoicePaymentResponse.get("InvoicePaymentJSONResponse");
	    		JSONObject dsAROpenResponse = (JSONObject)invoicePaymentJSONResponse.get("dsAROpenResponse");
	    		JSONArray dtAROpenResponseArray = (JSONArray)dsAROpenResponse.get("dtAROpenResponse");
	    		
	    		/*for(int j=0;j<dtAROpenResponseArray.size();j++){
    			JSONObject invoicePaymentResObj = (JSONObject)dtAROpenResponseArray.get(j);
    			String invoicePaymentStatus = insertInvoicePaymentResponse(invoicePaymentResObj.get("CustomerID").toString(),invoicePaymentResObj.get("BranchID").toString(),
    									invoicePaymentResObj.get("ProcessDate").toString(),invoicePaymentResObj.get("InvoiceNumber").toString(),
    									invoicePaymentResObj.get("InstallmentSequence").toString(),invoicePaymentResObj.get("TransactionID").toString(),
    									invoicePaymentResObj.get("ShipmentNumber").toString(),invoicePaymentResObj.get("InvoiceType").toString(),
    									invoicePaymentResObj.get("ShipToSequence").toString(),invoicePaymentResObj.get("BillToSequence").toString(),
    									invoicePaymentResObj.get("OpenAmount").toString(),invoicePaymentResObj.get("PaymentAmount").toString(),
    									invoicePaymentResObj.get("DiscountAmount").toString(),invoicePaymentResObj.get("InvoiceBalance").toString(),paymentId);
	    		}*/
	    		
	    		String invoicePaymentResponseStatus = insertInvoicePaymentResponseBatchInsert(dtAROpenResponseArray,paymentId);

				/* String negativeInvoiceStatus = insertInvoicePaymentOfNegativeInvoices(customerId,systemIdArrayData,invoiceNoArrayData,openAmountArrayData,disAmountArrayData,shipToSequence,billToSequence,
																amountTendered,invoiceBalance,paymentId,paymentMethod,allowDiscountOnCCPayment); */
	    		
	    		message="success";
	    	}
	    	else{
	    		insertDmsiApiInvPayError(errorCode,customerId,systemId,invoiceNumber,paymentId,message);
	    	}
		}
		catch (Exception e) {
			e.getMessage();
		}
		return message;
	}


	public JSONObject agilityPublicAccountsReceivableService(String url,JSONObject requestObject,String contextId,String systemId)
	{
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		headerMaps.put("ContextId", contextId);
		headerMaps.put("Branch", systemId);
		String contentType=MediaType.APPLICATION_JSON;
		return apiCall(url, requestObject.toString(), "POST", contentType, headerMaps);
	}
	
	public JSONObject getContextId(String url,JSONObject requestObject)
	{
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		String contentType=MediaType.APPLICATION_JSON;
		return apiCall(url, requestObject.toString(), "POST", contentType, headerMaps);
	}

	public JSONObject apiCall(String url,String data,String method,String contentType,HashMap<String, String> headerMaps){
		
		JSONObject jsonObj = new JSONObject();
		String inputLine = "";
		HttpsURLConnection httpsCon =null;
		HttpURLConnection httpCon =null;
		InputStream ins = null;
		InputStreamReader isr = null;
		BufferedReader in = null;
		try {
			//Utils.log("URL : " + url);
			//Utils.log("Data : " + data);
			
			String protocall[]= url.split("://");
			if("http".equalsIgnoreCase(protocall[0])) {
	
				URL myurl = new URL(url);
				httpCon = (HttpURLConnection) myurl.openConnection();
				httpCon.setRequestMethod(method);
	
				httpCon.setReadTimeout(180000);
				httpCon.setConnectTimeout(180000);
				httpCon.setUseCaches(false);
				httpCon.setRequestProperty("Content-Type", contentType);
	
				if(headerMaps!=null) {
					for (Map.Entry<String, String> entry : headerMaps.entrySet()) {
						httpCon.setRequestProperty(entry.getKey(), entry.getValue());
						
						//Utils.log(entry.getKey()+" : "+entry.getValue());
					}
				}
	
				if(!"GET".equalsIgnoreCase(method)){
					httpCon.setDoOutput(true);
					DataOutputStream wr = new DataOutputStream(httpCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
	
				StringBuilder stringBuilder = new StringBuilder();
				int responseCode = httpCon.getResponseCode();
	
				if(responseCode<400) {
					ins = httpCon.getInputStream();
				}else {
					ins=httpCon.getErrorStream();
				}
				isr = new InputStreamReader(ins);
				in = new BufferedReader(isr);
	
				while ((inputLine = in.readLine()) != null) {
					stringBuilder.append(inputLine);
				}
				
				//Utils.log("Log : "+stringBuilder);
				
				if(stringBuilder!=null && stringBuilder.length()>0) {
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					jsonObj=JSONObject.fromObject(output);
				}
	
			}else {
	
				// Create a trust manager that does not validate certificate chains
				TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
					public java.security.cert.X509Certificate[] getAcceptedIssuers() {
						return null;
					}
	
					public void checkClientTrusted(X509Certificate[] certs, String authType) {
					}
	
					public void checkServerTrusted(X509Certificate[] certs, String authType) {
					}
				} };
	
				// Install the all-trusting trust manager
				SSLContext sc = SSLContext.getInstance("SSL");
				sc.init(null, trustAllCerts, new java.security.SecureRandom());
				HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
	
				// Create all-trusting host name verifier
				HostnameVerifier allHostsValid = new HostnameVerifier() {
					public boolean verify(String hostname, SSLSession session) {
						return true;
					}
				};
	
				// Install the all-trusting host verifier
				HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
				URL myurl = new URL(url);
				httpsCon = (HttpsURLConnection) myurl.openConnection();
				httpsCon.setRequestMethod(method);
				httpsCon.setRequestProperty("Content-Type", contentType);
				httpsCon.setReadTimeout(180000);
				httpsCon.setConnectTimeout(180000);
				httpsCon.setUseCaches(false);
				if(headerMaps!=null) {
					for (Map.Entry<String, String> entry : headerMaps.entrySet()) {
						httpsCon.setRequestProperty(entry.getKey(), entry.getValue());
						
						Utils.log(entry.getKey()+" : "+entry.getValue());
					}
				}
				if(!"GET".equalsIgnoreCase(method)){
					httpsCon.setDoInput(true);
					httpsCon.setDoOutput(true);
					DataOutputStream wr = new DataOutputStream(httpsCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
				StringBuilder stringBuilder = new StringBuilder();
				int responseCode = httpsCon.getResponseCode();
	
				Utils.log("Status code : "+responseCode);
				
				if(responseCode<400) {
					ins = httpsCon.getInputStream();
				}else {
					ins=httpsCon.getErrorStream();
				}
				isr = new InputStreamReader(ins);
				in = new BufferedReader(isr);
	
				while ((inputLine = in.readLine()) != null) {
					stringBuilder.append(inputLine);
				}
				
				//Utils.log("Log : "+stringBuilder);
	
				if(stringBuilder!=null && stringBuilder.length()>0){
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					jsonObj=JSONObject.fromObject(output);
				}
			}
			return jsonObj;
	
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return null;
		}finally {
	
			try {
				if(httpCon!=null)
					httpCon.disconnect();
				if(httpsCon!=null)
					httpsCon.disconnect();
				if(ins!=null)
					ins.close();
				if(isr!=null)
					isr.close();
				if(in!=null)
					in.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return null;
			}
		}
	}

	
	public String insertCashReceiptsACHPaymentResponse(String invoiceNo,String amountTendered,String paymentId,String customerId)
	{
		String status="fail";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_ACH_RESPONSE (INVOICE_NUMBER,AMOUNT_TENDERED,PAYMENT_ID,CUST_CODE,CREATED_DATE,CREATED_TIME) values (?,?,?,?,CURRENT_DATE,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, invoiceNo); 
			pstmt.setString(2, amountTendered); 
			pstmt.setString(3, paymentId);
			pstmt.setString(4, customerId);
			SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
			Date createdTime = new Date();
			pstmt.setString(5, sdf.format(createdTime));
			
			pstmt.execute();
			status="success";

			Utils.close(pstmt);				
			Utils.close(con);

		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return status;
	}

	public String insertInvoicePaymentResponse(String customerId,String branchId,String processDate,String invoiceNumber,String installmentSequence, String transactionId,
			String shipmentNumber, String invoiceType, String shipToSequence,String billToSequence,String openAmount,String paymentAmount,
			String discountAmount, String invoiceBalance, String paymentId)
	{
		String status="fail";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_INV_PAY_RESPONSE (CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,INSTALLMENT_SEQUENCE,TRANSACTION_ID,SHIPMENT_NUMBER, "
						+" INVOICE_TYPE,SHIPTO_SEQUENCE,BILLTO_SEQUENCE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT,INVOICE_BALANCE,PAYMENT_ID) "   
						+" values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, customerId); 
			pstmt.setString(2, branchId); 
			
			SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
			Date date = dt.parse(processDate);
			SimpleDateFormat dt1 = new SimpleDateFormat("dd-MMM-yyyy");
			
			pstmt.setString(3, dt1.format(date)); 
			pstmt.setString(4, invoiceNumber); 
			pstmt.setString(5, installmentSequence);
			pstmt.setString(6, transactionId); 
			pstmt.setString(7, shipmentNumber); 
			pstmt.setString(8, invoiceType); 
			pstmt.setString(9, shipToSequence); 
			pstmt.setString(10, billToSequence); 
			pstmt.setString(11, openAmount); 
			pstmt.setString(12, paymentAmount); 
			pstmt.setString(13, discountAmount); 
			pstmt.setString(14, invoiceBalance); 
			pstmt.setString(15, paymentId);
			
			pstmt.execute();
			status="success";

			Utils.close(pstmt);				
			Utils.close(con);

		} catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);				
			Utils.close(con);
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return status;
	}

	
	public String insertInvoicePaymentResponseBatchInsert(JSONArray dtAROpenResponseArray, String paymentId)
	{
		String message="";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		DistUtils du=null;
		try{
			//du=DistUtils.getDistUtils(session);
			du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_INV_PAY_RESPONSE (CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,INSTALLMENT_SEQUENCE,TRANSACTION_ID,SHIPMENT_NUMBER, "
					+" INVOICE_TYPE,SHIPTO_SEQUENCE,BILLTO_SEQUENCE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT,INVOICE_BALANCE,PAYMENT_ID) "   
					+" values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery);

			for(int i=0;i<dtAROpenResponseArray.size();i++){
    			JSONObject invoicePaymentResObj = (JSONObject)dtAROpenResponseArray.get(i);
    			pstmt.setString(1, invoicePaymentResObj.get("CustomerID").toString()); 
				pstmt.setString(2, invoicePaymentResObj.get("BranchID").toString()); 
				
				SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
				Date date = dt.parse(invoicePaymentResObj.get("ProcessDate").toString());
				SimpleDateFormat dt1 = new SimpleDateFormat("dd-MMM-yyyy");
				
				pstmt.setString(3, dt1.format(date)); 
				pstmt.setString(4, invoicePaymentResObj.get("InvoiceNumber").toString()); 
				pstmt.setString(5, invoicePaymentResObj.get("InstallmentSequence").toString());
				pstmt.setString(6, invoicePaymentResObj.get("TransactionID").toString()); 
				pstmt.setString(7, invoicePaymentResObj.get("ShipmentNumber").toString()); 
				pstmt.setString(8, invoicePaymentResObj.get("InvoiceType").toString()); 
				pstmt.setString(9, invoicePaymentResObj.get("ShipToSequence").toString()); 
				pstmt.setString(10, invoicePaymentResObj.get("BillToSequence").toString()); 
				pstmt.setString(11, invoicePaymentResObj.get("OpenAmount").toString()); 
				pstmt.setString(12, invoicePaymentResObj.get("PaymentAmount").toString()); 
				pstmt.setString(13, invoicePaymentResObj.get("DiscountAmount").toString()); 
				pstmt.setString(14, invoicePaymentResObj.get("InvoiceBalance").toString()); 
				pstmt.setString(15, paymentId);
    			
    			pstmt.addBatch();
    		}
			
            int[] count = pstmt.executeBatch();
            Utils.log("count : " + count.length);
            if(count.length>0)
				message = "Data has been inserted";
			else 
				message =  "Unable to process your request. Please try after some time.";
            
            //con.commit();
            Utils.close(pstmt);
            Utils.close(con);
		
		}
		catch(SQLException sqlEx){
			try{
				con.rollback();
			}
			catch (Exception e) {
				Utils.log("SQL Exception :: " , e);
			}
			Utils.close(pstmt);
            Utils.close(con);
            sqlEx.printStackTrace();
			Utils.log("SQL Exception :: " , sqlEx);
		}
		catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);
            Utils.close(con);
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}
		finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return message;
	}

	public String insertInvoicePaymentOfNegativeInvoices(String customerId,String[] systemIdArrayData,String[] invoiceNoArrayData,String[] openAmountArrayData,String[] disAmountArrayData,
						String shipToSequence, String billToSequence,String amountTendered,String invoiceBalance, String paymentId,String paymentMethod,String allowDiscountOnCCPayment)
	{
		String message="";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		DistUtils du=null;
		try{
			//du=DistUtils.getDistUtils(session);
			du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_INV_PAY_RESPONSE (CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,INSTALLMENT_SEQUENCE,TRANSACTION_ID,SHIPMENT_NUMBER, "
					+" INVOICE_TYPE,SHIPTO_SEQUENCE,BILLTO_SEQUENCE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT,INVOICE_BALANCE,PAYMENT_ID) "   
					+" values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery);

			for(int i=0;i<invoiceNoArrayData.length;i++){
				if(Double.parseDouble(openAmountArrayData[i]) < 0 ){
					double openAmt=0;
					if(paymentMethod.equalsIgnoreCase("creditcard") && allowDiscountOnCCPayment.equalsIgnoreCase("N")){
						Utils.log("if block open amt >>>> "+Double.parseDouble(openAmountArrayData[i]));
						openAmt=Double.parseDouble(openAmountArrayData[i]);
						Utils.log("if block open amt >>>> "+openAmt);
					}
					else{ 
						Utils.log("else block open amt >>>> "+Double.parseDouble(openAmountArrayData[i]));
						openAmt=Double.parseDouble(openAmountArrayData[i])-Double.parseDouble(disAmountArrayData[i]);					
						Utils.log("else block open amt >>>> "+openAmt);
					}
					
					pstmt.setString(1, customerId); 
					pstmt.setString(2, systemIdArrayData[i].trim()); 
					pstmt.setString(3, "");
					pstmt.setString(4, invoiceNoArrayData[i].trim()); 
					pstmt.setString(5, "");
					pstmt.setString(6, "");
					pstmt.setString(7, ""); 
					pstmt.setString(8, "");
					pstmt.setInt(9, Integer.parseInt(shipToSequence.trim())); 
					pstmt.setInt(10, Integer.parseInt(billToSequence.trim())); 
					pstmt.setDouble(11, openAmt); 
					pstmt.setDouble(12, openAmt); 
					pstmt.setDouble(13, 0); 
					pstmt.setDouble(14, 0); 
					pstmt.setString(15, paymentId); 
				
					pstmt.addBatch();
				}
    			
    		}
			
            int[] count = pstmt.executeBatch();
            Utils.log("count : " + count.length);
            if(count.length>0)
				message = "Data has been inserted";
			else 
				message =  "Unable to process your request. Please try after some time.";
            
            //con.commit();
            Utils.close(pstmt);
            Utils.close(con);
		
		}
		catch(SQLException sqlEx){
			try{
				con.rollback();
			}
			catch (Exception e) {
				Utils.log("SQL Exception :: " , e);
			}
			Utils.close(pstmt);
            Utils.close(con);
            sqlEx.printStackTrace();
			Utils.log("SQL Exception :: " , sqlEx);
		}
		catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);
            Utils.close(con);
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}
		finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return message;
	}
	
	
	public String insertCashReceiptsCCTokenPaymentResponse(String invoiceNumber,String amountTendered,String surcharge,String approvedAmount,String paymentId, String merchantName,
			String merchantAddressOne, String merchantAddressTwo, String merchantCity,String merchantState,String merchantZip,String transactionAmount,String transactionDate,
			String accountNumber, String authorizationCode, String applicationId, String surchargeAmount, String surchargeDescriptor, String cardNetworkName, String applicationLabel,
			String terminalId, String cardholderName, String salesTaxAmount, String transactionType, String entryMode, String approvalNumber, String HostResponse, String customerId)
	{
		String status="fail";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_CC_RESPONSE (INVOICENUMBER,AMOUNTTENDERED,SURCHARGE,APPROVEDAMOUNT,PAYMENTID,MERCHANTNAME,MERCHANTADDRESS1,"
						+" MERCHANTADDRESS2,MERCHANTCITY,MERCHANTSTATE,MERCHANTZIP,TRANSACTIONAMOUNT,TRANSACTIONDATE,ACCOUNTNUMBER,AUTHORIZATIONCODE,"   
						+" APPLICATIONID,SURCHARGEAMOUNT,SURCHARGEDESCRIPTOR,CARDNETWORKNAME,APPLICATIONLABEL,TERMINALID,CARDHOLDERNAME,SALESTAXAMOUNT,"
						+" TRANSACTIONTYPE,ENTRYMODE,APPROVALNUMBER,HOSTRESPONSE,CUST_CODE,CREATED_DATE,CREATED_TIME) "
						+" values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURRENT_DATE,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, invoiceNumber); 
			pstmt.setString(2, amountTendered); 
			pstmt.setString(3, surcharge); 
			pstmt.setString(4, approvedAmount); 
			pstmt.setString(5, paymentId);
			pstmt.setString(6, merchantName); 
			pstmt.setString(7, merchantAddressOne); 
			pstmt.setString(8, merchantAddressTwo); 
			pstmt.setString(9, merchantCity); 
			pstmt.setString(10, merchantState); 
			pstmt.setString(11, merchantZip); 
			pstmt.setString(12, transactionAmount); 

			SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
			Date date = dt.parse(transactionDate);
			SimpleDateFormat dt1 = new SimpleDateFormat("dd-MMM-yyyy");

			pstmt.setString(13, dt1.format(date));
			pstmt.setString(14, accountNumber);
			pstmt.setString(15, authorizationCode);
			pstmt.setString(16, applicationId);
			pstmt.setString(17, surchargeAmount);
			pstmt.setString(18, surchargeDescriptor);
			pstmt.setString(19, cardNetworkName);
			pstmt.setString(20, applicationLabel);
			pstmt.setString(21, terminalId);
			pstmt.setString(22, cardholderName);
			pstmt.setString(23, salesTaxAmount);
			pstmt.setString(24, transactionType);
			pstmt.setString(25, entryMode);
			pstmt.setString(26, approvalNumber);
			pstmt.setString(27, HostResponse);
			pstmt.setString(28, customerId);
			SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
			Date createdTime = new Date();
			pstmt.setString(29, sdf.format(createdTime));
			
			pstmt.execute();
			status="success";

			Utils.close(pstmt);				
			Utils.close(con);

		} catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);				
			Utils.close(con);
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return status;
	}
	
	
	public String insertDmsiApiInvPaySelected(String customerId,String branchId,String processDate,String invoiceNumber,String shipmentNumber,
			 							String invoiceType, String shipToSequence,String billToSequence,String openAmount,String paymentAmount,
										String discountAmount, String invoiceBalance, String paymentId)
	{
		String status="fail";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_INV_PAY_SELECTED (CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,SHIPMENT_NUMBER,INVOICE_TYPE, "
								+" SHIPTO_SEQUENCE,BILLTO_SEQUENCE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT,INVOICE_BALANCE,PAYMENT_ID) "   
								+" values (?,?,?,?,?,?,?,?,?,?,?,?,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, customerId); 
			pstmt.setString(2, branchId); 
			
			SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
			Date date = dt.parse(processDate);
			SimpleDateFormat dt1 = new SimpleDateFormat("dd-MMM-yyyy");
			
			pstmt.setString(3, dt1.format(date)); 
			pstmt.setString(4, invoiceNumber); 
			pstmt.setString(5, shipmentNumber);
			pstmt.setString(6, invoiceType); 
			pstmt.setString(7, shipToSequence); 
			pstmt.setString(8, billToSequence); 
			pstmt.setString(9, openAmount); 
			pstmt.setString(10, paymentAmount); 
			pstmt.setString(11, discountAmount); 
			pstmt.setString(12, invoiceBalance); 
			pstmt.setString(13, paymentId); 
			
			pstmt.execute();
			status="success";

			Utils.close(pstmt);				
			Utils.close(con);

		} catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);				
			Utils.close(con);
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return status;
	}


	public String insertDmsiApiInvPaySelectedBatchUpdate(String customerId,String[] systemIdArrayData,String[] invoiceNoArrayData,String[] openAmountArrayData,String[] disAmountArrayData,
									String shipToSequence, String billToSequence,String amountTendered,String invoiceBalance, String paymentId,String paymentMethod,String allowDiscountOnCCPayment)
	{
		String message="";
		Connection con = null;
		PreparedStatement pstmt=null;
		DistUtils du=null;
		try{
			//du=DistUtils.getDistUtils(session);
			du=new DistUtils();
			con=du.getPro2DataConnection();
			String sqlQuery="insert into DMSI_API_INV_PAY_SELECTED (CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,INVOICE_TYPE, "
								+" SHIPTO_SEQUENCE,BILLTO_SEQUENCE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT,INVOICE_BALANCE,PAYMENT_ID) "   
								+" values (?,?,CURRENT_DATE,?,?,?,?,?,?,?,?,?) ";
			
			Utils.log("Query : " + sqlQuery);
			pstmt = con.prepareStatement(sqlQuery);

			for(int i=0;i<invoiceNoArrayData.length;i++){
				double openAmt=0;
				if(paymentMethod.equalsIgnoreCase("creditcard") && allowDiscountOnCCPayment.equalsIgnoreCase("N"))
					openAmt=Double.parseDouble(openAmountArrayData[i]);
				else 
					openAmt=Double.parseDouble(openAmountArrayData[i])-Double.parseDouble(disAmountArrayData[i]);					
				
				pstmt.setString(1, customerId); 
				pstmt.setString(2, systemIdArrayData[i].trim()); 
				pstmt.setString(3, invoiceNoArrayData[i].trim()); 
				//pstmt.setInt(4, shipmentNumber); 
				pstmt.setString(4, "");
				pstmt.setInt(5, Integer.parseInt(shipToSequence.trim())); 
				pstmt.setInt(6, Integer.parseInt(billToSequence.trim())); 
				pstmt.setDouble(7, openAmt); 
				pstmt.setDouble(8, Double.parseDouble(amountTendered.trim())); 
				pstmt.setDouble(9, Double.parseDouble(disAmountArrayData[i].trim())); 
				pstmt.setDouble(10, Double.parseDouble(invoiceBalance.trim())); 
				pstmt.setString(11, paymentId); 
    			
    			pstmt.addBatch();
    		}
			
            int[] count = pstmt.executeBatch();
            Utils.log("count : " + count.length);
            if(count.length>0)
				message = "Data has been inserted";
			else 
				message =  "Unable to process your request. Please try after some time.";
            
            //con.commit();
            Utils.close(pstmt);
            Utils.close(con);
		
		}
		catch(SQLException sqlEx){
			try{
				con.rollback();
			}
			catch (Exception e) {
				Utils.log("SQL Exception :: " , e);
			}
			Utils.close(pstmt);
            Utils.close(con);
            sqlEx.printStackTrace();
			Utils.log("SQL Exception :: " , sqlEx);
		}
		catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);
            Utils.close(con);
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}
		finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return message;
	}

	
	public String insertDmsiApiInvPayError(String errorCode,String customerId,String branchId,String invoiceNumber,String paymentId,String errorMessage)
	{
		String status="fail";
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getPro2DataConnection();
			sqlQuery="insert into DMSI_API_INV_PAY_ERROR (ERROR_CODE,CUSTOMER_ID,BRANCH_ID,PROCESS_DATE,INVOICE_NUMBER,PAYMENT_ID,ERROR_MESSAGE) "   
							+" values (?,?,?,CURRENT_DATE,?,?,?) ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, errorCode); 
			pstmt.setString(2, customerId); 
			pstmt.setString(3, branchId); 
			pstmt.setString(4, invoiceNumber); 
			pstmt.setString(5, paymentId);
			pstmt.setString(6, errorMessage); 
			
			pstmt.execute();
			status="success";
			
			Utils.close(pstmt);				
			Utils.close(con);
			
		} catch (Exception e) {
			// TODO: handle exception
			Utils.close(pstmt);				
			Utils.close(con);
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(pstmt);				
			Utils.close(con);
		}
		return status;
	}
	
	
	public JSONObject sendMail(String from,String to,String sendCC,String sendBCC, 
			String subject,String tag,String htmlBody,String textBody,
			String replyTo,String messageStream) {

		String url="";
		try{
			FileReader reader=new FileReader("eTechLogix.properties");  
			Properties prop=new Properties();  
			prop.load(reader);    
			url=prop.getProperty("EmailUrl");
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		headerMaps.put("X-Postmark-Server-Token", "6b22e017-8903-4030-bf0e-d45d63c3f4d3");
		
		JSONObject reqBody=new JSONObject();
		reqBody.put("From", from);
		reqBody.put("To", to);
		reqBody.put("Cc", sendCC);
		reqBody.put("Bcc", sendBCC);
		reqBody.put("Subject", subject);
		reqBody.put("Tag", tag);
		reqBody.put("HtmlBody", htmlBody);
		reqBody.put("TextBody", textBody);
		reqBody.put("ReplyTo", replyTo);
		reqBody.put("MessageStream", messageStream);
		
		String contentType=MediaType.APPLICATION_JSON;
		Utils.log("Request: "+reqBody);
		//return apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
	
		ApiCall apiCallObj = new ApiCall();
		JSONObject jsonObj = apiCallObj.apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
		return jsonObj;
	}

	
	public ArrayList<HashMap<String, String>> getDmsiApiInvPayResponseData(String paymentId) {	
		String sqlQuery="",filterString = "",orderNo="",shipmentNo="",invoiceFilePath="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select INVOICE_NUMBER,INVOICE_TYPE,OPEN_AMOUNT,PAYMENT_AMOUNT,DISCOUNT_AMOUNT from DMSI_API_INV_PAY_RESPONSE where PAYMENT_ID='"+paymentId+"' ";
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector invoiceNoVector = new Vector();
			Vector invoiceTypeVector = new Vector();
			Vector paymentAmountVector = new Vector();
			Vector discountAmountVector = new Vector();
			if (ht != null && ht.size() > 0) {
				invoiceNoVector = (Vector)ht.get("INVOICE_NUMBER");
				invoiceTypeVector = (Vector)ht.get("INVOICE_TYPE");
				paymentAmountVector = (Vector)ht.get("PAYMENT_AMOUNT");
				discountAmountVector = (Vector)ht.get("DISCOUNT_AMOUNT");
			}
	        if (invoiceNoVector.size() > 0) {
	        	for (int i = 0; i < invoiceNoVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("invoiceNo", invoiceNoVector.get(i).toString());
	        		temp.put("invoiceType", invoiceTypeVector.get(i).toString());
	        		temp.put("paymentAmount", paymentAmountVector.get(i).toString());
					temp.put("discountAmount", discountAmountVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

	public HashMap<String,String> getUserDetails(String customerId){
		String query="";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query="select DISTINCT FIRSTNAME,MIDDLENAME,LASTNAME,ADDRESS,STATE,CITY,ZIP,PHONE,EMAILID,ALLOWAUTHORIZED,"
					+"ALLOWDISCOUNTONCCPAYMENT,CCSURCHARGEFEESPERCENT,ALLOWDISCOUNTACHPAY from ETECHUSER where DEPTID='"+customerId.trim()+"' and PAYMENTS='Y' ";
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


<%-- <jsp:forward page="../customerPortal/A_CP_InvoicePayment.jsp"></jsp:forward> --%>

