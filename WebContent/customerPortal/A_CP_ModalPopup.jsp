<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.utils.*" %>
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
	String userId = (String)session.getAttribute("userId");

	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);
	
	String noOfOpenOrdersTileData = getNoOfOpenOrdersData(custKey);
	String totalOrderAmountTileData = getTotalOrderAmountData(custKey);
	
	List<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
	listData = getOpenOrdersData(custKey);
	//request.setAttribute("openInvoiceListData",listData);
	
%>


<!DOCTYPE html>
<html lang="en">
<head>
	<title>Bootstrap Example</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	
	<link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
	<script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
	<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
	
	<style type="text/css">
	</style>
	
	<SCRIPT>
	
		var toDate;
		$(document).ready(function(){
			
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			toDate = mm + '-' + (dd) + '-' + now.getFullYear();
			
			$(document).on('dblclick','#OpenOrdersTable tbody tr', function (event) {
				//systemId = $(this).closest('tr').children('td:eq(1)').text();
		  		//soId = $(this).closest('tr').children('td:eq(2)').text();
		  		popupForOpenOrdersInquiry();
			});

		});

		
        function popupForOpenOrdersInquiry(systemId,soId){
		 	debugger;
			    
			$('#InquiryModal').modal('show');
        }

		
	</script>

</head>
<body>

    <!-- START HEADER-->
	<%@ include file="A_CP_Header.jsp" %>
    <!-- END HEADER-->

    <div class="page-wrapper">

        <!-- PAGE CONTENT-->
        <div class="page-content--bgf7">

            <!-- WELCOME-->
            <section class="welcome p-t-10">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-6">
                            <h3 class="title-5 m-b-35"><img src="NewPortalAssets/assets/images/open_orders.png" width="18px" height="18px"/>&nbsp;Open Orders</h3>
                        </div>
                        <div class="col-md-6">
				<h3 class="title-5 m-b-35" align="right"><%=userNameHeader%></h3>
			</div>
                    </div>
                    <div class="row">
                    	<div class="col-md-12">
                    		<hr class="line-seprate">
                    	</div>
                    </div>
                </div>
            </section>
            <!-- END WELCOME-->

            <!-- STATISTIC-->
            <section class="statistic statistic2">
                <div class="container">
                    <div class="row">
                        <div class="col-md-6 col-lg-3 offset-lg-3 mb-3 mb-lg-0">
                            <div class="item">
                                <h4 class="number" style="color: black; text-align: center; font-size: 15px;"><font color="white" ><%=noOfOpenOrdersTileData %></font></h4>
                                <h6 style="color: black;text-align: center; font-size: 15px;"><font color="white"># of Open Orders</font></h6>
                            </div>
                        </div>
                        <div class="col-md-6 col-lg-3">
                            <div class="item">
                                <h4 class="number" style="color: black; text-align: center; font-size: 15px;"><font color="white"><%=totalOrderAmountTileData %></font></h4>
                                <h6 style="color: black;text-align: center; font-size: 15px;"><font color="white">Total Order Amount</font></h6>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            <!-- END STATISTIC-->


            <!-- DATA TABLE-->
            <section class="p-t-20">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-12">
                            
                            <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive" id="table-div" >
	                                <table id="OpenOrdersTable" class="table table-striped table-hover table-grid tab-Table FINdatatableStyle" role="grid" width="100%" aria-describedby="datatable-example_info" style="font-size:12px;font-family: Verdana;">
	                                    <thead>
	                                        <tr>
												<th align="center" width="2%"></th>
		                                    	<th align="center" width="4%">Branch</th>
	                                            <th align="center" width="4%">SO#</th>
	                                            <th align="center" width="10%">Order Date</th>
	                                            <th align="center" width="20%">Ship To</th>
	                                            <th align="center" width="27%">Address</th>
	                                            <th align="center" width="8%">Cust PO</th>
	                                            <th align="center" width="9%">Type</th>
	                                            <th align="center" width="10%">Order Total</th>
	                                            <th align="center" width="10%">Total Sale</th>
	                                            <th align="center" width="10%">Action</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<% if(listData != null && listData.size()>0){ 
												for(int i=0;i<listData.size();i++){
													HashMap map=(HashMap)listData.get(i);
											%>
												<tr class="tr-shadow" style="cursor: pointer">
													<td align="left"><i class="fa fa-plus" style="color:blue"></i></td>
													<td align="left"><%=map.get("systemId")%></td>
													<td align="left"><%=map.get("soId")%></td>
													<td align="left"><%=map.get("orderDate")%></td>
													<td align="left"><%=map.get("custName")%></td>
													<td align="left"><%=map.get("shipTo")%></td>
													<td align="left"><%=map.get("custPo")%></td>
													<td align="left"><%=map.get("saleType")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("orderTotal").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("totalSale").toString()))%></td>
													<td><button type="button" class="btn btn-info btn-lg" data-toggle="modal" data-target="#InquiryModal" onclick="popupForOpenOrdersInquiry('<%=map.get("systemId")%>','<%=map.get("soId")%>')">View</button></td>
												</tr>
											<%}}%>
	                                    </tbody>
	                                
									</table>
	                            </div>
                        	</div>
                        </div>
                    </div>
                </div>
            </section>
            <!-- END DATA TABLE-->

        </div>
    </div>

	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->


	<div class="container">
    	<div class="modal fade" id="InquiryModal" role="dialog" aria-labelledby="modalLabel">
       		<div class="modal-fullscreen-xxl-down">
        		<div class="modal-content">
          			<div class="modal-header">
            			<h5 class="modal-title" id="modalLabel">Modal</h5>
<!-- 	             	<button type="button" class="close" data-dismiss="modal" aria-label="Close">
              				<span aria-hidden="true">&times;</span>
            			</button> -->
          			</div>
		          			<div class="modal-body">
										<div class="row">
											<div class="col-md-12 mt-2" align="center">
					                            <label><img src="NewPortalAssets/assets/images/open_orders.png" width="18px" height="18px"/>&nbsp;<b>Order Information</b></label>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>SO#</b></label>
					                            <input type="text" name="soId" id="soId" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Branch</b></label>
					                            <input type="text" name="branch" id="branch" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ordered Date</b></label>
					                            <input type="text" name="orderDate" id="orderDate" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Customer#</b></label>
					                            <input type="text" name="customerId" id="customerId" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Customer Name</b></label>
					                            <input type="text" name="customerName" id="customerName" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
												<label><b>Customer PO</b></label>
                            					<input type="text" name="customerPo" id="customerPo" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Ship-to Name</b></label>
					                            <input type="text" name="shipToName" id="shipToName" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ordered By</b></label>
					                            <input type="text" name="orderedBy" id="orderedBy" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Payment Terms Code</b></label>
					                            <input type="text" name="paymentTermsCode" id="paymentTermsCode" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Address 1</b></label>
					                            <input type="text" name="addressOne" id="addressOne" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Expected Delivery Date</b></label>
					                            <input type="text" name="expectedDeliveryDate" id="expectedDeliveryDate" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Reference</b></label>
					                            <input type="text" name="reference" id="reference" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4" >
					                            <label><b>Address 2</b></label>
					                            <input type="text" name="addressTwo" id="addressTwo" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4" >
						                        <label><b>Freight Terms</b></label>
					                            <input type="text" name="freightTerms" id="freightTerms" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>Ship Via</b></label>
					                            <input type="text" name="shipVia" id="shipVia" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4">
					                            <label><b>City</b></label>
					                            <input type="text" name="city" id="city" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4">
					                            <label><b>State</b></label>
					                            <input type="text" name="state" id="state" value="" class="form-control" style="height: 25px;" readonly>
											</div>
											<div class="col-md-4" >
					                            <label><b>Zip</b></label>
					                            <input type="text" name="zip" id="zip" value="" class="form-control" style="height: 25px;" readonly>
											</div>
										</div>
		
									<table class="table table-striped" id="OpenOrdersInquiryDataTable">
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
																<tr>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">$&nbsp;test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: left;">test</td>
																	<td class="datatableBtnWrp" nowrap style="text-align: right;">$&nbsp;test</td>
																</tr>

							  			</tbody>
									</table>            			
		          			</div>
          					<div class="modal-footer">
          						<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="closeModal()">Close</button>
          					</div>
        		</div>
       		</div>
    	</div>
	</div>
  
  	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script> 
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script> 

<script type="text/javascript">
	function closeModal() {
   		debugger;
   		$('#InquiryModal').modal('hide');
	}


</script>


</body>
</html>



<%!

	public ArrayList<HashMap<String, String>> getOpenOrdersData(String custKey) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			
			sqlQuery = "select distinct sh.SYSTEM_ID,sh.SO_ID,sh.ORDER_DATE, "
						+" sa.CUST_NAME, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO, sh.CUST_PO, "
						+" sh.SALE_TYPE,sh.ORDER_TOTAL,sh.TOTAL_SELL " 
						+" from SO_HEADER sh, SHIP_TO_ADDRESS sa " 
						+" where sh.SO_ID=sa.TRAN_ID(+) "
						+" and sh.cust_key='"+custKey+"' "
						+" and sh.so_status!='I' ";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector systemIdVector = new Vector();
			Vector soIdVector = new Vector();
			Vector orderDateVector = new Vector();
			Vector custNameVector = new Vector();
			Vector shipToVector = new Vector();
			Vector custPoVector = new Vector();
			Vector saleTypeVector = new Vector();
			Vector orderTotalVector = new Vector();
			Vector totalSellVector = new Vector();
	
			if (ht != null && ht.size() > 0) {
				systemIdVector = (Vector) ht.get("SYSTEM_ID");
				soIdVector = (Vector) ht.get("SO_ID");
				orderDateVector = (Vector) ht.get("ORDER_DATE");
				custNameVector = (Vector) ht.get("CUST_NAME");
				shipToVector = (Vector) ht.get("SHIP_TO");
				custPoVector = (Vector) ht.get("CUST_PO");
				saleTypeVector = (Vector) ht.get("SALE_TYPE");
				orderTotalVector = (Vector) ht.get("ORDER_TOTAL");
				totalSellVector = (Vector) ht.get("TOTAL_SELL");
			}
	        if (systemIdVector.size() > 0) {
	        	for (int i = 0; i < systemIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("systemId", systemIdVector.get(i).toString());
					temp.put("soId", soIdVector.get(i).toString());
					temp.put("orderDate", orderDateVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("shipTo", shipToVector.get(i).toString());
					temp.put("custPo", custPoVector.get(i).toString());
					temp.put("saleType", saleTypeVector.get(i).toString());
					temp.put("orderTotal", orderTotalVector.get(i).toString());
					temp.put("totalSale", totalSellVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}

	public String getNoOfOpenOrdersData(String custKey){	
		String sqlQuery="",filterString = "",openOrders="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select count(*) "
						+" from  SO_HEADER sh, SHIP_TO_ADDRESS sa " 
						+" where sh.SO_ID=sa.TRAN_ID(+) "
						+" and sh.cust_key='"+custKey+"' "
						+" and sh.so_status!='I' ";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			openOrders=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return openOrders;
	}
	
	
	public String getTotalOrderAmountData(String custKey){	
		String sqlQuery="",filterString = "",orderAmount="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select TO_CHAR(sum(sh.TOTAL_SELL) , 'fm999G999G999D00') as total_amount "
						+" from  SO_HEADER sh, SHIP_TO_ADDRESS sa " 
						+" where sh.SO_ID=sa.TRAN_ID(+) "
						+" and sh.cust_key='"+custKey+"' "
						+" and sh.so_status!='I' "; 
	
			Utils.log("Query >>>>>> "+sqlQuery);
			orderAmount=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return orderAmount;
	
	}
	
	
	
%>



