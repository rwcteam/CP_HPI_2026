/*
Dist Utils

Last update: 29-Jume-2001 @ asif
method added: 	public Hashtable getDataFromQuery(String query)
Version 1.1

Last update: 02-July-2001 @ asif
method added: 	public String getData(Hashtable hash,String formFieldName,int pos)
Version 1.2

Last update: 10-July-2001 @ azam
method added: 	public String getFieldInfo(String Query)
Version 1.3

Last update: 19-July-2001 @ asif
method added: 	public Vector getFieldInfo(String Query)
Version 1.4

Last update: 25-July-2001 @ asif
method added: 	public static Vector  warehouseValues(String companyId)
Version 1.5

Last update: 18-August-2001 @ asif
method added: 	public Hashtable getDataFromHashtable(Hashtable uomRequest){
Version 1.6


Last update: 02-Feb-2002 @ asif
method added getUtils(HttpSession session);
method added getCompanyId(HttpSession session);
Version 1.7


Last update: 30-Dec-2002 @ Sanjeev
method added fetchTypes();
Version 1.7

Last update: 16-March-2004 @ Khalid
method added getImageLocation(String location)

Last update: 29-March-2004 @ Khalid
method added marketValues(String companyId)

Last update: 28-April 2004 @ Sanjeev
method getCurrentDateAddedMonth(java.sql.Date currentDate,noOfMonths)

Last update: 31-July 2004 @ Khalid
method departmentValues(String companyId)
 */

package com.etechlogix.distribution.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.TimeZone;
import java.util.Vector;
import java.math.*;
import java.text.SimpleDateFormat;  
import javax.ejb.EJBException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import javax.sql.DataSource;

import org.apache.commons.lang.StringUtils;
import org.apache.lucene.analysis.WhitespaceAnalyzer;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import com.etechlogix.utils.InvalidParameterException;
import com.etechlogix.utils.ParameterNotFoundException;
import com.etechlogix.utils.ProcessingErrorException;
import com.etechlogix.utils.Utils;
import org.json.*;

import java.util.Date;
import java.text.SimpleDateFormat;


public class DistUtils   implements Serializable, DistUtilsInterface{

	private Properties SystemDefaults;
	private String companyId = "";
	private String propertiesFile;
	private Utils u;
	private Vector printerNames;
	private Vector printerAddress;
	private Vector printerLocation;
	private Vector printerId;
	private Vector printerTypes;

	private static Map productSubstitutionMap;

	/**
	 * Creates a DistUtils object and loads the default system properties file
	 * eTechLogix.properties.
	 **/
	public DistUtils() throws Exception {
		InputStream in = null;

		try {
			
			//in = this.getClass().getClassLoader().getResourceAsStream("eTechLogix.properties");
			in=DistUtils.class.getResourceAsStream("eTechLogix.properties"); //tomcat
			SystemDefaults = new Properties();
			SystemDefaults.load(in);
			printerNames = new Vector(1, 1);
			printerAddress = new Vector(1, 1);
			printerLocation = new Vector(1, 1);
			printerId = new Vector(1, 1);
			printerTypes = new Vector(1, 1);
			
		} catch (Exception e) {
			System.out.println("ERROR IN DistUtils...Loading eTechLogix file +"+e);
			throw new Exception("ERROR IN DistUtils...Loading eTechLogix file",	e);
		} finally {
			if (in != null)
				in.close();
		}
	} 

	/**
	 * creates a DistUtils object and loads properties file specified by
	 * parameter "propertiesFile".
	 **/
	public DistUtils(String websiteId) throws Exception {
		InputStream in = null;
		Utils.log("websiteId::="+websiteId);
		try {
			companyId = websiteId;
			propertiesFile = websiteId + ".properties";
			in = this.getClass().getClassLoader().getResourceAsStream(propertiesFile); 
			SystemDefaults = new Properties();
			SystemDefaults.load(in);
		} catch (Exception e) {
			throw new Exception("ERROR IN DistUtils...Loaging eTechLogix file",
					e);
		} finally {
			if (in != null)
				in.close();
		}
	}

	public int getSearchLimit() {
		int recordLimit = 0;
		try {
			recordLimit = Integer.parseInt(SystemDefaults
					.getProperty("RecordLimit"));
		} catch (NumberFormatException nfe) {
			recordLimit = 500;
		}
		return recordLimit;
	}

	public int getPrintLimit() {
		int printLimit = 0;
		try {
			printLimit = Integer.parseInt(SystemDefaults
					.getProperty("PrintLimit"));
		} catch (NumberFormatException nfe) {
			printLimit = 500;
		}
		return printLimit;
	}
	
	public String getMuduleType(String url){
		String moduleType = "";
		if(url != null && url.length() > 4){
			moduleType = url.substring(1,3);
		}
		return moduleType.toUpperCase();
	}

	// //
	// // getting connection from the weblogic pool.
	// /

	public Connection getConnection() throws Exception {
		try {
			
			
		    
			///class javax.naming.InitialContext cannot be cast to class java.lang.String 
			//(javax.naming.InitialContext is in module java.naming of loader 'bootstrap'; 
			//java.lang.String is in module java.base of loader 'bootstrap')
			TimeZone timeZone = TimeZone.getTimeZone("America/Phoenix");
		     TimeZone.setDefault(timeZone);
			
			Context initialContext = new InitialContext();
			Context environmentContext = (Context)initialContext.lookup("java:comp/env");
			String  dataResourceName = "eTechLogixPool";
		    DataSource dataSource = (DataSource)environmentContext.lookup(dataResourceName);
		    org.apache.tomcat.jdbc.pool.DataSource tomcatDs =	    (org.apache.tomcat.jdbc.pool.DataSource) dataSource;

	    	Utils.log(
	    		    "Active Connection=" + tomcatDs.getActive()
	    		    + ", Idle=" + tomcatDs.getIdle()
	    		    + ", Size=" + tomcatDs.getSize()
	    		    + ", MaxActive=" + tomcatDs.getMaxActive()
	    		    + ", WaitCount=" + tomcatDs.getWaitCount()
	    		);
	    	
	        Connection con = dataSource.getConnection();
			
	//Utils.log("Connected to Etech Pool");
	         
	         
			
			//Class.forName("weblogic.jdbc.pool.Driver").newInstance();
			//Connection con =

			//DriverManager.getConnection("jdbc:weblogic:pool:eTechLogixPool",					null);

			return con;
		} catch (Exception e) {
			Utils.log("Caught in the DistUtils.getConnection ", e);
			throw e;
		}
	}
	
	// //
		// // getting connection from the weblogic pool Pro2DataSource.
		// /
		
		public Connection getDataConnectionPro2DataSource() throws Exception {
			Context initCtx = null;
			// InitialContext initCtx=null;
			try { //tomcat
				Context initialContext = new InitialContext();
				Context environmentContext = (Context)initialContext.lookup("java:comp/env");
				String  dataResourceName = "Pro2DataSource";
			    DataSource dataSource = (DataSource)environmentContext.lookup(dataResourceName);
		        Connection con = dataSource.getConnection();
				
				return con;
			} catch (NamingException ne) {
				Utils.logError("UNABLE to get a connection from Pro2DataSource!..", ne);
				log("Please make sure that you have setup the connection pool properly");
				throw new EJBException(ne);
			} finally {
				try {
					if (initCtx != null)
						initCtx.close();
				} catch (NamingException ne) {
					log("Error closing context: " + ne);
					throw new EJBException(ne);
				}
			}
		}

	// //
	// // getting connection from the weblogic datasource.
	// /

	public Connection getDataConnection(Context context) throws Exception {
		try {
			DataSource ds = (javax.sql.DataSource) context
					.lookup("eTechDataSource");
			return ds.getConnection();
		} catch (NamingException ne) {
			Utils.logError("UNABLE to get a connection from eTechLogixPool!-", ne);
			Utils.logError("Please make sure that you have setup the connection pool properly");
			throw new EJBException(ne);
		}		
	}
// tomcat
	public Connection getDataConnection() throws Exception {
		Context initCtx = null;
		// InitialContext initCtx=null;
		try {
			// Added for reg2 cloud to solve - java ORA-01882: timezone region not found
			TimeZone timeZone = TimeZone.getTimeZone("America/Phoenix");
		     TimeZone.setDefault(timeZone);
		     // ENd
			Context initialContext = new InitialContext();
			Context environmentContext = (Context)initialContext.lookup("java:comp/env");
			String  dataResourceName = "eTechLogixPool";
		    DataSource dataSource = (DataSource)environmentContext.lookup(dataResourceName);
		    
		    org.apache.tomcat.jdbc.pool.DataSource tomcatDs =	    (org.apache.tomcat.jdbc.pool.DataSource) dataSource;

	    	Utils.log(
	    		    "Active Data Connection=" + tomcatDs.getActive()
	    		    + ", Idle=" + tomcatDs.getIdle()
	    		    + ", Size=" + tomcatDs.getSize()
	    		    + ", MaxActive=" + tomcatDs.getMaxActive()
	    		    + ", WaitCount=" + tomcatDs.getWaitCount()
	    		);
	    	
		   
		    
	        Connection con = dataSource.getConnection();
	        //Utils.log("Connected to Etech getDataConnection");
	        return con;
		} catch (Exception ne) {
			Utils.logError("UNABLE to get a connection from eTechLogixPool!!", ne);
			log("Please make sure that you have setup the connection pool properly");
			throw new Exception(ne);
		} finally {
			try {
				if (initCtx != null)
					initCtx.close();
			} catch (NamingException ne) {
				log("Error closing context: " + ne);
				throw new Exception(ne);
			}
		}
	}
	
	public Connection getPro2DataConnection() throws Exception {
		Context initCtx = null;
		// InitialContext initCtx=null;
		try {
			// initCtx=new InitialContext();
			/* tomcat
			initCtx = getInitialContext();
			DataSource ds = (javax.sql.DataSource) initCtx
					.lookup("Pro2DataSource");
			return ds.getConnection();
			*/
			Context initialContext = new InitialContext();
			Context environmentContext = (Context)initialContext.lookup("java:comp/env");
			String  dataResourceName = "Pro2DataSource";
		    DataSource dataSource = (DataSource)environmentContext.lookup(dataResourceName);
	        Connection con = dataSource.getConnection();
			
			return con;
		} catch (NamingException ne) {
			Utils.logError("UNABLE to get a connection from Pro2DataSource!", ne);
			log("Please make sure that you have setup the connection pool properly");
			throw new EJBException(ne);
		} finally {
			try {
				if (initCtx != null)
					initCtx.close();
			} catch (NamingException ne) {
				log("Error closing context: " + ne);
				throw new EJBException(ne);
			}
		}
	}

	
	private void log(String s) {
		Utils.log(s);
	}

	//
	// check the record exist?
	//
	
	public boolean isRecordExists(Context context, String tableName, Hashtable primKey)
			throws Exception {
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		boolean found = false;

		try {
			String query = "select count(*) as count from " + tableName
					+ " where ";
			Enumeration enum1 = primKey.keys();
			String where = "";
			while (enum1.hasMoreElements()) {
				String key = (String) enum1.nextElement();
				String value = (String) primKey.get(key);
				if (where.equals(""))
					where += key + "='" + value + "'";
				else
					where += " and " + key + "='" + value + "'";
			}
			query += where;

			con = getDataConnection(context);

			ps = con.prepareStatement(query);
			rs = ps.executeQuery();

			rs.next();
			int count = rs.getInt("count");
			if (count > 0)
				found = true; // record found
			else
				found = false;
		} catch (Exception e) {
			throw new Exception("Caught in the isRecordExists: " + e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}
		return found;		
	}
	
	public boolean isRecordExists(String tableName, Hashtable primKey)
			throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		boolean found = false;

		try {
			String query = "select count(*) as count from " + tableName
					+ " where ";
			Enumeration enum1 = primKey.keys();
			String where = "";
			while (enum1.hasMoreElements()) {
				String key = (String) enum1.nextElement();
				String value = (String) primKey.get(key);
				if (where.equals(""))
					where += key + "='" + value + "'";
				else
					where += " and " + key + "='" + value + "'";
			}
			query += where;

			con = getDataConnection();

			ps = con.prepareStatement(query);
			rs = ps.executeQuery();
			Utils.log("query>>>>weweew>>>>>>"+ query);
			rs.next();
			int count = rs.getInt("count");
			if (count > 0)
				found = true; // record found
			else
				found = false;
		} catch (Exception e) {
			throw new Exception("Caught in the isRecordExists: " + e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return found;
	}

	// pass the query and get the particular field Information

	public String getFieldInfo(Context context, String query) throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		String fieldInfo = "";
		try {
			con = getDataConnection(context);
			ps = con.prepareStatement(query);
			rs = ps.executeQuery();
			if (rs.next()) {
				fieldInfo = Utils.removeNull(rs.getString(1));
			}
			// Utils.log(Query);
		} catch (Exception e) {
			Utils.log(query);
			throw new Exception("Caught in the getFieldInfo: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;		
	}

	public String getFieldInfo(String Query) throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		String fieldInfo = "";
		try {
			con = getDataConnection();
			ps = con.prepareStatement(Query);
			rs = ps.executeQuery();
			if (rs.next()) {
				fieldInfo = Utils.removeNull(rs.getString(1));
			}
			// Utils.log(Query);
		} catch (Exception e) {
			Utils.log(Query);
			throw new Exception("Caught in the getFieldInfo: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;
	}
	
	public String getFieldInfoPro2(String Query) throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		String fieldInfo = "";
		try {
			con = getPro2DataConnection();
			ps = con.prepareStatement(Query);
			rs = ps.executeQuery();
			if (rs.next()) {
				fieldInfo = Utils.removeNull(rs.getString(1));
			}
			// Utils.log(Query);
		} catch (Exception e) {
			Utils.log(Query);
			throw new Exception("Caught in the getFieldInfoPro2: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;
	}
	
	public String getFieldString(String Query) throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		String fieldInfo = "";
		try {
			con = getDataConnection();
			ps = con.prepareStatement(Query);
			rs = ps.executeQuery();
			while (rs.next()) {
				fieldInfo += Utils.removeNull(rs.getString(1))+",";
			}
			if(fieldInfo.indexOf(",")!=-1){
				fieldInfo=fieldInfo.substring(0,fieldInfo.length()-1);
			}
			// Utils.log(Query);
		} catch (Exception e) {
			Utils.log(Query);
			throw new Exception("Caught in the getFieldInfo: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;
	}

	// / The all data from the reslt set and store it into the vector
	// /

	public Hashtable getDataFromQuery(Context context, String query) throws Exception {
		Connection con = null;
		PreparedStatement pst = null;
		ResultSet rs = null;
		ResultSetMetaData rsMeta = null;
		try {
			con = getDataConnection(context);
			pst = con.prepareStatement(query);
			rs = pst.executeQuery();
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			Hashtable hash = new Hashtable();
			int i = 1;
			String val = "";
			String name = "";
			Vector temp = null;
			String type = "";
			while (rs.next()) {
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					type = rsMeta.getColumnTypeName(k);
					if (type.equals("DATE"))
						val = Utils.changeDateFormat(rs.getDate(k));
					else
						val = Utils.removeNull(rs.getString(k));
					if (i == 1) {
						temp = new Vector(10, 2);
						temp.add(i - 1, val);
						hash.put(name, temp);
					} else {
						temp = (Vector) hash.get(name);
						temp.add(i - 1, val);
						hash.put(name, temp);
					}
				}
				i++; // second record
			}
			return hash;
		} catch (Exception e) {
			Utils.log("Error in getDataFromQuery()", e);
			throw new ProcessingErrorException(e);
		} finally {
			Utils.close(rs);
			Utils.close(pst);
			Utils.close(con);
		}		
	}
	
	public Hashtable getDataFromQuery(String query) throws Exception {

		Connection con = null;
		PreparedStatement pst = null;
		ResultSet rs = null;
		ResultSetMetaData rsMeta = null;
		try {
			con = getDataConnection();
			pst = con.prepareStatement(query);
			rs = pst.executeQuery();
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			Hashtable hash = new Hashtable();
			int i = 1;
			String val = "";
			String name = "";
			Vector temp = null;
			String type = "";
			
			while (rs.next()) {
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					type = rsMeta.getColumnTypeName(k);
					if (type.equals("DATE"))
						val = Utils.changeDateFormat(rs.getDate(k));
					else
						val = Utils.removeNull(rs.getString(k));

					if (i == 1) {
						temp = new Vector(10, 2);
						temp.add(i - 1, val);
						hash.put(name, temp);
					} else {
						temp = (Vector) hash.get(name);
						temp.add(i - 1, val);
						hash.put(name, temp);
					}
				}
				i++; // second record
			}

			return hash;
		} catch (Exception e) {
			Utils.logError("getDataFromQuery() " + e.getMessage() + " query: " + query, e);
			throw new ProcessingErrorException(e);
		} finally {
			Utils.close(rs);
			Utils.close(pst);
			Utils.close(con);
		}
	}
	
	public Hashtable getDataFromQueryPro2(String query) throws Exception {

		Connection con = null;
		PreparedStatement pst = null;
		ResultSet rs = null;
		ResultSetMetaData rsMeta = null;
		try {
			con = getPro2DataConnection();
			pst = con.prepareStatement(query);
			rs = pst.executeQuery();
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			Hashtable hash = new Hashtable();
			int i = 1;
			String val = "";
			String name = "";
			Vector temp = null;
			String type = "";			
			while (rs.next()) {
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					type = rsMeta.getColumnTypeName(k);
					if (type.equals("DATE"))
						val = Utils.changeDateFormat(rs.getDate(k));
					else
						val = Utils.removeNull(rs.getString(k));
					if (i == 1) {
						temp = new Vector(10, 2);
						temp.add(i - 1, val);
						hash.put(name, temp);
					} else {
						temp = (Vector) hash.get(name);
						temp.add(i - 1, val);
						hash.put(name, temp);
					}
				}
				i++; // second record
			}

			return hash;
		} catch (Exception e) {
			Utils.logError("getDataFromQuery() " + e.getMessage() + " query: " + query, e);
			throw new ProcessingErrorException(e);
		} finally {
			Utils.close(rs);
			Utils.close(pst);
			Utils.close(con);
		}
	}
	
	public ArrayList<String> getDataFromQueryInArrayList(String query) throws Exception {

		Connection con = null;
		PreparedStatement pst = null;
		ResultSet rs = null;
		ResultSetMetaData rsMeta = null;
		try {
			con = getDataConnection();
			pst = con.prepareStatement(query);
			rs = pst.executeQuery();
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			ArrayList<String> list = new ArrayList<String>();
			int i = 1;
			String val = "";
			String name = "";
			Vector temp = null;
			String type = "";
			
			while (rs.next()) {
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					type = rsMeta.getColumnTypeName(k);
					if (type.equals("DATE"))
						val = Utils.changeDateFormat(rs.getDate(k));
					else
						val = Utils.removeNull(rs.getString(k));

					list.add(val);
					/*if (i == 1) {
						temp = new Vector(10, 2);
						temp.add(i - 1, val);
						hash.put(name, temp);
					} else {
						temp = (Vector) hash.get(name);
						temp.add(i - 1, val);
						hash.put(name, temp);
					}*/
				}
				i++; // second record
			}

			return list;
		} catch (Exception e) {
			Utils.logError("getDataFromQuery() " + e.getMessage() + " query: " + query, e);
			throw new ProcessingErrorException(e);
		} finally {
			Utils.close(rs);
			Utils.close(pst);
			Utils.close(con);
		}
	}
	
	
	/* Methoud for multiple uom*/
	public ArrayList getDataFromQueryForUOM(String query) throws Exception {

		  Connection con = null;
		  PreparedStatement pst = null;
		  ResultSet rs = null;
		  ResultSetMetaData rsMeta = null;
		  ArrayList uomlist = new ArrayList();
		  try {
		   con = getDataConnection();
		   pst = con.prepareStatement(query);
		   rs = pst.executeQuery();
		   rsMeta = rs.getMetaData();
		   int coulmns = rsMeta.getColumnCount();
		   Hashtable hash = null;
		   int i = 1;
		   String val = "";
		   String name = "";
		   Vector temp = null;
		   String type = "";

		   while (rs.next()) {
		    hash = new Hashtable();
		    for (int k = 1; k <= coulmns; k++) {
		     name = rsMeta.getColumnName(k);
		     type = rsMeta.getColumnTypeName(k);
		     if (type.equals("DATE"))
		      val = Utils.changeDateFormat(rs.getDate(k));
		     else
		      val = Utils.removeNull(rs.getString(k));

		     temp = new Vector();
		     temp.add(0, val);
		     hash.put(name, temp);
		    }
		    uomlist.add(hash);   // second record
		   }

		   return uomlist;
		  } catch (Exception e) {
		   Utils.logError("getDataFromQuery() " + e.getMessage() + " query: " + query, e);
		   throw new ProcessingErrorException(e);
		  } finally {
		   Utils.close(rs);
		   Utils.close(pst);
		   Utils.close(con);
		  }
		 }

	/* method to get printer names from printer table */
	public void setPrinterNames() throws Exception {
		Statement st = null;
		Connection con = null;
		ResultSet rs = null;
		try {
			if (printerId != null) {
				printerId.removeAllElements();
				printerAddress.removeAllElements();
				printerLocation.removeAllElements();
				printerNames.removeAllElements();
				printerTypes.removeAllElements();
			}
			con = getDataConnection();
			st = con.createStatement();
			rs = st
					.executeQuery("select * from printer where printername is not null  and printerType='L' ORDER BY warehouse, PRINTERID");
			while (rs.next()) {
				printerNames.add(rs.getString("printername"));
				printerAddress.add(rs.getString("printeraddress"));
				printerLocation.add(rs.getString("printerlocation"));
				printerId.add(rs.getString("printerid"));
				printerTypes.add(rs.getString("printerType"));
			}
		} catch (SQLException se) {
			throw new Exception("Caught in PrintCustomer:print Query" + se);
		} finally {
			if (con != null) {
				rs.close();
				st.close();
				con.close();
			}
		}
	}

	public void setPrinterNames(String printerType) throws Exception {
		Statement st = null;
		Connection con = null;
		ResultSet rs = null;
		try {
			if (printerId != null) {
				printerId.removeAllElements();
				printerAddress.removeAllElements();
				printerLocation.removeAllElements();
				printerNames.removeAllElements();
				printerTypes.removeAllElements();
			}
			con = getDataConnection();
			st = con.createStatement();
			rs = st
					.executeQuery("select * from printer where printername is not null  and printerType='D' ORDER BY warehouse, PRINTERID");
			while (rs.next()) {
				printerNames.add(rs.getString("printername"));
				printerAddress.add(rs.getString("printeraddress"));
				printerLocation.add(rs.getString("printerlocation"));
				printerId.add(rs.getString("printerid"));
				printerTypes.add(rs.getString("printerType"));
			}
		} catch (SQLException se) {
			throw new Exception("Caught in PrintCustomer:print Query" + se);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
	}

	public void setPrinterNamesAll() throws Exception {
		Statement st = null;
		Connection con = null;
		ResultSet rs = null;
		try {
			if (printerId != null) {
				printerId.removeAllElements();
				printerAddress.removeAllElements();
				printerLocation.removeAllElements();
				printerNames.removeAllElements();
				printerTypes.removeAllElements();
			}
			con = getDataConnection();
			st = con.createStatement();
			rs = st
					.executeQuery("select * from printer where printername is not null  ORDER BY warehouse, PRINTERID");
			while (rs.next()) {
				printerNames.add(rs.getString("printername"));
				printerAddress.add(rs.getString("printeraddress"));
				printerLocation.add(rs.getString("printerlocation"));
				printerId.add(rs.getString("printerid"));
				printerTypes.add(rs.getString("printerType"));
			}
		} catch (SQLException se) {
			throw new Exception("Caught in PrintCustomer:print Query" + se);
		} finally {
			if (con != null) {
				rs.close();
				st.close();
				con.close();
			}
		}
	}

	/**
	 * Returns Printer Names
	 * 
	 * @param in
	 *            void
	 * @param out
	 *            Vector. *
	 */

	public Vector getPrinterNames() {
		return printerNames;
	}

	public Vector getPrinterAddress() {
		return printerAddress;
	}

	public Vector getPrinterLocation() {
		return printerLocation;
	}

	public Vector getPrinterId() {
		return printerId;
	}

	public Vector getPrinterTypes() {
		return printerTypes;
	}

	/*
	 * To fetch data from the vector; which is bind with the name in hashtable
	 * 
	 * @ return String
	 * 
	 * @ Exception
	 */

	public String getData(Hashtable hash, String formFieldName, int pos) {

		Vector vec = null;
		vec = (Vector) hash.get(formFieldName);
		String value = "";
		if (vec != null) {
			value = (String) vec.get(pos);
		} else
			value = "";
		return value;
	}

	/*
	 * 
	 * @return String[]
	 * 
	 * @Exception java.lang.Exception
	 * 
	 * @param String
	 */

	// pass the query and get the particular field Information
	
	public Vector getFieldInfo(Context context, String query, int noOfFields) throws Exception {
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		Vector fieldInfo = new Vector(3, 1);
		try {
			con = getDataConnection(context);
			ps = con.prepareStatement(query);
			rs = ps.executeQuery();
			if (rs.next()) {
				for (int i = 0; i < noOfFields; i++) {
					fieldInfo.add(i, rs.getString(i + 1));
				}
			} else {
				for (int i = 0; i < noOfFields; i++) {
					fieldInfo.add(i, "");
				}
			}
		} catch (Exception e) {
			throw new Exception("Caught in the getFieldInfo: " + e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;
		
	}

	public Vector getFieldInfo(String Query, int noOfFields) throws Exception {

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		Vector fieldInfo = new Vector(3, 1);
		try {
			con = getDataConnection();
			ps = con.prepareStatement(Query);
			rs = ps.executeQuery();
			if (rs.next()) {
				for (int i = 0; i < noOfFields; i++) {
					fieldInfo.add(i, rs.getString(i + 1));
				}
			} else {
				for (int i = 0; i < noOfFields; i++) {
					fieldInfo.add(i, "");
				}
			}
		} catch (Exception e) {
			throw new Exception("Caught in the getFieldInfo: " + e);
		} finally {
			Utils.close(rs);
			Utils.close(ps);
			Utils.close(con);
		}

		return fieldInfo;
	}

	/*
	 * This function is used to get the warehouse list from the warehouse tabel
	 * 
	 * @param String comapanyId --used in the where clause of query
	 * 
	 * @return Vector -- It will rerun the list of warehouse
	 * 
	 * @exception java.lang.Exception
	 */

	public Vector warehouseValues(Context context, String companyId) throws Exception {
		String warehouseName = "";
		Vector warehouseValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection(context);
			st = con.createStatement();
			String query = "Select * from warehouse where companyId='"
					+ companyId + "' AND NVL(TYPE,'A')='A'";
			rs = st.executeQuery(query);
			Utils.log(" INSIDE WAREHOUSEVALUES !" + rs + "#");
			if (rs.next()) {
				do {
					warehouseName = Utils.removeNull(rs.getString("warehouse"));
					warehouseValues.add(warehouseName);
				} while (rs.next());
			} else {
				throw new Exception("No warehouse present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return warehouseValues;
		
	}
	
	public Vector warehouseValuesAgility() throws Exception {
		String warehouseName = "";
		Vector warehouseValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getPro2DataConnection();
			st = con.createStatement();
			String query = "Select system_id from system_file";
			rs = st.executeQuery(query);
			Utils.log(" INSIDE WAREHOUSEVALUES !" + rs + "#");
			if (rs.next()) {
				do {
					warehouseName = Utils.removeNull(rs.getString("system_id"));
					warehouseValues.add(warehouseName);
				} while (rs.next());
			} else {
				throw new Exception("No warehouse present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return warehouseValues;
		
	}

	public Vector warehouseValues(String companyId) throws Exception {

		String warehouseName = "";
		Vector warehouseValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from warehouse where companyId='"
					+ companyId + "' AND NVL(TYPE,'A')='A'";
			rs = st.executeQuery(query);
			Utils.log(" INSIDE WAREHOUSEVALUES !" + rs + "#");
			if (rs.next()) {
				do {
					warehouseName = Utils.removeNull(rs.getString("warehouse"));
					warehouseValues.add(warehouseName);
				} while (rs.next());
			} else {
				throw new Exception("No warehouse present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return warehouseValues;

	}
	public Vector warehouseValuesShipSO(String companyId) throws Exception {

		String warehouseName = "";
		Vector warehouseValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from warehouse where companyId='"
					+ companyId + "' AND NVL(TYPE,'A')='A'  and nvl(CONSIGNMENT,'N')='N' ";
			rs = st.executeQuery(query);
			Utils.log(" INSIDE WAREHOUSEVALUES !" + rs + "#");
			if (rs.next()) {
				do {
					warehouseName = Utils.removeNull(rs.getString("warehouse"));
					warehouseValues.add(warehouseName);
				} while (rs.next());
			} else {
				throw new Exception("No warehouse present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return warehouseValues;

	}
	public Vector warehouseValuesInitWhseSo(String companyId) throws Exception {

		String warehouseName = "";
		Vector warehouseValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from warehouse where companyId='"
					+ companyId + "' AND NVL(TYPE,'A')='A' and nvl(validSO,'N')='Y' and nvl(CONSIGNMENT,'N')='N'";
			rs = st.executeQuery(query);
			Utils.log(" INSIDE WAREHOUSEVALUES !" + rs + "#");
			if (rs.next()) {
				do {
					warehouseName = Utils.removeNull(rs.getString("warehouse"));
					warehouseValues.add(warehouseName);
				} while (rs.next());
			} else {
				throw new Exception("No warehouse present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return warehouseValues;

	}
	/**
	 * Selecting the child class for a given class and vice versa. It check
	 * upClass param. If it is "Y" means system will select all those classes
	 * who has the classlevel puls one for the given classlevel
	 * 
	 * @param HttpServletRequest
	 *            request
	 * @return Vector
	 * @exception java.lang.Exception
	 */
	
	public Vector classValues(Context context, HttpServletRequest request) throws Exception {
		Utils.logEntry("DistUtils.classValues");
		String companyId = "";
//		String productNo = "";
		String classMaster = "";
		String query = "";
		String upClass = ""; // for the parent class
		Vector classValues = new Vector(1, 1);
		Connection con = null;
		HttpSession session = request.getSession(false);

		companyId = (String) session.getAttribute("companyId");
		if (companyId == null)
			throw new Exception(u.getErrorMessage("LOG-01"));

		String parentId = "";
		parentId = request.getParameter("parentId");

		upClass = Utils.getParameterCheck("upClass", request);

		if (upClass.equals("Y")) {
			if (parentId == null) {
				throw new Exception("The classed shown are at the top level");
			}
			query = "select classId from inventoryclass where classlevel="
					+ "(select classlevel-1 from inventoryclass where classId='"
					+ parentId + "' and companyId='" + companyId
					+ "') and companyId='" + companyId + "'";
		} else {
			query = "Select classId from inventoryclass where parentclassid";

			if (parentId == null) {
				query += " is null";
			} else {
				query += "='" + parentId + "'";
			}
			query += " and companyId='" + companyId + "'";
		}
		Utils.logInfo("Query ::: : "+query);

		Statement st = null;
		ResultSet rs = null;
		try {
			con = getDataConnection(context);
			st = con.createStatement();
			rs = st.executeQuery(query);
			while (rs.next()) {
				classMaster = Utils.removeNull(rs.getString("classid"));
				classValues.add(classMaster);
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		Utils.logExit("DistUtils.classValues");
		return classValues;	
	}
	
	public Vector classValues(HttpServletRequest request) throws Exception {

		// u.log("InventoryWarehouseProcess:inside classValues");
		String companyId = "";
//		String productNo = "";
		String classMaster = "";
		String query = "";
		String upClass = ""; // for the parent class
		Vector classValues = new Vector(1, 1);
		Connection con = null;
		HttpSession session = request.getSession(false);

		companyId = (String) session.getAttribute("companyId");
		if (companyId == null)
			throw new Exception(u.getErrorMessage("LOG-01"));

		String parentId = "";
		parentId = request.getParameter("parentId");

		upClass = Utils.getParameterCheck("upClass", request);

		if (upClass.equals("Y")) {
			if (parentId == null) {
				throw new Exception("The classed shown are at the top level");
			}
			query = "select classId from inventoryclass where classlevel="
					+ "(select classlevel-1 from inventoryclass where classId='"
					+ parentId + "' and companyId='" + companyId
					+ "') and companyId='" + companyId + "'";
		} else {
			query = "Select classId from inventoryclass where parentclassid";

			if (parentId == null) {
				query += " is null";
			} else {
				query += "='" + parentId + "'";
			}
			query += " and companyId='" + companyId + "'";
		}
		// u.log("Query ::: : "+query);

		Statement st = null;
		ResultSet rs = null;
		try {
			con = getDataConnection();
			st = con.createStatement();
			rs = st.executeQuery(query);
			while (rs.next()) {
				classMaster = Utils.removeNull(rs.getString("classid"));
				classValues.add(classMaster);
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return classValues;
	}

	/*
	 * 
	 * @param Hashtable uomRequest --It contains all the request objct for
	 * variaus UOM
	 * 
	 * @return Hashtable -- returns hashtable for all values on the request
	 * 
	 * @exception java.lang.Exception
	 */

	public Hashtable getDataFromHashtable(Hashtable uomRequest, Vector fields)
			throws Exception {
		Utils.log("uomRequest>>>DistUtils>>>>"+ uomRequest);
		HttpServletRequest request = null;
		Enumeration keys = null;
		Enumeration names = null;
		String uom = "";
		String param = "";
		String values = "";
		Hashtable hash = new Hashtable();
		keys = uomRequest.keys();

		int i = 0;
		while (keys.hasMoreElements()) {
			uom = (String) keys.nextElement();
			request = (HttpServletRequest) uomRequest.get(uom);
			Vector temp = null;
			names = fields.elements();
			while (names.hasMoreElements()) {
				param = (String) names.nextElement();
				values = request.getParameter(param);
				if (values == null)
					values = "";
				if (i == 0) {
					temp = new Vector(10, 2);
					temp.add(i, values);
					hash.put(param, temp);
				} else {
					temp = (Vector) hash.get(param);
					temp.add(i, values);
					hash.put(param, temp);
				}
			}
			break; // second record
		}
		return hash;
	}
	
	
	public ArrayList getDataFromHashtableForUom(ArrayList uomList, Vector fields)
			throws Exception {
		Utils.log("uomRequest>>>DistUtils>>>>"+ uomList);
		HttpServletRequest request = null;
		Enumeration keys = null;
		Enumeration names = null;
		String uom = "";
		String param = "";
		String values = "";
		
		if(uomList != null && uomList.size() > 0){
			for(int j=0; j < uomList.size(); j++){
				Hashtable hash = (Hashtable) uomList.get(j);
				keys = hash.keys();

				int i = 0;
				while (keys.hasMoreElements()) {
					uom = (String) keys.nextElement();
					request = (HttpServletRequest) hash.get(uom);
					Vector temp = null;
					names = fields.elements();
					while (names.hasMoreElements()) {
						param = (String) names.nextElement();
						values = request.getParameter(param);
						if (values == null)
							values = "";
						if (i == 0) {
							temp = new Vector(10, 2);
							temp.add(i, values);
							hash.put(param, temp);
						} else {
							temp = (Vector) hash.get(param);
							temp.add(i, values);
							hash.put(param, temp);
						}
					}
					i++; // second record
				}
			}
		}
	
		return uomList;
	}

	public synchronized static String getCurrentDate(String separator) {

		Calendar cal = new GregorianCalendar();
		java.util.Date dt = new java.util.Date();
		cal.setTime(dt);
		String curDate = "";
//		String year = "";
		curDate = (cal.get(Calendar.MONTH) + 1) + separator
				+ cal.get(Calendar.DATE) + separator + cal.get(Calendar.YEAR);
		return curDate;
	}

	public synchronized static String getCurrentTime(String separator) {

		Calendar cal = new GregorianCalendar();
		java.util.Date dt = new java.util.Date();
		cal.setTime(dt);
		String curTime = "";
		int hr = cal.get(Calendar.HOUR);
		int min = cal.get(Calendar.MINUTE);
		int sec = cal.get(Calendar.SECOND);
		String amPm[] = { "AM", "PM" };
		String hour = "";
		String minute = "";
		String second = "";
		String ampmStr = "";
		hour = (hr < 10) ? "0" + hr : "" + hr;
		minute = (min < 10) ? "0" + min : "" + min;
		second = (sec < 10) ? "0" + sec : "" + sec;
		ampmStr = "" + amPm;
		curTime = hour + separator + minute + separator + second + " "
				+ amPm[cal.get(Calendar.AM_PM)];
		return curTime;
	}

	public double getGlNoAmount(Context context, String field, long glNo, String currentPeriod) 
			throws Exception {
		String query = "select sum(" + field
		+ ") as balance from glInterface  where gl_No='" + glNo + "'"
		+ "  and period='" + currentPeriod + "' and companyId='"
		+ companyId + "'";
		return Utils.parseDouble(getFieldInfo(context, query));		
	}
	
	public double getGlNoAmount(String field, long glNo, String currentPeriod)
			throws Exception {
		String query = "select sum(" + field
				+ ") as balance from glInterface  where gl_No='" + glNo + "'"
				+ "  and period='" + currentPeriod + "' and companyId='"
				+ companyId + "'";
		// Utils.log(query);
		return Utils.parseDouble(getFieldInfo(query));
	}

	public void setCompanyId(String newComapnyId) {
		this.companyId = newComapnyId;
	}

	public String getCompanyId() {
		return companyId;
	}

	public int generateLineNo(Context context, String query) throws Exception {
		int lineNo = 0;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection(context);
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(query);
			if (rs.next()) {
				rs.last();
				lineNo = rs.getInt("lineNo");
				lineNo = lineNo + 1;
			} else {
				lineNo = 1;
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return lineNo;
		
	}

	public int generateLineNo(String query) throws Exception {
		int lineNo = 0;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(query);
			if (rs.next()) {
				rs.last();
				lineNo = rs.getInt("lineNo");
				lineNo = lineNo + 1;
			} else {
				lineNo = 1;
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return lineNo;
	}

	// no need to synchronize since each session has a seperate instance of
	// distutis

	public synchronized static String getCompanyId(HttpSession session)
			throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("companyId") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("companyId");
	}

	public synchronized static Utils getUtils(HttpSession session)
			throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((Utils) session.getAttribute("Utils") == null)
			throw new Exception("Error: Login Session Expire");
		return (Utils) session.getAttribute("Utils");
	}

	public synchronized static DistUtils getDistUtils(HttpSession session)
			throws Exception {
		if ((DistUtils) session.getAttribute("DistUtils") == null)
			throw new Exception("Error: Login Session Expire");
		return (DistUtils) session.getAttribute("DistUtils");
	}

	public String getDefaultWarehouse(HttpSession session) throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("defaultWarehouse") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("defaultWarehouse");
	}

	public String getDefaultPrinter(HttpSession session) throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("defaultPrinter") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("defaultPrinter");
	}

	public synchronized static String getUserId(HttpSession session)
			throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("userId") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("userId");
	}

	public synchronized static String getUserName(HttpSession session)
			throws Exception {
		if (session == null)
			throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("userName") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("userName");
	}

	public synchronized static String getShowRebateCost(HttpSession session)
			throws Exception {
		if (session == null)
				throw new Exception("Error: Login Session Expire");
		if ((String) session.getAttribute("showRebateCost") == null)
			throw new Exception("Error: Login Session Expire");
		return (String) session.getAttribute("showRebateCost");
}

	public int getRecords(String tableName, String query) throws SQLException,
			Exception {
		String searchQuery = "";
		int i = 0;
		if ((i = query.indexOf("where")) != -1) {
			searchQuery = "select count(*) from " + tableName + " "
					+ query.substring(i);
		} else {
			searchQuery = "select count(*) from " + tableName;
		}
		return getRecords(searchQuery);
	}

	public int getRecords(Context context, String query) throws SQLException, Exception {
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		int count = 0;
		try {
			con = getDataConnection(context);
			stmt = con.createStatement();
			rs = stmt.executeQuery(query);
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (Exception e) {
			Utils.log("Error in PortalUtils.getRecords: " + query, e);
		} finally {
			Utils.close(rs);
			Utils.close(stmt);
			Utils.close(con);
		}
		return count;		
	}
	
	public int getRecords(String query) throws SQLException, Exception {

		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		int count = 0;
		try {
			con = getDataConnection();
			stmt = con.createStatement();
			rs = stmt.executeQuery(query);
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (Exception e) {
			Utils.log("Error in PortalUtils.getRecords: " + query, e);
		} finally {
			Utils.close(rs);
			Utils.close(stmt);
			Utils.close(con);
		}

		return count;

	}

	/**
	 * Gets an initi//// al context for the current user, password and url.
	 * ////// *
	 * 
	 * @return Context
	 * @exception java.lang.Exception
	 *                if there is an error in getting the Context
	 */
	public static synchronized Context getInitialContext() throws Exception {
		Properties p = new Properties();
		Context initCtx = new InitialContext();
		p.put(initCtx, "weblogic.jndi.WLInitialContextFactory");
		return new InitialContext(p);
	}

	public static String changePeriodFormat(int period) {
		String periodStr = (new Integer(period)).toString();
		int len = periodStr.length();
		Utils.log("Inside.DistUtils..period" + period);
		Utils.log("Inside.DistUtils...periodStr" + periodStr);
//		String mm = "";
//		String yyyy = "";
		if (len == 6) {
			Utils.log("Inside.DistUtils" + len);
			periodStr = periodStr.substring(0, 2) + "-"
					+ periodStr.substring(2);
			Utils.log("Inside.DistUtils1.." + periodStr);
		} else {
			periodStr = periodStr.substring(0, 1) + "-"
					+ periodStr.substring(1);
			Utils.log("Inside.DistUtils2.." + periodStr);
		}
		return periodStr;
	}

	// /////////////////////////////////////////////////////////////
	/**
	 * returns a java.sql.Date type Form parameter. if it does not exist, throws
	 * exception.
	 */
	public static java.sql.Date getParameterSqlDateTest(String paramName,
			String paramName1, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException {
		String date1 = request.getParameter(paramName);
		String format = request.getParameter(paramName1);
		if (date1 == null)
			throw new ParameterNotFoundException(paramName);
		if (format == null)
			throw new ParameterNotFoundException(paramName1);
		date1 = date1.toLowerCase();
		format = format.toUpperCase();
		Utils.log("Date1 : " + date1 + " Format :   " + format);
		date1 = date1.trim();
		format = format.trim();
		if (date1.equals("") || format.equals(""))
			return null;
		// /////////////////////////////
		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";
		try {
			int i1 = format.indexOf("DD");
			dd = date1.substring(i1, i1 + 2);
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				mm = date1.substring(i2, i2 + 3);
				if (mm.equalsIgnoreCase("jan"))
					mm = "01";
				else if (mm.equalsIgnoreCase("feb"))
					mm = "02";
				else if (mm.equalsIgnoreCase("mar"))
					mm = "03";
				else if (mm.equalsIgnoreCase("apr"))
					mm = "04";
				else if (mm.equalsIgnoreCase("may"))
					mm = "05";
				else if (mm.equalsIgnoreCase("jun"))
					mm = "06";
				else if (mm.equalsIgnoreCase("jul"))
					mm = "07";
				else if (mm.equalsIgnoreCase("aug"))
					mm = "08";
				else if (mm.equalsIgnoreCase("sep"))
					mm = "09";
				else if (mm.equalsIgnoreCase("oct"))
					mm = "10";
				else if (mm.equalsIgnoreCase("nov"))
					mm = "11";
				else if (mm.equalsIgnoreCase("dec"))
					mm = "12";
			} else {
				i2 = format.indexOf("MM");
				mm = date1.substring(i2, i2 + 2);
			}
			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
				yy = date1.substring(i3, i3 + 4);
			} else {
				i3 = format.indexOf("YY");
				yy = date1.substring(i3, i3 + 2);
				yy = "20" + yy;
			}

			date2 = dd + "." + mm + "." + yy;
			Utils.log("Date2 : " + date2);

			return new java.sql.Date(new GregorianCalendar(
					Integer.parseInt(yy), Integer.parseInt(mm) - 1, Integer
							.parseInt(dd)).getTime().getTime());
		} catch (Exception e) {
			Utils.log("Error in getParameterSqlDateTest: ", e);
			throw new InvalidParameterException(paramName + "&&" + format);
		}
	}

	
	
	public static java.sql.Date getParameterSqlDateTestNew(String date1,
			String paramName1, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException {
		//String date1 = request.getParameter(paramName);
		String format = request.getParameter(paramName1);
		if (date1 == null)
			throw new ParameterNotFoundException(date1);
		if (format == null)
			throw new ParameterNotFoundException(paramName1);
		date1 = date1.toLowerCase();
		format = format.toUpperCase();
		Utils.log("Date1 : " + date1 + " Format :   " + format);
		date1 = date1.trim();
		format = format.trim();
		if (date1.equals("") || format.equals(""))
			return null;
		// /////////////////////////////
		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";
		try {
			int i1 = format.indexOf("DD");
			dd = date1.substring(i1, i1 + 2);
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				mm = date1.substring(i2, i2 + 3);
				if (mm.equalsIgnoreCase("jan"))
					mm = "01";
				else if (mm.equalsIgnoreCase("feb"))
					mm = "02";
				else if (mm.equalsIgnoreCase("mar"))
					mm = "03";
				else if (mm.equalsIgnoreCase("apr"))
					mm = "04";
				else if (mm.equalsIgnoreCase("may"))
					mm = "05";
				else if (mm.equalsIgnoreCase("jun"))
					mm = "06";
				else if (mm.equalsIgnoreCase("jul"))
					mm = "07";
				else if (mm.equalsIgnoreCase("aug"))
					mm = "08";
				else if (mm.equalsIgnoreCase("sep"))
					mm = "09";
				else if (mm.equalsIgnoreCase("oct"))
					mm = "10";
				else if (mm.equalsIgnoreCase("nov"))
					mm = "11";
				else if (mm.equalsIgnoreCase("dec"))
					mm = "12";
			} else {
				i2 = format.indexOf("MM");
				mm = date1.substring(i2, i2 + 2);
			}
			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
				yy = date1.substring(i3, i3 + 4);
			} else {
				i3 = format.indexOf("YY");
				yy = date1.substring(i3, i3 + 2);
				yy = "20" + yy;
			}

			date2 = dd + "." + mm + "." + yy;
			Utils.log("Date2 : " + date2);

			return new java.sql.Date(new GregorianCalendar(
					Integer.parseInt(yy), Integer.parseInt(mm) - 1, Integer
							.parseInt(dd)).getTime().getTime());
		} catch (Exception e) {
			Utils.log("Error in getParameterSqlDateTest: ", e);
			throw new InvalidParameterException(date1 + "&&" + format);
		}
	}
	
	
	// ///////////////////////////
	// Change Sql date format from yyyy-mm-dd to selected date format
	public static String changeDateFormatTest(java.sql.Date dt, String format)
			throws Exception {
		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";
		if (dt == null)
			return "";
		try {
			String date1 = dt.toString();
			format = format.toUpperCase();
			// Utils.log("Date1 : "+date1+" Format : "+format);
			dd = date1.substring(8, 10);
			mm = date1.substring(5, 7);
			mm = (mm.length() < 2) ? "0" + mm : mm;
			yy = date1.substring(0, 4);
			int i1 = format.indexOf("DD");
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				if (mm.equalsIgnoreCase("01"))
					mm = "jan";
				else if (mm.equalsIgnoreCase("02"))
					mm = "feb";
				else if (mm.equalsIgnoreCase("03"))
					mm = "mar";
				else if (mm.equalsIgnoreCase("04"))
					mm = "apr";
				else if (mm.equalsIgnoreCase("05"))
					mm = "may";
				else if (mm.equalsIgnoreCase("06"))
					mm = "jun";
				else if (mm.equalsIgnoreCase("07"))
					mm = "jul";
				else if (mm.equalsIgnoreCase("08"))
					mm = "aug";
				else if (mm.equalsIgnoreCase("09"))
					mm = "sep";
				else if (mm.equalsIgnoreCase("10"))
					mm = "oct";
				else if (mm.equalsIgnoreCase("11"))
					mm = "nov";
				else if (mm.equalsIgnoreCase("12"))
					mm = "dec";
				mm = mm.toUpperCase();
			} else {
				i2 = format.indexOf("MM");
			}
			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
			} else {
				i3 = format.indexOf("YY");
				yy = yy.substring(2);
			}
			for (int i = 0; i < format.length(); i++) {
				String temp = "" + format.charAt(i);
				if (i == i1)
					date2 = date2 + dd;
				else if (i == i2)
					date2 = date2 + mm;
				else if (i == i3)
					date2 = date2 + yy;
				else if (temp.equals(".") || temp.equals("/")
						|| temp.equals("-"))
					date2 = date2 + temp;
			}
			// Utils.log("Date2 : "+date2+" Format : "+format);

		} catch (Exception e) {
			throw new Exception("Problem with date format " + e);
		}
		return date2;
	}

	// Change String date format from yyyy-mm-dd to selected date format
	public static String changeDateFormatTest(String dt, String format)
			throws Exception {
		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";

		Utils.log(" date " + dt + " format " + format);

		if (dt == null)
			return "";
		try {
			String date1 = dt.substring(0, 10);
			format = format.toUpperCase();
			// Utils.log("Date1 : "+date1+" Format : "+format);
			dd = date1.substring(8, 10);
			mm = date1.substring(5, 7);
			mm = (mm.length() < 2) ? "0" + mm : mm;
			yy = date1.substring(0, 4);
			int i1 = format.indexOf("DD");
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				if (mm.equalsIgnoreCase("01"))
					mm = "jan";
				else if (mm.equalsIgnoreCase("02"))
					mm = "feb";
				else if (mm.equalsIgnoreCase("03"))
					mm = "mar";
				else if (mm.equalsIgnoreCase("04"))
					mm = "apr";
				else if (mm.equalsIgnoreCase("05"))
					mm = "may";
				else if (mm.equalsIgnoreCase("06"))
					mm = "jun";
				else if (mm.equalsIgnoreCase("07"))
					mm = "jul";
				else if (mm.equalsIgnoreCase("08"))
					mm = "aug";
				else if (mm.equalsIgnoreCase("09"))
					mm = "sep";
				else if (mm.equalsIgnoreCase("10"))
					mm = "oct";
				else if (mm.equalsIgnoreCase("11"))
					mm = "nov";
				else if (mm.equalsIgnoreCase("12"))
					mm = "dec";
				mm = mm.toUpperCase();
			} else {
				i2 = format.indexOf("MM");
			}
			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
			} else {
				i3 = format.indexOf("YY");
				yy = yy.substring(2);
			}
			for (int i = 0; i < format.length(); i++) {
				String temp = "" + format.charAt(i);
				if (i == i1)
					date2 = date2 + dd;
				else if (i == i2)
					date2 = date2 + mm;
				else if (i == i3)
					date2 = date2 + yy;
				else if (temp.equals(".") || temp.equals("/")
						|| temp.equals("-"))
					date2 = date2 + temp;
			}
			// Utils.log("Date2 : "+date2+" Format : "+format);

		} catch (Exception e) {
			throw new Exception("Problem with date format " + e);
		}
		return date2;
	}

	public static String convertToSQLDate(String date1,
			String standardDateFormat) {
		String date2 = "";
		for (int i = 0; i < date1.length(); i++) {
			String temp = "" + date1.charAt(i);
			if (temp.equals(".") || temp.equals("/") || temp.equals("-")) {
			} else {
				date2 = date2 + temp;
			}
		}
		date2 = "TO_DATE('" + date2 + "','" + standardDateFormat + "')";

		return date2;
	}

	// //////////////////////////////
	public static String getFormattedCurrentDate(String format)
			throws Exception {
//		java.sql.Date currentDate = null;
//		String date = "";
		GregorianCalendar today = new GregorianCalendar();
		// currentDate = new java.sql.Date(new GregorianCalendar(
		// today.get(Calendar.YEAR)
		// ,today.get(Calendar.MONTH)
		// ,today.get(Calendar.DATE)).getTime().getTime());

		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";
		try {
			format = format.toUpperCase();
			// Utils.log("Date1 : "+date1+" Format : "+format);
			dd = "" + today.get(Calendar.DATE);
			dd = (dd.length() < 2) ? "0" + dd : dd;
			mm = "" + (today.get(Calendar.MONTH) + 1);
			mm = (mm.length() < 2) ? "0" + mm : mm;
			yy = "" + today.get(Calendar.YEAR);
			int i1 = format.indexOf("DD");
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				if (mm.equalsIgnoreCase("01"))
					mm = "jan";
				else if (mm.equalsIgnoreCase("02"))
					mm = "feb";
				else if (mm.equalsIgnoreCase("03"))
					mm = "mar";
				else if (mm.equalsIgnoreCase("04"))
					mm = "apr";
				else if (mm.equalsIgnoreCase("05"))
					mm = "may";
				else if (mm.equalsIgnoreCase("06"))
					mm = "jun";
				else if (mm.equalsIgnoreCase("07"))
					mm = "jul";
				else if (mm.equalsIgnoreCase("08"))
					mm = "aug";
				else if (mm.equalsIgnoreCase("09"))
					mm = "sep";
				else if (mm.equalsIgnoreCase("10"))
					mm = "oct";
				else if (mm.equalsIgnoreCase("11"))
					mm = "nov";
				else if (mm.equalsIgnoreCase("12"))
					mm = "dec";
				mm = mm.toUpperCase();
			} else {
				i2 = format.indexOf("MM");
			}
			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
			} else {
				i3 = format.indexOf("YY");
				yy = yy.substring(2);
			}
			for (int i = 0; i < format.length(); i++) {
				String temp = "" + format.charAt(i);
				if (i == i1)
					date2 = date2 + dd;
				else if (i == i2)
					date2 = date2 + mm;
				else if (i == i3)
					date2 = date2 + yy;
				else if (temp.equals(".") || temp.equals("/")
						|| temp.equals("-"))
					date2 = date2 + temp;
			}
			// Utils.log("Date2 : "+date2+" Format : "+format);

		} catch (Exception e) {
			throw new Exception("Problem with date format " + e);
		}
		return date2;
	}

	public static String getMonthList(HttpServletRequest request)
			throws Exception {
		String companyId = "";
		DistUtils du = null;
		Utils u = null;
		String curMon = "";
		String standardDateFormat = "";
		HttpSession session = request.getSession(false);
		du = DistUtils.getDistUtils(session);
		String curDate = "";
		String curPeriod = "";
		GregorianCalendar today = new GregorianCalendar();
		try {
			companyId = (String) session.getAttribute("companyId");
			standardDateFormat = (String) session
					.getAttribute("standardDateFormat");
			if (companyId == null)
				throw new Exception(u.getErrorMessage("LOG-01"));
			curDate = getFormattedCurrentDate(standardDateFormat);
			curPeriod = du.getPeriodFormat(companyId, curDate, "SA",
					standardDateFormat);
			if (curPeriod.length() < 6) {
				curMon = curPeriod.substring(0, 1);
				curMon = "0" + curMon;
			} else
				curMon = curPeriod.substring(0, 2);
		} catch (Exception ex) {
			curMon = "" + (today.get(Calendar.MONTH) + 1);
			Utils
					.log("currentPeriod not found for this type"
							+ ex.getMessage());
		}
		String showStr = "";
		String tmpStr = "";
		for (int i = 1; i <= 12; i++) {
			if (i <= 9)
				tmpStr = "0" + (new Integer(i)).intValue();
			else
				tmpStr = "" + (new Integer(i)).intValue();
			if (!tmpStr.equals(curMon)) {
				showStr += "<option value='" + tmpStr + "'>" + tmpStr
						+ "</option>";
			} else {
				showStr += "<option value='" + curMon + "' selected>" + tmpStr
						+ "</option>";
			}
		}// end of for
		return showStr;
	}

	public static String getYearList(HttpServletRequest request)
			throws Exception {
		String companyId = "";
		DistUtils du = null;
		Utils u = null;
		int curYear = 0;
		String standardDateFormat = "";
		HttpSession session = request.getSession(false);
		du = DistUtils.getDistUtils(session);
		String curDate = "";
		String curPeriod = "";
		GregorianCalendar today = new GregorianCalendar();
		try {
			companyId = (String) session.getAttribute("companyId");
			standardDateFormat = (String) session
					.getAttribute("standardDateFormat");
			if (companyId == null)
				throw new Exception(u.getErrorMessage("LOG-01"));

			curDate = getFormattedCurrentDate(standardDateFormat);
			curPeriod = du.getPeriodFormat(companyId, curDate, "SA",
					standardDateFormat);
			if (curPeriod.length() < 6)
				curYear = Utils.parseInt(curPeriod.substring(1, 5));
			else
				curYear = Utils.parseInt(curPeriod.substring(2, 6));
		} catch (Exception ex) {
			curYear = today.get(Calendar.YEAR);
			Utils
					.log("currentPeriod not found for this type in  GLACCOUNTPERIOD A"
							+ ex);
		}

		String showStr = "";
		showStr = "";
		for (int i = curYear - 10; i <= curYear + 10; i++) {
			if (i != curYear)
				showStr += "<option value='" + i + "'>" + i + "</option>";
			else
				showStr += "<option value='" + i + "' selected>" + i
						+ "</option>";
		}// end of for
		return showStr;
	}
	
	public String getPeriodFormat(Context context, String companyId, String date, String type,
			String standardDateFormat) throws Exception {
		Utils.logEntry("DistUtils.getPeriodFormat");
		String period = "";
		String query = " select currentPeriod from glAccountPeriod where companyId='"
				+ companyId
				+ "' and  type='"
				+ type
				+ "' and startingdate <= to_date('"
				+ date
				+ "','"
				+ standardDateFormat
				+ "')  and endingdate >= to_date('"
				+ date
				+ "','" + standardDateFormat + "')  ";
		Utils.logInfo(" IN get Period Format query " + query);
		try {
			period = getFieldInfo(context, query);
			if (period.trim().equals(""))
				throw new Exception(" Period not found in GLAccount Period ");
		} catch (Exception e) {
			throw new Exception(" " + e.getMessage());
		}
		Utils.logExit("DistUtils.getPeriodFormat");
		return period;		
	}

	public String getPeriodFormat(String companyId, String date, String type,
			String standardDateFormat) throws Exception {
		String period = "";
		String query = " select currentPeriod from glAccountPeriod where companyId='"
				+ companyId
				+ "' and  type='"
				+ type
				+ "' and startingdate <= to_date('"
				+ date
				+ "','"
				+ standardDateFormat
				+ "')  and endingdate >= to_date('"
				+ date
				+ "','" + standardDateFormat + "')  ";
		Utils.log(" IN get Period Format query " + query);
		try {
			period = getFieldInfo(query);
			if (period.trim().equals(""))
				throw new Exception(" Period not found in GLAccount Period ");
		} catch (Exception e) {
			throw new Exception(" " + e.getMessage());
		}
		return period;
	}

	// Added for the purpose of ARCustomerAging Inquiry
	public static Hashtable getCustomerAgingInfo(HttpServletRequest request,
			String customerId, String ageAccountAsOf, String ageBy)
			throws Exception {
		Connection con = null;
		DistUtils du = null;
		HttpSession session = request.getSession();
		Hashtable agingInfo = new Hashtable();
		Statement st = null;
		ResultSet rs = null;
		// String customerId="";
		String companyId = "";
		companyId = DistUtils.getCompanyId(session);
		du = DistUtils.getDistUtils(session);
		String standardDateFormat = (String) session
				.getAttribute("standardDateFormat");
		Utils.log("In aging standardDateFormat" + standardDateFormat);
		double days = 0;
		double balPastDays1 = 0;
		double balPastDays30 = 0;
		double balPastDays60 = 0;
		double balPastDays90 = 0;
		double notDue = 0;
		double currentAmt = 0;
		try {
			// customerId=u.getParameterString("customerId", request);
			con = du.getDataConnection();
			st = con.createStatement();
			String searchQuery = "select (debitAmt-(creditAmt+discountTakenAmount)) as debitamt ,TO_DATE('"
					+ ageAccountAsOf
					+ "','"
					+ standardDateFormat
					+ "')-"
					+ ageBy + "  as days from ArInvoice";
			searchQuery += " where companyId='" + companyId
					+ "' and customerid='" + customerId + "'";
			searchQuery += " and (debitAmt-(creditAmt+discountTakenAmount))!=0 ";
			rs = st.executeQuery(searchQuery);
			Utils.log("searchQuery" + searchQuery);
			// Prepare the output file.

			while (rs.next()) {
				days = rs.getDouble("days");
				if (days >= 1 && days <= 30)
					balPastDays1 += rs.getDouble("debitamt");
				else if (days > 30 && days <= 60)
					balPastDays30 += rs.getDouble("debitamt");
				else if (days > 60 && days <= 90)
					balPastDays60 += rs.getDouble("debitamt");
				else if (days > 90)
					balPastDays90 += rs.getDouble("debitamt");
				else if (days < -29)
					notDue += rs.getDouble("debitamt");
				else if (days <= 0 && days >= -29) {
					currentAmt += rs.getDouble("debitamt");
				}

			}
			agingInfo.put("balPastDays1", new Double(balPastDays1));
			agingInfo.put("balPastDays30", new Double(balPastDays30));
			agingInfo.put("balPastDays60", new Double(balPastDays60));
			agingInfo.put("balPastDays90", new Double(balPastDays90));
			agingInfo.put("notDue", new Double(notDue));
			agingInfo.put("currentAmt", new Double(currentAmt));

		}// end try
		catch (Exception e) {
			Utils.log("Inside Aging Query ageBy :", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return agingInfo;
	}

	public int getMaxLineInReport() {
		int maxLine = 0;
		try {
			maxLine = Integer.parseInt(SystemDefaults
					.getProperty("MaxLineInReport"));
		} catch (NumberFormatException nfe) {
			maxLine = 40;
		}
		return maxLine;
	}

	public int getMaxLineInReport(String companyId, String printerName,
			String orientation) throws Exception {
		int maxLine = 0;
		String printerType = "";
		try {
			printerType = Utils
					.removeNull(
							getFieldInfo("Select printerType from printer where printerId='"
									+ printerName
									+ "' and companyId='"
									+ companyId + "'")).trim();
			if (printerType.equalsIgnoreCase("D")
					&& orientation.equalsIgnoreCase("P")) {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineDotMatrixPortrait"));
			} else if (printerType.equalsIgnoreCase("D")
					&& orientation.equalsIgnoreCase("L")) {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineDotMatrixLandscape"));
			} else if (printerType.equalsIgnoreCase("L")
					&& orientation.equalsIgnoreCase("P")) {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineLaserPortrait"));
			} else {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineLaserLandscape"));
			}

			Utils.log("################    MAX LINE for Printer:" + printerType
					+ " and Orientation :" + orientation + " is " + maxLine);
		} catch (NumberFormatException nfe) {
			maxLine = 40;
		}
		return maxLine;
	}

	public int getMaxLineInReport(String orientation) throws Exception {
		int maxLine = 0;
//		String printerType = "";
		try {
			// printerType=Utils.removeNull(getFieldInfo("Select printerType from printer where printerId='"+printerName+"' and companyId='"+companyId+"'")).trim();

			if (orientation.equalsIgnoreCase("P")) {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineLaserPortrait"));
			} else {
				maxLine = Integer.parseInt(SystemDefaults
						.getProperty("MaxLineLaserLandscape"));
			}

			Utils
					.log("################    MAX LINE for Printer:and Orientation :"
							+ orientation + " is " + maxLine);
		} catch (NumberFormatException nfe) {
			maxLine = 40;
		}
		return maxLine;
	}

	public String parseURL(String URL) {
		int len = 0;
		StringBuffer buf = new StringBuffer();
		try {
			len = URL.length();
			for (int i = 0; i < len; i++) {
				char c = URL.charAt(i);
				if (c == ' ') {
					buf.append("+");
				} else {
					buf.append(c);
				}
			}// end of for loop
		}// end of try
		catch (Exception e) {
			Utils.log("Error in ParseURL function ...." + e.getMessage());
		}
		return buf.toString();

	}// end of function parseURL

	public String getFirstFiscalPeriod() {
		String fiscalMonth = "";
		int currentYear = 0;
		String firstFiscalPeriod = "";
		try {
			fiscalMonth = SystemDefaults.getProperty("FiscalMonth");
			Utils.log("1111 fiscalMonth " + fiscalMonth);
			if (fiscalMonth.length() == 1) {
				if (Integer.parseInt(fiscalMonth) > 0
						&& Integer.parseInt(fiscalMonth) <= 9) {
					fiscalMonth = "0" + fiscalMonth;
				}
			}
		} catch (NumberFormatException nfe) {
			fiscalMonth = "03";
		}
		Calendar cal = new GregorianCalendar();
//		java.util.Date dt = new java.util.Date();
		currentYear = cal.get(Calendar.YEAR);
		firstFiscalPeriod = fiscalMonth + new Integer(currentYear).toString();
		return firstFiscalPeriod;
	}

	public long getRefreshTimeForApplet() {
		long refreshTime = 0;
		try {
			refreshTime = Long.parseLong(SystemDefaults
					.getProperty("RefreshTimeForApplet"));
		} catch (NumberFormatException nfe) {
			refreshTime = 15000;
		}
		return refreshTime;
	}

	public Vector fetchTypes() {
		String types = "";
		Vector vTypes = new Vector(1, 1);
		try {
			types = SystemDefaults.getProperty("ModuleTypes");
			StringTokenizer stringtokenizer = new StringTokenizer(types, ",");
//			int i = stringtokenizer.countTokens();
			int j = 0;
			while (stringtokenizer.hasMoreTokens())
				try {
					vTypes.add(stringtokenizer.nextToken());
					j++;
				} catch (Exception _ex) {
				}

		}// end of outer try
		catch (Exception nfe) {
			Utils.log("Inside Types :" + nfe);
		}
		Utils.log("size of vector" + vTypes.size());
		return vTypes;
	}

	public boolean checkCurrentPeriod(String companyId, String date,
			String type, String standardDateFormat) throws Exception {
		String currentPeriod = "";
		String previousPeriod = "";
//		String status = "";
		int newMonth = 0;
		int newYear = 0;
		String query = " select currentPeriod from glAccountPeriod where companyId='"
				+ companyId
				+ "' and  type='"
				+ type
				+ "' and status='O' and startingdate <= to_date('"
				+ date
				+ "','"
				+ standardDateFormat
				+ "')  and endingdate >= to_date('"
				+ date
				+ "','"
				+ standardDateFormat + "')  ";
		// String
		// query=" select currentPeriod,startingDate,endingDate from glAccountPeriod where companyId='"+companyId+"' and  type='"+type+"' and status='O' ";
		Utils.log(" IN get Period DateRange query " + query);
		currentPeriod = getFieldInfo(query);
		Utils.log("currentPeriod in DistUtils=========================="
				+ currentPeriod);
		if (currentPeriod.equals("")) {// Checking whether currentPeriod of
			// Parameter Date is Closed
			Utils.log("Error : Period not Found ");
			throw new Exception("Error : Period is closed in GLAccount Period");
		}// end of if
		else {// //Checking whether Previous currentPeriod of Parameter Date is
			// Open
			if (currentPeriod.length() == 5
					&& Utils.parseInt(currentPeriod.substring(0, 1)) == 1) {
				newMonth = 12;
				newYear = Utils.parseInt(currentPeriod.substring(1)) - 1;
				previousPeriod = new Integer(newMonth).toString()
						+ new Integer(newYear).toString();
				Utils
						.log("previousPeriod in DistUtils=========================="
								+ previousPeriod);
			}// end of if
			else if (currentPeriod.length() == 5
					&& Utils.parseInt(currentPeriod.substring(0, 1)) != 1) {
				newMonth = Utils.parseInt(currentPeriod.substring(0, 1)) - 1;
				newYear = Utils.parseInt(currentPeriod.substring(1)) - 1;
				previousPeriod = new Integer(newMonth).toString()
						+ new Integer(newYear).toString();
				Utils
						.log("previousPeriod in DistUtils=========================="
								+ previousPeriod);
			}// end of else if
			/*
			 * request from jeremy to allow register run whether the pre period
			 * is open or not else{
			 * newMonth=Utils.parseInt(currentPeriod.substring(0,2))-1;
			 * newYear=Utils.parseInt(currentPeriod.substring(2));
			 * previousPeriod=new Integer(newMonth).toString()+new
			 * Integer(newYear).toString();
			 * Utils.log("previousPeriod in DistUtils=========================="
			 * +previousPeriod); }//end of else
			 * query=" select status from glAccountPeriod where companyId='"
			 * +companyId
			 * +"' and  type='"+type+"' and  currentPeriod="+previousPeriod
			 * +"  "; status=getFieldInfo(query); if(status.equals("O")){
			 * Utils.log("Error : Previous Period is Open "); throw new
			 * Exception("Error : Previous Period is Open in GLAccount Period");
			 * }
			 */
		}// end of else
		return true;
	}// end of getPeriodDateRange Function

	/*
	 * Fetching Valid Open Current Period Searching on current period and
	 * previous Period
	 */
	
	

	public String getCurrentPeriod(String companyId, String date, String type,
			String standardDateFormat) throws Exception {
		String currentPeriod = "";
		String previousPeriod = "";
		String status = "";
		int newMonth = 0;
		int newYear = 0;
		String query = " select currentPeriod from glAccountPeriod where companyId='"
				+ companyId
				+ "' and  type='"
				+ type
				+ "' and startingdate <= to_date('"
				+ date
				+ "','"
				+ standardDateFormat
				+ "')  and endingdate >= to_date('"
				+ date
				+ "','" + standardDateFormat + "') and status='O' ";
		Utils.log(" IN get Period DateRange query " + query);

		try {
			currentPeriod = getFieldInfo(query);
			Utils.log("currentPeriod in DistUtils=========================="
					+ currentPeriod);
			if (currentPeriod.equals("")) {// Checking whether currentPeriod of
				// Parameter Date is Closed
				Utils.log("Error : Period not Found ");
				throw new Exception("Period not found in GLAccount Period");

			}// end of if
			else {// //Checking whether Previous currentPeriod of Parameter Date
				// is Open
				if (currentPeriod.length() == 5
						&& Utils.parseInt(currentPeriod.substring(0, 1)) == 1) {
					newMonth = 12;
					newYear = Utils.parseInt(currentPeriod.substring(1)) - 1;
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log("In if previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of if
				else if (currentPeriod.length() == 5
						&& Utils.parseInt(currentPeriod.substring(0, 1)) != 1) {
					newMonth = Utils.parseInt(currentPeriod.substring(0, 1)) - 1;
					newYear = Utils.parseInt(currentPeriod.substring(1));
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log("In else if previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of else if
				else {
					newMonth = Utils.parseInt(currentPeriod.substring(0, 2)) - 1;
					newYear = Utils.parseInt(currentPeriod.substring(2));
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log(" In else previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of else
				query = " select status from glAccountPeriod where companyId='"
						+ companyId + "' and  type='" + type
						+ "' and  currentPeriod=" + previousPeriod + "  ";
				status = getFieldInfo(query);
				if (status.equals("O")) {
					Utils.log(" Previous Period is Open ");
					currentPeriod = previousPeriod;
				}
			}// end of else
		} catch (Exception e) {
			throw new Exception(" " + e.getMessage());
		}
		return currentPeriod;
	}// end of getCurrentPeriod Function

	/*
	 * Fetching Valid Open Period Searching on current period and previous
	 * Period
	 */

	public String fetchCurrentPeriod(String companyId, String period,
			String type, String standardDateFormat) throws Exception {
		String currentPeriod = "";
		String previousPeriod = "";
		String status = "";
		int newMonth = 0;
		int newYear = 0;
		String query = " select currentPeriod from glAccountPeriod where companyId='"
				+ companyId + "' and  type='" + type + "'  and status='O' ";
		Utils.log(" IN get Period DateRange query " + query);

		try {
			currentPeriod = getFieldInfo(query);
			Utils.log("currentPeriod in DistUtils=========================="
					+ currentPeriod);
			if (currentPeriod.equals("")) {// Checking whether currentPeriod of
				// Parameter Date is Closed
				Utils.log("Error : Period not Found ");
				throw new Exception("Period not found in GLAccount Period");

			}// end of if
			else {// //Checking whether Previous currentPeriod of Parameter Date
				// is Open
				if (currentPeriod.length() == 5
						&& Utils.parseInt(currentPeriod.substring(0, 1)) == 1) {
					newMonth = 12;
					newYear = Utils.parseInt(currentPeriod.substring(1)) - 1;
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log("In if previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of if
				else if (currentPeriod.length() == 5
						&& Utils.parseInt(currentPeriod.substring(0, 1)) != 1) {
					newMonth = Utils.parseInt(currentPeriod.substring(0, 1)) - 1;
					newYear = Utils.parseInt(currentPeriod.substring(1));
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log("In else if previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of else if
				else {
					newMonth = Utils.parseInt(currentPeriod.substring(0, 2)) - 1;
					newYear = Utils.parseInt(currentPeriod.substring(2));
					previousPeriod = new Integer(newMonth).toString()
							+ new Integer(newYear).toString();

					Utils
							.log(" In else previousPeriod in DistUtils=========================="
									+ previousPeriod);
				}// end of else
				query = " select status from glAccountPeriod where companyId='"
						+ companyId + "' and  type='" + type
						+ "' and  currentPeriod=" + previousPeriod + "  ";
				status = getFieldInfo(query);
				if (status.equals("O")) {
					Utils.log(" Previous Period is Open ");
					currentPeriod = previousPeriod;
				}
			}// end of else
		} catch (Exception e) {
			throw new Exception(" " + e.getMessage());
		}
		return currentPeriod;
	}// end of getCurrentPeriod Function

	public String getComboValues(HttpServletRequest request, String table,
			String module) throws Exception {
		DistUtils du = null;
		HttpSession session = request.getSession();
		Hashtable nameValuePair = new Hashtable();
		String companyId = "";
		String options = "";
		Vector code = new Vector(10, 2);
		Vector value = new Vector(10, 2);
		companyId = DistUtils.getCompanyId(session);
		du = DistUtils.getDistUtils(session);
		Utils.log("In getFOB..step..1..");
		try {
			String searchQuery = "select code,value from  " + table
					+ "  where companyId='" + companyId + "' and type='"
					+ module + "' and show='Y' order by seqno asc";
			Utils.log("searchQuery" + searchQuery);
			nameValuePair = du.getDataFromQuery(searchQuery);
			if (nameValuePair != null) {
				code = (Vector) nameValuePair.get("CODE");
				value = (Vector) nameValuePair.get("VALUE");
				if (code.size() != 0) {
					for (int i = 0; i < code.size(); i++) {
						options += "<option value='" + code.get(i) + "'>"
								+ value.get(i) + "</option>";

					}
				}
			}

		}// end try
		catch (Exception e) {
			Utils.log("getFob in DIstUtils:" + e.getMessage());
			throw new Exception("Error in getComboValues");
		}
		return options;
	}

	public String getAdjustmentCodeComboValues(HttpServletRequest request,String type) throws Exception {
		DistUtils du = null;
		HttpSession session = request.getSession();
		Hashtable nameValuePair = new Hashtable();
		String companyId = "";
		String options = "";
		Vector code = new Vector(10, 2);
		Vector value = new Vector(10, 2);
		companyId = DistUtils.getCompanyId(session);
		du = DistUtils.getDistUtils(session);
		Utils.log("In getFOB..step..1..");
		try {
			String searchQuery = "select code,description from  adjustmentcode " 
					+ "  where companyId='" + companyId + "' and type='"
					+ type + "' order by description";
			Utils.log("searchQuery" + searchQuery);
			nameValuePair = du.getDataFromQuery(searchQuery);
			if (nameValuePair != null) {
				code = (Vector) nameValuePair.get("CODE");
				value = (Vector) nameValuePair.get("DESCRIPTION");
				if (code.size() != 0) {
					for (int i = 0; i < code.size(); i++) {
						options += "<option value='" + code.get(i) + "'>"
								+ value.get(i) + "</option>";

					}
				}
			}

		}// end try
		catch (Exception e) {
			Utils.log("getFob in DIstUtils:" + e.getMessage());
			throw new Exception("Error in getComboValues");
		}
		return options;
	}
	public String getVehicleTypeCombo(HttpServletRequest request, String vehicleAdmin) throws Exception {
		DistUtils du = null;
		HttpSession session = request.getSession();
		Hashtable nameValuePair = new Hashtable();
		String companyId = "";
		String options = "";
		Vector code = new Vector();
		companyId = DistUtils.getCompanyId(session);
		du = DistUtils.getDistUtils(session);
		Utils.log("In getFOB..step..1..");
		try {
			String searchQuery = "select distinct vhtype from inventorymaster "+ 
					"  where companyId='" + companyId + "' and vhtype is not null and classid like '95%' ";
			if(vehicleAdmin.equals("N"))
				searchQuery+=" and vhType!='Personal' ";
			Utils.log("searchQuery" + searchQuery);
			nameValuePair = du.getDataFromQuery(searchQuery);
			if (nameValuePair != null) {
				code = (Vector) nameValuePair.get("VHTYPE");
				
				if (code.size() != 0) {
					for (int i = 0; i < code.size(); i++) {
						options += "<option value='" + code.get(i) + "'>"+ code.get(i) + "</option>";

					}
				}
			}

		}// end try
		catch (Exception e) {
			Utils.log("getFob in DIstUtils:" + e.getMessage());
			throw new Exception("Error in getComboValues");
		}
		return options;
	}
	public String getParentClassList(HttpServletRequest request) throws Exception {
		DistUtils du = null;
		HttpSession session = request.getSession();
		Hashtable nameValuePair = new Hashtable();
		String companyId = "";
		String options = "	<option value='' selected >SEARCH BY PRODUCT TYPE</option>";
		Vector code = new Vector(10, 2);
		Vector value = new Vector(10, 2);
		companyId = DistUtils.getCompanyId(session);
		du = DistUtils.getDistUtils(session);
		Utils.log("In getFOB..step..1..");
		try {
			String classQuery = "select classid,classdescription from  inventoryclass" + 
					"  where companyId='" + companyId + "' and classlevel=1 AND CLASSID NOT IN (69, 97, 90) order by classdescription";
			Utils.log("searchQuery" + classQuery);
			nameValuePair = du.getDataFromQuery(classQuery);
			if (nameValuePair != null) {
				code = (Vector) nameValuePair.get("CLASSID");
				value = (Vector) nameValuePair.get("CLASSDESCRIPTION");
				if (code.size() != 0) {
					for (int i = 0; i < code.size(); i++) {
						options += "<option value='" + code.get(i) + "'>"
								+ value.get(i) + "</option>";

					}
				}
			}

		}// end try
		catch (Exception e) {
			Utils.log("getParentClass in DIstUtils:" + e.getMessage());
			throw new Exception("Error in getComboValues");
		}
		return options;
	}
	
	// return all vlues from Branch
	public Vector branchValues(Context context, String companyId) throws Exception {
		String branchName = "";
		Vector branchValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection(context);
			st = con.createStatement();
			String query = "Select * from branch where companyId='" + companyId
					+ "' and nvl(active,'Y')='Y' ";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					branchName = Utils.removeNull(rs.getString("branch"));
					branchValues.add(branchName);
				} while (rs.next());
			} else {
				throw new Exception("No Branch present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(con);
			Utils.close(st);
			Utils.close(con);
		}
		return branchValues;		
	}
	
	public Vector branchValues(String companyId) throws Exception {

		String branchName = "";
		Vector branchValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from branch where companyId='" + companyId
					+ "' and nvl(active,'Y')='Y' ";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					branchName = Utils.removeNull(rs.getString("branch"));
					branchValues.add(branchName);
				} while (rs.next());
			} else {
				throw new Exception("No Branch present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(con);
			Utils.close(st);
			Utils.close(con);
		}
		return branchValues;

	}

	// returns date in sql form

	public static java.sql.Date convertToFormattedSqlDate(String date1,
			String format) throws Exception {

		if (format == "")
			throw new Exception("not a Valid Date Format");
		Utils.log("Date1 ...11..: " + date1 + " Format : " + format);
		date1 = date1.toLowerCase();
		format = format.toUpperCase();
		Utils.log("Date1 : " + date1 + " Format : " + format);
		date1 = date1.trim();
		format = format.trim();
		if (date1.equals("") || format.equals(""))
			return null;

//		String date2 = "";
		String dd = "";
		String mm = "";
		String yy = "";
		try {
			int i1 = format.indexOf("DD");
			dd = date1.substring(i1, i1 + 2);
			int i2 = format.indexOf("MON");
			if (i2 != -1) {
				mm = date1.substring(i2, i2 + 3);
				if (mm.equalsIgnoreCase("jan"))
					mm = "01";
				else if (mm.equalsIgnoreCase("feb"))
					mm = "02";
				else if (mm.equalsIgnoreCase("mar"))
					mm = "03";
				else if (mm.equalsIgnoreCase("apr"))
					mm = "04";
				else if (mm.equalsIgnoreCase("may"))
					mm = "05";
				else if (mm.equalsIgnoreCase("jun"))
					mm = "06";
				else if (mm.equalsIgnoreCase("jul"))
					mm = "07";
				else if (mm.equalsIgnoreCase("aug"))
					mm = "08";
				else if (mm.equalsIgnoreCase("sep"))
					mm = "09";
				else if (mm.equalsIgnoreCase("oct"))
					mm = "10";
				else if (mm.equalsIgnoreCase("nov"))
					mm = "11";
				else if (mm.equalsIgnoreCase("dec"))
					mm = "12";
			} else {
				i2 = format.indexOf("MM");
				mm = date1.substring(i2, i2 + 2);
			}

			int i3 = format.indexOf("YYYY");
			if (i3 != -1) {
				yy = date1.substring(i3, i3 + 4);
			} else {
				i3 = format.indexOf("YY");
				yy = date1.substring(i3, i3 + 2);
				yy = "20" + yy;
			}

			return new java.sql.Date(new GregorianCalendar(
					Integer.parseInt(yy), Integer.parseInt(mm) - 1, Integer
							.parseInt(dd)).getTime().getTime());
		} catch (Exception e) {
			Utils.log("Error in convertToSqlDate: ", e);
			throw new Exception("" + e.getMessage());
		}
	}

	public static String removeFraction(double number, int mask)
			throws Exception {
		// Utils.log("number==In Remove Fravction====="+number);
		String newNumber = "";
		int index = 0;
		String fractNum = "";
		boolean flag = false;
		newNumber = "" + Utils.getDoublePatternMask(number, mask);
		index = newNumber.indexOf(".");
		fractNum = newNumber.substring(index + 1);
		// Utils.log("fractNum===="+fractNum);
		for (int i = 0; i < fractNum.length(); i++) {
			String tempChar = "" + fractNum.charAt(i);
			if (!tempChar.equals("0")) {
				flag = true;
				// Utils.log("flag===="+flag);
			}

		} // end of for
		// Utils.log("flag=111==="+flag);
		if (!flag) {
			newNumber = newNumber.substring(0, index);
		}
		// Utils.log("newNumber===="+newNumber);
		return newNumber;

	}

	public String getStateList(Context context, String companyId) throws Exception {
		String state = "";
		Vector stateVec = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		String options = "";
		try {
			con = getDataConnection(context);
			st = con.createStatement();
			String query = "select distinct upper(state) state from warehouse where state is not null and companyId='"
					+ companyId
					+ "' union all select distinct upper(stateId) state from state where companyId='"
					+ companyId
					+ "' and stateID not in (select distinct upper(state) state from warehouse where state is not null and companyId='"
					+ companyId + "')";
			Utils.log(" INSIDE stateVec query$$$$$#" + query);
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					state = Utils.removeNull(rs.getString("state"));
					Utils.log(" INSIDE stateVec !" + state);
					stateVec.add(state);
				} while (rs.next());
			} else {
				throw new Exception("No state present for Company Id:"
						+ companyId);
			}
			if (stateVec.size() == 0) {
				throw new Exception("No state avaliable for the company ID  "
						+ companyId);
			}
			for (int i = 0; i < stateVec.size(); i++) {
				options += "<option value='" + stateVec.get(i) + "'>"
						+ stateVec.get(i) + "</option>";
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return options;		
	}
	
	public String getStateList(String companyId) throws Exception {

		String state = "";
		Vector stateVec = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		String options = "";
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "select distinct upper(state) state from warehouse where state is not null and companyId='"
					+ companyId
					+ "' union all select distinct upper(stateId) state from state where companyId='"
					+ companyId
					+ "' and stateID not in (select distinct upper(state) state from warehouse where state is not null and companyId='"
					+ companyId + "')";
			Utils.log(" INSIDE stateVec query$$$$$#" + query);
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					state = Utils.removeNull(rs.getString("state"));
					Utils.log(" INSIDE stateVec !" + state);
					stateVec.add(state);
				} while (rs.next());
			} else {
				throw new Exception("No state present for Company Id:"
						+ companyId);
			}
			if (stateVec.size() == 0) {
				throw new Exception("No state avaliable for the company ID  "
						+ companyId);
			}
			for (int i = 0; i < stateVec.size(); i++) {
				options += "<option value='" + stateVec.get(i) + "'>"
						+ stateVec.get(i) + "</option>";
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return options;

	}

	public int getRecordsUnion(Context context, String query) throws SQLException, Exception {
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		int count = 0;
		try {
			con = getDataConnection(context);
			stmt = con.createStatement();
			rs = stmt.executeQuery(query);
			while (rs.next()) {
				count++;
			}
		} catch (Exception e) {
			Utils.log("Error in du.getRecordsUnion: " + query, e);
		} finally {
			Utils.close(rs);
			Utils.close(stmt);
			Utils.close(con);
		}

		return count;
		
	}
	
	public int getRecordsUnion(String query) throws SQLException, Exception {

		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		int count = 0;
		try {
			con = getDataConnection();
			stmt = con.createStatement();
			rs = stmt.executeQuery(query);
			while (rs.next()) {
				count++;
			}
		} catch (Exception e) {
			Utils.log("Error in du.getRecordsUnion: " + query, e);
		} finally {
			Utils.close(rs);
			Utils.close(stmt);
			Utils.close(con);
		}

		return count;

	}
	public static String getModuleName(HttpServletRequest request)
	throws Exception {
		String moduleName = "";
		String module="";
try {
	DistUtils du=new DistUtils();
	module=request.getRequestURI();
	Utils.log("DistUtils title module"+module);
	module=module.substring(4,(module.lastIndexOf(".")+4));
	moduleName=du.getFieldInfo(" select description from module where upper(functionname) like upper('%"+module+"%')");
	return moduleName;
} catch (Exception e) {
	Utils.log("Caught in the DistUtils.getReportHeader ", e);
	throw e;
}

}
	public static String getReportHeader(HttpServletRequest request, int pageNo)
			throws Exception {
		String strHeader = "";
		String curDate = "";
		String curTime = "";
		String userName = "";
		String moduleName = "";
		String companyName = "";
		String standardDateFormat = "";
		String module="";
		HttpSession session = request.getSession(false);
		try {
			DistUtils du=new DistUtils();
			standardDateFormat = (String) session
					.getAttribute("standardDateFormat");
			userName = (String) session.getAttribute("userName");
			companyName = (String) session.getAttribute("companyName");
			//moduleName =(String) session.getAttribute("moduleName") ;
			userName = (String) session.getAttribute("userName");
			module=request.getRequestURI();
			Utils.log("new title module"+module);
			module=module.substring(4,(module.lastIndexOf(".")+4));
			moduleName=du.getFieldInfo(" select description from module where upper(functionname) like upper('%"+module+"%')");
			curDate = DistUtils.getFormattedCurrentDate(standardDateFormat);
			curTime = DistUtils.getCurrentTime(":");
			Utils.log("curDate!!!!!!!!!!!!!!!!!!!!!!!!!!" + curDate);

			strHeader = "<table  cellspacing=1 cellpadding=0 width=100%><tr bgcolor=#fff2e6 height=15 class=dataHeader><td align=left width=10%>Date </td><td nowrap width=15% align=left>"
					+ curDate
					+ "</td><td  align=center >"
					+ companyName
					+ "</td><td align=left width=10%>Page </td><td nowrap width=10% align=left>"
					+ pageNo + "</td></tr>";
			strHeader += "<tr bgcolor=#fff2e6 height=15 class='dataHeader'><td align=left>User Id</td><td nowrap align=left> "
					+ userName
					+ "</td><td align=center >"
					+ moduleName
					+ "</td><td align=left>Time </td><td nowrap align=left>"
					+ curTime + "</td></tr>";
			strHeader += "<tr bgcolor=#fff2e6 height=15 class=dataHeader><td colspan=5>&nbsp;</td></tr></table>";
			return strHeader;
		} catch (Exception e) {
			Utils.log("Caught in the DistUtils.getReportHeader ", e);
			throw e;
		}

	}

	/*
	 * This method will return Image Location from Property File
	 */
	public String getImageLocation(String location) throws Exception {

		String imageLocation = "";
		Utils.log("In distutils....location is " + location + " file"
				+ SystemDefaults.toString());
		try {
			imageLocation = SystemDefaults.getProperty(location).toString();
			Utils.log("image" + imageLocation);
		} catch (Exception e) {
			Utils.log("Image Location Not Found " + e.getMessage());
			throw new Exception("Image Location Not Found");
		}

		return imageLocation;

	}

	/*
	 * This method will return all vlues from market
	 */

	public Vector marketValues(Context context, String companyId) throws Exception {
		String market = "";
		Vector marketValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection(context);
			st = con.createStatement();
			String query = "Select * from market where companyId='" + companyId
					+ "'";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					market = Utils.removeNull(rs.getString("market"));
					marketValues.add(market);
				} while (rs.next());
			} else {
				throw new Exception("No Market present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return marketValues;
		
	}

	public Vector marketValues(String companyId) throws Exception {

		String market = "";
		Vector marketValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from market where companyId='" + companyId
					+ "'";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					market = Utils.removeNull(rs.getString("market"));
					marketValues.add(market);
				} while (rs.next());
			} else {
				throw new Exception("No Market present for Company Id:"
						+ companyId);
			}

		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return marketValues;

	}

	public static java.sql.Date getCurrentDateAddedMonth(
			java.sql.Date currentDate, int no_of_Months) throws Exception {
		try {
			Calendar cal = Calendar.getInstance();
			java.util.Date curdate = null;
			curdate = new java.util.Date(currentDate.getTime());
			cal.setTime(curdate);
			cal.add(Calendar.MONTH, no_of_Months);
			curdate = cal.getTime();
			currentDate = Utils.convertToSqlDate(curdate);

		} catch (Exception e) {
			throw new Exception("Problem with date  " + e);
		}
		return currentDate;
	}

	// return all vlues from Departent
	public Vector departmentValues(Context context, String companyId) throws Exception {
		String deptId = "";
		Vector deptValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection(context);
			st = con.createStatement();
			String query = "Select * from department where companyId='"
					+ companyId + "'";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					deptId = Utils.removeNull(rs.getString("deptid"));
					deptValues.add(deptId);
				} while (rs.next());
			} else {
				throw new Exception("No Department present for Company Id:"
						+ companyId);
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return deptValues;		
	}
	
	public Vector departmentValues(String companyId) throws Exception {

		String deptId = "";
		Vector deptValues = new Vector(1, 1);
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;

		try {
			con = getDataConnection();
			st = con.createStatement();
			String query = "Select * from department where companyId='"
					+ companyId + "'";
			rs = st.executeQuery(query);
			if (rs.next()) {
				do {
					deptId = Utils.removeNull(rs.getString("deptid"));
					deptValues.add(deptId);
				} while (rs.next());
			} else {
				throw new Exception("No Department present for Company Id:"
						+ companyId);
			}
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}
		return deptValues;

	}

	// return all values from Department
	public String convertNumberIntoWords(Context context, String numberStr) throws Exception {
		String numberStrReturn = "";
		String intPart = "";
		String fracPart = "";
		if (Utils.parseDouble(numberStr) != 0) {
			if (numberStr.indexOf(".") != -1) {
				intPart = numberStr.substring(0, numberStr.indexOf("."));
				fracPart = numberStr.substring(numberStr.indexOf(".") + 1,
						numberStr.length());
				numberStrReturn = getFieldInfo(context, "SELECT TO_CHAR(TO_DATE('"
						+ intPart + "', 'J'), 'JSP') FROM DUAL");
				if (Utils.parseInt(fracPart) != 0) {
					fracPart = fracPart + "/"
							+ ((int) Math.pow(10, fracPart.length()));
					numberStrReturn = numberStrReturn + " and " + fracPart;
				}

			} else {
				numberStrReturn = getFieldInfo(context, "SELECT TO_CHAR(TO_DATE('"
						+ numberStr + "', 'J'), 'JSP') FROM DUAL");
			}
		}
		return numberStrReturn;		
	}
	
	public String convertNumberIntoWords(String numberStr) throws Exception {

		String numberStrReturn = "";
		String intPart = "";
		String fracPart = "";
		if (Utils.parseDouble(numberStr) != 0) {
			if (numberStr.indexOf(".") != -1) {
				intPart = numberStr.substring(0, numberStr.indexOf("."));
				fracPart = numberStr.substring(numberStr.indexOf(".") + 1,
						numberStr.length());
				if(!intPart.trim().equals("0") && !intPart.trim().equals("")){
				numberStrReturn = getFieldInfo("SELECT TO_CHAR(TO_DATE('"
						+ intPart + "', 'J'), 'JSP') FROM DUAL");
				}
				if (Utils.parseInt(fracPart) != 0) {
					fracPart = fracPart + "/"
							+ ((int) Math.pow(10, fracPart.length()));
					if(!intPart.trim().equals("0") && !intPart.trim().equals("")){
					numberStrReturn = numberStrReturn + " and " + fracPart;
					}
					else
				    	numberStrReturn=fracPart;
				}

			} else {
				numberStrReturn = getFieldInfo("SELECT TO_CHAR(TO_DATE('"
						+ numberStr + "', 'J'), 'JSP') FROM DUAL");
			}
		}

		return numberStrReturn;

	}

	public double getCustomerBalance(Context context, String customerId, String companyId)
			throws Exception {
		double balance = 0;
		String customerType = "";
		String balQuery = "";
		String parentCustomer="";
		try {
			customerType = getFieldInfo(context, "select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P") && !customerType.equals("S"))
				//balQuery = " ar.customerId='" + customerId + "' ";
			if (customerType.equals("P"))
				balQuery = " ar.customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo(context, "select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				balQuery = " ar.customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				balQuery = " ar.customerId='" + customerId + "' ";
			
			balance = Utils
					.parseDouble(getFieldInfo(context, "select   sum( (nvl(ar.debitAmt,0) - ( nvl(ar.creditAmt,0) + nvl(ar.discountTakenAmount,0) - nvl(ar.adjustmentTakenAmt,0)))) from arinvoice ar where "
							+ balQuery
							+ " and registerno<>0 and companyId='"
							+ companyId + "'"));
		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception("Problem with getting customer balalnce  " + e);
		}
		return balance;		
	}
	
	public double getCustomerBalalnce(String customerId, String companyId)
			throws Exception {
		double balance = 0;
		String customerType = "";
		String balQuery = "";
		String parentCustomer="";
		try {
			customerType = getFieldInfo("select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P") && !customerType.equals("S"))
				//balQuery = " ar.customerId='" + customerId + "' ";
			if (customerType.equals("P"))
				balQuery = " ar.customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo("select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				balQuery = " ar.customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				balQuery = " ar.customerId='" + customerId + "' ";
			
			balance = Utils
					.parseDouble(getFieldInfo("select   sum( (nvl(ar.debitAmt,0) - ( nvl(ar.creditAmt,0) + nvl(ar.discountTakenAmount,0) - nvl(ar.adjustmentTakenAmt,0)))) from arinvoice ar where "
							+ balQuery
							+ " and registerno<>0 and companyId='"
							+ companyId + "'"));
		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception("Problem with getting customer balalnce  " + e);
		}
		return balance;
	}
	public double getCustomerPendingPayment(String customerId, String companyId)
	throws Exception {
double balance = 0;
String customerType = "";
String balQuery = "";
String parentCustomer="";
try {
	customerType = getFieldInfo("select nvl(customerType,'R') from customer where customerid='"
			+ customerId + "' and companyId='" + companyId + "'");
	if (customerType.equals("P"))
		balQuery = " customerId in (select customerId from customer where (parentId='"
				+ customerId
				+ "' OR customerId='"
				+ customerId
				+ "')) ";
	else if (customerType.equals("S")){
		parentCustomer = getFieldInfo("select nvl(parentid,'PAR01') from customer where customerid='"
				+ customerId + "' and companyId='" + companyId + "'");
		balQuery = " customerId in (select customerId from customer where (parentId='"
			+ parentCustomer
			+ "' OR customerId='"
			+ customerId
			+ "')) ";
	}
	else
		balQuery = " customerId='" + customerId + "' ";
	
	balance = Utils
			.parseDouble(getFieldInfo("select sum(totalcredit) from cashpaymentheader where status in ('E','P') and "+balQuery+" and companyId='"+companyId+"'"));
} catch (Exception e) {
	Utils.log("error", e);
	throw new Exception("Problem with getting customer balalnce  " + e);
}
return balance;
}
	public int getCustomerDueInvoices(Context context, String customerId, String companyId) 
			throws Exception {
		int noOfDueInvoices = 0;
		String customerType = "";
		String noOfDueInvoicesQuery = "";
		String parentCustomer="";
		try {
			String curDate = getFormattedCurrentDate("DD-MON-YYYY");
			customerType = getFieldInfo(context, "select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P") && !customerType.equals("S"))
				//noOfDueInvoicesQuery = " ar.customerId='" + customerId + "' ";
			if (customerType.equals("P"))
				noOfDueInvoicesQuery = " ar.customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo(context, "select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				noOfDueInvoicesQuery = " ar.customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				noOfDueInvoicesQuery = " ar.customerId='" + customerId + "' ";
			noOfDueInvoices = Utils
					.parseInt(getFieldInfo(context, "select  count(*) from arinvoice ar where "
							+ noOfDueInvoicesQuery
							+ " and companyId='1' and (nvl(ar.debitAmt,0) - ( nvl(ar.creditAmt,0) + nvl(ar.discountTakenAmount,0) - nvl(ar.adjustmentTakenAmt,0)))>0 and ar.registerno!=0 and duedate<'"
							+ curDate + "'"));
		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception("Problem with getting customer balalnce  " + e);
		}
		return noOfDueInvoices;
		
	}

	public int getCustomerDueInvoices(String customerId, String companyId)
			throws Exception {
		int noOfDueInvoices = 0;
		String customerType = "";
		String noOfDueInvoicesQuery = "";
		String parentCustomer="";
		try {
			String curDate = getFormattedCurrentDate("DD-MON-YYYY");
			customerType = getFieldInfo("select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P") && !customerType.equals("S"))
				//noOfDueInvoicesQuery = " ar.customerId='" + customerId + "' ";
			if (customerType.equals("P"))
				noOfDueInvoicesQuery = " ar.customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo("select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				noOfDueInvoicesQuery = " ar.customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				noOfDueInvoicesQuery = " ar.customerId='" + customerId + "' ";
			noOfDueInvoices = Utils
					.parseInt(getFieldInfo("select  count(*) from arinvoice ar where "
							+ noOfDueInvoicesQuery
							+ " and companyId='1' and (nvl(ar.debitAmt,0) - ( nvl(ar.creditAmt,0) + nvl(ar.discountTakenAmount,0) - nvl(ar.adjustmentTakenAmt,0)))>0 and ar.registerno!=0 and duedate<'"
							+ curDate + "'"));
			Utils.log("select  count(*) from arinvoice ar where "
							+ noOfDueInvoicesQuery
							+ " and companyId='1' and (nvl(ar.debitAmt,0) - ( nvl(ar.creditAmt,0) + nvl(ar.discountTakenAmount,0) - nvl(ar.adjustmentTakenAmt,0)))>0 and ar.registerno!=0 and duedate<'"
							+ curDate + "'");
		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception("Problem with getting customer balalnce  " + e);
		}
		return noOfDueInvoices;
	}

	public double getCustomerOpenOrderBalance(Context context, String customerId,
			String companyId) throws Exception {
		double balance = 0;
		String customerType = "";
		String balQuery = "";
		String parentCustomer="";
		try {
			customerType = getFieldInfo(context, "select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P"))
				//balQuery = " customerId='" + customerId + "' ";
			if(customerType.equals("P"))
				balQuery = " customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo(context, "select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				balQuery = " customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				balQuery = " customerId='" + customerId + "' ";
			// balance=Utils.parseDouble(getFieldInfo("select sum(nvl(balopenorder,0) ) from customer ar where "+balQuery+" and companyId='"+companyId+"'"));
			balance = Utils
					.parseDouble(getFieldInfo(context, "select sum(od.oqtyextendedprice)+sum(od.oqtytax1)+sum(od.oqtytax2)+sum(od.oqtytax3) from orderheader oh, orderdetail od where oh.orderno=od.orderno and oh.orderext=od.orderext and "
							+ balQuery
							+ " and oh.orderstatus in('E','O','C','I','P','W') and oh.termscode not in ('CA','CC','CK','CR') AND od.companyId='"
							+ companyId + "'"));

		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception(
					"Problem with getting customer open order balalnce  " + e);
		}
		return balance;		
	}

	public double getCustomerOpenOrderBalalnce(String customerId,
			String companyId) throws Exception {
		double balance = 0;
		String customerType = "";
		String balQuery = "";
		String parentCustomer="";
		Connection con =null;
		PreparedStatement pst=null ;
		ResultSet rs =null;
		try {
			customerType = getFieldInfo("select nvl(customerType,'R') from customer where customerid='"
					+ customerId + "' and companyId='" + companyId + "'");
			//if (!customerType.equals("P"))
				//balQuery = " customerId='" + customerId + "' ";
			if(customerType.equals("P"))
				balQuery = " customerId in (select customerId from customer where (parentId='"
						+ customerId
						+ "' OR customerId='"
						+ customerId
						+ "')) ";
			else if (customerType.equals("S")){
				parentCustomer = getFieldInfo("select nvl(parentid,'PAR01') from customer where customerid='"
						+ customerId + "' and companyId='" + companyId + "'");
				balQuery = " customerId in (select customerId from customer where (parentId='"
					+ parentCustomer
					+ "' OR customerId='"
					+ customerId
					+ "')) ";
			}
			else
				balQuery = " customerId='" + customerId + "' ";
			// balance=Utils.parseDouble(getFieldInfo("select sum(nvl(balopenorder,0) ) from customer ar where "+balQuery+" and companyId='"+companyId+"'"));
			Utils.log("before balalnce-DU-1");
			
			String openOrderQuery="select orderNo, orderExt " +
			"from orderheader oh " +
			"where " +
			 balQuery
			+ " and oh.orderstatus not in('I','C','R','D') and oh.termscode not in ('CA','CC','CK','CR') AND oh.companyId='"+ companyId + "'";
			
			String confirmOrderQuery="select orderNo, orderExt " +
			"from orderheader oh " +
			"where " +
			 balQuery
			+ " and oh.orderstatus in('I','C') and oh.termscode not in ('CA','CC','CK','CR') AND oh.companyId='"+ companyId + "'";
			Utils.log("openOrderQuery"+openOrderQuery);
			Utils.log("confirmOrderQuery"+confirmOrderQuery);
			con = getDataConnection();
			pst = con.prepareStatement(openOrderQuery);
			rs = pst.executeQuery();
			while(rs.next()){
				balance+= Utils.parseDouble(getFieldInfo("select sum(od.oqtyextendedprice)" +
						"+sum(od.oqtytax1)+sum(od.oqtytax2)+sum(od.oqtytax3) " +
						"from orderdetail od where OrderNo='"+rs.getString("orderNo")+"' and orderExt="+rs.getInt("orderExt")));
			}
			 pst = con.prepareStatement(confirmOrderQuery);
			rs = pst.executeQuery();
			while(rs.next()){
				balance+= Utils.parseDouble(getFieldInfo("select  sum(od.netprice)" +
					"+sum(od.taxamt1)+sum(od.taxamt2)+sum(od.taxamt3) " +
						"from orderdetail od where OrderNo='"+rs.getString("orderNo")+"' and orderExt="+rs.getInt("orderExt")));
			}
			rs.close();
			pst.close();
			con.close();
			Utils.log("Customer open Order Balance"+balance);
			/*balance = Utils.parseDouble(getFieldInfo("select sum(od.oqtyextendedprice)" +
					"+sum(od.oqtytax1)+sum(od.oqtytax2)+sum(od.oqtytax3) " +
					"from orderheader oh, " +
					"orderdetail od where " +
					"oh.orderno=od.orderno " +
					"and oh.orderext=od.orderext and "
							+ balQuery
							+ " and oh.orderstatus not in('I','C','R','D') and oh.termscode not in ('CA','CC','CK','CR') AND oh.companyId='"
							+ companyId + "'"));
			balance += Utils.parseDouble(getFieldInfo("select sum(od.netprice)" +
					"+sum(od.taxamt1)+sum(od.taxamt2)+sum(od.taxamt3) " +
					"from orderheader oh, " +
					"orderdetail od where " +
					"oh.orderno=od.orderno " +
					"and oh.orderext=od.orderext and "
							+ balQuery
							+ " and oh.orderstatus  in('I','C') and oh.termscode not in ('CA','CC','CK','CR') AND oh.companyId='"
							+ companyId + "'"));
			
			Utils.log("select sum(od.oqtyextendedprice)+sum(od.oqtytax1)+sum(od.oqtytax2)+sum(od.oqtytax3) from orderheader oh, orderdetail od where oh.orderno=od.orderno and oh.orderext=od.orderext and "
							+ balQuery
							+ " and oh.orderstatus not in('R','D') and oh.termscode not in ('CA','CC','CK','CR') AND oh.companyId='"
							+ companyId + "'");
			*/

		} catch (Exception e) {
			Utils.log("error", e);
			throw new Exception(
					"Problem with getting customer open order balalnce  " + e);
		}
		finally{
			try{
			rs.close();
			pst.close();
			con.close();
			}
			catch(Exception e){}
		}
		return balance;

	}

	/*
	 * Returns a list of strings (in order) for products that match the supplied
	 * keywords
	 */
	public static List productKeywordSearch(String searchKeywords) {

		ArrayList results = new ArrayList();
		if (searchKeywords == null || searchKeywords.trim().equals("")) {
			return results;
		}

		Directory directory = null;
		IndexSearcher searcher = null;

		try {

			directory = FSDirectory.getDirectory(new File(
					"/opt/lucene/sd/product"));

			searcher = new IndexSearcher(directory);

			BooleanQuery.setMaxClauseCount(65536);
			QueryParser parser = new QueryParser("keyword",
					new WhitespaceAnalyzer());
			parser.setAllowLeadingWildcard(true);

			StringBuffer sb = new StringBuffer();
			String[] keys = searchKeywords.split("\\s");
			for (int i = 0; i < keys.length; i++) {

				if (i > 0)
					sb.append(" ");

				String k = keys[i].trim().toLowerCase();
				if (StringUtils.isNumeric(k)) {
					k = "*" + k;
				}

				if (productSubstitutionMap.containsKey(k)) {

					String[] subs = (String[]) productSubstitutionMap.get(k);

					if (subs.length > 1) {
						sb.append("+(");

						for (int j = 0; j < subs.length; j++) {
							if (j > 0)
								sb.append(" OR ");
							sb.append(subs[j]).append("*");
						}
						sb.append(")");
					} else if (subs.length == 1) {
						sb.append("+").append(k).append("*");
					}

				} else {
					sb.append("+").append(k).append("*");
				}

			}

			Query query = parser.parse(sb.toString());
			TopDocs docs = searcher.search(query, 100000);

			if (docs == null || docs.scoreDocs == null
					|| docs.scoreDocs.length == 0) {
				searcher.close();
				return results;
			}

			for (int i = 0; i < docs.scoreDocs.length; i++) {
				String productNo = searcher.doc(docs.scoreDocs[i].doc).get(
						"productno");
				results.add(productNo);
			}

			searcher.close();

		} catch (ParseException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (searcher != null) {
				try {
					searcher.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return results;
	}

	public static void main(String[] args) {
		List results = productKeywordSearch("br shingle");
		System.out.println("Found " + results.size() + " results");
		for (int i = 0; i < results.size(); i++)
			System.out.println(results.get(i));
	}

	static {

		List subList = new ArrayList();
		subList.add(new String[] { "malarkey", "mlrky", "mlarky" });
		subList.add(new String[] { "brown", "br", "brwn", "brn" });
		subList.add(new String[] { "white", "wh", "wht" });
		subList.add(new String[] { "black", "bl", "bk", "blk" });
		subList.add(new String[] { "green", "gr", "grn" });
		subList.add(new String[] { "gray", "gr", "gry" });
		subList.add(new String[] { "yellow", "yel", "ylw" });
		subList.add(new String[] { "orange", "orng", "ornge" });
		subList.add(new String[] { "terracotta", "terra cotta", "tc", "tccta",
				"tctta" });
		subList.add(new String[] { "piece", "pc" });
		subList.add(new String[] { "box", "bx" });
		subList.add(new String[] { "roll", "rl" });
		subList.add(new String[] { "pallet", "pal" });
		subList.add(new String[] { "redland", "rdlnd", "redlnd" });
		subList.add(new String[] { "plastic", "plas", "plast" });
		subList.add(new String[] { "cement", "cmnt", "cemnt" });
		subList.add(new String[] { "roofing", "rfg" });
		subList.add(new String[] { "roof", "rf" });
		subList.add(new String[] { "shake", "sh", "shk", "shke" });
		subList.add(new String[] { "slate", "sl", "slt", "slte" });
		subList.add(new String[] { "capistrano", "capi", "capis" });
		subList.add(new String[] { "ridge", "rg", "rge" });
		subList.add(new String[] { "rake", "rk", "rke" });
		subList.add(new String[] { "mansard", "mans", "trim" });
		subList.add(new String[] { "birdstop", "brdstp", "bdstp", "bs" });
		subList.add(new String[] { "2-pc", "2pc", "pc" });
		subList.add(new String[] { "malibu", "mali" });
		subList.add(new String[] { "coating", "coat" });
		subList.add(new String[] { "aluminum", "alum", "alm" });
		subList.add(new String[] { "galvanized", "galv" });
		subList.add(new String[] { "gallon", "gal", "gl" });
		subList.add(new String[] { "fieldstone", "fldstne" });
		subList.add(new String[] { "villa", "vil" });

		productSubstitutionMap = new HashMap();

		for (int i = 0; i < subList.size(); i++) {

			List wordList = Arrays.asList((String[]) subList.get(i));
			Collections.sort(wordList, new Comparator() {
				public int compare(Object arg0, Object arg1) {
					return ((String) arg0).compareToIgnoreCase((String) arg1)
							* -1;
				}
			});

			// each word is a key
			for (int j = 0; j < wordList.size(); j++) {
				List currentWords = new ArrayList();
				for (int z = 0; z < wordList.size(); z++) {
					currentWords.add(wordList.get(z));
				}
				if (currentWords.size() != 0)
					productSubstitutionMap.put(wordList.get(j), currentWords
							.toArray(new String[currentWords.size()]));
			}
		}
	}
	public  String [] wrapText (String text, int len)
	{
	  // return empty array for null text
	  if (text == null)
	  return new String [] {};

	  // return text if len is zero or less
	  if (len <= 0)
	  return new String [] {text};

	  // return text if less than length
	  if (text.length() <= len)
	  return new String [] {text};

	  char [] chars = text.toCharArray();
	  Vector lines = new Vector();
	  StringBuffer line = new StringBuffer();
	  StringBuffer word = new StringBuffer();

	  for (int i = 0; i < chars.length; i++) {
	    word.append(chars[i]);

	    if (chars[i] == ' ' || chars[i] == ':') {
	      if ((line.length() + word.length()) > len) {
	        lines.add(line.toString());
	        line.delete(0, line.length());
	      }

	      line.append(word);
	      word.delete(0, word.length());
	    }
	  }

	  // handle any extra chars in current word
	  if (word.length() > 0) {
	    if ((line.length() + word.length()) > len) {
	      lines.add(line.toString());
	      line.delete(0, line.length());
	    }
	    line.append(word);
	  }

	  // handle extra line
	  if (line.length() > 0) {
	    lines.add(line.toString());
	  }

	  String [] ret = new String[lines.size()];
	  int c = 0; // counter
	  for (Enumeration e = lines.elements(); e.hasMoreElements(); c++) {
	    ret[c] = (String) e.nextElement();
	  }

	  return ret;
	}
	public  String replaceDoubleBackSlash(String text){
		text=text.replaceAll("\\\\\\\\", "");
		return text;
	}
	public  String replaceSingleWithDoubleQuote(String text){
		text=text.replaceAll("''","\"");
		return text;
	}
	public Vector parseArrayToVector(String [] arryToVec){
		Vector retvec=new Vector();
		if(arryToVec!=null){
		for(int j=0;j<arryToVec.length;j++){
			retvec.add(arryToVec[j]);
		}
		}
		return retvec;
	}
	public static String round(double d, int decimalPlace) throws Exception{
	    BigDecimal bd = new BigDecimal(Double.toString(d));
	    if(decimalPlace<=3)
	    bd = bd.setScale(3,BigDecimal.ROUND_HALF_UP);
	    bd = bd.setScale(decimalPlace,BigDecimal.ROUND_HALF_UP);
	    return bd.toString();
	  }
	public static double roundDouble(double d, int decimalPlace) throws Exception{
	    BigDecimal bd = new BigDecimal(Double.toString(d));
	    if(decimalPlace<=3)
		    bd = bd.setScale(3,BigDecimal.ROUND_HALF_UP);
	    bd = bd.setScale(decimalPlace,BigDecimal.ROUND_HALF_UP);
	    return bd.doubleValue();
	  }
 
 public static String getPriorPeriod(int month, int year, int noOfMonths, String pattern){
	 SimpleDateFormat dateFormat = new SimpleDateFormat(pattern);
	 Calendar c = Calendar.getInstance();  
	 c.set(c.MONTH, month);
	 c.set(c.YEAR, year);
	 c.add(c.MONTH, noOfMonths*-1);
	 return dateFormat.format(c.getTime()); 
 }
 
 public JSONObject getJsonFromResultSet(ResultSet rs) throws Exception {
		ResultSetMetaData rsMeta = null;
		JSONObject json = new JSONObject();
		try {

			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					dataType= rsMeta.getColumnTypeName(k);
					if(dataType.equals("DOUBLE"))
					itemjson.put(new Double(rs.getDouble(name)));
					else if(dataType.equals("INTEGER"))
						itemjson.put(new Integer(rs.getInt(name)));
					else if(dataType.equals("DATE"))
						itemjson.put(rs.getDate(name));
					else
						itemjson.put(rs.getString(name));
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.log("Error in getJsonFromResultSet()", e);
			throw new ProcessingErrorException(e);
		} 	
		return json;
	}
	
 public JSONObject getJsonFromQuery(String Query) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					//dataType= rsMeta.getColumnTypeName(k);
					//if(dataType.equals("DOUBLE"))
					//itemjson.put(new Double(rs.getDouble(name)));
					/*else if(dataType.equals("INTEGER"))
						itemjson.put(new Integer(rs.getInt(name)));
					else if(dataType.equals("DATE"))
						itemjson.put(rs.getDate(name));
					else*/
						itemjson.put(rs.getString(name));
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 
 public JSONObject getJsonFromQueryPro2(String Query) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		try {
			con = getPro2DataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
						itemjson.put(rs.getString(name));
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 
 public JSONObject getJsonFromQueryPro2Delivery(String Query) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		String so_id="";
		int shipment_num=0;
		try {
			con = getPro2DataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					itemjson.put(rs.getString(name));
				}
				so_id=rs.getString("so_id");
				shipment_num=rs.getInt("shipment_num");
				Utils.log("select nvl(count(*),0) from mob_confirm_img where orderid='"+so_id+"' and shipmentid="+shipment_num);
				String imageCount=Utils.removeNull(getFieldInfo("select nvl(count(*),0) from mob_confirm_img where orderid='"+so_id+"' and shipmentid="+shipment_num));
				itemjson.put(imageCount);
				itemjson.put("<a href=\"javascript:popupForUploadImage('"+so_id+"','"+shipment_num+"')\">Upload</a>");
				json.append("aaData", itemjson);
			}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st)
;
			Utils.close(con);
		}

		return json;
	}
 
 public JSONObject getJsonFromQuerySlowItem(String Query) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
						if(k!=9)
						itemjson.put(rs.getString(name));
						else{
							String classDesc=getClassDesc( rs.getString(name));
							itemjson.put(rs.getString(name)+ " : "+classDesc );
						}
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 
 public String getClassDesc( String classId) throws Exception{
	 	String classDesc="";
	 	String desc1="";
	 	String desc2="";
	 	String desc3="";
	 	String rootClass="";
	 	String level2="";
	 	String level3="";
	 	rootClass=classId.substring(0,2);
	 	Utils.log("rootClass"+rootClass);
	 	level2=classId.substring(2,4);
	 	Utils.log("level2"+level2);
	 	level3=classId.substring(4,6);
	 	Utils.log("level3"+level3);
	 	desc1=getFieldInfo("select classDescription from inventoryclass where classid='"+rootClass+"' and classlevel=1 and parentclassid='PARENT'");
	 	desc2=getFieldInfo("select classDescription from inventoryclass where classid='"+level2+"' and classlevel=2 and parentclassid='"+rootClass+"' and rootclass='"+rootClass+"'");
	 	desc3=getFieldInfo("select classDescription from inventoryclass where classid='"+level3+"' and classlevel=3 and parentclassid='"+level2+"' and rootclass='"+rootClass+"'");
	 	classDesc="<b>Class:</b> "+desc1+"       <b>Profile:</b> "+desc2+"       <b>Type:</b> "+desc3;
	 	return classDesc.toUpperCase();
		
	}
 
 public JSONObject getJsonFromQuerySODoc(String Query, String orderNo) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		Statement st1 = null;
		ResultSet rs1 = null;
		String returnOrderNo="";
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					Utils.log("K :"+k);
					name = rsMeta.getColumnName(k);
					Utils.log("name :"+name);
					if(k==10 || k==8){
						if(k==10){
						returnOrderNo="";
						st1 = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
								ResultSet.CONCUR_READ_ONLY);
						rs1 = st1.executeQuery("select orderno from orderdetail where returnorderno like '"+orderNo+"%' and productNo='"+rs.getString("productno")+"'");
						while(rs1.next()){
							returnOrderNo+="<a href=D_OEInqDocumentInquiry.jsp?Submit=orderSearch&orderNo="+rs1.getString("orderNo")+" target=_new>"+rs1.getString("orderNo")+"</a> ";
						}
						itemjson.put(returnOrderNo);
					}
					else if(k==8){
						int qtyAdjustmentReturnCount=Utils.parseInt(getFieldInfo("select count(*) from orderdetail where returnorderno like '"+orderNo+"%' and nvl(returnCode,'QA')='PA'  and productNo='"+rs.getString("productno")+"'"));
						if(qtyAdjustmentReturnCount>0 && !rs.getString("productno").equals("MEMO"))
							itemjson.put("PA");
						else{
							String returnqty=Utils.removeNull(rs.getString(name));
							if(!returnqty.equals("0"))
							itemjson.put(rs.getString(name));
							else
								itemjson.put("");
						}
					}
					}
					else
					itemjson.put(rs.getString(name));
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 public JSONObject getJsonFromQuerySOInvoice(String Query, String orderNo, String orderExt) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		Statement st1 = null;
		ResultSet rs1 = null;
		String returnOrderNo="";
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					Utils.log("K :"+k);
					name = rsMeta.getColumnName(k);
					Utils.log("name :"+name);
					if(k==10 || k==8){
						if(k==10){
						returnOrderNo="";
						st1 = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
								ResultSet.CONCUR_READ_ONLY);
						rs1 = st1.executeQuery("select orderno from orderdetail where returnorderno like '"+orderNo+"%' and returnOrderExt="+orderExt+" and productNo='"+rs.getString("productno")+"'");
						while(rs1.next()){
							returnOrderNo+="<a href=D_OEInqDocumentInquiry.jsp?Submit=orderSearch&orderNo="+rs1.getString("orderNo")+" target=_new>"+rs1.getString("orderNo")+"</a> ";
						}
						itemjson.put(returnOrderNo);
					}
					else if(k==8){
						int qtyAdjustmentReturnCount=Utils.parseInt(getFieldInfo("select count(*) from orderdetail where returnorderno like '"+orderNo+"%' and returnOrderExt="+orderExt+" and nvl(returnCode,'QA')='PA'  and productNo='"+rs.getString("productno")+"'"));
						if(qtyAdjustmentReturnCount>0 && !rs.getString("productno").equals("MEMO"))
							itemjson.put("PA");
						else{
							String returnqty=Utils.removeNull(rs.getString(name));
							if(!returnqty.equals("0"))
							itemjson.put(rs.getString(name));
							else
								itemjson.put("");
						}
					}
					}
					else
					itemjson.put(rs.getString(name));
					}
				json.append("aaData", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}


 
 public JSONObject getJsonFromQueryForChart(String Query) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			String name = "";
			String dataType="";
			while (rs.next()) {
				JSONArray itemjson = new JSONArray(); 
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					//dataType= rsMeta.getColumnTypeName(k);
					//if(dataType.equals("DOUBLE"))
					//itemjson.put(new Double(rs.getDouble(name)));
					/*else if(dataType.equals("INTEGER"))
						itemjson.put(new Integer(rs.getInt(name)));
					else if(dataType.equals("DATE"))
						itemjson.put(rs.getDate(name));
					else*/
						itemjson.put(rs.getString(name));
					}
				json.append("", itemjson);
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 
 public JSONObject getJsonForPurchasingRpt(String Query, String startDate) throws Exception {
	 	ResultSetMetaData rsMeta = null;
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		JSONObject json = new JSONObject();
		try {
			con = getDataConnection();
			st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			rs = st.executeQuery(Query);
			rsMeta = rs.getMetaData();
			int coulmns = rsMeta.getColumnCount();
			double totalSales=0;
			double unitSales=0;
			double safetyStock=0;
			double leadDays=0;
			String name = "";
			String dataType="";
			double available=0;
			double reOrderPoint=0;
			while (rs.next()) {
				JSONArray itemjson = new JSONArray();
				available=rs.getDouble("available");
				totalSales=rs.getDouble("units");
				unitSales=totalSales/92;
				String leadTimeQuery=" select round(sum(to_date(to_char(pr.receiptdate,'YYYYMMDD'),'YYYYMMDD')-to_date(to_char(pd.creationdate,'YYYYMMDD'),'YYYYMMDD')),2)/count(*) from podetail pd, poreceipts pr where "+ 
				   " pd.companyid=pr.companyid "+
					" and pd.ponumber=pr.ponumber "+
					" and pd.lineno=pr.podetailline and pd.companyid=1 "+
					" and pr.productno='"+rs.getString("productNo")+"' "+
					" and to_date(to_char(pr.receiptdate,'MM-DD-YYYY'),'MM-DD-YYYY')>=to_date('"+startDate+"','MM-DD-YYYY') "+
					 " and pr.status in ('I','R')";
				try{
					//Utils.log(leadTimeQuery);
					leadDays=Utils.parseDouble(getFieldInfo(leadTimeQuery));
					
				}
				catch(Exception e){
				 leadDays=0;
				 //Utils.log(leadTimeQuery,e);
				}
				safetyStock=(totalSales*80)/100;
				reOrderPoint=(unitSales*leadDays)+safetyStock;
				//Utils.log("uint"+unitSales+"leadDays"+leadDays+"safetyStock"+safetyStock+"reorder"+reOrderPoint+"aval"+available);
				if(available<=reOrderPoint){
				for (int k = 1; k <= coulmns; k++) {
					name = rsMeta.getColumnName(k);
					if(k!=coulmns)
					itemjson.put(rs.getString(name));
					else{
					String transferQuery="select  round(sum(IVD.shipqty),3) "+
					    " from ivtransferdetail IVD, ivtransferheader IVH "+
					    " where  IVH.companyId=IVD.companyId "+
					    " and IVH.transferno=IVD.transferno  "+
					    " and IVH.transferExt=IVD.transferExt "+ 
					    " and IVH.orderstatus in ('E','O','W','A', 'S','C') "+ 
					    //" and IVD.productNo not like 'MEMO%'  "+
					    " and IVD.Whseno is not null  "+
					    " and IVD.productNo='"+rs.getString("productNo")+"' "+
					    " and IVH.shipWhse='"+rs.getString("whseNo")+"' "+
					    " and IVH.companyId='1' ";
					
					String poQuery="select  nvl(round( nvl(extcost('1',im.uom_buy,im.Uom_stock,pd.productno,1,PD.orderqty-PD.totalReceivedQty,'W'),0),3),0) "+
							" from podetail PD, inventoryMaster IM  "+
							" where PD.companyId=IM.companyId  "+
							" and PD.productNo=IM.productNo  "+
							" and PD.productNo='"+rs.getString("productNo")+"' "+
							" and PD.Whseno='"+rs.getString("whseNo")+"' "+
							//" and NVL(IM.updateInventory,'Y')!='N' "+ 
							" and nvl(IM.serviceitem,'N')!='Y'  "+
							" and PD.POType in ('W','S')  "+
							" and PD.Status IN ('E','P')  "+
							" and nvl(PD.orderqty,0)!=0  "+
							" and PD.companyId='1' ";
					String reportCode=getFieldInfo("select code from ivwarehousereportdetail where productno='"+rs.getString("productNo")+"' and Whseno='"+rs.getString("whseNo")+"' ");
					
					double transferOnorder=Utils.parseDouble(getFieldInfo(transferQuery));
					//Utils.log("transferOnorder"+transferOnorder);
					double poOnorder=Utils.parseDouble(getFieldInfo(poQuery));
					//Utils.log("poOnorder"+poOnorder);
					itemjson.put(Utils.getDoublePatternMask(unitSales, 3));
					itemjson.put(Utils.getDoublePatternMask(leadDays, 2));
					itemjson.put(Utils.getDoublePatternMask(safetyStock, 3));
					itemjson.put(Utils.getDoublePatternMask(reOrderPoint, 3));
					itemjson.put(transferOnorder+poOnorder);
					itemjson.put(rs.getString(name));
					itemjson.put(reportCode);
					
					}
						
					}
				json.append("aaData", itemjson);
				}// reOrderpoint
				
				}
			
		} catch (Exception e) {
			Utils.logError(Query, e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(rs);
			Utils.close(st);
			Utils.close(con);
		}

		return json;
	}
 
 public String getDataTableheader(String[] headerArray) throws Exception {
		
		StringBuffer buildHeader=new StringBuffer() ;
		try {
			buildHeader.append("<thead><tr>");	
			for (int k = 0; k <headerArray.length; k++) {
					buildHeader.append("<th>"+headerArray[k]+"</th>");
				}
			buildHeader.append("</tr></thead>");
			
		} catch (Exception e) {
			Utils.log("Error in getJsonFromResultSet()", e);
			throw new ProcessingErrorException(e);
		} 	
		return buildHeader.toString();
	}
 public void buildFaxDirectory(String id, String faxNo, String type) throws Exception {
	 	Connection con = null;
		Statement st = null;	
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="insert into Faxdirectory values('"+id+"','"+faxNo+"','"+type+"')";
			Utils.log(query);
			int count=Utils.parseInt(getFieldInfo("select nvl(count(*),0) from faxDirectory where id='"+id+"' and faxNo='"+faxNo+"' and type='"+type+"'"));
			Utils.log("count"+count);
			if(count==0)
			st.executeUpdate(query);
		} catch (Exception e) {
			Utils.logError("Error in creating fax Dir", e);
			throw new Exception("Error in Jsondataquery: ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
	}
 public String getFaxDirectory(String id, String type) throws Exception {
	 	Connection con = null;
		Statement st = null;	
		ResultSet rs=null;
		StringBuffer faxDirectory=new StringBuffer();
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="select faxNo from faxDirectory where id='"+id+"' and type='"+type+"'";
			Utils.log(query);
			rs=st.executeQuery(query);
			while(rs.next()){
				faxDirectory.append(rs.getString("faxNo")+";");
			}
		} catch (Exception e) {
			Utils.logError("Error in getting fax Dir", e);
			throw new Exception("Error in get fax dir: ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
		return faxDirectory.toString();
	}
 
 public void buildEmailDirectory(String id, String emailId, String type) throws Exception {
	 	Connection con = null;
		Statement st = null;	
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="insert into emaildirectory values('"+id+"','"+emailId+"','"+type+"')";
			Utils.log(query);
			int count=Utils.parseInt(getFieldInfo("select nvl(count(*),0) from emailDirectory where id='"+id+"' and email='"+emailId+"' and type='"+type+"'"));
			Utils.log("count"+count);
			if(count==0)
			st.executeUpdate(query);
		} catch (Exception e) {
			Utils.logError("Error in creating fax Dir", e);
			throw new Exception("Error in build fax dir: ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
	}
 public String getEmailDirectory(String id, String type) throws Exception {
	 	Connection con = null;
		Statement st = null;	
		ResultSet rs=null;
		StringBuffer faxDirectory=new StringBuffer();
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="select distinct email from emailDirectory where id='"+id+"' and type='"+type+"'";
			Utils.log(query);
			rs=st.executeQuery(query);
			while(rs.next()){
				faxDirectory.append(rs.getString("email")+";");
			}
		} catch (Exception e) {
			Utils.logError("Error in getting email Dir", e);
			throw new Exception("Error in get email dir: ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
		return faxDirectory.toString();
	}
 public void createPrintConfirm(String companyId, String documentNo, String type, String user, String printer)throws Exception {
		Connection con = null;
		Statement st = null;	
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="insert into printconfirm " +
					"(companyId, documentno, type, printer, printuser, printdate, status) " +
					"values('"+companyId+"','"+documentNo+"','"+type+"','"+printer+"','"+user+"', sysdate,'E')";
			Utils.log(query);
			st.executeUpdate(query);
			
		} catch (Exception e) {
			Utils.logError("Error in creating print record", e);
			throw new Exception("Error in creating print record ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
 }
 
 
 public void createPrintConfirmForPickTicket(String companyId, String documentNo, String type, String user, String printer, int ticketSeq, String orderExt)throws Exception {
		Connection con = null;
		Statement st = null;	
		try {
			con = getDataConnection();
			st = con.createStatement();
			String query="insert into printconfirm " +
					"(companyId, documentno, type, printer, printuser, printdate, status,TicketSeq,orderExt,Validated ) " +
					"values('"+companyId+"','"+documentNo+"','"+type+"','"+printer+"','"+user+"', sysdate,'E' , '"+ticketSeq+"', '"+orderExt+"' ,'N' )";
			Utils.log("Insert Into printconfirm>>>>>>>"+query);
			st.executeUpdate(query);
			
		} catch (Exception e) {
			Utils.logError("Error in creating print record", e);
			throw new Exception("Error in creating print record ", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}	
}
 
 public String currentQuaterFromDate() throws Exception{
		String fromDate ="";
		String currentQtr = getFieldInfo("select  to_char(sysdate,'Q')  currentQuarter from dual");
		String currentYear = getFieldInfo("select   to_char(sysdate, 'YY')  currentQuarter from dual");
		
		if(currentQtr.equals("1")){
			fromDate ="01-JAN-"+currentYear;
		}else if(currentQtr.equals("2")){
			fromDate ="01-APR-"+currentYear;
		}else if(currentQtr.equals("3")){
			fromDate ="01-JUL-"+currentYear;
		}else if(currentQtr.equals("4")){
			fromDate ="01-OCT-"+currentYear;
		}
	return fromDate;	
	}

public String currentQuaterToDate() throws Exception{
		String toDate ="";
		String currentQtr = getFieldInfo("select  to_char(sysdate,'Q')  currentQuarter from dual");
		String currentYear = getFieldInfo("select   to_char(sysdate, 'YY')  currentQuarter from dual");
		
		if(currentQtr.equals("1")){
			toDate ="31-MAR-"+currentYear;
		}else if(currentQtr.equals("2")){
			toDate ="30-APR-"+currentYear;
		}else if(currentQtr.equals("3")){
			toDate ="30-SEP-"+currentYear;
		}else if(currentQtr.equals("4")){
			toDate ="31-DEC-"+currentYear;
		}
	return toDate;	
	}
//Added by Ranjeet to get data from both connection pool in JSON format
public JSONObject getJSONDataFromQuery(String query, String dbtype) {

	JSONObject jsonReturn = new JSONObject();

	Statement st = null;
	ResultSet rs = null;
	Connection con = null;
	ResultSetMetaData rsMeta = null;

	try {
		DistUtils du = new DistUtils();
		if (dbtype.equals("PRO2")) {
			con = du.getDataConnectionPro2DataSource();
		} else if (dbtype.equals("ETECH")) {
			con = du.getConnection();
		}
		st = con.createStatement();
		//Utils.log("query=" + query);
		rs = st.executeQuery(query);
		rsMeta = rs.getMetaData();
		JSONArray jArray = new JSONArray();
		while (rs.next()) {
			JSONObject jsonRow = new JSONObject();
			int columns = rsMeta.getColumnCount();
			for (int k = 1; k <= columns; k++) {
				String val = "";
				String name = rsMeta.getColumnName(k);
				String type = rsMeta.getColumnTypeName(k);

				if (type.equals("DATE"))
					val = Utils.changeDateFormat(rs.getDate(k));
				else
					val = removeNull(rs.getString(k));

				jsonRow.put(name, val);
			}
			jArray.put(jsonRow);
		}
		
		jsonReturn.put("data", jArray);
		Utils.close(rs);
		Utils.close(st);
		Utils.close(con);
	} catch (Exception e) {
		Utils.log("Exception", e);
		
	}
	finally
	{
		
		Utils.close(rs);
		Utils.close(st);
		Utils.close(con);
	}

	return jsonReturn;

}
public static String removeNull(String str) {
	if (str == null || str.equals(""))
		return "";
	else
		return (str.equals("null") ? "" : str);
}
// change by Ranjeet Ends here


// changes by Sachendra

	public String changeDateFormatAgiltyAPI(String dateString){
		String dateStr ="";
	    if(dateString.trim().equals("")){
	    	dateStr = null;
	    }
	    else{
			if(dateString.trim().matches("{1}[0-9]{4}[-]{1}[0-9]{2}[-][0-9]{2}")){
		   		//SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		   		try {
					//Date d = sdf.parse(dateString);
					//dateStr = sdf.format(d);
		   			dateStr = dateString;
		   			//Utils.log("If Block Date >>> " + dateStr);
		   		} catch (Exception e) {
					Utils.log("Without Date Change Exception  " , e);
				}
		   	}
		   	else{
		   		try{
		   			String replaceString = dateString.replace('/','-');
		   		    SimpleDateFormat dt = new SimpleDateFormat("dd-MM-yyyy");
		   		    Date date = dt.parse(replaceString);
		   		    SimpleDateFormat dt1 = new SimpleDateFormat("yyyy-MM-dd");
		   		    dateStr = dt1.format(date);
		   		    //Utils.log("Else Block Date >>> " + dateStr);
		   		}
		   		catch (Exception e) {
		   			e.printStackTrace();
		   			Utils.log("With Date Change Exception :: " , e);
		   		}
		   	}
	    }
		return dateStr;
	}

	
	public String penskeChangeDateFormatAgiltyAPI(String dateString){
		String dateStr ="";
	   	if(dateString.trim().equals("")){
	   		dateStr = null;
	   	}
	   	else{
			if(dateString.trim().matches("{1}[0-9]{4}[-]{1}[0-9]{2}[-][0-9]{2}")){
	    		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	    		try {
					Date d = sdf.parse(dateString);
					dateStr = sdf.format(d);
	    			//Utils.log("If Block Date >>> " + dateStr);
	    		} catch (Exception e) {
					Utils.log("Without Date Change Exception  " , e);
				}
	    	}
	    	else{
	    		try{
	    			String replaceString = dateString.replace('/','-');
	    		    SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
	    		    Date date = dt.parse(replaceString);
	    		    SimpleDateFormat dt1 = new SimpleDateFormat("yyyy-MM-dd");
	    		    dateStr = dt1.format(date);
	    		    //Utils.log("Else Block Date >>> " + dateStr);
	    		}
	    		catch (Exception e) {
	    			e.printStackTrace();
	    			Utils.log("With Date Change Exception :: " , e);
	    		}
	    	}
	   	}
		return dateStr;
	}
	
	public String processLineText(String lineText) {
		StringBuilder result = new StringBuilder();
	    boolean insideDoubleQuotes = false;
	    char[] charArray = lineText.toCharArray();
		for(int i=0; i<charArray.length; i++){
		      if (charArray[i] == '"') {
	    	  insideDoubleQuotes = !insideDoubleQuotes;
			} else if (charArray[i] == ',' && insideDoubleQuotes) {
	    		continue;
			}
	    	result.append(charArray[i]);
		}
	    return result.toString();
	}
	
// changes by Sachendra Ends here


	// Added by ranjeet 02-05-2024
	public int updateRecord(String query) {
		// need to remove
		Connection con = null;
		Statement smt = null;
		int retval = 0;

		try {
			
			con = getConnection();

			smt = con.createStatement();
			retval = smt.executeUpdate(query);
			Utils.close(smt);
			Utils.close(con);

		} catch (Exception e) {
			Utils.log("Exception", e);

		} finally {
			Utils.close(smt);
			Utils.close(con);
		}

		return retval;
	}
	// Added by ranjeet 08-06-2025
		public int insertRecord(String query) throws Exception{
			// need to remove
			Connection con = null;
			Statement smt = null;
			int retval = 0;

			try {
				
				con = getConnection();

				smt = con.createStatement();
				retval = smt.executeUpdate(query);
				Utils.close(smt);
				Utils.close(con);

			} catch (Exception e) {
				Utils.log("Exception", e);
				throw new Exception("Caught in the insertRecord:- ", e);

			} finally {
				Utils.close(smt);
				Utils.close(con);
			}

			return retval;
		}
	
	public void activityLog(HttpServletRequest request, String module,String activitytype,String activityname,String activitydesc)
	{
		try {
			HttpSession session=request.getSession();
			String userId = (String) session.getAttribute("userId");
			
			activityLog(userId,module, activitytype, activityname, activitydesc);
			
		} catch (Exception e) {
			Utils.log("Exception",e);
		}
	}
	
	public void activityLog(String userid,String module,String activitytype,String activityname,String activitydesc)
	{
		try {
			String slno=getFieldInfo("select nvl(max(slno),0)+1 from activitylog");
			
			String query="insert into activitylog(slno,module,activitytype,activityname,activitydesc,userid,entrydatetime)"
					+ "values("+slno+",'"+module+"','"+activitytype+"','"+activityname+"','"+activitydesc+"','"+userid+"',current_timestamp)";
			updateRecord(query);
		} catch (Exception e) {
			Utils.log("Exception",e);
		}
	}
	
	
}// End of Main Class