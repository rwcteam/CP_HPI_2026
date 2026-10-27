package com.etechlogix.distribution.utils;

/**
 * Title:        RWC
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:      eTechlogix  System India (P) Ltd
 * @author ashif ali
 * @version 1.0
 * @date 09-Nov-2001
 */

import java.net.*;
import java.io.*;
import com.etechlogix.utils.*;

import java.util.*;


public class PrinterClient {


  public String orientation;
  public String style;
  public String printerId="";
  public String msgCode="";
  private StringBuffer bf;
  private String message="";
  private String address;
  private PrinterInfo printerInfo;
  private String printerName;
  private String printString;

  /**
   *  Constructor
	* */

	 public PrinterClient(PrinterInfo printerInfo)throws Exception{
	  bf=new StringBuffer();
	  this.printerInfo=printerInfo;
	  style="<HTML><head><style type='text/css'>"
		+".top {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 8pt;color:#FFFF33;background-color:'#CC0000'}"
		+".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color:  #FF9933}"
		+".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color:#ffcc99}"
		+".parentHeader { font-size: 8pt; font-weight:bold;text-align:center; color:000000; background-color: #FF8899}"
		+".parentSum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ff8899}"
		+".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}"
		+".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}"
		+".data{ font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #fff2e6}"
		+".header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory}"
	   +"</style></head><BODY>";
	  bf.append(style);

	 }

	 	 public PrinterClient(PrinterInfo printerInfo, String newStyle)throws Exception{
		  bf=new StringBuffer();
		  this.printerInfo=printerInfo;
		  this.style=newStyle;
		  if(style.equals("")){
			 bf.append("<HTML><head><style type='text/css'>");
			 bf.append(".summary1 { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 10pt; color:black; background-color: #ffcc66}");
			 bf.append(".test { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 6pt; color: #000000}");
			 bf.append(".sum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ffcc99}");
			 bf.append(".parentHeader { font-size: 8pt; font-weight:bold;text-align:center; color:000000; background-color: #FF8899}");
			 bf.append(".parentSum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center; font-size: 7pt; font-weight:bold;color:#660000; background-color: #ff8899}");
			 bf.append(".delsum { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:black; background-color: #FF9933}");
			 bf.append(".summary { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right;font-size: 7pt; color:black; background-color: #ffcc66}");
			 bf.append(".rHeading { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color:#FFFF33; background-color: #CC0000}");
			 bf.append(".border { border: #3A7474; border-style: solid; border-top-width: .5pt; border-right-width: .5pt; border-bottom-width: .5pt; border-left-width:.5pt}");
			 bf.append(".data { font-family: Verdana, Arial, Helvetica, sans-serif; text-align:center;font-size: 7pt; color: #000000} .header { font-size: 8pt; font-weight:bold; color:red; background-color: ivory} </style></head><BODY><table width='100%' border='0.5' cellspacing=0 cellpadding=0>");
		  }
		else   bf.append(style);
	 }


	 public void appendToPrintString(Vector report)throws Exception{
		appendToPrintString(report,0,report.size());
	 }

    public void  appendToPrintString(Vector report, int start, int end)throws Exception{
		try{
		  for(int i=0;(i<end || i<report.size());i++){
			 bf.append(report.get(i));
		  }
		}
		catch(Exception e){
		  Utils.log("Error: in PrintClient",e);
		  throw e;
		}
  }


  /* send data through string    */
  public void sendReportToPrinter()throws Exception{
    int receive;
    String messageCode="";
    bf.append("</body></html>");
	 printString=bf.toString();


	 if(printerId.equals(""))throw new Exception("Please set the printer ID");
	 if(orientation.equals(""))throw new Exception("Please set the page orientation");
	 address=printerInfo.getPrinterAddress(printerId);
	 printerName=printerInfo.getPrinterName(printerId);
    try{
      byte buf[]=printString.getBytes();
      int noOfBytes=printString.length();
      System.out.print("Connecting..Printer.....");
      String query="Select port from printer where printerId='"+printerId+"' ";
      int port=Utils.parseInt(new DistUtils().getFieldInfo(query));
      Socket soc;
     // if(printerType.equalsIgnoreCase("D"))
      //soc=new Socket(address, 2000);
      //else
      soc=new Socket(address, port);
      System.out.println("Connetcted"+ port);
      DataOutputStream os=new DataOutputStream(soc.getOutputStream());
      os.writeBytes("'"+noOfBytes + "'~" + printerName +"~" + orientation + "~" + printString);
   // read mesage from server
      DataInputStream is=new DataInputStream(soc.getInputStream());
      StringBuffer confirm=new StringBuffer();
      while((receive=is.read())!=-1){
      confirm.append((char)receive);
      System.out.print((char)receive);
      }
      messageCode=confirm.toString();
      System.out.println("Confirmation note Printer-> " +messageCode);
      soc.close();
		  msgCode=messageCode;
      setMessage(messageCode);

      }
      catch(UnknownHostException ue){
		  Utils.log("PrinterClient->Can not resolve host:",ue);
		  throw ue;
		}

    catch(IOException ie){
		  Utils.log("PrinterClient->:",ie);
		  throw ie;
    }
    catch(Exception e){
		  Utils.log("PrinterClient->:",e);
		  throw e;
    }
  }

  public void setStyle(String newStyle){
	 this.style=newStyle;
  }

  public void appendToPrintString(String str){
    bf.append(str);
  }

  private void setMessage(String messageCode){
	 if(messageCode.equals("0"))message="Printer " + printerId + " is not available";
	 else if(messageCode.equals("1"))message="Reports has been printed successfully on " + printerId;
	 else if(messageCode.equals(""))message="Print server not connected, No Data has been send to printer";
  }


  public String getMessage(){
    return message;

  }
}