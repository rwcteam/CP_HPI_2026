<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>


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
	
	//List<HashMap<String, String>> listData = getPastPaymentData("00008664");
	List<HashMap<String, String>> listData = getPastPaymentData(custKey.trim().toString());

%>


	<style>
		/* Make the loader full screen */
		#loader {
			position: fixed;
		  	top: 0;
		  	left: 0;
		  	/* width: 100%;
		  	height: 100%; */
		  	width: 100vw;
		  	height: 100vh;
		  	/* background-color: rgba(255, 255, 255, 0.8); */  /* Semi-transparent background */
		  	display: flex;
		  	justify-content: center;
		  	align-items: center;
		  	z-index: 9999;  /* Ensure it's on top of all content */
		  	display: block;
  			margin-left: auto;
  			margin-right: auto;
  			margin-top: auto;
  			margin-bottom: auto;
  			background: url('NewPortalAssets/assets/images/loader.gif') 
			              50% 50% no-repeat rgba(255, 255, 255, 0.8);
			background-size:5%;			              
  			
		}
		
		/* Hide the loader when not in use */
		#loader.hidden {
		  display: none;
		}
		
		#loader img {
		  width: 50px;  /* Size of the loader image */
		  height: 50px;
		}
		
		.tr-shadow {
			/* cursor: -webkit-grab; 
			cursor: grab; */
			cursor: pointer;
		}		
		
	</style>


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
                            <h3 class="title-5 m-b-35"><img src="NewPortalAssets/assets/images/history.png" width="18px" height="18px"/>&nbsp;Past Payment</h3>
                        </div>
                        <!-- <div class="col-md-4" align="left">
                            <button type="button" name="PaymentButton" value="payment" onClick="getPaymentPage()" class="btn btn-primary" style="background-color: #818589;">PAYMENT</button>
                        </div> -->
						<!-- <div class="dopenav">
							<ul id="nav">
								<li class="liDark">
		                            <i><img src="NewPortalAssets/assets/images/history.png" width="18px" height="18px"/></i>Past Payment
		                            <span class="bot-line"></span>
								</li>
							</ul>
						</div> -->
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

            <p id="msg" style="color: green; font-weight: bold;"></p>
            <!-- DATA TABLE-->
            <section class="p-t-20">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-12">
                            <div id="showRecordDataTable" class="tabcontent">
	                            <div class="table-responsive" id="table-div" >
	                                <table id="PastPaymentTable" class="table border border-top-0 table-grid tab-Table" role="grid" width="100%" aria-describedby="datatable-example_info" style="font-size:12px;font-family: Verdana;">
	                                    <thead>
	                                        <tr>
			                                    <th width="2%" style="text-align: center;"></th>
			                                    <th width="15%" nowrap style="text-align: left;">PAYMENT#</thh>
		                                        <th width="15%" nowrap style="text-align: left;">PAYMENT DATE</th>
		                                        <th width="15%" nowrap style="text-align: right;">PAYMENT AMOUNT</th>
		                                        <!-- <th align="center" width="10%">PAYMENT METHOD</th> -->
		                                        <th width="10%" style="text-align: center;"></th>
		                                        <th width="44%" style="text-align: center;"></th>
	                                       	</tr>
	                                    </thead>
	                                    <tbody>
	                                    	<%
												if(listData != null && listData.size()>0){ 
													for(int i=0;i<listData.size();i++){
														HashMap map=(HashMap)listData.get(i);
											%>
												<tr class="tr-shadow">
												<%-- <td align="center"><a href="javascript:getInvoiceList('<%=map.get("soId")%>','<%=map.get("shipmentNum")%>')"><i class="fa fa-download" style="color:black"></i></a></td> --%>
													<td align="center"><!-- <button class="expand-btn">+</button> --></td>
													<td align="left"><%=map.get("paymentId")%></td>
													<td align="left"><%=map.get("paymentDate")%></td>
													<td align="right">$<%=df.format(Double.parseDouble(map.get("paymentAmount").toString()))%></td>
													<%-- <td align="left"><%=map.get("paymentMethod")%></td> --%>
													<%-- <td><button type="button" class="btn btn-primary" style="background-color: #818589; padding: 8px 20px;" onclick="downloadDetails('<%=map.get("paymentId") %>')">Download</button></td> --%>
													<td align="center"><a href="javascript:downloadDetails('<%=map.get("paymentId") %>')"><i class="fa fa-download" aria-hidden="true"></i></a></td>
													<td></td>
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
    
    	<!-- <div id="loader"><img src="NewPortalAssets/assets/images/ajax-loader.gif"  alt="Loading..."/></div> -->
     		<div id="loader"></div>
    
    </div>

	


	<!-- START FOOTER-->
	<%@ include file="A_CP_Footer.jsp" %>
    <!-- END FOOTER-->

	<script>
	
		$(document).ready(function(){
			debugger;
			$("#loader").hide();
	        // Handle the "+" button click event
	        $('#PastPaymentTable tbody').on('click', '.expand-btn', function() {
	        	var tr = $(this).closest('tr');
				var table = new DataTable('#PastPaymentTable');
				var row = table.row(tr);
				var data = row.data();
	        	//var row = table.row(tr);
	            
	        	// Check if the row is already open
	            if (row.child.isShown()) {
	            	$("#loader").hide();
	            	row.child.hide();
	                tr.find('.expand-btn').text('+');
	            } else {
	            	$("#loader").show();
	            	let nf = new Intl.NumberFormat('en-US');
	                var paymentId = tr.children('td').eq(1).text(); // Assuming ID is in column 1 (ID column)
	                $.ajax({
	    				url : "../customerPortal/A_CP_PastPaymentAction.jsp?param=GetDetails&paymentId="+paymentId,
	    				type : 'POST',
	    				dataType : 'json',
	    		        contentType : 'application/json',
	                    success: function(response) {
	                    	$("#loader").hide();
	    		        	var data = response.ChildTableList;
	    		        	var childDataTable = "";
	    		        	childDataTable = childDataTable + '<table id="DetailsTable" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;font-size: 12px;">';
	    		        	childDataTable = childDataTable + '<thead><tr><th align="left">INVOICE#</th><th align="left">INVOICE DATE</th><th align="right">PAYMENT AMT</th><th align="right">DISCOUNT AMT</th><th></th></tr></thead><tbody>';
	    		        	if(data.length != 0){
	    		        		$.each(data, function (key, row) {
	    		        			let paymentAmt=parseFloat(row.paymentAmount).toFixed(2);
		    		        		let discountAmt=parseFloat(row.discountAmount).toFixed(2);
		    		        		var formattedPaymentAmount = paymentAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
		    		        		var formattedDiscountAmount = discountAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
	    		        			childDataTable = childDataTable + '<tr class="no-click>'+
	    																'<td align="left">'+row.refNum+'</td>'+
	    																'<td align="left">'+row.invoiceDate+'</td>'+
	    																'<td align="right">'+addCommas(formattedPaymentAmount)+'</td>'+
	    																'<td align="right">'+addCommas(formattedDiscountAmount)+'</td>'+
	    																'<td></td>'+
	    										   				   	  '</tr>';
	    		        		});
	    		        	}
	    		        	childDataTable=childDataTable+'</tbody></table>';
	                        row.child(childDataTable).show();
	                        tr.find('.expand-btn').text('-'); // Change "+" to "-" when row is expanded

	                    },
	                    error: function() {
	                    	$("#loader").hide();
	                    	row.child('<div>Failed to load data.</div>').show();
	                    }
	                });
	            }
	        });

			$('#PastPaymentTable tbody').on('click', '.tr-shadow', function() {
				$("#loader").hide();
				var tr = $(this).closest('tr');
				var table = new DataTable('#PastPaymentTable');
				var row = table.row(tr);
				var data = row.data();
	        	//var row = table.row(tr);
			
	            // Check if the row is already open
	            if (row.child.isShown()){
	            	$("#loader").hide();
	            	row.child.hide();
	                tr.find('.expand-btn').text('+');
	            } else {
	            	$("#loader").show();
	            	let nf = new Intl.NumberFormat('en-US');
	                var paymentId = tr.children('td').eq(1).text(); // Assuming ID is in column 1 (ID column)
	                $.ajax({
	    				url : "../customerPortal/A_CP_PastPaymentAction.jsp?param=GetDetails&paymentId="+paymentId,
	    				type : 'POST',
	    				dataType : 'json',
	    		        contentType : 'application/json',
	                    success: function(response) {
	                    	$("#loader").hide();
	    		        	var data = response.ChildTableList;
	    		        	var childDataTable = "";
	    		        	childDataTable = childDataTable + '<table id="DetailsTable" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;font-size: 12px;">';
	    		        	childDataTable = childDataTable + '<thead><tr><th align="left">INVOICE#</th><th align="left">INVOICE DATE</th><th align="right">PAYMENT AMT</th><th align="right">DISCOUNT AMT</th><th></th></tr></thead><tbody>';
	    		        	if(data.length != 0){
	    		        		$.each(data, function (key, row) {
	    		        			let paymentAmt=parseFloat(row.paymentAmount).toFixed(2);
		    		        		let discountAmt=parseFloat(row.discountAmount).toFixed(2);
		    		        		var formattedPaymentAmount = paymentAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
		    		        		var formattedDiscountAmount = discountAmt.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
	    		        			childDataTable = childDataTable + '<tr class="no-click">'+
																		'<td align="left">'+row.refNum+'</td>'+
	    																'<td align="left">'+row.invoiceDate+'</td>'+
	    																'<td align="right">'+addCommas(formattedPaymentAmount)+'</td>'+
	    																'<td align="right">'+addCommas(formattedDiscountAmount)+'</td>'+
	    										   				   		'<td></td>'+  
	    															'</tr>';
	    		        		});
	    		        	}
	    		        	childDataTable=childDataTable+'</tbody></table>';
	                        row.child(childDataTable).show();
	                        tr.find('.expand-btn').text('-'); // Change "+" to "-" when row is expanded
			                        
	                    },
	                    error: function() {
	                    	$("#loader").hide();
	                    	row.child('<div>Failed to load data.</div>').show();
	                    }
	                });
	            }
			});
				
			$('#PastPaymentTable').DataTable({
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
				'bDestroy': true
			});

		}); 	

		
		function addCommas(nStr){
		    nStr += '';
		    var x = nStr.split('.');
		    var x1 = x[0];
		    var x2 = x.length > 1 ? '.' + x[1] : '';
		    var rgx = /(\d+)(\d{3})/;
		    while (rgx.test(x1)) {
		        x1 = x1.replace(rgx, '$1' + ',' + '$2');
		    }
		    return x1 + x2;
		}
		
		
		function getPaymentPage(){
			window.location = "../customerPortal/A_CP_InvoicePayment.jsp?pageName=InvoicePayment";	 			
		}

		function getPastPaymentPage(){
			window.location = "../customerPortal/A_CP_PastPayment.jsp?pageName=InvoicePayment";	 			
		}

		
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}
	   	
		function downloadDetails(paymentId){
			debugger;
			if(paymentId == null || paymentId == ""){
				alert("Please provide paymentId");
				return false;
			}
			else{
	            $.ajax({
					url : "../customerPortal/A_CP_PastPaymentAction.jsp?param=GetExcel&paymentId="+paymentId,
					type : 'POST',
    				dataType : 'json',
    		        contentType : 'application/json',
	                success: function(response) {
	                	//$('#msg').html(response.message);
	                	//openExcel(response.filePath);
	                	var jsonData = response.ChildTableList;
	                	
	                	// Create a new workbook and a worksheet from JSON data
	                    const wb = XLSX.utils.book_new();
	                    const ws = XLSX.utils.json_to_sheet(jsonData);

	                    // Append the worksheet to the workbook
	                    XLSX.utils.book_append_sheet(wb, ws, "Sheet1");

	                    // Generate the Excel file and trigger the download
	                    XLSX.writeFile(wb, "Payment_Detail.xlsx");
	                },
	                error: function() {
	                }
	            });
			}
		}
		
		
		function openExcel(filePath){
			msgWindow=open('/' + filePath, "_blank");
			if(msgWindow.opener==null) msgWindow.opener = self;
				msgWindow.focus();
		}
		
	</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.1/xlsx.full.min.js"></script>

<%!

	public ArrayList<HashMap<String, String>> getPastPaymentData(String custKey) {	
		String sqlQuery="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select PAYMENT_ID_NUM,PAYMENT_DATE,PAYMENT_AMOUNT,PAYMENT_METHOD "
						+" from ARCASH "
						+" where CREATED_BY='API' and REF_TYPE='CA' and TRANS_CODE='CA' " 
						+" and PAYMENT_DATE>=sysdate-365 and cust_key='"+custKey+"' ";
			Utils.log("Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector paymentIdVector = new Vector();
			Vector paymentDateVector = new Vector();
			Vector paymentAmountVector = new Vector();
			Vector paymentMethodVector = new Vector();
			if (ht != null && ht.size() > 0) {
				paymentIdVector = (Vector) ht.get("PAYMENT_ID_NUM");
				paymentDateVector = (Vector) ht.get("PAYMENT_DATE");
				paymentAmountVector = (Vector) ht.get("PAYMENT_AMOUNT");
				paymentMethodVector = (Vector) ht.get("PAYMENT_METHOD");
			}
	        if (paymentIdVector.size() > 0) {
	        	for (int i = 0; i < paymentIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("paymentId", paymentIdVector.get(i).toString());
					temp.put("paymentDate", paymentDateVector.get(i).toString());
					temp.put("paymentAmount", paymentAmountVector.get(i).toString());
					temp.put("paymentMethod", paymentMethodVector.get(i).toString());
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
