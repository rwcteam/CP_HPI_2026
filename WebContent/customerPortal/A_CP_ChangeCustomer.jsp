<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.io.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>
<%-- <%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %> --%>


<% 

	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();
	
	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}

	String message=(String)request.getAttribute("message");
	if(message == null)
		message="";

	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId :: " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key :: " + custKey);


%>


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
                        <div class="col-md-12">
                            <!-- <h1 class="title-4">Welcome back
                                <span>John!</span>
                            </h1> -->
                            <h3 class="title-5 m-b-35"><!-- <img src="NewPortalAssets/assets/images/invoices.png" width="18px" height="18px"/> -->&nbsp;Change Customer</h3>
                            <hr class="line-seprate">
                        </div>
                    </div>
                </div>
            </section>
            <!-- END WELCOME-->

            <!-- START STATISTIC-->
            <section class="statistic statistic2">
                <div class="container">
                	<form name="ChangeCustomerForm" id="ChangeCustomerForm" action="" method="post">
		                <div class="row">
		                	<div class="col-md-12 form-group" align="center">
						<h4 style="color: green; text-align: center;"><%=message %></h4>
		                	</div>
		                </div>
		                <div class="row">
							<input type="hidden" name="param" id="param" value="UpdateCustomerId">
							<div class="col-md-2 form-group" align="right">
							   	<label><strong>Customer#</strong></label>
							</div>
							<div class="col-md-2 form-group" align="left">
								<input type="text" name="customerId" id="customerId" class="form-control" required>
							</div>
							<div class="col-md-2 form-group" align="left">
							  	<button type="button" onclick="updateCustomerId()" class="btn btn-primary" style="background-color: #b30000;">Submit</button>
							</div>
	                	</div>
	                </form>
                </div>
            </section>
			<!-- END STATISTIC-->            


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
			
	
			$('#datepicker1,#datepicker2').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				maxDate: "0",
			});

			$("#customerId").autocomplete({
				autoFocus: true,
			    source: "../customerPortal/getAgCustomer.jsp",
				focus: function( event, ui ) { return false},
				//source: availableTags,
				minLength: 3,
				select: function( event, ui ) {
					document.ChangeCustomerForm.customerId.value=ui.item.value.substr(0,ui.item.value.indexOf(':')-1);
				  	return false;
				}
			}); 

			
			$('#CustomerDeliveryTable').DataTable({
				'pageLength': 25,
				"aaSorting": [[ 2, "desc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            /* 'copy', 'csv', 'excel' */
			            'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5'
			        ],
				'bDestroy': true
			});
			
		}); 	
	

		function updateCustomerId(){
			var customerId = document.getElementById('customerId').value;
			if(customerId == "" || customerId == null ){
				alert("Please select customer#");
				return false;
			}
			else{
				document.ChangeCustomerForm.action="../customerPortal/A_CP_ChangeCustomerAction.jsp";
				document.ChangeCustomerForm.submit();	        
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

