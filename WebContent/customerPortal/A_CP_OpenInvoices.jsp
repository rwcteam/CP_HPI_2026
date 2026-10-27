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
	String userId = (String)session.getAttribute("userId");

	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);
			
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	
	String openInvoiceTileData = getOpenInvoiceTileData(custKey);
	String openAmountTileData = getOpenAmountTileData(custKey);
	double openAmountTotal=0;
	
	List<HashMap<String, String>> listData = getOpenInvoiceData(custKey);
	if(listData != null && listData.size()>0){ 
		for(int i=0;i<listData.size();i++){
			HashMap map=(HashMap)listData.get(i);
			openAmountTotal=openAmountTotal+Double.parseDouble(map.get("openAmt").toString()); 
		}
	}
	
	//listData = getOpenInvoiceData(custKey);
	//request.setAttribute("openInvoiceListData",listData);

%>

	<style>
	    html,
	    body {
	        height: 100%;
	        margin: 0;
	        display: flex;
	        flex-direction: column;
	    }
	</style>


    <!-- START HEADER-->
	<%@ include file="A_CP_Header.jsp" %>
    <!-- END HEADER-->

	<div class="page-wrapper">
	    <!-- PAGE CONTENT-->
	    <div class="page-content--bgf7">
	        <section class="py-4">
	            <div class="container-fluid">
	                
	                <div class="row mb-5">
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 mb-3">
	                        <h6 class="mb-md-0 text-uppercase"><img src="NewPortalAssets/assets/images/icons/invoice.png" width="40px" alt=""> Open Invoices</h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
	                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-invoice display-4"></i>
	                                </div>
	                                <div class="bg-white p-2 w-100">
	                                    <p class="mb-1">Open Invoices</p>
	                                    <h3 class="mb-0"><%=openInvoiceTileData %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
	                        <div class="card rounded-0 bg-danger-subtle border-0">
	                            <div
	                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
	                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
	                                    <i class="icon-invoice display-4"></i>
	                                </div>
	                                <div class="bg-white p-2 w-100">
	                                    <p class="mb-1">Open Amount</p>
	                                    <h3 class="mb-0">$<%=df.format(openAmountTotal) %></h3>
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                </div>
	                
	                <% if(listData != null && listData.size()>0){ %>
	                <div class="row">
	                    <div class="col-md-12">
                            <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive" id="table-div" >
	                                <table id="OpenInvoicesTable" class="table border border-top-0 table-grid tab-Table" role="grid" width="100%" aria-describedby="datatable-example_info" >
	                                    <thead>
	                                        <tr>
		                                    	<th align="center" width="2%"></th>
		                                    	<th align="center" width="">Branch</thh>
	                                            <th align="center" width="">Tran#</th>
	                                            <th align="center" width="">Ship#</th>
	                                            <th align="center" width="">Invoice Date</th>
	                                            <th align="center" width="">Name</th>
	                                            <th align="center" width="60%">Ship To</th>
	                                            <th align="center" width="">Cust Po</th>
	                                            <th align="center" width="">Type</th>
	                                            <th align="center" width="">Invoice Amt</th>
	                                            <th align="center" width="">Open Amt</th>
	                                            <th align="right" width="">Discount</th>
	                                            <th align="right" width="">Dis Date</th>
	                                            <th align="right" width="">Due Date</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<%  
												for(int i=0;i<listData.size();i++){
													HashMap map=(HashMap)listData.get(i);
											%>
												<tr class="tr-shadow">
													<td align="center"><a href="javascript:getInvoiceList('<%=map.get("soId")%>','<%=map.get("shipmentNum")%>')" class="btn btn-outline-danger btn-sm"><i class="icon-download"></i> PDF</a></td>
													<td align="left"><%=map.get("refNumSysId")%></td>
													<td align="left"><%=map.get("soId")%></td>
													<td align="left"><%=map.get("shipmentNum")%></td>
													<td align="left" nowrap><%=map.get("invoiceDate")%></td>
													<td align="left"><%=map.get("custName")%></td>
													<td align="left"><%=map.get("shipTo")%></div></td>
													<td align="left"><%=map.get("custPo")%></td>
													<td align="left"><%=map.get("refType")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("amount").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("openAmt").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("discountAmountOpen").toString()))%></td>
													<td align="left" nowrap><%=map.get("discountDate")%></td>
													<td align="left" nowrap><%=map.get("dueDate")%></td>
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


	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->

	<script type="text/javascript">
	
		/* $(document).ready(function(){
		    $('li').click(function(event){
		        //remove all pre-existing active classes
		        $('.has-sub').removeClass('has-sub');
	
		        //add the active class to the link we clicked
		        $(this).addClass('has-sub');     
		        event.preventDefault();
		    });
		}); */
	
	
		/* $(document).ready(function(){
			$(".list-unstyled").click(function(){
				$(this).css('background', 'red');
			});
		}); */
	
		/* var make_button_active = function(){
	    	var siblings =($(this).siblings());
		    siblings.each(function (index){
	      		$(this).removeClass('has-sub');
	    	})
		    $(this).addClass('has-sub');
		}

		$(document).ready(function(){
	    	$(".list-unstyled li").click(make_button_active);
	  	}); */
	
	/*     $(document).ready(function() {
	        $(function() {
	            $( "#my_date_picker" ).datepicker();
	        });
	    }) */
			
	    var orderId,shipmentId;
		var id,today ;
		var fromDate = '${requestScope.fromDate}';
		var toDate = '${requestScope.toDate}';
	
		$(document).ready(function(){
	  		//debugger;
	
	  		//hideDateFilter();
	  		
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			today = mm + '-' + (dd) + '-' + now.getFullYear();
			
			dateFunction(fromDate,toDate);
	
			$('#datepicker1,#datepicker2').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				maxDate: "0",
			});

			
			$('#OpenInvoicesTable').DataTable({
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
				/* 'scrollY': "60vh",
				'scrollX': true,
				'scrollCollapse': true, 
				'paging': true, 
				'autoWidth': false */
			});
			
			//applyFilterForTodayData();
			
			$('#closeModalPrimary').click(function() {
			    $('#modal').modal('hide');
			});
	
			$('#closeModalSecondry').click(function() {
			    $('#modal').modal('hide');
			});
	
			$('#emailButton').click(function() {
				sendEmail();
			});
			
		    $('a').click(function(){
		        $('a').removeClass("active");
		        $(this).addClass("active");
		    });
			
		$('.dataTables_filter input').attr('placeholder', 'Search items...');
		}); 	
	
	  	function dateFunction(fromDate,toDate){
	  		if(fromDate == "" || fromDate == null || toDate == "" || toDate==null){
				$('#datepicker1').val(today);
				$('#datepicker2').val(today);
	  		}
	  	}
	
	   	
	   	function popupForViewOrderDeliveryImage(orderNo,shipmentNo){
	   		orderId = orderNo;
	   		shipmentId = shipmentNo;
	   		popupForViewOrderDeliveryNotes(orderNo,shipmentNo);
	  		populateEmailAddress(orderNo);
			$.ajax({
			 	url:"../so/OrderDeliveryImageSearchBySimpleJDBC.jsp?param=fetchImages&orderNo="+orderNo+"&shipmentNo="+shipmentNo,
				type : "POST",
				dataType: "text",
				success: function (response) {
					$('#imageList').html(response);
				},
			 	failure: function (response) {
			    }
			});
			$('#modal').modal('show');
		}
	
	   	function popupForViewOrderDeliveryNotes(orderNo,shipmentNo){
			$('#notesTable tbody').empty();
			$.ajax({
				url : "../so/A_SOOrderDeliveryNotes.jsp?param=fetchNotes&orderNo="+orderNo+"&shipmentNo="+shipmentNo,
				type : 'POST',
				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.NotesList;
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
							var notesRow = '<tr>'+
												'<td align="center"><b>'+(++key)+'</b></td>'+
												'<td align="center">&nbsp;</td>'+
												'<td align="center"><b>:</b></td>'+
												'<td align="center">&nbsp;</td>'+
												'<td align="center">'+row.notes+'</td>'+
						   				   '</tr>';
							$('#notesTable').append(notesRow);
						});
		        	}
		        },
				failure: function (response) {
				}
			});
		 	//$('#modal').modal('show'); 	
	   	}
	
	   	
	 	function populateEmailAddress(orderNo) {
	 		$.ajax({
 				url:"../customerPortal/CustomerDeliveryAction.jsp?param=PopulateEmail&orderNo="+orderNo,
 				type : "POST",
 				dataType: "text",
 				success: function (response) {
 					$('#emailNameId').val(response);
 				},
 			 	failure: function (response) {
 			    }
 			});
		}

	  	function hideDateFilter(){
	  		document.getElementById("dateDiv").style.display = "none";
	  	}

		function applyFilter(){
			var timeValue = document.getElementById('time').value;
			if (timeValue == "Custom" ) {
			    document.getElementById("dateDiv").style.display = "";
			}
			else {
				//hideDateFilter();
				document.getElementById("dateDiv").style.display = "none";
				window.location = "../customerPortal/CustomerDelivery.jsp?timeValue="+timeValue;
			}
		}
		
		function submitForm() {
			var timeValue = document.getElementById('time').value;
			var fromDate = document.getElementById('datepicker1').value;
			var toDate = document.getElementById('datepicker2').value;
			if (fromDate == "" || fromDate == null) {
				alert("Please select from date");
				return false;
			}
			else if (toDate == "" || toDate == null) {
				alert("Please select to date");
				return false;
			}
			else {
				window.location = "../customerPortal/CustomerDelivery.jsp?timeValue="+timeValue+"&fromDate="+fromDate+"&toDate="+toDate;
			} 
		}
    
	   	function getInvoiceList(orderNo,shipmentNo){
	   		debugger;
	   		$.ajax({
			 	url:"../customerPortal/A_CP_OpenInvoicesAction.jsp?param=GetInvoices&orderNo="+orderNo+"&shipmentNo="+shipmentNo,
				type : "POST",
				dataType: "text",
				success: function (response) {
					window.open(response.toString(), "_blank");
				},
			 	failure: function (response) {
			    }
			});
	   	}
		
		/* function exit2(){
			parent.location='/index.htm?actionCode=Logout';
		} */

		/* function exit2(){
			parent.location='/login?actionCode=Logout';
		} */
		
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}

	   	
	</script>


<%!

	public ArrayList<HashMap<String, String>> getOpenInvoiceData(String custKey) {	
		String sqlQuery="",filterString = "",orderNo="",shipmentNo="",invoiceFilePath="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct ar.REF_NUM_SYSID, "
							+" case when to_char(ar.tran_id)='0' then ar.ref_num else to_char(ar.tran_id)  end  as so_id, "
							+" ar.shipment_num,ao.REF_DATE as invoice_date, "
							+" sa.cust_name, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as ship_to, sh.CUST_PO, "
							+" ar.ref_type, ar.amount,ar.open_amt,ar.DISCOUNT_AMOUNT,ar.DISCOUNT_AMOUNT_OPEN, ar.DISCOUNT_DATE, ar.due_date "
							+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa, aropen ao " 
							+" where ar.TRAN_ID=sh.so_id(+) "
							+" and ar.TRAN_ID=sa.TRAN_ID(+) "
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
				            +" and ar.open_amt=ao.open_amt "
							+" and ar.open_amt!=0 " 
							+" and ar.ref_type in ('IN','CM','DM','FC','CI') and ar.cust_key='"+custKey+"' "
							+" order by ao.REF_DATE desc";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector refNumSysIdVector = new Vector();
			Vector soIdVector = new Vector();
			Vector shipmentNumVector = new Vector();
			Vector invoiceDateVector = new Vector();
			Vector custNameVector = new Vector();
			Vector shipToVector = new Vector();
			Vector custPoVector = new Vector();
			Vector refTypeVector = new Vector();
			Vector amountVector = new Vector();
			Vector openAmtVector = new Vector();
			Vector discountAmountVector = new Vector();
			Vector discountAmountOpenVector = new Vector();
			Vector discountDateVector = new Vector();
			Vector dueDateVector = new Vector();
			if (ht != null && ht.size() > 0) {
				refNumSysIdVector = (Vector) ht.get("REF_NUM_SYSID");
				soIdVector = (Vector) ht.get("SO_ID");
				shipmentNumVector = (Vector) ht.get("SHIPMENT_NUM");
				invoiceDateVector = (Vector) ht.get("INVOICE_DATE");
				custNameVector = (Vector) ht.get("CUST_NAME");
				shipToVector = (Vector) ht.get("SHIP_TO");
				custPoVector = (Vector) ht.get("CUST_PO");
				refTypeVector = (Vector) ht.get("REF_TYPE");
				amountVector = (Vector) ht.get("AMOUNT");
				openAmtVector = (Vector) ht.get("OPEN_AMT");
				discountAmountVector = (Vector) ht.get("DISCOUNT_AMOUNT");
				discountAmountOpenVector = (Vector) ht.get("DISCOUNT_AMOUNT_OPEN");
				discountDateVector = (Vector) ht.get("DISCOUNT_DATE");
				dueDateVector = (Vector) ht.get("DUE_DATE");
			}
	        if (refNumSysIdVector.size() > 0) {
	        	for (int i = 0; i < refNumSysIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("refNumSysId", refNumSysIdVector.get(i).toString());
					temp.put("soId", soIdVector.get(i).toString());
					temp.put("shipmentNum", shipmentNumVector.get(i).toString());
					temp.put("invoiceDate", invoiceDateVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("shipTo", shipToVector.get(i).toString());
					temp.put("custPo", custPoVector.get(i).toString());
					temp.put("refType", refTypeVector.get(i).toString());
					temp.put("amount", amountVector.get(i).toString());
					temp.put("openAmt", openAmtVector.get(i).toString());
					temp.put("discountAmount", discountAmountVector.get(i).toString());
					temp.put("discountAmountOpen", discountAmountOpenVector.get(i).toString());
					temp.put("discountDate", discountDateVector.get(i).toString());
					temp.put("dueDate", dueDateVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}


	public String getOpenInvoiceTileData(String custKey){	
		String sqlQuery="",filterString = "",openInvoices="";
		try {
			DistUtils du = new DistUtils();
			/* sqlQuery = "select count(distinct case when to_char(ar.tran_id)='0' then ar.ref_num else to_char(ar.tran_id) end) as TOTAL_INVOICES "
						+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa "
						+" where ar.TRAN_ID=sh.so_id(+) "
						+" and ar.TRAN_ID=sa.TRAN_ID(+) "
						+" and ar.open_amt!=0 "
						+" and ar.ref_type in ('IN','CM','DM','FC','CI') "
						+" and ar.ref_num not like ( 'AD-%') "
						+" and ar.cust_key='"+custKey+"' "; */
						
			sqlQuery = "select count(*) as TOTAL_INVOICES "
						+" from aropendt ar, aropen ao, cust cu "
						+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') "
						+" and ar.cust_key=ao.cust_key "
						+" and ar.REF_NUM=ao.REF_NUM "
						+" and ar.cust_key=cu.cust_key "
			            		+" and ar.open_amt=ao.open_amt "
						+" and ar.open_amt!=0 "
						+" and ar.cust_key='"+custKey+"' ";			
 
			Utils.log("Query >>>>>> "+sqlQuery);
			openInvoices=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return openInvoices;
	}

	
	public String getOpenAmountTileData(String custKey){	
		String sqlQuery="",filterString = "",OpenAmount="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select sum(ar.open_amt) as OPEN_AMOUNT "
						+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa, aropen ao, cust cu "						
						+" where ar.TRAN_ID=sh.so_id(+) "
						+" and ar.TRAN_ID=sa.TRAN_ID(+) "
						+" and ar.cust_key=ao.cust_key "
						+" and ar.REF_NUM=ao.REF_NUM "
						+" and ar.cust_key=cu.cust_key "
						+" and ar.open_amt=ao.open_amt "
						+" and ar.open_amt!=0 " 
						+" and ar.ref_type in ('IN','CM','DM','FC','CI','CA') "
						+" and ar.cust_key='"+custKey+"' "; 
 
			Utils.log("Query >>>>>> "+sqlQuery);
			OpenAmount=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return OpenAmount;
	
	}

%>
