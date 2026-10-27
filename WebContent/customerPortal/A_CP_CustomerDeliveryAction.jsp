<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.etechlogix.utils.Utils"%>
<%@page import="com.etechlogix.distribution.utils.*"%>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload"%>

<%@page import="java.io.BufferedReader" %>
<%@page import="java.io.DataOutputStream" %>
<%@page import="java.io.IOException" %>
<%@page import="java.io.InputStream" %>
<%@page import="java.io.InputStreamReader" %>

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

<%@page import="javax.ws.rs.core.MediaType" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="com.sun.jersey.api.client.*" %>
<%@page import="com.sun.jersey.api.client.WebResource.Builder" %>
<%@page import="com.sun.jersey.api.client.config.ClientConfig" %>
<%@page import="com.sun.jersey.api.client.config.DefaultClientConfig" %>
<%@page import="com.sun.jersey.client.urlconnection.HTTPSProperties" %>
<%@page import="com.sun.jersey.core.header.FormDataContentDisposition" %>
<%@page import="net.sf.json.JSONArray" %>
<%@page import="net.sf.json.JSONObject" %>
<%-- <%@page import="org.json.*" %> --%>

<%

	try {
		String param=request.getParameter("param");
		Utils.log("Param >>>>>>> " + param);
		if(param.equalsIgnoreCase("FetchImages")){
			String output="";
			String orderNo=request.getParameter("orderNo");
			String shipmentNo=request.getParameter("shipmentNo");
				
			String sqlQuery="";
			Connection con=null;
			Statement pstmt=null;
			ResultSet rs=null;
			String imgUrl="MobileService/OrderImage/";
			String folderName="1-"+orderNo+"-"+shipmentNo+"/";
			String finalImgUrl="",tempURL="",bucketName="";
			try {
				DistUtils du=new DistUtils();
				con=du.getConnection();
				//sqlQuery=" select COMPANYID,USERID,IMGTYPE,DELIMG,CREATED,SLNO from MOB_CONFIRM_IMG where ORDERID='"+orderNo+"' and SHIPMENTID='"+shipmentNo+"' " ;
				
				sqlQuery="select COMPANYID,USERID,IMGTYPE,DELIMG,CREATED,SLNO "
							+" from MOB_CONFIRM_IMG where ORDERID='"+orderNo+"' and SHIPMENTID='"+shipmentNo+"' "
				          	+" union "
				          	+" select COMPANYID,'DES' as USERID,IMGTYPE,DELIMG,CREATED,SLNO " 
							+" from MOB_DESCARTES_IMG where ORDERID='"+orderNo+"' and SHIPMENTID='"+shipmentNo+"' ";
				Utils.log("Query " + sqlQuery);
				pstmt=con.createStatement();
				rs=pstmt.executeQuery(sqlQuery);
				StringBuffer imageListBuffer=new StringBuffer();
				while(rs.next()) {
					if(!rs.getString("DELIMG").equals(null) || rs.getString("DELIMG") != ""){
						if(rs.getString(2).trim().equalsIgnoreCase("DES")){
							bucketName="rwcdescartes";
							finalImgUrl=rs.getString("DELIMG").trim();
							Utils.log("Inside des " + finalImgUrl);
						}
						else{
							bucketName="rwcappliveimage";
							finalImgUrl=imgUrl + folderName + rs.getString("DELIMG").trim();
							Utils.log("Inside app " + finalImgUrl);
						}
					}
					
					/*if(!rs.getString("DELIMG").equals(null) || rs.getString("DELIMG") != "")
						finalImgUrl=imgUrl + folderName + rs.getString("DELIMG").trim();
					else
						finalImgUrl="assets/images/NoImageAvailable.jpg";*/

					Utils.log(finalImgUrl);
					S3_Upload su=new S3_Upload();
					tempURL=su.getTempURL(finalImgUrl,bucketName);
					Utils.log("tempURL >>>> "+tempURL);

					imageListBuffer.append("<li><img src='"+tempURL+"' alt='No Imaage'></li>");
					//imageListBuffer.append("<li><img data-original=\'"+tempURL+"' src='"+tempURL+"'></li>");
				}
				output=imageListBuffer.toString();
			} 
			catch (Exception e) {
				// TODO: handle exception
				Utils.close(con);
				Utils.close(rs);
				Utils.close(pstmt);				
				e.printStackTrace();
				Utils.log("SS Exception :: " , e);
			}
			finally {
				Utils.close(con);
				Utils.close(rs);
				Utils.close(pstmt);				
			}
			out.print(output);
		}
		else if(param.equalsIgnoreCase("FetchNotes")){
			String output="";
			String orderNo = request.getParameter("orderNo");
			String shipmentNo = request.getParameter("shipmentNo");

			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();

			ArrayList<HashMap<String, String>> data = getNotesList(orderNo,shipmentNo);
			for(int i=0;i<data.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)data.get(i);
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("notes", map.get("notes"));
				jsonArray.add(jsonObj);
			}
			mainJSONObj.put("NotesList", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("PopulateEmail")){
			String orderNo=request.getParameter("orderNo");
			DistUtils du=new DistUtils();								
			String custCodeQuery=" select cust_code from so_header sh, cust ct where sh.cust_key=ct.cust_key and so_id='"+orderNo+"' ";
			String custCode=Utils.removeNull(du.getFieldInfoPro2(custCodeQuery));
			String emailQuery=" select email from CONTACT ct, cust cs where cs.CUST_KEY=ct.COMPANY_INTERNAL_KEY and cs.cust_code='"+custCode+"' ";
			String emailId=Utils.removeNull(du.getFieldInfoPro2(emailQuery));
			out.print(emailId.toString());
		}
		else if (param.equalsIgnoreCase("SendEmail")) {
			String emailId=request.getParameter("emailId");
			String orderNo=request.getParameter("orderNo");
			String shipmentNo=request.getParameter("shipmentNo");
			String loginUser=(String)session.getAttribute("userId");
			
			//String sendFrom="it@rwc.org";
			String sendFrom="";

			String from="RWC Building Products Delivery <delivery@rwc.org> ";
			String to=emailId;
			String sendCC="";
			String sendBCC="delivery@rwc.org";
			String subject="";
			String tag="Invitation";
			String htmlBody="";
			String textBody="Hello";
			String replyTo="";
			//boolean trackOpens=true;
			//String trackLinks="HtmlOnly";
			String messageStream="outbound";				

			Connection con=null;
			PreparedStatement pstmt=null;
			ResultSet rs=null;

			try{
				DistUtils du=new DistUtils();
				String sendFromQuery=" select emailid from etechuser where userid='"+loginUser+"'";
				Utils.log("Query for send from :: " + sendFromQuery);
				sendFrom=Utils.removeNull(du.getFieldInfo(sendFromQuery));
				
				String replyToQuery=" select uc.email_address from user_ctl uc, so_header sh where sh.created_by=uc.user_or_group_id and sh.so_id='"+orderNo+"' ";
				Utils.log("Query for reply to :: " + replyToQuery);
				replyTo=Utils.removeNull(du.getFieldInfoPro2(replyToQuery));
				
				if(replyTo == null || replyTo == ""){
					replyTo="it@rwc.org";
				}
			} 
			catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
				Utils.log("SS Exception :: " , e);
			}
			finally {
				Utils.close(pstmt);				
				Utils.close(rs);
				Utils.close(con);
			}

			
			MailSend mailSend=new MailSend();
			try {
				String sendTo=emailId;  
				subject="Re:Delivery images for Order#"+orderNo+" and Shipment#"+shipmentNo;
				
				htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\"><table border=\"0\"  width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\"><tr><td><table height=\"30\" ><tr><td style='font-family:\"Trebuchet MS\";font-size:14px;'></td></tr>"
							+"<p><tr><td>"
							+"<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td>&nbsp;<br></td></tr><tr><td style='font-family:\"Trebuchet MS\";font-size:14px;'>Hello,<br><br></tr></td>"
							+"</table></td></tr></p>"
							+"<tr><td style='font-family:\"Arial\";font-size:14px;'>Please click the link below to see your delivery images for <b>Order#"+orderNo+"</b> and <b>Shipment#"+shipmentNo+"</b> :&nbsp;<br><br><font><a href='https://reg2.rwc.org/so/ct_shp_img_Cron.jsp?orderNo="+orderNo+"&shipmentNo="+shipmentNo+"' target='_blank'>Delivery Images</a>  </font><br><br></td></tr>"
							+"<tr><td ><p style='font-family:\"Arial\";font-size:14px;'>We value your business!</p></td></tr><br><br>"
							+"<tr><td ><p style='font-family:\"Arial\";font-size:14px;'><b>RWC Customer Service</b></p></td></tr><br>"
							+"<tr><td ><p style='font-family:\"Arial\";font-size:14px;'><img src=\"https://reg2.rwc.org/rwcnewlogo.png\" width=\"15%\" height=\"15%\"/></p></td></tr><br>"
							+"</table></td></tr>"
							+"</tr></td></table></BODY></html>";
							
				//mailSend.send(subject, sendTo, sendFrom, sendCC, sendBCC, message);
				JSONObject responseObj=sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
				Utils.log("Response :"+responseObj);
				
				if(Integer.parseInt(responseObj.get("ErrorCode").toString()) == 0) {
					Utils.log("Message : "+responseObj.get("Message")+"");
					request.setAttribute("message", responseObj.get("Message"));
				}else {
					request.setAttribute("message", "Unable to process your request. Please try after some time.");
				}
			} 
			catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
			}
		}

	}
	catch (Exception e) {
		e.getMessage();
	}

%>

<%!

	public ArrayList<HashMap<String, String>> getNotesList(String orderNo,String shipmentNo) {
		String query="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query = " select notes from mob_notes where orderid='"+orderNo+"' and shipmentid='"+shipmentNo+"' ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector notesVector = new Vector();
			if (ht != null && ht.size() != 0) {
				notesVector = (Vector) ht.get("NOTES");
			}
	        if (notesVector.size() > 0) {
	        	for (int i = 0; i < notesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("notes", notesVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}




	public JSONObject sendMail(String from,String to,String sendCC,String sendBCC, 
								String subject,String tag,String htmlBody,String textBody,
								String replyTo,String messageStream) {
		
		String url="https://api.postmarkapp.com/email";
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
	}

	
	public JSONObject apiCall(String url,String data,String method,String contentType,HashMap<String, String> headerMaps){
		
		JSONObject json_obj=new JSONObject();
		String inputLine="";
		HttpsURLConnection httpsCon =null;
		HttpURLConnection httpCon =null;
		InputStream ins=null;
		InputStreamReader isr=null;
		BufferedReader in=null;
		try {
			Utils.log("URL : " + url);
			Utils.log("data : " + data);
			String protocall[]= url.split("://");

			if("http".equalsIgnoreCase(protocall[0])) {
				URL myurl=new URL(url);
				httpCon=(HttpURLConnection) myurl.openConnection();
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
					DataOutputStream wr=new DataOutputStream(httpCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
	
				StringBuilder stringBuilder=new StringBuilder();
				int responseCode=httpCon.getResponseCode();
	
				if(responseCode<400) {
					ins=httpCon.getInputStream();
				}else {
					ins=httpCon.getErrorStream();
				}
				isr=new InputStreamReader(ins);
				in=new BufferedReader(isr);
	
				while ((inputLine=in.readLine()) != null) {
					stringBuilder.append(inputLine);
				}
				
				Utils.log("Log : "+stringBuilder);
				
				if(stringBuilder!=null && stringBuilder.length()>0) {
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					json_obj=JSONObject.fromObject(output);
				}
	
			}else {
	
				// Create a trust manager that does not validate certificate chains
				TrustManager[] trustAllCerts=new TrustManager[] { new X509TrustManager() {
					public java.security.cert.X509Certificate[] getAcceptedIssuers() {
						return null;
					}
	
					public void checkClientTrusted(X509Certificate[] certs, String authType) {
					}
	
					public void checkServerTrusted(X509Certificate[] certs, String authType) {
					}
				} };
	
				// Install the all-trusting trust manager
				SSLContext sc=SSLContext.getInstance("SSL");
				sc.init(null, trustAllCerts, new java.security.SecureRandom());
				HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
	
				// Create all-trusting host name verifier
				HostnameVerifier allHostsValid=new HostnameVerifier() {
					public boolean verify(String hostname, SSLSession session) {
						return true;
					}
				};
	
				// Install the all-trusting host verifier
				HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
				URL myurl=new URL(url);
				httpsCon=(HttpsURLConnection) myurl.openConnection();
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
					DataOutputStream wr=new DataOutputStream(httpsCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
				StringBuilder stringBuilder=new StringBuilder();
				int responseCode=httpsCon.getResponseCode();
	
				Utils.log("Status code : "+responseCode);
				
				if(responseCode<400) {
					ins=httpsCon.getInputStream();
				}else {
					ins=httpsCon.getErrorStream();
				}
				isr=new InputStreamReader(ins);
				in=new BufferedReader(isr);
	
				while ((inputLine=in.readLine()) != null) {
					stringBuilder.append(inputLine);
	
				}
				
				Utils.log("Log : "+stringBuilder);
	
				if(stringBuilder!=null && stringBuilder.length()>0) {
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					json_obj=JSONObject.fromObject(output);
				}
	
			}
			return json_obj;
	
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


