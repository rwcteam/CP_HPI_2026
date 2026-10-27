<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@page import="com.etechlogix.utils.Utils"%>
<%@page import="com.etechlogix.distribution.utils.*"%>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>

<% 
	Utils.log("A_CP_ForgotCredentials.jsp  >>>> ");
	request.setAttribute("message","Wrong password. Try again or click Forgot password to reset it.");
%>
<jsp:forward page="../login.jsp" ></jsp:forward>
