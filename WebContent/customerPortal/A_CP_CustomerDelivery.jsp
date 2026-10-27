<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>

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
	String standardDateFormat = (String)session.getAttribute("standardDateFormat");
	String timeValue = request.getParameter("timeValue");
	if (timeValue == null || timeValue.equals("") || timeValue.equalsIgnoreCase("today")) 
		timeValue="Today";
	String fromDate = request.getParameter("fromDate");
	if (fromDate == null || fromDate.equals("")) 
		fromDate="";
	String toDate = request.getParameter("toDate");
	if (toDate == null || toDate.equals("")) 
		toDate="";
	
	
	Utils u = new Utils();
	String applet = "";
	String message = "";
	String sqlQuery = "";
	
	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	
	String tileDataToday = getTileDataToday(customerId);
	String tileDataMonth = getTileDataMonth(customerId);
	
	List<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
	/* if(timeValue.equalsIgnoreCase("today")){
		listData = getCustomerDataToday(customerId);
	}
	else{
		listData = getCustomerData(customerId,timeValue,fromDate,toDate,standardDateFormat);
	} */
	
	listData = getCustomerData(customerId,timeValue,fromDate,toDate,standardDateFormat);
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
</style>

<div class="page-wrapper">
    <!-- PAGE CONTENT-->
    <div class="page-content--bgf7">
        <section class="py-4">
            <div class="container-fluid">
                <div class="row mb-5">
                   <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 mb-3">
                        <h6 class="mb-4 text-uppercase"><img src="NewPortalAssets/assets/images/icons/assigned-deliveries.png" width="40px" class="" alt="" />&nbsp; Assigned Deliveries</h6>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div
                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-fast-delivery display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <p class="mb-1">Today's Deliveries</p>
                                    <h3 class="mb-0"><%=tileDataToday%></h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div
                                class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-fast-delivery display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <p class="mb-1">Current Month Deliveries</p>
                                    <h3 class="mb-0"><%=tileDataMonth%></h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-3 mb-4 d-sm-flex">
                        <p class="m-0 mr-2">Filter:</p>
                        <div>
 	                       <div class="btn-group btn-group-toggle w-100 overflow-auto" data-toggle="buttons">                            
                                <%if(timeValue.trim().equalsIgnoreCase("Today")){%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100 active" id="label1">
	                                    <input type="radio" name="time" id="todayRadio" value="Today" onchange="applyFilter()"  autocomplete="off" checked> Today
	                                </label>
	                            <%}else{%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100" id="label1">
	                                    <input type="radio" name="time" id="todayRadio" value="Today" onchange="applyFilter()"  autocomplete="off" checked> Today
	                                </label>
	                            <%}if(timeValue.trim().equalsIgnoreCase("ThreeDays")){%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100 active" id="label2">
	                                    <input type="radio" name="time" id="threeDaysRadio" value="ThreeDays" onchange="applyFilter()" autocomplete="off"> Last 3 Days
	                                </label>
	                            <%}else{%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100" id="label2">
	                                    <input type="radio" name="time" id="threeDaysRadio" value="ThreeDays" onchange="applyFilter()" autocomplete="off"> Last 3 Days
	                                </label>
	                            <%}if(timeValue.trim().equalsIgnoreCase("OneWeek")){%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100 active" id="label3">
	                                    <input type="radio" name="time" id="oneWeekRadio" value="OneWeek" onchange="applyFilter()" autocomplete="off"> A Week ago
	                                </label>
	                            <%}else{%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100" id="label3">
	                                    <input type="radio" name="time" id="oneWeekRadio" value="OneWeek" onchange="applyFilter()" autocomplete="off"> A Week ago
	                                </label>
	                            <%}if(timeValue.trim().equalsIgnoreCase("Custom")){%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100 active" id="label4">
	                                    <input type="radio" name="time" id="customRadio" value="Custom" onchange="applyFilter()" autocomplete="off"> Date Range
	                                </label>
	                           	<%}else{%>
	                                <label class="btn btn-sm btn-outline-danger rounded-0 w-100" id="label4">
	                                    <input type="radio" name="time" id="customRadio" value="Custom" onchange="applyFilter()" autocomplete="off"> Date Range
	                                </label>
	                           	<%}%>
                            </div>
                            <div class="daterange d-none">
                                <div class="d-sm-flex mt-3">
                                    <div class="form-group d-flex align-items-center mr-sm-1 mb-sm-0">
                                        <input type="text" name="fromDate" id="datepicker1" value="<%=fromDate%>" placeholder="Start Date" value="" class="form-control form-control-sm">
                                    </div>
                                    <div class="form-group d-flex align-items-center mr-sm-1 mb-sm-0">
                                        <input type="text" name="toDate" id="datepicker2" value="<%=toDate%>" placeholder="End Date" value="" class="form-control form-control-sm">
                                    </div>
                                    <button class="btn btn-danger btn-sm" onClick="submit()">Filter</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div id="showRecordDataTable" class="tabcontent">                            
                            <table id="CustomerDeliveryTable"
                                class="table border border-top-0 table-grid tab-Table" role="grid"
                                width="100%" aria-describedby="datatable-example_info">
                                <thead>
                                    <tr>
                                       	<th align="center" width="4%">Order#</thh>
	                                	<th align="center" width="4%">Shipment#</th>
	                                    <th align="center" width="12%">Exp Delivery date</th>
	                                    <th align="center" width="10%">Ship via</th>
	                                    <!-- <th align="center" width="4%">Whse</th> -->
	                                    <th align="center" width="20%">Ship To Name</th>
	                                    <th align="center" width="25%">Ship To Address</th>
	                                    <th align="center" width="8%">City</th>
	                                    <th align="center" width="3%">State</th>
	                                    <th align="center" width="3%">Zip</th>
	                                    <th align="center" width="7%">Status</th>
	                                    <th align="right" width="4%">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                	<%
	                                   	if(listData != null && listData.size()>0){
											for(int i=0;i<listData.size();i++){
												HashMap map=(HashMap)listData.get(i);
									%>
	                                	<tr class="tr-shadow">
											<td align="left"><%=map.get("soId")%></td>
											<td align="left"><%=map.get("shipmentNum")%></td>
											<td align="left"><%=map.get("expDeliveryDate")%></td>
											<td align="left"><%=map.get("shipVia")%></td>
											<!-- <td align="left"></td> -->
											<td align="left"><%=map.get("custName")%></td>
											<td align="left"><%=map.get("address1")%></td>
											<td align="left"><%=map.get("city")%></td>
											<td align="left"><%=map.get("state")%></td>
											<td align="left"><%=map.get("zip")%></td>
											<%if(map.get("status").toString().equalsIgnoreCase("Delivered")){%>
												<td align="left"><span class="bg-success-subtle p-1 px-2 rounded-lg text-nowrap rounded-pill"><%=map.get("status")%></span></td>
											<%}else{%>
												<td align="left"><span class="bg-warning-subtle p-1 px-2 rounded-lg text-nowrap rounded-pill"><%=map.get("status")%></span></td>
											<%}%>
											<%if(map.get("status").toString().equalsIgnoreCase("Delivered")){%>
												<td align="center"><button class="btn btn-outline-danger btn-sm d-flex align-items-center" title="View" data-toggle="modal" data-target="#ImageGalleryModal" 
																			onclick="popupForViewOrderDeliveryImage('<%=map.get("soId")%>','<%=map.get("shipmentNum")%>')"><i class="icon-visible fs-1 mr-2"></i> View</button></td>
											<%}else{%>
												<td align="center">-</td>
											<%}%>
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
        </section>
    </div>
</div>


<div class="modal" id="ImageGalleryModal" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="ImageGalleryModalTitle" aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered modal-xl" role="document">
    	<div class="modal-content rounded-0">
      		<div class="modal-header">
        		<h5 class="modal-title" id="ImageGalleryModalTitle"><img src="NewPortalAssets/assets/images/icons/gallery.png" width="30px" alt=""> Gallery</h5>
        		<a href="javascript:void(0)" class="close small opacity-100 text-dark" data-dismiss="modal" aria-label="Close"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		<div class="row">
            		<div class="col-md-8 d-flex mb-3">
                		<!-- <p class="bg-warning-subtle p-2 d-flex w-100 m-0"><span class="text-danger font-weight-bold pr-2 d-flex rounded-lg">Note:</span> Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.</p> -->
                		<div class="modal-body">
            				<table id="NotesTable">
				          		<tbody>
				          		</tbody>
				      		</table>
          				</div>
            		</div>
            		<div class="col-md-4 mb-3">
                		<form>
                    		<div class="form-group">
                        		<input type="text" class="form-control" name="email" id="email" placeholder="Email Address">
                    		</div>
                    		<button type="button" class="btn btn-danger w-100" onclick="sendEmail()">Send</button>
                		</form>
            		</div>
        		</div>
        		<div id="gallery">
            			<ul class="pictures" id="imageList"></ul>
        		</div>  
    		</div>
    	</div>
  	</div>
</div>


<!-- START FOOTER-->
<%@ include file="A_CP_Footer.jsp" %>
<!-- END FOOTER-->


	<script type="text/javascript">
	
	/*     $(document).ready(function() {
	        $(function() {
	            $( "#my_date_picker" ).datepicker();
	        });
	    }) */
			
	    var orderId,shipmentId;
		var id,today ;
		var fromDate = '<%=fromDate%>';
		var toDate = '<%=toDate%>';
		var timeValue = '<%=timeValue%>'
		
		$(function() {
			debugger;
			
			if(timeValue == 'Custom')
				$("#dateDiv").show();
			else 
				$("#dateDiv").hide();
	  		
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

			
			$('#CustomerDeliveryTable').DataTable({
				'pageLength': 25,
				"aaSorting": [[ 2, "desc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            /* 'copy', 'csv', 'excel' */
			            /*'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5'*/
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
				'bDestroy': true,
				'scrollY': "50vh",
				'scrollX' : true,
				'scrollCollapse': true
			});
			
			//applyFilterForTodayData();
			
			$('#closeModalPrimary').click(function() {
			    $('#modal').modal('hide');
			});
	
			$('#closeModalSecondry').click(function() {
			    $('#modal').modal('hide');
			});
	
			/* $('#emailButton').click(function() {
				sendEmail();
			}); */
			
		    $('a').click(function(){
		        $('a').removeClass("active");
		        $(this).addClass("active");
		    });
			
			
	        $('input[name="time"]').change(function () {
	            if ($('#customRadio').is(':checked')) {
	                $('.daterange').removeClass('d-none');
	            } else {
	                $('.daterange').addClass('d-none');
	            }
	        });
			
			/* const radios = document.querySelectorAll('input[name="time"]');
			radios.forEach(radio => {
			    radio.addEventListener('change', () => {
			        radios.forEach(r => r.parentElement.classList.remove('active'));
			        if (radio.checked) {
			            radio.parentElement.classList.add('active');
			        }
			    });
			}); */

			var viewer;
		    $('#ImageGalleryModal').on('shown.bs.modal', function (e) {
		        if (e.namespace === 'bs.modal') {
		            // Wait for a short delay to ensure DOM update/render
		            setTimeout(function () {
		                viewer = new Viewer(document.getElementById('gallery'), {
		                    //url: 'data-original',
		                    url: 'src',
		                });
		            }, 100); // Adjust delay as needed
		        }
		    });
		
			$('.dataTables_filter input').attr('placeholder', 'Search items...');
		});	

	  	function dateFunction(fromDate,toDate){
	  		if(fromDate == "" || fromDate == "null" || toDate == "" || toDate == "null"){
				$('#datepicker1').val(today);
				$('#datepicker2').val(today);
	  		}
	  	}
	
	   	function popupForViewOrderDeliveryImage(orderNo,shipmentNo){
	   		debugger;
	   		orderId = orderNo;
	   		shipmentId = shipmentNo;
	   		popupForViewOrderDeliveryNotes(orderNo,shipmentNo);
	  		populateEmailAddress(orderNo);
			$.ajax({
			 	url:"../so/OrderDeliveryImageSearchBySimpleJDBC.jsp?param=FetchImages&orderNo="+orderNo+"&shipmentNo="+shipmentNo,
				type : "POST",
				dataType: "text",
				success: function (response) {
					$('#imageList').html(response);
				},
			 	failure: function (response) {
			    }
			});
		}
	
	   	function popupForViewOrderDeliveryNotes(orderNo,shipmentNo){
			$('#NotesTable tbody').empty();
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
							$('#NotesTable').append(notesRow);
						});
		        	}
		        },
				failure: function (response) {
				}
			});
	   	}
	
	   	
	 	function populateEmailAddress(orderNo) {
	 		$.ajax({
 				url:"../so/A_SOOrderDeliveryNotes.jsp?param=PopulateEmail&orderNo="+orderNo,
 				type : "POST",
 				dataType: "text",
 				success: function (response) {
 					$('#email').val(response);
 				},
 			 	failure: function (response) {
 			    }
 			});
		}

 		function sendEmail(){
 			debugger;
			var result = window.confirm('Want to send email?');
			if(result){
	 			var emailId = $('#email').val();
				if(emailId == "" || emailId == null ){
					alert("Please Enter Email Address");
					return false;
				}
				else{
		 			$.ajax({
		 			 	url:"../so/A_SOOrderDeliveryImageEmail.jsp?param=SendEmail&emailId="+emailId+"&orderNo="+orderId+"&shipmentNo="+shipmentId ,
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
				return true;			
			} 
			else
				return false;			
 		}
	
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
			window.location = "../customerPortal/A_CP_CustomerDeliveryAction.jsp";
		} */
		
		function applyFilter() {
			debugger;
			//var timeValue = document.getElementById('time').value;
			//var timeValue = document.getElementsByName('time').value;
			var timeValue = document.querySelector('input[name="time"]:checked').value;
			if (timeValue != "Custom" ) {
				window.location = "../customerPortal/A_CP_CustomerDelivery.jsp?pageName=DeliveryImages&timeValue="+timeValue;
			}			
		}
		
		function submit(){
			debugger;
			var timeValue = document.querySelector('input[name="time"]:checked').value;
			if (timeValue == "Custom" ){
				var fromDate = document.getElementById('datepicker1').value;
				var toDate = document.getElementById('datepicker2').value;
				if (fromDate == "" || fromDate == null) {
					alert("Please Select Start Date");
					return false;
				}
				else if (toDate == "" || toDate == null) {
					alert("Please Select End Date");
					return false;
				}
				else {
					window.location = "../customerPortal/A_CP_CustomerDelivery.jsp?pageName=DeliveryImages&timeValue="+timeValue+"&fromDate="+fromDate+"&toDate="+toDate;
				} 
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

		
		/* window.addEventListener('DOMContentLoaded', function () {
	    	var gallery = document.getElementById('gallery');
	       	var viewer;

	       	$('#ImageGalleryModal').on('shown.bs.modal', function (e) {
	        	// WARNING: should ignore Viewer's `shown` event here.
	         	if(e.namespace === 'bs.modal') {
	           		viewer = new Viewer(gallery, {
	             		//url: 'data-original',
	           			url: 'src',
	           		});
	         	}
	       	}).on('hidden.bs.modal', function (e) {
	        	// WARNING: should ignore Viewer's `hidden` event here.
	        	if(e.namespace === 'bs.modal') {
  	        	viewer.destroy();
		        }
	    	});
	     }); */

	     /* document.addEventListener("DOMContentLoaded", function () {
	         const gallery = document.getElementById('gallery');
	         if (gallery && typeof Viewer === 'function') {
	         	new Viewer(gallery);
	         } else {
	         	console.error("Viewer.js not loaded or #galley not found.");
	         }
	     }); */
	     
	</script>

<%!

	public ArrayList<HashMap<String, String>> getCustomerDataToday(String customerId) {	
		String sqlQuery="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			
			sqlQuery = "select  to_char(sh.EXPECT_DATE,'MM-DD-YYYY') as exp_delivery_date , SH.ROUTE_ID_CHAR, SH.STOP, so.SHIP_VIA,sh.driver, "
						+" sh.so_id, sh.SHIPMENT_NUM,SO.SALE_TYPE, cu.cust_code, sa.CUST_NAME, sa.ADDRESS_1, sa.ADDRESS_2, sa.city,sa.state, sa.ZIP " 
						+" from shipments_header sh, so_header so, SHIP_TO_ADDRESS sa, cust cu "
						+" where SO.SO_ID=SH.SO_ID AND sh.so_id=sa.TRAN_ID and sa.shipment_num=(select max(shipment_num) from SHIP_TO_ADDRESS sa1 where sa1.tran_id=sh.so_id) "
						+" and sh.cust_guid=cu.cust_guid and sa.type='SO' and so.ship_via not in ('CSTMR PICKUP','CPU RWC','CPU DIRECT') and cu.cust_code='"+customerId+"' " 
						+" and sh.EXPECT_DATE=TO_CHAR(CURRENT_DATE, 'dd-mon-yyyy')  ";
	
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector expDeliveryDateVector = new Vector();
			Vector routeIdCharVector = new Vector();
			Vector stopVector = new Vector();
			Vector shipViaVector = new Vector();
			Vector driverVector = new Vector();
			Vector soIdVector = new Vector();
			Vector shipmentNumVector = new Vector();
			Vector saleTypeVector = new Vector();
			Vector custCodeVector = new Vector();
			Vector custNameVector = new Vector();
			Vector address1Vector = new Vector();
			Vector address2Vector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
	
			if (ht != null && ht.size() > 0) {
				expDeliveryDateVector = (Vector) ht.get("EXP_DELIVERY_DATE");
				routeIdCharVector = (Vector) ht.get("ROUTE_ID_CHAR");
				stopVector = (Vector) ht.get("STOP");
				shipViaVector = (Vector) ht.get("SHIP_VIA");
				driverVector = (Vector) ht.get("DRIVER");
				soIdVector = (Vector) ht.get("SO_ID");
				shipmentNumVector = (Vector) ht.get("SHIPMENT_NUM");
				saleTypeVector = (Vector) ht.get("SALE_TYPE");
				custCodeVector = (Vector) ht.get("CUST_CODE");
				custNameVector = (Vector) ht.get("CUST_NAME");
				address1Vector = (Vector) ht.get("ADDRESS_1");
				address2Vector = (Vector) ht.get("ADDRESS_2");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
	
			}
	        if (expDeliveryDateVector.size() > 0) {
	        	for (int i = 0; i < expDeliveryDateVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("expDeliveryDate", expDeliveryDateVector.get(i).toString());
					temp.put("routeIdChar", routeIdCharVector.get(i).toString());
					temp.put("stop", stopVector.get(i).toString());
					temp.put("shipVia", shipViaVector.get(i).toString());
					temp.put("driver", driverVector.get(i).toString());
					temp.put("soId", soIdVector.get(i).toString());
					temp.put("shipmentNum", shipmentNumVector.get(i).toString());
					temp.put("saleType", saleTypeVector.get(i).toString());
					temp.put("custCode", custCodeVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("address1", address1Vector.get(i).toString());
					temp.put("address2", address2Vector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
					temp.put("status", getDeliveryStatus(soIdVector.get(i).toString(),shipmentNumVector.get(i).toString()));
	
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}


	public ArrayList<HashMap<String, String>> getCustomerData(String customerId,String timeValue,String fromDate,String toDate,String standardDateFormat) {	
		String sqlQuery="",filterString = "", deliveryStatus="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			if(timeValue.equalsIgnoreCase("today"))
				filterString = " and sh.EXPECT_DATE=TO_CHAR(CURRENT_DATE, 'dd-mon-yyyy') ";
			else if(timeValue.equalsIgnoreCase("ThreeDays"))
				filterString = " and sh.EXPECT_DATE>=TO_CHAR(CURRENT_DATE-3, 'dd-mon-yyyy') and sh.EXPECT_DATE<=TO_CHAR(CURRENT_DATE , 'dd-mon-yyyy') " ;
			else if(timeValue.equalsIgnoreCase("OneWeek"))
				filterString = " and sh.EXPECT_DATE>=TO_CHAR(CURRENT_DATE-7, 'dd-mon-yyyy') and sh.EXPECT_DATE<=TO_CHAR(CURRENT_DATE , 'dd-mon-yyyy') " ;
			else if(timeValue.equalsIgnoreCase("custom"))
				filterString = " and sh.EXPECT_DATE>=to_date('"+fromDate+"','MM-dd-yyyy') and sh.EXPECT_DATE<=to_date('"+toDate+"','MM-dd-yyyy') ";
			
			sqlQuery = "select  to_char(sh.EXPECT_DATE,'MM-DD-YYYY') as exp_delivery_date , SH.ROUTE_ID_CHAR, SH.STOP, so.SHIP_VIA,sh.driver, "
						+" sh.so_id, sh.SHIPMENT_NUM,SO.SALE_TYPE, cu.cust_code, sa.CUST_NAME, sa.ADDRESS_1, sa.ADDRESS_2, sa.city,sa.state, sa.ZIP, sh.STATUS_FLAG " 
						+" from shipments_header sh, so_header so, SHIP_TO_ADDRESS sa, cust cu "
						+" where SO.SO_ID=SH.SO_ID AND sh.so_id=sa.TRAN_ID and sa.shipment_num=(select max(shipment_num) from SHIP_TO_ADDRESS sa1 where sa1.tran_id=sh.so_id) "
						+" and sh.cust_guid=cu.cust_guid and sa.type='SO' and so.ship_via not in ('CSTMR PICKUP','CPU RWC','CPU DIRECT') "
						+" and cu.cust_code='"+customerId+"' "+filterString+" " 
						+" order by sh.EXPECT_DATE desc ";

			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector expDeliveryDateVector = new Vector();
			Vector routeIdCharVector = new Vector();
			Vector stopVector = new Vector();
			Vector shipViaVector = new Vector();
			Vector driverVector = new Vector();
			Vector soIdVector = new Vector();
			Vector shipmentNumVector = new Vector();
			Vector saleTypeVector = new Vector();
			Vector custCodeVector = new Vector();
			Vector custNameVector = new Vector();
			Vector address1Vector = new Vector();
			Vector address2Vector = new Vector();
			Vector cityVector = new Vector();
			Vector stateVector = new Vector();
			Vector zipVector = new Vector();
			Vector statusVector = new Vector();

			if (ht != null && ht.size() > 0) {
				expDeliveryDateVector = (Vector) ht.get("EXP_DELIVERY_DATE");
				routeIdCharVector = (Vector) ht.get("ROUTE_ID_CHAR");
				stopVector = (Vector) ht.get("STOP");
				shipViaVector = (Vector) ht.get("SHIP_VIA");
				driverVector = (Vector) ht.get("DRIVER");
				soIdVector = (Vector) ht.get("SO_ID");
				shipmentNumVector = (Vector) ht.get("SHIPMENT_NUM");
				saleTypeVector = (Vector) ht.get("SALE_TYPE");
				custCodeVector = (Vector) ht.get("CUST_CODE");
				custNameVector = (Vector) ht.get("CUST_NAME");
				address1Vector = (Vector) ht.get("ADDRESS_1");
				address2Vector = (Vector) ht.get("ADDRESS_2");
				cityVector = (Vector) ht.get("CITY");
				stateVector = (Vector) ht.get("STATE");
				zipVector = (Vector) ht.get("ZIP");
				statusVector = (Vector) ht.get("STATUS_FLAG");
			}
	        if (expDeliveryDateVector.size() > 0) {
	        	for (int i = 0; i < expDeliveryDateVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("expDeliveryDate", expDeliveryDateVector.get(i).toString());
					temp.put("routeIdChar", routeIdCharVector.get(i).toString());
					temp.put("stop", stopVector.get(i).toString());
					temp.put("shipVia", shipViaVector.get(i).toString());
					temp.put("driver", driverVector.get(i).toString());
					temp.put("soId", soIdVector.get(i).toString());
					temp.put("shipmentNum", shipmentNumVector.get(i).toString());
					temp.put("saleType", saleTypeVector.get(i).toString());
					temp.put("custCode", custCodeVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("address1", address1Vector.get(i).toString());
					temp.put("address2", address2Vector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
					
					deliveryStatus=statusVector.get(i).toString();
					if(deliveryStatus.equalsIgnoreCase("i"))
						temp.put("status", "Delivered");
					else 
						temp.put("status", getDeliveryStatus(soIdVector.get(i).toString(),shipmentNumVector.get(i).toString()));
						
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	
	}


	public String getTileDataToday(String customerId) {	
		String sqlQuery="",filterString = "",tileData="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct count( * ) "
						+" from shipments_header sh, so_header so, SHIP_TO_ADDRESS sa, cust cu " 
						+" where SO.SO_ID=SH.SO_ID AND sh.so_id=sa.tran_id " 
						+" and sa.shipment_num=(select max(shipment_num) from SHIP_TO_ADDRESS sa1 where sa1.tran_id=sh.so_id) "
						+" and sh.cust_guid=cu.cust_guid and sa.type='SO' and so.ship_via not in ('CSTMR PICKUP','CPU RWC','CPU DIRECT') "
						+" and cu.cust_code='"+customerId+"' and sh.EXPECT_DATE=TO_CHAR(CURRENT_DATE, 'dd-mon-yyyy') ";
 
			Utils.log("Query >>>>>> "+sqlQuery);
			tileData=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return tileData;
	
	}

	
	public String getTileDataMonth(String customerId) {	
		String sqlQuery="",filterString = "",tileData="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select distinct count( * ) "
						+" from shipments_header sh, so_header so, SHIP_TO_ADDRESS sa, cust cu " 
						+" where SO.SO_ID=SH.SO_ID AND sh.so_id=sa.tran_id " 
						+" and sa.shipment_num=(select max(shipment_num) from SHIP_TO_ADDRESS sa1 where sa1.tran_id=sh.so_id) "
						+" and sh.cust_guid=cu.cust_guid and sa.type='SO' and so.ship_via not in ('CSTMR PICKUP','CPU RWC','CPU DIRECT') and cu.cust_code='"+customerId+"' "
						+" and sh.EXPECT_DATE>=TO_CHAR(ADD_MONTHS(CURRENT_DATE, -1),'dd-mon-yyyy') and sh.EXPECT_DATE<=TO_CHAR(CURRENT_DATE , 'dd-mon-yyyy') "; 
 
			Utils.log("Query >>>>>> "+sqlQuery);
			tileData=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return tileData;
	
	}


	public String getDeliveryStatus(String orderId, String shipmentNo){
		String status="";
		try{
			DistUtils du=new DistUtils();
			String sqlQuery = " select count(*) as num from MOB_CONFIRM_IMG where ORDERID="+orderId.trim()+" and SHIPMENTID="+shipmentNo.trim()+" and UPLOADTOAWS='Y' ";
			String num = Utils.removeNull(du.getFieldInfo(sqlQuery));
	
			if(Integer.parseInt(num) > 0)
				status = "Delivered";
			else 
				status = "In Transit";
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			Utils.log("SS Exception :: " , e);
		}
		return status;

	}

%>
