package com.etechlogix.distribution.ad.servlet;

import java.sql.*;
import java.util.*;
import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.*;

/**
 * Title: ETechUser.java
 * Description: Contains methods to query ETECHUSER table in
 *              distribution database.
 * Copyright:    Copyright (c) 2000
 * Company: eTechLogix
 * @author Azam
 * @version 1.0
 * updated on 23 july 2001 by asif
 * added getUserName()
 * @version 1.1
 */

public class ETechUser {

  private String groupId;
  private String defaultWarehouse;
  private String defaultPrinter;
  private String startupMenu;
  private String companyId;
  private String userName;
  private String defaultPersonalPrinter;
  private String showRebateCost;
  Connection con;

 /**
  * Constructor
  *
  * @param conn         Connection
  */

  public ETechUser(Connection cConnect) {
         con = cConnect;
  }
  public ETechUser() {

  }
  public boolean validateAndGetGroupId(String userId, String password, String companyId)
    throws SQLException , LoginException {

	  PreparedStatement pstmt1 = null;
	  ResultSet rs1 = null;
	  PreparedStatement pstmt2 = null;
	  ResultSet rs2 = null;

	  try {
		  String query="SELECT USERID, FIRSTNAME, MIDDLENAME, LASTNAME, GROUPID, PASSWORDEXPIRYDATE, STATUS, DEFAULTWAREHOUSE, DEFAULTPRINTER, DEFAULTPERSONALPRINTER, nvl(SHOWREBATECOST,'N') as SHOWREBATECOST FROM ETECHUSER WHERE (rtrim(USERID) = '" + userId + "') AND (rtrim(PASSWORD) = '" + password + "')";
		  //Utils.log(query);
		  pstmt1 = con.prepareStatement(query);
		  rs1 = pstmt1.executeQuery();

		  String rsGroupId;

		  if (rs1.next()) {
			  String rsUserId   = rs1.getString("USERID");
			  String rsStatus = rs1.getString("STATUS");
			  java.sql.Date rsPassExpDate = rs1.getDate("PASSWORDEXPIRYDATE");
			  //Utils.log(rsPassExpDate+":"+GregorianCalendar.getInstance().getTime());
			  groupId = rs1.getString("GROUPID");
			  defaultWarehouse = rs1.getString("DEFAULTWAREHOUSE");
			  defaultPrinter = rs1.getString("DEFAULTPRINTER");
			  userName=Utils.removeNull(rs1.getString("FIRSTNAME"))+" "+Utils.removeNull(rs1.getString("MIDDLENAME"))+" "+Utils.removeNull(rs1.getString("LASTNAME"));
			  defaultPersonalPrinter=rs1.getString("DEFAULTPERSONALPRINTER");
			  showRebateCost=rs1.getString("SHOWREBATECOST");
			  // check the default printer


			  // 1 - Check if the user account is active
			  if ((rsStatus == null) || (!(rsStatus.equals("A"))))
				  throw new LoginException("User Account Disabled", userId, password, 1);

			  // 2 - Check if account has expired
			  if (rsPassExpDate==null || rsPassExpDate.compareTo(GregorianCalendar.getInstance().getTime()) < 0)
				  throw new LoginException("User Account Expired", userId, password, 2);

			  if(defaultPrinter==null || defaultPrinter.equals(""))
				  throw new LoginException("Default printer is not set for the user",userId, password, 3);

			  /*if(defaultWarehouse==null || defaultWarehouse.equals(""))
				  throw new LoginException("Default warehouse is not set for the user",userId, password, 4);*/

			  if(defaultPersonalPrinter==null || defaultPersonalPrinter.equals(""))
				  throw new LoginException("Default personal printer is not set for the user",userId, password, 3);

		  }
		  else throw new LoginException("Login Credentials Not Recognized", userId, password, 0);

		  rs1.close ();

		  pstmt2 = con.prepareStatement("SELECT STATUS, COMPANYID, EXPIRYDATE, STARTUPMENU FROM ETECHUSERGROUP WHERE (rtrim(COMPANYID)='"+ companyId +"') and (rtrim(GROUPID) = '" + groupId + "')");
		  rs2 = pstmt2.executeQuery();
		  if (rs2.next()) {

			  String rsGroupStatus = rs2.getString("STATUS");
			  java.sql.Date rsGroupExpDate = rs2.getDate("EXPIRYDATE");
			  startupMenu = rs2.getString("STARTUPMENU");
			  companyId=rs2.getString("COMPANYID");
			  // 3 - Check if user group account is active
			  if ((rsGroupStatus == null) || (!(rsGroupStatus.equals("A"))))
				  throw new LoginException("User Group Account Disabled", userId, password, 5);

			  // 4 - Check if Group is expired
			  if (rsGroupExpDate==null ||  rsGroupExpDate.compareTo(GregorianCalendar.getInstance().getTime()) < 0)
				  throw new LoginException("User Group Account Expired", userId, password, 6);
		  }
		  else
			  throw new LoginException("Login Credentials Not Recognized for This Company", userId, password, 0);

	  } finally {
		  try { if (rs1!=null) rs1.close(); } catch (Exception e) {}
		  try { if (pstmt1!=null) pstmt1.close(); } catch (Exception e) {}
		  try { if (rs2!=null) rs2.close(); } catch (Exception e) {}
		  try { if (pstmt2!=null) pstmt2.close(); } catch (Exception e) {}
	  }

	  return true;
    }

  public void setGroupId(String newGroupId) {
    groupId = newGroupId;
  }
  public String getGroupId() {
    return groupId;
  }

  public void setDefaultWarehouse(String newDefaultWarehouse) {
    defaultWarehouse = newDefaultWarehouse;
  }
  public String getDefaultWarehouse() {
    return defaultWarehouse;
  }

  public void setShowRebateCost(String newShowRebateCost) {
	    showRebateCost = newShowRebateCost;
	  }
	  public String getShowRebateCost() {
	    return showRebateCost;
	  }

  public void setDefaultPrinter(String newDefaultPrinter) {
    defaultPrinter = newDefaultPrinter;
  }
  public String getDefaultPrinter() {
    return defaultPrinter;
  }
  public void setDefaultPersonalPrinter(String newDefaultPersonalPrinter) {
	    defaultPersonalPrinter = newDefaultPersonalPrinter;
	  }
	  public String getDefaultPersonalPrinter() {
	    return defaultPersonalPrinter;
	  }
  public void setStartupMenu(String newStartupMenu) {
    startupMenu = newStartupMenu;
  }
  public String getStartupMenu() {
    return startupMenu;
  }
  public void setCompanyId(String newCompanyId) {
    companyId= newCompanyId;
  }
  public String getCompanyId() {
    return companyId;
  }

	public String getUserName(){
	  return userName;
	}
	
	public String getCompanyPage(String compId)throws SQLException, RecordNotFoundException, Exception
	{
		DistUtils du=new DistUtils();
		Connection localCon = null;
		Statement pre=null;
		ResultSet rs = null;
		
		try {			
			String query="select companyPage from companyparameter where companyId='"+compId+"'";
			localCon = du.getDataConnection();
			pre=localCon.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			rs = pre.executeQuery(query);
			
			if(rs.next())
			{
				String companyPage=rs.getString("companyPage");
				return companyPage;
			}
			else
			{
				throw new RecordNotFoundException("NF");
			}
		} finally {
			try { if (rs!=null) rs.close(); } catch (Exception e) {}
	    	try { if (pre!=null) pre.close(); } catch (Exception e) {}
	    	try { if (localCon!=null) localCon.close(); } catch (Exception e) {}
		}
	}
 
}