<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.Utils"%>
<%@page import="com.etechlogix.distribution.utils.*"%>
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
<%-- <%@page import = "org.json.*" %> --%>
<%@page import="jakarta.servlet.http.Part"%>
<%@page import="jakarta.servlet.annotation.MultipartConfig"%>


<%
	String param=request.getParameter("param");
	Utils.log("Param  >>>> " + param);
	if(param.equalsIgnoreCase("SaveOrUpdateUserDetails")) {
		try {
			String userId = (String)session.getAttribute("userId");
			String firstName=request.getParameter("firstName");
			String middleName=request.getParameter("middleName");
			String lastName=request.getParameter("lastName");
			String emailId=request.getParameter("emailId");
			String address=request.getParameter("address");
			String city=request.getParameter("city");
			String state=request.getParameter("state");
			String zip=request.getParameter("zip");
			String phone=request.getParameter("phone");
			
			String result="";
			String recordExistStatus=recordExist(userId);
			if(recordExistStatus.trim().equals("")){
				result = insertUserDetails(userId,firstName,middleName,lastName,emailId,address,city,state,zip,phone);
				if(result.equalsIgnoreCase("success"))
					request.setAttribute("message", "Details has been inserted");
				else
					request.setAttribute("message", "We are facing some technical issue. Please try again....");
			}else{
				result = updateUserDetails(userId,firstName,middleName,lastName,emailId,address,city,state,zip,phone);
				if(result.equalsIgnoreCase("success"))
					request.setAttribute("message", "Details has been updated");
				else
					request.setAttribute("message", "We are facing some technical issue. Please try again....");
			}
		}
		catch (Exception e) {
			e.getMessage();
		}
		%>
		<jsp:forward page="../customerPortal/A_CP_UserProfile.jsp?pageName=UserProfile"></jsp:forward>
		<%
	}
	else if(param.equalsIgnoreCase("ChangePassword")) {
		String message="";
		try {
			String from = "RWC Customer Service Portal <portal@rwc.org> ";
			String to = "";
			String sendCC = "it@rwc.org";
			String sendBCC = "";
			String subject = "Your Password Has Been Successfully Updated";
			String tag = "Invitation";
			String htmlBody = "";
			String textBody = "Hello";
			String replyTo = "";
			String messageStream = "outbound";

			String userId=(String)session.getAttribute("userId");
			String firstName = (String)session.getAttribute("firstName");
			String lastName = (String)session.getAttribute("lastName");
			String emailId=(String)session.getAttribute("emailId");
			to=emailId;
			String currentPassword=request.getParameter("currentPassword");
			String newPassword=request.getParameter("newPassword");
			String confirmNewPassword=request.getParameter("confirmNewPassword");

			String password=passwordExit(newPassword,userId);
			if(newPassword.trim().equals(password.trim())){
				message="Password already exit";
			}else if(currentPassword.trim().equals(newPassword.trim())){
				message="Current Password and New Password can not be same";
			}else if(!newPassword.trim().equals(confirmNewPassword.trim())){
				message="New Password and Confirm New Password are not same";
			}else{
				String status = changePassword(currentPassword,newPassword,confirmNewPassword,userId);
				if(status.equalsIgnoreCase("success")){
					String loginStatus=updateFirstTimeLogin(userId);
					Utils.log("LoginStatus >>>> " + loginStatus);
					
					htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
									"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
										"<tr><td><table height=\"100\" width=\"100%\">"+
													"<tr><td><p>Hello &nbsp;"+firstName+"&nbsp;"+lastName+",</p></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td><p> We're confirming that your password has been successfully updated. Your account security is important to us, and we're glad to see you taking steps to protect it.</p></td></tr>"+
													"<tr><td><p> If you did not initiate this change or if you encounter any issues signing in with your new password, please contact our support team immediately at it@rwc.org.</p></td></tr>"+
													"<tr><td><p> Thank you for being a valued customer.</p></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td><p> Best Regards, </p></td></tr>"+
												  	"<tr><td><p> RWC Building Products Customer Service </p></td></tr>"+
												"</table></td></tr>"+
									"</table></BODY></html>";

					JSONObject responseObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
					Utils.log("Response :"+responseObj);
					if(Integer.parseInt(responseObj.get("ErrorCode").toString()) == 0) {
						Utils.log("Message : "+responseObj.get("Message")+"");
						message="Your Password Has Been Successfully Updated";
					}else {
						message="Unable to process your request. Please try after some time.";
					}
				}
				else{
					message="Unable to process your request. Please try after some time.";
				}
				//response.sendRedirect("../customerPortal/A_CP_Logout.jsp");
			}
		}
		catch (Exception e) {
			e.getMessage();
		}
		
		//out.print(message.toString());
		response.setContentType("text/html");
        response.getWriter().print(message.toString());
    	out.flush();
		
	}
	else if(param.equalsIgnoreCase("UpdatePassword")) {
		try {
			String from = "RWC Customer Service Portal <portal@rwc.org> ";
			String to = "";
			String sendCC = "it@rwc.org";
			String sendBCC = "";
			String subject = "Your Password Has Been Successfully Updated";
			String tag = "Invitation";
			String htmlBody = "";
			String textBody = "Hello";
			String replyTo = "";
			String messageStream = "outbound";

			String userId=(String)session.getAttribute("userId");
			String firstName = (String)session.getAttribute("firstName");
			String lastName = (String)session.getAttribute("lastName");
			String emailId=(String)session.getAttribute("emailId");
			to=emailId;
			String currentPassword=request.getParameter("currentPassword");
			String newPassword=request.getParameter("newPassword");
			String confirmNewPassword=request.getParameter("confirmNewPassword");

			String password=passwordExit(newPassword,userId);
			if(newPassword.trim().equals(password.trim())){
				request.setAttribute("message","Password already exit");
			}else if(currentPassword.trim().equals(newPassword.trim())){
				request.setAttribute("message","Current Password and New Password can not be same");
			}else if(!newPassword.trim().equals(confirmNewPassword.trim())){
				request.setAttribute("message","New Password and Confirm New Password are not same");
			}else{
				String status = changePassword(currentPassword,newPassword,confirmNewPassword,userId);
				if(status.equalsIgnoreCase("success")){
					String loginStatus=updateFirstTimeLogin(userId);
					Utils.log("LoginStatus >>>> " + loginStatus);
					
					htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
									"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
										"<tr><td><table height=\"100\" width=\"100%\">"+
													"<tr><td><p>Hello &nbsp;"+firstName+"&nbsp;"+lastName+",</p></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td><p> We're confirming that your password has been successfully updated. Your account security is important to us, and we're glad to see you taking steps to protect it.</p></td></tr>"+
													"<tr><td><p> If you did not initiate this change or if you encounter any issues signing in with your new password, please contact our support team immediately at it@rwc.org.</p></td></tr>"+
													"<tr><td><p> Thank you for being a valued customer.</p></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td></td></tr>"+
													"<tr><td><p> Best Regards, </p></td></tr>"+
												  	"<tr><td><p> RWC Building Products Customer Service </p></td></tr>"+
												"</table></td></tr>"+
									"</table></BODY></html>";

					JSONObject responseObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
					Utils.log("Response :"+responseObj);
					if(Integer.parseInt(responseObj.get("ErrorCode").toString()) == 0) {
						Utils.log("Message : "+responseObj.get("Message")+"");
						request.setAttribute("message","Your Password Has Been Successfully Updated");
					}else {
						request.setAttribute("message","Unable to process your request. Please try after some time.");
					}
				}
				else{
					request.setAttribute("message","Unable to process your request. Please try after some time.");
				}
				%><jsp:forward page="../login.jsp"></jsp:forward><%
			}
		}
		catch (Exception e) {
			e.getMessage();
		}
		%><jsp:forward page="../customerPortal/A_CP_ChangePassword.jsp"></jsp:forward><%
	}
	else if(param.equalsIgnoreCase("ForgotPassword")) {
		try {
			String from = "RWC Customer Service Portal <portal@rwc.org>";
			String to = "";
			String sendCC = "";
			//String sendBCC = "delivery@rwc.org";
			String sendBCC = "";
			String subject = "Forgot Password";
			String tag = "Invitation";
			String htmlBody = "";
			String textBody = "Hello";
			String replyTo = "";
			String messageStream = "outbound";				

			to = request.getParameter("emailId");
			request.setAttribute("emailId",to);
			//String userId = (String)session.getAttribute("userId");
			HashMap<String,String> hm=forgetPassword(to);
			String status=(String)hm.get("status");
			if(status.equals("invalid")){
				request.setAttribute("message","Invalid email. Please enter the email that you registered with.");
			}
			else{
				String pwd=(String)hm.get("password");
				//String pwd="1234";
				String mobileNo=(String)hm.get("mobileNo");
				//String recipients[]={to};  
				subject="Your user informaion";
				htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\"><table border=\"0\"  width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\"><tr><td><table height=\"200\" ><tr><td >Dear &nbsp;Sir,</td></tr><br>"+
								"<tr><td><p> We have received a password request and your password is&nbsp;<b>"+pwd+"</b>. Please change it in next login. </p> </td></tr><br>"+
								"<p><tr><td>"+
								"<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;Use the following username and password to login<br></tr></td>"+
								"</table></td></tr></p><br>"+
							  	"<td><tr><p>Thanks for your cooperation.</p></td></tr><br>"+
							  	"<tr><td ><p> Keep writing us to make it more users friendly.</p><br></td></tr>"+
								"<tr><td ><p>Regards,</p></td></tr><br>"+
								"<tr><td><p>Activation Team</p><br></td></tr></table></td></tr>"+
								"</tr></td></table></BODY></html>";

				JSONObject responseObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
				Utils.log("Response :"+responseObj);
				if(Integer.parseInt(responseObj.get("ErrorCode").toString()) == 0) {
					Utils.log("Message : "+responseObj.get("Message")+"");
					//request.setAttribute("message", responseObj.get("Message"));
					request.setAttribute("message","Password sent to your email.");
				}else {
					request.setAttribute("message", "Unable to process your request. Please try after some time.");
				}
			}
		}
		catch (Exception e) {
			e.getMessage();
		}
		%>
		<jsp:forward page="../customerPortal/A_CP_ForgetPassword.jsp"></jsp:forward>
		<%
	}
	else if(param.equalsIgnoreCase("SignUp")) {
		try {
			String from = "RWC Customer Service Portal <portal@rwc.org>";
			String to = "";
			//String sendCC = "";
			String sendCC = "it@rwc.org,jvillanueva@henryproducts.com";
			String sendBCC = "";
			//String sendBCC = "delivery@rwc.org";
			String subject = "";
			String tag = "Invitation";
			String htmlBody = "";
			String textBody = "Hello";
			String replyTo = "";
			String messageStream = "outbound";
			
			String companyName=request.getParameter("companyName");
			String rwcCustomerId=request.getParameter("rwcCustomerId");
			String firstName=request.getParameter("firstName");
			String lastName=request.getParameter("lastName");
			String emailId=request.getParameter("emailId");
			to=emailId;
			String phoneNo=request.getParameter("phoneNo");

			subject="Request Received: Access to RWC Customer Portal";
			htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
							"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
								"<tr><td><table height=\"100\" width=\"100%\">"+
											"<tr><td align=\"center\" style=\"font-size: 20px;\"><b>RWC Customer Portal Access Request</b></td></tr><br>"+
											"<tr><td><p><b> Hello &nbsp;"+firstName+",</b></p></td></tr><br>"+
											"<tr><td><p> Thank you for your interest in the RWC Building Products Customer Portal. We have successfully received your access request and are currently reviewing the details you provided.</p></td></tr><br>"+
											"<tr><td><p><b> Registration Details:</b></p></td></tr><br>"+
											"<tr><td><p><ul><li><b> Company name: &nbsp;</b>"+companyName+"</li>"+
															"<li><b> RWC Customer ID: &nbsp;</b>"+rwcCustomerId+"</li>"+
															"<li><b> First Name: &nbsp;</b>"+firstName+"</li>"+
															"<li><b> Last Name: &nbsp;</b>"+lastName+"</li>"+
															"<li><b> Email: &nbsp;</b>"+emailId+"</li>"+
															"<li><b> Phone: &nbsp;</b>"+phoneNo+"</li>"+
											"</ul></p></td></tr><br>"+	
										  	"<tr><td><p> We will process your request as quickly as possible. Most requests are completed within one to two business days. Should we require any additional information or have questions about your request, we will contact you directly. We appreciate your patience and are eager to help you make the most of our Customer Portal.</p></td></tr><br>"+
										  	"<tr><td><p><b> Best Regards,</b></p></td></tr><br>"+
										  	"<tr><td><p><b> RWC Building Products</b></p></td></tr><br>"+
										"</table></td></tr>"+
							"</table></BODY></html>";

			JSONObject responseObj = sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
			Utils.log("Response :"+responseObj);
			if(Integer.parseInt(responseObj.get("ErrorCode").toString()) == 0) {
				Utils.log("Message : "+responseObj.get("Message")+"");
				request.setAttribute("message", "Thank you for your registration request. Our team will reach out to you with further details within 24-48 hours.");
				String result = saveSignUpDetails(companyName,rwcCustomerId,firstName,lastName,phoneNo,emailId);
				if(result.equalsIgnoreCase("success"))
					request.setAttribute("message", "Thank you for your registration request. Our team will reach out to you with further details within 24-48 hours.");
				else
					request.setAttribute("message", "We are facing some technical issue. Please try again....");
			}else {
				request.setAttribute("message", "Unable to process your request. Please try after some time.");
			}						  			
		}
		catch (Exception e) {
			e.getMessage();
		}
		%>
		<jsp:forward page="../customerPortal/A_CP_SignUpMessage.jsp"></jsp:forward>
		<%
	}

%>

<%!

	public String recordExist(String userId){
		String userIdExist="";   
		try{
			DistUtils du=new DistUtils();								
			String query = " select USERID from ETECHUSER where USERID='"+userId+"' ";
			Utils.log("User Id Exist >>>> " + query);
			userIdExist = Utils.removeNull(du.getFieldInfo(query));
		}
		catch (Exception e) {
			e.getMessage();
		}
		return userIdExist;
	}

	
	public String insertUserDetails(String userId,String firstName,String middleName,String lastName,String emailId,
									String address,String city,String state,String zip,String phone)
	{
		String queryStatus="fail";
		String sqlQuery="";
		Connection con = null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="insert into ETECHUSER (USERID,FIRSTNAME,MIDDLENAME,LASTNAME,EMAILID,ADDRESS,CITY,STATE,ZIP,PHONE) "
						+"values ('"+userId+"','"+firstName+"','"+middleName+"','"+lastName+"','"+emailId+"','"+address+"','"+city+"','"+state+"','"+zip+"','"+phone+"') ";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				queryStatus="success";
	
			Utils.close(stmt);
			Utils.close(con);
		
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(stmt);				
			Utils.close(con);
		}
		return queryStatus;
	}
	
	
	public String updateUserDetails(String userId,String firstName,String middleName,String lastName,String emailId,
										String address,String city,String state,String zip,String phone)
	{
		String queryStatus="fail";
		String sqlQuery="";
		Connection con = null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="update ETECHUSER set FIRSTNAME='"+firstName+"',MIDDLENAME='"+middleName+"',LASTNAME='"+lastName+"',EMAILID='"+emailId+"',"
						+"ADDRESS='"+address+"',CITY='"+city+"',STATE='"+state+"',ZIP='"+zip+"',PHONE='"+phone+"' "
						+" where USERID='"+userId+"' ";
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				queryStatus="success";
		
			Utils.close(stmt);
			Utils.close(con);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(stmt);
			Utils.close(con);
		}
		return queryStatus;
	}

	
	public String passwordExit(String newPassword,String userId){
		String password ="";
		try{
			DistUtils distUtils=new DistUtils();
			password = Utils.removeNull(distUtils.getFieldInfo(" select PASSWORD from ETECHUSER where PASSWORD='"+newPassword+"'and USERID='"+userId+"' "));
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}
		return password;
	}
	
	public String changePassword(String currentPassword,String newPassword,String confirmNewPassword,String userId )
	{
		String queryStatus="fail";
		String sqlQuery="";
		Connection con = null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="update ETECHUSER set PASSWORD='"+confirmNewPassword+"' where PASSWORD='"+currentPassword+"'and USERID='"+userId+"' ";
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				queryStatus="success";
		
			Utils.close(stmt);
			Utils.close(con);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(stmt);
			Utils.close(con);
		}
		return queryStatus;
	}

	public HashMap<String,String> forgetPassword(String emailId) {	
		String sqlQuery="",status="invalid";
		HashMap<String, String> temp = new HashMap<String, String>();
		try {
			DistUtils du = new DistUtils();
			sqlQuery = " select EMAILID,PASSWORD from ETECHUSER where EMAILID='"+emailId+"' ";
			//sqlQuery = " select EMAILID,PASSWORD from ETECHUSER where USERID='"+emailId+"' ";
			Utils.log("Query :: "+sqlQuery);
			Hashtable ht=du.getDataFromQuery(sqlQuery);	
			Vector emailIdVector = new Vector();
			Vector passwordVector = new Vector();
			if (ht != null && ht.size() > 0) {
				emailIdVector = (Vector) ht.get("EMAILID");
				passwordVector = (Vector) ht.get("PASSWORD");
			}
	        if (emailIdVector.size() > 0) {
	        	for (int i = 0; i < emailIdVector.size(); i++) {  
	        		status="valid";
	        		temp.put("emailId", emailIdVector.get(i).toString());
					temp.put("password", passwordVector.get(i).toString());
					temp.put("status", status);
				}
			}else{
	        	temp.put("status", status);
	        }
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	
	}

	
	public String saveSignUpDetails(String companyName,String rwcCustomerId,String firstName,String lastName,String phoneNo,String emailId)
	{
		String queryStatus="fail";
		String sqlQuery="";
		Connection con = null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="insert into AE_PORTALSIGNUPREQUESTS (COMPANYNAME,CUSTOMERID,FIRSTNAME,LASTNAME,PHONE,EMAIL,DATECREATED)"
						+" values ('"+companyName+"','"+rwcCustomerId+"','"+firstName+"','"+lastName+"','"+phoneNo+"','"+emailId+"',CURRENT_DATE)";
			Utils.log("sqlQuery >>>> "+sqlQuery);
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				queryStatus="success";

			Utils.close(stmt);
			Utils.close(con);
		
		} catch (Exception e) {
			// TODO: handle exception
			Utils.close(stmt);
			Utils.close(con);
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(stmt);				
			Utils.close(con);
		}
		return queryStatus;
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
		
		//String url = "https://api.postmarkapp.com/email";
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

	
	public String updateFirstTimeLogin(String userId)
	{
		String queryStatus="fail";
		String sqlQuery="";
		Connection con = null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="update ETECHUSER set FIRSTTIMELOGIN=1 where USERID='"+userId+"'";
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				queryStatus="success";
		
			Utils.close(stmt);
			Utils.close(con);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("Exception :: " , e);
		}finally {
			Utils.close(stmt);
			Utils.close(con);
		}
		return queryStatus;
	}

%>
