package com.etechlogix.distribution.ad.servlet;
/**
 * Title: DistributionLoginServlet.java
 * Description: Contains Process of Login Servlet in
 *              distribution database.
 * Copyright:    Copyright (c) 2000
 * Company: eTechLogix
 * @author Azam
 * Modify Date: 18-July-2001
 * (Add Functionality to check valid warehouse and set in session)
 * @version 1.01
 * updated on 23 july 2001 by asif
 * added userName in session
 * @version 1.02
 */

import java.io.*;
import java.util.*;
import java.sql.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import com.etechlogix.distribution.ad.servlet.ETechUser;
import com.etechlogix.utils.*;
import com.etechlogix.distribution.utils.DistUtils;

public class DistributionLoginServlet  implements Serializable{
    private HttpSession session = null;
    private String actionCode = "";
    private String companyId = "";
    private String password = "";
    private String userId = "";
    private String websiteId = "";
    private String groupId ="";
    private String defaultWarehouse  = "";
    private String defaultPrinter  = "";
    private String defaultPersonalPrinter  = "";
    private String startupMenu = "";
    private String warehouse = "";
    private String priceMask = "";
    private String allowNonStock = "";
    private String standardDateFormat="";
    private String deptId="";
    private String showRebateCost="";
    private String userName="";
    private String allowFinancialMenu="";
    
    private String firstName="";
    private String middleName="";
    private String lastName="";
    private String address="";
    private String state="";
    private String city="";
    private String zip="";
    private String phone="";
    private String emailId="";
    private String allowAuthorized="";
    private String allowDiscountOnCCPayment="";
    private String ccSurchargeFeesPercent="";
    private String customerId="";
    private String custKey="";
    private String firstTimeLogin="";
    private String allowDiscountAchPay="";
    
    HttpServletResponse response;


  public String  doProcessing(HttpServletRequest request) throws LoginException, Exception {
	  
	 String message="";
	 DistUtils du=null;
	  try {
		if(du==null)du=new DistUtils();
        actionCode = Utils.getParameterString("actionCode", request);
        if (actionCode.equals("Logout")){
         logout(request);
         message="Successfully logout";
         }
        else if(actionCode.equals("Login")){
            websiteId  = Utils.getParameterString("websiteId", request);
            userId     = Utils.getParameterString("userId", request);
            password   = Utils.getParameterString("password", request);
            //companyId  = Utils.getParameterString("companyId", request);
            
            companyId  = "1";
            //warehouse  = Utils.getParameterString("warehouse", request);
            warehouse = Utils.removeNull(du.getFieldInfo(" select DEFAULTWAREHOUSE from ETECHUSER where USERID='"+userId+"' and PASSWORD='"+password+"' "));
            priceMask  = Utils.getParameterString("priceMask", request);
            allowNonStock= Utils.getParameterString("allowNonStock", request);
            standardDateFormat  = Utils.getParameterString("standardDateFormat", request);
            deptId= Utils.getParameterString("deptId", request);
            login(request);
        }
    }
    catch(LoginException le) {

    	Utils.log("DistributionLoginServlet. LoginException :",le);
    	message="fail";
    	/*if(le.getErrorCode()==7){
     		throw new LoginException("WARNING: "+le.getMessage(),le);
     	}
     	else{
     		throw new LoginException("ERROR: "+le.getMessage(),le);
		}*/
    	return message;

    }
    catch(Exception e) {
    	Utils.log("DistributionLoginServlet: Exception",e);
    	message="fail";
    	//throw new Exception("ERROR: An error occurred. Please notify the System Administrator.");
    }

    return message;
  }

  private void login(HttpServletRequest request)
    throws LoginException, Exception {

    DistUtils du=null;
    Utils u=null;
    Connection con=null;
    ETechUser eTechUser=null;
    boolean validated=false;
    try{
      if(du==null)du=new DistUtils();
      if(u==null) u=new Utils();
      con=du.getDataConnection();
      eTechUser = new ETechUser(con);
        if(eTechUser==null)throw new Exception("Problemin login");
        validated=eTechUser.validateAndGetGroupId(userId, password, companyId);
        }
      finally{
        if(con!=null)con.close();
        }

    if (validated) {
       groupId = eTechUser.getGroupId();
       defaultWarehouse  = eTechUser.getDefaultWarehouse();
       defaultPrinter  = eTechUser.getDefaultPrinter();
       startupMenu = eTechUser.getStartupMenu();
       userName=eTechUser.getUserName();
       defaultPersonalPrinter  = eTechUser.getDefaultPersonalPrinter();
       showRebateCost = eTechUser.getShowRebateCost();

        if ((startupMenu == null) || (startupMenu.equals("")))
           startupMenu = "D_AdminMainPage.jsp";

        session = request.getSession(true);
        session.setAttribute("userId", userId);
        session.setAttribute("companyId", companyId);
        session.setAttribute("defaultWarehouse", defaultWarehouse);
        session.setAttribute("defaultPrinter", defaultPrinter);
        session.setAttribute("userName", userName);
        session.setAttribute("startupMenu", startupMenu);
        session.setAttribute("Utils",u);
        session.setAttribute("DistUtils",du);
        session.setAttribute("priceMask",priceMask);
        session.setAttribute("allowNonStock",allowNonStock);
        session.setAttribute("standardDateFormat",standardDateFormat);
        session.setAttribute("groupId",groupId);
        session.setAttribute("deptId",deptId);
        session.setAttribute("defaultPersonalPrinter",defaultPersonalPrinter);
        session.setAttribute("showRebateCost", showRebateCost);

        allowFinancialMenu = Utils.removeNull(du.getFieldInfo(" select ALLOWFINANCIALMENU from ETECHUSER where USERID='"+userId+"' "));
        session.setAttribute("allowFinancialMenu", allowFinancialMenu);
        
    	HashMap<String, String> userDetail = getEtechUserDetails(userId);
    	if(userDetail != null && userDetail.size()>0){ 
    		for(int i=0;i<userDetail.size();i++){
    			firstName=userDetail.get("firstName").toString();
    			middleName=userDetail.get("middleName").toString();
    			lastName=userDetail.get("lastName").toString();
    			address=userDetail.get("address").toString();
    			state=userDetail.get("state").toString();
    			city=userDetail.get("city").toString();
    			zip=userDetail.get("zip").toString();
    			phone=userDetail.get("phone").toString();
    			emailId=userDetail.get("emailId").toString();
    			allowAuthorized=userDetail.get("allowAuthorized").toString();
    			allowDiscountOnCCPayment=userDetail.get("allowDiscountOnCCPayment").toString();
    			ccSurchargeFeesPercent=userDetail.get("ccSurchargeFeesPercent").toString();
    			firstTimeLogin=userDetail.get("firstTimeLogin").toString();
    			allowDiscountAchPay=userDetail.get("allowDiscountAchPay").toString();
    		
    		}
    	}

    	session.setAttribute("firstName", firstName);
    	session.setAttribute("middleName", middleName);
    	session.setAttribute("lastName", lastName);
    	session.setAttribute("address", address);
    	session.setAttribute("state", state);
    	session.setAttribute("city", city);
    	session.setAttribute("zip", zip);
    	session.setAttribute("phone", phone);
    	session.setAttribute("emailId", emailId);
    	session.setAttribute("allowAuthorized", allowAuthorized);
    	session.setAttribute("allowDiscountOnCCPayment", allowDiscountOnCCPayment);
    	session.setAttribute("ccSurchargeFeesPercent", ccSurchargeFeesPercent);
    	session.setAttribute("firstTimeLogin", firstTimeLogin);
    	session.setAttribute("allowDiscountAchPay", allowDiscountAchPay);
    	
    	customerId = Utils.removeNull(du.getFieldInfo(" select deptid from etechuser where userid='"+userId+"' "));
    	custKey = Utils.removeNull(du.getFieldInfoPro2(" select cust_key from cust where cust_code='"+customerId+"' "));
    	session.setAttribute("customerId", customerId);
    	session.setAttribute("custKey", custKey);

      // Check Warehouse from Warehouse Table
      Hashtable primKey=new Hashtable();
      primKey.put("COMPANYID",companyId);
      primKey.put("WAREHOUSE",warehouse);
      if(!du.isRecordExists("Warehouse",primKey))
      throw new LoginException("This Warehouse is not a Valid Warehouse", userId, password, 8);

      if(!warehouse.equals(defaultWarehouse))
      throw new LoginException("This Warehouse is not your Default Warehouse", userId, password, 7);
      if(priceMask.equals("0"))
      throw new LoginException("Price Mask is set to zero", userId, password,9);
     }
}

  public void cronLogin(HttpServletRequest request)
  throws LoginException, Exception {

  DistUtils du=null;
  Utils u=null;
  Connection con=null;
  ETechUser eTechUser=null;
  boolean validated=false;
  try{
    du=new DistUtils();
    u=new Utils();
    con=du.getDataConnection();
    eTechUser = new ETechUser(con);
      if(eTechUser==null)throw new Exception("Problemin login");
      validated=eTechUser.validateAndGetGroupId("SYS", "~ZRWCETECH123", "1");
      }
    finally{
      if(con!=null)con.close();
      }

  if (validated) {
     groupId = eTechUser.getGroupId();
     defaultWarehouse  = eTechUser.getDefaultWarehouse();
     defaultPrinter  = eTechUser.getDefaultPrinter();
     startupMenu = eTechUser.getStartupMenu();
     userName=eTechUser.getUserName();
     defaultPersonalPrinter  = eTechUser.getDefaultPersonalPrinter();
     showRebateCost = eTechUser.getShowRebateCost();
     warehouse=Utils.removeNull(request.getParameter("warehouse")).trim();
      if ((startupMenu == null) || (startupMenu.equals("")))
         startupMenu = "D_AdminMainPage.jsp";

      session = request.getSession(true);
      session.setAttribute("userId", "SYS");
      session.setAttribute("companyId", "1");
      session.setAttribute("defaultWarehouse", defaultWarehouse);
      session.setAttribute("defaultPrinter", defaultPrinter);
      session.setAttribute("userName", userName);
      session.setAttribute("startupMenu", startupMenu);
      session.setAttribute("Utils",u);
      session.setAttribute("DistUtils",du);
      session.setAttribute("priceMask","2");
      session.setAttribute("allowNonStock","Y");
      session.setAttribute("standardDateFormat","MM-DD-YY");
      session.setAttribute("groupId",groupId);
      session.setAttribute("deptId","0");
      session.setAttribute("defaultPersonalPrinter",defaultPersonalPrinter);
      session.setAttribute("showRebateCost", showRebateCost);
      session.setAttribute("costMask","3");
			// Check Warehouse from Warehouse Table
Utils.log(warehouse);
	if(warehouse.equals("") || warehouse.equals(" "))
		warehouse="PHX";
    Hashtable primKey=new Hashtable();
    primKey.put("COMPANYID","1");
    primKey.put("WAREHOUSE",warehouse);
    if(!du.isRecordExists("Warehouse",primKey))
    throw new LoginException("This Warehouse is not a Valid Warehouse", userId, password, 8);

   // if(!warehouse.equals(defaultWarehouse))
    //throw new LoginException("This Warehouse is not your Default Warehouse", userId, password, 7);
    if(priceMask.equals("0"))
    throw new LoginException("Price Mask is set to zero", userId, password,9);
   }
}
  
  private void logout(HttpServletRequest request) throws ServletException, IOException {
       Utils.log("log 1");
      if (request.getSession(false) != null){
        Utils.log("log 2");
       request.getSession(false).invalidate();
       }
       Utils.log("log 3");
  }


	public HashMap<String,String> getEtechUserDetails(String userId){
		String query="";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query="select FIRSTNAME,MIDDLENAME,LASTNAME,ADDRESS,STATE,CITY,ZIP,PHONE,EMAILID,ALLOWAUTHORIZED,"
					+"ALLOWDISCOUNTONCCPAYMENT,CCSURCHARGEFEESPERCENT,FIRSTTIMELOGIN,ALLOWDISCOUNTACHPAY from ETECHUSER where USERID='"+userId+"' ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector firstNameVector = new Vector();
			Vector middleNameVector = new Vector();
			Vector lastNameVector = new Vector();
			Vector addressVector = new Vector();
			Vector stateVector = new Vector();
			Vector cityVector = new Vector();
			Vector zipVector = new Vector();
			Vector phoneVector = new Vector();
			Vector emailIdVector = new Vector();
			Vector allowAuthorizedVector = new Vector();
			Vector allowDiscountOnCCPaymentVector = new Vector();
			Vector ccSurchargeFeesPercentVector = new Vector();
			Vector firstTimeLogin = new Vector();
			Vector allowDiscountAchPayVector = new Vector();
			if (ht != null && ht.size() != 0) {
				firstNameVector = (Vector) ht.get("FIRSTNAME");
				middleNameVector = (Vector) ht.get("MIDDLENAME");
				lastNameVector = (Vector) ht.get("LASTNAME");
				addressVector = (Vector) ht.get("ADDRESS");
				stateVector = (Vector) ht.get("STATE");
				cityVector = (Vector) ht.get("CITY");
				zipVector = (Vector) ht.get("ZIP");
				phoneVector = (Vector) ht.get("PHONE");
				emailIdVector = (Vector) ht.get("EMAILID");
				allowAuthorizedVector = (Vector) ht.get("ALLOWAUTHORIZED");
				allowDiscountOnCCPaymentVector = (Vector) ht.get("ALLOWDISCOUNTONCCPAYMENT");
				ccSurchargeFeesPercentVector = (Vector) ht.get("CCSURCHARGEFEESPERCENT");
				firstTimeLogin = (Vector) ht.get("FIRSTTIMELOGIN");
				allowDiscountAchPayVector = (Vector) ht.get("ALLOWDISCOUNTACHPAY");
			}
	        if (allowAuthorizedVector.size() > 0) {
	        	for (int i = 0; i < allowAuthorizedVector.size(); i++) {  
	    			temp=new HashMap<String, String>();
	        		temp.put("firstName", firstNameVector.get(i).toString());
	        		temp.put("middleName", middleNameVector.get(i).toString());
	        		temp.put("lastName", lastNameVector.get(i).toString());
	        		temp.put("address", addressVector.get(i).toString());
	        		temp.put("state", stateVector.get(i).toString());
	        		temp.put("city", cityVector.get(i).toString());
	        		temp.put("zip", zipVector.get(i).toString());
	        		temp.put("phone", phoneVector.get(i).toString());
	        		temp.put("emailId", emailIdVector.get(i).toString());
	    			temp.put("allowAuthorized", allowAuthorizedVector.get(i).toString());
					temp.put("allowDiscountOnCCPayment", allowDiscountOnCCPaymentVector.get(i).toString());
					temp.put("ccSurchargeFeesPercent", ccSurchargeFeesPercentVector.get(i).toString());
					temp.put("firstTimeLogin", firstTimeLogin.get(i).toString());
					temp.put("allowDiscountAchPay", allowDiscountAchPayVector.get(i).toString());
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}


}