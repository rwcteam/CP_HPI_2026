package com.etechlogix.distribution.utils;

import javax.servlet.http.*;
import java.util.*;
import com.etechlogix.utils.*;

public class MailForReceipt  {
  HttpSession session=null;
  DistUtils du=null;
  Utils u = null;

 public MailForReceipt() { }


 public void sendReceiptMail(HttpServletRequest request, HttpServletResponse response,String sendTo,String userEmailId,String subject,Vector SendMailVec)
        throws Exception
    {
	Utils.log("inside post## 11111");
    String cc = "";
    String bcc = "";
        session=request.getSession();
        response.setContentType("text/html");
        try{
            u=DistUtils.getUtils(session);
            du =DistUtils.getDistUtils(session);

            String urlString ="";
            urlString+="<style type='text/css'>"+
            "<!--"+
            ".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}"+
            ".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}"+
            ".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}"+
            ".data{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #fff2e6}"+
            ".data1{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffff}"+
            ".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}"+
            ".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffcc66}"+
            ".border {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}"+
            ".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}"+
            ".invdorder {  border-color: #004646 black black; border: #3A7474; border-style: solid; border-top-width: 0.5pt; border-right-width: 0.5pt; border-bottom-width: 0.5pt; border-left-width: 0.5pt}"+
            ".rHeadingPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight: bold;color:#000000; background-color: #C9C98F}"+
            ".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}"+
            ".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}"+
            "-->"+
            "<!--"+
            "-->"+
            "</style>";
            urlString +="<table  width=99% border=0 cellspacing=1 cellpadding=0 bgcolor=#FFB7B7 height=0 align='center'>";
            Utils.log("inside post SendMailVec.size() ##"+SendMailVec.size());
            for(int i=0;i<SendMailVec.size();i++){
                    urlString += SendMailVec.get(i);
            }
            urlString +="</table>";
            MailSend mailSend = new MailSend();
            mailSend.send(subject, sendTo, userEmailId, cc, bcc, urlString);
        }
        catch(Exception exception)
        {
       	 Utils.logError("Error: sendTo: '" + sendTo + "', cc: '" + cc + "', " +
    			 "bcc: '" + bcc + "', user email id: '" + userEmailId + "', " +
    			 "subject: '" + subject + "'", exception);
            throw new Exception("Could not connect to SMTP host: "+u.getSMTPServer());
        }
    }
  
 public void sendReceiptMail(HttpServletRequest request, HttpServletResponse response,String sendTo,String cc, String bcc,String userEmailId,String subject,Vector SendMailVec)
 throws Exception
{
Utils.log("inside post## 11111");
 session=request.getSession();
 response.setContentType("text/html");
 try{
     u=DistUtils.getUtils(session);
     du =DistUtils.getDistUtils(session);

     String urlString =Utils.removeNull(request.getParameter("text")).trim();
     urlString+="<style type='text/css'>"+
     "<!--"+
     ".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}"+
     ".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}"+
     ".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}"+
     ".data{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #fff2e6}"+
     ".data1{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffff}"+
     ".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}"+
     ".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffcc66}"+
     ".border {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}"+
     ".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}"+
     ".invdorder {  border-color: #004646 black black; border: #3A7474; border-style: solid; border-top-width: 0.5pt; border-right-width: 0.5pt; border-bottom-width: 0.5pt; border-left-width: 0.5pt}"+
     ".rHeadingPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight: bold;color:#000000; background-color: #C9C98F}"+
     ".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}"+
     ".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}"+
     "-->"+
     "<!--"+
     "-->"+
     "</style>";
     urlString +="<table  width=99% border=0 cellspacing=1 cellpadding=0 bgcolor=#FFB7B7 height=0 align='center'>";
     Utils.log("inside post SendMailVec.size() ##"+SendMailVec.size());
     for(int i=0;i<SendMailVec.size();i++){
             urlString += SendMailVec.get(i);
     }
     urlString +="</table>";

     MailSend mailSend = new MailSend();
     mailSend.send(subject, sendTo, userEmailId, cc, bcc, urlString);
     
 }
 catch(Exception exception)
 {
	 Utils.logError("Error: sendTo: '" + sendTo + "', cc: '" + cc + "', " +
			 "bcc: '" + bcc + "', user email id: '" + userEmailId + "', " +
			 "subject: '" + subject + "'", exception);
	 throw new Exception("Could not connect to SMTP host: "+u.getSMTPServer());
 }
}
 public void sendReceiptMail(String sendTo,String cc, String bcc,String userEmailId,String subject,Vector SendMailVec)
 throws Exception
{
Utils.log("inside post## 11111");

 try{
       String urlString="<style type='text/css'>"+
     "<!--"+
     ".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}"+
     ".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}"+
     ".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}"+
     ".data{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #fff2e6}"+
     ".data1{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffff}"+
     ".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}"+
     ".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #ffcc66}"+
     ".border {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}"+
     ".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}"+
     ".invdorder {  border-color: #004646 black black; border: #3A7474; border-style: solid; border-top-width: 0.5pt; border-right-width: 0.5pt; border-bottom-width: 0.5pt; border-left-width: 0.5pt}"+
     ".rHeadingPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight: bold;color:#000000; background-color: #C9C98F}"+
     ".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}"+
     ".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}"+
     "-->"+
     "<!--"+
     "-->"+
     "</style>";
     urlString +="<table  width=99% border=0 cellspacing=1 cellpadding=0 bgcolor=#FFB7B7 height=0 align='center'>";
     Utils.log("inside post SendMailVec.size() ##"+SendMailVec.size());
     for(int i=0;i<SendMailVec.size();i++){
             urlString += SendMailVec.get(i);
     }
     urlString +="</table>";

     MailSend mailSend = new MailSend();
     mailSend.send(subject, sendTo, userEmailId, cc, bcc, urlString);
     
 }
 catch(Exception exception)
 {
	 Utils.logError("Error: sendTo: '" + sendTo + "', cc: '" + cc + "', " +
			 "bcc: '" + bcc + "', user email id: '" + userEmailId + "', " +
			 "subject: '" + subject + "'", exception);
	 throw new Exception("Could not connect to SMTP host: "+u.getSMTPServer());
 }
}

}//Main
