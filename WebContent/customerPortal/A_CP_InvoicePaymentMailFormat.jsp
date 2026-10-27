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
<%-- <%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%> --%>

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
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();
	
	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}
	String userId = (String)session.getAttribute("userId");
	
	Utils.log("inside invoice payment email format page >>>>>>>> ");
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	String allowDiscountOnCCPayment = (String)session.getAttribute("allowDiscountOnCCPayment");
	Utils.log("allowDiscountOnCCPayment :: " + allowDiscountOnCCPayment);
	
	String customerFirstName = (String)session.getAttribute("firstName");
	String customerLastName = (String)session.getAttribute("lastName");
	//String customerEmailId = (String)session.getAttribute("emailId");
	String customerEmailId = "sachendra.agr@gmail.com";
	
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	FileReader reader=new FileReader("eTechLogix.properties");  
    Properties prop=new Properties();  
    prop.load(reader);    
    String url=prop.getProperty("AgilityUrl");
    String loginUrl = url+"Session/Login";
    
	JSONObject childBody=new JSONObject();
	childBody.put("LoginID", "bfarooq");
	childBody.put("Password", "rwc");
	JSONObject mainBody=new JSONObject();
	mainBody.put("request", childBody);
	
	try {
		String message="";
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");  
		Date transactionDate = new Date();
		
		String row="";
		for(int k=1;k<=4;k++){
			row+="<tr><td width=\"100\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+"111"+k+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble("123456"+k))+"</td><td width=\"150\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble("2.5"+k))+"</td>";
		}
		
		String from = "RWC Customer Service Portal <portal@rwc.org>";
		String to = customerEmailId;
		//String sendCC = "";
		//String sendCC = "it@rwc.org";
		String sendCC = "sachendra@letuscode.com,sachendra.agr@gmail.com";
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
										"<tr><td><ul style=\"list-style-type: none;\"><li><b> Amount : &nbsp;</b>$"+df.format(Double.parseDouble("123456"))+"</li>"+
													"<li><b> Surcharge : </b>&nbsp;"+"123456789"+"</li>"+
													"<li><b> Transaction ID : </b>&nbsp;"+"123456789"+"</li>"+
													"<li><b> Date : </b>&nbsp;"+sdf.format(transactionDate)+"</li>"+
										"</ul></td></tr>"+	
										"<tr><td></td></tr><tr><td></td></tr>"+
										"<tr><td>The following invoices have been paid through this payment.</td></tr>"+
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
												
												
		        						/*htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
        										"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
        											"<tr><td><table height=\"100\" width=\"100%\">"+
        														"<tr><td><b>"+customerFirstName+"&nbsp;"+customerLastName+",</b></td></tr>"+
        														"<tr><td></td></tr>"+
        														"<tr><td></td></tr>"+
        														"<tr><td></td></tr>"+
        														"<tr><td><b> Your recent payment has been successfully processed.</b></td></tr>"+
        														"<tr><td></td></tr><tr><td></td></tr>"+
        														"<tr><td><b> Transaction Details:</b></td></tr>"+
        														"<tr><td><ul style=\"list-style-type: none;\"><li><b> Amount : &nbsp;</b>$"+df.format(Double.parseDouble("12345"))+"</li>"+
        																"<li><b> Surcharge : </b>&nbsp;"+"123456789"+"</li>"+
        																"<li><b> Transaction ID : </b>&nbsp;"+"123456789"+"</li>"+
        																"<li><b> Date : </b>&nbsp;"+sdf.format(transactionDate)+"</li>"+
        														"</ul></td></tr>"+	
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
        										"</table></BODY></html>";*/


		JSONObject mailResObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
		Utils.log("Response :"+mailResObj);
		if(Integer.parseInt(mailResObj.get("ErrorCode").toString()) == 0) {
			Utils.log("Message : "+mailResObj.get("Message")+"");
			message="Your payment has been successfully processed. A confirmation email has been sent to your inbox.";
		}else{
			message="Unable to process your request. Please try after some time.";
		}
	}
	catch (Exception e) {
		e.getMessage();
	}

	
	/*try {
		String message="MES0001311982-002 not found. (ID# 2381)";
		String row="";
		for(int k=0;k<4;k++){
			int slNo=k+1;
			//row+="<tr><td width=\"250\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+slNo+". Invoice No 111"+k+" - $"+df.format(Double.parseDouble("123456"+k))+"</td></tr>";
			row+="<tr><td width=\"170\" align=\"left\" style=\"border: .5px solid #f0f5f5\">"+"111"+k+"</td><td width=\"160\" align=\"right\" style=\"border: .5px solid #f0f5f5\">$"+df.format(Double.parseDouble("123456"+k))+"</td></tr>";
		}
		
		String from = "RWC Customer Service Portal <portal@rwc.org>";
		//String to = "bree@rwc.org,a.gonzalez@rwc.org";
		String to = "sachendra.agr@gmail.com,sachendra@letuscode.com";
		//String sendCC = "";
		String sendCC = "it@rwc.org";
		String sendBCC = "";
		String subject = "";
		String tag = "Invitation";
		String htmlBody = "";
		String textBody = "Hello";
		String replyTo = "";
		String messageStream = "outbound";
		
		subject="Payment# 45672345565656 Not Applied as Requested";
		htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
						"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
							"<tr><td><table height=\"100\" width=\"100%\">"+
										"<tr><td><b>Hi AR Team,</b></td></tr>"+
										"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
										"<tr><td>We have received a payment from <b>"+customerFirstName+"&nbsp;"+customerLastName+"</b> in the amount of <b>$123456</b> with the payment ID</td></tr>"+
										"<tr><td><b>45672345565656</b>. However, this payment has not been applied to any specific invoice due to the following error: </td></tr>"+
										"<tr><td><b>"+message+"</b></td></tr>"+
										"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
										"<tr><td>Below are the selected invoices for this payment:</td></tr>"+
										"<tr><td><table border=\"0\" style=\"border: .5px solid #f0f0f5\">"+
												"<tr><td align=\"left\" style=\"border: .5px solid #f0f5f5\"><b>Invoice#</b></td><td align=\"right\" style=\"border: .5px solid #f0f5f5\"><b>Payment Amt</b></td></tr>"+
												row+
											"</table></td></tr>"+
										"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
										"<tr><td>Could you please resolve the issue and apply the payment accordingly? </td></tr>"+
										"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
										"<tr><td>Thank you for your assistance</td></tr>"+
										"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
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
	}
	catch (Exception e) {
		e.getMessage();
	}*/

%>

<%!


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
		return apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
	
		//ApiCall apiCallObj = new ApiCall();
		//JSONObject jsonObj = apiCallObj.apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
		//return jsonObj;
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
			Utils.log("URL : " + url);
			Utils.log("Data : " + data);
			
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
						
						Utils.log(entry.getKey()+" : "+entry.getValue());
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
				
				Utils.log("Log : "+stringBuilder);
				
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
				
				Utils.log("Log : "+stringBuilder);
	
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


%>


<%-- <jsp:forward page="../customerPortal/A_CP_InvoicePayment.jsp"></jsp:forward> --%>

