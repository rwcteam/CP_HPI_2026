<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.awt.Color"%>
<%@page import="com.lowagie.text.*"%>
<%@page import="com.lowagie.text.pdf.*"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>



<%
	Utils u= new Utils();
	try {
		final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
		String param = request.getParameter("param");
		Utils.log("param  >>>>>> "+param);
		
		String custKey=(String)session.getAttribute("custKey");
		if (param.equalsIgnoreCase("InquiryHeader")){

			String output="";
			//String systemId = request.getParameter("systemId");
			String soId = request.getParameter("soId");

			JSONObject jsonObj = new JSONObject();
			HashMap<String, String> map = getOpenOrdersInquiryHeader(custKey,soId);
			jsonObj.put("soId", map.get("soId"));
			jsonObj.put("systemId", map.get("systemId"));
			jsonObj.put("custCode", map.get("custCode"));
			jsonObj.put("custName", map.get("custName"));
			jsonObj.put("custPo", map.get("custPo"));
			jsonObj.put("shipTo", map.get("shipTo"));
			jsonObj.put("orderedBy", map.get("orderedBy"));
			jsonObj.put("payTermsCode", map.get("payTermsCode"));
			jsonObj.put("addressOne", map.get("addressOne"));
			jsonObj.put("expectedDeliveryDate", map.get("expectedDeliveryDate"));
			jsonObj.put("reference", map.get("reference"));
			jsonObj.put("addressTwo", map.get("addressTwo"));
			jsonObj.put("city", map.get("city"));
			jsonObj.put("state", map.get("state"));
			jsonObj.put("zip", map.get("zip"));
			jsonObj.put("phone", map.get("phone"));
			jsonObj.put("shipVia", map.get("shipVia"));
			jsonObj.put("freightTerms", map.get("freightTerms"));
			jsonObj.put("orderDate", map.get("orderDate"));
			jsonObj.put("orderTotal", df.format(Double.parseDouble(map.get("orderTotal").toString())));
			jsonObj.put("totalSale", df.format(Double.parseDouble(map.get("totalSale").toString())));
			jsonObj.put("contactName", map.get("miscTen"));
			jsonObj.put("phoneNo", map.get("miscEleven"));
			
			output=jsonObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("InquiryDetails")) {

			String output="";
			//String systemId = request.getParameter("systemId");
			String soId = request.getParameter("soId");

			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
			ArrayList<HashMap<String, String>> listData = getOpenOrdersInquiryDetails(soId);
			for(int i=0;i<listData.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)listData.get(i);
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("soId", map.get("soId"));
				jsonObj.put("sequence", map.get("sequence"));
				jsonObj.put("item", map.get("item"));
				jsonObj.put("description", map.get("description"));
				jsonObj.put("size", map.get("size"));
				jsonObj.put("qtyOrdered", map.get("qtyOrdered"));
				jsonObj.put("shipped", map.get("shipped"));
				jsonObj.put("remainingQty", map.get("remainingQty"));
				jsonObj.put("uom", map.get("uom"));
				jsonObj.put("price", map.get("price"));
				jsonObj.put("priceUomCode", map.get("priceUomCode"));
				jsonObj.put("extPrice", map.get("extPrice"));
				jsonArray.put(jsonObj);
			}
			mainJSONObj.put("InquiryDetails", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
			//out.close();
		}
		else if(param.equalsIgnoreCase("ReportPdf")){
			String message="",filePath="";
			String soId = request.getParameter("soId");
			JSONObject finalJson = new JSONObject();
			try{
				Utils.log("start - print------");
				byte [] documentBytes=getReportPdf(request,custKey.trim(),soId.trim());
				if(documentBytes.length > 0){
					filePath = "openOrdersPDFFiles/" + new Date().getTime()  + ".pdf";
					//File file1 = new File(u.getHomeDirectory() + filePath);
					File file1 = new File("/home/tomcat/apache-tomcat-10.1.9/customerportal/ROOT/"+filePath);
					Utils.log("file1 >>>> "+file1);
					OutputStream docbytes = new FileOutputStream(file1);
					docbytes.write(documentBytes);
					docbytes.close();
				} else {
					message = "Error in pdf creation";
					Utils.log("message :: "+message);
				}
			} catch (Exception e){
				message = e.getMessage();
			}
			Utils.log("end print------");
			finalJson.put("filepath", filePath);
			finalJson.put("message", message);
			out.println(finalJson.toString());
		}
		/*else if (param.equalsIgnoreCase("InquiryDetails")) {

			String output="";
			String systemId = request.getParameter("systemId");
			String soId = request.getParameter("soId");
			
			final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
			StringBuffer detailsListBuffer=new StringBuffer();			
			ArrayList<HashMap<String, String>> listData = getOpenOrdersInquiryDetails(soId);
			String row="";
		    
			row="<thead>"+
					"<tr>"+
						"<th style=\"text-align: left; width: 4%;\" nowrap>SO#</th>"+
				  		"<th style=\"text-align: left; width: 4%;\" nowrap>Line#</th>"+
				  		"<th style=\"text-align: left; width: 4%;\" nowrap>Item</th>"+
						"<th style=\"text-align: left; width: 40%;\">Item Description</th>"+
						"<th style=\"text-align: left; width: 12%;\" nowrap>Size</th>"+
						"<th style=\"text-align: right; width: 4%;\" nowrap>Ordered Qty</th>"+
						"<th style=\"text-align: right; width: 4%;\" nowrap>Shipped</th>"+
						"<th style=\"text-align: right; width: 4%;\" nowrap>Remaining Qty</th>"+
						"<th style=\"text-align: left; width: 4%;\" nowrap>UOM</th>"+
						"<th style=\"text-align: right; width: 8%;\" nowrap>Price</th>"+
						"<th style=\"text-align: left; width: 4%;\" nowrap>UOM</th>"+
						"<th style=\"text-align: right; width: 8%;\" nowrap>Ext Total</th>"+
					"</tr>"+
		    	"</thead>"+
  				"<tbody>";
  			detailsListBuffer.append(row);
			for(int i=0;i<listData.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)listData.get(i);
				row="<tr>"+
								"<td align=\"left\" nowrap>"+map.get("soId")+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("sequence")+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("item")+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("description")+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("size")+"</td>"+
								"<td align=\"right\" nowrap>"+df.format(Double.parseDouble(map.get("qtyOrdered").toString()))+"</td>"+
								"<td align=\"right\" nowrap>"+df.format(Double.parseDouble(map.get("shipped").toString()))+"</td>"+
								"<td align=\"right\" nowrap>"+df.format(Double.parseDouble(map.get("remainingQty").toString()))+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("uom")+"</td>"+
								"<td align=\"right\" nowrap>"+df.format(Double.parseDouble(map.get("price").toString()))+"</td>"+
								"<td align=\"left\" nowrap>"+map.get("priceUomCode")+"</td>"+
								"<td align=\"right\" nowrap>"+df.format(Double.parseDouble(map.get("extPrice").toString()))+"</td>"+
							"<tr>";
							
				detailsListBuffer.append(row);
			}
			detailsListBuffer.append("</tbody>");
			output=detailsListBuffer.toString();
			
			out.print(output);
			out.close();
		}
		else if (param.equalsIgnoreCase("InquiryDetails")) {

			DistUtils du=new DistUtils();
			Utils utils= new Utils();
			String output="";
			String systemId = request.getParameter("systemId");
			String soId = request.getParameter("soId");
			String applet="";
			String sqlQuery = "select sd.SO_ID,sd.SEQUENCE,it.ITEM, it.DESCRIPTION, it.SIZE_, sd.QTY_ORDERED,nvl(sum(sp.qty),0) AS SHIPPED, "
									+" sd.qty_ordered-nvl(sum(sp.qty),0) as REMAINING_QTY, sd.UOM,sd.PRICE, sd.PRICE_UOM_CODE, " 
									+" (sd.price/sd.disp_price_conv)*sd.qty_ordered*sd.disp_qty_conv as EXT_PRICE "
									+" from so_detail sd, item it, shipments_detail sp " 
									+" where sd.item_ptr=it.item_ptr " 
									+" and sd.so_id=sp.so_id(+) " 
									+" and sd.sequence=sp.sequence(+) "
									+" and sd.so_id='"+soId+"' " 
									+" group by sd.so_id, sd.sequence,it.item, it.description, it.size_, sd.qty_ordered, " 
									+" sd.bo, sd.uom,sd.price, sd.price_uom_code, (sd.price/sd.disp_price_conv)*sd.qty_ordered*sd.disp_qty_conv ";
			Utils.log("Query :: "+sqlQuery);	
			try{
				applet=du.getJsonFromQueryPro2(sqlQuery).toString();
				//Utils.log("applet"+applet);
				if(applet.length()>=1)
					applet=applet.substring(1, applet.length()-1);
				if(!applet.trim().equals(""))
					applet=","+applet;
			
				String dataTableProperty=Utils.loadFile(utils.getHTMLDirectory() +"grid/dataTables//A_CP_OpenOrderInquiryDT.properties");
				applet=dataTableProperty+applet;
				utils.log("applet ======= "+applet);
			}
			catch(Exception e){
				utils.log("error ======= ",e);
			}
			output=applet.toString();
			
			out.print(output);
			out.close();
		}*/

	}
	catch (Exception e) {
		e.getMessage();
	}

%>

<%!

	public HashMap<String, String> getOpenOrdersInquiryHeader(String custKey, String soId) {	
		String sqlQuery="",filterString = "";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			//sqlQuery = "select distinct sh.SO_ID,sh.SYSTEM_ID,cu.CUST_CODE,cu.CUST_NAME,sh.CUST_PO, "
			sqlQuery = "select distinct sh.SO_ID,sh.SYSTEM_ID,cu.CUST_CODE,sa.CUST_NAME,sh.CUST_PO, "
							+" sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO,sh.ORDERED_BY, "
							+" sh.PAY_TERMS_CODE,sa.ADDRESS_1,sh.EXP_SHIP_DATE,sh.REFERENCE,sa.ADDRESS_2,sa.CITY,sa.STATE,sa.ZIP, "
							+" sa.PHONE,sh.SHIP_VIA,sh.FREIGHT_TERMS_ID,sh.ORDER_DATE, sh.ORDER_TOTAL,sh.TOTAL_SELL,sa.MISC_10,sa.MISC_11 "
							+" from SO_HEADER sh, SHIP_TO_ADDRESS sa, cust cu " 
							+" where sh.cust_key=cu.cust_key " 
							+" and sh.SO_ID=sa.TRAN_ID(+) " 
							+" and sh.cust_key='"+custKey+"' " 
							+" and sh.SO_ID='"+soId+"' ";
			Utils.log("OpenOrdersInquiryHeader Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector soIdVector = new Vector();
			Vector systemIdVector = new Vector();
			Vector custCodeVector = new Vector();
			Vector custNameVector = new Vector();
			Vector custPoVector = new Vector();
			Vector shipToVector = new Vector();
			Vector orderedByVector = new Vector();
			Vector payTermsCodeVector = new Vector();
			Vector addressOneVector = new Vector();
			Vector expectedDeliveryDateVector = new Vector();
			Vector referenceVector = new Vector();
			Vector addressTwoVector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
			Vector phoneVector = new Vector();
			Vector shipViaVector = new Vector();
			Vector freightTermsVector = new Vector();
			Vector orderDateVector = new Vector();
			Vector orderTotalVector = new Vector();
			Vector totalSellVector = new Vector();
			Vector miscTenVector = new Vector();
			Vector miscElevenVector = new Vector();
			if (ht != null && ht.size() > 0) {
				soIdVector = (Vector) ht.get("SO_ID");
				systemIdVector = (Vector) ht.get("SYSTEM_ID");
				custCodeVector = (Vector) ht.get("CUST_CODE");
				custNameVector = (Vector) ht.get("CUST_NAME");
				custPoVector = (Vector) ht.get("CUST_PO");
				shipToVector = (Vector) ht.get("SHIP_TO");
				orderedByVector = (Vector) ht.get("ORDERED_BY");
				payTermsCodeVector = (Vector) ht.get("PAY_TERMS_CODE");
				addressOneVector = (Vector) ht.get("ADDRESS_1");
				expectedDeliveryDateVector = (Vector) ht.get("EXP_SHIP_DATE");
				referenceVector = (Vector) ht.get("REFERENCE");
				addressTwoVector = (Vector) ht.get("ADDRESS_2");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
				phoneVector = (Vector) ht.get("PHONE");
				shipViaVector = (Vector) ht.get("SHIP_VIA");
				freightTermsVector = (Vector) ht.get("FREIGHT_TERMS_ID");
				orderDateVector = (Vector) ht.get("ORDER_DATE");
				orderTotalVector = (Vector) ht.get("ORDER_TOTAL");
				totalSellVector = (Vector) ht.get("TOTAL_SELL");
				miscTenVector = (Vector) ht.get("MISC_10");
				miscElevenVector = (Vector) ht.get("MISC_11");
			}
	        if (soIdVector.size() > 0) {
	        	for (int i = 0; i < soIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("soId", soIdVector.get(i).toString());
	        		temp.put("systemId", systemIdVector.get(i).toString());
	        		temp.put("custCode", custCodeVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("custPo", custPoVector.get(i).toString());
					temp.put("shipTo", shipToVector.get(i).toString());
					temp.put("orderedBy", orderedByVector.get(i).toString());
					temp.put("payTermsCode", payTermsCodeVector.get(i).toString());
					temp.put("addressOne", addressOneVector.get(i).toString());
					temp.put("expectedDeliveryDate", expectedDeliveryDateVector.get(i).toString());
					temp.put("reference", referenceVector.get(i).toString());
					temp.put("addressTwo", addressTwoVector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
					temp.put("phone", phoneVector.get(i).toString());
					temp.put("shipVia", shipViaVector.get(i).toString());
					temp.put("freightTerms", freightTermsVector.get(i).toString());
					temp.put("orderDate", orderDateVector.get(i).toString());
					temp.put("orderTotal", orderTotalVector.get(i).toString());
					temp.put("totalSale", totalSellVector.get(i).toString());
					temp.put("miscTen", miscTenVector.get(i).toString());
					temp.put("miscEleven", miscElevenVector.get(i).toString());
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}

	public ArrayList<HashMap<String, String>> getOpenOrdersInquiryDetails(String soId) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select sd.SO_ID,sd.SEQUENCE,it.ITEM, it.DESCRIPTION, it.SIZE_, sd.QTY_ORDERED,nvl(sum(sp.qty),0) AS SHIPPED, "
						+" sd.qty_ordered-nvl(sum(sp.qty),0) as REMAINING_QTY, sd.UOM,sd.PRICE, sd.PRICE_UOM_CODE, " 
						+" (sd.price/sd.disp_price_conv)*sd.qty_ordered*sd.disp_qty_conv as EXT_PRICE "
						+" from so_detail sd, item it, shipments_detail sp " 
						+" where sd.item_ptr=it.item_ptr " 
						+" and sd.so_id=sp.so_id(+) " 
						+" and sd.sequence=sp.sequence(+) "
						+" and sd.so_id='"+soId+"' " 
						+" group by sd.so_id, sd.sequence,it.item, it.description, it.size_, sd.qty_ordered, " 
						+" sd.bo, sd.uom,sd.price, sd.price_uom_code, (sd.price/sd.disp_price_conv)*sd.qty_ordered*sd.disp_qty_conv "
						+" order by sd.SEQUENCE ";
			Utils.log("OpenOrdersInquiryDetails Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector soIdVector = new Vector();
			Vector sequenceVector = new Vector();
			Vector itemVector = new Vector();
			Vector descriptionVector = new Vector();
			Vector sizeVector = new Vector();
			Vector qtyOrderedVector = new Vector();
			Vector shippedVector = new Vector();
			Vector remainingQtyVector = new Vector();
			Vector uomVector = new Vector();
			Vector priceVector = new Vector();
			Vector priceUomCodeVector = new Vector();
			Vector extPriceVector = new Vector();
			if (ht != null && ht.size() > 0) {
				soIdVector = (Vector) ht.get("SO_ID");
				sequenceVector = (Vector) ht.get("SEQUENCE");
				itemVector = (Vector) ht.get("ITEM");
				descriptionVector = (Vector) ht.get("DESCRIPTION");
				sizeVector = (Vector) ht.get("SIZE_");
				qtyOrderedVector = (Vector) ht.get("QTY_ORDERED");
				shippedVector = (Vector) ht.get("SHIPPED");
				remainingQtyVector = (Vector) ht.get("REMAINING_QTY");
				uomVector = (Vector) ht.get("UOM");
				priceVector = (Vector) ht.get("PRICE");
				priceUomCodeVector = (Vector) ht.get("PRICE_UOM_CODE");
				extPriceVector = (Vector) ht.get("EXT_PRICE");
			}
	        if (soIdVector.size() > 0) {
	        	for (int i = 0; i < soIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("soId", soIdVector.get(i).toString());
					temp.put("sequence", sequenceVector.get(i).toString());
					temp.put("item", itemVector.get(i).toString());
					temp.put("description", descriptionVector.get(i).toString());
					temp.put("size", sizeVector.get(i).toString());
					temp.put("qtyOrdered", qtyOrderedVector.get(i).toString());
					temp.put("shipped", shippedVector.get(i).toString());
					temp.put("remainingQty", remainingQtyVector.get(i).toString());
					temp.put("uom", uomVector.get(i).toString());
					temp.put("price", priceVector.get(i).toString());
					temp.put("priceUomCode", priceUomCodeVector.get(i).toString());
					temp.put("extPrice", extPriceVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	
	
	private BaseFont baseFont;
	private Font boldFont;
	
	public BaseFont getBaseFont() {
		return baseFont;
	}	

	public byte[] getReportPdf(HttpServletRequest request,String custKey,String soId)
			throws SQLException, Exception {
	
		ByteArrayOutputStream documentBytes = null ;
		Utils.log("Generating PDF..........");
		int manDate=0;
		int leadDays=0;
	
		try {
			boldFont = new Font(getBaseFont(), 7, Font.BOLD, Color.BLACK);
			Font textFont=new Font(getBaseFont(), 7, Font.NORMAL, Color.BLACK);
			Font font7=new Font(getBaseFont(), 7, Font.NORMAL, Color.BLACK);
			Font fontWhite=new Font(getBaseFont(), 0, Font.NORMAL, Color.WHITE);
			new Font(getBaseFont(), 9, Font.BOLD);
			
			Font totalBoldFont=new Font(getBaseFont(), 10, Font.BOLD, Color.BLACK);
			Font totalTextFont=new Font(getBaseFont(), 10, Font.NORMAL, Color.BLACK);

			Document document = null;		
			ByteArrayOutputStream copyDocumentBytes = new ByteArrayOutputStream();
			PdfCopyFields copy = new PdfCopyFields(copyDocumentBytes);
			//PdfPCell[] Cell=new PdfPCell[20];
			documentBytes = new ByteArrayOutputStream();
			
			document = new Document(PageSize.LETTER.rotate(), 8, 8, 12, 12);
			//document = new Document(PageSize.LETTER.rotate(), 12, 12, 16, 16);
			//document = new Document(new Rectangle(PageSize.A4));
			PdfWriter writer=PdfWriter.getInstance(document,documentBytes);
			document.open();
				
			final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
			final DecimalFormat dftpd = new DecimalFormat("#,###,###,##0.000");
			
			Date date1 = new Date();
			SimpleDateFormat formatter = new SimpleDateFormat("MM/dd/yy hh:mm:ss a");
			String generateDate = formatter.format(date1);
				
			PdfPTable head1=new PdfPTable(1);
			PdfPCell Cell1 = new PdfPCell(new Phrase(1, "RWC BUILDING PRODUCTS", textFont));
			Cell1 = new PdfPCell(new Phrase(1, "RWC BUILDING PRODUCTS : Open Orders " + generateDate, boldFont));
			Cell1.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
			Cell1.setBorder(PdfCell.NO_BORDER);
			head1.addCell(Cell1);
			document.add(head1);
				
			PdfPTable containerTable = new PdfPTable(1);
			containerTable.setWidthPercentage(100);
			PdfPCell containerCell = null;
			PdfPTable headerTable = new PdfPTable(6);
			headerTable.setWidthPercentage(100);
			headerTable.setHeaderRows(3);
			PdfPTable detailsTable = new PdfPTable(12);
			detailsTable.setWidthPercentage(100);
			
			float[] headerTableColumnWidths = new float[]{4f,10f,8f,6f,8f,6f};
			headerTable.setWidths(headerTableColumnWidths);

			float[] detailsTableColumnWidths = new float[]{4f,4f,3f,18f,5f,5f,4f,6f,3f,4f,3f,4f};
			detailsTable.setWidths(detailsTableColumnWidths);
				
			HashMap<String, String> map = getOpenOrdersInquiryHeader(custKey,soId);
			String soOrderId=map.get("soId");
			if(soOrderId==null)
				soOrderId="";
			String systemId=map.get("systemId");
			if(systemId==null)
				systemId="";
			String custCode=map.get("custCode");
			if(custCode==null)
				custCode="";
			String custName=map.get("custName");
			if(custName==null)
				custName="";
			String custPo=map.get("custPo");
			if(custPo==null)
				custPo="";
			String shipTo=map.get("shipTo");
			if(shipTo==null)
				shipTo="";
			String orderedBy=map.get("orderedBy");
			if(orderedBy==null)
				orderedBy="";
			String payTermsCode=map.get("payTermsCode");
			if(payTermsCode==null)
				payTermsCode="";
			String addressOne=map.get("addressOne");
			if(addressOne==null)
				addressOne="";
			String expectedDeliveryDate=map.get("expectedDeliveryDate");
			if(expectedDeliveryDate==null)
				expectedDeliveryDate="";
			String reference=map.get("reference");
			if(reference==null)
				reference="";
			String addressTwo=map.get("addressTwo");
			if(addressTwo==null)
				addressTwo="";
			String city=map.get("city");
			if(city==null)
				city="";
			String state=map.get("state");
			if(state==null)
				state="";
			String zip=map.get("zip");
			if(zip==null)
				zip="";
			String phone=map.get("phone");
			if(phone==null)
				phone="";
			String shipVia=map.get("shipVia");
			if(shipVia==null)
				shipVia="";
			String freightTerms=map.get("freightTerms");
			if(freightTerms==null)
				freightTerms="";
			String orderDate=map.get("orderDate");
			if(orderDate==null)
				orderDate="";
			String orderTotal=df.format(Double.parseDouble(map.get("orderTotal").toString()));
			if(orderTotal==null)
				orderTotal="";
			String totalSale=df.format(Double.parseDouble(map.get("totalSale").toString()));
			if(totalSale==null)
				totalSale="";
			String contactName=map.get("miscTen");
			if(contactName==null)
				contactName="";
			String phoneNo=map.get("miscEleven");
			if(phoneNo==null)
				phoneNo="";
        		
			PdfPCell cell = null;
			cell = new PdfPCell(new Phrase(1, "Total Sale :", totalBoldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			cell.setBorder(PdfCell.NO_BORDER);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "$"+totalSale, totalTextFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			cell.setBorder(PdfCell.NO_BORDER);
			cell.setColspan(5);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Order Total :", totalBoldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			cell.setBorder(PdfCell.NO_BORDER);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "$"+orderTotal, totalTextFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			cell.setBorder(PdfCell.NO_BORDER);
			cell.setColspan(5);
			headerTable.addCell(cell);

			cell = new PdfPCell(new Phrase(1, "", textFont));
			cell.setColspan(6);
			cell.setBorder(PdfCell.NO_BORDER);
			cell.setFixedHeight(10f);
			headerTable.addCell(cell);
			
			cell = new PdfPCell(new Phrase(1, "SO#", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, soOrderId, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Branch", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, systemId, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Ordered Date", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, orderDate, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
				
			cell = new PdfPCell(new Phrase(1, "Customer#", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, custCode+" : "+custName, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Customer Name", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, custName, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Customer PO", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, custPo, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);

			cell = new PdfPCell(new Phrase(1, "Ship To", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, custName, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Ordered By", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, orderedBy, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Payment Terms Code", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, payTermsCode, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Address 1", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, addressOne, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Expected Delivery Date", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, expectedDeliveryDate, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Reference", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, reference, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);

			cell = new PdfPCell(new Phrase(1, "Address 2", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, addressTwo, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Contact Name", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, custName, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Ship Via", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, shipVia, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			cell.setColspan(2);
			headerTable.addCell(cell);

			cell = new PdfPCell(new Phrase(1, "City/State/Zip", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, city+" "+state+" "+zip, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Phone", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, phoneNo, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Freight Terms", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, freightTerms, textFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			//cell.setColspan(2);
			headerTable.addCell(cell);
			
			containerCell = new PdfPCell();
			containerCell.addElement(headerTable);
			containerTable.addCell(containerCell);

			cell = new PdfPCell(new Phrase(1, "", textFont));
			cell.setColspan(12);
			cell.setBorder(PdfCell.NO_BORDER);
			cell.setFixedHeight(10f);
			detailsTable.addCell(cell);
				
			cell = new PdfPCell(new Phrase(1, "SO#", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Line#", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Item", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Description", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Size", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Ordered Qty", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Shipped", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Remaining Qty", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "UOM", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Price", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "UOM", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			detailsTable.addCell(cell);
			cell = new PdfPCell(new Phrase(1, "Ext Total", boldFont));
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			detailsTable.addCell(cell);

			ArrayList<HashMap<String, String>> listData = getOpenOrdersInquiryDetails(soId);
			if(listData!=null && listData.size()>0){
  				for(int i=0; i<listData.size(); i++){
  					HashMap temp=(HashMap)listData.get(i);
  					cell = new PdfPCell(new Phrase(1, temp.get("soId").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("sequence").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("item").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("description").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("size").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, dftpd.format(Double.parseDouble(temp.get("qtyOrdered").toString())), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, dftpd.format(Double.parseDouble(temp.get("shipped").toString())), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, dftpd.format(Double.parseDouble(temp.get("remainingQty").toString())), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("uom").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, dftpd.format(Double.parseDouble(temp.get("price").toString())), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, temp.get("priceUomCode").toString(), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
  					detailsTable.addCell(cell);
  					cell = new PdfPCell(new Phrase(1, df.format(Double.parseDouble(temp.get("extPrice").toString())), textFont));
  					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
  					detailsTable.addCell(cell);
  					
				}
			}
			
			containerCell = new PdfPCell();
			containerCell.addElement(detailsTable);
			containerTable.addCell(containerCell);
			
			//document.add(mainTable);
			document.add(containerTable);
			document.close();
			Utils.log("PDF ----Generated-----");
		}
		catch(Exception e){
			Utils.log("Exception SS >> ",e);
		}
			 
		byte [] returnBytes = documentBytes.toByteArray();
		Utils.log("returnBytes : "+returnBytes);
		documentBytes.close();
		return returnBytes;
	}

%>
