package com.etechlogix.distribution.ad.servlet;

import java.io.BufferedReader;
/**
 *  The servlet that handles the user login process
 * Copyright (c) 2002 by eTechLogix, Inc. All Rights Reserved.
 * Author Asim
 */
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.Vector;

/*import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;*/

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;



import org.json.JSONObject;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.LoginException;
import com.etechlogix.utils.Utils;

public class UserLoginServlet extends HttpServlet {

	public static final String apiKey = "60351741"; 
	public static final String apiSecret = "tfXeuyXeUcy7VQ2h";  
	public static final String localUrl = "http://reg2.rwc.org:8080/ReqResponse/RequestResponse";
	public static final String apiUrlVerify = "https://api.nexmo.com/verify/json";
	public static final String apiUrlVerifyCheck = "https://api.nexmo.com/verify/check/json";
	public static final String apiUrlVerifyCancel = "https://api.nexmo.com/verify/control/json";
	public static final String countryCode = "";

  /**
   *  Initialize global variables
   *
   * @param config                     ServletConfig
   * @exception                        ServletException
   */
  public void init(ServletConfig config) throws ServletException {
    super.init(config);

  }

  /**
   * Process the HTTP Get request
   *
   * @param request                    HttpServletRequest
   * @param response                   HttpServletResponse
   * @exception                        ServletException
   * @exception                        IOException
   */
  public void doGet(HttpServletRequest request, HttpServletResponse response) throws
ServletException, IOException {
    doPost(request,response);
  }

  /**
   *  Process the HTTP Post request. It just call <code>doGet</code> method to do the same
thing.
   *
   * @param request                    HttpServletRequest
   * @param response                   HttpServletResponse
   * @exception                        ServletException
   * @exception                        IOException
   */
  public void doPost(HttpServletRequest request, HttpServletResponse response) throws
ServletException, IOException  {

HttpSession session = null;
PrintWriter out = new PrintWriter (response.getOutputStream());
String warehouse="";
String companyId="";
String password="";
String userId="";
String msgTable= "";
String selectedWarehouse="";
String selectedCompanyId="";
String companyIdFromSession="";
String forward="";
String message="";
String deptId="";
String defaultWarehouse="";
DistUtils du=null;
Utils u=null;
String actionCode="";
String priceMask="";
String allowNonStock= "";
String standardDateFormat="";
deptId= "";
String startupMenu ="";
String Submit="";
String searchFile="";
int errorCode=0;
int pwdCahngeDays = 0;
//int pwdCahngeDaysLeft = 0;
String script ="<script language='javascript'>";
String tempWarehouse="";
String tempCompanyId="";
boolean warehouseFlag=false;
boolean companyFlag=false;
boolean showVerifyUser=false;
Vector companyIds=null;
Vector defaultCompanyIds=null;
String defaultCompanyId="";
try{
	u=new Utils();
	du=new DistUtils();
	session=request.getSession(true);
	searchFile=u.loadURL("index.htm");
	actionCode=request.getParameter("actionCode");
	priceMask=request.getParameter("priceMask");
	allowNonStock= request.getParameter("allowNonStock");
	standardDateFormat=request.getParameter("standardDateFormat");
	deptId= request.getParameter("deptId");
	Submit=request.getParameter("Submit");
	//companyId=u.removeNull(request.getParameter("companyId")).trim();
	password=u.removeNull(request.getParameter("password")).trim();
	userId=u.removeNull(request.getParameter("userId")).trim();
	selectedWarehouse=request.getParameter("warehouse");
	//selectedCompanyId=request.getParameter("companyId");
	selectedCompanyId="1";

	Utils.log(" FIRST LOG Submit is "+Submit);
	Utils.log(" FIRST LOG 1 selectedWarehouse is "+selectedWarehouse);
	Utils.log(" FIRST LOG 2 selectedCompanyId s "+selectedCompanyId);

	Utils.log(" actionCode=== "+actionCode);

if(actionCode!=null && actionCode.equals("Logout")){

	 userId=u.removeNull((String)(session.getAttribute("userId")));

      if(!userId.equals("")){
          message="Logout Sucessfully";
          Utils.log("session is "+session);
          session.invalidate();
          userId="";
        }
        else{
         	message="You are not Logged In";
      }

    Utils.log(" message===="+message);

		script+="document.forms[0].userId.value='"+userId+"';";
		script+=" document.forms[0].companyId.value='';";
		script+="document.forms[0].warehouse.value='';";
		script+="document.forms[0].password.value='';";
		script+="</script>";
		searchFile= Utils.replaceString("<!--message-->", message, searchFile);
		searchFile= Utils.replaceString("<!--warehouse-->", warehouse, searchFile);
		searchFile= Utils.replaceString("<!--companyId-->", companyId, searchFile);
		searchFile= Utils.replaceString("<!--script-->", script, searchFile);
    out.println(searchFile);
    out.flush();
    //return;

}
else{
				boolean isSecure = request.isSecure();
				
if(!userId.equals("")){
if(Submit.equals("GetCompanies") ){

  String query="";
						String query1="";
  String tmpPassword="";
    //query="select distinct companyid from etechusergroup where groupid in(select groupid from usergroupmatrix where userid='"+userId+"')";
    query="select distinct eg.companyid,et.defaultCompanyId from etechusergroup eg, usergroupmatrix ugm,etechuser et where eg.groupid =ugm.groupid and ugm.userid=et.userid and ugm.userid='"+userId+"' and et.password='"+password+"' ";
						query1="SELECT FLOOR( NVL(DATEPASSCHANGE, TO_DATE('0001-01-01','YYYY-MM-DD')) - SYSDATE) AS DAYS FROM ETECHUSER WHERE USERID = '"+userId+"' AND PASSWORD='"+password+"'";
						
    Utils.log("QUERY FOR DIFFRENT COMS..."+query);
						Utils.log("QUERY FOR LAST PASSWD DAYS COUNT..."+query1);
						
						pwdCahngeDays = Utils.parseInt(du.getFieldInfo(query1));
						
						//pwdCahngeDaysLeft = 90 - pwdCahngeDays; // difference last password changed
						
						boolean isPhoneVerified = session.getAttribute("isPhoneVerified") != null ? (Boolean) session.getAttribute("isPhoneVerified") : false;
						
    Hashtable ht1=null;

    ht1=new Hashtable();
		companyIds=new Vector(10,5);
    defaultCompanyIds=new Vector(10,5);
		ht1=du.getDataFromQuery(query);

    if(ht1!=null && ht1.size() !=0){
							if(isSecure && !isPhoneVerified){
								showVerifyUser = true;
								Vector data  = du.getFieldInfo("SELECT NVL(REGEXP_REPLACE(MOBILE, '[^0-9]', ''), ' ') MOBILE, nvl(TwoWayAuth, 'N') TWOWAYAUTH FROM ETECHUSER WHERE USERID = '"+userId+"' ", 2);

								String mobileNo = (String)data.get(0);
								String twoWayAuth = (String)data.get(1);
								if(twoWayAuth.trim().equals("") || twoWayAuth.trim().equals("N")){
									message = "You are not authorized to access the system from outside";
								} else if(!mobileNo.trim().equals("")){
									Map<String, String> params = new HashMap<String, String>();
									params.put("number", countryCode+mobileNo);
									params.put("brand", "RWC");
									params.put("pin_expiry", "180");
									params.put("next_event_wait", "180");
									String verifyRes = postRequest(apiUrlVerify, params);
									Utils.log("verifyRes  >>>>>>>>>>>>  " + verifyRes);
									try {
										JSONObject verifyResJson = new JSONObject(verifyRes);
										if(verifyResJson != null && verifyResJson.has("status") && verifyResJson.getString("status").equals("0")){
											session.setAttribute("request_id", verifyResJson.getString("request_id"));
										} else {
											message = "Oops some error occured on sending sms!";
										}
									} catch (Exception jsEx) {
										Utils.log("NexMO Json", jsEx);
										message = "Oops some error occured on sending sms!";
									}
									searchFile= Utils.replaceString("8888888888", mobileNo, searchFile);
								} else {
									message = "Please contact adminitrator to update your Mobile Number";
								}
								session.removeAttribute("isSaveUrl");
								
							} else {
					companyIds=(Vector)ht1.get("COMPANYID");
          defaultCompanyIds=(Vector)ht1.get("DEFAULTCOMPANYID");
							if(pwdCahngeDays <= 0){
								message= "You Need To Change Password";
								script += "document.forms[0].action = '/ChangePassword';"  ;
							
							} else if(pwdCahngeDays > 0 && pwdCahngeDays <= 10){
								message= pwdCahngeDays + " Day(s) Left To Change Password";
							}
		}
							if(isSecure && isPhoneVerified){
								session.removeAttribute("isPhoneVerified");
								session.setAttribute("isSaveUrl", true);
							}
						}
    else {
          message="Login Credentials Not Recognized";
    }
    for (int i=0; i< companyIds.size();i++){
        defaultCompanyId=(String)defaultCompanyIds.get(i);
				tempCompanyId=(String)companyIds.get(i);
				companyId+="<option value='"+companyIds.get(i)+"'>"+companyIds.get(i)+"</option>";
        session.setAttribute("companyIdSession",companyId);

        if(tempCompanyId.equals(defaultCompanyId)){
          selectedCompanyId=defaultCompanyId;
				}
     }
 }
}
				
				boolean isSaveUrl = session.getAttribute("isSaveUrl") != null ? (Boolean) session.getAttribute("isSaveUrl") : false;
						
				Utils.log("login servlet isSaveUrl   ============   " + isSaveUrl);
				
				if(selectedCompanyId!=null && !selectedCompanyId.equals("")){
					if(isSecure && !isSaveUrl){
						response.sendRedirect(request.getContextPath() + "/index.htm");
						return;
					}
				}
				
//if(companyId!=null && !companyId.equals("")){
if(selectedCompanyId!=null && !selectedCompanyId.equals("")){

  	try{
      Vector allWarehouseFromTable=du.warehouseValues(selectedCompanyId);
 			Vector masterInfo = new Vector(3,1);
			Vector userInfo = new Vector(2,1);
		try{
			masterInfo = du.getFieldInfo("select priceMask, DateFormat,allowNonStock from masterInformation where companyId='"+selectedCompanyId+"' ",3);

			if(masterInfo!=null && masterInfo.size()>0){
				priceMask=(String)masterInfo.get(0);
				standardDateFormat=(String)masterInfo.get(1);
				allowNonStock=(String)masterInfo.get(2);
			}
			else{
				priceMask="3";
				standardDateFormat="MM-DD-YYYY";
				allowNonStock="N";
			}


			if(allWarehouseFromTable.size()==0){
				message="No warehouse avaliable for the Company ID";
			}

			userInfo=du.getFieldInfo("select defaultWarehouse,deptId from etechuser where userId='"+userId+"'",2);

			if(userInfo!=null && userInfo.size()>0){
				defaultWarehouse=(String)userInfo.get(0);
				deptId=Utils.removeNull((String)userInfo.get(1)).trim();

				if(Submit.equals("ChangeCompany") || Submit.equals("GetCompanies")){
					selectedWarehouse=defaultWarehouse;
					companyIdFromSession=(String)session.getAttribute("companyIdSession");
					Utils.log("companyIdFromSession ......"+companyIdFromSession);
				}
			}
			
			for (int i=0; i< allWarehouseFromTable.size();i++){
				tempWarehouse=(String)allWarehouseFromTable.get(i);
				if(tempWarehouse.equals(selectedWarehouse)){
					warehouseFlag=true;
				}
				warehouse+="<option value='"+allWarehouseFromTable.get(i)+"'>"+allWarehouseFromTable.get(i)+"</option>";
				session.setAttribute("warehouseSession",warehouse);
			}
		 	if(!warehouseFlag){
		 		selectedWarehouse=tempWarehouse;
		 	}
		}catch(Exception e1){
			message=e1.getMessage();
      Utils.log(" ERROR MESSAGE ############  "+message);
      throw e1;
		}


		 }
		 catch(Exception ex ){
		 	message=ex.getMessage();
		 	Utils.log(" STEP 2 "+message);

 			script+="document.forms[0].userId.value='"+userId+"';";
			//script+=" document.forms[0].companyId.value='"+companyId+"';";
      script+=" document.forms[0].companyId.value='"+selectedCompanyId+"';";
			script+="document.forms[0].warehouse.value='"+selectedWarehouse+"';";
			script+="document.forms[0].password.value='"+password+"';";
			script+="document.Login.priceMask.value='"+priceMask+"'; ";
			script+="document.Login.standardDateFormat.value='"+standardDateFormat+"'; ";
			script+="document.Login.allowNonStock.value='"+allowNonStock+"'; ";
			script+="document.Login.deptId.value='"+deptId+"'; ";

//			script+=" showMessage('"+ message+"');";

			script+="</script>";

			searchFile= Utils.replaceString("<!--message-->", message, searchFile);
			searchFile= Utils.replaceString("<!--warehouse-->", warehouse, searchFile);
			searchFile= Utils.replaceString("<!--companyId-->", companyId, searchFile);
	    searchFile= Utils.replaceString("<!--script-->", script, searchFile);

      out.println(searchFile);
      out.flush();
//    out.close();
      return;

		 }//second try

    }// end of !comanyid=""

				isSaveUrl = session.getAttribute("isSaveUrl") != null ? (Boolean) session.getAttribute("isSaveUrl") : false;
				
				Utils.log("login servlet isSaveUrl end of !comanyid=  ============   " + isSaveUrl);

    if(selectedCompanyId!=null && selectedWarehouse!=null && !(Submit.equals("ChangeCompany") || Submit.equals("GetCompanies")) ) {
			Utils.log("************* In Distribution Login Servlet ******** ");
      DistributionLoginServlet dls=null;
			try{
						String query1="SELECT FLOOR(NVL(DATEPASSCHANGE, TO_DATE('0001-01-01','YYYY-MM-DD')) - SYSDATE) AS DAYS FROM ETECHUSER WHERE USERID = '"+userId+"' AND PASSWORD='"+password+"'";
						
						Utils.log("QUERY FOR LAST PASSWD DAYS COUNT..."+query1);
						
						pwdCahngeDays = Utils.parseInt(du.getFieldInfo(query1));
						
						//pwdCahngeDaysLeft = 90 - pwdCahngeDays;
						
						if(pwdCahngeDays <= 0){
							response.sendRedirect(request.getContextPath() + "/ChangePassword?userId=" + userId);
							return;
						}
						
				dls=new DistributionLoginServlet();
				message=dls.doProcessing(request);
				startupMenu = (String)session.getAttribute("startupMenu");
				Utils.log("############  startupMenu ###########  "+startupMenu);
				defaultWarehouse = (String)session.getAttribute("defaultWarehouse");
				//--- Calling function for the ShortCut key

				//shortKey(session,du,companyId,userId);
				shortKey(session,du,selectedCompanyId,userId);

				Utils.log("############  error code ###########  "+errorCode);
				Utils.log("############  selectedWarehouse ###########  "+selectedWarehouse+"   defaultWarehouse=="+defaultWarehouse );
				if(selectedWarehouse.equals(defaultWarehouse) && errorCode!=9){
					Utils.log("selectedWarehouse==="+selectedWarehouse+" and errorCode==="+errorCode);
					response.sendRedirect(request.getContextPath() + "/"+startupMenu);
					return;
				}
			}
			catch(LoginException le){
				startupMenu = (String)session.getAttribute("startupMenu");
				errorCode=le.getErrorCode();
				message=le.getMessage(); // errorCode 7 means different warehouse

				if(errorCode==7){
				session.setAttribute("defaultWarehouse",selectedWarehouse);
				defaultWarehouse=selectedWarehouse;
					forward="<a href= '"+startupMenu+ "'><b>Continue</b></a>";
				}
				else if(errorCode==9){
					forward="<a href= '"+startupMenu+ "'><b>Continue</b></a>";
				}

				Utils.log(" STEP 3 "+message);

		        script+="document.forms[0].userId.value='"+userId+"'; ";
		        //script+=" document.forms[0].companyId.value='"+companyId+"';";
		        script+=" document.forms[0].companyId.value='"+selectedCompanyId+"';";
		        script+="document.forms[0].warehouse.value='"+selectedWarehouse+"';";
		        script+="document.forms[0].password.value='"+password+"';";
		        script+="document.Login.priceMask.value='"+priceMask+"'; ";
				script+="document.Login.standardDateFormat.value='"+standardDateFormat+"'; ";
				script+="document.Login.allowNonStock.value='"+allowNonStock+"'; ";
				script+="document.Login.deptId.value='"+deptId+"'; ";
		
				//script+=" showMessage('"+ message+"' );";
		        script+="</script>";
		     	searchFile= Utils.replaceString("<!--message-->", message, searchFile);
		        searchFile= Utils.replaceString("<!--warehouse-->", warehouse, searchFile);
		        searchFile= Utils.replaceString("<!--companyId-->", (String)session.getAttribute("companyIdSession"), searchFile);
		        searchFile= Utils.replaceString("<!--script-->",script, searchFile);
		        searchFile= Utils.replaceString("<!--forward-->", forward, searchFile);
		        out.println(searchFile);
		        out.flush();
		        return;
			}
			catch(Exception e){
				message=e.getMessage();
				Utils.log(" STEP 2 "+message);
				script+="document.forms[0].userId.value='"+userId+"'; ";
				//script+=" document.forms[0].companyId.value='"+companyId+"';";
        script+=" document.forms[0].companyId.value='"+selectedCompanyId+"';";
				script+="document.forms[0].warehouse.value='"+selectedWarehouse+"';";
				script+="document.forms[0].password.value='"+password+"';";
				script+="document.Login.priceMask.value='"+priceMask+"'; ";
				script+="document.Login.standardDateFormat.value='"+standardDateFormat+"'; ";
				script+="document.Login.allowNonStock.value='"+allowNonStock+"'; ";
				script+="document.Login.deptId.value='"+deptId+"'; ";

//				script+=" showMessage('"+ message+"' );";
				script+="</script>";
				searchFile= Utils.replaceString("<!--message-->", message, searchFile);
				searchFile= Utils.replaceString("<!--warehouse-->", warehouse, searchFile);
				searchFile= Utils.replaceString("<!--companyId-->", companyId, searchFile);
				searchFile= Utils.replaceString("<!--script-->", script, searchFile);
				searchFile= Utils.replaceString("<!--forward-->", forward, searchFile);

				out.println(searchFile);
				out.flush();
				return;
			}
					isSaveUrl = session.getAttribute("isSaveUrl") != null ? (Boolean) session.getAttribute("isSaveUrl") : false;

					Utils.log("login servlet isSaveUrl last =  ============   " + isSaveUrl);
					
					//request.setAttribute("message", "Wrong password. Try again or click Forgot password to reset it.");
					//response.sendRedirect("login.jsp");

					//RequestDispatcher requestDispatcher = request.getRequestDispatcher("login.jsp");
		            //requestDispatcher.forward(request, response);

					

     }// end if(selectedWarehouse!=null && !Submit.equals("ChangeCompany"))
      Utils.log("..............Final warehouse..."+warehouse);
      script+="document.forms[0].userId.value='"+userId+"'; ";
      //script+=" document.forms[0].companyId.value='"+companyId+"';";
      script+=" document.forms[0].companyId.value='"+selectedCompanyId+"';";
      script+="document.forms[0].warehouse.value='"+selectedWarehouse+"';";
      script+="document.forms[0].password.value='"+password+"';";
      script+="document.Login.priceMask.value='"+priceMask+"'; ";
			script+="document.Login.standardDateFormat.value='"+standardDateFormat+"'; ";
			script+="document.Login.allowNonStock.value='"+allowNonStock+"'; ";
			script+="document.Login.deptId.value='"+deptId+"'; ";
				if(message.equals("") && showVerifyUser){
					script+="document.getElementById('popupEdit-New').style.display = 'block'; ";
					
				}
//			script+=" showMessage('"+ message+"');";
			script+="</script>";
      searchFile= Utils.replaceString("<!--message-->", message, searchFile);
			searchFile= Utils.replaceString("<!--warehouse-->", warehouse, searchFile);
			searchFile= Utils.replaceString("<!--companyId-->", companyIdFromSession, searchFile);
			searchFile= Utils.replaceString("<!--script-->", script, searchFile);
			searchFile= Utils.replaceString("<!--forward-->", forward, searchFile);

			out.println(searchFile);
			out.flush();
}//end of else of(action code != logout
}
catch(Exception e){
	message=e.getMessage();
	Utils.log(" FIRST CATCH STEP 1 ",e);
    	Utils.log(" ERROR IN GETTING VALUES ");
}
}
	private void shortKey(HttpSession session,DistUtils du,String companyId,String userId) throws Exception{
		//--- Code for the ShortCut key
		Utils.log("In shortcut key=====================================companyId >"+companyId+"  userid==>"+userId);
		Hashtable ht=null;
		Vector vShortCut=null;
		Vector vUrl=null;
		Vector vdescription=null;
		ht=new Hashtable();
		vShortCut=new Vector(10,5);
		vUrl=new Vector(10,5);
		vdescription=new Vector(10,5);
		//ht=du.getDataFromQuery("Select shortCut,urlName from ShortCutKey where companyId='"+companyId+"' and userId='"+userId+"'");
		ht=du.getDataFromQuery("Select shortCut,urlName,description from ShortCutKey where companyId='"+companyId+"' ");

		if(ht!=null){
			vShortCut=(Vector)ht.get("SHORTCUT");
			vUrl=(Vector)ht.get("URLNAME");
			vdescription=(Vector)ht.get("DESCRIPTION");
			session.setAttribute("shortCut",vShortCut);
			session.setAttribute("urlName",vUrl);
			session.setAttribute("vdescription",vdescription);
			//Utils.log("vdescription>>>>>>"+ vdescription);
		}
	}

	public static String postRequest(String urlString, Map<String,String> params1){
		
		params1.put("api_key", apiKey);
		params1.put("api_secret", apiSecret);
		
		StringBuilder sb = new StringBuilder();
        StringBuilder postData = new StringBuilder();
        String response = "";
        
        try{
        	
        	URL url = new URL(localUrl);
        	
        	String jsonParams = new JSONObject(params1).toString();
        	
        	Utils.log("jsonParams   >>>>>>>>>>>  " + jsonParams);
        	        	
        	Map<String,String> params = new HashMap<String, String>();
        	params.put("url", urlString);
        	params.put("params", jsonParams);
        	params.put("requestType", "POST");
        	
        	for (Map.Entry<String,String> param : params.entrySet()) {
                if (postData.length() != 0) postData.append('&');
                postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
                postData.append('=');
                postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
            }
            
        	Utils.log("params   >>>>>>>>>>>  " + params);
        	Utils.log("postData   >>>>>>>>>>>  " + postData.toString());
        	
            byte[] postDataBytes = postData.toString().getBytes("UTF-8");
            
            //if(postDataBytes.length > 0)
            //	throw new Exception("Exp");
            
	        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
	        conn.setRequestMethod("POST");
	        //conn.setConnectTimeout(20*1000);
	        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
	        conn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
	        conn.setDoOutput(true);
			conn.setDoInput(true);
			conn.getOutputStream().write(postDataBytes);

			InputStreamReader isr = new InputStreamReader(conn.getInputStream(), "UTF-8");
			
			Reader in = new BufferedReader(isr);

			for (int c; (c = in.read()) >= 0;)
				sb.append((char) c);
			
			if(isr!=null)isr.close();
			
			if(in!=null)in.close();
			
			response = sb.toString();
        
        } catch(Exception e){
        	Utils.log("NEXMO API", e);
        }
        
        Utils.log("response  ===============  " + response);
        
        /*if(urlString.contains("check")){
        	if(params1.get("code").equals("1234"))
        		response = "{\"request_id\":\"11bb272e0af64645ab504e9e4663e188\",\"status\":\"0\",\"event_id\":\"0B0000000E71D518\",\"price\":\"0.03000000\",\"currency\":\"EUR\"}";
        	else
        		response = "{\"request_id\":\"11bb272e0af64645ab504e9e4663e187\",\"status\":\"1\",\"event_id\":\"0B0000000E71D518\",\"price\":\"0.03000000\",\"currency\":\"EUR\"}";
        } else {
        	response = "{\"request_id\": \"11bb272e0af64645ab504e9e4663e188\",\"status\": \"0\"}";
        }*/
        
        return response;
	}
		

}
