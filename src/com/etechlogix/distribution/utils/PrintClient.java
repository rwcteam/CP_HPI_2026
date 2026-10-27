package com.etechlogix.distribution.utils;

/**
 * Title:        RWC
 * Description:  Print PrintClient
 *
 *
 *
 * Copyright:    Copyright (c) 2001
 * Company:      etechLogix
 * @author Azam
 * @version 1.0
 */
import java.net.*;
import java.io.*;
import com.etechlogix.utils.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.etechlogix.distribution.utils.DistUtils;

public class PrintClient {
  private Properties SystemDefaults;
  public PrintClient()  throws Exception {
	  FileInputStream in = null;
	  try {
      File file = new File("eTechLogix.properties");
      in = new FileInputStream(file);
      SystemDefaults = new Properties();
      SystemDefaults.load(in);
    } catch (Exception e) {
      throw new Exception(e.getMessage()+ "\nCurrent Directory:"+System.getProperty("user.dir"));
    } finally {
    	if(in!=null) in.close();
    }
  }
  public String sendReportToPrinter(Vector report, String printer, String address, String orientation, String header,String companyId,String fileName,String a){
  String printerType="";
  String printerName="";
  String messageCode="";
  String paperSize="";
  String fName[]={""};
  boolean bTicketPrint=false;
    try{
    fName[0]="PrintPickTicket.jsp";
    fName[1]="PrintStagingTicket.jsp";
    fName[2]="PrintTransferPickTicket.jsp";
    fName[3]="PrintTransferStagingTicket.jsp";

    for(int i=0;fName!=null && i<fName.length;i++){
            if(fName[i].trim().equalsIgnoreCase(fileName.trim())){
              bTicketPrint=true;
              break;
            }
    }
    Utils.log("request fileName in printClient==="+fileName);
    Utils.log("bTicketPrint in printClient==="+bTicketPrint);
    Vector v=new Vector(2);
    String query="Select printerType,printerName from printer where printerId='"+printer+"' and companyId='"+companyId+"'";
    v=new DistUtils().getFieldInfo(query,2);
    if(v!=null){
      printerType=Utils.removeNull(v.get(0).toString()).toString();
      printerName=Utils.removeNull(v.get(1).toString()).toString();
    }
    Utils.log("query==="+query);
    StringBuffer bf=new StringBuffer();
    Utils.log("printerType===="+printerType);
    if(printerType.equalsIgnoreCase("D") && bTicketPrint){
      Utils.log("Printing the Report through DotMatrix Printer..........................");
      bf.append("<HTML><head><style type='text/css'>");
      bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 11pt; color:black}");
      bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color: #000000}");
      bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 8pt; font-weight:bold;color:#000000}");
      bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt;  font-weight:bold;color:#000000}");
      bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 8pt; color:#000000}");
      bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 9pt; font-weight:bold; color:#000000}");
      bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 9pt; color:#FFFFFF}");
      bf.append(".border { border: #000000; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
      bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color: #000000}");
      bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
      bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
      bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
      bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color: #000000} .header { font-size: 9pt; font-weight:bold; color:#000000} </style></head><BODY><table border='0.5' cellspacing=1 cellpadding=0>");
      bf.append(header);
    }
    else if(printerType.equalsIgnoreCase("D") && !bTicketPrint){
      Utils.log("Printing the Report through DotMatrix Printer..........................");
      bf.append("<HTML><head><style type='text/css'>");
      bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 12pt; color:black}");
      bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 12pt; color: #000000}");
      bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 12pt; font-weight:bold;color:#000000}");
      bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 12pt;  font-weight:bold;color:#000000}");
      bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 12pt; color:#000000}");
      bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12pt; font-weight:bold; color:#000000}");
      bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 12pt; color:#FFFFFF}");
      bf.append(".border { border: #000000; border-style: solid; border-top-width: .5pt; border-right-width: .12pt; border-bottom-width: .5pt; border-left-width:.5pt}");
      bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 12pt; color: #000000}");
      bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
      bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
      bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 12pt; color: #000000} .header { font-size: 9pt; font-weight:bold; color:#000000} </style></head><BODY><table border='0.5' cellspacing=1 cellpadding=0>");
      bf.append(header);
    }
    else{
      Utils.log("Printing the Report through Laser Printer..........................");
      bf.append("<HTML><head><style type='text/css'>");
      bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
      bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
      bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
      bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
      bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
      bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#FFFF33; background-color: #CC0000}");
      bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
      bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
      bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color: #000000; font-weight:bold}");
      bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
      bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
      bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table width='100%' border='0.5' cellspacing=1 cellpadding=0 >");
      bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
      bf.append(header);
    }


    for(int i=0;i<report.size();i++)
      {
      bf.append(report.get(i));
    }
    bf.append("</table></body></html>");
    messageCode=sendReportToPrinter(bf.toString(),printerName,address,orientation,paperSize);
    }
    catch(Exception e)
        { System.out.println("Error: in Vector 1" +e.getMessage());}

  return messageCode;
    }

  public String sendReportToPrinter(Vector report, String printer, String address, String orientation, String header,String companyId,String fileName){

  Utils.log("#############  Print Client 1 ################ ");
  String printerType="";
  String printerName="";
  String messageCode="";
  String paperSize="";
  String fName[]=new String[6];
  Utils.log("#############  Print Client 2 report vector size ################ "+report.size());
  boolean bTicketPrint=false;
    try{
        fName[0]="PrintPickTicket.jsp";
        fName[1]="PrintStagingTicket.jsp";
        fName[2]="PrintInvoice.jsp";
        fName[3]="D_PORptPrint.jsp";
        fName[4]="PrintTransferPickTicket.jsp";
         fName[5]="PrintTransferStagingTicket.jsp";


        Utils.log("fileName in PrintClient==="+fileName);
        Utils.log("fName.length in PrintClient==="+fName.length);
        for(int i=0;fName!=null && i<fName.length;i++){
        Utils.log("In for loop............................");
                if(fName[i].trim().equalsIgnoreCase(fileName.trim())){
                  bTicketPrint=true;
                  break;
                }
        }

        Utils.log("bTicketPrint==="+bTicketPrint);
            Vector v=new Vector(2);
            String query="Select printerType,printerName from printer where printerId='"+printer+"' and companyId='"+companyId+"'";
            v=new DistUtils().getFieldInfo(query,2);
            if(v!=null){
              printerType=Utils.removeNull(v.get(0).toString()).toString();
              printerName=Utils.removeNull(v.get(1).toString()).toString();
            }
            Utils.log("query==="+query);
            StringBuffer bf=new StringBuffer();
            Utils.log("printerType===="+printerType);
            if(printerType.equalsIgnoreCase("D")){
              Utils.log("Printing the Report through DotMatrix Printer..........................");
              if(bTicketPrint){
                    bf.append("<HTML><head><style type='text/css'>");
                    bf.append(".summary1 { font-family: Courier; text-align:center;font-size: 10pt; color:black}");
                    bf.append(".test { font-family: Courier; text-align:right;font-size: 10pt; color: #000000}");
                    bf.append(".sum { font-family: Courier; text-align:center; font-size: 10pt; color:#000000}");
                    bf.append(".delsum { font-family: Courier; font-size: 10pt;  color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".summary { font-family: Courier; text-align:right;font-size: 10pt; color:#000000}");
                    bf.append(".rHeading { font-family: Courier; text-align:center;font-size: 10pt;  color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".divider { font-family: Courier; text-align:center;font-size: 10pt; color:#FFFFFF}");
                    bf.append(".border { border: #ffffff; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
                    bf.append(".poprintborder {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}");
                    bf.append(".delsumPO   { font-family: Courier; font-size: 10pt;color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".datapoprint { font-family: Courier;font-size: 10pt; color: #000000}");
                    bf.append(".pageHeader{ font-family: Courier; font-size: 7pt; color:black }");
                    bf.append(".dataHeader { font-family: Courier; text-align:center;font-size: 10pt; color: #000000}");
                    bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
                    bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
                    bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
                    bf.append(".data { font-family: Courier; text-align:center;font-size: 10pt; color: #000000} .header { font-size: 10pt;  color:#000000} </style></head><BODY><table border='0.5' cellspacing=1 cellpadding=0>");
                    bf.append(header);
                    paperSize="B";
              }
                else{
                    bf.append("<HTML><head><style type='text/css'>");
                    bf.append(".summary1 { font-family: Courier; text-align:center;font-size: 12pt; color:black}");
                    bf.append(".test { font-family: Courier; text-align:right;font-size: 12pt; color: #000000}");
                    bf.append(".sum { font-family: Courier; text-align:center; font-size: 12pt; color:#000000}");
                    bf.append(".delsum { font-family: Courier; font-size: 12pt;  color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".summary { font-family: Courier; text-align:right;font-size: 12pt; color:#000000}");
                    bf.append(".rHeading { font-family: Courier; text-align:center;font-size: 12pt;  color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".divider { font-family: Courier; text-align:center;font-size: 12pt; color:#FFFFFF}");
                    bf.append(".border { border: #ffffff; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
                    bf.append(".poprintborder {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt}");
                    bf.append(".delsumPO   { font-family: Courier; font-size: 12pt;color:#000000;bordercolor:#000000; border-right-style: solid; bordercolorlight:#000000;border-right-width: thin}");
                    bf.append(".datapoprint { font-family: Courier;font-size: 12pt; color: #000000}");
                    bf.append(".pageHeader{ font-family: Courier; font-size: 12pt; color:black }");
                    bf.append(".dataHeader { font-family: Courier; text-align:center;font-size: 12pt; color: #000000}");
                    bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
                    bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
                    bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
                    bf.append(".data { font-family: Courier; text-align:center;font-size: 12pt; color: #000000} .header { font-size: 10pt;  color:#000000} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0>");
                    
                    bf.append(header);
                    paperSize="C";
                }
              Utils.log("paperSize=========================="+paperSize);
            }
            else{
              Utils.log("Printing the Report through Laser Printer..........................");
              bf.append("<HTML><head><style type='text/css'>");
              bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
              bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
              bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
              bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
              bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
              bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#FFFF33; background-color: #CC0000}");
              bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
              bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
              bf.append(".poprintborder {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt;background-color :#DEDEBC}");
              bf.append(".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}");
              bf.append(".datapoprint { font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 7pt; color: #000000;font-weight:bold}");
              bf.append(".pageHeader{ font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 7pt; color:black; font-weight: bold; background-color: #fff2e6}");
              bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color: #000000; font-weight:bold}");
              bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
              bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
              bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
              bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt;background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0 >");
              
              bf.append(header);
              paperSize="A";
            }


            for(int i=0;i<report.size();i++)
              {
              bf.append(report.get(i));
            }
            bf.append("</table></body></html>");
            messageCode=sendReportToPrinter(bf.toString(),printerName,address,orientation,paperSize);
    }//end of try
    catch(Exception e)
        { System.out.println("Error: in Vector 2" +e.getMessage());}

  return messageCode;
    }

/* send data through string    */
  public String sendReportToPrinter(String printToFile, String printer, String address, String orientation,String paperSize){
    int receive;
    String messageCode="";
    
    try{
      byte buf[]=printToFile.getBytes();
      int noOfBytes=printToFile.length();
      System.out.print("Connecting.......");
      System.out.print("address......."+address);
      String query="Select port from printer where printerId='"+printer+"' ";
      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));
      Socket soc;
     // if(printerType.equalsIgnoreCase("D"))
      //soc=new Socket(address, 2000);
      //else
      soc=new Socket(address, port);
      System.out.println("Connetcted"+ port);
      DataOutputStream os=new DataOutputStream(soc.getOutputStream());
      os.writeBytes("'"+noOfBytes + "'~" + printer +"~" + orientation + "~" + paperSize + "~" + printToFile);
      os.flush();
      System.out.println("send Bytes " + noOfBytes);
      System.out.println("send Bytes printer " + printer);
      System.out.println("send Bytes paperSize" + paperSize);
      //System.out.println("send Bytes printToFile" + printToFile);


   // read mesage from server
      DataInputStream is=new DataInputStream(soc.getInputStream());
      StringBuffer confirm=new StringBuffer();
      if(noOfBytes!=0){
      while((receive=is.read())!=-1){
      confirm.append((char)receive);
      System.out.print((char)receive);
      }
      }
      messageCode=confirm.toString();
      System.out.println("Confirmation note : " +messageCode);
      soc.close();
      }
    catch(UnknownHostException ue)
      {System.out.println("Can't resolve Host " +ue.getMessage());}

    catch(IOException ie)
      {System.out.println("Error: Connection Refuse " +ie);}

    catch(Exception e)
        {System.out.println("Error: " +e.getMessage());}

  return messageCode;
  }

  public String sendReportToPrinter(String printToFile, String printer, String address, String orientation,String paperSize,String reportType){
    int receive;
    String messageCode="";
    try{
      byte buf[]=printToFile.getBytes();
      int noOfBytes=printToFile.length();
      Utils.log("Connecting......." + printToFile);
      Utils.log("address......."+address);
      String query="Select port from printer where printerId='"+printer+"' ";
      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));
      Socket soc;
     // if(printerType.equalsIgnoreCase("D"))
      //soc=new Socket(address, 2000);
      //else
      soc=new Socket(address, port);
      System.out.println("Connetcted"+ port);
      DataOutputStream os=new DataOutputStream(soc.getOutputStream());
      os.writeBytes("'"+noOfBytes + "'~" + printer +"~" + orientation + "~" + paperSize + "~" + reportType + "~" + printToFile);
      os.flush();
     Utils.log("send Bytes " + noOfBytes);
     Utils.log("send Bytes printer " + printer);
     Utils.log("send Bytes paperSize" + paperSize);
      //System.out.println("send Bytes printToFile" + printToFile);


   // read mesage from server
      DataInputStream is=new DataInputStream(soc.getInputStream());
      StringBuffer confirm=new StringBuffer();
      if(noOfBytes!=0){
      while((receive=is.read())!=-1){
      confirm.append((char)receive);
      System.out.print((char)receive);
      }
      
      messageCode=confirm.toString();
      }
      else
    	  messageCode="No Data Found to Print";
      System.out.println("Confirmation note : " +messageCode);
      soc.close();
      }
    catch(UnknownHostException ue)
      {System.out.println("Can't resolve Host " +ue.getMessage());
      messageCode="Can't resolve Host ";
      }

    catch(IOException ie)
      {System.out.println("Error: Connection Refuse " +ie);
      messageCode="Error: Connection Refuse";
      }

    catch(Exception e)
        {System.out.println("Error: " +e.getMessage());
        messageCode="Error: " +e.getMessage();
        }

  return messageCode;
}

///////////////////////////////////////////////////////////////////////////////////
//For Existing Report The Overloaded Method sendReportToPrinter()
  public String sendReportToPrinter(Vector report, String printer, String address, String orientation, String header){
    Utils.log("Getting Report in Earlier Version of method sendReportToPrinter()");
    String messageCode="";
    try{
    StringBuffer bf=new StringBuffer();
	    bf.append(" ");
	    /*bf.append("<HTML><head><style type='text/css'>");
	    bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
	    bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
	    bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
	    bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
	    bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
	    bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}");
	    bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
	    bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
	    bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0 >");
            */
           bf.append("<HTML><head><style type='text/css'>");
              bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
              bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
              bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
              bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
              bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
              bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#FFFF33; background-color: #CC0000}");
              bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
              bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
              bf.append(".poprintborder {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt;background-color :#DEDEBC}");
              bf.append(".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}");
              bf.append(".datapoprint { font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 7pt; color: #000000;font-weight:bold}");
              bf.append(".pageHeader{ font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 7pt; color:black; font-weight: bold; background-color: #fff2e6}");
              bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color: #000000; font-weight:bold}");
              bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
              bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
              bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
              bf.append(".dataH { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:left;font-size: 7pt;background-color: FFF2E6; color: #000000} ");
              bf.append(".summaryH { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:left;font-size: 7pt; color:black; background-color: #ffcc66}");
              bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt;background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0 >");
              
              bf.append(header);
	      for(int i=0;i<report.size();i++)
	      {
	      bf.append(report.get(i));
	      }
	    bf.append("</table></body><html>");

    messageCode=sendReportToPrinter(bf.toString(),printer,address,orientation,"A","L");

    }
    catch(Exception e)
        { System.out.println("Error: in Vector " +e.getMessage());}

  return messageCode;
  }

  
  public String sendReportToPrinterPdf(Vector report, String printer, String address, String orientation, String header){
	    Utils.log("Getting Report in Earlier Version of method sendReportToPrinter()");
	    String messageCode="";
	    try{
	    StringBuffer bf=new StringBuffer();
		    bf.append(" ");
		    /*bf.append("<HTML><head><style type='text/css'>");
		    bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
		    bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
		    bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
		    bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
		    bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
		    bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}");
		    bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
		    bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
		    bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0 >");
	            */
	           bf.append("<HTML><head><style type='text/css'>");
	              bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
	              bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
	              bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
	              bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
	              bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
	              bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold; color:#FFFF33; background-color: #CC0000}");
	              bf.append(".divider { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 8pt; color:#FFFFFF; background-color: #0000FF}");
	              bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
	              bf.append(".poprintborder {  border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width: .5pt;background-color :#DEDEBC}");
	              bf.append(".delsumPO { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; font-weight:bold;color:#000000; background-color: #C9C98F}");
	              bf.append(".datapoprint { font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 7pt; color: #000000;font-weight:bold}");
	              bf.append(".pageHeader{ font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 7pt; color:black; font-weight: bold; background-color: #fff2e6}");
	              bf.append(".dataHeader { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color: #000000; font-weight:bold}");
	              bf.append(".datasmall { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 3pt; color: #000000}");
	              bf.append(".dataLarge4 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 32pt; color: #000000; font-weight:bold}");
	              bf.append(".dataLarge3 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 24pt; color: #000000; font-weight:bold}");
	              bf.append(".dataH { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:left;font-size: 7pt;background-color: FFF2E6; color: #000000} ");
	              bf.append(".summaryH { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:left;font-size: 7pt; color:black; background-color: #ffcc66}");
	              bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt;background-color: FFF2E6; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table border='0.5' width='100%' cellspacing=1 cellpadding=0 >");
	              
	              bf.append(header);
		      for(int i=0;i<report.size();i++)
		      {
		      bf.append(report.get(i));
		      }
		    bf.append("</table></body><html>");

	    messageCode=sendReportToPrinterPdf(report,printer,address,orientation,"A","L");

	    }
	    catch(Exception e)
	        { System.out.println("Error: in Vector " +e.getMessage());}

	  return messageCode;
	  }
  
  public String sendReportToPrinterPdf(Vector printToFile, String printer, String address, String orientation,String paperSize,String reportType){
	    int receive;
	    String messageCode="";
	    try{
	      byte buf[]=(byte []) printToFile.get(0);
	      int noOfBytes=printToFile.size();
	      Utils.log("Connecting......." + printToFile);
	      Utils.log("address......."+address);
	      String query="Select port from printer where printerId='"+printer+"' ";
	      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));
	      Socket soc;
	     // if(printerType.equalsIgnoreCase("D"))
	      //soc=new Socket(address, 2000);
	      //else
	      soc=new Socket(address, port);
	      System.out.println("Connetcted"+ port);
	      DataOutputStream os=new DataOutputStream(soc.getOutputStream());
	      os.writeBytes("'"+noOfBytes + "'~" + printer +"~" + orientation + "~" + paperSize + "~" + reportType + "~" + printToFile);
	     // os.write(buf);
	      os.flush();
	     Utils.log("send Bytes " + noOfBytes);
	     Utils.log("send Bytes printer " + printer);
	     Utils.log("send Bytes paperSize" + paperSize);
	      //System.out.println("send Bytes printToFile" + printToFile);


	   // read mesage from server
	      DataInputStream is=new DataInputStream(soc.getInputStream());
	      StringBuffer confirm=new StringBuffer();
	      if(noOfBytes!=0){
	      while((receive=is.read())!=-1){
	      confirm.append((char)receive);
	      System.out.print((char)receive);
	      }
	      
	      messageCode=confirm.toString();
	      }
	      else
	    	  messageCode="No Data Found to Print";
	      System.out.println("Confirmation note : " +messageCode);
	      soc.close();
	      }
	    catch(UnknownHostException ue)
	      {System.out.println("Can't resolve Host " +ue.getMessage());
	      messageCode="Can't resolve Host ";
	      }

	    catch(IOException ie)
	      {System.out.println("Error: Connection Refuse " +ie);
	      messageCode="Error: Connection Refuse";
	      }

	    catch(Exception e)
	        {System.out.println("Error: " +e.getMessage());
	        messageCode="Error: " +e.getMessage();
	        }

	  return messageCode;
	}

/* send data through string    */
  
  
  public String sendpdfReportToPrinterPdf(HttpServletRequest httpservletrequest,byte[] printToFile, String printer, String address, String orientation,String fileType,String userId,String documentNo,boolean flag) throws Exception{
		String messageCode = "";
		int receive;
		Socket soc = null;
		DataOutputStream os = null;
		DataInputStream is = null;
		String result="";

		try {
			int noOfBytes = printToFile.length;
			Utils.log("printToFile......." + printToFile);
			Utils.log("address......." + address);
			String query="Select port from printer where printerId='"+printer+"' ";
		      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));

			Utils.log("port>>11>> " + port);
			soc = new Socket(address, port);

			String encodedBase64 = com.lowagie.text.pdf.codec.Base64.encodeBytes(printToFile);

			String completeDate = encodedBase64;

			byte[] comData = completeDate.getBytes();
			String fileSize="";
			if(flag){
				 fileSize="data-size:" + comData.length+"|PrinterName:"+printer+"|FileType:"+fileType+"|UserId:"+userId+"|DocumentNo:"+documentNo+"|NoOfCopies:1";
			}else{
				 fileSize="data-size:" + comData.length+"|PrinterName:"+printer+"|FileType:"+fileType+"|UserId:"+userId+"|DocumentNo:"+documentNo+"|NoOfCopies:1";
			}
			
			Utils.log("fileSize>>>>" + fileSize);
			byte[] dataSize = fileSize.getBytes();

			os = new DataOutputStream(soc.getOutputStream());
			os.write(dataSize);

			os.flush();
			Utils.log("send Bytes " + noOfBytes);
			Utils.log("send Bytes printer " + printer);
			
			is = new DataInputStream(soc.getInputStream());
			StringBuffer confirm = new StringBuffer();
			if (noOfBytes != 0) {
				if ((receive = is.read()) != -1) {
					confirm.append((char) receive);
					Utils.log(">>1>>>"+(char) receive);

				}
				Utils.log("confirm ------- " + confirm);
				if (confirm.toString().trim().equals("1")) {

					os.write(comData);
					os.flush();
					Utils.log("send Bytes>>111>>> " + noOfBytes);
					Utils.log("send Bytes printer " + printer);
					
					receive = -1;

					confirm = new StringBuffer();
					if (noOfBytes != 0) {
						while ((receive = is.read()) != -1) {
							confirm.append((char) receive);
							Utils.log("++2>>>>"+(char) receive);
						}

						messageCode = confirm.toString();
					}
					
				

				}else {
					while ((receive = is.read()) != -1) {
						confirm.append((char) receive);
						Utils.log("asdasd>>>3>>>"+(char) receive);
					}
				}

				messageCode = confirm.toString();
				receive = -1;

				/*confirm = new StringBuffer();
				if (noOfBytes != 0) {
					while ((receive = is.read()) != -1) {
						confirm.append((char) receive);
						System.out.print((char) receive);
					}

					messageCode = confirm.toString();
				}*/

			}

			Utils.log("messageCode>>>dfgdgd>>>>"+ messageCode.trim());
		
			
			char c = messageCode.trim().charAt(0);
			if(c=='F'){
				result="1";
				Utils.log("result>>>>>222>>>"+ result);
			}else{
				result=messageCode.trim();
			}
			   Utils.log("result>>>>>>>>"+ result);
		}

		catch (UnknownHostException ue) {
			Utils.log("messageCode>>>>>>>1>>>>" + ue.getMessage());
			messageCode = "Can't resolve Host ";
		}

		/*catch (IOException ie) {
			Utils.log("messageCode>>>>>2>>>>>>" + ie.getMessage());
			messageCode = "Error: Connection Refuse";
		}

		catch (Exception e) {
			Utils.log("messageCode>>>>>>3>>>>>" + e.getMessage());
			messageCode = "Error: " + e.getMessage();
		}*/ finally {
			try {
				if (soc != null)
					soc.close();
				if (os != null)
					os.close();
				if (is != null)
					is.close();
			} catch (Exception e2) {
			}
		}

		Utils.log("messageCode>>>>>>>4>>>>" + messageCode);
		return result;
	}

  

/*public static byte[] serializ(FileRequestResponse obj) throws IOException, ClassNotFoundException {
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    ObjectOutputStream os = new ObjectOutputStream(out);
    os.writeObject(obj);
   // Utils.log("out.toByteArray()>>>>>"+ out.toByteArray());
   // FileRequestResponse obghf= (FileRequestResponse) deserialize(out.toByteArray());
  //  Utils.log("obghf>>>>>"+ obghf.getFileName());
    
    try{
    byte[] yourBytes = out.toByteArray();
    byte [] newByte = null;
    Utils.log("out.toByteArray()>>>>>>>"+ yourBytes.length);
    StringBuilder strBu= new StringBuilder();
    for(int i=0; i< yourBytes.length;i++){
    	
    	int abc;
    	if(yourBytes[i] < 0){  
    		abc= (yourBytes[i]+256);
    	}else{
    		abc=yourBytes[i];
    	}
    	newByte[i]=(byte) abc;
    	strBu.append(newByte[i]+ " ");
    }

    Utils.log("strBu>>>>>>>"+ strBu);
    //Utils.log("Byte>>>>>"+strBu);
  //  String encodedBase64 = new String(com.lowagie.text.pdf.codec.Base64.encodeBytes(out.toByteArray())); 
    }catch(Exception e){
    	Utils.log("error>>>>>>>"+ e.getMessage());
    }
    return out.toByteArray();
}*/


/*public static Object deserialize(byte[] data) throws IOException, ClassNotFoundException {
    ByteArrayInputStream in = new ByteArrayInputStream(data);
    ObjectInputStream is = new ObjectInputStream(in);
    return is.readObject();
}*/
  
  public String sendReportToPrinter(String printToFile, String printer, String address, String orientation){
    Utils.log("Printing Report in Earlier Version of method sendReportToPrinter()");
    int receive;
    String messageCode="";
    try{
      byte buf[]=printToFile.getBytes();
      int noOfBytes=printToFile.length();
      System.out.print("Connecting.......");
      System.out.print("address......."+address);
      String query="Select port from printer where printerId='"+printer+"' ";
      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));
      Socket soc;
     // if(printerType.equalsIgnoreCase("D"))
      //soc=new Socket(address, 2000);
      //else
      soc=new Socket(address, port);
      System.out.println("Connetcted"+ port);
      DataOutputStream os=new DataOutputStream(soc.getOutputStream());
      os.writeBytes("'"+noOfBytes + "'~" + printer +"~" + orientation + "~" + printToFile);
      System.out.println("send Bytes " + noOfBytes);

   // read mesage from server
      DataInputStream is=new DataInputStream(soc.getInputStream());
      StringBuffer confirm=new StringBuffer();
      if(noOfBytes!=0){
      while((receive=is.read())!=-1){
      confirm.append((char)receive);
      System.out.print((char)receive);
      }
      }
      messageCode=confirm.toString();
      System.out.println("Confirmation note : " +messageCode);
      soc.close();
      }
    catch(UnknownHostException ue)
      {System.out.println("Can't resolve Host " +ue.getMessage());}

    catch(IOException ie)
      {System.out.println("Error: Connection Refuse " +ie);}

    catch(Exception e)
        {System.out.println("Error: " +e.getMessage());}

  return messageCode;
  }


  public String sendEmailPdfForPrint(HttpServletRequest httpservletrequest,byte[] invoice,  String invoiceNo, String customerPo, String customerEmail )
		    throws ServletException, IOException
		{
			Utils.log("inside post##");
		    HttpSession session = httpservletrequest.getSession();      
			String sendTo = customerEmail.trim();
			String sendCC = "";
			String sendBCC = "";
			String userEmailId = "rwcinvoices@rwc.org";
			String subject = "PickTicket for "+invoiceNo;
			String message="";
			String coverLetter="Attached, please find your " + subject+" in PDF format. \n\n"+
								"Thank you!";
			 Utils.log("b>>invoice>>>>>>"+invoice);
		
			
		    try{
				Utils u = DistUtils.getUtils(session);
				DistUtils du = DistUtils.getDistUtils(session);

				String urlString ="";
				Utils.log("invoice>>>>>>"+invoice);
				    MailSend mailSend = new MailSend();
			    mailSend.sendPdf(subject, sendTo, userEmailId, sendCC, sendBCC, invoice,coverLetter);
				message="1";
		        
		       /* InternetAddress ainternetaddress[] = InternetAddress.parse(sendTo, true);
		        InternetAddress ainternetaddressCC[] = InternetAddress.parse(sendCC, true);
		        InternetAddress ainternetaddressBCC[] = InternetAddress.parse(sendBCC, true);
		  */

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

			
  public void sendBytes(byte[] myByteArray, int start, int len, Socket socket) throws IOException {
	    if (len < 0)
	        throw new IllegalArgumentException("Negative length not allowed");
	    if (start < 0 || start >= myByteArray.length)
	        throw new IndexOutOfBoundsException("Out of bounds: " + start);
	    // Other checks if needed.

	    // May be better to save the streams in the support class;
	    // just like the socket variable.
	    OutputStream out = socket.getOutputStream(); 
	    DataOutputStream dos = new DataOutputStream(out);

	    dos.writeInt(len);
	    if (len > 0) {
	        dos.write(myByteArray, start, len);
	    }
	}



}
