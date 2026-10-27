<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.time.LocalDate" %>
<%@page import="java.time.format.DateTimeFormatter" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="jakarta.servlet.http.Part"%>
<%@page import="jakarta.servlet.annotation.MultipartConfig"%>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="java.text.DecimalFormat"%>
<%-- <%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%> --%>
<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>

<%@page import="javax.ws.rs.core.MediaType" %>
<%@page import="java.net.URL" %>
<%@page import="java.net.HttpURLConnection" %>
<%@page import="java.security.cert.CertificateException" %>
<%@page import="java.security.cert.X509Certificate" %>

<%@page import="javax.net.ssl.HostnameVerifier" %>
<%@page import="javax.net.ssl.HttpsURLConnection" %>
<%@page import="javax.net.ssl.SSLContext" %>
<%@page import="javax.net.ssl.SSLSession" %>
<%@page import="javax.net.ssl.TrustManager" %>
<%@page import="javax.net.ssl.X509TrustManager" %>

<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.io.FileUtils"%>


<%
	try {
		DistUtils du=new DistUtils();
		Utils u= new Utils();
		final DecimalFormat df = new DecimalFormat("#,###,###,##0.000");
		String userId = (String)session.getAttribute("userId").toString().trim();
		Utils.log("userId >>>> "+userId);
		String changeCustomerUserId = (String)session.getAttribute("changeCustomerUserId");
		if(changeCustomerUserId == null || changeCustomerUserId.trim().isEmpty()) {
		    changeCustomerUserId = userId;
		}
		
		String companyId = (String)session.getAttribute("companyId").toString().trim();
		String custKey=(String)session.getAttribute("custKey").toString().trim();
		String customerId = (String)session.getAttribute("customerId").toString().trim();
		//String defaultWarehouse = (String)session.getAttribute("defaultWarehouse");
		String defaultWarehouse=Utils.removeNull(du.getFieldInfo("select defaultwarehouse from etechuser where deptid='"+customerId+"' and userid='"+changeCustomerUserId+"'"));
		Utils.log("DefaultWarehouse >>>> "+defaultWarehouse);
		String warehouse=Utils.removeNull(du.getFieldInfoPro2("SELECT SYSTEM_ID from SYSTEM_FILE where SYSTEM_ID like '%"+defaultWarehouse+"'"));
		Utils.log("Warehouse >>>> "+warehouse);
		
		FileReader reader=new FileReader("eTechLogix.properties");  
		Properties prop=new Properties();  
	    prop.load(reader);    
	    //String url=prop.getProperty("AgilityUrl");
	    String url="https://api-1362-1.dmsi.com/AgilityPublic/rest/";
	    String loginUrl = url+"Session/Login";
	    
		JSONObject childBody=new JSONObject();
		childBody.put("LoginID", "API");
		childBody.put("Password", "~Zrwcetech123");
		JSONObject mainBody=new JSONObject();
		mainBody.put("request", childBody);

		String param = Utils.removeNull(request.getParameter("param")).trim();
		Utils.log("Param >>>> " + param);
		if(param.equalsIgnoreCase("CreateOrder")){
			String output="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
			ArrayList<HashMap<String, String>> listData = getDetail(quoteId);
			for(int i=0;i<listData.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)listData.get(i);
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("item", map.get("item"));
				jsonObj.put("description", map.get("quoteDesc")+" "+map.get("extDesc"));
				jsonObj.put("size", map.get("size"));
				jsonObj.put("price", map.get("price"));
				jsonObj.put("priceUomCode", map.get("priceUomCode"));
				jsonObj.put("quantity", map.get("quantity"));
				jsonObj.put("stockingUom", map.get("stockingUom"));
				jsonArray.add(jsonObj);
			}
			mainJSONObj.put("Details", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("HeaderDetails")){
				String output="";
				String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
				JSONObject jsonObj = new JSONObject();
				HashMap<String, String> map = getCustomerDetail(quoteId);
				jsonObj.put("shipToName", map.get("custName"));
				jsonObj.put("addressOne", map.get("addressOne"));
				jsonObj.put("addressTwo", map.get("addressTwo"));
				jsonObj.put("addressThree", map.get("addressThree"));
				jsonObj.put("shipVia", map.get("shipVia"));
				jsonObj.put("city", map.get("city"));
				jsonObj.put("state", map.get("state"));
				jsonObj.put("zip", map.get("zip"));
				jsonObj.put("contactName", map.get("miscTen"));
				jsonObj.put("phone", map.get("miscEleven"));
				output=jsonObj.toString();
				out.print(output);
		}
		else if(param.equalsIgnoreCase("SaveOrder")){
			String message="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			
			HashMap<String, String> mapData = getCustomerDetail(quoteId);
			String templateId=mapData.get("quoteId");
			String systemId=mapData.get("systemId");
			String custName=mapData.get("custName");
			String shipToSeqNum=mapData.get("shipToSeqNum");
			String custPORequired=mapData.get("custPORequired");
			String emailAddress=mapData.get("emailAddress");
			//String shipToName=mapData.get("shipToName"); 
			/*String addressOne=mapData.get("addressOne"); 
			String addressTwo=mapData.get("addressTwo"); 
			String addressThree=mapData.get("addressThree"); 
			String city=mapData.get("city"); 
			String state=mapData.get("state"); 
			String zip=mapData.get("zip");*/ 
			String country=mapData.get("country");
			String phone=mapData.get("phone");
			String taxCode=mapData.get("taxCode");
			String saleType=mapData.get("saleType");
			//String shipVia=mapData.get("shipVia"); 
			String shipComplete=mapData.get("shipComplete");
			String miscOne=mapData.get("miscOne");
			String miscTwo=mapData.get("miscTwo");
			String miscThree=mapData.get("miscThree");
			String miscFour=mapData.get("miscFour");
			String miscFive=mapData.get("miscFive");
			String miscSix=mapData.get("miscSix");
			String miscSeven=mapData.get("miscSeven");
			String miscEight=mapData.get("miscEight");
			String miscNine=mapData.get("miscNine");
			String miscTen=mapData.get("miscTen");
			String miscEleven=mapData.get("miscEleven");
			String miscTwelve=mapData.get("miscTwelve");
			String miscDateOne=mapData.get("miscDateOne");
			String miscDateTwo=mapData.get("miscDateTwo");
			String origSourceId=mapData.get("origSourceId");
			String salesAgentOne=mapData.get("salesAgentOne");
			String salesAgentTwo=mapData.get("salesAgentTwo");
			String salesAgentThree=mapData.get("salesAgentThree");
			String salesAgentOnePCTDelt=mapData.get("salesAgentOnePCTDelt");
			String salesAgentTwoPCTDelt=mapData.get("salesAgentTwoPCTDelt");
			String salesAgentThreePCTDelt=mapData.get("salesAgentThreePCTDelt");
			String freightTerms=mapData.get("freightTerms");
			String payTermsCode=mapData.get("payTermsCode");
			
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String messageStr = Utils.removeNull(request.getParameter("message")).trim();
			String notes = Utils.removeNull(request.getParameter("notes")).trim();
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String addressThree = Utils.removeNull(request.getParameter("addressThree")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String memoOne = Utils.removeNull(request.getParameter("memoOne")).trim();
			String memoTwo = Utils.removeNull(request.getParameter("memoTwo")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();

			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			if(expectedDeliveryDate.trim().equals("")){
				Date currentDate = new Date();
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				String fullYear="";
				String year=expectedDeliveryDate.substring(6,expectedDeliveryDate.length());
				if(year.length() == 2){
					if(Integer.parseInt(year) < 50)
						fullYear="20"+year;
			   		else
			   			fullYear="19"+year;
			  	}
				else{
					fullYear=year;
				}

				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate.substring(0,6)+fullYear.trim());
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}
			
			String itemCode = Utils.removeNull(request.getParameter("itemCode")).trim();
			String priceString = Utils.removeNull(request.getParameter("price")).trim();
			String priceUom = Utils.removeNull(request.getParameter("priceUom")).trim();
			String orderedQty = Utils.removeNull(request.getParameter("orderedQty")).trim();
			String stockingUom = Utils.removeNull(request.getParameter("stockingUom")).trim();
			
			String[] itemCodeArray = itemCode.split(",");
			String[] priceArray = priceString.split(",");
			String[] priceUomArray = priceUom.split(",");
			String[] orderedQtyArray = orderedQty.split(",");
			String[] stockingUomArray = stockingUom.split(",");
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("CustomerID", customerId);
			jsonObject.put("ShipToSequence", Integer.parseInt(shipToSeqNum)); 
			jsonObject.put("TransactionReference", referenceId.trim());
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", userId.trim());
			jsonObject.put("CustomerPurchaseOrder", customerPo.trim());
			jsonObject.put("CheckPORequiredSettings", false);
			jsonObject.put("CheckPODuplicateSettings", false);
			jsonObject.put("AcknowledgementEmailAddress", emailAddress.trim());
			jsonObject.put("AcknowledgementEmailAddress2", "");
			jsonObject.put("AcknowledgementFaxNumber", "");
			jsonObject.put("PrePaid", false);
			jsonObject.put("ShipToName", shipToName.trim()); 
			jsonObject.put("ShipToAddress1", addressOne.trim());
			jsonObject.put("ShipToAddress2", addressTwo.trim());
			jsonObject.put("ShipToAddress3", addressThree.trim());
			jsonObject.put("ShipToCity", city.trim());
			jsonObject.put("ShipToState", state.trim());
			jsonObject.put("ShipToZip", zip.trim());
			jsonObject.put("ShipToCountry", country.trim());
			jsonObject.put("ShipToPhone", phone.trim());
			jsonObject.put("TaxCode", taxCode.trim());
			jsonObject.put("SaleType", saleType.trim());
			jsonObject.put("OrderMessage", messageStr.trim());
			jsonObject.put("OrderHold", true);
			jsonObject.put("ShipVia", shipVia.trim());
			jsonObject.put("ShipComplete", false);
			jsonObject.put("ShipCompleteOverride", false);
			jsonObject.put("CreateShipment", false);
			jsonObject.put("MiscField1", miscOne.trim());
			jsonObject.put("MiscField2", miscTwo.trim());
			jsonObject.put("MiscField3", miscThree.trim());
			jsonObject.put("MiscField4", miscFour.trim());
			jsonObject.put("MiscField5", quoteId.trim());
			jsonObject.put("MiscField6", miscSix.trim());
			jsonObject.put("MiscField7", miscSeven.trim());
			jsonObject.put("MiscField8", miscEight.trim());
			jsonObject.put("MiscField9", miscNine.trim());
			jsonObject.put("MiscField10", memoOne.trim());
			jsonObject.put("MiscField11", memoTwo.trim());
			jsonObject.put("MiscField12", miscTwelve.trim());
			jsonObject.put("MiscDate1", null);
			jsonObject.put("MiscDate2", null);
			jsonObject.put("APISourceID", userId.trim());
			jsonObject.put("SalesAgent1", salesAgentOne.trim());
			jsonObject.put("SalesAgent2", "API"); 
			jsonObject.put("SalesAgent3", salesAgentThree.trim());
			jsonObject.put("SalesAgent4", "");
			jsonObject.put("SalesAgent5", "");
			jsonObject.put("SalesAgent6", "");
			jsonObject.put("SalesAgent1PctOfOrder", salesAgentOnePCTDelt.trim());
			jsonObject.put("SalesAgent2PctOfOrder", salesAgentTwoPCTDelt.trim());
			jsonObject.put("SalesAgent3PctOfOrder", salesAgentThreePCTDelt.trim());
			jsonObject.put("SalesAgent4PctOfOrder", "");
			jsonObject.put("SalesAgent5PctOfOrder", "");
			jsonObject.put("SalesAgent6PctOfOrder", "");
			jsonObject.put("RouteID", "");
			jsonObject.put("ExpectedDate", expectedDeliveryDate.trim());
			jsonObject.put("OverrideShippingTrackingData", true);
			jsonObject.put("ShippingTrackingSignatureReq", true);
			jsonObject.put("ShippingTrackingInsuranceReq", false);
			jsonObject.put("ShippingTrackingSaturdayDelivery", true);
			jsonObject.put("ShippingTrackingSundayDelivery", false);
			jsonObject.put("ShippingTrackingDelvInstructions", "");
			jsonObject.put("FreightTerms", freightTerms.trim());
			jsonObject.put("PaymentTerms", payTermsCode.trim());

			JSONArray dtOrderHeaderRequestArray = new JSONArray();
			dtOrderHeaderRequestArray.add(jsonObject);

			JSONObject dsOrderHeaderRequestObj=new JSONObject();
			dsOrderHeaderRequestObj.put("dtOrderHeaderRequest", dtOrderHeaderRequestArray.toString());
			
			JSONObject jsonObjectNotes1=new JSONObject();
			//jsonObjectNotes1.put("OrderNote", "Hold order");
			jsonObjectNotes1.put("OrderNote", notes.trim());
			jsonObjectNotes1.put("HotNote", true);

			JSONArray dtOrderHeaderNotesRequestArray = new JSONArray();
			dtOrderHeaderNotesRequestArray.add(jsonObjectNotes1);
			
			JSONObject jsonObjectNotes2=new JSONObject();
			//jsonObjectNotes2.put("OrderNote", "Must ship on time");
			jsonObjectNotes2.put("OrderNote", notes.trim());
			jsonObjectNotes2.put("HotNote", false);
			dtOrderHeaderNotesRequestArray.add(jsonObjectNotes2);
			
			dsOrderHeaderRequestObj.put("dtOrderHeaderNotesRequest", dtOrderHeaderNotesRequestArray.toString());

			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject jsonObjectTwo=new JSONObject();
				jsonObjectTwo.put("Sequence", 1);
				jsonObjectTwo.put("ItemCode", itemCodeArray[i]);
				jsonObjectTwo.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				jsonObjectTwo.put("UOM", stockingUomArray[i]);
				jsonObjectTwo.put("Charge", false);
				jsonObjectTwo.put("Price", Double.parseDouble(priceArray[i]));
				jsonObjectTwo.put("PriceUOM", priceUomArray[i]);
				jsonObjectTwo.put("PriceOverride", true);
				jsonObjectTwo.put("UseItemConvertPriceAndUOM", false);
				jsonObjectTwo.put("OrderCost", false);
				jsonObjectTwo.put("CustomerPOLineNumber", "");
				jsonObjectTwo.put("DepartmentName", "");
				jsonObjectTwo.put("DepartmentNumber", "");
				jsonObjectTwo.put("PartNumber", "");
				jsonObjectTwo.put("SKU", "");
				jsonObjectTwo.put("UPCCode", "");
				jsonObjectTwo.put("ItemMessage", "");
				jsonObjectTwo.put("PrintMsgOnForms", false);
				jsonObjectTwo.put("PrintMsgOnFormsOverride", false);
				jsonObjectTwo.put("SendMsgToWMS", false);
				jsonObjectTwo.put("SendMsgToWMSOverride", false);
				jsonObjectTwo.put("APIPriceSourceType", "");
				jsonObjectTwo.put("APIPriceSourceRef", "");
				
				dtOrderItemRequestArray.add(jsonObjectTwo);
			}
			
			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			
			JSONObject jsonObjectThree=new JSONObject();
			jsonObjectThree.put("OrderItemSequence", 0);
			jsonObjectThree.put("ComponentSequence", 0);
			jsonObjectThree.put("BomType", "");
			jsonObjectThree.put("ItemCode", "");
			jsonObjectThree.put("PartNumber", "");
			jsonObjectThree.put("OrderQty", 0);
			jsonObjectThree.put("Price", 0);
			jsonObjectThree.put("PriceOverride", true);
			jsonObjectThree.put("Thickness", 0);
			jsonObjectThree.put("Width", 0);
			jsonObjectThree.put("Length", 0);
			jsonObjectThree.put("PieceCount", 0);
			jsonObjectThree.put("TallyUOM", "");
			jsonObjectThree.put("PrintFlag", false);
			jsonObjectThree.put("SundryCost", 0);
			jsonObjectThree.put("SundryCostOverride", false);
			jsonObjectThree.put("ItemMessage", "");
			jsonObjectThree.put("PrintMsgOnForms", false);
			jsonObjectThree.put("PrintMsgOnFormsOverride", false);
			jsonObjectThree.put("UOM", "");
			
			JSONArray dtOrderItemComponentRequestArray = new JSONArray();
			dtOrderItemComponentRequestArray.add(jsonObjectThree);
			
			JSONObject dsOrderItemComponentRequestObj=new JSONObject();
			dsOrderItemComponentRequestObj.put("dtOrderItemComponentRequest", dtOrderItemComponentRequestArray.toString());
			
			JSONObject jsonObjectFour=new JSONObject();
	        jsonObjectFour.put("JurisdictionType", "State");
			jsonObjectFour.put("State", "NV");
			jsonObjectFour.put("County", "");
			jsonObjectFour.put("City", "");
			jsonObjectFour.put("Description", "");
			jsonObjectFour.put("SalesTaxRate", 0);
			
			JSONArray dtTaxAuthorityRequestArray = new JSONArray();
			dtTaxAuthorityRequestArray.add(jsonObjectFour);
			
			JSONObject dsTaxAuthorityRequestObj=new JSONObject();
			dsTaxAuthorityRequestObj.put("dtTaxAuthorityRequest", dtTaxAuthorityRequestArray.toString());
			
			JSONObject finalObj=new JSONObject();
			finalObj.put("dsOrderHeaderRequest",dsOrderHeaderRequestObj);
			finalObj.put("dsOrderItemRequest",dsOrderItemRequestObj);
			finalObj.put("dsOrderItemComponentRequest",dsOrderItemComponentRequestObj);
			finalObj.put("dsTaxAuthorityRequest",dsTaxAuthorityRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request",finalObj);

			Utils.log("Create Order Request Object >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				Utils.log("Login Response >>>> "+loginRespObj);
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				Utils.log("Context Id >>>> "+contextId);
				//String systemId = loginResp.get("InitialBranch").toString();
				Utils.log("System Id >>>> "+systemId);
				
				String createOrderUrl = url+"Orders/SalesOrderCreate";
				//String createOrderUrl = url+"Orders/SalesOrderCreateValidate";
				
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,createOrderUrl,contextId,systemId);
	        	Utils.log("SalesOrderCreate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		int newOrderId = Integer.parseInt(res.get("NewOrderID").toString());
	        		Utils.log("NewOrderID >>>> "+newOrderId);
	        		
	    			String deviceId="BROWSER";
	    			String imageType="S";
	    			int imageSlNo = 1;
	    			String shipmentId ="1";
	    			String fileName ="";
	    			
	    			Collection<Part> parts = request.getParts();
	    			for (Part part : parts) {
	    			    if (part.getName().equals("documentFile") && part.getSize() > 0) {
		    				Utils.log("content-disposition >>>> "+part.getHeader("content-disposition"));
		    				for(String cd : part.getHeader("content-disposition").split(";")) {
		    					Utils.log("cd >>>> "+cd);
		    					if (cd.trim().startsWith("filename")){
		    						Utils.log(cd.substring(cd.indexOf('=') + 1).trim().replace("\"", ""));
		    						fileName=cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
		    			        }
		    				}
			    			long sizeInBytes = part.getSize();
			    			Utils.log("sizeInBytes >>>> "+sizeInBytes);	
			    			Utils.log("FileName >>>> "+fileName);
		    				
			    			if(fileName==null){
			    				request.setAttribute("message","Select pdf Or jpeg file to upload");
			    			}
			    			else {
			    				String headerHomeEx ="";
			    				int dotPosition = fileName.lastIndexOf(".");
			    				headerHomeEx = fileName.substring(dotPosition+1,fileName.length());	

			    				if(headerHomeEx.equalsIgnoreCase("xlsx") 
			    					|| headerHomeEx.equalsIgnoreCase("docx")
			    					|| headerHomeEx.equalsIgnoreCase("txt")
			    					|| headerHomeEx.equalsIgnoreCase("csv")
			    					|| headerHomeEx.equalsIgnoreCase("png"))
			    				{
			    					request.setAttribute("message","File must be pdf Or jpeg ");
			    				}
			    				else{ 
									FileReader mobileReader=new FileReader("MobileApp.properties");  
								    Properties p=new Properties();  
								    p.load(mobileReader);    
								    String path=p.getProperty("ImagePathCustomerPortal");
								    Utils.log("Path >>>> "+path);  

								    String folderName = path+companyId+"-"+String.valueOf(newOrderId)+"-"+shipmentId;
									File forFolder=new File(folderName);
									if(!forFolder.exists()) {
										boolean flag=forFolder.mkdirs();
										if(!flag){
											request.setAttribute("message","Unable to create directory.");
										}
									}
									
									imageSlNo = getImageSlNo(companyId, String.valueOf(newOrderId), shipmentId);
									fileName = companyId+"-"+String.valueOf(newOrderId)+"-"+shipmentId+"-"+String.format("%02d" , imageSlNo)+"."+headerHomeEx;
									//String filePath = folderName +"/"+ fileName;
									//File imageFile = new File(filePath);
									//fileItem.write(imageFile);

		    						String inBoundFilePath = folderName +"/"+ fileName;
		    						Utils.log("In Bound File Path >>>> " + inBoundFilePath);
		    						InputStream fileContent=part.getInputStream();
		    						File file = new File(inBoundFilePath);
		    		        		try{
		    		        			FileOutputStream outputStream = new FileOutputStream(file);
		    		        			byte[] buffer = new byte[4096];
		    		            		int bytesRead;
		    		            		while ((bytesRead = fileContent.read(buffer)) != -1) {
		    		                		outputStream.write(buffer, 0, bytesRead);
		    		            		}
		    		            		outputStream.close();
		    		        		}
		    						catch(Exception exception) {
		    							Utils.log("Exception in writing file >>>> "+exception);	
		    						}
										
									long imageSize = (sizeInBytes/1024);
									
									String awsUrl="MobileService/OrderImage/"+companyId+"-"+String.valueOf(newOrderId)+"-"+shipmentId+"/"+fileName;

									S3_Upload su = new S3_Upload();
					        		String result= su.S3uploadImage(new File(inBoundFilePath), awsUrl, "rwcappliveimage");
					        		if(result.equalsIgnoreCase("success")){
					        			String status = insertImage(companyId,String.valueOf(newOrderId),shipmentId,userId,imageType,fileName,imageSlNo,imageSize);
						    			if(status.equalsIgnoreCase("success"))
						    				request.setAttribute("message", "Your document has been uploaded Successfully.");
						    			else
						    				request.setAttribute("message", "We are facing some technical issue. Please try again....");
							    	}

			    				}
		    				}

	    				}
    			    }
    			
	    			message="<div class='bg-success-subtle p-3 text-center'>"
		    	          		+"<img src='NewPortalAssets/assets/images/icons/success-icon.png' width='70px' alt='' class='mb-3'>"
		    	         		+"<p class='mb-0'>The new order is created and order# is "+newOrderId+" to view <a href='javascript:popupForOpenOrdersInquiry(\""+newOrderId+"\")'>click here</a></p>"
	    	       			+"</div>";

					String from = "RWC Customer Service Portal <portal@rwc.org>";
					String to = "c.held@rwc.org,basil@rwc.org";
					//String to = "sachendra.agr@gmail.com,basil@rwc.org";
					String sendCC = "";
					String sendBCC = "";
					String subject = "";
					String tag = "Invitation";
					String htmlBody = "";
					String textBody = "Hello";
					String replyTo = "";
					String messageStream = "outbound";
						
					subject="Customer Portal: New Order# "+newOrderId+" by "+userId.trim()+" ";
					htmlBody="<html><BODY cellpadding=\"0\" cellspacing=\"0\">"+
									"<table border=\"0\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" hspace=\"0\" vspace=\"0\"  bordercolor=\"#FFFFFF\">"+
										"<tr><td><table height=\"100\" width=\"100%\">"+
												"<tr><td> A new Order# "+newOrderId+" is created by User "+userId.trim()+". </td></tr>"+
												"<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>"+
												"<tr><td><b> Warm regards,</b></td></tr>"+
												"<tr><td><b> RWC Building Products Customer Service</b></td></tr>"+
											"</table></td></tr>"+
									"</table></BODY></html>";
					sendMail(from,to,sendCC,sendBCC,subject,tag,htmlBody,textBody,replyTo,messageStream);
	        	}
	        	else{
	    			message="<div class='bg-danger-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/fail-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='text-danger mb-0'>Unable to process your request. Please try after some time.</p>"
	              			+"</div>";
	        	}
			}
			
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("QuicklistPriceandAvailList")){
			String message="",output="";

			JSONObject jsonObject=new JSONObject();
			jsonObject.put("CustomerID", customerId);
			jsonObject.put("ShipToSequence", 0); 

			JSONObject requestObj=new JSONObject();
			requestObj.put("request",jsonObject);

			Utils.log("QuicklistPriceandAvailList Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();

				String quicklistPriceandAvailListUrl = url+"Orders/QuicklistPriceandAvailList";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quicklistPriceandAvailListUrl,contextId,warehouse);
	        	Utils.log("QuicklistPriceandAvailList Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	    			JSONObject mainJSONObj = new JSONObject();
	        		JSONArray jsonArray = new JSONArray();
					JSONObject jsonObj = null;
	        		JSONObject itemCustomerPricingResponse = (JSONObject)res.get("ItemCustomerPricingResponse");
	        		if(itemCustomerPricingResponse != null){
	        			JSONObject dsItemCustomerPricingResponse = (JSONObject)itemCustomerPricingResponse.get("dsItemCustomerPricingResponse");
	        			if(dsItemCustomerPricingResponse != null){
	        				JSONArray dtItemPriceAndQtyResponseArray = (JSONArray)dsItemCustomerPricingResponse.get("dtItemPriceAndQtyResponse");
	        				if(dtItemPriceAndQtyResponseArray != null){
	            	    		for(int i=0;i<dtItemPriceAndQtyResponseArray.size();i++){
	            	    			JSONObject obj = (JSONObject)dtItemPriceAndQtyResponseArray.get(i);
        	    	        		jsonObj = new JSONObject();
        	    	        		jsonObj.put("itemCode", obj.get("ItemCode").toString());
        	    	        		jsonObj.put("itemXref", obj.get("ItemXref").toString());
        	    	        		jsonObj.put("itemSize", obj.get("ItemSize").toString());
        	    	        		jsonObj.put("dimensionSize", obj.get("DimensionSize").toString());
        	    	        		jsonObj.put("itemDescription", obj.get("ItemDescription").toString());
        	    	        		jsonObj.put("extendedDescription", obj.get("ExtendedDescription").toString());
        	    	        		jsonObj.put("thickness", obj.get("Thickness").toString());
        	    	        		jsonObj.put("thicknessUOM", obj.get("ThicknessUOM").toString());
        	    	        		jsonObj.put("width", obj.get("Width").toString());
        	    	        		jsonObj.put("widthUOM", obj.get("WidthUOM").toString());
        	    	        		jsonObj.put("length", obj.get("Length").toString());
        	    	        		jsonObj.put("lengthUOM", obj.get("LengthUOM").toString());
        	    	        		jsonObj.put("itemGroupMajor", obj.get("ItemGroupMajor").toString());
        	    	        		jsonObj.put("itemGroupMinor", obj.get("ItemGroupMinor").toString());
        	    	        		jsonObj.put("minPackQty", obj.get("MinPackQty").toString());
        	    	        		jsonObj.put("minPackType", obj.get("MinPackType").toString());
        	    	        		jsonObj.put("nonsaleable", obj.get("Nonsaleable").toString());
        	    	        		jsonObj.put("stock", obj.get("Stock").toString());
        	    	        		jsonObj.put("itemType", obj.get("ItemType").toString());
        	    	        		jsonObj.put("itemTypeName", obj.get("ItemTypeName").toString());
        	    	        		jsonObj.put("imageUrl", obj.get("ImageUrl").toString());
        	    	        		jsonObj.put("UOM", obj.get("UOM").toString());
        	    	        		jsonObj.put("onHandQty", obj.get("OnHandQty").toString());
        	    	        		jsonObj.put("availableQty", obj.get("AvailableQty").toString());
        	    	        		jsonObj.put("priceUOM", obj.get("PriceUOM").toString());
        	    	        		jsonObj.put("grossPrice", obj.get("GrossPrice").toString());
        	    	        		jsonObj.put("priceUOMGrossPrice", obj.get("PriceUOMGrossPrice").toString());
        	    	        		jsonObj.put("netPrice", obj.get("NetPrice").toString());
        	    	        		jsonObj.put("priceUOMNetPrice", obj.get("PriceUOMNetPrice").toString());
        	    	        		jsonObj.put("discountDescription", obj.get("DiscountDescription").toString());
        	    	        		jsonObj.put("quickList", obj.get("QuickList").toString());
        	    	        		jsonObj.put("rankValue", obj.get("RankValue").toString());
        	    	        		jsonObj.put("dimension", obj.get("Dimension").toString());
        	    	        		jsonObj.put("specialItemType", obj.get("SpecialItemType").toString());
        	    	        		jsonObj.put("promo", obj.get("Promo").toString());
        	    	        		jsonObj.put("defaultWeight", obj.get("DefaultWeight").toString());
        	    	        		jsonObj.put("defaultWeightUOM", obj.get("DefaultWeightUOM").toString());
        	    	        		jsonObj.put("defaultLoad", obj.get("DefaultLoad").toString());
        	    	        		jsonObj.put("defaultLoadUOM", obj.get("DefaultLoadUOM").toString());
        	    	        		jsonObj.put("primarySupplierWeight", obj.get("PrimarySupplierWeight").toString());
        	    	        		jsonObj.put("primarySupplierWeightUOM", obj.get("PrimarySupplierWeightUOM").toString());
        	    	        		jsonObj.put("primarySupplierLoad", obj.get("PrimarySupplierLoad").toString());
        	    	        		jsonObj.put("primarySupplierLoadUOM", obj.get("PrimarySupplierLoadUOM").toString());
        	    	        		jsonArray.add(jsonObj);
	            	    		}
	        				}
	        			}
	        		}
	    			mainJSONObj.put("QuoteItemList", jsonArray);
	    			output=mainJSONObj.toString();
	    			out.print(output);
	        	}
			}
		}
		else if(param.equalsIgnoreCase("CustomerDetails")){
			String output="";
			JSONObject jsonObj = new JSONObject();
			HashMap<String, String> map = getCustDetail(customerId.trim());
			jsonObj.put("addressOne", map.get("addressOne"));
			//jsonObj.put("addressTwo", map.get("addressTwo"));
			//jsonObj.put("addressThree", map.get("addressThree"));
			//jsonObj.put("shipVia", map.get("shipVia"));
			jsonObj.put("city", map.get("city"));
			jsonObj.put("state", map.get("state"));
			jsonObj.put("zip", map.get("zip"));
			//jsonObj.put("contactName", map.get("miscTen"));
			//jsonObj.put("phone", map.get("miscEleven"));
			
			output=jsonObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("SaveTemplate")){
			String message="";
			
			String shipToSeq = Utils.removeNull(request.getParameter("shipToSeq")).trim();
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String contactName = Utils.removeNull(request.getParameter("memoOne")).trim();
			String phone = Utils.removeNull(request.getParameter("memoTwo")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String jobNo = Utils.removeNull(request.getParameter("addressThree")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Date currentDate = new Date();
			if(expectedDeliveryDate.equals("")){
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate);
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			String notes = Utils.removeNull(request.getParameter("notes")).trim();
			String messageStr = Utils.removeNull(request.getParameter("message")).trim();
			
			String todayDate=sdf.format(currentDate);
			
			String itemCode = Utils.removeNull(request.getParameter("itemCode")).trim();
			String priceString = Utils.removeNull(request.getParameter("price")).trim();
			String priceUom = Utils.removeNull(request.getParameter("priceUom")).trim();
			String stockingUom = Utils.removeNull(request.getParameter("stockingUom")).trim();
			
			String[] itemCodeArray = itemCode.split(",");
			String[] priceArray = priceString.split(",");
			String[] priceUomArray = priceUom.split(",");
			String[] stockingUomArray = stockingUom.split(",");
			
			JSONObject completeJSONObj=new JSONObject();
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("CustomerID", customerId);
			jsonObject.put("ShipToSequence", Integer.parseInt(shipToSeq));
			jsonObject.put("SaleType", "WH");//from ship_to table
			jsonObject.put("RequestedDeliveryDate", expectedDeliveryDate.trim());
			jsonObject.put("TransactionReference", referenceId.trim());
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", userId.trim());
			jsonObject.put("CustomerPO", customerPo.trim());
			jsonObject.put("AcknowledgementEmailAddress", "");
			jsonObject.put("AcknowledgementEmailAddress2", "");
			jsonObject.put("AcknowledgementFaxNumber", "");
			jsonObject.put("ShipToName", shipToName.trim());
			jsonObject.put("ShipToAddress1", addressOne.trim());
			jsonObject.put("ShipToAddress2", addressTwo.trim());
			jsonObject.put("ShipToAddress3", jobNo.trim());
			jsonObject.put("ShipToCity", city.trim());
			jsonObject.put("ShipToState", state.trim());
			jsonObject.put("ShipToZip", zip.trim());
			jsonObject.put("ShipToCountry", "");
			jsonObject.put("ShipToPhone", "");
			jsonObject.put("OrderMessage", messageStr.trim());
			jsonObject.put("ShipVia", shipVia.trim());
			jsonObject.put("ActivationDate", todayDate.trim());//today date
			jsonObject.put("CloseDate", "2025-02-14");//date 1 month after today date
			jsonObject.put("ExternalSource", "");
			jsonObject.put("ExternalProjectID", "");
			jsonObject.put("SourceLogin", "");

			JSONArray dtQuoteHeaderRequestArray = new JSONArray();
			dtQuoteHeaderRequestArray.add(jsonObject);

			JSONObject dtQuoteHeaderRequestObj=new JSONObject();
			dtQuoteHeaderRequestObj.put("dtQuoteHeaderRequest", dtQuoteHeaderRequestArray.toString());
			
			JSONArray dtQuoteHeaderNotesRequestArray = new JSONArray();

			JSONObject jsonObjectNotes1=new JSONObject();
			jsonObjectNotes1.put("OrderNote", "Hold order");
			jsonObjectNotes1.put("HotNote", true);
			dtQuoteHeaderNotesRequestArray.add(jsonObjectNotes1);
			
			JSONObject jsonObjectNotes2=new JSONObject();
			jsonObjectNotes2.put("OrderNote", "Must ship on time");
			jsonObjectNotes2.put("HotNote", false);
			dtQuoteHeaderNotesRequestArray.add(jsonObjectNotes2);
			
			dtQuoteHeaderRequestObj.put("dtQuoteHeaderNotesRequest", dtQuoteHeaderNotesRequestArray.toString());

			JSONObject dsQuoteHeaderRequestObj=new JSONObject(); 
			dsQuoteHeaderRequestObj.put("dsQuoteHeaderRequest",dtQuoteHeaderRequestObj);
			
			completeJSONObj.put("QuoteHeaderJSON",dsQuoteHeaderRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject firstJSONObj=new JSONObject();
				firstJSONObj.put("Sequence", 1);
				firstJSONObj.put("ItemCode", itemCodeArray[i]);
				firstJSONObj.put("OrderQty", 1);
				firstJSONObj.put("UOM", stockingUomArray[i]);
				firstJSONObj.put("Charge", false);
				firstJSONObj.put("Price", Double.parseDouble(priceArray[i]));
				firstJSONObj.put("PriceUOM", priceUomArray[i]);
				firstJSONObj.put("PriceOverride", true);
				firstJSONObj.put("UseItemConvertPriceAndUOM", false);
				firstJSONObj.put("OrderCost", false);
				firstJSONObj.put("CustomerPOLineNumber", "");
				firstJSONObj.put("DepartmentName", "");
				firstJSONObj.put("DepartmentNumber", "");
				firstJSONObj.put("PartNumber", "");
				firstJSONObj.put("SKU", "");
				firstJSONObj.put("UPCCode", "");
				firstJSONObj.put("ItemMessage", "");
				firstJSONObj.put("PrintMsgOnForms", false);
				firstJSONObj.put("PrintMsgOnFormsOverride", false);
				firstJSONObj.put("SendMsgToWMS", false);
				firstJSONObj.put("SendMsgToWMSOverride", false);
				firstJSONObj.put("APIPriceSourceType", "");
				firstJSONObj.put("APIPriceSourceRef", "");
				firstJSONObj.put("ShippingBranch", "");
				firstJSONObj.put("DetailGroupID", "");
				firstJSONObj.put("AddPermanentDetailGroupID", false);
				firstJSONObj.put("UseGroupAsDefaultNewItems", false);
				firstJSONObj.put("TemplateItemCode", "");
				firstJSONObj.put("NonStockSize", "");
				firstJSONObj.put("NonStockDescription", "");
				firstJSONObj.put("NonStockExtDescription", "");
				firstJSONObj.put("NonStockCopyCustomFields", false);
				firstJSONObj.put("NonStockSupplierID", "");
				firstJSONObj.put("NonStockSupplierShipFromSequence", 1);
				firstJSONObj.put("NonStockSupplierPartNumber", "");
				firstJSONObj.put("NonStockProductGroupMajor", "");
				firstJSONObj.put("NonStockProductGroupMinor", "");
				firstJSONObj.put("NonStockPriceCodeMajor", "");
				firstJSONObj.put("NonStockPriceCodeMinor", "");
				firstJSONObj.put("NonStockCost", 0);
				firstJSONObj.put("NonStockCostUOM", "");
				
				/* JSONObject secondJSONObj=new JSONObject();
				secondJSONObj.put("ItemCode", "");
				secondJSONObj.put("Charge", false);
				secondJSONObj.put("Price", 0);

				JSONObject thirdJSONObj=new JSONObject();
				thirdJSONObj.put("ItemCode", "");
				thirdJSONObj.put("OrderCost", false);
				thirdJSONObj.put("Price", 0); 
				
				dtOrderItemRequestArray.add(secondJSONObj);
				dtOrderItemRequestArray.add(thirdJSONObj);*/

				dtOrderItemRequestArray.add(firstJSONObj);
			}
			
			JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
			JSONObject fourthJSONObj=new JSONObject();
			fourthJSONObj.put("Sequence", 0);
			fourthJSONObj.put("Thickness", 0);
			fourthJSONObj.put("Width", 0);
			fourthJSONObj.put("Length", 0);
			fourthJSONObj.put("OrderQty", 0);
			fourthJSONObj.put("UOM", "");
			fourthJSONObj.put("Price", 0);
			fourthJSONObj.put("PriceUOM", "");
			fourthJSONObj.put("PriceOverride", false);
			dtOrderItemDimensionRequestArray.add(fourthJSONObj);

			JSONObject finalObj=new JSONObject();
			finalObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			finalObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest",finalObj);
			
			completeJSONObj.put("OrderItemJSON",dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request",completeJSONObj);

			Utils.log("QuoteCreate Request Object >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String createTemplateUrl = url+"Orders/QuoteCreate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,createTemplateUrl,contextId,warehouse);
	        	Utils.log("CreateTemplate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		int newOrderId = Integer.parseInt(res.get("NewOrderID").toString());
	        		Utils.log("NewOrderID >>>> "+newOrderId);
	    			message="<div class='bg-success-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/success-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='mb-0'>The new template is created and template# is "+newOrderId+" </p>"
	              			+"</div>";
	        	}
	        	else{
	    			message="<div class='bg-danger-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/fail-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='text-danger mb-0'>Unable to process your request. Please try after some time.</p>"
	              			+"</div>";
	        	}
			}

			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("GetTemplateHeader")){
			String output="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			
			JSONObject jsonBody=new JSONObject();
			jsonBody.put("SearchBy", "Quote ID");
			jsonBody.put("SearchValue", quoteId);
			jsonBody.put("CustomerID", customerId);
			jsonBody.put("ShipToSequence", 0);
			jsonBody.put("IncludeOnlyOpenQuotes", false);
			jsonBody.put("ChunkStartPointer", "");
			jsonBody.put("RecordFetchLimit", "");
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", jsonBody);
			
			JSONObject jsonObj = new JSONObject();
			
			Utils.log("QuoteList Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();

				String quoteListUrl = url+"Orders/QuoteList";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteListUrl,contextId,warehouse);
	        	Utils.log("QuoteList Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		JSONObject quoteDisplayResponse = (JSONObject)res.get("QuoteDisplayResponse");
	        		if(quoteDisplayResponse != null){
	        			JSONObject dsQuotesResponse = (JSONObject)quoteDisplayResponse.get("dsQuotesResponse");
	        			if(dsQuotesResponse != null){
	        				JSONArray dtQuoteResponseArray = (JSONArray)dsQuotesResponse.get("dtQuoteResponse");
	        				if(dtQuoteResponseArray != null){
	        					for(int j=0;j<dtQuoteResponseArray.size();j++){
	        	        			JSONObject obj = (JSONObject)dtQuoteResponseArray.get(j);
	        	        			Utils.log("QuoteID >>>> "+obj.get("QuoteID").toString());

	        	        			jsonObj.put("quoteId", obj.get("QuoteID").toString());
	        	        			jsonObj.put("shipToName", obj.get("ShipToName").toString());
	        	        			jsonObj.put("addressOne", obj.get("ShipToAddress1").toString());
	        	        			jsonObj.put("addressTwo", obj.get("ShipToAddress2").toString());
	        	        			jsonObj.put("addressThree", obj.get("ShipToAddress3").toString());
	        	        			jsonObj.put("city", obj.get("ShipToCity").toString());
	        	        			jsonObj.put("state", obj.get("ShipToState").toString());
	        	        			jsonObj.put("zip", obj.get("ShipToZip").toString());
	        	        			//jsonObj.put("custName", obj.get("QuoteID").toString());
	        	        			jsonObj.put("phone", obj.get("ShipToPhone").toString());
	        	        			jsonObj.put("shipVia", obj.get("ShipVia").toString());
	        	        			jsonObj.put("customerPO", obj.get("CustomerPO").toString());
	        	        			jsonObj.put("referenceId", obj.get("TransactionReference").toString());
	        	        			jsonObj.put("jobNo", obj.get("TransactionJob").toString());
	        	        			//jsonObj.put("expectedDeliveryDate", "");
	        	        		}
	        				}
	        			}
	        		}
	        	}
			}
			
			/* JSONObject jsonObj = new JSONObject();
			HashMap<String, String> map = getTemplateHeader(customerId,quoteId);
			jsonObj.put("quoteId", map.get("quoteId"));
			jsonObj.put("custPORequired", map.get("custPORequired"));
			jsonObj.put("custName", map.get("custName"));
			jsonObj.put("addressOne", map.get("addressOne"));
			jsonObj.put("addressTwo", map.get("addressTwo"));
			jsonObj.put("addressThree", map.get("addressThree"));
			jsonObj.put("city", map.get("city"));
			jsonObj.put("state", map.get("state"));
			jsonObj.put("zip", map.get("zip")); */
			output=jsonObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("UpdateTemplateHeader")){
			String message="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			Utils.log("quoteId >>>> "+quoteId);
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String jobNo = Utils.removeNull(request.getParameter("jobNo")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			if(expectedDeliveryDate.equals("")){
				Date currentDate = new Date();
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				String fullYear="";
				String year=expectedDeliveryDate.substring(6,expectedDeliveryDate.length());
				if(year.length() == 2){
					if(Integer.parseInt(year) < 50)
						fullYear="20"+year;
			   		else
			   			fullYear="19"+year;
			  	}
				else{
					fullYear=year;
				}

				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate.substring(0,6)+fullYear.trim());
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			JSONObject jsonObject=new JSONObject();
			jsonObject.put("TransactionReference", referenceId);
			jsonObject.put("TransactionJob", jobNo);
			jsonObject.put("OrderedBy", userId);
			jsonObject.put("CustomerPO", customerPo);
			jsonObject.put("ShipVia", shipVia);
			jsonObject.put("RequestedDeliveryDate", expectedDeliveryDate);
			jsonObject.put("ActivationDate", "");
			jsonObject.put("CloseDate", "");
			jsonObject.put("ExternalSource", "");
			jsonObject.put("ExternalProjectID", "");
			
			JSONArray dtQuoteHeaderUpdateRequestArray = new JSONArray();
			dtQuoteHeaderUpdateRequestArray.add(jsonObject);

			JSONObject dtQuoteHeaderUpdateRequestObj=new JSONObject();
			dtQuoteHeaderUpdateRequestObj.put("dtQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestArray);

			JSONObject dsQuoteHeaderUpdateRequestObj=new JSONObject();
			dsQuoteHeaderUpdateRequestObj.put("dsQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestObj);

			JSONObject secondObj=new JSONObject();
			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest", secondObj);
			
			JSONObject mainJSONObj=new JSONObject();
			mainJSONObj.put("OrderID", quoteId);
			mainJSONObj.put("QuoteHeaderUpdateJSON", dsQuoteHeaderUpdateRequestObj);
			mainJSONObj.put("OrderItemUpdateJSON", dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainJSONObj);
			
			Utils.log("QuoteUpdate Header Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String quoteUpdateUrl = url+"Orders/QuoteUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteUpdateUrl,contextId,warehouse);
	        	Utils.log("QuoteUpdate Header Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
	        		message=res.get("MessageText").toString();
	        	else
	    			message=res.get("MessageText").toString();
	        }
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("QuoteIdQuickList")){
			String output="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
			/*ArrayList<HashMap<String, String>> listData = getTemplateItemList(quoteId);
			for(int i=0;i<listData.size();i++){
				HashMap<String, String> map = (HashMap<String, String>)listData.get(i);
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("displaySeq", map.get("displaySeq"));
				jsonObj.put("itemCode", map.get("item"));
				jsonObj.put("itemDescription", map.get("quoteDesc")+" "+map.get("extDesc"));
				jsonObj.put("itemSize", map.get("size"));
				jsonObj.put("grossPrice", map.get("price"));
				jsonObj.put("priceUOM", map.get("priceUomCode"));
				//jsonObj.put("quantity", map.get("quantity"));
				jsonObj.put("UOM", map.get("stockingUom"));
				jsonArray.add(jsonObj);
			}*/
			
			JSONObject jsonBody=new JSONObject();
			jsonBody.put("SearchBy", "Quote ID");
			jsonBody.put("SearchValue", quoteId);
			jsonBody.put("CustomerID", customerId);
			jsonBody.put("ShipToSequence", 0);
			jsonBody.put("IncludeOnlyOpenQuotes", false);
			jsonBody.put("ChunkStartPointer", "");
			jsonBody.put("RecordFetchLimit", "");
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", jsonBody);
			
			Utils.log("QuoteIdQuickList Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();

				String quoteListUrl = url+"Orders/QuoteList";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteListUrl,contextId,warehouse);
	        	Utils.log("QuoteIdQuickList Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		JSONObject quoteDisplayResponse = (JSONObject)res.get("QuoteDisplayResponse");
	        		if(quoteDisplayResponse != null){
	        			JSONObject dsQuotesResponse = (JSONObject)quoteDisplayResponse.get("dsQuotesResponse");
	        			if(dsQuotesResponse != null){
	        				JSONArray dtQuoteResponseArray = (JSONArray)dsQuotesResponse.get("dtQuoteResponse");
	        				if(dtQuoteResponseArray != null){
	        					for(int i=0;i<dtQuoteResponseArray.size();i++){
	        	        			JSONObject obj = (JSONObject)dtQuoteResponseArray.get(i);
	        	        			Utils.log("QuoteID >>>> "+obj.get("QuoteID").toString());
	        	        			JSONArray dtQuoteDetailResponseArray = (JSONArray)obj.get("dtQuoteDetailResponse");
	    	        				if(dtQuoteDetailResponseArray != null){
	    	        					for(int j=0;j<dtQuoteDetailResponseArray.size();j++){
	    	        	        			JSONObject dtQuoteDetailResponseObj = (JSONObject)dtQuoteDetailResponseArray.get(j);
	    	        	        			JSONObject jsonObj = new JSONObject();
			        	        			jsonObj.put("displaySeq", dtQuoteDetailResponseObj.get("DisplaySequence").toString());
			        	        			jsonObj.put("itemCode", dtQuoteDetailResponseObj.get("ItemCode").toString());
			        	        			jsonObj.put("itemDescription", dtQuoteDetailResponseObj.get("ItemDescription").toString());
			        	        			jsonObj.put("itemSize", dtQuoteDetailResponseObj.get("ItemSize").toString());
			        	        			jsonObj.put("grossPrice", dtQuoteDetailResponseObj.get("GrossPrice").toString());
			        	        			jsonObj.put("priceUOM", dtQuoteDetailResponseObj.get("PriceUOM").toString());
			        	        			jsonObj.put("extPrice", dtQuoteDetailResponseObj.get("ExtendedPrice").toString());
			        	        			jsonObj.put("qty", dtQuoteDetailResponseObj.get("TotalOrderedQuantity").toString());
			        	        			jsonObj.put("UOM", dtQuoteDetailResponseObj.get("PriceUOM").toString());
			        	        			jsonArray.add(jsonObj);
	    	        					}
	    	        				}
	        	        		}
	        				}
	        			}
	        		}
	        	}
			}
			mainJSONObj.put("QuoteItemList", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("DeleteTemplate")){
			String message="success";
			String quoteId=Utils.removeNull(request.getParameter("quoteId")).trim();
			Utils.log("QuoteDelete quoteId >>>> "+quoteId);

			JSONObject jsonObj=new JSONObject();
			jsonObj.put("QuoteID", quoteId);
			jsonObj.put("DeleteReleasedQuote", true);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", jsonObj);
			
			Utils.log("QuoteDelete Request Object >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String quoteDeleteUrl = url+"Orders/QuoteDelete";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteDeleteUrl,contextId,warehouse);
	        	Utils.log("Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
					request.setAttribute("message", res.get("MessageText").toString());
				else
					request.setAttribute("message", res.get("MessageText").toString());
			}
			response.sendRedirect("../customerPortal/A_CP_Shop.jsp?pageName=Shop");
			return;
		}
		else if(param.equalsIgnoreCase("DeleteTemplateItem")){
			String message="";
			String quoteId=Utils.removeNull(request.getParameter("quoteId")).trim();
			String lineNo=Utils.removeNull(request.getParameter("lineNo")).trim();
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("Sequence", lineNo);

			JSONArray dtOrderItemRequestArray = new JSONArray();
			dtOrderItemRequestArray.add(jsonObject);

			JSONObject dtOrderItemRequestObj=new JSONObject();
			dtOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest", dtOrderItemRequestObj);

			JSONObject mainObj=new JSONObject();
			mainObj.put("OrderID", Integer.parseInt(quoteId));
			mainObj.put("DeleteReleasedDetails", true);
			mainObj.put("QuoteDetailsDeleteJSON", dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainObj);

			Utils.log("QuoteDetailsDelete Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				String systemId = "0302PHX";
				
				String quoteDetailsDeleteUrl = url+"Orders/QuoteDetailsDelete";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteDetailsDeleteUrl,contextId,warehouse);
	        	Utils.log("QuoteDetailsDelete Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		//message=res.get("MessageText").toString();
	        		message="Item Deleted";
	        	}
	        	else
	    			message=res.get("MessageText").toString();
			}
			
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("AddItem")){
			String message="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			Utils.log("quoteId >>>> "+quoteId);
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			
			String itemCode = Utils.removeNull(request.getParameter("itemCode")).trim();
			String priceString = Utils.removeNull(request.getParameter("price")).trim();
			String priceUom = Utils.removeNull(request.getParameter("priceUom")).trim();
			String stockingUom = Utils.removeNull(request.getParameter("stockingUom")).trim();
			
			String[] itemCodeArray = itemCode.split(",");
			String[] priceArray = priceString.split(",");
			String[] priceUomArray = priceUom.split(",");
			String[] stockingUomArray = stockingUom.split(",");
			
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Date currentDate = new Date();
			if(expectedDeliveryDate.equals("")){
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate);
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("TransactionReference", "");
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", "");
			jsonObject.put("CustomerPO", customerPo);
			jsonObject.put("ShipVia", "");
			jsonObject.put("RequestedDeliveryDate", expectedDeliveryDate);
			jsonObject.put("ActivationDate", "");
			jsonObject.put("CloseDate", "");
			jsonObject.put("ExternalSource", "");
			jsonObject.put("ExternalProjectID", "");
			
			JSONArray dtQuoteHeaderUpdateRequestArray = new JSONArray();
			dtQuoteHeaderUpdateRequestArray.add(jsonObject);

			JSONObject dtQuoteHeaderUpdateRequestObj=new JSONObject();
			dtQuoteHeaderUpdateRequestObj.put("dtQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestArray.toString());

			JSONObject dsQuoteHeaderUpdateRequestObj=new JSONObject();
			dsQuoteHeaderUpdateRequestObj.put("dsQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject firstJSONObj=new JSONObject();
				firstJSONObj.put("Sequence", 1);
				firstJSONObj.put("ItemCode", itemCodeArray[i]);
				firstJSONObj.put("OrderQty", 1);
				firstJSONObj.put("UOM", stockingUomArray[i]);
				firstJSONObj.put("Charge", false);
				firstJSONObj.put("Price", Double.parseDouble(priceArray[i]));
				firstJSONObj.put("PriceUOM", priceUomArray[i]);
				firstJSONObj.put("PriceOverride", true);
				firstJSONObj.put("UseItemConvertPriceAndUOM", false);
				firstJSONObj.put("OrderCost", false);
				firstJSONObj.put("CustomerPOLineNumber", "");
				firstJSONObj.put("DepartmentName", "");
				firstJSONObj.put("DepartmentNumber", "");
				firstJSONObj.put("PartNumber", "");
				firstJSONObj.put("SKU", "");
				firstJSONObj.put("UPCCode", "");
				firstJSONObj.put("ItemMessage", "");
				firstJSONObj.put("PrintMsgOnForms", false);
				firstJSONObj.put("PrintMsgOnFormsOverride", false);
				firstJSONObj.put("SendMsgToWMS", false);
				firstJSONObj.put("SendMsgToWMSOverride", false);
				firstJSONObj.put("APIPriceSourceType", "");
				firstJSONObj.put("APIPriceSourceRef", "");
				firstJSONObj.put("DetailGroupID", "");
				firstJSONObj.put("AddPermanentDetailGroupID", false);
				firstJSONObj.put("UseGroupAsDefaultNewItems", false);
				
				dtOrderItemRequestArray.add(firstJSONObj);
			}

			JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
			JSONObject fourthJSONObj=new JSONObject();
			fourthJSONObj.put("Sequence", 0);
			fourthJSONObj.put("Thickness", 0);
			fourthJSONObj.put("Width", 0);
			fourthJSONObj.put("Length", 0);
			fourthJSONObj.put("OrderQty", 0);
			fourthJSONObj.put("UOM", "");
			fourthJSONObj.put("Price", 0);
			fourthJSONObj.put("PriceUOM", "");
			fourthJSONObj.put("PriceOverride", false);
			dtOrderItemDimensionRequestArray.add(fourthJSONObj);

			JSONObject finalObj=new JSONObject();
			finalObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			finalObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest",finalObj);
			
			JSONObject mainObj=new JSONObject();
			mainObj.put("OrderID", quoteId);
			mainObj.put("QuoteHeaderUpdateJSON", dsQuoteHeaderUpdateRequestObj);
			mainObj.put("OrderItemUpdateJSON", dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainObj);
			
			Utils.log("QuoteUpdate Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String quoteUpdateUrl = url+"Orders/QuoteUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteUpdateUrl,contextId,warehouse);
	        	Utils.log("QuoteUpdate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
	    			message=res.get("MessageText").toString();
	        	else
	    			message=res.get("MessageText").toString();
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("SaveCreateOrder")){
			String message="";
			String shipToSeq = Utils.removeNull(request.getParameter("shipToSeq")).trim();
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String contactName = Utils.removeNull(request.getParameter("contactName")).trim();
			String phone = Utils.removeNull(request.getParameter("phone")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String jobNo = Utils.removeNull(request.getParameter("jobNo")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			if(expectedDeliveryDate.equals("")){
				Date currentDate = new Date();
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				String fullYear="";
				String year=expectedDeliveryDate.substring(6,expectedDeliveryDate.length());
				if(year.length() == 2){
					if(Integer.parseInt(year) < 50)
						fullYear="20"+year;
			   		else
			   			fullYear="19"+year;
			  	}
				else{
					fullYear=year;
				}

				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate.substring(0,6)+fullYear.trim());
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			String notes = Utils.removeNull(request.getParameter("notes")).trim();
			String messageStr = Utils.removeNull(request.getParameter("message")).trim();
			
			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");

			JSONObject jsonObject=new JSONObject();
			jsonObject.put("CustomerID", customerId);
			//jsonObject.put("ShipToSequence", Integer.parseInt(shipToSeq));
			jsonObject.put("ShipToSequence", 1);
			jsonObject.put("TransactionReference", referenceId);
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", userId);
			jsonObject.put("CustomerPurchaseOrder", customerPo);
			jsonObject.put("CheckPORequiredSettings", false);
			jsonObject.put("CheckPODuplicateSettings", false);
			jsonObject.put("AcknowledgementEmailAddress", "");
			jsonObject.put("AcknowledgementEmailAddress2", "");
			jsonObject.put("AcknowledgementFaxNumber", "");
			jsonObject.put("PrePaid", false);
			jsonObject.put("ShipToName", shipToName); 
			jsonObject.put("ShipToAddress1", addressOne);
			jsonObject.put("ShipToAddress2", addressTwo);
			jsonObject.put("ShipToAddress3", jobNo);
			jsonObject.put("ShipToCity", city.trim());
			jsonObject.put("ShipToState", state.trim());
			jsonObject.put("ShipToZip", zip.trim());
			jsonObject.put("ShipToCountry", "");
			jsonObject.put("ShipToPhone", phone);
			jsonObject.put("TaxCode", "");
			jsonObject.put("SaleType", "");
			jsonObject.put("OrderMessage", messageStr.trim());
			jsonObject.put("OrderHold", true);
			jsonObject.put("ShipVia", shipVia.trim());
			jsonObject.put("ShipComplete", false);
			jsonObject.put("ShipCompleteOverride", false);
			jsonObject.put("CreateShipment", false);
			jsonObject.put("MiscField1", "");
			jsonObject.put("MiscField2", "");
			jsonObject.put("MiscField3", "");
			jsonObject.put("MiscField4", "");
			jsonObject.put("MiscField5", "");
			jsonObject.put("MiscField6", "");
			jsonObject.put("MiscField7", "");
			jsonObject.put("MiscField8", "");
			jsonObject.put("MiscField9", "");
			jsonObject.put("MiscField10", "");
			jsonObject.put("MiscField11", "");
			jsonObject.put("MiscField12", "");
			jsonObject.put("MiscDate1", null);
			jsonObject.put("MiscDate2", null);
			jsonObject.put("APISourceID", userId.trim());
			jsonObject.put("SalesAgent1", "");
			jsonObject.put("SalesAgent2", "API"); 
			jsonObject.put("SalesAgent3", "");
			jsonObject.put("SalesAgent4", "");
			jsonObject.put("SalesAgent5", "");
			jsonObject.put("SalesAgent6", "");
			jsonObject.put("SalesAgent1PctOfOrder", "");
			jsonObject.put("SalesAgent2PctOfOrder", "");
			jsonObject.put("SalesAgent3PctOfOrder", "");
			jsonObject.put("SalesAgent4PctOfOrder", "");
			jsonObject.put("SalesAgent5PctOfOrder", "");
			jsonObject.put("SalesAgent6PctOfOrder", "");
			jsonObject.put("RouteID", "");
			jsonObject.put("ExpectedDate", expectedDeliveryDate.trim());
			jsonObject.put("OverrideShippingTrackingData", true);
			jsonObject.put("ShippingTrackingSignatureReq", true);
			jsonObject.put("ShippingTrackingInsuranceReq", false);
			jsonObject.put("ShippingTrackingSaturdayDelivery", true);
			jsonObject.put("ShippingTrackingSundayDelivery", false);
			jsonObject.put("ShippingTrackingDelvInstructions", "");
			jsonObject.put("FreightTerms", "");
			jsonObject.put("PaymentTerms", "");

			JSONArray dtOrderHeaderRequestArray = new JSONArray();
			dtOrderHeaderRequestArray.add(jsonObject);

			JSONObject dsOrderHeaderRequestObj=new JSONObject();
			dsOrderHeaderRequestObj.put("dtOrderHeaderRequest", dtOrderHeaderRequestArray.toString());
			
			JSONObject jsonObjectNotes1=new JSONObject();
			//jsonObjectNotes1.put("OrderNote", "Hold order");
			jsonObjectNotes1.put("OrderNote", notes.trim());
			jsonObjectNotes1.put("HotNote", true);

			JSONArray dtOrderHeaderNotesRequestArray = new JSONArray();
			dtOrderHeaderNotesRequestArray.add(jsonObjectNotes1);
			
			JSONObject jsonObjectNotes2=new JSONObject();
			//jsonObjectNotes2.put("OrderNote", "Must ship on time");
			jsonObjectNotes2.put("OrderNote", notes.trim());
			jsonObjectNotes2.put("HotNote", false);
			dtOrderHeaderNotesRequestArray.add(jsonObjectNotes2);
			
			dsOrderHeaderRequestObj.put("dtOrderHeaderNotesRequest", dtOrderHeaderNotesRequestArray.toString());

			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject jsonObjectTwo=new JSONObject();
				jsonObjectTwo.put("Sequence", 1);
				jsonObjectTwo.put("ItemCode", itemCodeArray[i]);
				jsonObjectTwo.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				jsonObjectTwo.put("UOM", stockingUomArray[i]);
				jsonObjectTwo.put("Charge", false);
				jsonObjectTwo.put("Price", Double.parseDouble(priceArray[i]));
				jsonObjectTwo.put("PriceUOM", priceUomArray[i]);
				jsonObjectTwo.put("PriceOverride", true);
				jsonObjectTwo.put("UseItemConvertPriceAndUOM", false);
				jsonObjectTwo.put("OrderCost", false);
				jsonObjectTwo.put("CustomerPOLineNumber", "");
				jsonObjectTwo.put("DepartmentName", "");
				jsonObjectTwo.put("DepartmentNumber", "");
				jsonObjectTwo.put("PartNumber", "");
				jsonObjectTwo.put("SKU", "");
				jsonObjectTwo.put("UPCCode", "");
				jsonObjectTwo.put("ItemMessage", "");
				jsonObjectTwo.put("PrintMsgOnForms", false);
				jsonObjectTwo.put("PrintMsgOnFormsOverride", false);
				jsonObjectTwo.put("SendMsgToWMS", false);
				jsonObjectTwo.put("SendMsgToWMSOverride", false);
				jsonObjectTwo.put("APIPriceSourceType", "");
				jsonObjectTwo.put("APIPriceSourceRef", "");
				
				dtOrderItemRequestArray.add(jsonObjectTwo);
			}
			
			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			
			JSONObject jsonObjectThree=new JSONObject();
			jsonObjectThree.put("OrderItemSequence", 0);
			jsonObjectThree.put("ComponentSequence", 0);
			jsonObjectThree.put("BomType", "");
			jsonObjectThree.put("ItemCode", "");
			jsonObjectThree.put("PartNumber", "");
			jsonObjectThree.put("OrderQty", 0);
			jsonObjectThree.put("Price", 0);
			jsonObjectThree.put("PriceOverride", true);
			jsonObjectThree.put("Thickness", 0);
			jsonObjectThree.put("Width", 0);
			jsonObjectThree.put("Length", 0);
			jsonObjectThree.put("PieceCount", 0);
			jsonObjectThree.put("TallyUOM", "");
			jsonObjectThree.put("PrintFlag", false);
			jsonObjectThree.put("SundryCost", 0);
			jsonObjectThree.put("SundryCostOverride", false);
			jsonObjectThree.put("ItemMessage", "");
			jsonObjectThree.put("PrintMsgOnForms", false);
			jsonObjectThree.put("PrintMsgOnFormsOverride", false);
			jsonObjectThree.put("UOM", "");
			
			JSONArray dtOrderItemComponentRequestArray = new JSONArray();
			dtOrderItemComponentRequestArray.add(jsonObjectThree);
			
			JSONObject dsOrderItemComponentRequestObj=new JSONObject();
			dsOrderItemComponentRequestObj.put("dtOrderItemComponentRequest", dtOrderItemComponentRequestArray.toString());
			
			JSONObject jsonObjectFour=new JSONObject();
	        jsonObjectFour.put("JurisdictionType", "State");
			jsonObjectFour.put("State", "NV");
			jsonObjectFour.put("County", "");
			jsonObjectFour.put("City", "");
			jsonObjectFour.put("Description", "");
			jsonObjectFour.put("SalesTaxRate", 0);
			
			JSONArray dtTaxAuthorityRequestArray = new JSONArray();
			dtTaxAuthorityRequestArray.add(jsonObjectFour);
			
			JSONObject dsTaxAuthorityRequestObj=new JSONObject();
			dsTaxAuthorityRequestObj.put("dtTaxAuthorityRequest", dtTaxAuthorityRequestArray.toString());
			
			JSONObject finalObj=new JSONObject();
			finalObj.put("dsOrderHeaderRequest",dsOrderHeaderRequestObj);
			finalObj.put("dsOrderItemRequest",dsOrderItemRequestObj);
			finalObj.put("dsOrderItemComponentRequest",dsOrderItemComponentRequestObj);
			finalObj.put("dsTaxAuthorityRequest",dsTaxAuthorityRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request",finalObj);

			Utils.log("SalesOrderCreate Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String createOrderUrl = url+"Orders/SalesOrderCreate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,createOrderUrl,contextId,warehouse);
	        	Utils.log("SalesOrderCreate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		int newOrderId = Integer.parseInt(res.get("NewOrderID").toString());
	        		Utils.log("NewOrderID >>>> "+newOrderId);
	    			message="<div class='bg-success-subtle p-3 text-center'>"
		    	          		+"<img src='NewPortalAssets/assets/images/icons/success-icon.png' width='70px' alt='' class='mb-3'>"
		    	         		+"<p class='mb-0'>The new order is created and order# is "+newOrderId+" </p>"
	    	       			+"</div>";
	        	}else{
	    			message="<div class='bg-danger-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/fail-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='text-danger mb-0'>Unable to process your request. Please try after some time.</p>"
	              			+"</div>";
	        	}
			}
			
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("GetCreateOrderHeader")){
			String output="";
			String orderId = Utils.removeNull(request.getParameter("soId")).trim();
			
			JSONObject jsonBody=new JSONObject();
			jsonBody.put("SearchBy", "Order ID");
			jsonBody.put("SearchValue", orderId);
			jsonBody.put("CustomerID", customerId);
			jsonBody.put("ShipToSequence", 0);
			jsonBody.put("OrderDateRangeStart", null);
			jsonBody.put("OrderDateRangeEnd", null);
			jsonBody.put("ExpectedDateRangeStart", null);
			jsonBody.put("ExpectedDateRangeEnd", null);			
			jsonBody.put("FetchOnlyChangedSince", null);
			jsonBody.put("IncludeOpenOrders", true);
			jsonBody.put("IncludeInvoicedOrders", false);			
			jsonBody.put("IncludeCanceledOrders", false);			
			jsonBody.put("ChunkStartPointer", "");	
			jsonBody.put("RecordFetchLimit", "");	

			JSONObject requestObj=new JSONObject();
			requestObj.put("request", jsonBody);
			
			JSONObject jsonObj = new JSONObject();
			Utils.log("SalesOrderList Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();

				String salesOrderListUrl = url+"Orders/SalesOrderList";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderListUrl,contextId,warehouse);
	        	Utils.log("SalesOrderList Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		JSONObject ordersResponse = (JSONObject)res.get("OrdersResponse");
	        		if(ordersResponse != null){
	        			JSONObject dsOrdersResponse = (JSONObject)ordersResponse.get("dsOrdersResponse");
	        			if(dsOrdersResponse != null){
	        				JSONArray dtOrderResponseArray = (JSONArray)dsOrdersResponse.get("dtOrderResponse");
	        				if(dtOrderResponseArray != null){
	        					for(int j=0;j<dtOrderResponseArray.size();j++){
	        	        			JSONObject obj = (JSONObject)dtOrderResponseArray.get(j);
	        	        			Utils.log("OrderID >>>> "+obj.get("OrderID").toString());
	        	        			jsonObj.put("orderId", obj.get("OrderID").toString());
	        	        			jsonObj.put("shipToName", obj.get("ShipToName").toString());
	        	        			jsonObj.put("addressOne", obj.get("ShipToAddress1").toString());
	        	        			jsonObj.put("addressTwo", obj.get("ShipToAddress2").toString());
	        	        			jsonObj.put("addressThree", obj.get("ShipToAddress3").toString());
	        	        			jsonObj.put("city", obj.get("ShipToCity").toString());
	        	        			jsonObj.put("state", obj.get("ShipToState").toString());
	        	        			jsonObj.put("zip", obj.get("ShipToZip").toString());
	        	        			//jsonObj.put("custName", obj.get("QuoteID").toString());
	        	        			jsonObj.put("phone", obj.get("ShipToPhone").toString());
	        	        			jsonObj.put("shipVia", obj.get("ShipVia").toString());
	        	        			jsonObj.put("customerPO", obj.get("CustomerPO").toString());
	        	        			jsonObj.put("referenceId", obj.get("TransactionReference").toString());
	        	        			jsonObj.put("jobNo", obj.get("TransactionJob").toString());
	        	        			//jsonObj.put("expectedDeliveryDate", "");
	        	        		}
	        				}
	        			}
	        		}
	        	}
			}
			output=jsonObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("UpdateOrderHeader")){
			String message="";
			String orderId = Utils.removeNull(request.getParameter("orderId")).trim();
			Utils.log("orderId >>>> "+orderId);
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String contactName = Utils.removeNull(request.getParameter("contactName")).trim();
			String phone = Utils.removeNull(request.getParameter("phone")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String jobNo = Utils.removeNull(request.getParameter("jobNo")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			if(expectedDeliveryDate.equals("")){
				Date currentDate = new Date();
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				String fullYear="";
				String year=expectedDeliveryDate.substring(6,expectedDeliveryDate.length());
				if(year.length() == 2){
					if(Integer.parseInt(year) < 50)
						fullYear="20"+year;
			   		else
			   			fullYear="19"+year;
			  	}
				else{
					fullYear=year;
				}

				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate.substring(0,6)+fullYear.trim());
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			String notes = Utils.removeNull(request.getParameter("notes")).trim();
			String messageStr = Utils.removeNull(request.getParameter("message")).trim();
			
			JSONObject firstJSONObj=new JSONObject();
			firstJSONObj.put("TransactionReference", referenceId);
			firstJSONObj.put("TransactionJob", jobNo);
			firstJSONObj.put("OrderedBy", userId);
			firstJSONObj.put("CustomerPurchaseOrder", customerPo);
			firstJSONObj.put("ShipVia", shipVia);
			firstJSONObj.put("MiscField1", "");
			firstJSONObj.put("MiscField2", "");
			firstJSONObj.put("MiscField3", "");
			firstJSONObj.put("MiscField4", "");
			firstJSONObj.put("MiscField5", "");
			firstJSONObj.put("MiscField6", "");
			firstJSONObj.put("MiscField7", "");
			firstJSONObj.put("MiscField8", "");
			firstJSONObj.put("MiscField9", "");
			firstJSONObj.put("MiscField10", "");
			firstJSONObj.put("MiscField11", "");
			firstJSONObj.put("MiscField12", "");
			firstJSONObj.put("MiscDate1", null);
			firstJSONObj.put("MiscDate2", null);
			firstJSONObj.put("SalesAgent1", "");
			firstJSONObj.put("SalesAgent2", "");
			firstJSONObj.put("SalesAgent3", "");
			firstJSONObj.put("SalesAgent4", "");
			firstJSONObj.put("SalesAgent5", "");
			firstJSONObj.put("SalesAgent6", "");
			firstJSONObj.put("SalesAgent1PctOfOrder", 0);
			firstJSONObj.put("SalesAgent2PctOfOrder", 0);
			firstJSONObj.put("SalesAgent3PctOfOrder", 0);
			firstJSONObj.put("SalesAgent4PctOfOrder", 0);
			firstJSONObj.put("SalesAgent5PctOfOrder", 0);
			firstJSONObj.put("SalesAgent6PctOfOrder", 0);
			
			JSONArray dtOrderHeaderUpdateRequestArray = new JSONArray();
			dtOrderHeaderUpdateRequestArray.add(firstJSONObj);

			JSONObject dtOrderHeaderUpdateRequestObj=new JSONObject();
			dtOrderHeaderUpdateRequestObj.put("dtOrderHeaderUpdateRequest", dtOrderHeaderUpdateRequestArray.toString());

			JSONObject dsOrderHeaderUpdateRequestObj=new JSONObject();
			dsOrderHeaderUpdateRequestObj.put("dsOrderHeaderUpdateRequest", dtOrderHeaderUpdateRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray);

			JSONObject jsonObjectThree=new JSONObject();
			jsonObjectThree.put("OrderItemSequence", 0);
			jsonObjectThree.put("ComponentSequence", 0);
			jsonObjectThree.put("BomType", "");
			jsonObjectThree.put("ItemCode", "");
			jsonObjectThree.put("PartNumber", "");
			jsonObjectThree.put("OrderQty", 0);
			jsonObjectThree.put("Thickness", 0);
			jsonObjectThree.put("Width", 0);
			jsonObjectThree.put("Length", 0);
			jsonObjectThree.put("PieceCount", 0);
			jsonObjectThree.put("TallyUOM", "");
			jsonObjectThree.put("PrintFlag", false);
			jsonObjectThree.put("SundryCost", 0);
			jsonObjectThree.put("SundryCostOverride", false);
			jsonObjectThree.put("ItemMessage", "");
			jsonObjectThree.put("PrintMsgOnForms", false);
			jsonObjectThree.put("PrintMsgOnFormsOverride", false);
			jsonObjectThree.put("UOM", "");
			jsonObjectThree.put("ShipLoose", true);
			
			JSONArray dtOrderItemComponentRequestArray = new JSONArray();
			dtOrderItemComponentRequestArray.add(jsonObjectThree);
			
			JSONObject dtOrderItemComponentRequestObj = new JSONObject();
			dtOrderItemComponentRequestObj.put("dtOrderItemComponentRequest", dtOrderItemComponentRequestArray.toString());

			JSONObject mainJSONObj = new JSONObject();
			mainJSONObj.put("OrderID", orderId);
			mainJSONObj.put("OrderHeaderUpdateJSON", dsOrderHeaderUpdateRequestObj);
			mainJSONObj.put("dsOrderItemRequest", dsOrderItemRequestObj);
			mainJSONObj.put("dsOrderItemComponentRequest", dtOrderItemComponentRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainJSONObj);
			
			Utils.log("SalesOrderUpdate Header Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String salesOrderUpdateUrl = url+"Orders/SalesOrderUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderUpdateUrl,contextId,warehouse);
	        	Utils.log("SalesOrderUpdate Header Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		message=res.get("MessageText").toString();
	        		message="Sales Order header updated";
	        	}else{
	    			message=res.get("MessageText").toString();
	        	}
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("CreateOrderItemList")){
			String output="";
			String orderId = Utils.removeNull(request.getParameter("soId")).trim();
			JSONArray jsonArray = new JSONArray();
			JSONObject mainJSONObj = new JSONObject();
			
			JSONObject jsonBody=new JSONObject();
			jsonBody.put("SearchBy", "Order ID");
			jsonBody.put("SearchValue", orderId);
			jsonBody.put("CustomerID", customerId);
			jsonBody.put("ShipToSequence", 0);
			jsonBody.put("OrderDateRangeStart", null);
			jsonBody.put("OrderDateRangeEnd", null);
			jsonBody.put("ExpectedDateRangeStart", null);
			jsonBody.put("ExpectedDateRangeEnd", null);			
			jsonBody.put("FetchOnlyChangedSince", null);
			jsonBody.put("IncludeOpenOrders", true);
			jsonBody.put("IncludeInvoicedOrders", false);			
			jsonBody.put("IncludeCanceledOrders", false);			
			jsonBody.put("ChunkStartPointer", "");	
			jsonBody.put("RecordFetchLimit", "");	
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", jsonBody);
			
			Utils.log("SalesOrderList Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();

				String salesOrderListUrl = url+"Orders/SalesOrderList";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderListUrl,contextId,warehouse);
	        	Utils.log("SalesOrderList Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		JSONObject ordersResponse = (JSONObject)res.get("OrdersResponse");
	        		if(ordersResponse != null){
	        			JSONObject dsOrdersResponse = (JSONObject)ordersResponse.get("dsOrdersResponse");
	        			if(dsOrdersResponse != null){
	        				JSONArray dtOrderResponseArray = (JSONArray)dsOrdersResponse.get("dtOrderResponse");
	        				if(dtOrderResponseArray != null){
	        					for(int i=0;i<dtOrderResponseArray.size();i++){
	        	        			JSONObject obj = (JSONObject)dtOrderResponseArray.get(i);
	        	        			Utils.log("OrderID >>>> "+obj.get("OrderID").toString());
	        	        			JSONArray dtOrderDetailResponseArray = (JSONArray)obj.get("dtOrderDetailResponse");
	    	        				if(dtOrderDetailResponseArray != null){
	    	        					for(int j=0;j<dtOrderDetailResponseArray.size();j++){
	    	        	        			JSONObject dtOrderDetailResponseObj = (JSONObject)dtOrderDetailResponseArray.get(j);
	    	        	        			JSONObject jsonObj = new JSONObject();
			        	        			jsonObj.put("displaySeq", dtOrderDetailResponseObj.get("DisplaySequence").toString());
			        	        			jsonObj.put("itemCode", dtOrderDetailResponseObj.get("ItemCode").toString());
			        	        			jsonObj.put("itemDescription", dtOrderDetailResponseObj.get("ItemDescription").toString());
			        	        			jsonObj.put("itemSize", dtOrderDetailResponseObj.get("ItemSize").toString());
			        	        			jsonObj.put("grossPrice", dtOrderDetailResponseObj.get("GrossPrice").toString());
			        	        			jsonObj.put("priceUOM", dtOrderDetailResponseObj.get("PriceUOM").toString());
			        	        			jsonObj.put("extPrice", dtOrderDetailResponseObj.get("ExtendedPrice").toString());
			        	        			jsonObj.put("qty", dtOrderDetailResponseObj.get("TotalUnstagedQuantity").toString());
			        	        			jsonObj.put("UOM", dtOrderDetailResponseObj.get("QuantityUOM").toString());
			        	        			jsonArray.add(jsonObj);
	    	        					}
	    	        				}
	        	        		}
	        				}
	        			}
	        		}
	        	}
			}
			mainJSONObj.put("QuoteItemList", jsonArray);
			output=mainJSONObj.toString();
			out.print(output);
		}
		else if(param.equalsIgnoreCase("SalesOrderDetailsUpdate")){
			String message="";
			String orderId = Utils.removeNull(request.getParameter("orderId")).trim();
			String[] itemSeqArray = (request.getParameter("itemSeq")).split(",");
			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");
			
			JSONObject firstJSONObject=new JSONObject();
			firstJSONObject.put("UpdateLinkedTran", false);
			firstJSONObject.put("UpdateLinkedPrintedTran", false);
			
			JSONArray dtDetailUpdateSettingsArray = new JSONArray();
			dtDetailUpdateSettingsArray.add(firstJSONObject);

			JSONObject dtDetailUpdateSettingsObj=new JSONObject();
			dtDetailUpdateSettingsObj.put("dtDetailUpdateSettings", dtDetailUpdateSettingsArray.toString());
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject secondJSONObject=new JSONObject();
				secondJSONObject.put("Sequence", itemSeqArray[i]);
				secondJSONObject.put("OrderQty", orderedQtyArray[i]);
				secondJSONObject.put("UOM", stockingUomArray[i]);
				secondJSONObject.put("UseItemConvertPriceAndUOM", false);
				secondJSONObject.put("DetailGroupID", "");
				secondJSONObject.put("AddPermanentDetailGroupID", false);
				secondJSONObject.put("UseGroupAsDefaultNewItems", false);
				
				JSONObject thirdJSONObject=new JSONObject();
				thirdJSONObject.put("Sequence", itemSeqArray[i]);
				thirdJSONObject.put("Thickness", 2);
				thirdJSONObject.put("Width", 4);
				thirdJSONObject.put("Length", 8);
				thirdJSONObject.put("PieceCount", 0);
				thirdJSONObject.put("OrderQty", 6);
				thirdJSONObject.put("UOM", "");

				JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
				dtOrderItemDimensionRequestArray.add(thirdJSONObject);

				//secondJSONObject.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());
				dtOrderItemRequestArray.add(secondJSONObject);
			}
			
			JSONObject dtOrderItemRequestObj=new JSONObject();
			dtOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			
			JSONObject orderDetailsUpdateJSONObj = new JSONObject();
			orderDetailsUpdateJSONObj.put("dsDetailUpdateSettings", dtDetailUpdateSettingsObj);
			orderDetailsUpdateJSONObj.put("dsOrderItemRequest", dtOrderItemRequestObj);
			
			JSONObject mainJSONObj = new JSONObject();
			mainJSONObj.put("SalesOrderID", orderId);
			mainJSONObj.put("OrderDetailsUpdateJSON", orderDetailsUpdateJSONObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainJSONObj);
			
			Utils.log("SalesOrderDetailsUpdate Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String salesOrderDetailsUpdateUrl = url+"Orders/SalesOrderDetailsUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderDetailsUpdateUrl,contextId,warehouse);
	        	Utils.log("SalesOrderDetailsUpdate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		message=res.get("MessageText").toString();
	        		message="Sales order details updated";
	        	}else{
	    			message=res.get("MessageText").toString();
	        	}
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("AddOrderItem")){
			String message="";
			String orderId = Utils.removeNull(request.getParameter("orderId")).trim();
			Utils.log("orderId >>>> "+orderId);
			/*String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String contactName = Utils.removeNull(request.getParameter("contactName")).trim();
			String phone = Utils.removeNull(request.getParameter("phone")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();*/

			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");
			
			JSONObject firstJSONObj=new JSONObject();
			firstJSONObj.put("TransactionReference", "");
			firstJSONObj.put("TransactionJob", "");
			firstJSONObj.put("OrderedBy", userId);
			firstJSONObj.put("CustomerPurchaseOrder", "");
			firstJSONObj.put("ShipVia", "");
			firstJSONObj.put("MiscField1", "");
			firstJSONObj.put("MiscField2", "");
			firstJSONObj.put("MiscField3", "");
			firstJSONObj.put("MiscField4", "");
			firstJSONObj.put("MiscField5", "");
			firstJSONObj.put("MiscField6", "");
			firstJSONObj.put("MiscField7", "");
			firstJSONObj.put("MiscField8", "");
			firstJSONObj.put("MiscField9", "");
			firstJSONObj.put("MiscField10", "");
			firstJSONObj.put("MiscField11", "");
			firstJSONObj.put("MiscField12", "");
			firstJSONObj.put("MiscDate1", null);
			firstJSONObj.put("MiscDate2", null);
			firstJSONObj.put("SalesAgent1", "");
			firstJSONObj.put("SalesAgent2", "");
			firstJSONObj.put("SalesAgent3", "");
			firstJSONObj.put("SalesAgent4", "");
			firstJSONObj.put("SalesAgent5", "");
			firstJSONObj.put("SalesAgent6", "");
			firstJSONObj.put("SalesAgent1PctOfOrder", 0);
			firstJSONObj.put("SalesAgent2PctOfOrder", 0);
			firstJSONObj.put("SalesAgent3PctOfOrder", 0);
			firstJSONObj.put("SalesAgent4PctOfOrder", 0);
			firstJSONObj.put("SalesAgent5PctOfOrder", 0);
			firstJSONObj.put("SalesAgent6PctOfOrder", 0);
			
			JSONArray dtOrderHeaderUpdateRequestArray = new JSONArray();
			dtOrderHeaderUpdateRequestArray.add(firstJSONObj);

			JSONObject dtOrderHeaderUpdateRequestObj=new JSONObject();
			dtOrderHeaderUpdateRequestObj.put("dtOrderHeaderUpdateRequest", dtOrderHeaderUpdateRequestArray.toString());

			JSONObject dsOrderHeaderUpdateRequestObj=new JSONObject();
			dsOrderHeaderUpdateRequestObj.put("dsOrderHeaderUpdateRequest", dtOrderHeaderUpdateRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject jsonObjectTwo=new JSONObject();
				jsonObjectTwo.put("Sequence", 1);
				jsonObjectTwo.put("ItemCode", itemCodeArray[i]);
				jsonObjectTwo.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				jsonObjectTwo.put("UOM", stockingUomArray[i]);
				jsonObjectTwo.put("Charge", false);
				jsonObjectTwo.put("Price", Double.parseDouble(priceArray[i]));
				jsonObjectTwo.put("PriceUOM", priceUomArray[i]);
				jsonObjectTwo.put("PriceOverride", true);
				jsonObjectTwo.put("UseItemConvertPriceAndUOM", false);
				jsonObjectTwo.put("OrderCost", false);
				jsonObjectTwo.put("CustomerPOLineNumber", "");
				jsonObjectTwo.put("DepartmentName", "");
				jsonObjectTwo.put("DepartmentNumber", "");
				jsonObjectTwo.put("PartNumber", "");
				jsonObjectTwo.put("SKU", "");
				jsonObjectTwo.put("UPCCode", "");
				jsonObjectTwo.put("ItemMessage", "");
				jsonObjectTwo.put("PrintMsgOnForms", false);
				jsonObjectTwo.put("PrintMsgOnFormsOverride", false);
				jsonObjectTwo.put("SendMsgToWMS", false);
				jsonObjectTwo.put("SendMsgToWMSOverride", false);
				jsonObjectTwo.put("APIPriceSourceType", "");
				jsonObjectTwo.put("APIPriceSourceRef", "");
				jsonObjectTwo.put("DetailGroupID", "");
				jsonObjectTwo.put("AddPermanentDetailGroupID", false);
				jsonObjectTwo.put("UseGroupAsDefaultNewItems", false);
				dtOrderItemRequestArray.add(jsonObjectTwo);
			}

			/* JSONObject freightChargeObject=new JSONObject();
			freightChargeObject.put("ItemCode", "Freight Charge");
			freightChargeObject.put("Charge", true);
			freightChargeObject.put("Price", 0);
			dtOrderItemRequestArray.add(freightChargeObject);

			JSONObject freightCostObject=new JSONObject();
			freightCostObject.put("ItemCode", "Freight Cost");
			freightCostObject.put("Charge", true);
			freightCostObject.put("Price", 0);
			dtOrderItemRequestArray.add(freightCostObject); */
			
			JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
			JSONObject fourthJSONObj=new JSONObject();
			fourthJSONObj.put("Sequence", 0);
			fourthJSONObj.put("Thickness", 0);
			fourthJSONObj.put("Width", 0);
			fourthJSONObj.put("Length", 0);
			fourthJSONObj.put("OrderQty", 0);
			fourthJSONObj.put("UOM", "");
			fourthJSONObj.put("Price", 0);
			fourthJSONObj.put("PriceUOM", "");
			fourthJSONObj.put("PriceOverride", false);
			dtOrderItemDimensionRequestArray.add(fourthJSONObj);

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			dsOrderItemRequestObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());

			JSONObject jsonObjectThree=new JSONObject();
			jsonObjectThree.put("OrderItemSequence", 0);
			jsonObjectThree.put("ComponentSequence", 0);
			jsonObjectThree.put("BomType", "");
			jsonObjectThree.put("ItemCode", "");
			jsonObjectThree.put("PartNumber", "");
			jsonObjectThree.put("OrderQty", 0);
			jsonObjectThree.put("Thickness", 0);
			jsonObjectThree.put("Width", 0);
			jsonObjectThree.put("Length", 0);
			jsonObjectThree.put("PieceCount", 0);
			jsonObjectThree.put("TallyUOM", "");
			jsonObjectThree.put("PrintFlag", false);
			jsonObjectThree.put("SundryCost", 0);
			jsonObjectThree.put("SundryCostOverride", false);
			jsonObjectThree.put("ItemMessage", "");
			jsonObjectThree.put("PrintMsgOnForms", false);
			jsonObjectThree.put("PrintMsgOnFormsOverride", false);
			jsonObjectThree.put("UOM", "");
			jsonObjectThree.put("ShipLoose", true);
			
			JSONArray dtOrderItemComponentRequestArray = new JSONArray();
			dtOrderItemComponentRequestArray.add(jsonObjectThree);
			
			JSONObject dtOrderItemComponentRequestObj = new JSONObject();
			dtOrderItemComponentRequestObj.put("dtOrderItemComponentRequest", dtOrderItemComponentRequestArray.toString());

			JSONObject mainJSONObj = new JSONObject();
			mainJSONObj.put("OrderID", orderId);
			mainJSONObj.put("OrderHeaderUpdateJSON", dsOrderHeaderUpdateRequestObj);
			mainJSONObj.put("dsOrderItemRequest", dsOrderItemRequestObj);
			mainJSONObj.put("dsOrderItemComponentRequest", dtOrderItemComponentRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainJSONObj);
			
			Utils.log("SalesOrderUpdate Add Item Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String salesOrderUpdateUrl = url+"Orders/SalesOrderUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderUpdateUrl,contextId,warehouse);
	        	Utils.log("SalesOrderUpdate Add Item Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
	    			message=res.get("MessageText").toString();
	        	else
	    			message=res.get("MessageText").toString();
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("DeleteCreateOrder")){
			String message="";
			String orderId=Utils.removeNull(request.getParameter("orderId")).trim();
			Utils.log("SalesOrderCancel orderId >>>> "+orderId);

			JSONObject jsonObj=new JSONObject();
			jsonObj.put("ReasonCode", "");
			jsonObj.put("Comment", "");
			jsonObj.put("CancelLinkedTran", true);
			jsonObj.put("AllowLinkedPrintedTran", true);
			jsonObj.put("SendS855", false);
			jsonObj.put("SendS870", false);
			
			JSONArray dtOrderCancelArray = new JSONArray();
			dtOrderCancelArray.add(jsonObj);
			
			JSONObject dtOrderCancelJsonObject=new JSONObject();
			dtOrderCancelJsonObject.put("dtOrderCancel", dtOrderCancelArray.toString());
			
			JSONObject dsOrderCancelJsonObject=new JSONObject();
			dsOrderCancelJsonObject.put("dsOrderCancel", dtOrderCancelJsonObject);
			
			JSONObject mainObj=new JSONObject();
			mainObj.put("SalesOrderID", Integer.parseInt(orderId));
			mainObj.put("OrderCancelJSON", dsOrderCancelJsonObject);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainObj);
			
			Utils.log("SalesOrderCancel Request Object >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String salesOrderCancelUrl = url+"Orders/SalesOrderCancel";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderCancelUrl,contextId,warehouse);
	        	Utils.log("SalesOrderCancel Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
					request.setAttribute("message", res.get("MessageText").toString());
				else
					request.setAttribute("message", res.get("MessageText").toString());
			}
			response.sendRedirect("../customerPortal/A_CP_Shop.jsp?pageName=Shop");
			return;
		}
		else if(param.equalsIgnoreCase("DeleteCreateOrderItem")){
			String message="";
			String orderId=Utils.removeNull(request.getParameter("quoteId")).trim();
			String lineNo=Utils.removeNull(request.getParameter("lineNo")).trim();
			
			JSONObject jsonFirstObj=new JSONObject();
			jsonFirstObj.put("UpdateLinkedTran", true);
			jsonFirstObj.put("UpdateLinkedPrintedTran", true);
			
			JSONArray dtDetailDeleteSettingsArray = new JSONArray();
			dtDetailDeleteSettingsArray.add(jsonFirstObj);

			JSONObject dtDetailDeleteSettingsJsonObject=new JSONObject();
			dtDetailDeleteSettingsJsonObject.put("dtDetailDeleteSettings", dtDetailDeleteSettingsArray.toString());
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("Sequence", lineNo);

			JSONArray dtOrderItemRequestArray = new JSONArray();
			dtOrderItemRequestArray.add(jsonObject);

			JSONObject dtOrderItemRequestObj=new JSONObject();
			dtOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());

			JSONObject orderDetailsDeleteJSONObj=new JSONObject();
			orderDetailsDeleteJSONObj.put("dsDetailDeleteSettings", dtDetailDeleteSettingsJsonObject);
			orderDetailsDeleteJSONObj.put("dsOrderItemRequest", dtOrderItemRequestObj);
			
			JSONObject mainObj=new JSONObject();
			mainObj.put("SalesOrderID", Integer.parseInt(orderId));
			mainObj.put("OrderDetailsDeleteJSON", orderDetailsDeleteJSONObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainObj);

			Utils.log("SalesOrderDetailsDelete Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String salesOrderDetailsDeleteUrl = url+"Orders/SalesOrderDetailsDelete";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,salesOrderDetailsDeleteUrl,contextId,warehouse);
	        	Utils.log("SalesOrderDetailsDelete Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		//message=res.get("MessageText").toString();
	        		message="Item Deleted";
	        	}
	        	else
	    			message=res.get("MessageText").toString();
			}
			
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("SaveQuoteEntry")){
			String message="";
			String shipToSeq = Utils.removeNull(request.getParameter("shipToSeq")).trim();
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String addressOne = Utils.removeNull(request.getParameter("addressOne")).trim();
			String addressTwo = Utils.removeNull(request.getParameter("addressTwo")).trim();
			String city = Utils.removeNull(request.getParameter("city")).trim();
			String state = Utils.removeNull(request.getParameter("state")).trim();
			String zip = Utils.removeNull(request.getParameter("zip")).trim();
			String contactName = Utils.removeNull(request.getParameter("memoOne")).trim();
			String phone = Utils.removeNull(request.getParameter("memoTwo")).trim();
			String shipVia = Utils.removeNull(request.getParameter("shipVia")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();
			String referenceId = Utils.removeNull(request.getParameter("referenceId")).trim();
			String jobNo = Utils.removeNull(request.getParameter("addressThree")).trim();
			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Date currentDate = new Date();
			if(expectedDeliveryDate.equals("")){
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate);
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			String notes = Utils.removeNull(request.getParameter("notes")).trim();
			String messageStr = Utils.removeNull(request.getParameter("message")).trim();

			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");

			String todayDate=sdf.format(currentDate);
			LocalDate today = LocalDate.now();
			LocalDate oneMonthLater = today.plusMonths(1);
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			String formattedDate = oneMonthLater.format(formatter);
			
			JSONObject completeJSONObj=new JSONObject();
			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("CustomerID", customerId);
			jsonObject.put("ShipToSequence", Integer.parseInt(shipToSeq));
			jsonObject.put("SaleType", "WH");//from ship_to table
			jsonObject.put("RequestedDeliveryDate", expectedDeliveryDate.trim());
			jsonObject.put("TransactionReference", referenceId.trim());
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", userId.trim());
			jsonObject.put("CustomerPO", customerPo.trim());
			jsonObject.put("AcknowledgementEmailAddress", "");
			jsonObject.put("AcknowledgementEmailAddress2", "");
			jsonObject.put("AcknowledgementFaxNumber", "");
			jsonObject.put("ShipToName", shipToName.trim());
			jsonObject.put("ShipToAddress1", addressOne.trim());
			jsonObject.put("ShipToAddress2", addressTwo.trim());
			jsonObject.put("ShipToAddress3", jobNo.trim());
			jsonObject.put("ShipToCity", city.trim());
			jsonObject.put("ShipToState", state.trim());
			jsonObject.put("ShipToZip", zip.trim());
			jsonObject.put("ShipToCountry", "");
			jsonObject.put("ShipToPhone", "");
			jsonObject.put("OrderMessage", messageStr.trim());
			jsonObject.put("ShipVia", shipVia.trim());
			jsonObject.put("ActivationDate", todayDate.trim());//today date
			jsonObject.put("CloseDate", formattedDate.trim());//date 1 month after today date
			jsonObject.put("ExternalSource", "");
			jsonObject.put("ExternalProjectID", "");
			jsonObject.put("SourceLogin", "");

			JSONArray dtQuoteHeaderRequestArray = new JSONArray();
			dtQuoteHeaderRequestArray.add(jsonObject);

			JSONObject dtQuoteHeaderRequestObj=new JSONObject();
			dtQuoteHeaderRequestObj.put("dtQuoteHeaderRequest", dtQuoteHeaderRequestArray.toString());
			
			JSONArray dtQuoteHeaderNotesRequestArray = new JSONArray();

			JSONObject jsonObjectNotes1=new JSONObject();
			jsonObjectNotes1.put("OrderNote", "Hold order");
			jsonObjectNotes1.put("HotNote", true);
			dtQuoteHeaderNotesRequestArray.add(jsonObjectNotes1);
			
			JSONObject jsonObjectNotes2=new JSONObject();
			jsonObjectNotes2.put("OrderNote", "Must ship on time");
			jsonObjectNotes2.put("HotNote", false);
			dtQuoteHeaderNotesRequestArray.add(jsonObjectNotes2);
			
			dtQuoteHeaderRequestObj.put("dtQuoteHeaderNotesRequest", dtQuoteHeaderNotesRequestArray.toString());

			JSONObject dsQuoteHeaderRequestObj=new JSONObject(); 
			dsQuoteHeaderRequestObj.put("dsQuoteHeaderRequest",dtQuoteHeaderRequestObj);
			
			completeJSONObj.put("QuoteHeaderJSON",dsQuoteHeaderRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject firstJSONObj=new JSONObject();
				firstJSONObj.put("Sequence", 1);
				firstJSONObj.put("ItemCode", itemCodeArray[i]);
				firstJSONObj.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				firstJSONObj.put("UOM", stockingUomArray[i]);
				firstJSONObj.put("Charge", false);
				firstJSONObj.put("Price", Double.parseDouble(priceArray[i]));
				firstJSONObj.put("PriceUOM", priceUomArray[i]);
				firstJSONObj.put("PriceOverride", true);
				firstJSONObj.put("UseItemConvertPriceAndUOM", false);
				firstJSONObj.put("OrderCost", false);
				firstJSONObj.put("CustomerPOLineNumber", "");
				firstJSONObj.put("DepartmentName", "");
				firstJSONObj.put("DepartmentNumber", "");
				firstJSONObj.put("PartNumber", "");
				firstJSONObj.put("SKU", "");
				firstJSONObj.put("UPCCode", "");
				firstJSONObj.put("ItemMessage", "");
				firstJSONObj.put("PrintMsgOnForms", false);
				firstJSONObj.put("PrintMsgOnFormsOverride", false);
				firstJSONObj.put("SendMsgToWMS", false);
				firstJSONObj.put("SendMsgToWMSOverride", false);
				firstJSONObj.put("APIPriceSourceType", "");
				firstJSONObj.put("APIPriceSourceRef", "");
				firstJSONObj.put("ShippingBranch", "");
				firstJSONObj.put("DetailGroupID", "");
				firstJSONObj.put("AddPermanentDetailGroupID", false);
				firstJSONObj.put("UseGroupAsDefaultNewItems", false);
				firstJSONObj.put("TemplateItemCode", "");
				firstJSONObj.put("NonStockSize", "");
				firstJSONObj.put("NonStockDescription", "");
				firstJSONObj.put("NonStockExtDescription", "");
				firstJSONObj.put("NonStockCopyCustomFields", false);
				firstJSONObj.put("NonStockSupplierID", "");
				firstJSONObj.put("NonStockSupplierShipFromSequence", 1);
				firstJSONObj.put("NonStockSupplierPartNumber", "");
				firstJSONObj.put("NonStockProductGroupMajor", "");
				firstJSONObj.put("NonStockProductGroupMinor", "");
				firstJSONObj.put("NonStockPriceCodeMajor", "");
				firstJSONObj.put("NonStockPriceCodeMinor", "");
				firstJSONObj.put("NonStockCost", 0);
				firstJSONObj.put("NonStockCostUOM", "");
				
				/* JSONObject secondJSONObj=new JSONObject();
				secondJSONObj.put("ItemCode", "");
				secondJSONObj.put("Charge", false);
				secondJSONObj.put("Price", 0);

				JSONObject thirdJSONObj=new JSONObject();
				thirdJSONObj.put("ItemCode", "");
				thirdJSONObj.put("OrderCost", false);
				thirdJSONObj.put("Price", 0); 
				
				dtOrderItemRequestArray.add(secondJSONObj);
				dtOrderItemRequestArray.add(thirdJSONObj);*/

				dtOrderItemRequestArray.add(firstJSONObj);
			}
			
			JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
			JSONObject fourthJSONObj=new JSONObject();
			fourthJSONObj.put("Sequence", 0);
			fourthJSONObj.put("Thickness", 0);
			fourthJSONObj.put("Width", 0);
			fourthJSONObj.put("Length", 0);
			fourthJSONObj.put("OrderQty", 0);
			fourthJSONObj.put("UOM", "");
			fourthJSONObj.put("Price", 0);
			fourthJSONObj.put("PriceUOM", "");
			fourthJSONObj.put("PriceOverride", false);
			dtOrderItemDimensionRequestArray.add(fourthJSONObj);

			JSONObject finalObj=new JSONObject();
			finalObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			finalObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest",finalObj);
			
			completeJSONObj.put("OrderItemJSON",dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request",completeJSONObj);

			Utils.log("QuoteEntry Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String createTemplateUrl = url+"Orders/QuoteCreate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,createTemplateUrl,contextId,warehouse);
	        	Utils.log("QuoteEntry Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		int newOrderId = Integer.parseInt(res.get("NewOrderID").toString());
	        		Utils.log("NewOrderID >>>> "+newOrderId);
	    			message="<div class='bg-success-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/success-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='mb-0'>The new quote is created and quote# is "+newOrderId+" </p>"
	              			+"</div>";
	        	}
	        	else{
	    			message="<div class='bg-danger-subtle p-3 text-center'>"
	    	          		+"<img src='NewPortalAssets/assets/images/icons/fail-icon.png' width='70px' alt='' class='mb-3'>"
	    	         		+"<p class='text-danger mb-0'>Unable to process your request. Please try after some time.</p>"
	              			+"</div>";
	        	}
			}

			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("AddQuoteEntryItem")){
			String message="";
			String quoteId = Utils.removeNull(request.getParameter("quoteId")).trim();
			String shipToName = Utils.removeNull(request.getParameter("shipToName")).trim();
			String customerPo = Utils.removeNull(request.getParameter("customerPo")).trim();

			String expectedDeliveryDate = Utils.removeNull(request.getParameter("expectedDeliveryDate")).trim();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Date currentDate = new Date();
			if(expectedDeliveryDate.equals("")){
				expectedDeliveryDate=sdf.format(currentDate);
			}
			else{
				SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
				Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate);
				expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
			}

			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");

			
			JSONObject jsonObject=new JSONObject();
			jsonObject.put("TransactionReference", "");
			jsonObject.put("TransactionJob", "");
			jsonObject.put("OrderedBy", "");
			jsonObject.put("CustomerPO", customerPo);
			jsonObject.put("ShipVia", "");
			jsonObject.put("RequestedDeliveryDate", expectedDeliveryDate);
			jsonObject.put("ActivationDate", "");
			jsonObject.put("CloseDate", "");
			jsonObject.put("ExternalSource", "");
			jsonObject.put("ExternalProjectID", "");
			
			JSONArray dtQuoteHeaderUpdateRequestArray = new JSONArray();
			dtQuoteHeaderUpdateRequestArray.add(jsonObject);

			JSONObject dtQuoteHeaderUpdateRequestObj=new JSONObject();
			dtQuoteHeaderUpdateRequestObj.put("dtQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestArray.toString());

			JSONObject dsQuoteHeaderUpdateRequestObj=new JSONObject();
			dsQuoteHeaderUpdateRequestObj.put("dsQuoteHeaderUpdateRequest", dtQuoteHeaderUpdateRequestObj);
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject firstJSONObj=new JSONObject();
				firstJSONObj.put("Sequence", 1);
				firstJSONObj.put("ItemCode", itemCodeArray[i]);
				firstJSONObj.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				firstJSONObj.put("UOM", stockingUomArray[i]);
				firstJSONObj.put("Charge", false);
				firstJSONObj.put("Price", Double.parseDouble(priceArray[i]));
				firstJSONObj.put("PriceUOM", priceUomArray[i]);
				firstJSONObj.put("PriceOverride", true);
				firstJSONObj.put("UseItemConvertPriceAndUOM", false);
				firstJSONObj.put("OrderCost", false);
				firstJSONObj.put("CustomerPOLineNumber", "");
				firstJSONObj.put("DepartmentName", "");
				firstJSONObj.put("DepartmentNumber", "");
				firstJSONObj.put("PartNumber", "");
				firstJSONObj.put("SKU", "");
				firstJSONObj.put("UPCCode", "");
				firstJSONObj.put("ItemMessage", "");
				firstJSONObj.put("PrintMsgOnForms", false);
				firstJSONObj.put("PrintMsgOnFormsOverride", false);
				firstJSONObj.put("SendMsgToWMS", false);
				firstJSONObj.put("SendMsgToWMSOverride", false);
				firstJSONObj.put("APIPriceSourceType", "");
				firstJSONObj.put("APIPriceSourceRef", "");
				firstJSONObj.put("DetailGroupID", "");
				firstJSONObj.put("AddPermanentDetailGroupID", false);
				firstJSONObj.put("UseGroupAsDefaultNewItems", false);
				
				dtOrderItemRequestArray.add(firstJSONObj);
			}

			JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
			JSONObject fourthJSONObj=new JSONObject();
			fourthJSONObj.put("Sequence", 0);
			fourthJSONObj.put("Thickness", 0);
			fourthJSONObj.put("Width", 0);
			fourthJSONObj.put("Length", 0);
			fourthJSONObj.put("OrderQty", 0);
			fourthJSONObj.put("UOM", "");
			fourthJSONObj.put("Price", 0);
			fourthJSONObj.put("PriceUOM", "");
			fourthJSONObj.put("PriceOverride", false);
			dtOrderItemDimensionRequestArray.add(fourthJSONObj);

			JSONObject finalObj=new JSONObject();
			finalObj.put("dtOrderItemRequest", dtOrderItemRequestArray.toString());
			finalObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray.toString());

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest",finalObj);
			
			JSONObject mainObj=new JSONObject();
			mainObj.put("OrderID", quoteId);
			mainObj.put("QuoteHeaderUpdateJSON", dsQuoteHeaderUpdateRequestObj);
			mainObj.put("OrderItemUpdateJSON", dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainObj);
			
			Utils.log("QuoteUpdate Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String quoteUpdateUrl = url+"Orders/QuoteUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteUpdateUrl,contextId,warehouse);
	        	Utils.log("QuoteUpdate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0)
	    			message=res.get("MessageText").toString();
	        	else
	    			message=res.get("MessageText").toString();
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}
		else if(param.equalsIgnoreCase("QuoteEntryDetailsUpdate")){
			String message="";
			String orderId = Utils.removeNull(request.getParameter("orderId")).trim();
			String[] itemSeqArray = (request.getParameter("itemSeq")).split(",");
			String[] itemCodeArray = (request.getParameter("itemCode")).split(",");
			String[] priceArray = (request.getParameter("price")).split(",");
			String[] priceUomArray = (request.getParameter("priceUom")).split(",");
			String[] orderedQtyArray = (request.getParameter("orderedQty")).split(",");
			String[] stockingUomArray = (request.getParameter("stockingUom")).split(",");
			
			JSONArray dtOrderItemRequestArray = new JSONArray();
			for(int i=0; i<itemCodeArray.length; i++){
				JSONObject jsonObj=new JSONObject();
				jsonObj.put("Sequence", Integer.parseInt(itemSeqArray[i]));
				jsonObj.put("OrderQty", Double.parseDouble(orderedQtyArray[i]));
				jsonObj.put("UOM", stockingUomArray[i]);
				jsonObj.put("UseItemConvertPriceAndUOM", false);
				jsonObj.put("Price", Double.parseDouble(priceArray[i]));
				jsonObj.put("PriceUOM", priceUomArray[i]);
				jsonObj.put("ApplyPriceToAllDimensions", true);
				jsonObj.put("PriceSubjectToFurtherDiscounts", false);
				jsonObj.put("PriceOverride", true);
				jsonObj.put("DetailGroupID", " ");
				jsonObj.put("AddPermanentDetailGroupID", true);
				jsonObj.put("UseGroupAsDefaultNewItems", false);
				
				JSONArray dtOrderItemDimensionRequestArray = new JSONArray();
				jsonObj.put("dtOrderItemDimensionRequest", dtOrderItemDimensionRequestArray);
				dtOrderItemRequestArray.add(jsonObj);
			}
			
			JSONObject dtOrderItemRequestObj=new JSONObject();
			dtOrderItemRequestObj.put("dtOrderItemRequest", dtOrderItemRequestArray);

			JSONObject dsOrderItemRequestObj=new JSONObject();
			dsOrderItemRequestObj.put("dsOrderItemRequest", dtOrderItemRequestObj);

			JSONObject mainJSONObj = new JSONObject();
			mainJSONObj.put("OrderID", Long.parseLong(orderId));
			mainJSONObj.put("QuoteDetailsUpdateJSON", dsOrderItemRequestObj);
			
			JSONObject requestObj=new JSONObject();
			requestObj.put("request", mainJSONObj);
			
			Utils.log("QuoteDetailsUpdate Request >>>> " + requestObj);
			ApiCall apiCallObj = new ApiCall();
			JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
			if(loginRespObj != null){
				JSONObject loginResp = (JSONObject)loginRespObj.get("response");
				String contextId = loginResp.get("SessionContextId").toString();
				//String systemId = loginResp.get("InitialBranch").toString();
				
				String quoteDetailsUpdateUrl = url+"Orders/QuoteDetailsUpdate";
	        	JSONObject responseObj = apiCallObj.agilityPublicAPICall(requestObj,quoteDetailsUpdateUrl,contextId,warehouse);
	        	Utils.log("QuoteDetailsUpdate Response >>>> "+responseObj);
	        	JSONObject res = (JSONObject)responseObj.get("response");
	        	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
	        		message=res.get("MessageText").toString();
	        		message="Quote details updated";
	        	}else{
	    			message=res.get("MessageText").toString();
	        	}
			}
						
			response.setContentType("text/html");
	        response.getWriter().print(message.toString());
	    	out.flush();
		}


	}
	catch (Exception e) {
		e.getMessage();
	}

%>

<%!

	public HashMap<String, String> getCustomerDetail(String quoteId) {	
		String sqlQuery="";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select qh.quote_id,qh.SYSTEM_ID, sa.cust_name,qh.SHIPTO_SEQ_NUM,cs.CUST_PO_REQUIRED,cu.EMAIL_ADDRESS,cs.SHIPTO_NAME, sa.ADDRESS_1, sa.ADDRESS_2,sa.ADDRESS_3,sa.CITY, sa.STATE, sa.ZIP, "
							+" sa.COUNTRY,sa.PHONE,qh.TAX_CODE,qh.SALE_TYPE,cs.SHIP_VIA,qh.SHIP_COMPLETE,sa.MISC_1,sa.MISC_2, "
							+" sa.MISC_3,sa.MISC_4,sa.MISC_5,sa.MISC_6,sa.MISC_7,sa.MISC_8,sa.MISC_9,sa.MISC_10,sa.MISC_11, "
							+" sa.MISC_12,sa.MISC_DATE1,sa.MISC_DATE2,qh.ORIG_SOURCE_ID,cs.SALES_AGENT_1,cs.SALES_AGENT_2, "
							+" cs.SALES_AGENT_3,cs.SALES_AGENT_1_PCT_DFLT,cs.SALES_AGENT_2_PCT_DFLT,cs.SALES_AGENT_3_PCT_DFLT, "
							+" cs.FREIGHT_TERMS,qh.PAY_TERMS_CODE "
							+" from quote_header qh, cust_shipto cs, cust cu, SHIP_TO_ADDRESS sa "
							+" WHERE qh.CUST_SHIPTO_GUID=cs.CUST_SHIPTO_GUID " 
							+" and qh.CUST_GUID=cu.CUST_GUID "
							+" and qh.QUOTE_ID=sa.tran_id and sa.type='QU' "
							+" and qh.quote_id='"+quoteId+"' ";
							/* +" and qh.type='Master/Template' " 
							+" and (closed_date is null or closed_date>=sysdate) " 
							+" and indefinite=1 " 
							+" order by qh.QUOTE_DATE "; */
			Utils.log("Details Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector quoteIdVector = new Vector();
			Vector systemIdVector = new Vector();
			Vector custNameVector = new Vector();
			Vector shipToSeqNumVector = new Vector();
			Vector custPORequiredVector = new Vector();
			Vector emailAddressVector = new Vector();
			Vector shipToNameVector = new Vector();
			Vector addressOneVector = new Vector();
			Vector addressTwoVector = new Vector();
			Vector addressThreeVector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
			Vector countryVector = new Vector();
			Vector phoneVector = new Vector();
			Vector taxCodeVector = new Vector();
			Vector saleTypeVector = new Vector();
			Vector shipViaVector = new Vector();
			Vector shipCompleteVector = new Vector();
			Vector miscOneVector = new Vector();
			Vector miscTwoVector = new Vector();
			Vector miscThreeVector = new Vector();
			Vector miscFourVector = new Vector();
			Vector miscFiveVector = new Vector();
			Vector miscSixVector = new Vector();
			Vector miscSevenVector = new Vector();
			Vector miscEightVector = new Vector();
			Vector miscNineVector = new Vector();
			Vector miscTenVector = new Vector();
			Vector miscElevenVector = new Vector();
			Vector miscTwelveVector = new Vector();
			Vector miscDateOneVector = new Vector();
			Vector miscDateTwoVector = new Vector();
			Vector origSourceIdVector = new Vector();
			Vector salesAgentOneVector = new Vector();
			Vector salesAgentTwoVector = new Vector();
			Vector salesAgentThreeVector = new Vector();
			Vector salesAgentOnePCTDeltVector = new Vector();
			Vector salesAgentTwoPCTDeltVector = new Vector();
			Vector salesAgentThreePCTDeltVector = new Vector();
			Vector freightTermsVector = new Vector();
			Vector payTermsCodeVector = new Vector();
			if (ht != null && ht.size() > 0) {
				quoteIdVector = (Vector) ht.get("QUOTE_ID");
				systemIdVector = (Vector) ht.get("SYSTEM_ID");
				custNameVector = (Vector) ht.get("CUST_NAME");
				shipToSeqNumVector = (Vector) ht.get("SHIPTO_SEQ_NUM");
				custPORequiredVector = (Vector) ht.get("CUST_PO_REQUIRED");
				emailAddressVector = (Vector) ht.get("EMAIL_ADDRESS");
				shipToNameVector = (Vector) ht.get("SHIPTO_NAME");
				addressOneVector = (Vector) ht.get("ADDRESS_1");
				addressTwoVector = (Vector) ht.get("ADDRESS_2");
				addressThreeVector = (Vector) ht.get("ADDRESS_3");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
				countryVector = (Vector) ht.get("COUNTRY");
				phoneVector = (Vector) ht.get("PHONE");
				taxCodeVector = (Vector) ht.get("TAX_CODE");
				saleTypeVector = (Vector) ht.get("SALE_TYPE");
				shipViaVector = (Vector) ht.get("SHIP_VIA");
				shipCompleteVector = (Vector) ht.get("SHIP_COMPLETE");
				miscOneVector = (Vector) ht.get("MISC_1");
				miscTwoVector = (Vector) ht.get("MISC_2");
				miscThreeVector = (Vector) ht.get("MISC_3");
				miscFourVector = (Vector) ht.get("MISC_4");
				miscFiveVector = (Vector) ht.get("MISC_5");
				miscSixVector = (Vector) ht.get("MISC_6");
				miscSevenVector = (Vector) ht.get("MISC_7");
				miscEightVector = (Vector) ht.get("MISC_8");
				miscNineVector = (Vector) ht.get("MISC_9");
				miscTenVector = (Vector) ht.get("MISC_10");
				miscElevenVector = (Vector) ht.get("MISC_11");
				miscTwelveVector = (Vector) ht.get("MISC_12");
				miscDateOneVector = (Vector) ht.get("MISC_DATE1");
				miscDateTwoVector = (Vector) ht.get("MISC_DATE2");
				origSourceIdVector = (Vector) ht.get("ORIG_SOURCE_ID");
				salesAgentOneVector = (Vector) ht.get("SALES_AGENT_1");
				salesAgentTwoVector = (Vector) ht.get("SALES_AGENT_2");
				salesAgentThreeVector = (Vector) ht.get("SALES_AGENT_3");
				salesAgentOnePCTDeltVector = (Vector) ht.get("SALES_AGENT_1_PCT_DFLT");
				salesAgentTwoPCTDeltVector = (Vector) ht.get("SALES_AGENT_2_PCT_DFLT");
				salesAgentThreePCTDeltVector = (Vector) ht.get("SALES_AGENT_3_PCT_DFLT");
				freightTermsVector = (Vector) ht.get("FREIGHT_TERMS");
				payTermsCodeVector = (Vector) ht.get("PAY_TERMS_CODE");
			}
	        if (quoteIdVector.size() > 0) {
	        	for (int i = 0; i < quoteIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("quoteId", quoteIdVector.get(i).toString());
	        		temp.put("systemId", systemIdVector.get(i).toString());
	        		temp.put("custName", custNameVector.get(i).toString());
					temp.put("shipToSeqNum", shipToSeqNumVector.get(i).toString());
					temp.put("custPORequired", custPORequiredVector.get(i).toString());
					temp.put("emailAddress", emailAddressVector.get(i).toString());
					temp.put("shipToName", shipToNameVector.get(i).toString());
					temp.put("addressOne", addressOneVector.get(i).toString());
					temp.put("addressTwo", addressTwoVector.get(i).toString());
					temp.put("addressThree", addressThreeVector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
					temp.put("country", countryVector.get(i).toString());
					temp.put("phone", phoneVector.get(i).toString());
					temp.put("taxCode", taxCodeVector.get(i).toString());
					temp.put("saleType", saleTypeVector.get(i).toString());
					temp.put("shipVia", shipViaVector.get(i).toString());
					temp.put("shipComplete", shipCompleteVector.get(i).toString());
					temp.put("miscOne", miscOneVector.get(i).toString());
					temp.put("miscTwo", miscTwoVector.get(i).toString());
					temp.put("miscThree", miscThreeVector.get(i).toString());
					temp.put("miscFour", miscFourVector.get(i).toString());
					temp.put("miscFive", miscFiveVector.get(i).toString());
					temp.put("miscSix", miscSixVector.get(i).toString());
					temp.put("miscSeven", miscSevenVector.get(i).toString());
					temp.put("miscEight", miscEightVector.get(i).toString());
					temp.put("miscNine", miscNineVector.get(i).toString());
					temp.put("miscTen", miscTenVector.get(i).toString());
					temp.put("miscEleven", miscElevenVector.get(i).toString());
					temp.put("miscTwelve", miscTwelveVector.get(i).toString());
					temp.put("miscDateOne", miscDateOneVector.get(i).toString());
					temp.put("miscDateTwo", miscDateTwoVector.get(i).toString());
					temp.put("origSourceId", origSourceIdVector.get(i).toString());
					temp.put("salesAgentOne", salesAgentOneVector.get(i).toString());
					temp.put("salesAgentTwo", salesAgentTwoVector.get(i).toString());
					temp.put("salesAgentThree", salesAgentThreeVector.get(i).toString());
					temp.put("salesAgentOnePCTDelt", salesAgentOnePCTDeltVector.get(i).toString());
					temp.put("salesAgentTwoPCTDelt", salesAgentTwoPCTDeltVector.get(i).toString());
					temp.put("salesAgentThreePCTDelt", salesAgentThreePCTDeltVector.get(i).toString());
					temp.put("freightTerms", freightTermsVector.get(i).toString());
					temp.put("payTermsCode", payTermsCodeVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}

	public ArrayList<HashMap<String, String>> getDetail(String quoteId) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select it.ITEM, qd.QUOTE_DESC,it.EXT_DESCRIPTION,it.SIZE_, qd.PRICE, qd.PRICE_UOM_CODE, 0 as QUANTITY, it.STOCKING_UOM "
							+" from quote_detail qd, item it " 
							+" where qd.ITEM_PTR=it.ITEM_PTR "
							+" and quote_id="+Integer.parseInt(quoteId.trim())+" " 
							+" order by qd.DISPLAY_SEQ ";
			Utils.log("Query >>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector itemVector = new Vector();
			Vector quoteDescVector = new Vector();
			Vector extDescVector = new Vector();
			Vector sizeVector = new Vector();
			Vector priceVector = new Vector();
			Vector priceUomCodeVector = new Vector();
			Vector quantityVector = new Vector();
			Vector stockingUomVector = new Vector();
			if (ht != null && ht.size() > 0) {
				itemVector = (Vector) ht.get("ITEM");
				quoteDescVector = (Vector) ht.get("QUOTE_DESC");
				extDescVector = (Vector) ht.get("EXT_DESCRIPTION");
				sizeVector = (Vector) ht.get("SIZE_");
				priceVector = (Vector) ht.get("PRICE");
				priceUomCodeVector = (Vector) ht.get("PRICE_UOM_CODE");
				quantityVector = (Vector) ht.get("QUANTITY");
				stockingUomVector = (Vector) ht.get("STOCKING_UOM");
			}
	        if (itemVector.size() > 0) {
	        	for (int i = 0; i < itemVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("item", itemVector.get(i).toString());
	        		temp.put("quoteDesc", quoteDescVector.get(i).toString());
	        		temp.put("extDesc", extDescVector.get(i).toString());
	        		temp.put("size", sizeVector.get(i).toString());
	        		temp.put("price", priceVector.get(i).toString());
					temp.put("priceUomCode", priceUomCodeVector.get(i).toString());
					temp.put("quantity", quantityVector.get(i).toString());
					temp.put("stockingUom", stockingUomVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	
	
	public JSONObject sendMail(String from,String to,String sendCC,String sendBCC, 
			String subject,String tag,String htmlBody,String textBody,
			String replyTo,String messageStream) {

		String url="";
		try{
			FileReader reader=new FileReader("eTechLogix.properties");  
			Properties prop=new Properties();  
			prop.load(reader);    
			url=prop.getProperty("EmailUrl");
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		headerMaps.put("X-Postmark-Server-Token", "6b22e017-8903-4030-bf0e-d45d63c3f4d3");
		
		JSONObject reqBody=new JSONObject();
		reqBody.put("From", from);
		reqBody.put("To", to);
		reqBody.put("Cc", sendCC);
		reqBody.put("Bcc", sendBCC);
		reqBody.put("Subject", subject);
		reqBody.put("Tag", tag);
		reqBody.put("HtmlBody", htmlBody);
		reqBody.put("TextBody", textBody);
		reqBody.put("ReplyTo", replyTo);
		reqBody.put("MessageStream", messageStream);
		
		String contentType=MediaType.APPLICATION_JSON;
		//Utils.log("Request: "+reqBody);
		//return apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
	
		ApiCall apiCallObj = new ApiCall();
		JSONObject jsonObj = apiCallObj.apiCall(url, reqBody.toString(), "POST", contentType, headerMaps);
		return jsonObj;
	}

	public int getImageSlNo(String companyId, String orderId, String shipmentId ) {
		String result="";
		String sqlQuery="";
		int imageSlNo=1;
		try {
			DistUtils du=new DistUtils();								
			sqlQuery = " select max(slno) from MOB_CONFIRM_IMG where companyid='"+companyId.trim()+"' and orderid="+Long.parseLong(orderId.trim())+" and shipmentid="+Integer.parseInt(shipmentId.trim())+" ";
			Utils.log("SlNo Query >>>> " + sqlQuery);
			if(!Utils.removeNull(du.getFieldInfo(sqlQuery)).trim().equals("")){
				imageSlNo=Integer.parseInt(Utils.removeNull(du.getFieldInfo(sqlQuery)));
			}
			Utils.log("Image SlNo >>>> "+imageSlNo);
		} 
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("SS Exception >>>> " , e);
		}
		return imageSlNo;
	}


	public String insertImage(String companyId, String orderId, String shipmentId, String userId, 
			String imageType, String imageName, int imageSlNo, long imageSize ) 
	{
		String sqlQuery="";
		String status="fail";
		Connection con=null;
		Statement stmt=null;
		try{
			DistUtils du=new DistUtils();
			con=du.getConnection();
			sqlQuery="insert into MOB_CONFIRM_IMG (COMPANYID,ORDERID,SHIPMENTID,USERID,IMGTYPE,DELIMG,SLNO,IMAGESIZE,CREATED) "
						+"values ('"+companyId+"',"+Long.parseLong(orderId)+","+Integer.parseInt(shipmentId)+",'"+userId+"', "
						+" '"+imageType+"','"+imageName+"',"+imageSlNo+","+imageSize+",CURRENT_TIMESTAMP) ";
			Utils.log("InsertImage Query >>>> " + sqlQuery);
			stmt = con.createStatement();
			int result=stmt.executeUpdate(sqlQuery);
			if(result>0)
				status="success";

			Utils.close(stmt);
			Utils.close(con);
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.close(stmt);
			Utils.close(con);
			Utils.log("Exception >>>> " , e);
		}finally {
			Utils.close(stmt);
			Utils.close(con);
		}
		return status;
	}
	
	
	public HashMap<String, String> getCustDetail(String customerId) {	
		String sqlQuery="";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = " select ADDRESS_1,CITY,STATE,ZIP from CUST where CUST_CODE='"+customerId+"' ";
			Utils.log("CustomerDetail Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector addressOneVector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
			if (ht != null && ht.size() > 0) {
				addressOneVector = (Vector) ht.get("ADDRESS_1");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
			}
	        if (addressOneVector.size() > 0) {
	        	for (int i = 0; i < addressOneVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("addressOne", addressOneVector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}

	
	public HashMap<String, String> getTemplateHeader(String customerId,String quoteId) {	
		String sqlQuery="",filterString = "";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select qh.quote_id,cs.CUST_PO_REQUIRED, sa.cust_name, sa.ADDRESS_1, sa.ADDRESS_2,sa.ADDRESS_3,sa.CITY, sa.STATE, sa.ZIP "
						+" from quote_header qh, cust_shipto cs, cust cu, SHIP_TO_ADDRESS sa "
						+" WHERE qh.CUST_SHIPTO_GUID=cs.CUST_SHIPTO_GUID " 
						+" and qh.CUST_GUID=cu.CUST_GUID "
						+" and qh.QUOTE_ID=sa.tran_id and sa.type='QU' "
						+" and cu.CUST_CODE='"+customerId+"' "
						+" and qh.CREATED_BY='API' "
						+" and qh.quote_id='"+quoteId+"' ";
			Utils.log("Query >>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector quoteIdVector = new Vector();
			Vector custPORequiredVector = new Vector();
			Vector custNameVector = new Vector();
			Vector addressOneVector = new Vector();
			Vector addressTwoVector = new Vector();
			Vector addressThreeVector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
			if (ht != null && ht.size() > 0) {
				quoteIdVector = (Vector) ht.get("QUOTE_ID");
				custPORequiredVector = (Vector) ht.get("CUST_PO_REQUIRED");
				custNameVector = (Vector) ht.get("CUST_NAME");
				addressOneVector = (Vector) ht.get("ADDRESS_1");
				addressTwoVector = (Vector) ht.get("ADDRESS_2");
				addressThreeVector = (Vector) ht.get("ADDRESS_3");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
			}
	        if (quoteIdVector.size() > 0) {
	        	for (int i = 0; i < quoteIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("quoteId", quoteIdVector.get(i).toString());
	        		temp.put("custPORequired", custPORequiredVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("addressOne", addressOneVector.get(i).toString());
					temp.put("addressTwo", addressTwoVector.get(i).toString());
					temp.put("addressThree", addressThreeVector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	public ArrayList<HashMap<String, String>> getTemplateItemList(String quoteId) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select qd.DISPLAY_SEQ,it.ITEM, qd.QUOTE_DESC,it.EXT_DESCRIPTION,it.SIZE_, qd.PRICE, qd.PRICE_UOM_CODE, 0 as QUANTITY, it.STOCKING_UOM "
							+" from quote_detail qd, item it " 
							+" where qd.ITEM_PTR=it.ITEM_PTR "
							+" and quote_id="+Integer.parseInt(quoteId.trim())+" " 
							+" order by qd.DISPLAY_SEQ ";
			Utils.log("Query >>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector displaySeqVector = new Vector();
			Vector itemVector = new Vector();
			Vector quoteDescVector = new Vector();
			Vector extDescVector = new Vector();
			Vector sizeVector = new Vector();
			Vector priceVector = new Vector();
			Vector priceUomCodeVector = new Vector();
			Vector quantityVector = new Vector();
			Vector stockingUomVector = new Vector();
			if (ht != null && ht.size() > 0) {
				displaySeqVector = (Vector) ht.get("DISPLAY_SEQ");
				itemVector = (Vector) ht.get("ITEM");
				quoteDescVector = (Vector) ht.get("QUOTE_DESC");
				extDescVector = (Vector) ht.get("EXT_DESCRIPTION");
				sizeVector = (Vector) ht.get("SIZE_");
				priceVector = (Vector) ht.get("PRICE");
				priceUomCodeVector = (Vector) ht.get("PRICE_UOM_CODE");
				quantityVector = (Vector) ht.get("QUANTITY");
				stockingUomVector = (Vector) ht.get("STOCKING_UOM");
			}
	        if (itemVector.size() > 0) {
	        	for (int i = 0; i < itemVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("displaySeq", displaySeqVector.get(i).toString());
	        		temp.put("item", itemVector.get(i).toString());
	        		temp.put("quoteDesc", quoteDescVector.get(i).toString());
	        		temp.put("extDesc", extDescVector.get(i).toString());
	        		temp.put("size", sizeVector.get(i).toString());
	        		temp.put("price", priceVector.get(i).toString());
					temp.put("priceUomCode", priceUomCodeVector.get(i).toString());
					temp.put("quantity", quantityVector.get(i).toString());
					temp.put("stockingUom", stockingUomVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

	
%>
