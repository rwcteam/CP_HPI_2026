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

	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);

	String yearValue = request.getParameter("year");
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	
	String year="";
	ArrayList<HashMap<String, String>> yearList = getYearList();
	for (int i=0; i< yearList.size();i++){
		HashMap mapData = (HashMap)yearList.get(i);
		if(!mapData.get("invoiceYear").toString().equalsIgnoreCase("NA")){
			year+="<option value='"+mapData.get("invoiceYear")+"'>"+mapData.get("invoiceYear")+"</option>";
		}
	}

	List<HashMap<String, String>> listData = getPastInvoices(custKey,yearValue);

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
	    <div class="page-content--bgf7">
	        <section class="py-4">
	            <div class="container-fluid">
	                <div class="row mb-2 justify-content-between">
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 mb-3">
	                        <h6 class="mb-4 text-uppercase"><img src="NewPortalAssets/assets/images/icons/invoice.png" width="40px" alt="" /> Past Invoices</h6>
	                    </div>
	                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
	                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
	                    </div>
	                </div>
	                <div class="row">
	                    <div class="col-md-3 mb-3">
	                        <form name="PastInvoiceForm" id="PastInvoiceForm" action="" method="post" class="align-items-center d-flex">
		                        <label class="text-nowrap m-0 mr-2">Filter:</label>
		                        <select name="year" id="year" class="form-control form-control-sm">
		                            <%if(yearValue==null || yearValue.equals("")){%>
										<option value="" selected="">Filter By Year</option>
									<%}else{%>
										<option value="<%=yearValue%>" selected><%=yearValue%></option>
									<%}%>
									<%=year%>
		                        </select>
		                        <button type="button" class="btn btn-danger btn-sm ml-2" onclick="getDataByYear()">Filter</button>
	                    	</form>
	                    </div>
	                    
	                    <div class="col-md-12">
	                        <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive">
	                                <table id="PastInvoicesTable"
	                                    class="table border border-top-0 table-grid tab-Table" role="grid"
	                                    width="100%" aria-describedby="datatable-example_info">
	                                    <thead>
	                                        <tr>
	                                           	<th align="center" width=""></th>
		                                    	<th align="center" width="">Branch</thh>
	                                            <th align="center" width="">Tran#</th>
	                                            <th align="center" width="">Ship#</th>
	                                            <th align="center" width="">Invoice Date</th>
	                                            <th align="center" width="">Name</th>
	                                            <th align="center" width="">Ship To</th>
	                                            <th align="center" width="">Cust Po</th>
	                                            <th align="center" width="">Type</th>
	                                            <th class="text-align-right" width="">Invoice Amt</th>
	                                            <th class="text-align-right" width="">Discount</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
	                                        <%
	                                        	if(listData != null && listData.size()>0){
													for(int i=0;i<listData.size();i++){
														HashMap map=(HashMap)listData.get(i);
											%>
		                                        <tr>
	                                        		<td align="center"><a href="javascript:getInvoiceList('<%=map.get("soId")%>','<%=map.get("shipmentNum")%>')" class="btn btn-outline-danger btn-sm"><i class="icon-download"></i> PDF</a></td>
													<td align="left"><%=map.get("refNumSysId")%></td>
													<td align="left"><%=map.get("soId")%></td>
													<td align="left"><%=map.get("shipmentNum")%></td>
													<td align="left" nowrap><%=map.get("invoiceDate")%></td>
													<td align="left"><div style="width:250px"><%=map.get("custName")%></div></td>
													<td align="left"><div style="width:350px"><%=map.get("shipTo")%></div></td>
													<td align="left"><%=map.get("custPo")%></td>
													<td align="left"><%=map.get("refType")%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("amount").toString()))%></td>
													<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("discountAmount").toString()))%></td>
		                                        </tr>
	                                        <%}}else{%>
	                                        	<tr>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"><div style="width:200px">Data Does Not Exist</div></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
	                                        		<td align="center"></td>
		                                        </tr>
	                                        <%}%>
	                                    </tbody>
	                                </table>
	                            </div>
	                        </div>
	                    </div>
	                </div>
	            </div>
	        </section>
	    </div>
	</div>

	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->

	<script type="text/javascript">
			
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

			
			$('#PastInvoicesTable').DataTable({
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

 		function sendEmail(){
 			var emailId = $('#emailNameId').val();
 			$.ajax({
 			 	url:"../customerPortal/CustomerDeliveryAction.jsp?param=SendEmail&emailId="+emailId+"&orderNo="+orderId+"&shipmentNo="+shipmentId ,
 				type : "POST",
 				dataType: "text",
 				success: function (response) {
 					alert("Email has been sent");
 					$('#message').html(response);
 				},
 			 	failure: function (response) {
 			    }
 			});
 		}

	 	
		window.addEventListener('DOMContentLoaded', function () {
		    	var galley = document.getElementById('galley');
		       	var viewer;
	
		       	$('#modal').on('shown.bs.modal', function (e) {
		        	// WARNING: should ignore Viewer's `shown` event here.
		         	if(e.namespace === 'bs.modal') {
		           		viewer = new Viewer(galley, {
		             		url: 'data-original',
		           		});
		         	}
		       	}).on('hidden.bs.modal', function (e) {
		        	// WARNING: should ignore Viewer's `hidden` event here.
		        	if(e.namespace === 'bs.modal') {
	  	        	viewer.destroy();
			        }
		    	});
		     });
	
		function closeModal(){
			$('#modal').modal('hide');
		}
	   	
	  	function hideDateFilter(){
	  		document.getElementById("dateDiv").style.display = "none";
	  	}

		/* window.onload = function() {
			submitForm();
		}; */
	  	
 		/* function applyFilterForTodayData(){
			window.location = "../customerPortal/CustomerDeliveryAction.jsp";
		} */
		
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
	   	
	   	
		function getDataByYear(){
			debugger;
			var year = document.getElementById('year').value;
			if(year == "" || year == null ){
				alert("Please select year");
				return false;
			}
			else{
				document.PastInvoiceForm.action="../customerPortal/A_CP_PastInvoices.jsp?pageName=PastInvoices&year="+year;
				document.PastInvoiceForm.submit();	        
			}
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

	public ArrayList<HashMap<String, String>> getPastInvoices(String custKey,String yearValue) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			if(yearValue==null || yearValue.equals(""))
				filterString=" and to_date(ao.REF_DATE)>=sysdate-90 ";
			else
				filterString=" and extract(YEAR from ao.REF_DATE) = "+yearValue+" ";
			
			
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct ar.REF_NUM_SYSID, "
							+" case when to_char(ar.tran_id)='0' then ar.ref_num else to_char(ar.tran_id)  end  as so_id, "
							+" ar.shipment_num,ao.REF_DATE as invoice_date, " 
							+" sa.cust_name, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as ship_to, sh.CUST_PO, "
							+" ar.ref_type, ar.amount,ar.DISCOUNT_AMOUNT "
							+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa, aropen ao " 
							+" where ar.TRAN_ID=sh.so_id(+) "
							+" and ar.TRAN_ID=sa.TRAN_ID(+) "
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
				            +" and ar.open_amt=ao.open_amt "
							+" and ar.open_amt=0 " 
							+" and  ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.cust_key='"+custKey+"' " +filterString 
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
			Vector discountAmountVector = new Vector();
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
				discountAmountVector = (Vector) ht.get("DISCOUNT_AMOUNT");
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

	public ArrayList<HashMap<String, String>> getYearList() {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			//String query = " select DISTINCT(extract(YEAR from CREATED_DATE)) as CREATED_DATE  from aropendt ORDER BY CREATED_DATE ";
			String query = " select DISTINCT NVL(TO_CHAR(extract(YEAR from REF_DATE)),'NA') as INVOICE_YEAR from aropen ORDER BY INVOICE_YEAR desc";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoiceYearVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoiceYearVector = (Vector) ht.get("INVOICE_YEAR");
			}
	        if (invoiceYearVector.size() > 0) {
	        	for (int i = 0; i < invoiceYearVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoiceYear", invoiceYearVector.get(i).toString());
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
