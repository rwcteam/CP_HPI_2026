package com.etechlogix.distribution.ad.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import javax.rmi.PortableRemoteObject;
import javax.transaction.UserTransaction;
import javax.ejb.*;
import java.io.*;
import java.util.*;
import java.sql.*;
import com.etechlogix.utils.*;
import com.etechlogix.distribution.utils.*;
import com.etechlogix.distribution.ad.entity.UserGroupMatrixHome;
import com.etechlogix.distribution.ad.entity.UserGroupMatrixPK;
import com.etechlogix.distribution.ad.entity.UserGroupMatrix;
import com.etechlogix.distribution.ad.db.UserGroupMatrixData;

public class UserGroupMatrixProcess implements Serializable{
    Utils u=null;
    DistUtils du=null;
    final String labelFileName="UserGroupMatrixLabel.properties";


// For Updating Record

public void updateRecord( HttpServletRequest request) throws Exception{

  boolean required=true;
  String userId="";
  String groupId="";

   javax.transaction.UserTransaction userTran=null;
   HttpSession session = request.getSession();
   du=DistUtils.getDistUtils(session);
   Context ctx = du.getInitialContext();
   Object ref = ctx.lookup("containerManaged.UserGroupMatrixHome");

	// Update the record.
  	try {
	userTran = (UserTransaction)ctx.lookup("javax.transaction.UserTransaction");
	userTran.begin();

	groupId =Utils.getParameterString("tmpGroupId",required,request);
        userId =Utils.getParameterString("tmpUserId",request);
        Utils.log("OLDGROUP......."+groupId);
        Utils.log("OLDUSER......."+userId);
	}
  catch (Exception e) {Utils.log("<P>UserGroupMatrix .doPost:",e);
      throw new ProcessingErrorException(e,labelFileName);
      }
   try {

     // Deleting record at present
      UserGroupMatrixHome home = (UserGroupMatrixHome) PortableRemoteObject.narrow(ref, UserGroupMatrixHome.class);
      // Find the record with the supplied Primary Key.
      UserGroupMatrixPK primaryKey = new UserGroupMatrixPK();
      primaryKey.GROUPID=groupId;
      primaryKey.USERID=userId;

      UserGroupMatrix userGroupMatrix = home.findByPrimaryKey(primaryKey);
      userGroupMatrix.remove();
      //Utils.log("Record Deleted in updateRecord");
        Utils.log("NEWGROUP......."+(Utils.getParameterString("groupId",required, request)));
        Utils.log("NEWUSER......."+(Utils.getParameterString("userId",required, request)));

      home.create(
       Utils.getParameterString("groupId",required, request)
      ,Utils.getParameterString("userId",required,request)
      );
      //Utils.log("Record Created in updateRecord");

      // Commit Transaction;
      userTran.commit();
      //Utils.log("Record Committed in updateRecord");
   }
    catch (Exception e) {
     // Rollback transaction in case an error occurs.
     try { userTran.rollback();}
     catch (Exception e2) {Utils.log(e.getMessage()+e2.getMessage());}
     Utils.log("<P>UserGroupMatrix.updateRecord: failed",e);
    throw new ProcessingErrorException(e, labelFileName);
}
}



  public void deleteRecord(HttpServletRequest request )
	  throws Exception, ServletException, IOException {
    boolean required=true;
    String userId="";
    String groupId="";

    javax.transaction.UserTransaction userTran=null;
    HttpSession session = request.getSession();
    du=DistUtils.getDistUtils(session);
    Context ctx = du.getInitialContext();
    Object ref = ctx.lookup("containerManaged.UserGroupMatrixHome");
     // Delete the record.
    try{
      userTran = (UserTransaction)ctx.lookup("javax.transaction.UserTransaction");
      userTran.begin();

      groupId =Utils.getParameterString("groupId",required,request);
      userId =Utils.getParameterString("userId",request);

      // Get Home interface for the UserGroupMatrix.
      UserGroupMatrixHome home = (UserGroupMatrixHome) PortableRemoteObject.narrow(ref, UserGroupMatrixHome.class);
      // Find the record with the supplied Primary Key.
      UserGroupMatrixPK primaryKey = new UserGroupMatrixPK();
      primaryKey.GROUPID=groupId;
      primaryKey.USERID=userId;
      UserGroupMatrix userGroupMatrix = home.findByPrimaryKey(primaryKey);
      userGroupMatrix.remove();
      // Commit Transaction;
      userTran.commit();
      //Utils.log("Record Deleted in deleteRecord");
       }
    catch (Exception e) {
     Utils.log("<P>UserGroupMatrixMaintenance.deleteRecord:",e);
     // Rollback transaction in case an error occurs.
     try { userTran.rollback();}
     catch (Exception e2) { Utils.log(e2.getMessage());}
     throw new ProcessingErrorException(e,labelFileName);
    }
   }


  public void createRecord(HttpServletRequest request )
	  throws SQLException, ServletException, IOException,Exception {

    boolean required=true;
    String userId="";
    String groupId="";
    javax.transaction.UserTransaction userTran=null;
    HttpSession session = request.getSession();
    du=DistUtils.getDistUtils(session);
    Context ctx = du.getInitialContext();
    Object ref = ctx.lookup("containerManaged.UserGroupMatrixHome");
    // Add the new record.
    try {
      userTran = (UserTransaction)ctx.lookup("javax.transaction.UserTransaction");
      userTran.begin(); // Start Transaction;
      // Get Home interface for the UserGroupMatrix.
      UserGroupMatrixHome home =(UserGroupMatrixHome) PortableRemoteObject.narrow(ref, UserGroupMatrixHome.class);
      home.create(
       Utils.getParameterString("groupId",required,request)
      ,Utils.getParameterString("userId",request)
      );
     // Commit Transaction;
      userTran.commit();
      //Utils.log("Record Created in createRecord");
    }
    catch(Exception e){
       try { 
    	   Utils.log("Error in add",e);
    	   userTran.rollback();}
        catch (Exception e2) {Utils.log(e2.getMessage());}
      throw new ProcessingErrorException(e,labelFileName);
      }
  }
}
