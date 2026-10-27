<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>

<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>
<%-- <%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%> --%>

<%
	String userId = (String)session.getAttribute("userId");
	Utils.log("userId :: " + userId);
	DistUtils du=new DistUtils();
	String param=request.getParameter("param");
	Utils.log("Param  >>>> " + param);
	if(param.equalsIgnoreCase("ChangeCustomerId")) {
		String message="";
		try {
			String customerId=request.getParameter("customerId");
			Utils.log("customerId  >>>> " + customerId);
			
	    	String custKey = Utils.removeNull(du.getFieldInfoPro2(" select cust_key from cust where cust_code='"+customerId+"' "));
	    	session.setAttribute("customerId", customerId);
	    	session.setAttribute("custKey", custKey);
				
			//request.setAttribute("message", "Customer# has been changed");
			message="Customer# has been changed";	
		}
		catch (Exception e) {
			e.getMessage();
		}
		out.print(message.toString());
	}
%>

