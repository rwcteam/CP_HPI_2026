package com.etechlogix.distribution.utils;

import java.util.*;
import java.io.*;
import java.sql.SQLException;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

import javax.mail.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;

import com.etechlogix.utils.Utils;

import javax.ws.rs.core.MediaType;
import java.net.URL;
import java.net.HttpURLConnection;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import net.sf.json.JSONObject;


/**
 * MailSend class encapsulates the logic for sending an email from within
 * SmartDistributor.  It reads the necessary properties from the 
 * eTechLogix.properties file to find the SMTP mail server and to
 * find the default address for BCC e-mails.
 * @author mdg
 *
 */
public class MailSend {
	private Properties properties;
	private String mailUser;
	
	/**
	 * MailSend() is the creator for this class, accepting no
	 * parameters.  It will throw an IOException or SQLException
	 * because it attempts to instantiate an object that throws those
	 * exceptions.  
	 * @throws IOException - if it can't instantiate a Utils object.
	 * @throws SQLException - if it can't instantiate a Utils object.
	 */
	public MailSend() throws IOException, SQLException {
		try {
			Utils u = new Utils();
			properties = new Properties();
			
			String smtpServer = u.getSMTPServer();
			Utils.log("smtp"+smtpServer);
			properties.put("mail.smtp.host", smtpServer);
			
			mailUser = u.getProperty("MailUser");
		} catch (IOException e) {
			Utils.logError(e.getMessage(), e);
			throw e;
		} catch (SQLException e) {
			Utils.logError(e.getMessage(), e);
			throw e;			
		}
	}
	
	/**
	 * send() sends an e-mail based on the inbound parameters
	 * @param subject - subject line of the message.  A blank or null subject
	 * will be replaced with "No Subject"
	 * @param sendTo - address to send the e-mail to.  Can be multiple 
	 * addresses, but they must be in a valid e-mail format (name@adddress.com
	 * for example.  Invalid email addresses or a null or blank sendTo
	 * will throw a MessagingException
	 * @param sendFrom - address that is sending the e-mail.  If multiple
	 * addresses are included in the inbound string, only the first one will
	 * be used.  Invalid email addresses or a null or blank sendFrom will
	 * throw a MessagingException  
	 * @param sendCC - addresses that will be copied on the e-mail.  Addresses
	 * must be valid or a MessagingException will be thrown.  Blank or null
	 * values will mean no CC's are sent.
	 * @param sendBCC - addresses that will be blind copied on the e-mail.
	 * Addresses must be valid or a MessagingException will be thrown.  By
	 * default, a BCC will always be sent to the MailUser property stored in
	 * eTechLogix.properties.  If no address is defined in eTechLogix.properties,
	 * no default BCC will be sent.  Blank or null values passed will mean no
	 * additional BCC's are sent.
	 * @param message - The message to be sent.  The email is formatted
	 * as text/html so the message should follow standard HTML formatting
	 * guidelines.
	 * @throws MessagingException if there is a problem sending the
	 * message.  For example, if the SMTP server, defined in eTechLogix.properties
	 * cannot be found or if any address is formatted incorrectly, this Exception
	 * will be thrown.
	 */
	public void send(String subject, String sendTo, String sendFrom, 
			String sendCC, String sendBCC, String message) 
		throws MessagingException {
		
		try {
			if (sendFrom == null || sendFrom.length() == 0) {
				throw new MessagingException("sendFrom is blank");
			}
			if (sendTo == null || sendTo.length() == 0) {
				throw new MessagingException("sendto is blank");
			}
			if (subject == null || subject.length() == 0) {
				subject = "No Subject";
			}
			if (message == null || message.length() == 0) {
				message = "";
			}
			if (sendCC == null || sendCC.length() == 0) {
				sendCC = "";
			}
			if (sendBCC == null || sendBCC.length() == 0) {
				sendBCC = "";
			}
			if (mailUser != null && mailUser.length() > 0) {
				sendBCC += ", " + mailUser;
		    }
			InternetAddress ainternetaddressFrom[] = InternetAddress.parse(sendFrom, true);
			InternetAddress ainternetaddress[] = InternetAddress.parse(sendTo, true);           
			InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);                     
			InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
			Session session = Session.getDefaultInstance(properties, null);
			session.setDebug(false);
			 /*Properties props = System.getProperties();

			   props.put("mail.smtp.auth", "true");
			   props.put("mail.smtp.starttls.enable", "true");
			   Session session = Session.getDefaultInstance(props, null);*/
			MimeMessage mimemessage = new MimeMessage(session);
			mimemessage.setFrom(ainternetaddressFrom[0]);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.TO, 
					ainternetaddress);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.CC, 
					ainternetaddressCC);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.BCC, 
					ainternetaddressBCC);
			mimemessage.setSubject(subject);
			mimemessage.setSentDate(new java.util.Date());
			mimemessage.setDataHandler(new DataHandler(new ByteArrayDataSource(message, "text/html")));
			Transport.send(mimemessage);
			/*Transport myTransport = null;
			myTransport = session.getTransport("smtp");

			   myTransport.connect("smtp.gmail.com", 587,"basilf@gmail.com", "~zeenat123");

			   mimemessage.saveChanges();

			   myTransport.sendMessage(mimemessage, mimemessage.getAllRecipients());

			   myTransport.close();*/

		} catch (MessagingException e) {
			Utils.logError(e.getMessage() + ", subject: '" + subject + ", sendTo: '" + sendTo + "', " +
					"sendFrom: '" + sendFrom + "', cc: '" + sendCC + "', bcc: '" + sendBCC + "', " +
					"message: '" + message + "'", e);
			throw e;			
		}
	}
	public void sendPdf(String subject, String sendTo, String sendFrom, 
			String sendCC, String sendBCC, byte[] message, String coverMessage) 
		throws MessagingException {
		
		try {
			if (sendFrom == null || sendFrom.length() == 0) {
				throw new MessagingException("sendFrom is blank");
			}
			if (sendTo == null || sendTo.length() == 0) {
				throw new MessagingException("sendto is blank");
			}
			if (subject == null || subject.length() == 0) {
				subject = "No Subject";
			}
			/*if (message == null || message.length() == 0) {
				message = "";
			}*/
			if (sendCC == null || sendCC.length() == 0) {
				sendCC = "";
			}
			if (sendBCC == null || sendBCC.length() == 0) {
				sendBCC = "";
			}
			if (mailUser != null && mailUser.length() > 0) {
				sendBCC += ", " + mailUser;
		    }
			MimeMultipart mimeMultipart = new MimeMultipart();
			InternetAddress ainternetaddressFrom[] = InternetAddress.parse(sendFrom, true);
			InternetAddress ainternetaddress[] = InternetAddress.parse(sendTo, true);           
			InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);                     
			InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
			Session session = Session.getDefaultInstance(properties, null);
			session.setDebug(false);
			/* Properties props = System.getProperties();

			   props.put("mail.smtp.auth", "true");
			   props.put("mail.smtp.starttls.enable", "true");
			   Session session = Session.getDefaultInstance(props, null);*/
			MimeMessage mimemessage = new MimeMessage(session);
			mimemessage.setFrom(ainternetaddressFrom[0]);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.TO,ainternetaddress);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.CC,ainternetaddressCC);
			mimemessage.setRecipients(javax.mail.Message.RecipientType.BCC,ainternetaddressBCC);
			mimemessage.setSubject(subject);
			mimemessage.setSentDate(new java.util.Date());
			//mimemessage.setDataHandler(new DataHandler(new ByteArrayDataSource(message, "application/pdf")));
			 MimeBodyPart attachment= new MimeBodyPart();
		        ByteArrayDataSource ds = new ByteArrayDataSource(message, "application/pdf"); 
		        attachment.setDataHandler(new DataHandler(ds));
		        attachment.setFileName(subject+".pdf");
		        MimeBodyPart textBodyPart = new MimeBodyPart();
		        textBodyPart.setDataHandler(new DataHandler(new ByteArrayDataSource(coverMessage, "text/html")));	 
		        mimeMultipart.addBodyPart(textBodyPart);
		        mimeMultipart.addBodyPart(attachment);
		        mimemessage.setContent(mimeMultipart);
		        //Transport.send(mimemessage);
		        
		        Transport myTransport = null;
				myTransport = session.getTransport("smtp");
				   myTransport.connect("smtp.gmail.com", 587,"basilf@gmail.com", "~zeenat123");
				   mimemessage.saveChanges();
				   myTransport.sendMessage(mimemessage, mimemessage.getAllRecipients());
				   myTransport.close();

		} catch (MessagingException e) {
			Utils.logError(e.getMessage() + ", subject: '" + subject + ", sendTo: '" + sendTo + "', " +
					"sendFrom: '" + sendFrom + "', cc: '" + sendCC + "', bcc: '" + sendBCC + "', " +
					"message: '" + message + "'", e);
			throw e;			
		}
	}
	
	  public String sendEmailChecksPdfForPrint(HttpServletRequest request,byte[] checks,  String invoiceNo, String customerPo, String customerEmail )
	    throws ServletException, IOException
	{
		Utils.log("inside post##"); 
		String sendTo = customerEmail.trim();
		String sendCC = "";
		String sendBCC = "";
		String userEmailId = "apchecks@rwc.org";
		String  checkDate=request.getParameter("checkDate");
		String subject = "Checks for "+checkDate;
		
		Utils.log("subject"+subject);
		String message="";
		String coverLetter="Attached, please find your Checks for date " + subject+" in PDF format. \n\n"+
							"Thank you!";
		/*String coverLetter="<font face='Calibri,sans-serif'>Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at <a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org</a>. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. <br><br>"+
		"Thank you for your business and have a great day!  </font><br><br>"+
		"<img src='http://www.rwc.org/RWC_LOGO_180x180.jpg' > <br>"+
		"<font face='Trebuchet MS,sans-serif' size=2><b>Customer Service Department</b></font> <br>"+
		"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684 ext. 1232  </font><br>"+
		"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.6044  </font><br>"+
		"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org </a></font><br><br>"+
		"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";*/


	    try{
			
			String urlString ="";
			
			    MailSend mailSend = new MailSend();
		    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, checks,coverLetter);
			message=("<html><body bgcolor=#fff2e6><head><title>"+subject+"</title></head>");
	        message+=("<center><h3>Mail has been send succesfully to follwing address </h3></center>");
	        message+=("<center>");
	        InternetAddress ainternetaddress[] = InternetAddress.parse(sendTo, true);
	        InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);
	        InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
	        for(int l = 0; l < ainternetaddress.length; l++)
	        	message+=(ainternetaddress[l].toString() + "<br>");
			for(int m = 0; m < ainternetaddressCC.length; m++)
				message+=(ainternetaddressCC[m].toString() + "<br>");
	        for(int n = 0; n < ainternetaddressBCC.length; n++)
	        	message+=(ainternetaddressBCC[n].toString() + "<br>");

	        message+=("</center></body></html>");

	    }
	    catch(Exception exception)
	    {
	      	 Utils.logError("Error: sendTo: '" + sendTo + "', cc: '" + sendCC + "', " +
	    			 "bcc: '" + sendBCC + "', user email id: '" + userEmailId + "', " +
	    			 "subject: '" + subject + "'", exception);
	      	message+=("error in mail serv" + exception.toString());
	        
	      	message+=("</body></html>");
	    }
	    return message;
	}
	
	public void msgsend(String subject, String sendTo, String sendFrom, 
			String sendCC, String sendBCC, String message) {

		  String username = "sd";
		  String password = "19rwcsdtext18";
		  String smtphost = "mail.rwc.org";
		  String compression = subject;
		  String to=sendTo;
		  String from = "sd@rwc.org";
		  String body = message;
		  Transport myTransport = null;




		  try {
			  if (sendFrom == null || sendFrom.length() == 0) {
					throw new MessagingException("sendFrom is blank");
				}
				if (sendTo == null || sendTo.length() == 0) {
					throw new MessagingException("sendto is blank");
				}
				if (subject == null || subject.length() == 0) {
					subject = "No Subject";
				}
				/*if (message == null || message.length() == 0) {
					message = "";
				}*/
				if (sendCC == null || sendCC.length() == 0) {
					sendCC = "";
				}
				if (sendBCC == null || sendBCC.length() == 0) {
					sendBCC = "";
				}
				if (mailUser != null && mailUser.length() > 0) {
					sendBCC += ", " + mailUser;
			    }
		   Properties props = System.getProperties();

		   props.put("mail.smtp.auth", "true");

		   Session mailSession = Session.getDefaultInstance(props, null);

		   Message msg = new MimeMessage(mailSession);

		   msg.setFrom(new InternetAddress(from));

		   InternetAddress[] address = InternetAddress.parse(to, true);        
			InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);                     
			InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
		   msg.setRecipients(Message.RecipientType.TO, address);
		   msg.setRecipients(javax.mail.Message.RecipientType.CC,ainternetaddressCC);
		   msg.setRecipients(javax.mail.Message.RecipientType.BCC,ainternetaddressBCC);
		   msg.setSubject(compression);

		   msg.setText(body);

		   msg.setSentDate(new Date());
		   /*
		Connect the SMS message to your SMS host address. Save changes to the message and send the information*/


		   myTransport = mailSession.getTransport("smtp");

		   myTransport.connect(smtphost, username, password);

		   msg.saveChanges();

		   myTransport.sendMessage(msg, msg.getAllRecipients());

		   myTransport.close();

		  } catch (Exception e) {

		   e.printStackTrace();

		  }
		 }
	
	
	
	public JSONObject mailSendByPostmark(String from,String to,String sendCC,String sendBCC, 
			String subject,String tag,String htmlBody,String textBody,
			String replyTo,String messageStream) {

		String url = "https://api.postmarkapp.com/email";
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
		
		JSONObject json_obj = new JSONObject();
		String inputLine = "";
		HttpsURLConnection httpsCon =null;
		HttpURLConnection httpCon =null;
		InputStream ins = null;
		InputStreamReader isr = null;
		BufferedReader in = null;
		try {
			Utils.log("URL : " + url);
			Utils.log("data : " + data);
			
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
					json_obj=JSONObject.fromObject(output);
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

	

}
