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

<!-- START HEADER-->
<%@ include file="A_CP_Header.jsp" %>
<!-- END HEADER-->


<style>
    html,
    body {
        height: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
    }
	    
    .slash-separator {
        display: inline-block; /* Allows width/height and vertical alignment */
        margin: 0 5px; /* Adjust spacing around the slash */
        font-weight: bold; /* Make the slash more prominent */
		vertical-align: middle; /* Align the slash vertically with the text */
	}
</style>


	<div class="page-wrapper" id="content">
	    <!-- PAGE CONTENT-->
	    <div class="page-content--bgf7">
	        <section class="py-4">
	            <div class="container-fluid">
	                <div class="row mb-5">
	                	<div class="col-xl-3 col-lg-6 col-md-6 mb-3">
	                        <h6 class="mb-md-0 text-uppercase"><img src="NewPortalAssets/assets/images/icons/open-order.png" width="40px" alt=""> Open Orders</h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
	                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-orders display-4"></i>
	                                </div>
	                                <div class="bg-white p-2 w-100">
	                                    <p class="mb-1">Total Open Orders</p>
	                                    <h3 class="mb-0"><%=noOfOpenOrdersTileData %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-orders display-4"></i>
	                                </div>
	                                <div class="bg-white p-2 w-100">
	                                    <p class="mb-1">Total Order Amount</p>
	                                    <h3 class="mb-0">$<%=totalOrderAmountTileData %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                </div>
	                
	                <%-- <div class="row mb-3 mb-lg-5">
	                    <div class="col-xl-4 col-lg-4 col-md-12 mb-4 mb-lg-0">
	                        <div class="d-flex flex-column align-items-center align-items-lg-start">
	                            <h6 class="mb-4 text-uppercase"><img src="NewPortalAssets/assets/images/icons/open-order.png" width="40px" alt=""> Open Orders</h6>
	                            <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle"><%=userNameHeader%></h6>
	                        </div>
	                    </div>
	                    <div class="col-xl-4 col-lg-4 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-orders display-4"></i>
	                                </div>
	                                <div class="bg-white p-3 w-100">
	                                    <p class="mb-1">Total Open Orders</p>
	                                    <h3 class="mb-0"><%=noOfOpenOrdersTileData %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                    <div class="col-xl-4 col-lg-4 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-orders display-4"></i>
	                                </div>
	                                <div class="bg-white p-3 w-100">
	                                    <p class="mb-1">Total Order Amount</p>
	                                    <h3 class="mb-0">$<%=totalOrderAmountTileData %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                </div> --%>
	                
	                <% if(listData != null && listData.size()>0){%>
	                <div class="row">
	                    <div class="col-md-12">
                            <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive" id="table-div" >
	                                <table id="OpenOrdersTable" class="table border border-top-0 table-grid tab-Table" role="grid" width="100%" aria-describedby="datatable-example_info">
	                                    <thead>
	                                        <tr>
	                                            <th align="center">Branch</th>
	                                            <th align="center">SO</th>
	                                            <th align="center">Order Date</th>
	                                            <th align="center">Ship to</th>
	                                            <th align="center">Address</th>
	                                            <th align="center">Cust PO</th>
	                                            <th align="center">Type</th>
	                                            <th align="right">Order Total</th>
	                                            <th align="right">Total Sale</th>
	                                            <th align="center">Action</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<% 
												for(int i=0;i<listData.size();i++){
													HashMap map=(HashMap)listData.get(i);
											%>
												<tr class="tr-shadow" style="cursor: pointer">
													<td align="left"><%=map.get("systemId")%></td>
													<td align="left"><%=map.get("soId")%></td>
													<td align="left"><%=map.get("orderDate")%></td>
													<td align="left"><%=map.get("custName")%></td>
													<td align="left"><%=map.get("shipTo")%></td>
													<td align="left"><%=map.get("custPo")%></td>
													<td align="left"><%=map.get("saleType")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("orderTotal").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("totalSale").toString()))%></td>
												    <td align="center"><button onclick="popupForOpenOrdersInquiry('<%=map.get("systemId")%>','<%=map.get("soId")%>','<%=df.format(Double.parseDouble(map.get("orderTotal").toString()))%>','<%=df.format(Double.parseDouble(map.get("totalSale").toString()))%>')"
                                                    	class="btn btn-outline-danger btn-sm d-flex align-items-center"
                                                    	data-toggle="modal" data-target="#orderInformation" title="View"><i
                                                        class="icon-visible fs-1 mr-2"></i> View</button></td>
												
												</tr>
											<%}%>
	                                    </tbody>
	                                
									</table>
	                            </div>
                        	</div>
	                    </div>
	                </div>
	                <%}%>
	            </div>
	        </section>
	    </div>
	</div>
	
	<div class="modal mx-100 w-100" id="orderInformation" data-backdrop="static" tabindex="-1" role="dialog"
	    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
	    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
	        <div class="modal-content rounded-0 mx-md-4">
	            <div class="modal-header">
	                <h5 class="modal-title" id="orderInformationCenterTitle"><img src="NewPortalAssets/assets/images/icons/open-order.png" width="40px" alt=""> Order Information</h5>
	                <div class="ml-auto">
		                <a href="javascript:getReportPdfOrExcel('ReportPdf');" class="btn btn-outline-danger btn-sm"><i class="fa fa-print"></i> </a>
		                <a href="javascript:void(0)" class="close small opacity-100 text-dark" data-dismiss="modal" aria-label="Close"><i class="icon-close-flat small"></i></a>
	                </div>
	            </div>
	            <div class="modal-body px-0">
	                <div class="container-fluid">
	                    <div class="row">
	         				<div class="col-md-12">
		                        <div class="row mt-0 mb-2 justify-content-center">
			                    	<div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
				                        <div class="card rounded-0 bg-danger-subtle border-0">
				                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
				                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
				                                    <i class="icon-orders display-4"></i>
				                                </div>
				                                <div class="bg-white p-2 w-100">
				                                    <p class="mb-1">Total Sale</p>
				                                    <h6 class="mb-0" id="totalSaleTile"></h6>
				                                </div>
				                            </div>
				                        </div>
				                    </div>
			                        <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
				                        <div class="card rounded-0 bg-danger-subtle border-0">
				                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
				                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
				                                    <i class="icon-orders display-4"></i>
				                                </div>
				                                <div class="bg-white p-2 w-100">
				                                    <p class="mb-1">Order Total</p>
				                                    <h6 class="mb-0" id="orderTotalTile"></h6>
				                                </div>
				                            </div>
				                        </div>
				                    </div>
		                        </div>
	                        </div>
	                    
	                        <div class="col-md-4 d-flex">
	                            <div class="card bg-light rounded-0 border-0 w-100">
	                                <div class="card-body">
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">SO#</h6>
	                                        <p class="m-0 text-xl-right" id="soId"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Customer#</h6>
	                                        <p class="m-0 text-xl-right" id="custCode"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Ship To</h6>
	                                        <p class="m-0 text-xl-right" id="shipTo"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Address 1</h6>
	                                        <p class="m-0 text-xl-right" id="addressOne"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> Address 2 </h6>
	                                        <p class="m-0 text-xl-right" id="addressTwo"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> City/State/Zip </h6>
	                                        <div class="d-flex">
		                                        <p class="m-0 text-xl-right" id="city"></p>&nbsp;
		                                        <p class="m-0 text-xl-right" id="state"></p>&nbsp;
		                                        <p class="m-0 text-xl-right" id="zip"></p>
	                                        </div>
	                                    </div>
	                                </div>
	                            </div>
	                        </div>
	                        <div class="col-md-4 d-flex">
	                            <div class="card bg-light rounded-0 border-0 w-100">
	                                <div class="card-body">
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Branch</h6>
	                                        <p class="m-0 text-xl-right" id="systemId"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Customer Name</h6>
	                                        <p class="m-0 text-xl-right" id="customerName"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Ordered By</h6>
	                                        <p class="m-0 text-xl-right" id="orderedBy"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> Expected Delivery Date </h6>
	                                        <p class="m-0 text-xl-right" id="expectedDeliveryDate"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> Contact Name </h6>
	                                        <p class="m-0 text-xl-right" id="contactName"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Phone</h6>
	                                        <p class="m-0 text-xl-right" id="phoneNo"></p>
	                                    </div>                                   
	                                </div>
	                            </div>
	                        </div>
	                        <div class="col-md-4 d-flex">
	                            <div class="card bg-light rounded-0 border-0 w-100">
	                                <div class="card-body">
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Ordered Date</h6>
	                                        <p class="m-0 text-xl-right" id="orderDate"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Customer PO</h6>
	                                        <p class="m-0 text-xl-right" id="customerPo"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Payment Terms Code</h6>
	                                        <p class="m-0 text-xl-right" id="paymentTermsCode"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Reference</h6>
	                                        <p class="m-0 text-xl-right" id="reference"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Ship Via</h6>
	                                        <p class="m-0 text-xl-right" id="shipVia"></p>
	                                    </div>
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> Freight Terms </h6>
	                                        <p class="m-0 text-xl-right" id="freightTerms"></p>
	                                    </div>
	                                    <!-- <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Notes</h6>
	                                        <p class="m-0 text-xl-right" id="notes"></p>
	                                    </div>                                   
	                                    <div class="d-xl-flex justify-content-between mb-2">
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold">Message</h6>
	                                        <p class="m-0 text-xl-right" id="message"></p>
	                                    </div> -->
	                                </div>
	                            </div>
	                        </div>
	                        
	                        <div class="col-md-12 mt-3">
								<div class="table-responsive">
									<table id="OpenOrdersInquiryDataTable" class="table border border-top-0 table-grid tab-Table" >
									    <thead>
											<tr>
												<th style="text-align: left; width: 4%;" nowrap>SO#</th>
											  	<th style="text-align: left; width: 4%;" nowrap>Line#</th>
											  	<th style="text-align: left; width: 4%;" nowrap>Item</th>
												<th style="text-align: left; width: 40%;">Item Description</th>
												<th style="text-align: left; width: 12%;" nowrap>Size</th>
												<th style="text-align: right; width: 4%;" nowrap>Ordered Qty</th>
												<th style="text-align: right; width: 4%;" nowrap>Shipped</th>
												<th style="text-align: right; width: 4%;" nowrap>Remaining Qty</th>
												<th style="text-align: left; width: 4%;" nowrap>UOM</th>
												<th style="text-align: right; width: 8%;" nowrap>Price</th>
												<th style="text-align: left; width: 4%;" nowrap>UOM</th>
												<th style="text-align: right; width: 8%;" nowrap>Ext Total</th>
											</tr>
									    </thead>
							  			<tbody>
							  			</tbody>
									</table>            			
								</div>
							</div>	                    
	                    </div>
	                </div>
	            </div>
	            <div class="modal-footer">
	            	<!-- <button type="button" name="ReportPdf" value="Report PDF" onClick="getReportPdfOrExcel('ReportPdf');" class="btn btn-lg btn-danger m-0 rounded-lg" >Print PDF</button>&nbsp; -->
	                <button type="button" data-dismiss="modal" class="btn btn-lg btn-danger m-0 rounded-lg">Close</button>
	            </div>
	        </div>
	    </div>
	</div>

	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->

	<script type="text/javascript">
	
	    var systemId,soIdTemp,orderId,shipmentId;
		var id,today ;
	
		$(document).ready(function(){
	  		//debugger;
	
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			today = mm + '-' + (dd) + '-' + now.getFullYear();
			
			$('#datepicker1,#datepicker2').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				maxDate: "0",
			});
			
			$('#OpenOrdersTable').DataTable({
				'pageLength': 25,
				"aaSorting": [[ 2, "desc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            {
		                    extend: 'copyHtml5',
		                    text: '<i class="icon-copy text-white mr-1"></i> Copy'
		                },
		                {
		                    extend: 'csvHtml5',
		                    text: '<i class="icon-download text-white mr-1"></i> CSV'
		                },
		                {
		                    extend: 'excelHtml5',
		                    text: '<i class="icon-download text-white mr-1"></i> XLS'
		                }
			        ],
				'bDestroy': true
			});
			
			/* $(document).on('dblclick','#OpenOrdersTable tbody tr', function (event) {
				systemId = $(this).closest('tr').children('td:eq(1)').text();
		  		soId = $(this).closest('tr').children('td:eq(2)').text();
		  		popupForOpenOrdersInquiry(systemId,soId);
			}); */

		    $('.dataTables_filter input').attr('placeholder', 'Search items...');

		}); 	

        function popupForOpenOrdersInquiry(systemId,soId,orderTotal,totalSale){
		 	debugger;
        	inquiryHeader(systemId,soId,orderTotal,totalSale);
			inquiryDetails(systemId,soId);
			soIdTemp=soId;
        }

        function inquiryHeader(systemId,soId,orderTotal,totalSale){
			$('#soId').text('');
			$('#systemId').text('');
			$('#custCode').text('');
			$('#customerName').text('');
			$('#customerPo').text('');
			$('#shipTo').text('');
			$('#orderedBy').text('');
			$('#paymentTermsCode').text('');
			$('#addressOne').text('');
			$('#expectedDeliveryDate').text('');
			$('#reference').text('');
			$('#addressTwo').text('');
			$('#city').text('');
			$('#state').text('');
			$('#zip').text('');
			$('#phone').text('');
			$('#shipVia').text('');
			$('#freightTerms').text('');
			$('#orderDate').text('');
			$('#contactName').text('');
			$('#phoneNo').text('');
        	$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_OpenOrdersInquiryAction.jsp?param=InquiryHeader&systemId="+systemId+"&soId="+soId,
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#soId').text(response.soId);
					$('#systemId').text(response.systemId);
					$('#custCode').text(response.custCode);
					$('#customerName').text(response.custName);
					$('#customerPo').text(response.custPo);
					$('#shipTo').text(response.custName);
					$('#orderedBy').text(response.orderedBy);
					$('#paymentTermsCode').text(response.payTermsCode);
					$('#addressOne').text(response.addressOne);
					$('#expectedDeliveryDate').text(response.expectedDeliveryDate);
					$('#reference').text(response.reference);
					$('#addressTwo').text(response.addressTwo);
					$('#city').text(response.city);
					$('#state').text(response.state);
					$('#zip').text(response.zip);
					$('#phone').text(response.phone);
					$('#shipVia').text(response.shipVia);
					$('#freightTerms').text(response.freightTerms);
					$('#orderDate').text(response.orderDate);
					$('#contactName').text(response.contactName);
					$('#phoneNo').text(response.phoneNo);
					$('#orderTotalTile').text('$'+orderTotal);
					$('#totalSaleTile').text('$'+totalSale);
				},
				failure: function (response) {
				}
			});
        }
        
        function inquiryDetails(systemId,soId){
 	  		//var popupDataTable = new DataTable('#OpenOrdersInquiryDataTable');
 	  		//popupDataTable.clear().draw();

	   		$('#OpenOrdersInquiryDataTable').find('tbody').detach();
	    	$('#OpenOrdersInquiryDataTable').append($('<tbody>'));

        	let nf = new Intl.NumberFormat('en-US');
        	$.ajax({
				url : "../customerPortal/A_CP_OpenOrdersInquiryAction.jsp?param=InquiryDetails&systemId="+systemId+"&soId="+soId,
				type : 'POST',
				//dataType : 'text',
				//async: true,
				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.InquiryDetails;
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
							var tempRow = '<tr>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.soId+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.sequence+'</td>'+
											'<td class="datatableBtnWrp" nowrap style="text-align: left;">'+row.item+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: left;">'+row.description+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: left;">'+row.size+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: right;">'+Number(row.qtyOrdered).toFixed(3)+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: right;">'+Number(row.shipped).toFixed(3)+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: right;">'+Number(row.remainingQty).toFixed(3)+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: center;">'+row.uom+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: right;">$ '+Number(row.price).toFixed(3)+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: center;">'+row.priceUomCode+'</td>'+
											'<td class="datatableBtnWrp" style="text-align: right;">$ '+Number(row.extPrice).toFixed(2)+'</td>'+
					   				   '</tr>';
							$('#OpenOrdersInquiryDataTable').append(tempRow);
						});
		        	}
					$('#OpenOrdersInquiryDataTable').DataTable({
						'pageLength': 50,
						//"aaSorting": [[ 2, "desc" ]],
						'dom': 'Blfrtip',
					    'buttons': [
					            /* 'copy', 'csv', 'excel' */
					            /*'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5'*/
				        ],
						'bDestroy': true,
						'scrollY': "50vh",
						'scrollX' : true,
						'autoWidth' : false,
						'scrollCollapse': true
					});

		        },
				failure: function (response) {
				}
			});

        	//$('#InquiryModal').modal('show');
        }

        
	   	function closeModal() {
	   		debugger;
	   		//$('#InquiryModal').modal('hide');
	   		$('#InquiryModal').modal().hide();
		}

	 	
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}

		function getReportPdfOrExcel(reportType){
			debugger;
	   		$('#preloader').removeClass('d-none');
			$.ajax({
				type: 'POST',
				url: '../customerPortal/A_CP_OpenOrdersInquiryAction.jsp?param='+reportType+'&soId='+soIdTemp,
				success: function(data){
					var jsonObj = $.parseJSON(data.trim());
					//showMessageNew(jsonObj.message);
					openPDF(jsonObj.filepath);
					$('#preloader').addClass('d-none');
				},
				beforeSend: function() {
					$('.overLay').show();
				},
				error: function(error) {
					$('#preloader').addClass('d-none');
				},
				complete: function() {
					$('.overLay').hide();
				},
			});				
		}
		
		function openPDF(pdfPath){
			msgWindow=open('/' + pdfPath, "_blank");
			if(msgWindow.opener==null) msgWindow.opener = self;
				msgWindow.focus();
		}
		
	</script>
	

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
						+" and sh.so_status NOT IN('I','C') ";
	
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
						+" from (select distinct sh.SYSTEM_ID,sh.SO_ID,sh.ORDER_DATE, "
						+" sa.CUST_NAME, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO, sh.CUST_PO, "
						+" sh.SALE_TYPE,sh.ORDER_TOTAL,sh.TOTAL_SELL " 
						+" from SO_HEADER sh, SHIP_TO_ADDRESS sa " 
						+" where sh.SO_ID=sa.TRAN_ID(+) "
						+" and sh.cust_key='"+custKey+"' "
						+" and sh.so_status NOT IN('I','C')) sh";
	
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
							+" from (select distinct sh.SYSTEM_ID,sh.SO_ID,sh.ORDER_DATE, "
							+" sa.CUST_NAME, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO, sh.CUST_PO, "
							+" sh.SALE_TYPE,sh.ORDER_TOTAL,sh.TOTAL_SELL " 
							+" from SO_HEADER sh, SHIP_TO_ADDRESS sa " 
							+" where sh.SO_ID=sa.TRAN_ID(+) "
							+" and sh.cust_key='"+custKey+"' "
							+" and sh.so_status NOT IN('I','C')) sh";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			orderAmount=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return orderAmount;
	
	}
	
%>
