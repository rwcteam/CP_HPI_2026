package com.etechlogix.hibernate.ad.servlet;

import com.etechlogix.utils.*;
import com.etechlogix.distribution.utils.*;
import java.sql.*;
import java.io.*;
import java.util.*;

public class EtechUserRestore implements Serializable{
  public String USERID;
  public String USERTYPE;
  public String GROUPID;
  public String USERINITIALS;
  public String FIRSTNAME;
  public String MIDDLENAME;
  public String LASTNAME;
  public String ADDRESS;
  public String CITY;
  public String STATE;
  public String ZIP;
  public String PHONE;
  public String FAX;
  public String MOBILE;
  
  public String CREDITCARDNO;
  public String EXPIRYDATE;
  
  public String PASSWORD;
  public String PASSWORDEXPIRYDATE;
  public String DEFAULTPRINTER;
  public String DEFAULTWAREHOUSE;
  public String X;
  public String STATUS;
  public String EMAILID;
  public String DATEOFBIRTH;
  public String SHOWREBATECOST;
  public String DEFAULTCOMPANYID;
  public String ALLOWCHANGERECEIPTWHSE;
  public String DEFAULTPERSONALPRINTER;
  public String EMPID;
  
  public String TITLE;
  public String OLDUSERID;
  
  public String PHONEEXT;
  public String SPEEDDIAL;
  public String DEPTID;

  public String COSTOVERRIDE;			
  public String ALLOWCHANGEPERIODJE	;		
  public String SHOWLOGINPOPUP;				
  public String FINANCIALEMAIL;			
  public String SOHELP;					
  public String ALLOWCLOSEPAYMENTRECEIPT;
  public String VEHICLEADMIN;				
  public String DATEPASSCHANGE;			
  public String ICRCORPORATE;			
  public String WRTRANSFERACCESS;		
  public String COMMPERMISSION;			
  public String AUTHORIZEDCODE;			
  public String ALLOWAUTHORIZED;			
  public String AUTHORIZEDAMOUNT;			
  public String ALLOWPAYTRACEALLWHSE;		
  public String CASHREPORTPERMISSION;	
  public String ALLOWSUGCONTRACTPRICAPPROVAL;
  public String NEWITEMREQUESTEMAIL;	
  public String OVERRIDEDELIVERYCOST;	
  public String PINCODE;					
  public String ALLOWPODELIVERYPRINT;		
  public String TWOWAYAUTH;
  
  public EtechUserRestore (Connection con, String query, String standardDateFormat) throws Exception{
		
		Statement st=null;
		ResultSet rs=null;
			
		try {
			st=con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			rs=st.executeQuery(query);
			if(rs.next()){
				this.USERID=Utils.removeNull(rs.getString("userId"));
				this.USERTYPE=Utils.removeNull(rs.getString("userType"));
				this.GROUPID=Utils.removeNull(rs.getString("groupId"));
				this.USERINITIALS=Utils.removeNull(rs.getString("userInitials"));
				this.FIRSTNAME=Utils.removeNull(rs.getString("firstName"));
				this.MIDDLENAME=Utils.removeNull(rs.getString("middleName"));
				this.LASTNAME=Utils.removeNull(rs.getString("lastName"));
				this.ADDRESS=Utils.removeNull(rs.getString("address"));
				this.CITY=Utils.removeNull(rs.getString("city"));
				this.STATE=Utils.removeNull(rs.getString("state"));
				this.ZIP=Utils.removeNull(rs.getString("zip"));
				this.PHONE=Utils.removeNull(rs.getString("phone"));
				this.FAX=Utils.removeNull(rs.getString("fax"));
				this.MOBILE=Utils.removeNull(rs.getString("mobile"));
				this.PASSWORD=Utils.removeNull(rs.getString("password"));
				this.EMAILID=Utils.removeNull(rs.getString("emailid"));
				this.SHOWREBATECOST=Utils.removeNull(rs.getString("showRebateCost"));
				this.DATEOFBIRTH=DistUtils.changeDateFormatTest(rs.getDate("dateOfBirth"),standardDateFormat);
				//this.PASSWORDEXPIRYDATE=Utils.changeDateFormat(rs.getDate("passwordExpiryDate"));
				this.PASSWORDEXPIRYDATE=DistUtils.changeDateFormatTest(rs.getDate("passwordExpiryDate"),standardDateFormat);
				this.DEFAULTPRINTER=Utils.removeNull(rs.getString("defaultPrinter"));
				this.DEFAULTWAREHOUSE=Utils.removeNull(rs.getString("defaultWarehouse"));
				this.X=Utils.removeNull(rs.getString("x"));
				this.STATUS=Utils.removeNull(rs.getString("status"));
				this.DEFAULTCOMPANYID=Utils.removeNull(rs.getString("defaultCompanyId"));
				this.ALLOWCHANGERECEIPTWHSE=rs.getString("allowChangeReceiptWhse");
				this.DEFAULTPERSONALPRINTER=rs.getString("defaultPersonalPrinter");
				this.EMPID=rs.getString("empId");
				this.PHONEEXT=rs.getString("phoneExt");
				this.SPEEDDIAL=rs.getString("speedDial");
				this.DEPTID=rs.getString("deptId");
			}
			else{
				throw new RecordNotFoundException("EtechUserKey","EtechUser");
			}
		} finally {
			try { if (rs!=null) rs.close(); } catch (Exception e) {}
	    	try { if (st!=null) st.close(); } catch (Exception e) {}
		}
	}

	public EtechUserRestore(){}
  
	public String getUserId(){
	    return USERID;
	  }
	public void setUserId(String userId) {
		this.USERID = userId;
	}

	public String getCostOverride() {
		return COSTOVERRIDE;
	}

	public void setCostOverride(String costOverride) {
		COSTOVERRIDE = costOverride;
	}

	public String getAllowChangePeriodJe() {
		return ALLOWCHANGEPERIODJE;
	}

	public void setAllowChangePeriodJe(String aLLOWCHANGEPERIODJE) {
		ALLOWCHANGEPERIODJE = aLLOWCHANGEPERIODJE;
	}

	public String getShowLoginPopUp() {
		return SHOWLOGINPOPUP;
	}

	public void setShowLoginPopUp(String sHOWLOGINPOPUP) {
		SHOWLOGINPOPUP = sHOWLOGINPOPUP;
	}

	public String getFinancialEmail() {
		return FINANCIALEMAIL;
	}

	public void setFINANCIALEMAIL(String fINANCIALEMAIL) {
		FINANCIALEMAIL = fINANCIALEMAIL;
	}

	public String getSoHelp() {
		return SOHELP;
	}

	public void setSOHELP(String sOHELP) {
		SOHELP = sOHELP;
	}

	public String getAllowClosePaymentReceipt() {
		return ALLOWCLOSEPAYMENTRECEIPT;
	}

	public void setAllowClosePaymentReceipt(String aLLOWCLOSEPAYMENTRECEIPT) {
		ALLOWCLOSEPAYMENTRECEIPT = aLLOWCLOSEPAYMENTRECEIPT;
	}

	public String getVehicleAdmin() {
		return VEHICLEADMIN;
	}

	public void setVehicleAdmin(String vEHICLEADMIN) {
		VEHICLEADMIN = vEHICLEADMIN;
	}

	public String getDatePasschange() {
		return DATEPASSCHANGE;
	}

	public void setDatePasschange(String dATEPASSCHANGE) {
		DATEPASSCHANGE = dATEPASSCHANGE;
	}

	public String getIcrCorporate() {
		return ICRCORPORATE;
	}

	public void setIcrCorporate(String iCRCORPORATE) {
		ICRCORPORATE = iCRCORPORATE;
	}

	public String getWrTransferAccess() {
		return WRTRANSFERACCESS;
	}

	public void setWrTransferAccess(String wRTRANSFERACCESS) {
		WRTRANSFERACCESS = wRTRANSFERACCESS;
	}

	public String getCommPermission() {
		return COMMPERMISSION;
	}

	public void setCommPermission(String cOMMPERMISSION) {
		COMMPERMISSION = cOMMPERMISSION;
	}

	public String getAuthorizedCode() {
		return AUTHORIZEDCODE;
	}

	public void setAuthorizedCode(String aUTHORIZEDCODE) {
		AUTHORIZEDCODE = aUTHORIZEDCODE;
	}

	public String getAllowAuthorized() {
		return ALLOWAUTHORIZED;
	}

	public void setAllowAuthorized(String aLLOWAUTHORIZED) {
		ALLOWAUTHORIZED = aLLOWAUTHORIZED;
	}

	public String getAuthorizedAmount() {
		return AUTHORIZEDAMOUNT;
	}

	public void setAuthorizedAmount(String aUTHORIZEDAMOUNT) {
		AUTHORIZEDAMOUNT = aUTHORIZEDAMOUNT;
	}

	public String getAllowPayTraceAllWhse() {
		return ALLOWPAYTRACEALLWHSE;
	}

	public void setAllowPayTraceAllWhse(String aLLOWPAYTRACEALLWHSE) {
		ALLOWPAYTRACEALLWHSE = aLLOWPAYTRACEALLWHSE;
	}

	public String getCashReportPermission() {
		return CASHREPORTPERMISSION;
	}

	public void setCashReportPermission(String cASHREPORTPERMISSION) {
		CASHREPORTPERMISSION = cASHREPORTPERMISSION;
	}

	public String getAllowSugContractPricApproval() {
		return ALLOWSUGCONTRACTPRICAPPROVAL;
	}

	public void setAllowSugContractPricApproval(String aLLOWSUGCONTRACTPRICAPPROVAL) {
		ALLOWSUGCONTRACTPRICAPPROVAL = aLLOWSUGCONTRACTPRICAPPROVAL;
	}

	public String getNewItemRequestEmail() {
		return NEWITEMREQUESTEMAIL;
	}

	public void setNewItemRequestEmail(String nEWITEMREQUESTEMAIL) {
		NEWITEMREQUESTEMAIL = nEWITEMREQUESTEMAIL;
	}

	public String getOverrideDeliveryCost() {
		return OVERRIDEDELIVERYCOST;
	}

	public void setOverrideDeliveryCost(String oVERRIDEDELIVERYCOST) {
		OVERRIDEDELIVERYCOST = oVERRIDEDELIVERYCOST;
	}

	public String getPinCode() {
		return PINCODE;
	}

	public void setPinCode(String pINCODE) {
		PINCODE = pINCODE;
	}

	public String getALLOWPODELIVERYPRINT() {
		return ALLOWPODELIVERYPRINT;
	}

	public void setAllowPODeliveryPrint(String aLLOWPODELIVERYPRINT) {
		ALLOWPODELIVERYPRINT = aLLOWPODELIVERYPRINT;
	}

	public String getTwoWayAuth() {
		return TWOWAYAUTH;
	}

	public void setTwoWayAuth(String tWOWAYAUTH) {
		TWOWAYAUTH = tWOWAYAUTH;
	}

	public String getUserType(){
	    return USERTYPE;
	  }


	public void setUserType(String userType){
	    USERTYPE = userType;

	  }


	public String getGroupId(){
	    return GROUPID;
	  }


	public void setGroupId(String groupId){
	    GROUPID = groupId;

	  }



	public String getUserInitials(){
	    return USERINITIALS;
	  }


	public void setUserInitials(String userInitials){
	    USERINITIALS = userInitials;

	  }



	public String getFirstName(){
	    return FIRSTNAME;
	  }


	public void setFirstName(String firstName){
	    FIRSTNAME = firstName;

	  }


	public String getMiddleName(){
	    return MIDDLENAME;
	  }


	public void setMiddleName(String middleName){
	    MIDDLENAME = middleName;

	  }

	public String getLastName(){
	    return LASTNAME;
	  }


	public void setLastName(String lastName){
	   LASTNAME = lastName;

	  }



	public String getAddress(){
	    return Utils.changeCarriageReturn(ADDRESS);
	  }
	public void setAddress(String address){
	    ADDRESS = address;
	     }
	public String getCity(){
	    return CITY;
	  }
	public void setCity(String city){
	    CITY = city;

	  }
	public String getState(){
	    return STATE;
	  }
	public void setState(String state){
	    STATE = state;

	  }
	public String getZip(){
	    return ZIP;
	  }

	public void setZip(String zip){
	    ZIP = zip;

	  }
	public String getPhone(){
	    return PHONE;
	  }
	public void setPhone(String phone){
	    PHONE = phone;

	  }
	public String getFax(){
	    return FAX;
	  }
	public void setFax(String fax){
	    FAX = fax;

	  }
	public String getMobile(){
	    return MOBILE;
	  }
	public void setMobile(String mobile){
	    MOBILE = mobile;

	  }

	public String getPassword(){
	    return PASSWORD;
	  }

	public void setPassword(String password){
	    PASSWORD = password;
	    }
	public String getPasswordExpiryDate(){
	    return PASSWORDEXPIRYDATE;
	  }


	public void setPasswordExpiryDate(String passwordExpiryDate){
	    PASSWORDEXPIRYDATE = passwordExpiryDate;

	  }
	public String getDefaultPrinter(){
	    return DEFAULTPRINTER;
	  }
	public void setDefaultPrinter(String defaultPrinter){
	    DEFAULTPRINTER = defaultPrinter;

	  }
	public String getDefaultWarehouse(){
	    return DEFAULTWAREHOUSE;
	  }
	public void setDefaultWarehouse(String defaultWarehouse){
	    DEFAULTWAREHOUSE = defaultWarehouse;

	  }
	public String getX(){
	    return X;
	  }

	public void setX(String x){
	    X = x;

	  }

	public String getStatus(){
	    return STATUS;
	  }

	public void setStatus(String status){
	    STATUS = status;

	  }

	public String getEmailId(){
	    return EMAILID;
	  }

	public void setEmailId(String emailId){
	    EMAILID = emailId;

	  }


	public String getShowRebateCost(){
	    return SHOWREBATECOST;
	  }

	public void setShowRebateCost(String showRebateCost){
	    SHOWREBATECOST = showRebateCost;

	}
	public String getDateOfBirth(){
	    return DATEOFBIRTH;
	  }

	public void setDateOfBirth(String dateOfBirth){
	    DATEOFBIRTH = dateOfBirth;

	  }

	public String getDefaultCompanyId(){
	    return DEFAULTCOMPANYID;
	  }

	public void setDefaultCompanyId(String defaultCompanyId){
	    DEFAULTCOMPANYID = defaultCompanyId;

	  }
	public String getAllowChangeReceiptWhse(){
	    return ALLOWCHANGERECEIPTWHSE;
	  }
	public void setAllowChangeReceiptWhse(String allowChangeReceiptWhse){
		ALLOWCHANGERECEIPTWHSE=allowChangeReceiptWhse;
	}
	public String getDefaultPersonalPrinter(){
	    return DEFAULTPERSONALPRINTER;
	  }
	public void setDefaultPersonalPrinter(String defaultPersonalPrinter){
		DEFAULTPERSONALPRINTER=defaultPersonalPrinter;
	}


	public String getEmpId(){
	    return EMPID;
	  }
	public void setEmpId(String empId){
		EMPID=empId;

	}
	public String getPhoneExt(){
	    return PHONEEXT;
	  }
	public void setPhoneExt(String phoneExt){
		PHONEEXT=phoneExt;

	}
	public String getSpeedDial(){
	    return SPEEDDIAL;
	  }
	public void setSpeedDial(String speedDial){
		SPEEDDIAL=speedDial;

	}
	public String getDeptId(){
	    return DEPTID;
	  }
	public void setDeptId(String deptId){
		DEPTID=deptId;

	}

	public String getCreditCardNo() {
		return CREDITCARDNO;
	}

	public void setCreditCardNo(String cREDITCARDNO) {
		CREDITCARDNO = cREDITCARDNO;
	}

	public String getEXPIRYDATE() {
		return EXPIRYDATE;
	}

	public void setEXPIRYDATE(String eXPIRYDATE) {
		EXPIRYDATE = eXPIRYDATE;
	}
	
	
  
}
