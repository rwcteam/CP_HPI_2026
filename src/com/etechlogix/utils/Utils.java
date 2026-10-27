package com.etechlogix.utils;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Locale;
import java.util.Properties;
import java.util.Random;
import java.util.ResourceBundle;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import oracle.jdbc.pool.OracleDataSource;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.etechlogix.distribution.utils.DistUtils;
import com.jnetdirect.jsql.JSQLDataSource;

public class Utils {

	final static private boolean VERBOSE = true;

	private static final SimpleDateFormat DASH_DATE_FORMAT = new SimpleDateFormat(
			"MM-dd-yyyy");
	private static final SimpleDateFormat DASH_DATE_FORMAT_SHORT = new SimpleDateFormat(
			"MM-dd-yy");
	private static final SimpleDateFormat BACKSLASH_DATE_FORMAT = new SimpleDateFormat(
			"MM/dd/yyyy");
	private static final SimpleDateFormat BACKSLASH_DATE_FORMAT_SHORT = new SimpleDateFormat(
			"MM/dd/yy");

	private static final Logger LOGGER = Logger.getLogger(Utils.class);

	private Properties SystemDefaults;
	private Properties errorMessages = null;
	private String companyId = "";
	private String propertiesFile;
	private Connection con;
	static private SimpleDateFormat logFormatter = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss:SSS");
	private static Random random = new Random(System.currentTimeMillis());
	private static PrintStream logFile = null;
	private NumberFormat currencyFormatter = null;
	private OracleDataSource oracleDataSource = null;
	private JSQLDataSource sqlServerDataSource = null;
	private int databaseType;

	/**
	 * Creates a Utils object and loads the default system properties file
	 * eTechLogix.properties.
	 **/
	public Utils() throws IOException, SQLException {
		this("eTechLogix");
	}

	/**
	 * creates a Utils object and loads properties file specified by parameter
	 * "propertiesFile".
	 **/
	public Utils(String websiteId) throws IOException, SQLException {
		companyId = websiteId;
		propertiesFile = websiteId + ".properties";
		InputStream in = this.getClass().getClassLoader().getResourceAsStream(propertiesFile); 
		SystemDefaults = new Properties();
		SystemDefaults.load(in);
		loadErrorMessageFile();
		currencyFormatter = NumberFormat.getCurrencyInstance(new Locale(
				getLanguageCode(), getCountryCode()));
		String dbType = SystemDefaults.getProperty("DatabaseType", "Oracle");
		if (dbType.equalsIgnoreCase("SQLSERVER"))
			databaseType = 1;
		else
			databaseType = 0;
		createDataSource();
		in.close();
	}

	private void loadErrorMessageFile() throws IOException {
		InputStream in = null;
		try {
			errorMessages = new Properties();
			String errMsgFileName = SystemDefaults.getProperty("ErrorMessages");
			
			in = this.getClass().getClassLoader().getResourceAsStream(errMsgFileName); 
			errorMessages.load(in);
		} catch (Exception e) {
			Utils.logError("Utils.loadErrorMessageFile"+e);
		} finally {
			if (in != null)
				in.close();
		}
	}

	private void createDataSource() throws SQLException {
		switch (databaseType) {
		case 1:
			try {
				sqlServerDataSource = new JSQLDataSource();
				// sqlServerDataSource = new com.inet.tds.TdsDataSource();
				// sqlServerDataSource=null;
				sqlServerDataSource.setURL(getDbUrl());
				// sqlServerDataSource.setServerName("localhost");
				// sqlServerDataSource.setDatabaseName("etl001");
				sqlServerDataSource.setUser(getDbUser());
				sqlServerDataSource.setPassword(getDbPassword());
			} catch (Exception e) {
				Utils.log("error:", e);
			}
			;
			break;
		default:
			oracleDataSource = new OracleDataSource(); // Set Oracle DataSource
			oracleDataSource.setURL(getDbUrl());
			oracleDataSource.setUser(getDbUser());
			oracleDataSource.setPassword(getDbPassword());
		}

	}

	/** Returns Error Message for the errorId */
	public String getErrorMessage(String id) {
		return errorMessages.getProperty(id);
	}

	/** Returns Error Message for the errorId */
	public String getErrorMessageDb(String id, String TableName) {
		return replaceString("<~TABLENAME~>", TableName, errorMessages
				.getProperty(id));
	}

	/** Returns Home directory from the properties file. */
	public String getHomeDirectory() {
		return SystemDefaults.getProperty("HomeDirectory");
	}

	/** Returns HTML directory from the properties file. */
	public String getHTMLDirectory() {
		return SystemDefaults.getProperty("HTMLDirectory");
	}

	/** Returns DataQueueServerHost from the properties file. */
	public String getDataQueueServerHost() {
		return SystemDefaults.getProperty("DataQueueServerHost");
	}

	/** Returns DataQueueServerHost from the properties file. */
	public String getDataQueueServerPort() {
		return SystemDefaults.getProperty("DataQueueServerPort");
	}

	/** Returns Database URL from the properties file. */
	public String getDbUrl() {
		return SystemDefaults.getProperty("DbUrl");
	}

	/** Returns Database User from the properties file. */
	public String getDbUser() {
		return SystemDefaults.getProperty("DbUser");
	}

	/** Returns Database Driver Class from the properties file. */
	public String getDbDriver() {
		return SystemDefaults.getProperty("DbDriver");
	}

	/** Returns Database User's Password from the properties file. */
	public String getDbPassword() {
		return SystemDefaults.getProperty("DbPassword");
	}

	/** Returns Classes directory from the properties file. */
	public String getClassesDirectory() {
		return SystemDefaults.getProperty("ClassesDirectory");
	}

	/** Returns GridApplet directory from the properties file. */
	public String getGridAppletDirectory() {
		return SystemDefaults.getProperty("GridAppletDirectory");
	}

	/** Returns Default Warehouse from the properties file. */
	public String getDefaultWarehouse() {
		return SystemDefaults.getProperty("DEFAULTWAREHOUSE");
	}

	/** Returns Absolute Path */
	public String getAbsolutePath() {
		File file = new File(".");
		return file.getAbsolutePath();
	}

	/** Returns ImageURL */
	public String getImageURL() {
		return SystemDefaults.getProperty("ImageURL");
	}

	/** Returns CatalogImageURL */
	public String getCatalogImageURL() {
		return SystemDefaults.getProperty("CatalogImageURL");
	}

	/** Returns CatalogImagePath */
	public String getCatalogImagePath() {
		return SystemDefaults.getProperty("CatalogImagePath") + "\\";
	}

	/** Returns Country */
	public String getCountry() {
		return SystemDefaults.getProperty("Country");
	}

	/** Returns CountryCode */
	public String getCountryCode() {
		if (SystemDefaults.getProperty("CountryCode") == null)
			return "us";
		else
			return SystemDefaults.getProperty("CountryCode");
	}

	/** Returns LanguageCode */
	public String getLanguageCode() {
		if (SystemDefaults.getProperty("LanguageCode") == null)
			return "en";
		else
			return SystemDefaults.getProperty("LanguageCode");
	}

	/** Returns SMTP Server */
	public String getSMTPServer() {
		return SystemDefaults.getProperty("SMTPServer");
	}

	/**
	 * Loads the page specified by "urlString"and writes it to the "out" Stream.
	 */
	public void showPage(PrintWriter out, String urlString) throws Exception {
		String inputFileName = getHomeDirectory() + File.separatorChar
				+ urlString;
		FileReader fin = new FileReader(inputFileName);
		BufferedReader bfin = new BufferedReader(fin);
		String s;
		while ((s = bfin.readLine()) != null)
			out.println("\n" + s);
		bfin.close();
		fin.close();
	}

	/**
	 * Loads the page specified by "urlString"and returns it as a String.
	 */
	public String loadURL(String urlString) throws IOException {
		String inputFileName = getHTMLDirectory() + urlString;
		FileReader fin = new FileReader(inputFileName);
		BufferedReader bfin = new BufferedReader(fin);
		String s = "", s1 = "";
		while ((s1 = bfin.readLine()) != null)
			s += "\n" + s1;
		bfin.close();
		fin.close();
		return s;
	}

	public static void main(String[] args) {

		System.out.println(Utils.replaceString("'", "''", "Lowe's"));
		String s = "This long string of text should not overflow the window. This long string of text should not overflow the window.This long string of text should not overflow the window. This long string of text should not overflow the window.This long string of text should not overflow the window. This long string of text should not overflow the window.This long string of text should not overflow the window. This long string of text should not overflow the window.This long string of text should not overflow the window. This long string of text should not overflow the window.";
		System.out.println(trimStringWithWhitespace(40, s));
		try {

			System.out.println(convertToSqlDate("03-23-1976".toString()));
			System.out.println(convertToSqlDate("03-23-1978 0:0:0".toString()));
			System.out.println(convertToSqlDate("3/23/1976".toString()));
			System.out.println(convertToSqlDate("7/23/1978 0:0:0".toString()));

			System.out.println(convertToSqlDate("07-18-08".toString()));

			System.out.println(convertToSqlDate("03+23+1976".toString()));

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	// -----------------------------------------------------------
	/**
	 * replaceString ver 1.1 Replaces repeated substrings in a longer input
	 * string with new substrings. Not case sensitive. Returns new manipulated
	 * string after all the replacements.
	 * 
	 * @param oldString
	 *            substring to be replaced with newString
	 * @param newString
	 *            new substring to replace oldString
	 * @param inputString
	 *            original string for manipulation
	 */
	// -----------------------------------------------------------
	public static String replaceString(String oldString, String newString,
			String inputString) {

		int i = -1, startIndex = 0, newStringLength = newString.length();
		while ((i = inputString.indexOf(oldString, startIndex)) != -1) {
			inputString = inputString.substring(0, i) + newString
					+ inputString.substring(i + oldString.length());
			startIndex = i + newStringLength;
		}
		return inputString;
	}

	// It will replace javascript compatible double Quote with \"

	public static String replaceString(String inputString) {
		String oldString = "\"";
		String newString = "\\\"";
		int i = -1, startIndex = 0, newStringLength = newString.length();
		while ((i = inputString.indexOf(oldString, startIndex)) != -1) {
			inputString = inputString.substring(0, i) + newString
					+ inputString.substring(i + oldString.length());
			startIndex = i + newStringLength;
		}
		oldString = "\'";
		newString = "\\\'";
		i = -1;
		startIndex = 0;
		newStringLength = newString.length();
		while ((i = inputString.indexOf(oldString, startIndex)) != -1) {
			inputString = inputString.substring(0, i) + newString
					+ inputString.substring(i + oldString.length());
			startIndex = i + newStringLength;
		}

		return inputString;
	}

	/*
	 * Old One public static String replaceString (String oldString, String
	 * newString, String inputString) { String outputString = ""; int i; for
	 * (i=0; i<inputString.length(); i++) { if (!(inputString.regionMatches
	 * (true, i, oldString, 0, oldString.length()))) outputString +=
	 * inputString.charAt(i); else { outputString += newString; i +=
	 * oldString.length()-1; } //else } //for
	 * log("Utils.replaceString Done..."); return outputString; }
	 */

	/** Writes a String to the default System output stream */
	public static void log(String s) {
		LOGGER.debug(s);
	}

	public static void log(String s, Exception e) {
		LOGGER.debug(s, e);
		e.printStackTrace(System.out);
	}

	public static void logFatal(String s) {
		LOGGER.fatal(s);
	}
	public static void logFatal(String s, Exception e) {
		LOGGER.fatal(s, e);
	}
	
	public static void logInfo(String s) {
		LOGGER.info(s);
	}
	public static void logInfo(String s, Exception e) {
		LOGGER.info(s, e);
	}
	
	public static void logError(String s) {
		LOGGER.error(s);
	}
	public static void logError(String s, Exception e) {
		LOGGER.error(s, e);
	}
	
	public static void logDebug(String s) {
		LOGGER.debug(s);
	}	
	public static void logDebug(String s, Exception e) {
		LOGGER.debug(s, e);
	}
	
	public static void logEntry(String s) {
		LOGGER.info("Entering function '" + s + "'");
	}
	public static void logExit(String s) {
		LOGGER.info("Exiting function '" + s + "'");
	}
	/**
	 * If the input string is "null" it returns an empty string, otherwise
	 * returns the same string.
	 */
	public static String removeNull(String str) {
		if (str == null || str.equals(""))
			return " ";
		else
			return (str.equals("null") ? " " : str);
	}

	/**
	 * it returns phone number in X(XXX)XXX-XXXX format
	 * 
	 * @param phone
	 *            String
	 */
	public static String formatPhone(String phone) {
		if (phone != null) {
			phone = phone.trim();

			if (phone.length() == 7)
				phone = phone.substring(0, 3) + "-" + phone.substring(3);
			else if (phone.length() == 10)
				phone = "(" + phone.substring(0, 3) + ")"
						+ phone.substring(3, 6) + "-" + phone.substring(6);
			else if ((phone.length() == 11) && phone.startsWith("1"))
				phone = "1(" + phone.substring(1, 4) + ")"
						+ phone.substring(4, 7) + "-" + phone.substring(7);
		} else
			phone = "";

		return phone;
	}

	/**
	 * It converts USA state abbreviation to its full state name. If input is
	 * longer than 2 characters or doesn't match, it returns the origional
	 * input. If input matched, it returns its full name.
	 * 
	 * @param state
	 *            String
	 */
	public static String longUSAState(String state) {
		Object obj = state.toUpperCase();
		return (String) longState.get(obj);
	}

	private static Hashtable longState = new Hashtable(53);
	static {
		longState.put("AK", "Alaska");
		longState.put("AL", "Alabama");
		longState.put("AR", "Arkansas");
		longState.put("AZ", "Arizona");
		longState.put("CA", "California");
		longState.put("CO", "Colorado");
		longState.put("CT", "Connecticut");
		longState.put("DC", "Washington DC");
		longState.put("DE", "Delaware");
		longState.put("FL", "Florida");
		longState.put("GA", "Georgia");
		longState.put("HI", "Hawaii");
		longState.put("IA", "Iowa");
		longState.put("ID", "Idaho");
		longState.put("IL", "Illinois");
		longState.put("IN", "Indiana");
		longState.put("KS", "Kansas");
		longState.put("KY", "Kentucky");
		longState.put("LA", "Louisiana");
		longState.put("MA", "Massachusetts");
		longState.put("MD", "Maryland");
		longState.put("ME", "Maine");
		longState.put("MI", "Michigan");
		longState.put("MN", "Minnessota");
		longState.put("MO", "Missouri");
		longState.put("MS", "Mississippi");
		longState.put("MT", "Montana");
		longState.put("NC", "North Carolina");
		longState.put("ND", "North Dakota");
		longState.put("NE", "Nebraska");
		longState.put("NH", "New Hampshire");
		longState.put("NJ", "New Jersey");
		longState.put("NM", "New Mexico");
		longState.put("NV", "Nevada");
		longState.put("NY", "New York");
		longState.put("OH", "Ohio");
		longState.put("OK", "Oklahoma");
		longState.put("OR", "Oregon");
		longState.put("PA", "Pennsylvania");
		longState.put("PR", "Peurto Rico");
		longState.put("RI", "Rhone Island");
		longState.put("SC", "South Carolina");
		longState.put("SD", "South Dakota");
		longState.put("TN", "Tennessee");
		longState.put("TX", "Texas");
		longState.put("UT", "Utah");
		longState.put("VI", "Virgin Islands");
		longState.put("VA", "Virginia");
		longState.put("VT", "Vermont");
		longState.put("WA", "Washington");
		longState.put("WI", "Wisconsin");
		longState.put("WV", "West Virginia");
		longState.put("WY", "Wyoming");
	}

	/**
	 * returns a String Type form parameter. if it does not exist, throws
	 * exception.
	 */
	public static String getParameterString(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		else
			return res.trim();
	}

	/**
	 * returns a String Type form parameter. if it does not exist, thorw
	 * InvalidParameter exception.
	 */
	public static String getParameterString(String paramName, boolean required,
			HttpServletRequest request) throws ParameterNotFoundException,
			DataNotFoundException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		if (res.equals("") && required)
			throw new DataNotFoundException(paramName);

		else
			return res.trim();
	}

	/**
	 * returns a Integer type Form parameter. if it does not exist, returns 0.
	 */
	public static long getParameterLong(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0;
			else
				return Long.parseLong(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterLong: ", e);
			throw new InvalidParameterException(paramName + "&&" + "number");
		}
	}

	/**
	 * returns a Integer type Form parameter. if it does not exist, returns 0.
	 */
	public static long getParameterLong(String paramName, boolean required,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0;
			else
				return Long.parseLong(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterLong: ", e);
			throw new InvalidParameterException(paramName + "&&" + "number");
		}
	}

	/**
	 * returns a Integer type Form parameter. if it does not exist, returns 0.
	 */
	public static int getParameterInteger(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0;
			else
				return Integer.parseInt(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterInteger: ", e);
			throw new InvalidParameterException(paramName + "&&" + "number");
		}
	}

	/**
	 * returns a Integer type Form parameter. if it does not exist, returns 0.
	 */
	public static int getParameterInteger(String paramName, boolean required,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		// throws Exception { //ParameterNotFoundException
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0;
			else
				return Integer.parseInt(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterInteger: ", e);
			throw new InvalidParameterException(paramName + "&&" + "number");
		}
	}

	/**
	 * returns a Double type Form parameter. if it does not exist, returns 0.
	 */
	public static double getParameterDouble(String paramName,
			int leftPrecision, int rightPrecision, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException {
		String res;
		double num;
		leftPrecision = leftPrecision - rightPrecision;
		String format = "";
		// if(leftPrecision==0){format+="0";leftPrecision=1;}

		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0.0;
			boolean valid = false;
			if (res.indexOf(".") == -1)
				res += ".";
			String left = res.substring(0, res.indexOf("."));
			String right = res.substring(res.indexOf(".") + 1);
			for (int i = 0; i < leftPrecision; i++)
				format += "0";
			format += ".";
			for (int i = 0; i < rightPrecision; i++)
				format += "0";
			valid = ((left.length() <= leftPrecision) && (right.length() <= rightPrecision));
			if (!valid)
				throw new InvalidParameterException(paramName + "&&" + format);
			num = Double.parseDouble(res);

			return num;
		} catch (NumberFormatException e) {
			for (int i = 0; i < leftPrecision; i++)
				Utils.logError("Utils.getParameterDouble: ", e);
			throw new InvalidParameterException(paramName + "&&" + format);
		}
	}

	/**
	 * returns a Double type Form parameter. if it does not exist, returns 0.
	 */
	public static double getParameterDouble(String paramName, boolean required,
			int leftPrecision, int rightPrecision, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException,
			DataNotFoundException {
		String res;
		double num;
		leftPrecision = leftPrecision - rightPrecision;
		String format = "";

		// if(leftPrecision==0){format+="0";leftPrecision=1;}

		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals("") && required)
				throw new DataNotFoundException(paramName);
			boolean valid = false;
			if (res.indexOf(".") == -1)
				res += ".";
			String left = res.substring(0, res.indexOf("."));
			String right = res.substring(res.indexOf(".") + 1);
			for (int i = 0; i < leftPrecision; i++)
				format += "0";
			format += ".";
			for (int i = 0; i < rightPrecision; i++)
				format += "0";
			valid = ((left.length() <= leftPrecision) && (right.length() <= rightPrecision));
			if (!valid)
				throw new InvalidParameterException(paramName + "&&" + format);
			num = Double.parseDouble(res);

			return num;
		} catch (NumberFormatException e) {
			for (int i = 0; i < leftPrecision; i++)
				Utils.logError("Utils.getParameterDouble: ", e);
			throw new InvalidParameterException(paramName + "&&" + format);
		}
	}

	/**
	 * returns a Double type Form parameter. if it does not exist, returns 0.
	 * will be remove later
	 */
	public static double getParameterDouble(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			throw new ParameterNotFoundException(paramName);
		res = res.trim();
		try {
			if (res.equals(""))
				return 0.0;
			else
				return Double.parseDouble(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterDouble: ", e);
			throw new InvalidParameterException(paramName);
		}
	}
	
	public static double getParameterDoubleValue(String paramName,
			String value) throws ParameterNotFoundException,
			InvalidParameterException {
		String res;
		//res = request.getParameter(paramName);
		if (value == null)
			throw new ParameterNotFoundException(paramName);
		res = value.trim();
		try {
			if (res.equals(""))
				return 0.0;
			else
				return Double.parseDouble(res);
		} catch (NumberFormatException e) {
			Utils.logError("Utils.getParameterDouble: ", e);
			throw new InvalidParameterException(paramName);
		}
	}

	/**
	 * returns a Date type Form parameter. if it does not exist, throws
	 * exception.
	 */
	public static java.util.Date getParameterDate(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {
		String dt = request.getParameter(paramName);
		if (dt == null)
			throw new ParameterNotFoundException(paramName);
		dt = dt.trim();
		if (dt.equals(""))
			return null;
		try {
			return new GregorianCalendar(Integer.parseInt(dt.substring(6, 10)),
					Integer.parseInt(dt.substring(0, 2)) - 1, Integer
							.parseInt(dt.substring(3, 5))).getTime();
		} catch (Exception e) {
			Utils.logError("Utils.getParameterDate: ", e);
			throw new InvalidParameterException(paramName + "&&" + "mm-dd-yyyy");
		}
	}

	/**
	 * returns a java.sql.Date type Form parameter. if it does not exist, throws
	 * exception.
	 */
	public static java.sql.Date getParameterSqlDate(String paramName,
			HttpServletRequest request) throws ParameterNotFoundException,
			InvalidParameterException {

		String dt = request.getParameter(paramName);
		if (dt == null)
			throw new ParameterNotFoundException(paramName);
		dt = dt.trim();
		if (dt.equals(""))
			return null;
		try {
			return new java.sql.Date(new GregorianCalendar(Integer.parseInt(dt
					.substring(6, 10)),
					Integer.parseInt(dt.substring(0, 2)) - 1, Integer
							.parseInt(dt.substring(3, 5))).getTime().getTime());
		} catch (Exception e) {
			Utils.logError("Utils.getParameterSqlDate: ", e);
			throw new InvalidParameterException(paramName + "&&" + "mm-dd-yyyy");
		}
	}

	/**
	 * returns a java.sql.Date type Form parameter. if it does not exist, throws
	 * exception.
	 */
	public static java.sql.Date getParameterSqlDate(String paramName,
			boolean required, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException,
			DataNotFoundException {

		String dt = request.getParameter(paramName);
		if (dt == null)
			throw new ParameterNotFoundException(paramName);
		dt = dt.trim();
		if (dt.equals("") && required)
			throw new DataNotFoundException(paramName);
		try {
			return new java.sql.Date(new GregorianCalendar(Integer.parseInt(dt
					.substring(6, 10)),
					Integer.parseInt(dt.substring(0, 2)) - 1, Integer
							.parseInt(dt.substring(3, 5))).getTime().getTime());
		} catch (Exception e) {
			Utils.logError("Utils.getParameterSqlDate: ", e);
			throw new InvalidParameterException(paramName + "&&" + "mm-dd-yyyy");
		}
	}

	/**
	 * returns a Date string in "mm-dd-yyyy" format. if it does not exist,
	 * throws exception.
	 */
	public static String getParameterSqlDateMMDDYYYY(String paramName,
			HttpServletRequest request) throws Exception {
		return new SimpleDateFormat("mm-dd-yyyy").format(request
				.getParameter(paramName));
	}

	/**
	 * returns nos of rows in a file. if it does not exist, throws exception.
	 */
	public static int getFileRow(FileInputStream fin) throws Exception {

		int rows = 0;
		int c = 0;
		try {
			while ((c = fin.read()) != -1) {
				if (c == '\n')
					rows++;
			}
		} catch (Exception e) {
			throw new Exception("Could Not read File " + fin);
		}

		return rows;
	}

	public static String setLength(String str, int length) {
		if (str.length() >= length)
			str = str.substring(0, length);

		StringBuffer strbuf = new StringBuffer(str);
		while (strbuf.length() < length)
			strbuf.append(' ');
		return strbuf.toString().substring(0, length);

	}

	void setCompanyId(String companyId) {
		this.companyId = companyId;
	}

	String getCompanyId() {
		return companyId;
	}

	String getDQServerName() {
		return SystemDefaults.getProperty("DQServerName");
	}

	String getDQServerPort() {
		return SystemDefaults.getProperty("DQServerPort");
	}

	public static String generateID() {
		return String.valueOf(System.currentTimeMillis())
				+ String.valueOf(random.nextLong());
	}

	public String getMainPage() {
		return SystemDefaults.getProperty("MainPage");
	}

	public int getImageWidth() {
		// int width;
		try {
			return Integer.parseInt(SystemDefaults.getProperty("ImageWidth"));
		} catch (Exception e) {
			return 0;
		}
	}

	public int getImageHeight() {
		// int height;
		try {
			return Integer.parseInt(SystemDefaults.getProperty("ImageHeight"));
			// return height;
		} catch (Exception e) {
			return 0;
		}
	}

	/**
	 * converts a date from "mm-dd-yyyy" formate to java.sql.Date
	 */
	public static java.sql.Date convertToSqlDate(String dateString)
			throws Exception {

		if (dateString == null || dateString.trim().length() < 8) {
			return null;
		}

		String trimmed = dateString.trim();
		int trimLength = 10;
		if (trimmed.length() < 10) {
			trimLength = trimmed.length();
		}
		trimmed = trimmed.substring(0, trimLength);

		if (trimmed.indexOf("/") != -1) {
			if (trimmed.length() == 8)
				return convertToSqlDate(BACKSLASH_DATE_FORMAT_SHORT
						.parse(trimmed));
			else
				return convertToSqlDate(BACKSLASH_DATE_FORMAT.parse(trimmed));
		} else if (trimmed.indexOf("-") != -1) {
			if (trimmed.length() == 8)
				return convertToSqlDate(DASH_DATE_FORMAT_SHORT.parse(trimmed));
			else
				return convertToSqlDate(DASH_DATE_FORMAT.parse(trimmed));
		}

		throw new RuntimeException(
				"Attempt to convertToSqlDate with invalid date format, supports mm-dd-yyyy or mm/dd/yyyy");

	}

	/**
	 * converts a date from java.lang.Data to java.sql.Date
	 */
	public static java.sql.Date convertToSqlDate(java.util.Date dt)
			throws Exception {
		java.sql.Date res;
		try {
			res = new java.sql.Date(dt.getTime());
		} catch (Exception e) {
			throw new Exception("Invalid Date");
		}
		return res;
	}

	public void openLogFile(String file) {
		// logFile = new FileWriter("eTechLogix.log");
	}

	public static void logToFile(String str) {
		try {
			if (VERBOSE) {
				if (logFile == null)
					logFile = new PrintStream(new FileOutputStream(
							"eTechLogix.log"));
				;
				// logFile.println("Log:["+logFormatter.format( new
				// GregorianCalendar().getTime())+"] "+str);
				logFile.println(logFormatter.format(Calendar.getInstance()
						.getTime())
						+ ","
						+ Calendar.getInstance().getTime().getTime()
						+ "," + str);

			}
		} catch (Exception e) {
			Utils.logError("Utils.logToFile", e);
		}
	}

	public static void printFormInfo(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			PrintWriter out = response.getWriter();
			out.println("<br>Path info            : " + request.getPathInfo());
			out.println("<br>Query String         : "
					+ request.getQueryString());
			out.println("<br>Remote User          : "
							+ request.getRemoteUser());
			out.println("<br>Remote Host          : "
							+ request.getRemoteHost());
			out.println("<br>Requested SessionId  : "
					+ request.getRequestedSessionId());
			out.println("<br>Requested URL        : "
							+ request.getRequestURI());
			out.println("<br>Servlet Path         : "
					+ request.getServletPath());
			out.println("<br>Form Variables       : ");
			// String param = null;
			// for (Enumeration en = request.getParameterNames();
			// en.hasMoreElements();param = en.nextElement().toString())
			// out.println("<br>Param-"+param+"    : "+request.getParameter(param
			// ));
			out.close();
		} catch (Exception e) {
			Utils.logError("Utils.printFormInfo", e);
		}

	} // printFormInfo

	/**
	 * This method connects to database for current user
	 * 
	 * @return Connection
	 */

	public Connection connectDatabase() throws SQLException {
		Connection connection;
		try {
			switch (databaseType) {
			// case 1: connection = sqlServerDataSource.getConnection();break;
			default:
				connection = oracleDataSource.getConnection();
			}
			connection.setAutoCommit(false);
		} catch (SQLException e) {
			Utils.logError("[" + getDbUrl() + "," + getDbUser() + ","
					+ getDbPassword() + "]", e);
			throw e;

		}
		return connection;
	}

	/**
	 * This method returns the database connection
	 * 
	 * @return Connection
	 */
	public Connection getDBConnection() {
		return con;
	}

	/**
	 * This method checks if database is connected
	 * 
	 * @return boolean
	 */
	public boolean dbConnected() {
		return con != null;
	}

	/**
	 * This method creates the error message page.
	 * 
	 * @param out
	 *            PrintWriter
	 * @param message
	 *            String
	 */
	public static void errorPage(PrintWriter out, String message) {
		out.println("<html>");
		out.println("<head><title>Register Error</title>");
		out.println("<script language=\"JavaScript\"><!--");
		out.println("  function buttonActive() {");
		out.println("    document.BACKBUTTON.src = \"../Images/backButton2.gif\"");
		out.println("    return true;}");
		out.println("  function buttonDeactive(btname) {");
		out.println("    document.BACKBUTTON.src = \"../Images/backButton1.gif\"");
		out.println("    return true;}//--></script></head>");

		out.println("<body background=\"../Images/greyline.gif\">");
		out.println("<table border=\"1\" width=\"100%\">");
		out.println("<tr><td width=\"100%\" bgcolor=\"#0066CC\"><font face=\"Times New Roman\" size=\"3\" color=\"#FFFFFF\"><b>&nbsp&nbspError...</b></font></td></tr>");
		out.println("<tr><td width=\"100%\" bgcolor=\"#FFFFE8\"><font face=\"Times New Roman\" size=\"3\" color=\"#000000\"><br>&nbsp&nbsp<b>"
						+ message + "</b><br><br></font></td></tr>");
		out.println("</table><br>");
		out.println("<img name=\"BACKBUTTON\" border=\"0\" src=\"../Images/backButton1.gif\" width=\"79\" height=\"29\" alt=\"Back to previous page\"  OnMouseOver=\"buttonActive('backButton')\" OnMouseOut=\"buttonDeactive('backButton')\" OnClick=\"history.go(-1)\">");
		out.println("<center><img border=\"0\" src=\"../Images/logo-original.jpg\" width=\"259\" height=\"149\"></center>");
		out.println("</body></html>");
	}

	/**
	 * This method creates the error message page.
	 * 
	 * @param out
	 *            PrintWriter
	 * @param message
	 *            String
	 * @param loginError
	 *            boolean set it to true if you want to show the login button
	 */
	public static void errorPage(PrintWriter out, String message,
			boolean loginError) {
		out.println("<html>");
		out.println("<head><title>User Login Error Page</title>");
		out.println("<script language=\"JavaScript\"><!--");
		out.println("  function buttonActive(btname) {");
		out.println("    if (btname == 'loginbutton')");
		out
				.println("      document.LOGINBUTTON.src = \"../Images/\"+btname+\"2.gif\";");
		out.println("    else");
		out
				.println("      document.BACKBUTTON.src = \"../Images/\"+btname+\"2.gif\"");
		out.println("    return true;}");
		out.println("  function buttonDeactive(btname) {");
		out.println("    if (btname == 'loginbutton')");
		out
				.println("      document.LOGINBUTTON.src = \"../Images/\"+btname+\"1.gif\";");
		out.println("    else");
		out
				.println("      document.BACKBUTTON.src = \"../Images/\"+btname+\"1.gif\"");
		out.println("    return true;}//--></script></head>");
		out.println("<body background=\"../Images/greyline.gif\">");

		out.println("<table border=\"1\" width=\"100%\">");
		out
				.println("<tr><td width=\"100%\" bgcolor=\"#0066CC\"><font face=\"Times New Roman\" size=\"3\" color=\"#FFFFFF\"><b>&nbsp&nbspError...</b></font></td></tr>");
		out
				.println("<tr><td width=\"100%\" bgcolor=\"#FFFFE8\"><font face=\"Times New Roman\" size=\"3\" color=\"#000000\"><br>&nbsp&nbsp<b>"
						+ message + "</b><br><br></font></td></tr>");
		out.println("</table><br>");

		if (loginError)
			out
					.println("<a href=\"../html/AdminLogin.html\" OnMouseOver=\"buttonActive('loginbutton')\" OnMouseOut=\"buttonDeactive('loginbutton')\"><img name=\"LOGINBUTTON\" border=\"0\" src=\"../Images/loginbutton1.gif\" width=\"79\" height=\"29\" alt=\"Go to Login page\"></a> ");

		out
				.println("<img name=\"BACKBUTTON\" border=\"0\" src=\"../Images/backButton1.gif\" width=\"79\" height=\"29\" alt=\"Back to previous page\"  OnMouseOver=\"buttonActive('backButton')\" OnMouseOut=\"buttonDeactive('backButton')\" OnClick=\"history.go(-1)\">");
		out.println("</body></html>");
	}

	/**
	 * This method returns a HTML table with error message title and message
	 * body. It doesn't do much. I just wrote this to impress my boss.
	 * 
	 * @param msgTitle
	 *            String
	 * @param msg
	 *            String
	 * @return String with <CODE>HTML</CODE> code
	 */
	public static String errorMsgTable(String msg) {
		return "<div id=\"Message\"><table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" bgcolor=\"#FF0000\">"
				+ "<tr> <td><font size=\"2\" face=\"Verdana, Arial, Helvetica, sans-serif\""
				+ "color=\"#99FF00\"><b>"
				+ msg
				+ "</b> </font></td> </tr></table></div>";
	}

	/**
	 * This method returns a HTML table with error message title and message
	 * body. It doesn't do much. I just wrote this to impress my boss.
	 * 
	 * @param msgTitle
	 *            String
	 * @param msg
	 *            String
	 * @return String with <CODE>HTML</CODE> code
	 */
	public static String errorMsgTable(String msgTitle, String msg) {
		return "<table border=\"1\" width=\"100%\">"
				+ "<tr><td width=\"100%\" bgcolor=\"#0066CC\"><font face=\"Times New Roman\" size=\"3\" color=\"#FFFFFF\"><b>&nbsp&nbspError...</b></font></td></tr>"
				+ "<tr><td width=\"100%\" bgcolor=\"#FFFFE8\"><font face=\"Times New Roman\" size=\"3\" color=\"#000000\"><br>&nbsp&nbsp<b>"
				+ msg + "</b><br><br></font></td></tr>" + "</table>";
	}

	/**
	 * This method gets <CODE>adminPassword</CODE> from <CODE>.property</CODE>
	 * file
	 * 
	 * @return String
	 */
	public String getAdminPassword() {
		return SystemDefaults.getProperty("AdminPassword");
	}

	/**
	 * It returns a HTML table with current session status.
	 * 
	 * @param session
	 *            HttpSession
	 * @return String
	 */
	public static String checkSessionStatus(HttpSession session) {
		String result = "<center><table border=\"1\" width=\"65%\" bgcolor=\"#99CC00\" cellspacing=\"0\" cellpadding=\"0\">"
				+ "<tr><td width=\"100%\" bgcolor=\"#008000\" colspan=\"2\"><p align=\"center\"><font face=\"Times New Roman\" size=\"3\" color=\"#FFFFFF\"><b>Http Session Attributes</b></font></td></tr>";
		if (session != null) {
			Enumeration en = session.getAttributeNames();

			if (en != null)
				while (en.hasMoreElements()) {
					String name = (String) en.nextElement();
					String value = session.getAttribute(name).toString();
					result += "<tr><td width=\"30%\">" + name
							+ "</td><td width=\"70%\">" + value + "</td></tr>";
				}

			result += "<tr><td width=\"30%\">Creation Time</td><td width=\"70%\">"
					+ new java.util.Date(session.getCreationTime()).toString()
					+ "</td></tr>";
			result += "<tr><td width=\"30%\">Last Accessed TIme</td><td width=\"70%\">"
					+ new java.util.Date(session.getLastAccessedTime())
							.toString() + "</td></tr>";
			result += "</table></center>";
		}

		return result;
	}

	/**
	 * This method gets the table property file directory from
	 * <CODE>.property</CODE> file
	 * 
	 * @return String
	 */
	public String getTablePropertyFileDir() {
		return SystemDefaults.getProperty("TablePropertyFileDirectory");
	}

	/**
	 * Convert <code>String</code> to <code>Color</code>. The value of string
	 * color could be any of the following.
	 * <ol>
	 * <li>Java constant colors - red, black, yellow, ... etc.
	 * <li>Hexidecimal numbers - 0xFF0000 (red), 0x00FF00 (green), 0x0000FF
	 * (blue), ... etc.
	 * <li>Octal numbers - 0 (black), 07777777777 (white), and others ... figure
	 * it out urself... :P
	 * </ol>
	 * 
	 * @param color
	 *            String
	 * @return Color
	 */
	public static Color strToColor(String color) {
		color = color.toUpperCase();

		if (color.startsWith("0"))
			return Color.decode(color);
		else {
			Color c = (Color) colorString.get(color.toUpperCase());
			if (c == null)
				c = Color.black;
			return c;
		}
	}

	public static Hashtable colorString = new Hashtable();
	static {
		colorString.put("BEIGE", new Color(221, 164, 147));
		colorString.put("BLACK", Color.black);
		colorString.put("BLUE", Color.blue);
		colorString.put("CYAN", Color.cyan);
		colorString.put("DARKGRAY", Color.darkGray);
		colorString.put("GRAY", Color.gray);
		colorString.put("GREEN", Color.green);
		colorString.put("LIGHTGRAY", Color.lightGray);
		colorString.put("MAGENTA", Color.magenta);
		colorString.put("ORANGE", Color.orange);
		colorString.put("PINK", Color.pink);
		colorString.put("RED", Color.red);
		colorString.put("TAN", new Color(231, 221, 211));
		colorString.put("WHITE", Color.white);
		colorString.put("YELLOW", Color.yellow);
	}

	/**
	 * This method converts something like 1/2 to 0.5 where 1/2 is a
	 * <code>String
   * </code> and the return value 0.5 is a double.
	 * 
	 * @param fractionString
	 *            String (Its name is obvious enough of what its type is)
	 * @return double
	 */
	public static double convertFractionStrToDouble(String fractionString) {
		double result = Double.NaN;
		int i = fractionString.indexOf("/");

		if (i > 0) {
			try {
				double n = new Double(fractionString.substring(0, i))
						.doubleValue();
				double d = new Double(fractionString.substring(i + 1))
						.doubleValue();
				if (d != 0) {
					result = n / d;
				}
			} catch (NumberFormatException e) {
				Utils.logError("Invalid nominator" + e.getMessage());
			}
		}

		return result;
	}

	/**
	 * This method is for people who write applet that has compatible problems
	 * with <code>Math.toRadians()</code> method in Java 2. If you are not
	 * writing applet, please use <code>Math.toRadians()</code> instead.
	 * 
	 * @param degree
	 *            double
	 * @return double
	 */
	public static double toRadians(double degree) {
		return Math.PI * degree / 180.0;
	}

	/**
	 * This method takes two sets of Latitude and Longitude on the Earth and
	 * returns the distance between these two points. This formula uses <b>arc
	 * cosine</b> to do the calculation. Some database system doesn't support
	 * <b>arc cosine</b>. If this happened, you need to use <b>arc tangent</b>
	 * to work around and replace <b>arc cosine</b>. <font face="Comic Sans MS"
	 * color="#0000FF"> Oracle DOES support arc cosine, and thank God fot
	 * that!</font>
	 * <p>
	 * This formula also uses <code>Math.toRadians</code> method to convert
	 * Latitude and Longitude to radians. Currently, <code>Applet</code> doesn't
	 * support <code>Math.toRadians </code>; it will cause <b>"Class not Found"
	 * exception. </b> If this happened, you may use
	 * <code>Utils.toRadians</code> method instead.
	 * 
	 * @param lat1
	 *            double 1st Latitude
	 * @param lon1
	 *            double 1st Longitude
	 * @param lat2
	 *            double 2nd Latitude
	 * @param lon2
	 *            double 2nd Longitude
	 */
	public static double getLatLonDistance(double lat1, double lon1,
			double lat2, double lon2) {
		lat1 = Math.toRadians(lat1);
		lat2 = Math.toRadians(lat2);
		lon1 = Math.toRadians(lon1);
		lon2 = Math.toRadians(lon2);

		return 3963 * Math.acos(Math.sin(lat1) * Math.sin(lat2)
				+ Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1));
	}

	public static void returnSamePage(HttpServletRequest request,
			PrintWriter out) throws IOException {
		String str = null;
		BufferedReader inp = request.getReader();
		str = inp.readLine();
		while (str != null) {
			out.println(str);
			str = inp.readLine();
		}
		inp.close();
	}

	public static String getRequestPage(HttpServletRequest request)
			throws IOException {
		String str = null;
		StringBuffer result = new StringBuffer("");
		BufferedReader inp = request.getReader();
		str = inp.readLine();
		Utils.log("getRequestPage.Before while");
		while (str != null) {
			result.append(str);
			str = inp.readLine();
		}
		Utils.log("getRequestPage.After while");
		inp.close();
		Utils.log("getRequestPage.before return");
		return result.toString();
	}

	/*
	 * The Oracle Error code when child record voilation Error due to a attempt
	 * to delete a record from a master
	 */
	public String getChildKey() {
		String childKey = SystemDefaults.getProperty("ChildKey");
		if (childKey != null)
			return childKey;
		else
			return "2292";
	}

	// The Oracle Error code when paren record voilation
	public String getParentKey() {
		String parentKey = SystemDefaults.getProperty("ParentKey");
		if (parentKey != null)
			return parentKey;
		else
			return "2291";
	}

	/*
	 * The Oracle Error code when Unique Value voilation Error due to a attempt
	 * to add duplicate value for a column
	 */
	public String getUniqueKey() {
		String uniqueKey = SystemDefaults.getProperty("UniqueKey");
		if (uniqueKey != null)
			return uniqueKey;
		else
			return "00001";
	}

	// Chnage date format from yyyy-mm-dd to mm-dd-yyyy
	public static String changeDateFormat(java.sql.Date dt) throws Exception {
		String newFormat = "";
		if (dt == null)
			return " ";
		try {
			String str = dt.toString();
			newFormat = str.substring(5, 7) + "-" + str.substring(8, 10) + "-"
					+ str.substring(0, 4);
		} catch (Exception e) {
			throw new Exception("Problem with date format " + e);
		}
		return newFormat;
	}

	/*
	 * To retrieve the value form a checkbox in the HTML form
	 */

	public static String getParameterCheck(String paramName,
			HttpServletRequest request) {
		String res;
		res = request.getParameter(paramName);
		if (res == null)
			res = "N";
		return res;
	}

	/*
	 * this function will return Enumeration of all Error Keys in error messages
	 * properties file
	 */

	public Enumeration getAllErrorCodes() {
		Enumeration enum1 = errorMessages.propertyNames();
		return enum1;
	}

	// Returns all the properties in the ErrorMessage File
	public Properties getErrorMessages() {
		return errorMessages;
	}

	/**
	 * Loads the page specified by "urlString"and returns it as a String.
	 */
	/*
	 * public static String loadFile(String urlString ) throws IOException {
	 * String inputFileName = urlString; FileReader fin = new
	 * FileReader(inputFileName); BufferedReader bfin = new BufferedReader(fin);
	 * String s="", s1=""; while ((s1 = bfin.readLine())!=null) s+= "\n"+s1;
	 * bfin.close(); fin.close(); return s; }
	 */
	public static String loadFile(String urlString) throws IOException {
		StringBuffer sb = new StringBuffer();

		try {

			FileReader fin = new FileReader(urlString);
			BufferedReader bfin = new BufferedReader(fin);

			String line = null;

			while ((line = bfin.readLine()) != null) {
				sb.append(line).append("\n");
			}

			bfin.close();
			fin.close();

		} catch (Exception e) {
			Utils.logError("Utils.loadFile " + e.getMessage() + " urlString: " + urlString, e);
		}
		return sb.toString();
	}

	// For handelling textarea of html form
	public static String changeCarriageReturn(String inputString) {
		// String out = "";
		int foundAt = -1;
		String temp = inputString;
		if (temp == null || temp.equals(""))
			return "";
		while ((foundAt = temp.indexOf('\r', foundAt + 1)) != -1) {

			String s1 = temp.substring(0, foundAt);
			String s2 = temp.substring(foundAt + 1, temp.length());
			temp = s1 + "" + s2;

		}
		foundAt = 0;
		while ((foundAt = temp.indexOf('\n', foundAt + 1)) != -1) {

			String s1 = temp.substring(0, foundAt);
			String s2 = temp.substring(foundAt + 1, temp.length());
			temp = s1 + "\\n" + s2;

		}

		return temp;
	}

	// Utils parseDouble

	/**
	 * returns a Double type Form parameter. if it does not exist, returns 0.
	 * will be remove later
	 */
	public static double parseDouble(String str) throws Exception {

		// double value = 0;

		if (str == null || (str.trim()).equals(""))
			return 0.0;
		else
			try {
				return Double.parseDouble(str);
			} catch (NumberFormatException e) {
				Utils.logError("Utils.parseDouble: ", e);
				throw new Exception("Error in parseDouble");
			}
	}

	// Utils parseInteger

	/**
	 * returns a Double type Form parameter. if it does not exist, returns 0.
	 */
	public static int parseInt(String str) throws Exception {

		// double value = 0;
		if (str == null || (str.trim()).equals(""))
			return 0;
		else
			try {
				return Integer.parseInt(str);
			} catch (NumberFormatException e) {
				Utils.log("Utils: Error in parseInteger: ", e);
				throw new Exception("Error in parseInteger");
			}
	}

	/**
	 * returns a long type Form parameter. if it does not exist, returns 0.
	 */
	public static long parseLong(String str) throws Exception {

		// long value = 0;
		if (str == null || (str.trim()).equals(""))
			return 0;
		else
			try {
				return Long.parseLong(str);
			} catch (NumberFormatException e) {
				Utils.log("Utils: Error in ParseLong: ", e);
				throw new Exception("Error in ParseLong");
			}
	}

	public static java.sql.Date getCurrentDate() throws Exception {
		return new java.sql.Date(new Date().getTime());
	}

	/**
	 * returns double, for the given pattern for any double value, throws
	 * exception.
	 */
	public static double getDoublePattern(double value, String pattern)
			throws Exception {

		double changeValue = 0;
		try {
			DecimalFormat nd = new DecimalFormat();
			nd.applyPattern(pattern);
			changeValue = Double.parseDouble(nd.format(value));
		} catch (Exception e) {
			throw new Exception("Could Not change Format ");
		}

		return changeValue;
	}

	public String formatCurrency(Object value) {
		return currencyFormatter.format(value);
	}

	public String formatCurrency(double value) {
		return currencyFormatter.format(value);
	}

	public String formatCurrency(int value) {
		return currencyFormatter.format(value);
	}

	public String getImportHome() {
		return SystemDefaults.getProperty("ImportHome", "");
	}

	public String getImportEnclosed() {
		return SystemDefaults.getProperty("ImportEnclosed", "");
	}

	public void updateAccessLog(HttpServletRequest request, String accessType)
			throws SQLException, Exception {

		Connection connection = null;
		PreparedStatement pstmt = null;
		Statement stmt = null;
		ResultSet resultSet = null;
		String ipAddress = request.getRemoteAddr(), query = "";
		String hostName = request.getRemoteHost();
		Timestamp accessTime = new Timestamp(new GregorianCalendar().getTime()
				.getTime());
		try {
			connection = connectDatabase();
			stmt = connection.createStatement();
			query = "select * from accesslog where AccessType='" + accessType
					+ "' and IPADDRESS='" + ipAddress + "' and hostName='"
					+ hostName + "' ";
			resultSet = stmt.executeQuery(query);
			if (resultSet.next()) { // incremenet update count and set date
				long count = resultSet.getLong("AccessCount") + 1;
				query = "update accesslog set accesscount=accesscount+1, lastaccess=? where AccessType='"
						+ accessType
						+ "' and IPADDRESS='"
						+ ipAddress
						+ "' and hostName='" + hostName + "' ";
				pstmt = connection.prepareStatement(query);
				// pstmt.setLong(1, count);
				pstmt.setTimestamp(1, accessTime);
				pstmt.executeUpdate();
			} else { // insert new record
				query = "insert into accesslog(AccessType, ipaddress, hostName, lastaccess, accesscount, status, description) "
						+ "values ('" + accessType + "',?,?,?,?,?,?)";
				pstmt = connection.prepareStatement(query);
				pstmt.setString(1, ipAddress);
				pstmt.setString(2, hostName);
				pstmt.setTimestamp(3, accessTime);
				pstmt.setLong(4, 1);
				pstmt.setString(5, "A");
				pstmt.setString(6, " ");
				pstmt.executeUpdate();
			}
			connection.commit();
		} catch (SQLException e) {
			Utils.log("Error Creating Accesslog[" + query + "]", e);
		} finally {
			Utils.close(resultSet);
//			try {
//				if (resultSet != null)
//					resultSet.close();
//			} catch (Exception e) {
//			}
			Utils.close(pstmt);
//			try {
//				if (pstmt != null)
//					pstmt.close();
//			} catch (Exception e) {
//			}
			Utils.close(stmt);
//			try {
//				if (stmt != null)
//					stmt.close();
//			} catch (Exception e) {
//			}
			Utils.close(connection);
//			try {
//				if (connection != null)
//					connection.close();
//			} catch (Exception e) {
//			}
		}
	}

	/**
	 * returns double standard format for reports throws exception.
	 */
	public static String getDoublePattern(double value) throws Exception {
		String changeValue = "";
		try {
			NumberFormat nf = NumberFormat.getNumberInstance();
			nf.setMaximumFractionDigits(2);
			nf.setMinimumFractionDigits(2);
			changeValue = nf.format(value);
		} catch (Exception e) {
			throw new Exception("Could Not change Format ");
		}
		return changeValue;
	}

	/**
	 * This mathod will compare two String values It will look at the null value
	 */

	public static boolean equals(String first, String second) {
		if (first == null || second == null) {
			return false;
		}
		return first.equals(second);
	}

	public String getProperty(String prop) {
		return SystemDefaults.getProperty(prop);
	}

	// new method1 27 mar 2002
	public static String getDoublePatternTwo(double value) throws Exception {
		String changeValue = "";
		String newstring = "";
		try {
			NumberFormat nf = NumberFormat.getNumberInstance();
			nf.setMaximumFractionDigits(2);
			nf.setMinimumFractionDigits(2);
			changeValue = nf.format(value);
			StringTokenizer sT = new StringTokenizer(changeValue, ",");
			while (sT.hasMoreTokens())
				newstring += sT.nextToken();
		} catch (Exception e) {
			throw new Exception("Could Not change Format ");
		}
		return newstring;
	}

	// new method2 27 mar 2002
	public static String getDoublePatternThree(double value) throws Exception {
		String changeValue = "";
		String newstring = "";
		try {
			NumberFormat nf = NumberFormat.getNumberInstance();
			nf.setMaximumFractionDigits(3);
			nf.setMinimumFractionDigits(3);
			changeValue = nf.format(value);
			StringTokenizer sT = new StringTokenizer(changeValue, ",");
			while (sT.hasMoreTokens())
				newstring += sT.nextToken();
		} catch (Exception e) {
			throw new Exception("Could Not change Format ");
		}
		return newstring;
	}

	/**
	 * converts a date from "mm-dd-yyyy:hh:mm:ss" formate to "mm-dd-yyyy"
	 */
	public static String convertToDate(String dt) throws Exception {
		String convertedDate = "";
		try {
			if (dt == null)
				dt = "";
			int i = dt.indexOf(":");
			if (i != -1) {
				convertedDate = dt.substring(0, i - 2);
				Utils.log(" convertedDate convertedTo Date "
						+ convertedDate.length());
			} else
				convertedDate = dt;
		} catch (Exception e) {
			Utils.logError("Utils.convertToDate(String)", e);
		}
		return convertedDate;
	}

	// Method for returning vlaue with mask no of decimals
	public static String getDoublePatternMask(double value, int mask)
			throws Exception {
		String changeValue = "";
		String newstring = "";
		//Utils.log("Value"+value +"Mask"+mask);
		
		
		try {
			if(value==Double.POSITIVE_INFINITY)
				value=0;
			if(value==Double.NEGATIVE_INFINITY)
				value=0;
			if (Double.isNaN(value))
				value=0;
			/*NumberFormat nf = NumberFormat.getNumberInstance();
			nf.setMaximumFractionDigits(mask);
			nf.setMinimumFractionDigits(mask);
			changeValue = nf.format(value);
			StringTokenizer sT = new StringTokenizer(changeValue, ",");
			while (sT.hasMoreTokens())
				newstring += sT.nextToken();*/
			newstring=DistUtils.round(value, mask);
		} catch (Exception e) {
			throw new Exception("Could Not change Format ",e);
		}
		return newstring;
	}

	public static String getDoublePatternMaskParenthesis(double value, int mask)
			throws Exception {
		String changeValue = "";
		String newstring = "";
		String leftParent = "(";
		String rightParent = ")";
		String pattern = "";
		// log("basil number format" + value);
		try {
			/*
			 * if(mask==0) pattern="#,###,###,###"; else if(mask==1)
			 * pattern="#,###,###,###.0"; else if(mask==2)
			 * pattern="#,###,###,###.00"; else if(mask==3)
			 * pattern="#,###,###,###.000"; else if(mask==4)
			 * pattern="#,###,###,###.0000"; else pattern="#,###,###,###.00";
			 * NumberFormat nf=new DecimalFormat(pattern);
			 */
			if(value==Double.POSITIVE_INFINITY)
				value=0;
			if(value==Double.NEGATIVE_INFINITY)
				value=0;
			if (Double.isNaN(value))
				value=0;
			value=DistUtils.roundDouble(value, mask);
			NumberFormat nf = NumberFormat.getNumberInstance();

			nf.setMaximumFractionDigits(mask);
			nf.setMinimumFractionDigits(mask);
			changeValue = nf.format(Math.abs(value));
			// log("basil number format" + changeValue);
			newstring = changeValue;
			/*
			 * StringTokenizer sT = new StringTokenizer(changeValue,",");
			 * while(sT.hasMoreTokens()) newstring += sT.nextToken();
			 */
			if (value < 0)
				newstring = leftParent + newstring + rightParent;
		} catch (Exception e) {
			throw new Exception("Could Not change Format ",e);
		}
		return newstring;
	}

	public static String getDoublePatternMaskNoParenthesis(double value, int mask)
	throws Exception {
			String changeValue = "";
			String newstring = "";
			String leftParent = "";
			String rightParent = "";
			String pattern = "";
			try {
				if(value==Double.POSITIVE_INFINITY)
					value=0;
				if(value==Double.NEGATIVE_INFINITY)
					value=0;
				if (Double.isNaN(value))
					value=0;
				value=DistUtils.roundDouble(value, mask);
				NumberFormat nf = NumberFormat.getNumberInstance();
			
				nf.setMaximumFractionDigits(mask);
				nf.setMinimumFractionDigits(mask);
				changeValue = nf.format(value);
				newstring = changeValue;
				if (value < 0)
					newstring = leftParent + newstring + rightParent;
			} catch (Exception e) {
				throw new Exception("Could Not change Format ",e);
			}
			return newstring;
}
	
	public static String getCarriageStr(String str, int size) {
		String str1 = "";
		if (str == null || str.equals("") || str.equals(" "))
			return "";

		if (str.length() > size) {
			while (str.length() > size) {
				str1 += str.substring(0, size) + "\n";
				str = str.substring(size);
				if (str.length() < size) {
					str1 = str1 + "\n" + str;
				}
			}
		} else {
			str1 += str;
		}
		return str1;
	}

	public static Statement getReadOnlyStatement(Connection con)
			throws SQLException {
		return con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY);
	}

	public static void close(Connection con) {
		try {
			if (con != null && !con.isClosed())
				con.close();
		} catch (Exception e) {
			Utils.logError("Utils.close(Connection) failed", e);
		}
	}

	public static void close(ResultSet rs) {
		try {
			if (rs != null)
				rs.close();
		} catch (Exception e) {
			Utils.logInfo("Utils.close(ResultSet) failed", e);
		}
	}

	public static void close(Statement st) {
		try {
			if (st != null)
				st.close();
		} catch (Exception e) {
			Utils.logInfo("Utils.close(Statement) failed", e);
		}
	}

	public static void closeResultSetAndStatement(ResultSet rs) {
		Statement st = null;
		try {
			if (rs != null){
				st = rs.getStatement();
			rs.close();
			}
		} catch (Exception e) {
			Utils.logInfo("Utils.closeResultSetAndStatement ResultSet close failed", e);
		}
		try {
			if (st != null)
				st.close();
		} catch (Exception e) {
			Utils.logInfo("Utils.closeResultSetAndStatement Connection close failed", e);
		}
	}

	public static void closeAllSqlObjects(ResultSet rs) {
		Statement st = null;
		Connection con = null;
		try {
			if (rs != null){
				st = rs.getStatement();
			rs.close();
			}
		} catch (Exception e) {
			Utils.logInfo("Utils.closeAllSQLObjects ResultSet close failed", e);
		}
		try {
			if (st != null){
				con = st.getConnection();
			st.close();
			}
		} catch (Exception e) {
			Utils.logInfo("Utils.closeAllSQLObjects Statement close failed", e);
		}
		try {
			if (con != null && !con.isClosed())
				con.close();
		} catch (Exception e) {
			Utils.logError("Utils.closeAllSQLObjects Connection close failed", e);
		}
	}

	public static String trimStringWithWhitespace(int trimLength, String s) {

		if (s == null) {
			return "";
		}

		String trimmed = s.trim();
		if (trimmed.length() == 0) {
			return "";
		}

		String[] all = StringUtils.splitByWholeSeparator(trimmed, null);

		StringBuffer sb = new StringBuffer();
		int currentLine = 0;
		for (int i = 0; i < all.length; i++) {

			sb.append(all[i]);

			if (i + 1 < all.length) {
				if (currentLine < trimLength + 1 + all[i + 1].length()) {
					sb.append(" ");
					currentLine += all[i].length() + 1;
				} else {
					sb.append("\n");
					currentLine = 0;
				}
			}

		}

		return sb.toString();

	}

}
