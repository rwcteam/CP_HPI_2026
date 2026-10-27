package com.etechlogix.utils;

import java.io.*;
import java.util.*;
import java.sql.SQLException;
import java.rmi.RemoteException;
import java.rmi.NoSuchObjectException;
import javax.rmi.PortableRemoteObject;
import javax.transaction.RollbackException;
import javax.ejb.DuplicateKeyException;
import javax.ejb.ObjectNotFoundException;
import com.etechlogix.distribution.grid.FieldsContainer;

/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Asif Ali
 * @version 2.0
 * last modified on 15-Feb-2002 by Ashif Ali
 */
public class ProcessingErrorException extends Exception {

  private String msg="";
  private Utils u=null;
  private String labelfileName;
  private String formFieldName;
	private String labelName;
	private String format;
	private Exception ex;
	private FieldsContainer fic;

   //first constructor

  public ProcessingErrorException(Exception ex) throws Exception{
Utils.log("1");

		this.ex=ex;
		exceptionHandler();
    if(u==null)u=new Utils();
  }
  //constructor uses tableNameLabel.properties file.

 public ProcessingErrorException(Exception ex, String fileName) throws Exception{
Utils.log("2");
    if(u==null)u=new Utils();
	  this.ex=ex;
		this.labelfileName=fileName;
		fic=new FieldsContainer(u.getProperty("GridAppletDirectory")+this.labelfileName);
		exceptionHandler();
  }

//third constructor

 public ProcessingErrorException(String message, String fieldName) throws Exception{
Utils.log("3");

    msg=message;
    formFieldName=fieldName;
 }



   private void exceptionHandler()throws Exception{
Utils.log("2.1");
				Utils.log("Inside ProcessionExc:"+ex.getClass());

			if(ex instanceof ProcessingErrorException)processingErrorException();
			else if(ex instanceof DuplicateKeyException)duplicateKeyException();
			else if(ex instanceof ObjectNotFoundException)objectNotFoundException();
			else if(ex instanceof SQLException)sqlException();
			else if(ex instanceof RemoteException)remoteException();
			else if(ex instanceof RollbackException)rollbackException();
			else if(ex instanceof DataNotFoundException)dataNotFoundException();
			else if(ex instanceof RecordNotFoundException)recordNotFoundException();
			else if(ex instanceof InvalidParameterException)invalidParameterException();
		  else{
				Utils.log("Exception could not be handled by ProcessionExc:"+ex.getClass());
			  msg=ex.getMessage();
			}
	}



		private void processingErrorException(){
			msg=((ProcessingErrorException)ex).getMessage();
			formFieldName=((ProcessingErrorException)ex).getFieldName();
                        Utils.log(" formFieldNameformFieldName "+formFieldName );
		}

	private void sqlException()throws Exception{
		    u=new Utils();
		  SQLException se=(SQLException)ex;
			int errorCode=se.getErrorCode();
                    Utils.log("Exception errorCode "+errorCode);
			String childKey=u.getChildKey();
                	String parentKey=u.getParentKey();
                	String uniqueKey=u.getUniqueKey();


                	Utils.log("Inside Processiong Exception: uniqueKeyuniqueKeyuniqueKey ERRO "+uniqueKey+" errorCode  "+errorCode);

                	if(errorCode==Integer.parseInt(childKey)){
                		msg=getChildError(se.getMessage());
                	}
		else if(errorCode==Integer.parseInt(parentKey)){
		            Utils.log("Inside Processiong Exception:"+msg);
			    msg=getParentError(se.getMessage());
		            Utils.log("Inside Processiong Exception:"+msg);

		}
		else if(errorCode==Integer.parseInt(uniqueKey)){
		            Utils.log("Inside Processiong Exception: FOR UNIQUE KEY ERRO "+msg);
			    msg=getUniqueError(se.getMessage());
		}
		else{
				msg=u.getErrorMessage(Integer.toString(errorCode));
				int t=msg.indexOf("&");
				if(t!=-1){
					String temp=msg;
					msg=temp.substring(0,t);
					formFieldName=temp.substring(t+1);
			  }
			  else throw new Exception("Please correct Error.Properties file for errorCode "+msg);
			}

    Utils.log("Inside Processiong Exception:"+msg);
	}

	 private void noSuchObjectException(){
				msg=u.getErrorMessage("TABLE-UPD001");
	 }
	 private void duplicateKeyException(){
				 msg=u.getErrorMessage("TABLE-ADD001");
	 }

	 private void remoteException()throws Exception{
		RemoteException re=(RemoteException) ex;
		Exception wrap=(Exception) re.detail;
Utils.log("4");

		if(wrap instanceof SQLException){
Utils.log("5");

			SQLException se=(SQLException) wrap;
		  ex=se;
			sqlException();
		}
		else{
		Utils.log("6");

			msg=wrap.getMessage();
		}
	 }

 private void rollbackException()throws Exception{
      String parentKey=u.getParentKey();
      String childKey=u.getChildKey();
      String uniqueKey=u.getUniqueKey();
      String errorMsg=ex.toString();
      Utils.log(" INSIDE ROLLBACK &&&&&&&&&&&& uniqueKey "+uniqueKey+" errorMsg "+errorMsg);
      if((errorMsg.indexOf(parentKey))!=-1)msg=getParentError(errorMsg);
      else if((errorMsg.indexOf(childKey))!=-1)msg=getChildError(errorMsg);
      else if((errorMsg.indexOf(uniqueKey))!=-1)msg=getUniqueError(errorMsg);
      else msg=getNestedSQLError(ex);
 }

 private void objectNotFoundException(){
				msg=u.getErrorMessage("TABLE-DEL001");
}


		private void dataNotFoundException(){
		  getData();
			String str=u.getErrorMessage("NO-DATA");
			msg=u.replaceString("<~KEY~>",labelName,str);
	 }

	 private void recordNotFoundException(){
		 getData();
		 msg=labelName;
	 }


		private void parameterNotFoundException(){
			getData();
			String str=u.getErrorMessage("NO-PARAM");
			msg=u.replaceString("<~KEY~>",labelName,str);
	 }

		private void invalidParameterException(){
			getData();
			String str=u.getErrorMessage("INV-PARAM");
			str=u.replaceString("<~KEY~>",labelName,str);
			msg=u.replaceString("<~FORMAT~>",format,str);
	 }



/*
    for child and parent record voilation

  */

  private String getParentError(String errorStr)throws Exception{

    String message="",consName="",fieldName="",info="";
		String nmesg="";
		Utils.log("Inside parent");
    Enumeration enum1=u.getAllErrorCodes();
    Properties errorMessages=u.getErrorMessages();
    while(enum1.hasMoreElements()){
      consName=(String)enum1.nextElement(); //constraint name
      if(errorStr.indexOf(consName)!=-1){
        info=(String)errorMessages.get(consName); //all information against the constaraitn name in the properties file
        break;
      }
    }
	 Utils.log("info:"+info);
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
    labelName=getLabelname(fieldName);
    nmesg=u.getErrorMessage("TABLE-ADDUPD");
    nmesg=u.replaceString("<~KEY~>",labelName,nmesg);
    nmesg=u.replaceString("<~TABLENAME~>",detailTable,nmesg);
		Utils.log("mes:"+nmesg);
    return nmesg;
}


 private String getChildError(String errorStr)throws Exception{
    String message="",consName="",fieldName="",info="";

    Enumeration enum1=u.getAllErrorCodes();
	  Properties errorMessages=u.getErrorMessages();
    while(enum1.hasMoreElements()){
      consName=(String)enum1.nextElement(); //constraint name
      if(errorStr.indexOf(consName)!=-1){
        info=(String)errorMessages.get(consName);
        break;
      }
    }

    if (info.equals("")) return errorStr;
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
    labelName=getLabelname(fieldName);

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

   //Entry/Form Lavel error and others


private void getData(){
String value=ex.getMessage();
    if(value.indexOf("&&")!=-1){
      StringTokenizer split=new StringTokenizer(value, "&&");
		  formFieldName=split.nextToken().trim();
      format=split.nextToken().trim();
    }
		else{
			formFieldName=ex.getMessage().trim();
		  format="";
		}
		labelName=getLabelname(formFieldName);
	}

	private String getLabelname(String field){
		if(fic==null)labelName=field;
    else labelName=fic.getLabelName(field);
		if(labelName.equals(""))labelName=field;
		return labelName;
	}

	public String getFieldName(){
    return formFieldName;
  }


	//called later for the User Defind Procedure
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
//	 System.out.println("Inside Processing: codeName "+codeName);
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




/*
    for child and parent record voilation

  */

  private String getUniqueError(String errorStr)throws Exception{

    String message="",consName="",fieldName="",info="";
		String nmesg="";
		Utils.log("Inside getUniqueError %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ");
    Enumeration enum1=u.getAllErrorCodes();
    Properties errorMessages=u.getErrorMessages();
    while(enum1.hasMoreElements()){
      consName=(String)enum1.nextElement(); //constraint name
      if(errorStr.indexOf(consName)!=-1){
        info=(String)errorMessages.get(consName); //all information against the constaraitn name in the properties file
        break;
      }
    }
	 Utils.log("info:"+info);
   if (info.equals(""))
    return u.getErrorMessage("UNIQUE-KEY");
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
    labelName=getLabelname(fieldName);
    nmesg=u.getErrorMessage("UNIQUE-KEY");

    nmesg=u.replaceString("<~FIELDNAME~>",labelName,nmesg);
    //nmesg=u.replaceString("<~TABLENAME~>",detailTable,nmesg);

    Utils.log("mes:"+nmesg);
    return nmesg;
}

}