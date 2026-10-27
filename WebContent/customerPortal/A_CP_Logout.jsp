<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<% 
	session.removeAttribute("userId");
	session.removeAttribute("companyId");
	//request.getSession().invalidate();
	session.invalidate();
	//session.setAttribute("userId",null);
	//session.setAttribute("companyId",null);

	//response.sendRedirect("login.htm");
	//session.setAttribute("loginstatus","false");
%>
<jsp:forward page="../login.jsp" />
