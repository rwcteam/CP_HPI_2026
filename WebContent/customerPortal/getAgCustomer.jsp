<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ page import="com.etechlogix.utils.*" %>
<%@ page import="com.etechlogix.distribution.utils.*" %>

<%
	String companyId="";
	companyId = (String)session.getAttribute("companyId");
	DistUtils du =DistUtils.getDistUtils(session);
	String customerId="",firstName="",lastName="";
	String customerClass="";
	String query="";
	JSONArray arrayObj=new JSONArray();
	try {
		String term = request.getParameter("term");
		term=term.replace(" ","%");
		query="select distinct DEPTID,FIRSTNAME,LASTNAME from ETECHUSER where GROUPID='CUSTOMER' and (UPPER(FIRSTNAME) like UPPER('%"+term+"%')) ";
		Hashtable ht=du.getDataFromQuery(query);		
		Vector customerIdVector=new Vector();
		Vector firstNameVector=new Vector();
		Vector lastNameVector=new Vector();
    	if (ht != null && ht.size() != 0) {
			customerIdVector = (Vector) ht.get("DEPTID");
			firstNameVector = (Vector) ht.get("FIRSTNAME");
			lastNameVector = (Vector) ht.get("LASTNAME");
		}
		if (customerIdVector.size() > 0) {
        	for (int j = 0; j < customerIdVector.size(); j++) {      	  
            	customerId=customerIdVector.get(j).toString();
            	firstName=firstNameVector.get(j).toString();
            	lastName=lastNameVector.get(j).toString();
            	arrayObj.put(customerId+" : "+firstName+" : "+lastName);
            	//out.println(customerId+" : "+name);
        	}
			Utils.log(arrayObj.toString());
			out.println(arrayObj.toString());
		}
	}
	catch(Exception exception) {
		Utils.log("Exception" ,exception);	
	}
%>
