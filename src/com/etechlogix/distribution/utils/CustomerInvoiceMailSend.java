
package com.etechlogix.distribution.utils;

import javax.mail.internet.InternetAddress;
import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;
import java.util.*;
import java.sql.*;
import com.etechlogix.utils.*;

public class CustomerInvoiceMailSend  {
	HttpSession session=null;
	Connection con=null;
	DistUtils du=null;
	Utils u = null;
	public CustomerInvoiceMailSend() {
    }
    public String sendEmail(HttpServletRequest httpservletrequest,String invoice,  String invoiceNo, String customerPo, String customerEmail )
        throws ServletException, IOException
    {
		Utils.log("inside post##");
        session=httpservletrequest.getSession();      
		String sendTo = customerEmail.trim();
		String sendCC = "";
		String sendBCC = "rwccustomerservice@rwc.org";
		String userEmailId = "rwccustomerservice@rwc.org";
		String subject = "Invoice# "+invoiceNo+" Customer PO# "+customerPo;
		String message="";
        try{
			u=DistUtils.getUtils(session);
			du =DistUtils.getDistUtils(session);

			String urlString ="";
			urlString+="<style type='text/css'>"+
			"<!--"+
			".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}"+
			".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}"+
			".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}"+
			".data{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: ##F7F7F7}"+
			".data1{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffff}"+
			".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}"+
			".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffcc66}"+
                        ".border {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}"+
                        ".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}"+
			".invdorder {  border-color: #004646 black black; border: #3A7474; border-style: solid; border-top-width: 0.5pt; border-right-width: 0.5pt; border-bottom-width: 0.5pt; border-left-width: 0.5pt}"+
                        ".rHeadingPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight: bold;color:#000000; background-color: #EFEFEF}"+
                        ".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 7pt; font-weight:bold;color:#000000; background-color: #EFEFEF}"+
                        ".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}"+
                        ".emailHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#000000; background-color: #E8E8E8}"+
                        ".emailTop { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#000000; background-color: #FFFFFF}"+
			"-->"+
			"<!--"+
			"-->"+
			"</style>";
			urlString +="<table  width=100% border=0 cellspacing=1 cellpadding=0  height=0 align='center'>";

				urlString += invoice;

			urlString +="</table>";
			
		    MailSend mailSend = new MailSend();
		    mailSend.send(subject, sendTo, userEmailId, sendCC, sendBCC, urlString);
			message=("<html><body bgcolor=#fff2e6><head><title>Email</title></head>");
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

    public String sendEmailPdf(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    throws ServletException, IOException
{
	Utils.log("inside post##");
    session=httpservletrequest.getSession();      
	String sendTo = customerEmail.trim();
	String sendCC = "";
	String sendBCC = "rwccustomerservice@rwc.org";
	String userEmailId = "rwccustomerservice@rwc.org";
	String subject = "RWC Invoice "+invoiceNo;
	String message="";
	/*String coverLetter="Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at rwccustomerservice@rwc.org. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. \n\n"+
						"Thank you for your business and have a great day!  \n\n \n\n"+
						"<img src='https://sd.rwc.org/rwc_logo.jpg' > \n\n"+
						"<b>Customer Service Department</b> \n\n"+
						"602.252.1684 ext. 1232  \n\n"+
						"Fax:  602.258.6044  \n\n"+
						"rwccustomerservice@rwc.org \n\n\n\n\n\n"+
						"<b><i>Building Products.  Building Relationships.  Building the Future.</i></b>";*/
	String coverLetter="<font face='Calibri,sans-serif'>Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at <a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org</a>. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. <br><br>"+
	"Thank you for your business and have a great day!  </font><br><br>"+
	//"<img src='http://letuscode.com/rwc/images/header/181_181_rwclogo.png' > <br><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b>Customer Service Department</b></font> <br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684 ext. 1232  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.6044  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org </a></font><br><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";

    try{
		u=DistUtils.getUtils(session);
		du =DistUtils.getDistUtils(session);

		String urlString ="";
		
		    MailSend mailSend = new MailSend();
	    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
		message=("<html><body bgcolor=#fff2e6><head><title>Email Invoices</title></head>");
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

    public String sendEmailPdfStatementForPrint(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    throws ServletException, IOException
{
	Utils.log("inside post##");
    session=httpservletrequest.getSession();      
	String sendTo = customerEmail.trim();
	//String sendTo = "devteam@rwc.org"; //for testing
	//String sendTo = "shadab@rwc.org"; //for testing
	String sendCC = "";
	String sendBCC = "";
	String userEmailId = "rwccustomerservice@rwc.org";
	String subject = "Statement for "+customerPo;
	String message="";
	/*String coverLetter="Attached, please find your " + subject+" in PDF format. <br>"
						+ "If you have any questions please contact our Customer Service Department at rwccustomerservice@rwc.org. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232.<br><br>"
						+ "Thank you for your business and have a great day!<br><br>"
						+ "<b>Customer Service Department</b><br>"
						+ "602.252.1684 ext. 1232<br>"
						+ "Fax: 602.258.6044<br>"
						+ "rwccustomerservice@rwc.org<br><br>"
						+ "<b><i>Building Products. Building Relationships. Building the Future.</i></b><br>";*/
	String coverLetter="<font face='Calibri,sans-serif'>Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at <a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org</a>. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. <br><br>"+
			"Thank you for your business and have a great day!  </font><br><br>"+
			//"<img src='http://letuscode.com/rwc/images/header/181_181_rwclogo.png' > <br><br>"+
			"<font face='Trebuchet MS,sans-serif' size=2><b>Customer Service Department</b></font> <br>"+
			"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684 ext. 1232  </font><br>"+
			"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.6044  </font><br>"+
			"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org </a></font><br><br>"+
			"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";
    try{
		u=DistUtils.getUtils(session);
		du =DistUtils.getDistUtils(session);

		String urlString ="";
		
		    MailSend mailSend = new MailSend();
	    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
		message=("<html><body bgcolor=#fff2e6><head><title>Email Statements</title></head>");
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

    public String sendEmailPdfStatementForCustomers(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    throws ServletException, IOException
{
	Utils.log("inside post##");
    session=httpservletrequest.getSession();      
	String sendTo = customerEmail.trim();
	String sendCC = "";
	String sendBCC = "rwccustomerservice@rwc.org";
	String userEmailId = "rwcinvoices@rwc.org";
	String subject = "Statement for "+customerPo;
	String message="";
	String coverLetter="Attached, please find your " + subject+" in PDF format. \n\n"+
						"Thank you!";
    try{
		u=DistUtils.getUtils(session);
		du =DistUtils.getDistUtils(session);

		String urlString ="";
		
		    MailSend mailSend = new MailSend();
	    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
		message=("<html><body bgcolor=#fff2e6><head><title>Email Statements</title></head>");
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
    
    public JSONObject sendEmailPdfStatementForCustomersJson(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    	    throws ServletException, IOException
    	{
    		Utils.log("inside post## email " + customerEmail);
    	    session=httpservletrequest.getSession();      
    	    String sendTo = customerEmail.trim();
    		String sendCC = "";
    		String sendBCC = "rwccustomerservice@rwc.org";
    		String userEmailId = "rwcinvoices@rwc.org";
    		String subject = "Statement for "+customerPo;
    		String message="";
    		String error="";
    		JSONObject jsonObject = new JSONObject();
    		String coverLetter="Attached, please find your " + subject+" in PDF format. \n\n"+
    							"Thank you!";
    	    try{
    			u=DistUtils.getUtils(session);
    			du =DistUtils.getDistUtils(session);

    			String urlString ="";
    			
    			    MailSend mailSend = new MailSend();
    		    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
    			message=("<html><body bgcolor=#fff2e6><head><title>Email Statements</title></head>");
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
    	      	StringWriter sw = new StringWriter();
    	      	exception.printStackTrace(new PrintWriter(sw));
    	      	error = sw.toString();
    	    }
    	    try {
				jsonObject.put("message", message);
				jsonObject.put("error", error.length() < 3500 ? error : error.substring(0, 3450));
			} catch (JSONException e) {
				Utils.log("Json Error",e);
			}
    	    
    	    return jsonObject;
    	}
    	    
    	public void insertErrorLog(HttpServletRequest request, String param1, String errmsg) throws Exception {
    		HttpSession session = request.getSession(false);
    		du = DistUtils.getDistUtils(session);
    		u = DistUtils.getUtils(session);
    		Statement smt = null;
    		String message = "";
    		try {
    			con = du.getDataConnection();
    			smt = con.createStatement();
    			String insertQuery = "insert into errorlog (param1, errormsg, errdate) values ('" + param1 + "', '" + errmsg + "', sysdate)";
    			smt.executeUpdate(insertQuery);
    		}catch (Exception e) {
    			message = e.getMessage();
    			Utils.log("Event process", e);
    		}
    		finally {
    			Utils.close(smt);
    			if (con != null) {
    				con.close();
    			}
    			Utils.close(smt);
    		}
    	}
    
    public String sendEmailPdfForPrint(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    throws ServletException, IOException
{
	Utils.log("inside post##");
    session=httpservletrequest.getSession();      
	String sendTo = customerEmail.trim();
	String sendCC = "";
	String sendBCC = "";
	String userEmailId = "rwcinvoices@rwc.org";
	String sInvoiceNo=Utils.removeNull(httpservletrequest.getParameter("invoiceNo")).trim();	
	String subject = "Invoices for "+invoiceNo;
	if(!sInvoiceNo.equals(""))
		subject="RWC Invoice# "+sInvoiceNo;
	Utils.log("subject"+subject);
	String message="";
	/*String coverLetter="Attached, please find your " + subject+" in PDF format. \n\n"+
						"Thank you!";*/
	String coverLetter="<font face='Calibri,sans-serif'>Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at <a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org</a>. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. <br><br>"+
	"Thank you for your business and have a great day!  </font><br><br>"+
	"<img src='http://www.rwc.org/RWC_LOGO_180x180.jpg' > <br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b>Customer Service Department</b></font> <br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684 ext. 1232  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.6044  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org </a></font><br><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";


    try{
		u=DistUtils.getUtils(session);
		du =DistUtils.getDistUtils(session);

		String urlString ="";
		
		    MailSend mailSend = new MailSend();
	    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
		message=("<html><body bgcolor=#fff2e6><head><title>Email Invoices</title></head>");
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


    public StringBuffer remLink(String s)
    {
        int i = 0;
        try
        {
            while(i != -1)
            {
                i = s.indexOf("<a");
                int j = s.indexOf("</a");
                String s1 = s.substring(0, i);
                String s2 = s.substring(j + 4);
                s = s1 + "" + s2;
            }
        }
        catch(Exception _ex) { }
        return new StringBuffer(s);
    }
    public String sendEmailPdfCash(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
    throws ServletException, IOException
{
	Utils.log("inside post##");
    session=httpservletrequest.getSession();      
	String sendTo = customerEmail.trim();
	String sendCC = "";
	String sendBCC = "";
	String userEmailId = "rwcinvoices@rwc.org";
	String subject = invoiceNo;
	String message="";
	/*String coverLetter="Attached, please find your " + subject+" in PDF format. \n\n"+
						"Thank you!";*/
	String coverLetter="<font face='Calibri,sans-serif'>Please find attached your electronic invoices in PDF format.  If you have any questions regarding quality, quantity or pricing, please contact our Customer Service Department at <a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org</a>. You may also fax us at 602-258-6044 or call us at 602-252-1684 extension 1232. <br><br>"+
	"Thank you for your business and have a great day!  </font><br><br>"+
	//"<img src='http://letuscode.com/rwc/images/header/181_181_rwclogo.png' > <br><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b>Customer Service Department</b></font> <br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684 ext. 1232  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.6044  </font><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:rwccustomerservice@rwc.org'>rwccustomerservice@rwc.org </a></font><br><br>"+
	"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";
    try{
		u=DistUtils.getUtils(session);
		du =DistUtils.getDistUtils(session);

		String urlString ="";
		
		    MailSend mailSend = new MailSend();
	    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
		message=("<html><body bgcolor=#fff2e6><head><title>Email Invoices</title></head>");
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

    public String sendEmailPdfForFinancial(HttpServletRequest httpservletrequest, String customerEmail, String period, String newPath, String baseUrl )
    	    throws ServletException, IOException
    	{
    		Utils.log("inside post##");
    	    session=httpservletrequest.getSession();      
    		String sendTo = customerEmail.trim();
    		String sendCC = "shadab@rwc.org";
    		String sendBCC = "";
    		String userEmailId = "shadab@rwc.org";
    		String subject = "Financial pdf link for "+period;
    		String message="";
    		StringBuilder links = new StringBuilder();
    		Utils.log("baseUrl>>>>>>"+ baseUrl);
    		links.append("");
    		String completeAddress = baseUrl.concat("/gl/D_GLNGRptBalanceSheetVariancePdfDownload.jsp");
    		String coverLetter="Please find attached your financial PDF link below \n\n <a href='click here: '>"+completeAddress+" </a> \n\n Use this token for download the PDF: "+newPath+"\n\n "+
    				"Thank you!";
    		
    	    try{
    			u=DistUtils.getUtils(session);
    			du =DistUtils.getDistUtils(session);

    			MailSend mailSend = new MailSend();
    			mailSend.msgsend(subject, sendTo, userEmailId, sendCC, sendBCC, coverLetter);
    			message=("<html><body bgcolor=#fff2e6><head><title>Email Statements</title></head>");
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
    	        
    	        Utils.log("successfully sent email");

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

}
