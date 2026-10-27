package com.etechlogix.distribution.so.servlet;

import java.io.FileReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.Scanner;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import com.etechlogix.distribution.so.servlet.ApiCall;
import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

//import net.sf.json.JSONArray;
//import net.sf.json.JSONObject;

public class PurchaseOrderAction extends HttpServlet{
	
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		String responseString = "";
		JSONObject responseJson=new JSONObject();
		String statusCode="1",message="",warehouse="";
		JSONObject resultObj = new JSONObject();
        String auditSequence = "", auditType = "",auditTable = "",auditRecordIndex = "", auditText = "";
		try{
			DistUtils du=new DistUtils();
			FileReader reader=new FileReader("eTechLogix.properties");  
			Properties prop=new Properties();  
			prop.load(reader);    
			//String url=prop.getProperty("AgilityUrl");
			String url="https://api-1362-1.dmsi.com/AgilityPublic/rest/";
			String loginUrl = url+"Session/Login";
			String secretApiKey = prop.getProperty("ApiKey");

			String jsonString = extractPostRequestBody(request);
			JSONObject obj = new JSONObject(jsonString);
			String token = Utils.removeNull(obj.optString("token")).trim();
			
			String query="SELECT COUNT(*) FROM DMSI_APITOKEN WHERE MODULE='PURCHASEORDER' AND TOKEN='"+token+"'";
			String tokenValid=du.getFieldInfo(query);
			
			if(Integer.parseInt(tokenValid)==0){
	        	resultObj.put("status", "error");
				resultObj.put("message", "Invalid Token");
				responseString = resultObj.toString();
			}
			else{
				String supplierNo = Utils.removeNull(obj.optString("supplierNo")).trim();
				String shipFromSequence = Utils.removeNull(obj.optString("shipFromSequence")).trim();
				String purchaseType = Utils.removeNull(obj.optString("purchaseType")).trim();
				String customerId = Utils.removeNull(obj.optString("customerId")).trim();
				warehouse = customerId.substring(3);
				String buyerId = Utils.removeNull(obj.optString("buyerId")).trim();
				String shipToSequence = Utils.removeNull(obj.optString("shipToSequence")).trim();
				String poDescription = Utils.removeNull(obj.optString("poDescription")).trim();
				String reference = Utils.removeNull(obj.optString("reference")).trim();
				String sendPOVia = Utils.removeNull(obj.optString("sendPOVia")).trim();
				String expectedShipDate = Utils.removeNull(obj.optString("expectedShipDate")).trim();
				String expectedReceiptDate = Utils.removeNull(obj.optString("expectedReceiptDate")).trim();
				JSONArray items = obj.optJSONArray("items");
				
				if (supplierNo.isEmpty()) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "Supplier# is required");
				    responseString = resultObj.toString();
				}
				else if (shipFromSequence.isEmpty() || Integer.parseInt(shipFromSequence) < 1) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "ShipFromSequence is required");
				    responseString = resultObj.toString();
				}				
				else if (purchaseType.isEmpty()) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "PurchaseType is required");
				    responseString = resultObj.toString();
				}				
				else if (customerId.isEmpty()) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "Customer# is required");
				    responseString = resultObj.toString();
				}				
				else if (shipToSequence.isEmpty() || Integer.parseInt(shipToSequence) < 1) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "ShipToSequence is required");
				    responseString = resultObj.toString();
				}				
				else if (sendPOVia.isEmpty()) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "SendPOVia is required");
				    responseString = resultObj.toString();
				}	
				else if (items == null || items.length() == 0) {
				    resultObj.put("status", "error");
				    resultObj.put("message", "Items are required");
				    responseString = resultObj.toString();
				}
				else{
					net.sf.json.JSONObject childBody=new net.sf.json.JSONObject();
					childBody.put("LoginID", "API");
					childBody.put("Password", "~Zrwcetech123");
					net.sf.json.JSONObject mainBody=new net.sf.json.JSONObject();
					mainBody.put("request", childBody);

					String expectedDeliveryDate="";
					//expectedDeliveryDate = Utils.removeNull(header.optString("ExpectedDate")).trim();
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
					if(expectedDeliveryDate.equals("")){
						Date currentDate = new Date();
						expectedDeliveryDate=sdf.format(currentDate);
					}else{
						String fullYear="";
						String year=expectedDeliveryDate.substring(6,expectedDeliveryDate.length());
						if(year.length() == 2){
							if(Integer.parseInt(year) < 50)
								fullYear="20"+year;
					   		else
					   			fullYear="19"+year;
					  	}else{
							fullYear=year;
						}

						SimpleDateFormat dt = new SimpleDateFormat("MM-dd-yyyy");
						Date expectedDeliveryDateFormatChange = dt.parse(expectedDeliveryDate.substring(0,6)+fullYear.trim());
						expectedDeliveryDate=sdf.format(expectedDeliveryDateFormatChange);
					}

					//first test using default values if it does not work then get values based on ShipFromSequence

					net.sf.json.JSONObject jsonObject=new net.sf.json.JSONObject();
					jsonObject.put("ShipFromSequence", Integer.parseInt(shipFromSequence)); //required
					jsonObject.put("PurchaseType", purchaseType);  //required
					jsonObject.put("OrderDate", expectedDeliveryDate.trim()); //current date
					jsonObject.put("CustomerID", customerId); //required
					jsonObject.put("ShipToSequence", Integer.parseInt(shipToSequence));  
					//jsonObject.put("PaymentTermsCode", "");
					//jsonObject.put("FreightTerms", "");
					jsonObject.put("PODescription", poDescription); //optional 
					//jsonObject.put("VerbalPO", "");
					jsonObject.put("Reference", reference); //optional
					//jsonObject.put("POLabel", "");
					jsonObject.put("SendPOVia", sendPOVia); //required
					jsonObject.put("Buyer1", buyerId); //optional
					//jsonObject.put("Buyer2", "");
					jsonObject.put("ExpectedShipDate", expectedShipDate); //optional
					jsonObject.put("ExpectedReceiptDate", expectedReceiptDate); //optional
					//jsonObject.put("ExpectedReceiptTime", "");
					//jsonObject.put("ExcludefromNetQtyUntil", "");
					jsonObject.put("UpdateLead", true);
					//jsonObject.put("ShipVia", "");
					//jsonObject.put("PickUpID", "");
					//jsonObject.put("TrackingDate", "");
					//jsonObject.put("ConfirmedBy", "");
					jsonObject.put("AllowChanges", true);
					//jsonObject.put("AllowChangesUntilDate", "");
					//jsonObject.put("AllowChangesUntilTime", "");
					jsonObject.put("APISourceID", "API");
					
					net.sf.json.JSONArray dtPurchaseOrderHeaderArray = new net.sf.json.JSONArray();
					dtPurchaseOrderHeaderArray.add(jsonObject);
					net.sf.json.JSONObject dsPurchaseOrderHeaderObj=new net.sf.json.JSONObject();
					dsPurchaseOrderHeaderObj.put("dtPurchaseOrderHeader", dtPurchaseOrderHeaderArray.toString());
							
					net.sf.json.JSONArray dtPurchaseOrderHeaderNotesArray = new net.sf.json.JSONArray();
					net.sf.json.JSONObject jsonObjectNotes1=new net.sf.json.JSONObject();
					jsonObjectNotes1.put("OrderNote", "");
					jsonObjectNotes1.put("HotNote", true);
					jsonObjectNotes1.put("ReminderDate", "");
					dtPurchaseOrderHeaderNotesArray.add(jsonObjectNotes1);
							
					net.sf.json.JSONObject jsonObjectNotes2=new net.sf.json.JSONObject();
					jsonObjectNotes2.put("OrderNote", "");
					jsonObjectNotes2.put("HotNote", false);
					jsonObjectNotes1.put("ReminderDate", "");
					dtPurchaseOrderHeaderNotesArray.add(jsonObjectNotes2);
							
					dsPurchaseOrderHeaderObj.put("dtPurchaseOrderHeaderNotes", dtPurchaseOrderHeaderNotesArray.toString());

					net.sf.json.JSONArray dtPurchaseOrderItemArray = new net.sf.json.JSONArray();
					if (items != null) {
						for (int i = 0; i < items.length(); i++) {
							JSONObject item = items.getJSONObject(i);
						    int sequence = i+1;
							String itemNo = item.optString("itemNo");
						    int qty = item.optInt("qty");

							net.sf.json.JSONObject jsonObjectTwo = new net.sf.json.JSONObject();
							jsonObjectTwo.put("Sequence", sequence);
							jsonObjectTwo.put("ItemCode", itemNo); //required
							jsonObjectTwo.put("OrderQty", qty); //required
							/*jsonObjectTwo.put("UOM", "");
							jsonObjectTwo.put("Cost", 1); //optional
							jsonObjectTwo.put("CostUOM", ""); 
							jsonObjectTwo.put("DueDate", "");
							jsonObjectTwo.put("ExpectedShipDate", ""); 
							jsonObjectTwo.put("ExpectedReceiptDate", "");
							jsonObjectTwo.put("Discount1", 0);
							jsonObjectTwo.put("Discount2", 0);
							jsonObjectTwo.put("Discount3", 0);
							jsonObjectTwo.put("GroupID", "");
							jsonObjectTwo.put("AddPermanentDetailGroupID", false);
							jsonObjectTwo.put("Description", "");
							jsonObjectTwo.put("ProposedSellPrice", 0);
							jsonObjectTwo.put("SellPriceUOM", "");
							jsonObjectTwo.put("Size", "");
							jsonObjectTwo.put("SupplierQuotedCost", false);
							jsonObjectTwo.put("SupplierQuoteID", "");*/

						    dtPurchaseOrderItemArray.add(jsonObjectTwo);
					    }
					}
							
					net.sf.json.JSONObject dsPurchaseOrderItemObj=new net.sf.json.JSONObject();
					dsPurchaseOrderItemObj.put("dtPurchaseOrderItem", dtPurchaseOrderItemArray.toString());
					
					net.sf.json.JSONObject purchaseOrderJSONObj=new net.sf.json.JSONObject();
					purchaseOrderJSONObj.put("dsPurchaseOrderHeader",dsPurchaseOrderHeaderObj);
					purchaseOrderJSONObj.put("dsPurchaseOrderItem",dsPurchaseOrderItemObj);
							
					net.sf.json.JSONObject finalObj=new net.sf.json.JSONObject();
					finalObj.put("SupplierID",supplierNo);
					finalObj.put("PurchaseOrderJSON",purchaseOrderJSONObj);
							
					net.sf.json.JSONObject reqObj=new net.sf.json.JSONObject();
					reqObj.put("request",finalObj);

					Utils.log("PurchaseOrderCreate Request Body >>>> " + reqObj);
					ApiCall apiCallObj = new ApiCall();
					net.sf.json.JSONObject loginRespObj = apiCallObj.getContextId(mainBody,loginUrl);
					if(loginRespObj != null){
							net.sf.json.JSONObject loginResp = (net.sf.json.JSONObject)loginRespObj.get("response");
							String contextId = loginResp.get("SessionContextId").toString();
							//String systemId = loginResp.get("InitialBranch").toString();
								
							String purchaseOrderCreateUrl = url+"Purchasing/PurchaseOrderCreate";
							net.sf.json.JSONObject responseObj = apiCallObj.agilityPublicAPICall(reqObj,purchaseOrderCreateUrl,contextId,warehouse);
					       	Utils.log("PurchaseOrderCreate Response >>>> "+responseObj);
					       	net.sf.json.JSONObject res = (net.sf.json.JSONObject)responseObj.get("response");
					       	if(Integer.parseInt(res.get("ReturnCode").toString()) == 0){
					       		if (res.containsKey("AuditResults") && res.get("AuditResults") != null) {
					       		    net.sf.json.JSONObject auditResults = (net.sf.json.JSONObject) res.get("AuditResults");
					       		    if (auditResults.containsKey("dsAuditResults") && auditResults.get("dsAuditResults") != null) {
					       		        net.sf.json.JSONObject dsAuditResults = (net.sf.json.JSONObject) auditResults.get("dsAuditResults");
					       		        if (dsAuditResults.containsKey("dtAuditResults") && dsAuditResults.get("dtAuditResults") != null) {
					       		            net.sf.json.JSONArray dtAuditResults = (net.sf.json.JSONArray) dsAuditResults.get("dtAuditResults");
					       		            for (int i = 0; i < dtAuditResults.size(); i++) {
					       		                net.sf.json.JSONObject audit = (net.sf.json.JSONObject) dtAuditResults.get(i);
					       		                auditSequence = audit.get("AuditSequence") != null 
					       		                        ? audit.get("AuditSequence").toString()
					       		                        : "";

					       		                auditType = audit.get("AuditType") != null
					       		                        ? audit.get("AuditType").toString()
					       		                        : "";

					       		                auditTable = audit.get("AuditTable") != null
					       		                        ? audit.get("AuditTable").toString()
					       		                        : "";

					       		                auditRecordIndex = audit.get("AuditRecordIndex") != null
					       		                        ? audit.get("AuditRecordIndex").toString()
					       		                        : "";

					       		                auditText = audit.get("AuditText") != null
					       		                        ? audit.get("AuditText").toString()
					       		                        : "";

					       		                Utils.log("AuditSequence >>>> " + auditSequence);
					       		                Utils.log("AuditType >>>> " + auditType);
					       		                Utils.log("AuditTable >>>> " + auditTable);
					       		                Utils.log("AuditRecordIndex >>>> " + auditRecordIndex);
					       		                Utils.log("AuditText >>>> " + auditText);
					       		            }
					       		        }
					       		    }
					       		}


					       		String newOrderId=res.get("NewOrderID").toString();
					       		Utils.log("NewOrderID >>>> "+newOrderId);

								message=res.get("MessageText").toString();
					        	resultObj.put("status", "success");
								resultObj.put("message", message);
					        	resultObj.put("orderNo", newOrderId);

					        	resultObj.put("auditSequence", auditSequence);
					        	resultObj.put("auditType", auditType);
					        	resultObj.put("auditTable", auditTable);
					        	resultObj.put("auditRecordIndex", auditRecordIndex);
					        	resultObj.put("auditText", auditText);
					        	responseString = resultObj.toString();
					        }else{
								message=res.get("MessageText").toString();
					        	resultObj.put("status", "error");
								resultObj.put("message", message);
					        	resultObj.put("orderNo", "0");
					        	responseString = resultObj.toString();
					        }
					}
					
				}
			}

		}catch(Exception ex){
			ex.printStackTrace();
			Utils.log("Exception AI Data Store", ex);
			responseString = "{\"status\":\"error\", \"message\": \" "+ex.toString()+" \"}";
		}

		Utils.log(responseString);
		response.getOutputStream().println(responseString);
		
	}

	
	static String extractPostRequestBody(HttpServletRequest request) throws Exception {
		if ("POST".equalsIgnoreCase(request.getMethod())) {
			Scanner s = new Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
			return s.hasNext() ? s.next() : "";
		}
		return "";
	}

	
	
}
