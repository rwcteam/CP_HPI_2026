package com.etechlogix.utils;

import java.io.*;
import java.util.*;
import com.etechlogix.distribution.grid.FieldsContainer;
import com.etechlogix.distribution.grid.Field;
import java.sql.SQLException;

/**
 * Title:  arcWin
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Asif Ali
 * @version 1.0
 */

public class ProcessingException extends Exception {
  private String msg;
  Utils u=null;
  private boolean trap;
  private String fileName;
  private String formFieldName;
	private FieldsContainer fic=null;


   //first constructor

  public ProcessingException(Exception e, Utils u) throws Exception{
    trap=false;
		this.u=u;
		if(e instanceof ProcessingException)copyException(e);
		if(!trap)sqlErrorMessage(e);

  }
  public ProcessingException(Exception e, Utils u, FieldsContainer fic) throws Exception{
    trap=false;
		this.u=u;
		this.fic=fic;
		if(e instanceof ProcessingException)copyException(e);
		if(!trap)sqlErrorMessage(e);

  }


//third constructor

 public ProcessingException(String message, String fieldName) throws Exception{
    super(message);
		msg=message;
    formFieldName=fieldName;
 }


  /*
    Trapping the database generated error Error
    @input Exception
    return String
*/

  private void sqlErrorMessage(Exception e)throws Exception{

    String fmessage="";
    formFieldName="";
    if (e instanceof SQLException) {
       SQLException se=(SQLException)e;
        int mess=se.getErrorCode();
        String childKey=u.getChildKey();
        String parentKey=u.getParentKey();
        if(mess==Integer.parseInt(childKey)){
          fmessage=getChildError(se.getMessage());
        }
        else if(mess==Integer.parseInt(parentKey)){
          fmessage=getParentError(se.getMessage());
        }
        else if(mess==Integer.parseInt("20008")){
          fmessage=se.getMessage();
          int indexOra =fmessage.indexOf("uncaught Java exception");
          String mesg="";
          fmessage = fmessage.substring(indexOra+3);
          indexOra =fmessage.indexOf("ORA");
          mesg = fmessage.substring(indexOra+3);
          fmessage = "ERROR: Java Stored Procedure, ORA"+mesg.substring(0,mesg.indexOf("ORA"));

        }
        else{
          fmessage=u.getErrorMessage(Integer.toString(mess));
        }
        if( fmessage==null || fmessage.equals(""))fmessage=se.getMessage();
    }
    else{
      e.printStackTrace(System.out);
      fmessage="Please see error on console: Contact Administrator";
    }

    if(fmessage==null || fmessage.equals("")){
      trap=true;
      fmessage=e.getMessage();
    }
    msg=fmessage;
  }


	/**
	 * This functions will be used  for trapping Form Level Erorr and
	 * RecordNotFoundException
	 *
	 * */

  private void formErrorMessage(Exception e)throws Exception{
    String fmessage="", parameterName="", labelName="";
    String value=e.getMessage();//get the fieldname
    String format="";

    if(value.indexOf("&&")!=-1){
      StringTokenizer split=new StringTokenizer(value, "&&");
      parameterName=split.nextToken();
      format=split.nextToken();
    }
		else{
				parameterName=e.getMessage();
		}

	  formFieldName=parameterName; //setting the for field
		labelName=getLabelName(parameterName);

    if(e instanceof RecordNotFoundException){
      trap=true;
      fmessage=labelName;
    }
    else if(e instanceof InvalidParameterException){
      trap=true;
      fmessage=u.getErrorMessage("INV-PARAM");
      fmessage=u.replaceString("<~KEY~>",labelName,fmessage);
      fmessage=u.replaceString("<~FORMAT~>",format,fmessage);
      }
    else if(e instanceof ParameterNotFoundException){
      trap=true;
      fmessage=u.getErrorMessage("NO-PARAM");
      fmessage=u.replaceString("<~KEY~>",labelName,fmessage);
     }
    else if(e instanceof DataNotFoundException){
      trap=true;
      fmessage=u.getErrorMessage("NO-DATA");
      fmessage=u.replaceString("<~KEY~>",labelName,fmessage);
     }
     if(!fmessage.equals("") && fmessage!=null)
      msg=fmessage;
 }




	/*
    for child and parent record voilation

  */

  private String getParentError(String errorStr)throws Exception{
    String message="";
    String consName="";
    String fieldName="";
    Enumeration enum1=u.getAllErrorCodes();
    Properties errorMessages=u.getErrorMessages();
    String info="";
    while(enum1.hasMoreElements()){
      consName=(String)enum1.nextElement(); //constraint name
      if(errorStr.indexOf(consName)!=-1 && consName.startsWith("FK")){
        info=errorMessages.getProperty(consName); //all information against the constaraitn name in the properties file
        break;
      }
    }
    Enumeration enum2=errorMessages.keys();
    while(enum2.hasMoreElements()){
      String str=(String) enum2.nextElement();
    }

   if (info.equals(""))
    return u.getErrorMessage("PARENT-KEY");
    String MasterTable= consName.substring((consName.indexOf("_")+1));
    StringTokenizer split=new StringTokenizer(info, "&");
    String detailTable="";
    try{
            fieldName=split.nextToken();
            detailTable=split.nextToken();
    }
    catch(Exception e){
      throw new Exception("Please correct Error.Proeprties file for constraint: "+consName);
    }
    fieldName=fieldName.trim();     //seting the formfield name
    formFieldName=fieldName;
    String labelName=getLabelName(fieldName);
    String nmesg="";
    nmesg=u.getErrorMessage("TABLE-ADDUPD");

    nmesg=u.replaceString("<~KEY~>",labelName,nmesg);
    nmesg=u.replaceString("<~TABLENAME~>",detailTable,nmesg);
    return nmesg;
}


  private String getChildError(String errorStr)throws Exception{
    String message="";
    String consName="";
    String fieldName="";
    String info="";
    Enumeration enum1=u.getAllErrorCodes();
    Properties errorMessages=u.getErrorMessages();

    while(enum1.hasMoreElements()){
      consName=(String)enum1.nextElement(); //constraint name
      if(errorStr.indexOf(consName)!=-1 && consName.startsWith("FK")){
        info=(String)errorMessages.get(consName);
        break;
      }
    }

    if (info.equals(""))
      return errorStr;

    String MasterTable= consName.substring((consName.indexOf("_")+1));
    StringTokenizer split=new StringTokenizer(info, "&");
    try{
      fieldName=split.nextToken();
      String detailTable=split.nextToken();
    }
    catch(Exception e){
      throw new Exception("Please correct Error.Proeprties file for constraint: "+consName);
    }

    String nmesg="";
    fieldName=fieldName.trim();     //seting the formfield name
    formFieldName=fieldName;
    String labelName=getLabelName(fieldName);
    nmesg=u.getErrorMessage("TABLE-DEL002");
    nmesg=u.replaceString("<~KEY~>",labelName,nmesg);
    nmesg=u.replaceString("<~TABLENAME~>",MasterTable,nmesg);
    return nmesg;
  }


 //  Return the Error message
 //
  public String getMessage(){
    msg=msg.replace('\n', ' ');
    msg=msg.replace('\r', ' ');
		return msg;
  }




	/**
	 * Returns the  form field associated with Error
	 *
	 * */

  public String getFieldName(){
    return formFieldName.trim();
  }



  private String getNestedSQLError(Exception e) throws Exception{

    String fieldName="";
    String info="";
    Enumeration enum1=u.getAllErrorCodes();
    String codeName="";
    Properties errorMessages=u.getErrorMessages();
    String errorStr=e.getMessage();
    String errorMsg="";
    String tempCodeName="";
    while(enum1.hasMoreElements()){
      codeName=(String)enum1.nextElement(); //code name
      tempCodeName="ORA-"+codeName;
      	 System.out.println("Inside Processing: codeName "+codeName);
      if(errorStr.indexOf(codeName)!=-1){
        info=(String)errorMessages.get(codeName);
        break;
      }
    }

    if(info==null || info.equals("")){
      errorMsg="Update Error Properties File: Please contact Adminstrator";
    }
    else{
      StringTokenizer split=new StringTokenizer(info, "&");
      try{
        errorMsg=split.nextToken();
				fieldName=split.nextToken();
      }
      catch(Exception er){
        throw new Exception("Please correct Error.Proeprties file for errorCode: "+codeName);
      }
      formFieldName=fieldName;
    }
		return errorMsg;
  }


	private String getLabelName(String field){
	  if(fic==null) return field;
		else if(fic.getLabelName(field).equals("")) return field ;
		else return fic.getLabelName(field);
	}

	private void copyException(Exception e){
		if(e instanceof ProcessingException){
			this.msg=((ProcessingException)e).getMessage();
			this.formFieldName=((ProcessingException)e).getFieldName();
			trap=true;
		}
}

}