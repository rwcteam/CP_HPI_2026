<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="java.text.DecimalFormat"%>



<% 

	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();
	
	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}

	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	String message=(String)request.getAttribute("message");
	if(message == null)
		message="";
	
	String custKey=(String)session.getAttribute("custKey");
	String soId=request.getParameter("soId");
	
	HashMap<String, String> headerMap = getOpenOrdersInquiryHeader(custKey,soId);
	List<HashMap<String, String>> listData = getOpenOrdersInquiryDetails(soId);

%>

<!doctype html>
<html lang="en">
<head>
    <title>Open Orders Inquiry</title>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
	
	<link rel='stylesheet' href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/ui-lightness/jquery-ui.css" >
	
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
	<!--<link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet"> -->
	    
	<!-- Data Table CSS-->
	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.13.4/css/jquery.dataTables.min.css">
	<link rel="stylesheet" href="https://cdn.datatables.net/buttons/1.4.1/css/buttons.dataTables.min.css">
	
    <!-- Jquery JS-->
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js" ></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js" ></script>
	    
	<!-- DataTable JS-->
	<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.3.1/js/dataTables.buttons.min.js"></script> 
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>

	<style type="text/css">
	
	</style>

	<script type="text/javascript">
	
		var today;
		
		$(document).ready(function(){
			debugger;
			
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
		    //var mm=now.getMonth();
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			today = mm + '-' + (dd) + '-' + now.getFullYear();

			/* $('#expectedDeliveryDate').val(today);
			
			$('#expectedDeliveryDate').datepicker({
	            changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
	            numberOfMonths: 1,
				maxDate: "0",
			}); */ 
			
			$('#OpenOrdersInquiryDataTable').DataTable({
				'pageLength': 50,
				//"aaSorting": [[ 1, "desc" ]],
				'dom': 'Blfrtip',
			    /* 'buttons': [
		            'copy', 'csv', 'excel', 'pdf'
		        ], */
				'bDestroy': true,
				'ordering': false
			});
		});

		/* window.onunload = function(){
			window.opener.location.reload();
		}; */
	
	</script>

</head>
<body>
<div class="container-fluid">
	<div class="body-wrapper">
		<div class="page-wrapper mdc-toolbar-fixed-adjust">
			<main class="content-wrapper">
				<div class="mdc-layout-grid">
					<div class="mdc-layout-grid__inner">
						<div class="mdc-layout-grid__cell stretch-card mdc-layout-grid__cell--span-12">
							<div class="card">
								<div class="card-body">
									<form name="OpenOrderInquiryForm" method="POST" role="form">
										<div class="row">
											<div class="col-md-12 mt-2" align="center">
					                            <label><img src="NewPortalAssets/assets/images/open_orders.png" width="18px" height="18px"/>&nbsp;<b>Order Information</b></label>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>SO#</b></label>
					                            <input type="text" name="soId" id="soId" value="<%=headerMap.get("soId") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Branch</b></label>
					                            <input type="text" name="branch" id="branch" value="<%=headerMap.get("systemId") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ordered Date</b></label>
					                            <input type="text" name="orderDate" id="orderDate" value="<%=headerMap.get("orderDate") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Customer#</b></label>
					                            <input type="text" name="customerId" id="customerId" value="<%=headerMap.get("custCode") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Customer Name</b></label>
					                            <input type="text" name="customerName" id="customerName" value="<%=headerMap.get("custName") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
												<label><b>Customer PO</b></label>
                            					<input type="text" name="customerPo" id="customerPo" value="<%=headerMap.get("custPo") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Ship-to Name</b></label>
					                            <input type="text" name="shipToName" id="shipToName" value="<%=headerMap.get("shipTo") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ordered By</b></label>
					                            <input type="text" name="orderedBy" id="orderedBy" value="<%=headerMap.get("orderedBy") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Payment Terms Code</b></label>
					                            <input type="text" name="paymentTermsCode" id="paymentTermsCode" value="<%=headerMap.get("payTermsCode") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Address 1</b></label>
					                            <input type="text" name="addressOne" id="addressOne" value="<%=headerMap.get("addressOne") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Expected Delivery Date</b></label>
					                            <input type="text" name="expectedDeliveryDate" id="expectedDeliveryDate" value="<%=headerMap.get("expectedDeliveryDate") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Reference</b></label>
					                            <input type="text" name="reference" id="reference" value="<%=headerMap.get("reference") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Address 2</b></label>
					                            <input type="text" name="addressTwo" id="addressTwo" value="<%=headerMap.get("addressTwo") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4" >
						                        <label><b>Freight Terms</b></label>
					                            <input type="text" name="freightTerms" id="freightTerms" value="<%=headerMap.get("freightTerms") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ship Via</b></label>
					                            <input type="text" name="shipVia" id="shipVia" value="<%=headerMap.get("shipVia") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4">
					                            <label><b>City</b></label>
					                            <input type="text" name="city" id="city" value="<%=headerMap.get("city") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>State</b></label>
					                            <input type="text" name="state" id="state" value="<%=headerMap.get("state") %>" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4" >
					                            <label><b>Zip</b></label>
					                            <input type="text" name="zip" id="zip" value="<%=headerMap.get("zip") %>" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>

									</form>
								</div>
							</div>
							<div class="card">
								<div class="card-body">
									<div class="col-md-12">
									   	<%if(listData != null && listData.size()>0){ %>
							 			<div id="showRecordDataTable" class="tabcontent">
											<div class="table-responsive" id="table-div" >
												<table id="OpenOrdersInquiryDataTable" class="table table-striped table-hover table-grid tab-Table FINdatatableStyle" role="grid" width="100%" aria-describedby="datatable-example_info" >
							              				<thead>
											  				<tr>
											  					<th style="text-align: left; width: 4%;" nowrap>SO#</th>
											  					<th style="text-align: left; width: 4%;" nowrap>Line#</th>
											  					<th style="text-align: left; width: 4%;" nowrap>Item</th>
														  		<th style="text-align: left; width: 40%;">Item Description</th>
														  		<th style="text-align: left; width: 4%;" nowrap>Size</th>
														  		<th style="text-align: right; width: 4%;" nowrap>Ordered Qty</th>
														  		<th style="text-align: right; width: 4%;" nowrap>Shipped</th>
														  		<th style="text-align: right; width: 4%;" nowrap>Remaining Qty</th>
																<th style="text-align: left; width: 8%;" nowrap>UOM</th>
																<th style="text-align: right; width: 8%;" nowrap>Price</th>
																<th style="text-align: left; width: 8%;" nowrap>UOM</th>
																<th style="text-align: right; width: 8%;" nowrap>Ext Total</th>
															</tr>
													  	</thead>
											  			<tbody>
											  				<%
																for(int i=0;i<listData.size();i++){
																	HashMap map=(HashMap)listData.get(i);
															%>
																<tr>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("soId")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("sequence")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("item")%></td>
																	<td class="datatableBtnWrp" style="text-align: left;"><%=map.get("description")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("size")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;"><%=df.format(Double.parseDouble(map.get("qtyOrdered").toString()))%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;"><%=df.format(Double.parseDouble(map.get("shipped").toString()))%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;"><%=df.format(Double.parseDouble(map.get("remainingQty").toString()))%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("uom")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">$&nbsp;<%=df.format(Double.parseDouble(map.get("price").toString()))%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;"><%=map.get("priceUomCode")%></td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">$&nbsp;<%=df.format(Double.parseDouble(map.get("extPrice").toString()))%></td>
																</tr>
															<%}%>
											  			</tbody>
													</table>
												</div>
								    		</div>
							    		<%}%>
									</div>
								</div>
							</div>
						</div>
					</div>

				</div>
			</main>
		</div>
	</div>
	</div>


</body>
</html>



<%!

	public HashMap<String, String> getOpenOrdersInquiryHeader(String custKey, String soId) {	
		String sqlQuery="",filterString = "";
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct cu.CUST_CODE,sh.SO_ID,sh.SYSTEM_ID,cu.CUST_NAME,sh.CUST_PO, "
							+" sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO,sh.ORDERED_BY, "
							+" sh.PAY_TERMS_CODE,sa.ADDRESS_1,sh.EXP_SHIP_DATE,sh.REFERENCE,sa.ADDRESS_2,sa.CITY,sa.STATE,sa.ZIP, "
							+" sa.PHONE,sh.SHIP_VIA,sh.FREIGHT_TERMS_ID,sh.ORDER_DATE "
							+" from SO_HEADER sh, SHIP_TO_ADDRESS sa, cust cu " 
							+" where sh.cust_key=cu.cust_key " 
							+" and sh.SO_ID=sa.TRAN_ID(+) " 
							+" and sh.cust_key='"+custKey+"' " 
							+" and sh.SO_ID='"+soId+"' ";
			Utils.log("Query >>>>>> "+sqlQuery);
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
						+" sd.bo, sd.uom,sd.price, sd.price_uom_code, (sd.price/sd.disp_price_conv)*sd.qty_ordered*sd.disp_qty_conv ";
			Utils.log("Query >>>>>> "+sqlQuery);
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

%>




