package com.etechlogix.distribution.utils;

import javax.mail.internet.InternetAddress;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.sql.*;
import com.etechlogix.utils.*;

public class MailSer extends HttpServlet {
	HttpSession session=null;
	Connection con=null;
	DistUtils du=null;
	Utils u = null;
	public MailSer() {
    }
    public void doPost(HttpServletRequest httpservletrequest, HttpServletResponse httpservletresponse)
        throws ServletException, IOException
    {
		Utils.log("inside post##");
        session=httpservletrequest.getSession();
        PrintWriter printwriter = httpservletresponse.getWriter();
        httpservletresponse.setContentType("text/html");
		String sendTo = httpservletrequest.getParameter("sendTo").trim();
		String sendCC = httpservletrequest.getParameter("sendCC").trim();
		String sendBCC = httpservletrequest.getParameter("sendBCC").trim();
		String userEmailId = httpservletrequest.getParameter("userEmailId");
		String type=Utils.removeNull(httpservletrequest.getParameter("type"));
		String idFrom=Utils.removeNull(httpservletrequest.getParameter("idFrom"));
		String mod=Utils.removeNull(httpservletrequest.getParameter("mod"));
		String subject = httpservletrequest.getParameter("subject");
        try{
			u=DistUtils.getUtils(session);
			du =DistUtils.getDistUtils(session);

			Vector SendMailVec = (Vector)session.getAttribute("SendMailVec");
			String urlString =httpservletrequest.getParameter("text");
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
			"-->"+
			"<!--"+
			"-->"+
			"</style>";
			urlString +="<table  width=100% border=0 cellspacing=1 cellpadding=0  height=0 align='center'>";
			for(int i=0;i<SendMailVec.size();i++){
				urlString += SendMailVec.get(i);
			}
			urlString +="</table>";
			
		    MailSend mailSend = new MailSend();
		    if(mod.equals("PO")){
		    	String userId=(String)session.getAttribute("userId");
		    	String buyerName=du.getFieldInfo("select upper(firstname ||' '||lastname) from etechuser where userid='"+userId+"'");
		    	String coverLetter="<font face='Calibri,sans-serif'>Please find attached your Purchase Order in PDF format.  If you have any questions regarding product, quantity or pricing, please contact "+buyerName+" at <a href='"+userEmailId+"'>"+userEmailId+"</a>. You may also fax us at 602-258-3163 or call us at 602-252-1684<br><br>"+
		    	httpservletrequest.getParameter("text")+"<br><br>Thank you and have a great day!  </font><br><br>"+
				"<img src='http://www.rwc.org/RWC_LOGO_180x180.jpg' > <br>"+
				"<font face='Trebuchet MS,sans-serif' size=2><b>"+buyerName+"</b></font> <br>"+
				"<font face='Trebuchet MS,sans-serif' size=2>602.252.1684</font><br>"+
				"<font face='Trebuchet MS,sans-serif' size=2>Fax:  602.258.3163  </font><br>"+
				"<font face='Trebuchet MS,sans-serif' size=2><a href='mailto:"+userEmailId+"'>"+userEmailId+" </a></font><br><br>"+
				"<font face='Trebuchet MS,sans-serif' size=2><b><i>Building Products.  Building Relationships.  Building the Future.</font></i></b>";
		    	byte[] faxbytes = (byte[])session.getAttribute( "pdfFile");
		    mailSend.sendPdf(subject, sendTo, userEmailId, 
		    		userEmailId+","+sendCC, sendBCC, faxbytes, coverLetter) ;
		    }
		    else
		    mailSend.send(subject, sendTo, userEmailId, userEmailId+","+sendCC, sendBCC, urlString);
		    du.buildEmailDirectory(idFrom, sendTo, type);
		    if(!sendCC.equals(""))
		    du.buildEmailDirectory(idFrom, sendCC, type);
		    if(!sendBCC.equals(""))
			    du.buildEmailDirectory(idFrom, sendBCC, type);
		    
			printwriter.println("<html><body bgcolor=#fff2e6><head><title>ETechLogix-EMail</title></head>");
            printwriter.println("<center><h3>Mail has been send succesfully to follwing address </h3></center>");
            printwriter.println("<center>");
            InternetAddress ainternetaddress[] = InternetAddress.parse(sendTo, true);
            InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);
            InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
            for(int l = 0; l < ainternetaddress.length; l++)
                printwriter.println(ainternetaddress[l].toString() + "<br>");
			for(int m = 0; m < ainternetaddressCC.length; m++)
                printwriter.println(ainternetaddressCC[m].toString() + "<br>");
            for(int n = 0; n < ainternetaddressBCC.length; n++)
                printwriter.println(ainternetaddressBCC[n].toString() + "<br>");

            printwriter.println("</center></body></html>");

        }
        catch(Exception exception)
        {
          	 Utils.logError("Error: sendTo: '" + sendTo + "', cc: '" + sendCC + "', " +
        			 "bcc: '" + sendBCC + "', user email id: '" + userEmailId + "', " +
        			 "subject: '" + subject + "'", exception);
            printwriter.println("error in mail serv" + exception.toString());
            exception.printStackTrace(printwriter);
            printwriter.println("</body></html>");
        }
    }

    public void init(ServletConfig servletconfig)
        throws ServletException
    {
        super.init(servletconfig);
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


}
