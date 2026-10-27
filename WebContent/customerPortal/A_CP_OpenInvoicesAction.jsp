<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.utils.Utils"%>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.sa.servlet.*" %>
<%@page import="com.etechlogix.distribution.ar.servlet.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="org.json.JSONArray" %>
<%@page import="org.json.JSONObject" %>
<%@page import="java.util.List" %>

<%
	try{
		String param=request.getParameter("param");
		Utils.log("Param >>>> " + param);
		String output="";
		Utils u = new Utils();
		if(param.equalsIgnoreCase("GetInvoices")){
			String orderNo = request.getParameter("orderNo");
			String shipmentNo = request.getParameter("shipmentNo");
			String awsInvoiceUrl="";
			
			ArrayList<HashMap<String, String>> listData = getInvoicesList(orderNo,shipmentNo);
			for(int i=0;i<listData.size();i++){
				HashMap map=(HashMap)listData.get(i);
				awsInvoiceUrl=map.get("invoiceFilePath").toString();
			}
			output=awsInvoiceUrl.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("GetStatementsPdf")){
			String pdfUrl = request.getParameter("awsUrl");
			String awsStatementsUrl=getDocPath(pdfUrl);
			output=awsStatementsUrl.toString();
			out.print(output);
		}
	}
	catch (Exception e) {
		e.getMessage();
	}
%>	
	
<%!

	public ArrayList<HashMap<String, String>> getInvoicesList(String orderNo, String shipmentNo){
		String query="",queryFilter="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query=" select ORDERNO,SHIPMENTNO,AWSURL from DMSI_CUSTOMER_DOCUMENTS where ORDERNO='"+orderNo+"' and SHIPMENTNO='"+shipmentNo+"' ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector orderNoVector = new Vector();
			Vector shipmentNoVector = new Vector();
			Vector awsUrlVector = new Vector();
			if (ht != null && ht.size() != 0) {
				orderNoVector = (Vector) ht.get("ORDERNO");
				shipmentNoVector = (Vector) ht.get("SHIPMENTNO");
				awsUrlVector = (Vector) ht.get("AWSURL");
			}
	        if (orderNoVector.size() > 0) {
	        	for (int i = 0; i < orderNoVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("orderNo", orderNoVector.get(i).toString());
					temp.put("shipmentNo", shipmentNoVector.get(i).toString());
					temp.put("invoiceFilePath", getDocPath(awsUrlVector.get(i).toString()));
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}


	public String getDocPath(String filePath){
		String tempPath="AA";
		String sqlQuery="";
		S3_Upload su=new S3_Upload();
		try {
			Utils.log("Image request Start....");
			tempPath = su.getTempURL(filePath,"barcodereader");
			//tempPath="<object data='"+tempPath+"#zoom=75' width='1000' height='900' >  </object>";
			Utils.log("tempPath ::"+tempPath);
		} catch (Exception e) {
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}	
		return tempPath;
	}

		
%>
