package com.etechlogix.distribution.utils;


import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.sql.*;
import com.etechlogix.utils.*;
import com.etechlogix.distribution.grid.*;
/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Ashif Ali
 * @version 1.0
 */

public class ScriptCreator {

	private HttpServletRequest request;
	private String query;
	private FieldsContainer fic;
	private boolean searchedRecord=false;

  public ScriptCreator(HttpServletRequest request,String labelFile,String query)throws Exception {
		this.request=request;
		this.query=query;
	  String submit=request.getParameter("Submit")+"";
		setFieldContainer(labelFile+".properties",submit);
  }

  public ScriptCreator(HttpServletRequest request,String labelFile,String query, String submit)throws Exception {
	  this.request=request;
	  this.query=query;
	  setFieldContainer(labelFile+".properties",submit);
  }

	public String getRestoreScript()throws IOException{
			String key="", value="";
			String nameArray="", valueArray="";
			String restoreScript="";
			Field fi=null;
			int fields = fic.getTotalFields();
			//nameArray=" var name= new Array("+fic.getTotalFields()+")\n";
			//valueArray=" var value= new Array("+fic.getTotalFields()+")\n";
			nameArray=" var nameArray= [] ; ";
			valueArray=" var value=  [] ; ";
		  int i=0;
			while(fic.hasMoreFields()){
				fi=fic.nextField();
				key=fi.getName();
				value=fi.getValue();
				value=parseString(value);
				nameArray+=" nameArray["+i+"]='"+key+"';";
				valueArray+="  value["+i+"]='"+value+"';";
				restoreScript+=" document.forms[0]."+key+".value='"+value+"';";
			i++;
			}
			
  //	return "<script>"+restoreScript+"</script>";
		return nameArray+" "+valueArray+"  setValuesInventoryFromArray(); ";

	}
	
	public String getRestoreScriptNew()throws IOException{
		String key="", value="";
		String nameArray="", valueArray="";
		String restoreScript="";
		Field fi=null;
		int fields = fic.getTotalFields();
		//nameArray=" var name= new Array("+fic.getTotalFields()+")\n";
		//valueArray=" var value= new Array("+fic.getTotalFields()+")\n";
		nameArray=" var nameArray= [] ; ";
		valueArray=" var value=  [] ; ";
		  int i=0;
			while(fic.hasMoreFields()){
				fi=fic.nextField();
				key=fi.getName();
				value=fi.getValue();
				value=parseString(value);
				nameArray+=" nameArray["+i+"]='"+key+"';";
				valueArray+="  value["+i+"]='"+value+"';";
				restoreScript+=" document.forms[0]."+key+".value='"+value+"';";
			i++;
			}
			
		return nameArray+" "+valueArray+"  setValuesInventoryFromArray(nameArray, value); ";

	}

	public boolean isRecordExists(){
		return searchedRecord;
	}

	private String parseString(String str)throws IOException{
    StringReader strReader=new StringReader(str);
    int c=0, i=0, count=0;
    char array[]=new char[2*str.length()];
		String st="";
		while(count<str.length()){
					c=strReader.read();
					if((char)c=='\'' ||(char)c=='\"'){
						array[i]=(char)'\\';
					  i++;
					}

	   array[i]=(char)c;
		 i++;
		 count++;
		}
		st=new String(array, 0, i);
	  return st==null?str: st;
	}

	private void setFieldContainer(String labelFile,String submit)throws ProcessingErrorException,Exception{
		DistUtils du=DistUtils.getDistUtils(request.getSession(false));
		Utils u=DistUtils.getUtils(request.getSession(false));
		labelFile=u.getProperty("GridAppletDirectory")+labelFile;
		Connection con=null;
		Statement st=null;
		ResultSet rs=null;
		try {
		  fic=new FieldsContainer(labelFile);
		  if(submit.equals("SearchRecord")){
				con=du.getDataConnection();
				st=con.createStatement();
				rs=st.executeQuery(query);
				Utils.log(query);
			  if(rs.next()){
				  Utils.log("true");

				  searchedRecord=true;
					fic.setFromResultSet(rs);
					}
		    else fic.setFromRequest(request);
		  }
			else{
				fic.setFromRequest(request);
			}
		}
		catch (Exception ex) {
		  throw ex;
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

	}


}