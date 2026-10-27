package com.etechlogix.distribution.utils;
import java.util.Hashtable;
import java.util.Vector;
import javax.servlet.http.*;

import java.sql.*;


public interface DistUtilsInterface {

	public Vector branchValues(String companyId) throws Exception;
	public boolean checkCurrentPeriod(String companyId, String date,
			String type, String standardDateFormat) throws Exception;
	public Vector classValues(HttpServletRequest request) throws Exception;
	public String convertNumberIntoWords(String numberStr) throws Exception;
	public Vector departmentValues(String companyId) throws Exception;
	public String fetchCurrentPeriod(String companyId, String period,
			String type, String standardDateFormat) throws Exception;
	public Vector fetchTypes();
	public int generateLineNo(String query) throws Exception;
	public String getComboValues(HttpServletRequest request, String table,
			String module) throws Exception;
	public String getCompanyId();
	public Connection getConnection() throws Exception;
	public String getCurrentPeriod(String companyId, String date, String type,
			String standardDateFormat) throws Exception;
	public double getCustomerBalalnce(String customerId, String companyId)
			throws Exception;
	public int getCustomerDueInvoices(String customerId, String companyId)
			throws Exception;
	public double getCustomerOpenOrderBalalnce(String customerId,
			String companyId) throws Exception;
	public String getData(Hashtable hash, String formFieldName, int pos);
	public Connection getDataConnection() throws Exception;
	public Hashtable getDataFromHashtable(Hashtable uomRequest, Vector fields)
			throws Exception;
	public Hashtable getDataFromQuery(String query) throws Exception;
	public String getDefaultPrinter(HttpSession session) throws Exception;
	public String getDefaultWarehouse(HttpSession session) throws Exception;
	public String getFieldInfo(String Query) throws Exception;
	public Vector getFieldInfo(String Query, int noOfFields) throws Exception;
	public String getFirstFiscalPeriod();
	public double getGlNoAmount(String field, long glNo, String currentPeriod)
			throws Exception;
	public String getImageLocation(String location) throws Exception;
	public int getMaxLineInReport();
	public int getMaxLineInReport(String orientation) throws Exception;
	public int getMaxLineInReport(String companyId, String printerName,
			String orientation) throws Exception;
	public String getPeriodFormat(String companyId, String date, String type,
			String standardDateFormat) throws Exception;
	public Vector getPrinterAddress();
	public Vector getPrinterId();
	public Vector getPrinterLocation();
	public Vector getPrinterNames();
	public Vector getPrinterTypes();
	public int getPrintLimit();
	public int getRecords(String query) throws SQLException, Exception;
	public int getRecords(String tableName, String query) throws SQLException,
			Exception;
	public int getRecordsUnion(String query) throws SQLException, Exception;
	public long getRefreshTimeForApplet();
	public int getSearchLimit();
	public String getStateList(String companyId) throws Exception;
	public boolean isRecordExists(String tableName, Hashtable primKey)
			throws Exception;
	public Vector marketValues(String companyId) throws Exception; 
	public String parseURL(String URL);
	public void setCompanyId(String newComapnyId);
	public void setPrinterNames() throws Exception;
	public void setPrinterNames(String printerType) throws Exception;
	public void setPrinterNamesAll() throws Exception;
	public Vector warehouseValues(String companyId) throws Exception;
	
}