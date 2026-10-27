<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>

<%@page import="org.apache.poi.xssf.usermodel.*"%>
<%@page import="org.apache.poi.ss.usermodel.*"%>
<%@page import="org.apache.poi.ss.util.CellRangeAddress"%>
<%@page import="org.apache.xmlbeans.XmlObject"%>
<%@page import="org.openxmlformats.schemas.spreadsheetml.x2006.main.CTSheet"%>

<% 

	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);

	//String param="DownloadDetails";
	String param=request.getParameter("param");
	Utils.log("param :: " + param);
	try {
		if(param.equalsIgnoreCase("GetDetails")){
			String output="";
			String paymentId = request.getParameter("paymentId");
		
			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
		
			ArrayList<HashMap<String, String>> data = getChildTableData(paymentId.trim().toString(),custKey.trim());
			for(int i=0;i<data.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)data.get(i);
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("refNum", map.get("refNum").trim().toString());
				jsonObj.put("invoiceDate", map.get("invoiceDate").trim().toString());
				jsonObj.put("paymentAmount", map.get("paymentAmount").trim().toString());
				jsonObj.put("discountAmount", map.get("discountAmount").trim().toString());
				jsonArray.put(jsonObj);
			}
			mainJSONObj.put("ChildTableList", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("GetExcel")){
			String output="";
			String paymentId = request.getParameter("paymentId");
		
			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
		
			ArrayList<HashMap<String, String>> data = getChildTableData(paymentId.trim().toString(),custKey.trim());
			for(int i=0;i<data.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)data.get(i);
				JSONObject jsonObj = new JSONObject();
jsonObj.put("INVOICE#", map.get("refNum").trim().toString());
jsonObj.put("INVOICE DATE", map.get("invoiceDate").trim().toString());	
jsonObj.put("PAYMENT AMT", map.get("paymentAmount").trim().toString());
jsonObj.put("DISCOUNT AMT", map.get("discountAmount").trim().toString());				

				jsonArray.put(jsonObj);
			}
			mainJSONObj.put("ChildTableList", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}

	}
	catch (Exception e) {
		e.getMessage();
	}

%>

<%!

	public ArrayList<HashMap<String, String>> getChildTableData(String paymentId,String custKey) {	
		String sqlQuery="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			/*sqlQuery = " select REF_NUM,PAYMENT_DATE,PAYMENT_AMOUNT,DISCOUNT_AMT " 
						+" from ARCASH " 
						+" where SESSION_ID = (select SESSION_ID from arcash where PAYMENT_ID_NUM='"+paymentId+"' and TRANS_CODE='AP' and ref_type in ('CA','DP') and payment_amount!=0 and cancelled!=1) order by ref_num "; */
			
			sqlQuery = " select ac.REF_NUM,ao.REF_DATE,ac.PAYMENT_AMOUNT,ac.DISCOUNT_AMT "
						+" from ARCASH ac, aropen ao "
						+" where ac.ref_num=ao.ref_num and ac.CUST_KEY=ao.CUST_KEY "
						+" and ac.SESSION_ID = (select SESSION_ID from arcash where PAYMENT_ID_NUM='"+paymentId+"' and TRANS_CODE='AP' and ref_type in ('CA','DP')and payment_amount!=0 and cancelled!=1) order by ref_num "; 
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector refNumVector = new Vector();
			Vector invoiceDateVector = new Vector();
			Vector paymentAmountVector = new Vector();
			Vector discountAmountVector = new Vector();
			if (ht != null && ht.size() > 0) {
				refNumVector = (Vector) ht.get("REF_NUM");
				invoiceDateVector = (Vector) ht.get("REF_DATE");
				paymentAmountVector = (Vector) ht.get("PAYMENT_AMOUNT");
				discountAmountVector = (Vector) ht.get("DISCOUNT_AMT");
			}
	        if (refNumVector.size() > 0) {
	        	for (int i = 0; i < refNumVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("refNum", refNumVector.get(i).toString());
					temp.put("invoiceDate", invoiceDateVector.get(i).toString());
					temp.put("paymentAmount", paymentAmountVector.get(i).toString());
					temp.put("discountAmount", discountAmountVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

	public String getInvoiceDate(String refNum,String custKey){
		String invoiceDate="";
		try{
			DistUtils du=new DistUtils();								
			String sqlQuery = "select REF_DATE from AROPEN where REF_NUM='"+refNum+"' and CUST_KEY='"+custKey+"' ";
			Utils.log("Query for invoice date :: " + sqlQuery);
			invoiceDate=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return invoiceDate;
	}


	public String downloadDetails(String paymentId, String custKey, String filePath){
		
		String status="";
		List<HashMap<String, String>> listData = getChildTableData(paymentId,custKey);

		try {
			status = "Success";
			Utils.log("filePath >> "+filePath);
			FileWriter writer = new FileWriter(filePath);
			
			writer.append("INVOICE#");
			writer.append('\t');
			writer.append("INVOICE DATE");
			writer.append('\t');
			writer.append("PAYMENT AMT");
			writer.append('\t');
			writer.append("DISCOUNT AMT");
			writer.append('\n');

			
			if(listData != null && listData.size()>0){ 
				for(int i=0;i<listData.size();i++){
					HashMap map=(HashMap)listData.get(i);

					writer.append(map.get("refNum").toString().trim());
					writer.append('\t');
					writer.append(map.get("invoiceDate").toString().trim());
					writer.append('\t');
					writer.append(map.get("paymentAmount").toString().trim());
					writer.append('\t');
					writer.append(map.get("discountAmount").toString().trim());
					writer.append('\n');
				}
			}
			writer.flush();
			writer.close();

		
		}
		catch (Exception e) {
			status = "ERROR";
			e.printStackTrace();
		} 
		return status;
	}
	
	
	public byte[] getReportExcel(HttpServletRequest request,String paymentId,String custKey)
			throws SQLException, Exception {
			Utils.log("Generating Excel..........");
			ByteArrayOutputStream documentBytes = new ByteArrayOutputStream();
			String query="";
			JSONObject mainObject=null;
			try {
				DistUtils du=new DistUtils();
				//String start_date=request.getParameter("invStartDate");
				//String end_date=request.getParameter("invEndDate");
				//Utils.log("start_date="+start_date+" end_date="+end_date);
		
				int rownum=0;
				XSSFWorkbook workbook = new XSSFWorkbook();
				XSSFSheet sheet = workbook.createSheet("Report");
				sheet.setColumnWidth(0, 25 * 256);
				sheet.setColumnWidth(1, 10 * 256);
				sheet.setColumnWidth(2, 10 * 256);
				sheet.setColumnWidth(3, 10 * 256);
				sheet.setColumnWidth(4, 10 * 256);
				sheet.setColumnWidth(5, 10 * 256);
				sheet.setColumnWidth(6, 10 * 256);
				sheet.setColumnWidth(7, 10 * 256);
				sheet.setColumnWidth(8, 10 * 256);
				sheet.setColumnWidth(9, 10 * 256);
				sheet.setColumnWidth(10, 10 * 256);
				sheet.setColumnWidth(11, 10 * 256);
				sheet.setColumnWidth(12, 10 * 256);
				sheet.setColumnWidth(13, 10 * 256);
				sheet.setColumnWidth(14, 10 * 256);
				
				
				
				XSSFCellStyle headstyle = workbook.createCellStyle();
				XSSFCellStyle textstyle = workbook.createCellStyle();
				XSSFCellStyle topHeadStyle = workbook.createCellStyle();
				XSSFCellStyle leftHeadStyle = workbook.createCellStyle();
				
				XSSFFont font = workbook.createFont();
				font.setFontHeight(11);
				font.setBold(true);
				
				
				JSONArray jsonArray = mainObject.getJSONArray("data");
				
				
				
				headstyle.setAlignment(HorizontalAlignment.CENTER);
				headstyle.setFont(font);
				topHeadStyle.setAlignment(HorizontalAlignment.RIGHT);
				topHeadStyle.setFont(font);
				leftHeadStyle.setAlignment(HorizontalAlignment.LEFT);
				leftHeadStyle.setFont(font);
				
				
				XSSFRow row = sheet.createRow(rownum);
				rownum++;
				Cell cell0 = row.createCell(0);
				
				cell0.setCellValue("RWC BUILDING PRODUCTS : From To ");
				cell0.setCellStyle(headstyle);
				sheet.addMergedRegion(new CellRangeAddress(0,0,0,10));
				
				/*
				row = sheet.createRow(rownum);
				rownum++;
				cell0 = row.createCell(0);
				
				cell0.setCellValue("From "+start_date+" To "+end_date);
				cell0.setCellStyle(headstyle);
				sheet.addMergedRegion(new CellRangeAddress(0,0,0,10));
				*/
				XSSFFont baseFont = workbook.createFont();
				XSSFFont boldFont = workbook.createFont();
				boldFont.setBold(true);
				XSSFFont textFont = workbook.createFont();
				textFont.setBold(false);
				textstyle.setFont(textFont);
				
				documentBytes = new ByteArrayOutputStream();
		
				row = sheet.createRow(rownum);
				rownum++;
				
				cell0 = row.createCell(0);
				cell0.setCellValue("Invoice Date");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(1);
				cell0.setCellValue("Warehouse");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(2);
				cell0.setCellValue("Order No");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(3);
				cell0.setCellValue("Shipment No");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(4);
				cell0.setCellValue("Sale Type");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(5);
				cell0.setCellValue("Match Status");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(6);
				cell0.setCellValue("Remarks");
				cell0.setCellStyle(headstyle);
				
				cell0 = row.createCell(7);
				cell0.setCellValue("User Name");
				cell0.setCellStyle(headstyle);
				cell0 = row.createCell(8);
				cell0.setCellValue("User Email");
				cell0.setCellStyle(headstyle);
				
				cell0 = row.createCell(9);
				cell0.setCellValue("Pending Days");
				cell0.setCellStyle(headstyle);
				
				cell0 = row.createCell(10);
				cell0.setCellValue("Status Flag");
				cell0.setCellStyle(headstyle);
				
				/* String ordership="";
				for (int i=0;i<jsonArray.length();i++)
				{
					JSONObject j=jsonArray.getJSONObject(i) ;
					if(i>0)
						ordership+=",";
					
					ordership+="'"+j.getString("ORDERNO")+"-"+j.getString("SHIPMENTNO")+"'";
					
				}
				if(ordership=="")
					ordership="null"; */
				
				
				workbook.write(documentBytes);
				workbook.close();
		
			} catch (Exception e) {
				Utils.log("Exception",e);
			}
			return documentBytes.toByteArray();
		}
	

%>
