<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.io.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.so.servlet.ApiCall"%>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>


<% 
	//response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
	//response.setHeader("Pragma", "no-cache");
	//response.setDateHeader("Expires", 0);

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
	Utils.log("customerId >>>> " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key >>>> " + custKey);
	String changeCustomerUserId = (String)session.getAttribute("changeCustomerUserId");
	if(changeCustomerUserId == null || changeCustomerUserId.trim().isEmpty()) {
	    changeCustomerUserId = userId;
	}
	String defaultWarehouse=Utils.removeNull(du.getFieldInfo("select defaultwarehouse from etechuser where deptid='"+customerId+"' and userid='"+changeCustomerUserId+"'"));
	Utils.log("DefaultWarehouse >>>> "+defaultWarehouse);
	String warehouse=Utils.removeNull(du.getFieldInfoPro2("SELECT SYSTEM_ID from SYSTEM_FILE where SYSTEM_ID like '%"+defaultWarehouse+"'"));
	Utils.log("Warehouse >>>> "+warehouse);

	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	
	ArrayList<HashMap<String, String>> createOrderList = getCreateOrderList(custKey.trim());
	ArrayList<HashMap<String, String>> templateList = getTemplateList(customerId.trim());
	ArrayList<HashMap<String, String>> quoteEntryList = getQuoteEntryList(customerId.trim());
	//ArrayList<HashMap<String, String>> createOrderList = getCreateOrderList("3745");
	
	String custPoRequired = Utils.removeNull(du.getFieldInfoPro2("select CUST_PO_REQUIRED from CUST_SHIPTO where CUST_KEY='"+custKey.trim()+"'"));
	Utils.log("custPoRequired >>>> " + custPoRequired);
	
	String shipToName="";
	ArrayList<HashMap<String, String>> shipToNameList = getShipToNameList(custKey.trim());
	for (int i=0; i< shipToNameList.size();i++){
		HashMap mapData = (HashMap)shipToNameList.get(i);
		if(!mapData.get("shipToName").toString().equalsIgnoreCase("NA")){
			shipToName+="<option value='"+mapData.get("shipToName")+"'>"+mapData.get("shipToName")+"</option>";
		}
	}
	
	String addressOne="";
	ArrayList<HashMap<String, String>> addressOneList = getAddressOneList(custKey.trim());
	for (int i=0; i< addressOneList.size();i++){
		HashMap mapData = (HashMap)addressOneList.get(i);
		if(!mapData.get("addressOne").toString().equalsIgnoreCase("NA")){
			addressOne+="<option value='"+mapData.get("addressOne")+"'>"+mapData.get("addressOne")+"</option>";
		}
	}
	
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
    <div class="page-content--bgf7">
        <section class="py-4">
            <div class="container-fluid">
                <div class="row mb-2 justify-content-between">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 mb-3">
		            	<h6 class="mb-4 text-uppercase"><img src="NewPortalAssets/assets/images/icons/template-orders.png" width="40px" alt="" />&nbsp; Shop</h6>
		          	</div>
	                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 order-xl-1 mb-3 mb-md-0 d-flex justify-content-sm-end align-items-start">
                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">

						<div class="d-flex align-items-center border-bottom w-100">
						
						    <!-- Tabs -->
						    <ul class="nav nav-pills flex-nowrap mb-2" id="payments-tab" role="tablist">
						        
						        <li class="nav-item">
						            <a class="nav-link active rounded-0 text-nowrap" data-target="#CreateNewOrder">
						                <img src="NewPortalAssets/assets/images/icons/template-orders.png" width="25px" class="mr-2" alt="" />
						                Create Order
						            </a>
						        </li>
						
						        <li class="nav-item">
						            <a class="nav-link rounded-0 text-nowrap" data-target="#CreateTemplate">
						                <img src="NewPortalAssets/assets/images/icons/templates.png" width="22px" class="mr-2" alt="" />
						                Template
						            </a>
						        </li>
						
						        <li class="nav-item">
						            <a class="nav-link rounded-0 text-nowrap" data-target="#QuoteEntry">
						                <img src="NewPortalAssets/assets/images/icons/quote-entry.png" width="22px" class="mr-2" alt="" />
						                Quote Entry
						            </a>
						        </li>
						
						    </ul>
						
						    <!-- Right Corner Help -->
						    <div class="ml-auto">
						        <a href="javascript:showHelpModal()"  class="text-nowrap" title="Help"><i class="bi bi-question-circle fs-4" style="font-size: 45px;"></i></a>

						    </div>
						
						</div>



                        <div class="tab-content" id="payments-tabContent">
                            <div class="tab-pane active" id="CreateNewOrder">
                                <div class="table-responsive">
  	                                <button class="btn btn-outline-danger btn-sm mb-3" onclick="popupForCreateOrderHeaderDetail()" data-toggle="modal" data-target="#CreateOrderModal"><i class="icon-plus"></i>Create New Order</button>
  	                                <table id="CreateNewOrderTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle" role="grid"
	                                    width="100%" aria-describedby="datatable-example_info">
	                                    <thead>
	                                        <tr>
	                                            <th align="center">Branch</th>
	                                            <th align="center">SO#</th>
	                                            <th align="center">Order Date</th>
	                                            <th align="center">Ship to</th>
	                                            <th align="center">Address</th>
	                                            <th align="center">Cust PO</th>
	                                            <th align="center">Type</th>
	                                            <th align="right">Order Total</th>
	                                            <th align="right">Total Sale</th>
	                                            <th align="center">ACTION</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<%
												if(createOrderList != null && createOrderList.size()>0){
													for(int i=0;i<createOrderList.size();i++){
														HashMap map=(HashMap)createOrderList.get(i);
														String orderStatus=getOrderStatus(map.get("soId").toString(),customerId,warehouse);
														if(orderStatus.equalsIgnoreCase("Open")){
											%>
	                                        <tr class="tr-shadow">
	                                        	<td align="left"><%=map.get("systemId")%></td>
												<td align="left"><%=map.get("soId")%></td>
												<td align="left"><%=map.get("orderDate")%></td>
												<td align="left"><%=map.get("custName")%></td>
												<td align="left"><%=map.get("shipTo")%></td>
												<td align="left"><%=map.get("custPo")%></td>
												<td align="left"><%=map.get("saleType")%></td>
												<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("orderTotal").toString()))%></td>
												<td style="text-align: right;"><%=df.format(Double.parseDouble(map.get("totalSale").toString()))%></td>
								      			<td style="text-align: left;">
									      			<div style="display: flex; gap: 5px; white-space: nowrap;">
								                   		<button class="btn btn-outline-danger btn-sm" onclick="popupForUpdateCreateOrderHeader('<%=map.get("soId")%>')"><i class="icon-update"></i> Update</button> 
								                   		<button class="btn btn-outline-danger btn-sm" onclick="deleteCreateOrderHeader('<%=map.get("soId")%>')"><i class="icon-delete"></i> Delete</button>
								                  		<button class="btn btn-outline-danger btn-sm d-flex align-items-center" onclick="popupForOpenOrdersInquiry('<%=map.get("soId")%>')" title="View"><i class="icon-visible fs-1 mr-2"></i> View</button>
								                   	</div>
							                   	</td>
	                                        </tr>
	                                        <%}}}else{%>
			                                	<tr>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="left"><div style="width:200px">Data Does Not Exist</div></td>
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
                            <div class="tab-pane" id="CreateTemplate">
                                <div class="table-responsive">
  	                                <button class="btn btn-outline-danger btn-sm mb-3" onclick="popupForTemplateHeaderDetail()" data-toggle="modal" data-target="#CreateTemplateModal"><i class="icon-plus"></i>Create New Template</button>
  	                                <table id="CreateNewTemplateTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle" role="grid"
	                                    width="100%" aria-describedby="datatable-example_info">

	                                    <colgroup>
									        <col style="width:6%">
									        <col style="width:20%">
									        <col style="width:20%">
									        <col style="width:10%">
									        <col style="width:10%">
									        <col style="width:6%">
									        <col style="width:6%">
									        <col style="width:6%">
									        <col style="width:16%">
									    </colgroup>

	                                    <thead>
	                                        <tr>
	                                            <th align="center">TEMPLATE#</thh>
	                                            <th align="center">SHIP TO</th>
	                                            <th align="center">ADDRESS 1</th>
	                                            <th align="center">ADDRESS 2</th>
	                                            <th align="center">ADDRESS 3</th>
	                                            <th align="center">CITY</th>
	                                            <th align="center">STATE</th>
	                                            <th align="center">ZIP</th>
	                                            <th align="center">ACTION</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<%
												if(templateList != null && templateList.size()>0){
													for(int i=0;i<templateList.size();i++){
														HashMap map=(HashMap)templateList.get(i);
											%>
	                                        <tr class="tr-shadow">
	                                            <td align="left"><%=map.get("quoteId")%></td>
	                                            <td align="left"><%=map.get("custName")%></td>
												<td align="left"><%=map.get("addressOne")%></td>
												<td align="left"><%=map.get("addressTwo")%></td>
												<td align="left"><%=map.get("addressThree")%></td>
												<td align="left"><%=map.get("city")%></td>
												<td align="left"><%=map.get("state")%></td>
												<td align="left"><%=map.get("zip")%></td>
								      			<td style="text-align: left;">
									      			<div style="display: flex; gap: 5px; white-space: nowrap;">
									      			    <button class="btn btn-outline-danger btn-sm" onclick="popupForHeaderDetail('<%=map.get("quoteId")%>','<%=map.get("custPORequired")%>')" data-toggle="modal" data-target="#createOrder"><i class="icon-plus"></i> Create Order</button>
								                   		<% if(map.get("createdBy").toString().trim().equalsIgnoreCase("API")){%>
									                   		<button class="btn btn-outline-danger btn-sm" onclick="popupForUpdateTemplateHeader('<%=map.get("quoteId")%>')"><i class="icon-update"></i> Update</button> 
									                   		<button class="btn btn-outline-danger btn-sm" onclick="deleteTemplateHeader('<%=map.get("quoteId")%>')"><i class="icon-delete"></i> Delete</button>
								                   		<%}%>
								                   	</div>	
							                   	</td>
	                                        </tr>
	                                        <%}}else{%>
			                                	<tr>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="left"><div style="width:200px">Data Does Not Exist</div></td>
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
                            <div class="tab-pane" id="QuoteEntry">
                                <div class="table-responsive">
  	                                <button class="btn btn-outline-danger btn-sm mb-3" onclick="popupForQuoteEntryHeaderDetail()" data-toggle="modal" data-target="#QuoteEntryModal"><i class="icon-plus"></i> Quote Entry </button>
  	                                <table id="QuoteEntryTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle" role="grid"
	                                    width="100%" aria-describedby="datatable-example_info">
	                                    
	                                    <colgroup>
									        <col style="width:10%">
									        <col style="width:25%">
									        <col style="width:35%">
									        <col style="width:15%">
									        <col style="width:15%">
									    </colgroup>
	                                    
	                                    <thead>
	                                        <tr>
	                             				<th align="center">QUOTE#</th>
	                                            <th align="center">SHIP TO</th>
	                             				<th align="center">ADDRESS</th>
	                                            <th class="text-right">ORDER TOTAL</th>
	                                            <th align="center">ACTION</th>
	                                        </tr>
	                                    </thead>
	                                    <tbody>
											<%
												if(quoteEntryList != null && quoteEntryList.size()>0){
													for(int i=0;i<quoteEntryList.size();i++){
														HashMap map=(HashMap)quoteEntryList.get(i);
											%>
	                                        <tr class="tr-shadow">
	                                            <td align="left"><%=map.get("quoteId")%></td>
	                                            <td align="left"><%=map.get("custName")%></td>
												<td align="left"><%=map.get("shipTo")%></td>
												<td align="right"><%=df.format(Double.parseDouble(map.get("orderTotal").toString()))%></td>
								      			<td style="text-align: left;">
								      			    <%-- <button class="btn btn-outline-danger btn-sm" onclick="popupForHeaderDetail('<%=map.get("quoteId")%>','<%=map.get("custPORequired")%>')" data-toggle="modal" data-target="#createOrder"><i class="icon-plus"></i> Create Order</button> --%>
							                   		<% if(map.get("createdBy").toString().trim().equalsIgnoreCase("API")){%>
								                   		<button class="btn btn-outline-danger btn-sm" onclick="popupForUpdateQuoteEntryHeader('<%=map.get("quoteId")%>')"><i class="icon-update"></i> Update</button> 
								                   		<button class="btn btn-outline-danger btn-sm" onclick="deleteQuoteEntryHeader('<%=map.get("quoteId")%>')"><i class="icon-delete"></i> Delete</button>
							                   		<%} %>
							                   	</td>
	                                        </tr>
	                                        <%}}else{%>
			                                	<tr>
			                                    	<td align="center"></td>
			                                    	<td align="center"></td>
			                                    	<td align="left"><div style="width:200px">Data Does Not Exist</div></td>
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
            </div>
        </section>
    </div>
</div>


<div class="modal mx-100 w-100" id="CreateOrderModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="createOrderModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Create Order </h5> &nbsp;
                <h5 class="modal-title" id="quoteIdForCreateOrderHeader"> </h5>
                <a href="javascript:closeModal()" class="close small opacity-100 text-dark" aria-label="Close" ><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="CreateOrderErrorMsg" style="text-align: center; color: red;"></p>
                        <div class="step-one d-block">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-4">Shipping Details</h5>
                                        </div>
                                        <div class="col-md-4">
                                        	<input type="hidden" name="createOrderModalCustPORequired" id="createOrderModalCustPORequired">
                                        	<input type="hidden" name="createOrderQuoteId" id="createOrderQuoteId">
                                        	<input type="hidden" name="createOrderShipToSeq" id="createOrderShipToSeq">
                                            <div class="form-group">
                                                <label for="createOrderShipToName">Ship to name</label>
                                                <input type="text" name="createOrderShipToName" id="createOrderShipToName" class="form-control" placeholder="Search"/>
                                            </div>
                                        </div>
                                        <div class="col-md-8">
                                            <div class="form-group">
                                                <label for="createOrderAddress1">Address 1 <span class="text-danger small">*</span></label>
                                                <input type="text" name="createOrderAddressOne" id="createOrderAddressOne" class="form-control" />
                                            	<div class="invalid-feedback">Please enter address</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="createOrderAddress2">Address 2</label>
                                                <input type="text" class="form-control" name="createOrderAddressTwo" id="createOrderAddressTwo" value="" placeholder="Enter address line 2" >
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="createOrderCity">City <span class="text-danger small">*</span></label> 
                                                <input type="text" class="form-control" name="createOrderCity" id="createOrderCity" value="" placeholder="Enter city" >
	                                            <div class="invalid-feedback">Please enter city</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="createOrderState">State <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="createOrderState" id="createOrderState" value="" placeholder="Enter state" >
                                            	<div class="invalid-feedback">Please enter state</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="createOrderZip">Zip <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="createOrderZip" id="createOrderZip" value="" placeholder="Enter zip code" >
	                                            <div class="invalid-feedback">Please enter zip</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderContactName">Contact name</label>
                                                <input type="text" class="form-control" name="createOrderMemoOne" id="createOrderMemoOne" value="" placeholder="Enter contact name" >
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderContactPhone">Phone</label>
                                                <input type="tel" class="form-control" name="createOrderMemoTwo" id="createOrderMemoTwo" value="" placeholder="Enter phone number" >
                                            </div>
                                        </div>

                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label>Ship Via <span class="text-danger small">*</span></label>
                                                <select name="createOrderShipVia" id="createOrderShipVia" class="form-control" >
													<option value="" selected>SELECT</option>
													<option value="RWC ROOFLOAD">ROOF LOAD</option>
													<option value="RWC GRNDROP">GROUND DROP</option>
	    										</select>
                                                <div class="invalid-feedback">Please Select ShipVia.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mb-1">
                                    <hr class="bg-light" />
                                </div>
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-3">Order Info</h5>
                                        </div>
                                        <!-- Group 2: Order Info -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderCustomerPO" id="createOrderCustomerPoLabel">Customer PO. </label>
                                                <input type="text" class="form-control" name="createOrderCustomerPo" id="createOrderCustomerPo" value="" placeholder="Enter customer PO">
                                                <div id="createOrderCustomerPOError" class="invalid-feedback">Please Enter Customer PO</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderReference">Reference</label>
                                                <input type="text" class="form-control" name="createOrderReferenceId" id="createOrderReferenceId" value="" placeholder="Enter reference">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderJobNo">Job no.</label>
                                                <input type="text" class="form-control" name="createOrderAddressThree" id="createOrderAddressThree" value="" placeholder="Enter job number">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="createOrderExpectedDelivery">Requested Delivery Date </label>
                                                <input type="text" class="form-control date-normalize" name="createOrderExpectedDeliveryDate" id="createOrderExpectedDeliveryDate" value="" pattern="\d{2}-\d{2}-\d{4}" title="Enter date as MM-DD-YYYY" maxlength="10" autocomplete="off">
                                            </div>
                                        </div>

                                        <!-- Group 3: Notes -->
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="createOrderNotes">Notes</label>
                                                <textarea name="createOrderNotes" id="createOrderNotes" value="" class="form-control" placeholder="Enter notes" rows="2" ></textarea>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="createOrderMessage">Message</label>
                                                <textarea name="createOrderMessage" id="createOrderMessage" value="" class="form-control" placeholder="Enter message" rows="2" ></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="step-two d-none" id="CreateOrderProductModal">  
                            <button class="btn btn-outline-danger btn-sm mb-3" id="createOrderAddItemBtn" onclick="popupForNewCreateOrderItemList()" data-toggle="modal" data-target="#CreateOrderItemListModal"><i class="icon-plus"></i>Add</button>
                            <form>
                                <div class="row">
                                    <div class="col-md-12">
                                        <table id="CreateOrderItemTable"
           									class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                  			role="grid" width="100%" aria-describedby="datatable-example_info">
                                            <thead>
                                                <tr>
                                                    <th width="7%" align="right" class="text-right"></th>
                                                    <th width="10%" align="left">Item</th>
                                                    <th width="50%" align="left">Description</th>
                                                    <th width="9%" align="left">Size</th>
                                                    <th width="10%" align="right" class="text-right">Price</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                    <th width="7%" align="center" class="text-center">QTY</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </form>
                        </div>
                </div>
            </div>
            <div class="modal-footer">
               	<button type="button" id="createOrderUpdateHeaderBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="updateCreateOrderHeader()" ><div class="spinner spinner-light d-none"></div> Save </button> &nbsp;
                <button type="button" id="createOrderNextBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="popupForCreateOrderItem()" >Next <i class="icon-right-arrow ml-3"></i></button>
                <button type="button" id="createOrderBackBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" >Back</button> &nbsp;
                <button type="button" id="createOrderCompleteBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" onclick="saveCreateOrder()" ><div class="spinner spinner-light d-none"></div> Save </button>
            </div>
        </div>
    </div>
</div>

<div class="modal mx-100 w-100" id="CreateOrderItemListModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="CreateOrderItemListModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Add New Item</h5>
                <a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="CreateOrderItemListModalMsg" style="text-align: center; color: red;"></p>
                   	<form>
                       	<div class="row">
                           	<div class="col-md-12">
                               	<table id="CreateOrderItemListTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                   	role="grid" width="100%" aria-describedby="datatable-example_info">
                               		<thead>
                                       	<tr>
                                           	<th width="7%" align="right" class="text-right"></th>
                                            <th width="10%" align="left">Item</th>
                                            <th width="50%" align="left">Description</th>
                                            <th width="9%" align="left">Size</th>
                                            <th width="10%" align="right" class="text-right">Price</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
                                            <th width="7%" align="center" class="text-center">QTY</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
										</tr>
                               		</thead>
                                    <tbody>
                                    </tbody>
                          		</table>
                         	</div>
                 		</div>
               		</form>
              	</div>
          	</div>
	        <div class="modal-footer">
	        	<button type="button" id="createOrderItemAddBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="addCreateOrderItem()" ><div class="spinner spinner-light d-none"></div> Add </button>
	        </div>
		</div>
    </div>
</div>


<div class="modal" id="CreateOrderMessageModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="MessageModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
				<a href="javascript:closeMessageModal()" class="close small opacity-100 text-dark" aria-label="Close" ><i class="icon-close-flat small"></i></a>            
			</div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0" id="CreateOrderMessageModalErrorMsg">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal" id="CreateOrderDeleteConfirmHeaderModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<!-- <button type="button" class="btn-close" data-dismiss="modal"></button> -->
        		<a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this order?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="createOrderConfirmDeleteHeaderBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>



<div class="modal" id="CreateOrderDeleteConfirmItemModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<!-- <button type="button" class="btn-close" data-dismiss="modal"></button> -->
        		<a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this order item?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="createOrderConfirmDeleteItemBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>



<div class="modal mx-100 w-100" id="CreateTemplateModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Template# </h5> &nbsp;
                <h5 class="modal-title" id="quoteIdForTemplateHeader"> </h5>
                <a href="javascript:closeModal()" class="close small opacity-100 text-dark" aria-label="Close"><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="TemplateErrorMsg" style="text-align: center; color: red;"></p>
                        <div class="step-one d-block">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-4">Shipping Details</h5>
                                        </div>
                                        <div class="col-md-4">
                                        	<input type="hidden" name="templateModalCustPORequired" id="templateModalCustPORequired">
                                        	<input type="hidden" name="templateQuoteId" id="templateQuoteId">
                                        	<input type="hidden" name="templateShipToSeq" id="templateShipToSeq">
                                            <div class="form-group">
                                                <label for="shipToName">Ship to name</label>
                                                <input type="text" name="templateShipToName" id="templateShipToName" class="form-control" placeholder="Search"/>
                                            </div>
                                        </div>
                                        <div class="col-md-8">
                                            <div class="form-group">
                                                <label for="templateAddress1">Address 1 <span class="text-danger small">*</span> </label>
                                                <input type="text" name="templateAddressOne" id="templateAddressOne" class="form-control" />
                                            	<div class="invalid-feedback">Please enter address</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="templateAddress2">Address 2</label>
                                                <input type="text" class="form-control" name="templateAddressTwo" id="templateAddressTwo" value="" placeholder="Enter address line 2" >
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="templateCity">City <span class="text-danger small">*</span> </label> 
                                                <input type="text" class="form-control" name="templateCity" id="templateCity" value="" placeholder="Enter city" >
	                                            <div class="invalid-feedback">Please enter city</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="templateState">State <span class="text-danger small">*</span> </label>
                                                <input type="text" class="form-control" name="templateState" id="templateState" value="" placeholder="Enter state" >
                                            	<div class="invalid-feedback">Please enter state</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="templateZip">Zip <span class="text-danger small">*</span> </label>
                                                <input type="text" class="form-control" name="templateZip" id="templateZip" value="" placeholder="Enter zip code" >
	                                            <div class="invalid-feedback">Please enter zip</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateContactName">Contact name</label>
                                                <input type="text" class="form-control" name="templateMemoOne" id="templateMemoOne" value="" placeholder="Enter contact name" >
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateContactPhone">Phone</label>
                                                <input type="tel" class="form-control" name="templateMemoTwo" id="templateMemoTwo" value="" placeholder="Enter phone number" >
                                            </div>
                                        </div>

                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label>Ship Via <span class="text-danger small">*</span></label>
                                                <select name="templateShipVia" id="templateShipVia" class="form-control" >
													<option value="" selected>SELECT</option>
													<option value="RWC ROOFLOAD">ROOF LOAD</option>
													<option value="RWC GRNDROP">GROUND DROP</option>
	    										</select>
                                                <div class="invalid-feedback">Please Select ShipVia.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mb-1">
                                    <hr class="bg-light" />
                                </div>
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-3">Order Info</h5>
                                        </div>
                                        <!-- Group 2: Order Info -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateCustomerPO" id="templateCustomerPoLabel">Customer PO. </label>
                                                <input type="text" class="form-control" name="templateCustomerPo" id="templateCustomerPo" value="" placeholder="Enter customer PO">
                                                <div id="customerPOError" class="invalid-feedback">Please Enter Customer PO</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateReference">Reference</label>
                                                <input type="text" class="form-control" name="templateReferenceId" id="templateReferenceId" value="" placeholder="Enter reference">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateJobNo">Job no.</label>
                                                <input type="text" class="form-control" name="templateAddressThree" id="templateAddressThree" value="" placeholder="Enter job number">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="templateExpectedDelivery">Requested Delivery Date </label>
                                                <input type="text" class="form-control date-normalize" name="templateExpectedDeliveryDate" id="templateExpectedDeliveryDate" value="" pattern="\d{2}-\d{2}-\d{4}" title="Enter date as MM-DD-YYYY" maxlength="10" autocomplete="off">
                                            </div>
                                        </div>

                                        <!-- Group 3: Notes -->
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="templateNotes">Notes</label>
                                                <textarea name="templateNotes" id="templateNotes" value="" class="form-control" placeholder="Enter notes" rows="2" ></textarea>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="templateMessage">Message</label>
                                                <textarea name="templateMessage" id="templateMessage" value="" class="form-control" placeholder="Enter message" rows="2" ></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="step-two d-none" id="productModal">  
                            <button class="btn btn-outline-danger btn-sm mb-3" id="templateAddItemBtn" onclick="popupForNewTemplateItemList()" data-toggle="modal" data-target="#TemplateItemListModal"><i class="icon-plus"></i>Add</button>
                            <form>
                                <div class="row">
                                    <div class="col-md-12">
                                        <table id="CreateTemplateItemTable"
                                            class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                            role="grid" width="100%" aria-describedby="datatable-example_info">
                                            <thead>
                                                <tr>
                                                    <th width="7%" align="right" class="text-right"></th>
                                                    <th width="10%" align="left">Item</th>
                                                    <th width="50%" align="left">Description</th>
                                                    <th width="9%" align="left">Size</th>
                                                    <th width="10%" align="right" class="text-right">Price</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </form>
                        </div>
                </div>
            </div>
            <div class="modal-footer">
               	<button type="button" id="templateUpdateQuoteHeaderBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="updateTemplateHeader()" ><div class="spinner spinner-light d-none"></div> Save </button> &nbsp;
                <button type="button" id="templateNextBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="popupForTemplateItem()" >Next <i class="icon-right-arrow ml-3"></i></button>
                <button type="button" id="templateBackBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" >Back</button> &nbsp;
                <button type="button" id="templateCompleteBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" onclick="saveTemplate()" ><div class="spinner spinner-light d-none"></div> Save </button>
				<button type="button" id="templateCloseBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" onclick="closeModal()"> Close </button>
            </div>
        </div>
    </div>
</div>

<div class="modal mx-100 w-100" id="TemplateItemListModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Add New Item</h5>
                <a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="TemplateItemListModalMsg" style="text-align: center; color: red;"></p>
                   	<form>
                       	<div class="row">
                           	<div class="col-md-12">
                               	<table id="TemplateItemListTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                   	role="grid" width="100%" aria-describedby="datatable-example_info">
                               		<thead>
                                       	<tr>
                                           	<th width="7%" align="right" class="text-right"></th>
                                            <th width="10%" align="left">Item</th>
                                            <th width="50%" align="left">Description</th>
                                            <th width="9%" align="left">Size</th>
                                            <th width="10%" align="right" class="text-right">Price</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
										</tr>
                               		</thead>
                                    <tbody>
                                    </tbody>
                          		</table>
                         	</div>
                 		</div>
               		</form>
              	</div>
          	</div>
	        <div class="modal-footer">
	        	<button type="button" id="addItemBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="addTemplateItem()" ><div class="spinner spinner-light d-none"></div> Add </button>
	        </div>
		</div>
    </div>
</div>


<div class="modal" id="TemplateMessageModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="MessageModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
				<a href="javascript:closeMessageModal()" class="close small opacity-100 text-dark" aria-label="Close"><i class="icon-close-flat small"></i></a>            
			</div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0" id="TemplateMessageModalErrorMsg">
		        		<!-- <h5 class="modal-title text-center" id=""><img src="NewPortalAssets/assets/images/icons/success-icon.png" width="70px" alt="" ></h5> -->
		          		<!-- <div class="bg-success-subtle p-3 text-center">
			          		<img src="NewPortalAssets/assets/images/icons/success-icon.png" width="70px" alt="" class="mb-3">
			         		<p id="errorMsg" class="mb-0"></p>
		          		</div> -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal" id="TemplateDeleteConfirmHeaderModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<!-- <button type="button" class="btn-close" data-dismiss="modal"></button> -->
        		<a href="javascript:closeModal()" class="close small opacity-100 text-dark" aria-label="Close" ><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this template?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="templateConfirmDeleteHeaderBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>

<div class="modal" id="TemplateDeleteConfirmItemModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<!-- <button type="button" class="btn-close" data-dismiss="modal"></button> -->
        		<a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this item?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="templateConfirmDeleteItemBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>


<div class="modal mx-100 w-100" id="QuoteEntryModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="quoteEntryCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="quoteEntryModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Quote Entry </h5> &nbsp;
                <h5 class="modal-title" id="quoteIdForQuoteEntryHeader"> </h5>
                <a href="javascript:closeModal()" class="close small opacity-100 text-dark" aria-label="Close" ><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="QuoteEntryErrorMsg" style="text-align: center; color: red;"></p>
                        <div class="step-one d-block">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-4">Shipping Details</h5>
                                        </div>
                                        <div class="col-md-4">
                                        	<input type="hidden" name="quoteEntryModalCustPORequired" id="quoteEntryModalCustPORequired">
                                        	<input type="hidden" name="quoteEntryQuoteId" id="quoteEntryQuoteId">
                                        	<input type="hidden" name="quoteEntryShipToSeq" id="quoteEntryShipToSeq">
                                            <div class="form-group">
                                                <label for="quoteEntryShipToName">Ship to name</label>
                                                <input type="text" name="quoteEntryShipToName" id="quoteEntryShipToName" class="form-control" placeholder="Search"/>
                                            </div>
                                        </div>
                                        <div class="col-md-8">
                                            <div class="form-group">
                                                <label for="quoteEntryAddress1">Address 1 <span class="text-danger small">*</span></label>
                                                <input type="text" name="quoteEntryAddressOne" id="quoteEntryAddressOne" class="form-control" />
                                            	<div class="invalid-feedback">Please enter address</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="quoteEntryAddress2">Address 2</label>
                                                <input type="text" class="form-control" name="quoteEntryAddressTwo" id="quoteEntryAddressTwo" value="" placeholder="Enter address line 2" >
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="quoteEntryCity">City <span class="text-danger small">*</span></label> 
                                                <input type="text" class="form-control" name="quoteEntryCity" id="quoteEntryCity" value="" placeholder="Enter city" >
	                                            <div class="invalid-feedback">Please enter city</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="quoteEntryState">State <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="quoteEntryState" id="quoteEntryState" value="" placeholder="Enter state" >
                                            	<div class="invalid-feedback">Please enter state</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="quoteEntryZip">Zip <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="quoteEntryZip" id="quoteEntryZip" value="" placeholder="Enter zip code" >
	                                            <div class="invalid-feedback">Please enter zip</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryContactName">Contact name</label>
                                                <input type="text" class="form-control" name="quoteEntryMemoOne" id="quoteEntryMemoOne" value="" placeholder="Enter contact name" >
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryContactPhone">Phone</label>
                                                <input type="tel" class="form-control" name="quoteEntryMemoTwo" id="quoteEntryMemoTwo" value="" placeholder="Enter phone number" >
                                            </div>
                                        </div>

                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label>Ship Via <span class="text-danger small">*</span></label>
                                                <select name="quoteEntryShipVia" id="quoteEntryShipVia" class="form-control" >
													<option value="" selected>SELECT</option>
													<option value="RWC ROOFLOAD">ROOF LOAD</option>
													<option value="RWC GRNDROP">GROUND DROP</option>
	    										</select>
                                                <div class="invalid-feedback">Please Select ShipVia.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mb-1">
                                    <hr class="bg-light" />
                                </div>
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-3">Order Info</h5>
                                        </div>
                                        <!-- Group 2: Order Info -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryCustomerPO" id="quoteEntryCustomerPoLabel">Customer PO. </label>
                                                <input type="text" class="form-control" name="quoteEntryCustomerPo" id="quoteEntryCustomerPo" value="" placeholder="Enter customer PO">
                                                <div id="quoteEntryCustomerPOError" class="invalid-feedback">Please Enter Customer PO</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryReference">Reference</label>
                                                <input type="text" class="form-control" name="quoteEntryReferenceId" id="quoteEntryReferenceId" value="" placeholder="Enter reference">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryJobNo">Job no.</label>
                                                <input type="text" class="form-control" name="quoteEntryAddressThree" id="quoteEntryAddressThree" value="" placeholder="Enter job number">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="quoteEntryExpectedDelivery">Requested Delivery Date </label>
                                                <input type="text" class="form-control date-normalize" name="quoteEntryExpectedDeliveryDate" id="quoteEntryExpectedDeliveryDate" value="" pattern="\d{2}-\d{2}-\d{4}" title="Enter date as MM-DD-YYYY" maxlength="10" autocomplete="off">
                                            </div>
                                        </div>

                                        <!-- Group 3: Notes -->
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="quoteEntryNotes">Notes</label>
                                                <textarea name="quoteEntryNotes" id="quoteEntryNotes" value="" class="form-control" placeholder="Enter notes" rows="2" ></textarea>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="quoteEntryMessage">Message</label>
                                                <textarea name="quoteEntryMessage" id="quoteEntryMessage" value="" class="form-control" placeholder="Enter message" rows="2" ></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="step-two d-none" id="QuoteEntryProductModal">  
                            <button class="btn btn-outline-danger btn-sm mb-3" id="quoteEntryAddItemBtn" onclick="popupForNewQuoteEntryItemList()" data-toggle="modal" data-target="#QuoteEntryItemListModal"><i class="icon-plus"></i>Add</button>
                            <form>
                                <div class="row">
                                    <div class="col-md-12">
                                        <table id="QuoteEntryItemTable"
           									class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                  			role="grid" width="100%" aria-describedby="datatable-example_info">
                                            <thead>
                                                <tr>
                                                    <th width="7%" align="right" class="text-right"></th>
                                                    <th width="10%" align="left">Item</th>
                                                    <th width="50%" align="left">Description</th>
                                                    <th width="9%" align="left">Size</th>
                                                    <th width="10%" align="right" class="text-right">Price</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                    <th width="7%" align="center" class="text-center">QTY</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </form>
                        </div>
                </div>
            </div>
            <div class="modal-footer">
               	<button type="button" id="quoteEntryUpdateHeaderBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="updateQuoteEntryHeader()" ><div class="spinner spinner-light d-none"></div> Save </button> &nbsp;
                <button type="button" id="quoteEntryNextBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="popupForQuoteEntryItem()" >Next <i class="icon-right-arrow ml-3"></i></button>
                <button type="button" id="quoteEntryBackBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" >Back</button> &nbsp;
                <button type="button" id="quoteEntryCompleteBtn" class="btn btn-lg btn-danger rounded-lg m-0 d-none" onclick="saveQuoteEntry()" ><div class="spinner spinner-light d-none"></div> Save </button>
            </div>
        </div>
    </div>
</div>

<div class="modal mx-100 w-100" id="QuoteEntryItemListModal" data-backdrop="static" data-keyboard="false"  tabindex="-1" role="dialog"
    aria-labelledby="quoteEntryCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="QuoteEntryItemListModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Add New Item</h5>
                <a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                	<p id="QuoteEntryItemListModalMsg" style="text-align: center; color: red;"></p>
                   	<form>
                       	<div class="row">
                           	<div class="col-md-12">
                               	<table id="QuoteEntryItemListTable" class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                   	role="grid" width="100%" aria-describedby="datatable-example_info">
                               		<thead>
                                       	<tr>
                                           	<th width="7%" align="right" class="text-right"></th>
                                            <th width="10%" align="left">Item</th>
                                            <th width="50%" align="left">Description</th>
                                            <th width="9%" align="left">Size</th>
                                            <th width="10%" align="right" class="text-right">Price</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
                                            <th width="7%" align="center" class="text-center">QTY</th>
                                            <th width="7%" align="center" class="text-center">UOM</th>
										</tr>
                               		</thead>
                                    <tbody>
                                    </tbody>
                          		</table>
                         	</div>
                 		</div>
               		</form>
              	</div>
          	</div>
	        <div class="modal-footer">
	        	<button type="button" id="quoteEntryItemAddBtn" class="btn btn-lg btn-danger rounded-lg m-0" onclick="addQuoteEntryItem()" ><div class="spinner spinner-light d-none"></div> Add </button>
	        </div>
		</div>
    </div>
</div>


<div class="modal" id="QuoteEntryMessageModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="MessageModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
				<a href="javascript:closeMessageModal()" class="close small opacity-100 text-dark" aria-label="Close" ><i class="icon-close-flat small"></i></a>            
			</div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0" id="QuoteEntryMessageModalErrorMsg">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal" id="QuoteEntryDeleteConfirmHeaderModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<!-- <button type="button" class="btn-close" data-dismiss="modal"></button> -->
        		<a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this quote?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="quoteEntryConfirmDeleteHeaderBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>



<div class="modal" id="QuoteEntryDeleteConfirmItemModal" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
    	<div class="modal-content">
      		<div class="modal-header">
        		<h5 class="modal-title">Confirm Deletion</h5>
        		<a href="#" class="close small opacity-100 text-dark" aria-label="Close" data-dismiss="modal"><i class="icon-close-flat small"></i></a>
      		</div>
      		<div class="modal-body">
        		Are you sure you want to delete this quote item?
      		</div>
      		<div class="modal-footer">
        		<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        		<button type="button" class="btn btn-danger" id="quoteEntryConfirmDeleteItemBtn">Delete</button>
      		</div>
    	</div>
  	</div>
</div>


<div class="modal mx-100 w-100" id="createOrder" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog"
    aria-labelledby="createOrderCenterTitle" aria-hidden="true">
    <div class="modal-dialog w-100 modal-dialog-centered mw-100" role="document">
        <div class="modal-content rounded-0 mx-md-4">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Create New Order</h5>
				<div class="d-flex align-items-center gap-3 flex-wrap">
				
				    <a href="javascript:showHelpModal()" class="text-nowrap mr-2" title="Help"><i class="bi bi-question-circle fs-4" style="font-size: 45px;"></i></a>

				    <!-- Upload Text -->
				    <!-- <span class="fw-semibold text-dark">Upload PO</span> -->
				
				    <!-- Hidden File Input -->
				    <input type="file"
				           name="documentFile"
				           id="documentFile"
				           class="d-none"
				           required
				           onchange="document.getElementById('fileNameText').innerText = this.files[0].name || 'No file chosen'">
				
				    <!-- Upload Button -->
				    <label for="documentFile"
				           class="btn btn-danger btn-sm d-flex align-items-center gap-2 px-3">
				
				        <!-- Bootstrap Icon -->
				        <i class="bi bi-cloud-upload-fill"></i>
				
				        <!-- <span>Choose File</span> -->
				    </label> &nbsp;
				
				    <!-- File Name -->
				    <span id="fileNameText" class="text-muted small">
				        No file chosen
				    </span>

				
				    <a href="javascript:closeModal()"
				       class="close small opacity-100 text-dark"
				       aria-label="Close">
				        <i class="icon-close-flat small"></i>
				    </a>
				
				</div>
            </div>
            <div class="modal-body px-0">
                <div class="container">
                        <div class="step-one d-block">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-4">Shipping Details</h5>
                                        </div>
                                        <div class="col-md-4">
                                        	<input type="hidden" name="modalQuoteId" id="modalQuoteId">
											<input type="hidden" name="modalCustPORequired" id="modalCustPORequired">
                                        
                                            <div class="form-group">
                                                <label for="shipToName">Ship to name</label>
                                                <input type="text" class="form-control" name="shipToName" id="shipToName"
                                                    placeholder="Enter ship to name">
                                            </div>
                                        </div>
                                        <div class="col-md-8">
                                            <div class="form-group">
                                                <label for="address1">Address 1 <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="addressOne" id="addressOne" value="" placeholder="Enter address line 1">
                                            	<div class="invalid-feedback">Please Enter Address 1.</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="address2">Address 2</label>
                                                <input type="text" class="form-control" name="addressTwo" id="addressTwo" value="" placeholder="Enter address line 2">
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="city">City <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="city" id="city" value="" placeholder="Enter city">
                                               	<div class="invalid-feedback">Please Enter City.</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="state">State <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="state" id="state" value="" placeholder="Enter state">
                                               	<div class="invalid-feedback">Please Enter State.</div>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="zip">Zip <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control" name="zip" id="zip" value="" placeholder="Enter zip code">
                                               	<div class="invalid-feedback">Please Enter Zip.</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="contactName">Contact name</label>
                                                <input type="text" class="form-control" name="memoOne" id="memoOne" value=""
                                                    placeholder="Enter contact name">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="contactPhone">Phone</label>
                                                <input type="tel" class="form-control" name="memoTwo" id="memoTwo" value=""
                                                    placeholder="Enter phone number">
                                            </div>
                                        </div>

                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label>Ship Via <span class="text-danger small">*</span></label>
                                                <select name="shipViaNew" id="shipViaNew" class="form-control" >
													<option value="" selected>SELECT</option>
													<option value="RWC ROOFLOAD">ROOF LOAD</option>
													<option value="RWC GRNDROP">GROUND DROP</option>
	    										</select>
                                                <div class="invalid-feedback">Please Select Ship VIA.</div>
                                                
                                                <!-- <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                                    <label class="btn btn-sm btn-outline-danger">
                                                        <input type="radio" name="options" id="option1" value="RWC ROOFLOAD"
                                                            autocomplete="roofLoad" checked> Roof Load
                                                    </label>
                                                    <label class="btn btn-sm btn-outline-danger">
                                                        <input type="radio" name="options" id="option2" value="RWC GRNDROP"
                                                            autocomplete="groundDrop"> Ground Drop
                                                    </label>
                                                </div> -->
                                            
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mb-1">
                                    <hr class="bg-light" />
                                </div>
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h5 class="text-danger mb-3">Order Info</h5>
                                        </div>
                                        <!-- Group 2: Order Info -->
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="customerPO" id="customerPOLabel">Customer PO. </label>
                                                <input type="text" class="form-control" name="customerPo" id="customerPo" value="" placeholder="Enter customer PO">
                                                <div id="customerPOError" class="invalid-feedback">Please enter Customer PO</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="reference">Reference</label>
                                                <input type="text" class="form-control" name="referenceId" id="referenceId" value=""
                                                    placeholder="Enter reference">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="jobNo">Job no.</label>
                                                <input type="text" class="form-control" name="addressThree" id="addressThree" value=""
                                                    placeholder="Enter job number">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="expectedDelivery">Expected Delivery Date <span class="text-danger small">*</span></label>
                                                <input type="text" class="form-control date-normalize" name="expectedDeliveryDate" id="expectedDeliveryDate" value="" pattern="\d{2}-\d{2}-\d{4}" title="Enter date as MM-DD-YYYY" maxlength="10">
                                            	<div class="invalid-feedback">Please enter a valid date in MM-DD-YYYY format.</div>
                                            </div>
                                        </div>

                                        <!-- Group 3: Notes -->
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="notes">Notes</label>
                                                <textarea name="notes" id="notes" value="" class="form-control" placeholder="Enter notes"
                                                    rows="2"></textarea>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="message">Message</label>
                                                <textarea name="message" id="message" value="" class="form-control" placeholder="Enter message"
                                                    rows="2"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="step-two d-none" id="productModal">                            
                            <form>
                                <div class="row">
                                    <div class="col-md-12">
                                        <table id="CreateOrderTable"
                                            class="table border border-top-0 table-grid tab-Table FINdatatableStyle"
                                            role="grid" width="100%" aria-describedby="datatable-example_info">
                                            <thead>
                                                <tr>
                                                    <th width="10%" align="left">Item</th>
                                                    <th width="50%" align="left">Description</th>
                                                    <th width="9%" align="left">Size</th>
                                                    <th width="10%" align="right" class="text-right">Price</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                    <th width="7%" align="right" class="text-right">QTY</th>
                                                    <th width="7%" align="center" class="text-center">UOM</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </form>
                        </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" id="backBtn" class="btn btn-lg btn-outline-danger m-0 rounded-lg mr-2 d-none">Back</button>
                <button type="button" id="nextBtn" onclick="popupForProduct()" class="btn btn-lg btn-danger rounded-lg m-0">Next <i class="icon-right-arrow ml-3"></i></button>
                <button type="button" id="completeBtn" onclick="saveOrder()" class="btn btn-danger btn-lg rounded-lg m-0 d-none"><div class="spinner spinner-light d-none"></div> Save Order</button>
            </div>
        </div>
    </div>
</div>


<div class="modal" id="MessageModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="MessageModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
				<a href="javascript:closeMessageModal()" class="close small opacity-100 text-dark" aria-label="Close"><i class="icon-close-flat small"></i></a>            
			</div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0" id="errorMsg">
		        		<!-- <h5 class="modal-title text-center" id=""><img src="NewPortalAssets/assets/images/icons/success-icon.png" width="70px" alt="" ></h5> -->
		          		<!-- <div class="bg-success-subtle p-3 text-center">
			          		<img src="NewPortalAssets/assets/images/icons/success-icon.png" width="70px" alt="" class="mb-3">
			         		<p id="errorMsg" class="mb-0"></p>
		          		</div> -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

	<div class="modal mx-100 w-100" id="orderInformation" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog"
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
	                                        <h6 class="m-0 text-nowrap pr-xl-5 font-weight-bold"> Ordered By </h6>
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
	                <button type="button" data-dismiss="modal" class="btn btn-lg btn-danger m-0 rounded-lg">Close</button>
	            </div>
	        </div>
	    </div>
	</div>




	<div class="modal mx-100 w-100" id="HelpModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog"
	    aria-labelledby="HelpModalTitle" aria-hidden="true">
	    <div class="modal-dialog modal-xl custom-help-modal modal-dialog-centered" role="document">
	        <div class="modal-content rounded-0 mx-md-4">
	            <div class="modal-header">
	                <!-- <h5 class="modal-title" id="exampleModalCenterTitle"><img src="NewPortalAssets/assets/images/icons/create-order.png" width="40px" alt=""> Create New Order</h5> -->
	               	<a href="javascript:closeHelpModal()" class="close small opacity-100 text-dark" aria-label="Close"><i class="icon-close-flat small"></i></a>
	            </div>
				<div class="modal-body px-0">
				    <div class="container py-3">
				        <!-- <h5 class="mb-4 text-center">Help Videos</h5> -->
				        <div class="row">
				            <!-- Video 1 -->
				            <div class="col-6 col-md-3 mb-3">
				                <a href="/tutorials/Creating_A_Sales_Order_Tutorial.mp4"
				                   target="_blank"
				                   class="text-decoration-none">
				
				                    <div class="card shadow-sm border-0 video-tile">
				
				                        <video class="w-100" muted preload="metadata">
				                            <source src="/tutorials/Creating_A_Sales_Order_Tutorial.mp4" type="video/mp4">
				                        </video>
				
				                        <div class="card-body text-center">
				                            <h6 class="mb-0 text-dark">
				                                Creating A Sales Order Tutorial
				                            </h6>
				                        </div>
				
				                    </div>
				
				                </a>
				
				            </div>
				
				            <!-- Video 2 -->
				            <div class="col-6 col-md-3 mb-3">
				
				                <a href="/tutorials/Creating_a_Template.mp4"
				                   target="_blank"
				                   class="text-decoration-none">
				
				                    <div class="card shadow-sm border-0 video-tile">
				
				                        <video class="w-100" muted preload="metadata">
				                            <source src="/tutorials/Creating_a_Template.mp4" type="video/mp4">
				                        </video>
				
				                        <div class="card-body text-center">
				                            <h6 class="mb-0 text-dark">
				                                Creating a Template
				                            </h6>
				                        </div>
				
				                    </div>
				
				                </a>
				
				            </div>
				
				            <!-- Video 3 -->
				            <div class="col-6 col-md-3 mb-3">
				
				                <a href="/tutorials/Creating_a_Sales_Order_From_a_Template.mp4"
				                   target="_blank"
				                   class="text-decoration-none">
				
				                    <div class="card shadow-sm border-0 video-tile">
				
				                        <video class="w-100" muted preload="metadata">
				                            <source src="/tutorials/Creating_a_Sales_Order_From_a_Template.mp4" type="video/mp4">
				                        </video>
				
				                        <div class="card-body text-center">
				                            <h6 class="mb-0 text-dark">
				                                Creating a Sales Order From a Template
				                            </h6>
				                        </div>
				
				                    </div>
				
				                </a>
				
				            </div>
				
				            <!-- Video 4 -->
				            <div class="col-6 col-md-3 mb-3">
				
				                <a href="/tutorials/RWC_Shop_Tutorial_Videos.mp4"
				                   target="_blank"
				                   class="text-decoration-none">
				
				                    <div class="card shadow-sm border-0 video-tile">
				
				                        <video class="w-100" muted preload="metadata">
				                            <source src="/tutorials/RWC_Shop_Tutorial_Videos.mp4" type="video/mp4">
				                        </video>
				
				                        <div class="card-body text-center">
				                            <h6 class="mb-0 text-dark">
				                                RWC Shop Tutorial Videos
				                            </h6>
				                        </div>
				
				                    </div>
				
				                </a>
				
				            </div>
				
				        </div>
				
				    </div>
				</div>
	            
	            <div class="modal-footer">
	                <button type="button" id="helpModalBtn" onclick="closeHelpModal()" class="btn btn-lg btn-outline-danger m-0 rounded-lg mr-2 d-none">Close</button>
	            </div>
	        </div>
	    </div>
	</div>




<!-- START FOOTER-->
<script src="https://cdnjs.cloudflare.com/ajax/libs/inputmask/5.0.7/jquery.inputmask.min.js"></script>
<%@ include file="A_CP_Footer.jsp" %>
<!-- END FOOTER-->
	  
	 <script>
		var fullYear;
		document.getElementById('expectedDeliveryDate').addEventListener('blur', function () {
		    const input = document.getElementById("expectedDeliveryDate").value.trim();
		
		    // Match MM-DD-YY or MM-DD-YYYY
		    const shortYearPattern = /^(\d{2})-(\d{2})-(\d{2})$/;
		    const match = input.match(shortYearPattern);
		
		    if (match) {
		        const mm = match[1];
		        const dd = match[2];
		        const yy = match[3];
		        
				if(yy.length == 2){
					if(parseInt(yy) < 50)
						fullYear="20"+yy;
			   		else
			   			fullYear="19"+yy;
			  	}
				else{
					fullYear=yy;
				}
		
		        // Convert to 2000+ format. You can adjust logic if needed.
		        //const fullYear = '20' + yy;
		        $('#expectedDeliveryDate').val(mm+'-'+(dd)+'-'+fullYear.trim());
		        //document.getElementById("expectedDeliveryDate").value = mm+'-'+(dd)+'-'+fullYear;
		    }
		});
		
		document.getElementById('templateExpectedDeliveryDate').addEventListener('blur', function () {
		    const input = document.getElementById("expectedDeliveryDate").value.trim();
		
		    // Match MM-DD-YY or MM-DD-YYYY
		    const shortYearPattern = /^(\d{2})-(\d{2})-(\d{2})$/;
		    const match = input.match(shortYearPattern);
		
		    if (match) {
		        const mm = match[1];
		        const dd = match[2];
		        const yy = match[3];
		        
				if(yy.length == 2){
					if(parseInt(yy) < 50)
						fullYear="20"+yy;
			   		else
			   			fullYear="19"+yy;
			  	}
				else{
					fullYear=yy;
				}
		
		        // Convert to 2000+ format. You can adjust logic if needed.
		        //const fullYear = '20' + yy;
		        $('#templateExpectedDeliveryDate').val(mm+'-'+(dd)+'-'+fullYear.trim());
		        //document.getElementById("expectedDeliveryDate").value = mm+'-'+(dd)+'-'+fullYear;
		    }
		});
		
	</script>
	  
	  
	  
	<script type="text/javascript">
	    var soIdTemp,orderId,shipmentId;
		var id,today;
		var rowIndex;
		var createOrderQuoteId,templateQuoteId,quoteEntryQuoteId,quoteIdVar,custPORequiredVar;
		var custPORequiredForOrderAndTemplate=<%=custPoRequired%>;
		var custKey='<%=custKey%>';
		var addedCreateOrderItemArray=[],addedItemArray=[];

		$(document).ready(function(){
	  		//hideDateFilter();
	  		var now = new Date();
		    var mm=now.getMonth() + 1;
			if(parseInt(mm)<10)
				mm='0'+mm;
			
			var dd=now.getDate();
			if(parseInt(dd)<10)
				dd='0'+dd;
			today = mm + '-' + (dd) + '-' + now.getFullYear();
			
			$('#expectedDeliveryDate').val(today);
			$('#expectedDeliveryDate').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				minDate: "0"
			});

			$('#createOrderExpectedDeliveryDate').val(today);
			$('#templateExpectedDeliveryDate').val(today);
			$('#quoteEntryExpectedDeliveryDate').val(today);
			$('#createOrderExpectedDeliveryDate,#templateExpectedDeliveryDate,#quoteEntryExpectedDeliveryDate').datepicker({
            	changeMonth: true,
				changeYear: true,
				dateFormat: 'mm-dd-yy',
            	numberOfMonths: 1,
				minDate: "0"
			});
			
			$('#CreateNewOrderTable,#CreateNewTemplateTable,#QuoteEntryTable').DataTable({
				'pageLength': 25,
				"aaSorting": [[ 2, "desc" ]],
				'dom': 'Blfrtip',
			    'buttons': [
			            /* 'copy', 'csv', 'excel' */
			            //'copyHtml5', 'excelHtml5', 'pdfHtml5', 'csvHtml5'
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

		    // Initially hide back and complete buttons
	        $('#backBtn').addClass('d-none');
	        $('#completeBtn').addClass('d-none');
	 
	        // Go to Step 2
	        $('#nextBtn').click(function(){
		        //$('.step-one').removeClass('d-block').addClass('d-none');
		        //$('.step-two').removeClass('d-none').addClass('d-block');
		 	});
		 
		    // Go back to Step 1
		    $('#backBtn').click(function(){
		        $('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-none').addClass('d-block');
		 
		        $('#backBtn').addClass('d-none');
		        $('#nextBtn').removeClass('d-none');
		        $('#completeBtn').addClass('d-none');
	        });
		    
		    $('.dataTables_filter input').attr('placeholder', 'Search items...');
		    
		    const input = document.getElementById('expectedDeliveryDate');
		    input.addEventListener('input', function (e) {
		      let value = input.value.replace(/\D/g, ''); // Remove non-digits
		      if (value.length > 8) value = value.slice(0, 8); // Limit to 8 digits

		      // Auto-insert dashes as user types
		      let formatted = '';
		      if (value.length > 0) formatted = value.slice(0, 2);
		      if (value.length > 2) formatted += '-' + value.slice(2, 4);
		      if (value.length > 4) formatted += '-' + value.slice(4, 8);

		      input.value = formatted;
		    });
			
	        $('#createOrderBackBtn').addClass('d-none');
	        $('#createOrderCompleteBtn').addClass('d-none');
	 
	        // Go to Step 2
	        $('#createOrderNextBtn').click(function(){
	        	//$('#createOrderUpdateHeaderBtn').addClass('d-none');
		 	});
		 
		    // Go back to Step 1
		    $('#createOrderBackBtn').click(function(){
		        $('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-none').addClass('d-block');
		 
		        $('#createOrderUpdateHeaderBtn').removeClass('d-none');
		        $('#createOrderBackBtn').addClass('d-none');
		        $('#createOrderNextBtn').removeClass('d-none');
		        $('#createOrderCompleteBtn').addClass('d-none');
	        });
		    
		    // Initially hide back and complete buttons
	        $('#templateBackBtn').addClass('d-none');
	        $('#templateCompleteBtn').addClass('d-none');
	 
	        // Go to Step 2
	        $('#templateNextBtn').click(function(){
	        	//$('#templateUpdateQuoteHeaderBtn').addClass('d-none');
		 	});
		 
		    // Go back to Step 1
		    $('#templateBackBtn').click(function(){
		        $('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-none').addClass('d-block');
		 
		        $('#templateUpdateQuoteHeaderBtn').removeClass('d-none');
		        $('#templateBackBtn').addClass('d-none');
		        $('#templateNextBtn').removeClass('d-none');
		        $('#templateCompleteBtn').addClass('d-none');
		        $('#templateCloseBtn').addClass('d-none');
	        });
		    
	        $('#quoteEntryBackBtn').addClass('d-none');
	        $('#quoteEntryCompleteBtn').addClass('d-none');
	 
	        $('#quoteEntryNextBtn').click(function(){
	        	//$('#quoteEntryUpdateHeaderBtn').addClass('d-none');
		 	});
		 
		    $('#quoteEntryBackBtn').click(function(){
		        $('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-none').addClass('d-block');
		 
		        $('#quoteEntryUpdateHeaderBtn').removeClass('d-none');
		        $('#quoteEntryBackBtn').addClass('d-none');
		        $('#quoteEntryNextBtn').removeClass('d-none');
		        $('#quoteEntryCompleteBtn').addClass('d-none');
	        });
		    
	        $(".nav-link").click(function () {
	            // remove active class from all tabs
	            $(".nav-link").removeClass("active");
	            // add active class to clicked tab
	            $(this).addClass("active");

	            // hide all content
	            $(".tab-pane").removeClass("active");
	            // show the targeted content
	            var target = $(this).data("target");
	            $(target).addClass("active");
	        });
		    
		    $('.dataTables_filter input').attr('placeholder', 'Search items...');
		    
			/* $("#createOrderShipToName").autocomplete({
				autoFocus: true,
			    source: "../customerPortal/getShipToName.jsp",
			    appendTo: "#CreateOrderModal",
			    minLength: 3,
			    focus: function( event, ui ) { return false},
				//source: availableTags,
				select: function( event, ui ) {
					$('#createOrderShipToSeq').val(ui.item.shipToSeq);
			        $('#createOrderShipToName').val(ui.item.value);
			        $('#createOrderAddressOne').val(ui.item.addressOne);
			        $('#createOrderCity').val(ui.item.city);
			        $('#createOrderState').val(ui.item.state);
			        $('#createOrderZip').val(ui.item.zip);
			        //$('#createOrderShipVia').val(ui.item.shipVia);
			        $('#createOrderCustomerPo').val(ui.item.customerPO);
					//userDetails();
					return false;
				}
			}); */
			
			/* $("#templateShipToName").autocomplete({
				autoFocus: true,
			    source: "../customerPortal/getShipToName.jsp",
			    appendTo: "#CreateTemplateModal",
			    minLength: 3,
			    focus: function( event, ui ) { return false},
				//source: availableTags,
				select: function( event, ui ) {
					$('#templateShipToSeq').val(ui.item.shipToSeq);
			        $('#templateShipToName').val(ui.item.value);
			        $('#templateAddressOne').val(ui.item.addressOne);
			        $('#templateCity').val(ui.item.city);
			        $('#templateState').val(ui.item.state);
			        $('#templateZip').val(ui.item.zip);
			        //$('#templateShipVia').val(ui.item.shipVia);
			        $('#templateCustomerPo').val(ui.item.customerPO);
					//userDetails();
					return false;
				}
			}); */ 

			/* $("#templateAddressOne").autocomplete({
				autoFocus: true,
			    source: "../customerPortal/getAddressOne.jsp",
			    appendTo: "#CreateTemplateModal",
			    minLength: 3,
			    focus: function( event, ui ) { return false},
				//source: availableTags,
				select: function( event, ui ) {
					document.getElementById('templateAddressOne').value = ui.item.value;
					//userDetails(userId);
					return false;
				}
			}); */ 

		}); 	

		document.getElementById("createOrderShipToName").addEventListener("keyup", function() {
	    	this.value = this.value.toUpperCase();
	    });

		document.getElementById("templateShipToName").addEventListener("keyup", function() {
	    	this.value = this.value.toUpperCase();
	    });

		document.getElementById("quoteEntryShipToName").addEventListener("keyup", function() {
	    	this.value = this.value.toUpperCase();
	    });

	    document.getElementById("templateAddressOne").addEventListener("keyup", function() {
	    	this.value = this.value.toUpperCase();
	    });

        function userDetails(){
			$('#templateAddressOne').val('');
			$('#templateCity').val('');
			$('#templateState').val('');
			$('#templateZip').val('');
			//$('#templateExpectedDeliveryDate').val('');
        	$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_ShopAction.jsp?param=CustomerDetails",
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#templateAddressOne').val(response.addressOne);
					$('#templateCity').val(response.city);
					$('#templateState').val(response.state);
					$('#templateZip').val(response.zip);
					//$('#templateExpectedDeliveryDate').val(response.expectedDeliveryDate);
				},
				failure: function (response) {
				}
			});
        }

        function popupForCreateOrderHeaderDetail(){
        	createOrderQuoteId="";
        	$('#CreateOrderErrorMsg').html('');
 			$('#createOrderAddressOne,#createOrderCity,#createOrderState,#createOrderZip,#createOrderShipVia,#createOrderCustomerPo').removeClass('is-invalid');
        	$("#createOrderUpdateHeaderBtn").hide();
        	$("#createOrderAddItemBtn").hide();
        	
        	$('#createOrderShipToName').val('').focus();
			$('#createOrderAddressOne').val('');
			$('#createOrderAddressTwo').val('');
			$('#createOrderCity').val('');
			$('#createOrderState').val('');
			$('#createOrderZip').val('');
			$('#createOrderMemoOne').val('');
			$('#createOrderMemoTwo').val('');
			$('#createOrderShipVia').val('');
			$('#createOrderCustomerPo').val('');
			$('#createOrderReferenceId').val('');
			$('#createOrderAddressThree').val('');
			//$('#createOrderExpectedDeliveryDate').val('');
			$('#createOrderNotes').val('');
			$('#createOrderMessage').val('');
			
			$("#quoteIdForCreateOrderHeader").hide().text("");
			$('#createOrderQuoteId').val('');
			
			$('#createOrderAddressOne').prop('readonly', false);
			$('#createOrderAddressTwo').prop('readonly', false);
			$('#createOrderCity').prop('readonly', false);
			$('#createOrderState').prop('readonly', false);
			$('#createOrderZip').prop('readonly', false);
			$('#createOrderMemoOne').prop('readonly', false);
			$('#createOrderMemoTwo').prop('readonly', false);
			$('#createOrderNotes').prop('readonly', false);
			$('#createOrderMessage').prop('readonly', false);
        }
        
        function popupForCreateOrderItem(){
        	debugger;
        	addedCreateOrderItemArray=[];
 			var modalCustPORequired = $('#createOrderModalCustPORequired').val().trim();
			var shipVia = $('#createOrderShipVia').val().trim();
 			var customerPo = $('#createOrderCustomerPo').val().trim();
 			var addressOne = $('#createOrderAddressOne').val().trim();
 			var city = $('#createOrderCity').val().trim();
 			var state = $('#createOrderState').val().trim();
 			var zip = $('#createOrderZip').val().trim();
         	
 			$('#createOrderAddressOne,#createOrderCity,#createOrderState,#createOrderZip,#createOrderShipVia,#createOrderCustomerPo').removeClass('is-invalid');
        	if(addressOne === "") {
        		$('#createOrderAddressOne').addClass("is-invalid").focus();
				return false;
			}
        	else if(city === "") {
        		$('#createOrderCity').addClass("is-invalid").focus();
				return false;
			}
        	if(state === "") {
        		$('#createOrderState').addClass("is-invalid").focus();
				return false;
			}
        	else if(zip === "") {
        		$('#createOrderZip').addClass("is-invalid").focus();
				return false;
			}
 			
 			if(shipVia === "") {
 				$('#createOrderShipVia').addClass("is-invalid").focus();
		        $('.step-one').removeClass('d-none').addClass('d-block');
		        $('#createOrderBackBtn').addClass('d-none');
		        $('#createOrderNextBtn').removeClass('d-none');
		        $('#createOrderCompleteBtn').addClass('d-none');
		        return false;
			}
			else{
	 			$('#createOrderShipVia').removeClass('is-invalid');
			}
			
			$('#createOrderCustomerPoLabel .required-star').remove();
	        if(custPORequiredForOrderAndTemplate == 1) {
				$('#createOrderCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
	        	if (customerPo == "") {
	 				$('#createOrderCustomerPo').addClass("is-invalid").focus();
			        $('.step-one').removeClass('d-none').addClass('d-block');
			        $('#createOrderBackBtn').addClass('d-none');
			        $('#createOrderNextBtn').removeClass('d-none');
			        $('#createOrderCompleteBtn').addClass('d-none');
			        return false;
			    } else {
		 			$('#createOrderCustomerPo').removeClass('is-invalid');
			        //$('.step-two').removeClass('d-block').addClass('d-none');
			        $('.step-one').removeClass('d-block').addClass('d-none');
			        $('.step-two').removeClass('d-none').addClass('d-block');
			        $('#createOrderBackBtn').removeClass('d-none');
			        $('#createOrderNextBtn').addClass('d-none');
			        $('#createOrderCompleteBtn').removeClass('d-none');
			    }
			}
	        else{
		        //$('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-block').addClass('d-none');
		        $('.step-two').removeClass('d-none').addClass('d-block');
		        $('#createOrderBackBtn').removeClass('d-none');
		        $('#createOrderNextBtn').addClass('d-none');
		        $('#createOrderCompleteBtn').removeClass('d-none');
	        }

			$('#CreateOrderItemTable').DataTable().destroy();
        	$('#CreateOrderItemTable tbody').empty();
        	
        	var urlStr="";
        	if(createOrderQuoteId !== ""){
        		$('#createOrderDeleteHeader').remove();
        		$('#createOrderExtPriceHeader').remove();
        		$('#CreateOrderItemTable thead tr').append(
        		        '<th id="createOrderExtPriceHeader" width="7%" class="text-right">Ext Price</th>'
        		);        		
        		$('#CreateOrderItemTable thead tr').append(
        		        '<th id="createOrderDeleteHeader" width="7%" class="text-center">Delete</th>'
        		);        		
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=CreateOrderItemList&soId="+createOrderQuoteId;
        	}
        	else{
        		$('#createOrderExtPriceHeader').remove();
        		$('#createOrderDeleteHeader').remove();
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList";
        	}

        	$('#createOrderUpdateHeaderBtn').addClass('d-none');
        	$('#preloader').removeClass('d-none');
        	$.ajax({
  				url : urlStr,
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="",seqTd="",checkboxTd="",extPriceTd="",priceUOMTd="",qtyUOMTd="",qtyTd="",deleteItemTd="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			if(createOrderQuoteId !== ""){
		        				seqTd = ' data-seq="'+row.displaySeq+'" ';
		        				checkboxTd = '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        				priceUOMTd = '<td class="text-center">'+row.priceUOM+'</td>';
		        				qtyTd = '<td class="text-right"><input type="number" value='+Number(row.qty).toFixed(3)+' style="width:100px;" class="form-control form-control-sm"></td>';
		        				//qtyTd = '<td class="text-right" nowrap>'+Number(row.qty).toFixed(3)+'</td>';
		        				qtyUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				extPriceTd = '<td class="text-right" nowrap>'+Number(row.extPrice).toFixed(3)+'</td>';
		        				addedCreateOrderItemArray.push(row.itemCode);
								deleteItemTd='<td class="text-center">'+
						        				'<button type="button" class="btn btn-outline-danger btn-sm delete-quote-btn" '+
							        				'data-quoteid="'+createOrderQuoteId+'" data-lineno="'+row.displaySeq+'">'+
						        					'<i class="icon-delete"></i> </button>'+
						    					'</td>';
		        			}else{
		        				seqTd = ' ';
		        				checkboxTd = '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        				priceUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				qtyTd = '<td class="text-right"><input type="number"  value="0" style="width:100px;" class="form-control form-control-sm"></td>';
		        				qtyUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				extPriceTd='';
		        				deleteItemTd='';
		        			}
		        					
		        			itemRow = '<tr '+seqTd+'>'+checkboxTd+
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											priceUOMTd+qtyTd+qtyUOMTd+extPriceTd+deleteItemTd+
						   			   '</tr>';
							$('#CreateOrderItemTable').append(itemRow);
						});
					}
					$('#CreateOrderItemTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					setTimeout(function () {
					    $('#CreateOrderItemTable tbody input[type="number"]:first').focus().select();
					}, 0);
					
					$('#CreateOrderItemTable').off('click', '.delete-quote-btn').on('click', '.delete-quote-btn', function() {
					    const quoteId = $(this).data('quoteid');
					    const lineNo = $(this).data('lineno');
					    deleteCreateOrderItem(quoteId, lineNo);
					});

					$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
        }
        
        $('#CreateOrderItemTable').off('input', 'input[type="number"]').on('input', 'input[type="number"]', function () {
            const qty = Number($(this).val());
            const row = $(this).closest('tr');
            const checkbox = row.find('.rowCheck');
            if (qty > 0) {
                checkbox.prop('checked', true);
            } else {
                checkbox.prop('checked', false);
            }
            
        });
        
        var createOrderDatatableLength=[],createOrderItemSeq=[],createOrderItemCode=[],createOrderPrice=[],createOrderPriceUom=[],createOrderOrderedQty=[],createOrderStockingUom=[];
		function saveCreateOrder(){
	   		debugger;
 			$('#createOrderAddressOne,#createOrderCity,#createOrderState,#createOrderZip,#createOrderShipVia,#createOrderCustomerPo').removeClass('is-invalid');
	   		var parameters;
        	var modalCustPORequired = $('#createOrderModalCustPORequired').val().trim();
	   		var shipToSeq = $('#createOrderShipToSeq').val().trim();
	   		var shipToName = $('#createOrderShipToName').val().trim();
			var addressOne = $('#createOrderAddressOne').val().trim();
			var addressTwo = $('#createOrderAddressTwo').val().trim();
			var city = $('#createOrderCity').val().trim();
			var state = $('#createOrderState').val().trim();
			var zip = $('#createOrderZip').val().trim();
			var contactName = $('#createOrderMemoOne').val().trim();
			var phone = $('#createOrderMemoTwo').val().trim();
			var shipVia = $('#createOrderShipVia').val().trim();
			var customerPo = $('#createOrderCustomerPo').val().trim();
			var referenceId = $('#createOrderReferenceId').val().trim();
			var jobNo = $('#createOrderAddressThree').val().trim();
			var expectedDeliveryDate = $('#createOrderExpectedDeliveryDate').val().trim();
			var notes = $('#createOrderNotes').val().trim();
			var message = $('#createOrderMessage').val().trim();

			createOrderItemSeq=[],createOrderItemCode=[],createOrderPrice=[],createOrderPriceUom=[],createOrderOrderedQty=[],createOrderStockingUom=[];
			/* var oTable = $('#CreateOrderItemTable').DataTable();
			var datatableLength = oTable.data().toArray();
			for (var i = 0; i < datatableLength.length; i++) {
			    var row = oTable.row(i);
			    var data = row.data();
			    var rowNode = row.node();
			    var checkbox = $(rowNode).find('input[type="checkbox"]');
			    if(checkbox.prop('checked')){
			    	var qty = $(rowNode).find('input').val();
			    	if (qty > 0) {
			    		createOrderItemCode.push(data[1]);
			    		createOrderPrice.push(parseFloat(data[4]));
			    		createOrderPriceUom.push(data[5]);
			    		createOrderOrderedQty.push(qty);
			    		createOrderStockingUom.push(data[7]);
			    	}
			    }
			} */	
			
			var oTable = $('#CreateOrderItemTable').DataTable();
			oTable.rows().every(function(rowIdx, tableLoop, rowLoop) {
			    var rowNode = this.node();
			    var $checkbox = $(rowNode).find('input[type="checkbox"]');
			    if ($checkbox.prop('checked')) {
			        var $cells = $(rowNode).find('td');
			        var qty = $(rowNode).find('input[type="number"]').val();
			        if (qty > 0) {
			        	createOrderItemSeq.push($(rowNode).data('seq'));
			            createOrderItemCode.push($cells.eq(1).text().trim());
			            createOrderPrice.push(parseFloat($cells.eq(4).text().trim()));
			            createOrderPriceUom.push($cells.eq(5).text().trim());
			            createOrderOrderedQty.push(qty);
			            createOrderStockingUom.push($cells.eq(7).text().trim());
			        }
			    }
			});

			$('#createOrderCustomerPoLabel .required-star').remove();
			if(custPORequiredForOrderAndTemplate == 1){
				$('#createOrderCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
				if (customerPo == "" || customerPo == null) {
					$('#createOrderCustomerPo').addClass("is-invalid").focus();
					return false;
				}
			}
			
			if($('.rowCheck:checked').length == 0) {
				$('#CreateOrderErrorMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
				if(createOrderQuoteId == ""){
					$('#preloader').removeClass('d-none');
					parameters="param=SaveCreateOrder&shipToSeq="+shipToSeq+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+
								"&city="+city+"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+
								"&referenceId="+referenceId+"&jobNo="+jobNo+"&expectedDeliveryDate="+expectedDeliveryDate+"&notes="+notes+"&message="+message+
								"&itemCode="+createOrderItemCode+"&price="+createOrderPrice+"&priceUom="+createOrderPriceUom+"&orderedQty="+createOrderOrderedQty+"&stockingUom="+createOrderStockingUom;
					$.ajax({
					 	url:"../customerPortal/A_CP_ShopAction.jsp",
						type : "POST",
						dataType: "text",
						data: parameters,
						success: function (response) {
							$('#CreateOrderModal').modal('hide');
							$('#CreateOrderMessageModal').modal('show');
							$('#CreateOrderMessageModalErrorMsg').html(response);
							$('#preloader').addClass('d-none');
						},
					 	failure: function (response) {
					    }
					});
				}else{
					parameters="param=SalesOrderDetailsUpdate&orderId="+createOrderQuoteId+"&itemSeq="+createOrderItemSeq+"&itemCode="+createOrderItemCode+"&price="+createOrderPrice+"&priceUom="+createOrderPriceUom+"&orderedQty="+createOrderOrderedQty+"&stockingUom="+createOrderStockingUom;
					$.ajax({
					 	url:"../customerPortal/A_CP_ShopAction.jsp",
						type : "POST",
						dataType: "text",
						data: parameters,
						success: function (response) {
							popupForCreateOrderItem();
						},
					 	failure: function (response) {
					    }
					});
				}
			}
		}
		
	   	function popupForUpdateCreateOrderHeader(soId){
	   		createOrderQuoteId=soId;

	   		$('#CreateOrderErrorMsg').html('');
 			$('#createOrderAddressOne,#createOrderCity,#createOrderState,#createOrderZip,#createOrderShipVia,#createOrderCustomerPo').removeClass('is-invalid');
        	$("#createOrderUpdateHeaderBtn").show();
        	$("#createOrderAddItemBtn").show();
        	$("#quoteIdForCreateOrderHeader").show();
        	
        	$('#createOrderShipToName').val('');
			$('#createOrderAddressOne').val('');
			$('#createOrderAddressTwo').val('');
			$('#createOrderCity').val('');
			$('#createOrderState').val('');
			$('#createOrderZip').val('');
			$('#createOrderMemoOne').val('');
			$('#createOrderMemoTwo').val('');
			$('#createOrderShipVia').val('');
			$('#createOrderCustomerPo').val('');
			$('#createOrderReferenceId').val('');
			$('#createOrderAddressThree').val('');
			//$('#createOrderExpectedDeliveryDate').val('');
			$('#createOrderNotes').val('');
			$('#createOrderMessage').val('');
			
			$('#createOrderAddressOne').prop('readonly', true);
			$('#createOrderAddressTwo').prop('readonly', true);
			$('#createOrderCity').prop('readonly', true);
			$('#createOrderState').prop('readonly', true);
			$('#createOrderZip').prop('readonly', true);
			$('#createOrderMemoOne').prop('readonly', true);
			$('#createOrderMemoTwo').prop('readonly', true);
			$('#createOrderNotes').prop('readonly', true);
			$('#createOrderMessage').prop('readonly', true);

			$('#createOrderCustomerPoLabel .required-star').remove();
			if(custPORequiredForOrderAndTemplate == 1){
				$('#createOrderCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
			}
			
			$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_ShopAction.jsp?param=GetCreateOrderHeader&soId="+soId,
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#createOrderQuoteId').val(response.orderId);
					$('#createOrderShipToName').val(response.shipToName);
					$('#createOrderAddressOne').val(response.addressOne);
					$('#createOrderAddressTwo').val(response.addressTwo);
					$('#createOrderCity').val(response.city);
					$('#createOrderState').val(response.state);
					$('#createOrderZip').val(response.zip);
					$('#createOrderMemoTwo').val(response.phone);
					$('#createOrderShipVia').val(response.shipVia);
					$('#createOrderCustomerPo').val(response.customerPO);
					$('#createOrderReferenceId').val(response.referenceId);
					$('#createOrderAddressThree').val(response.jobNo);
				},
				failure: function (response) {
				}
			});

			$('#quoteIdForCreateOrderHeader').html(createOrderQuoteId);
        	$('#CreateOrderModal').modal('show');
	   	}
	   	
	   	function updateCreateOrderHeader(){
	   		$('#CreateOrderErrorMsg').html('');
	   		var orderId = $('#createOrderQuoteId').val().trim();
	   		var shipToName = $('#createOrderShipToName').val().trim();
			var addressOne = $('#createOrderAddressOne').val().trim();
			var addressTwo = $('#createOrderAddressTwo').val().trim();
			var city = $('#createOrderCity').val().trim();
			var state = $('#createOrderState').val().trim();
			var zip = $('#createOrderZip').val().trim();
			var contactName = $('#createOrderMemoOne').val().trim();
			var phone = $('#createOrderMemoTwo').val().trim();
			var shipVia = $('#createOrderShipVia').val().trim();
			var customerPo = $('#createOrderCustomerPo').val().trim();
			var referenceId = $('#createOrderReferenceId').val().trim();
			var jobNo = $('#createOrderAddressThree').val().trim();
			var expectedDeliveryDate = $('#createOrderExpectedDeliveryDate').val().trim();
			var notes = $('#createOrderNotes').val().trim();
			var message = $('#createOrderMessage').val().trim();

			parameters="param=UpdateOrderHeader&orderId="+orderId+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+
						"&city="+city+"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+
						"&referenceId="+referenceId+"&jobNo="+jobNo+"&expectedDeliveryDate="+expectedDeliveryDate+"&notes="+notes+"&message="+message;
			$.ajax({
			 	url:"../customerPortal/A_CP_ShopAction.jsp",
				type : "POST",
				dataType : 'text',
				data: parameters,
				success: function (response) {
					$('#CreateOrderErrorMsg').html(response);
				},
			 	failure: function (response) {
			    }
			});
	   	}

		
	   	function popupForNewCreateOrderItemList(){
	   		$('#preloader').removeClass('d-none');
	   		$('#CreateOrderItemListModalMsg').html('');
			$('#CreateOrderItemListTable').DataTable().destroy();
        	$('#CreateOrderItemListTable tbody').empty();
  			$.ajax({
  				url : "../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList",
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			var hideCheckbox = addedCreateOrderItemArray.includes(row.itemCode);
		        		    var checkboxTd = hideCheckbox ? '<td></td>' : '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        		    itemRow = '<tr>'+
		        		    				checkboxTd +
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											'<td class="text-center">'+row.UOM+'</td>'+
											'<td class="text-right"><input type="number"  value="0" style="width:100px;" class="form-control form-control-sm"></td>'+
											'<td class="text-center">'+row.UOM+'</td>'+
						   			   '</tr>';
							$('#CreateOrderItemListTable').append(itemRow);
						});
					}
					$('#CreateOrderItemListTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					$('#CreateOrderItemListTable tbody tr').each(function () {
				        if ($(this).find('.rowCheck').length === 0) {
				            $(this).find('input[type="number"]').attr('tabindex', '-1');
				        }
				    });
					
					$('#CreateOrderItemListTable tbody tr').has('input.rowCheck').find('input[type="number"]').first().focus().select();
					
			   		$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
	   	}

        $('#CreateOrderItemListTable').off('input', 'input[type="number"]').on('input', 'input[type="number"]', function () {
            const qty = Number($(this).val());
            const row = $(this).closest('tr');
            const checkbox = row.find('.rowCheck');
            if (qty > 0) {
                checkbox.prop('checked', true);
            } else {
                checkbox.prop('checked', false);
            }
            
        });

		function deleteCreateOrderHeader(soId){
	   	    $('#CreateOrderDeleteConfirmHeaderModal').modal('show');
	   	    $('#createOrderConfirmDeleteHeaderBtn').off('click').on('click', function () {
				window.location="../customerPortal/A_CP_ShopAction.jsp?param=DeleteCreateOrder&orderId="+soId;
				$('#CreateOrderDeleteConfirmHeaderModal').modal('hide');
				
	   	    });
		}

		function deleteCreateOrderItem(quoteId, lineNo) {
	   	    $('#CreateOrderDeleteConfirmItemModal').modal('show');
	   	    $('#createOrderConfirmDeleteItemBtn').off('click').on('click', function () {
	   	        var parameters = "param=DeleteCreateOrderItem&quoteId=" + quoteId + "&lineNo=" + lineNo;
	   	        $.ajax({
	   	            url: "../customerPortal/A_CP_ShopAction.jsp",
	   	            type: "POST",
	   	            dataType: "text",
	   	            data: parameters,
	   	            success: function (response) {
	   	                $('#CreateOrderErrorMsg').html(response);
	   	             	popupForCreateOrderItem();
	   	                $('#CreateOrderDeleteConfirmItemModal').modal('hide');
	   	            }
	   	        });
	   	    });
	   	}

	   	function addCreateOrderItem(){
	   		debugger;
	   		var parameters;
	   		var orderId = $.trim($('#createOrderQuoteId').val());
	   		var shipToName = $('#createOrderShipToName').val().trim();
			var addressOne = $('#createOrderAddressOne').val().trim();
			var addressTwo = $('#createOrderAddressTwo').val().trim();
			var city = $('#createOrderCity').val().trim();
			var state = $('#createOrderState').val().trim();
			var zip = $('#createOrderZip').val().trim();
			var contactName = $('#createOrderMemoOne').val().trim();
			var phone = $('#createOrderMemoTwo').val().trim();
			var shipVia = $('#createOrderShipVia').val().trim();
			var customerPo = $('#createOrderCustomerPo').val().trim();
			var referenceId = $('#createOrderReferenceId').val().trim();

			createOrderItemCode=[],createOrderPrice=[],createOrderPriceUom=[],createOrderOrderedQty=[],createOrderStockingUom=[];
			var oTable = $('#CreateOrderItemListTable').DataTable();
			oTable.rows().every(function(rowIdx, tableLoop, rowLoop) {
			    var rowNode = this.node();
			    var $checkbox = $(rowNode).find('input[type="checkbox"]');
			    if ($checkbox.prop('checked')) {
			        var $cells = $(rowNode).find('td');
			        var qty = $(rowNode).find('input[type="number"]').val();
			        if (qty > 0) {
			            createOrderItemCode.push($cells.eq(1).text().trim());
			            createOrderPrice.push(parseFloat($cells.eq(4).text().trim()));
			            createOrderPriceUom.push($cells.eq(5).text().trim());
			            createOrderOrderedQty.push(qty);
			            createOrderStockingUom.push($cells.eq(7).text().trim());
			        }
			    }
			});
			
			if($('.rowCheck:checked').length === 0) {
				$('#CreateOrderItemListModalMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
		   		$('#preloader').removeClass('d-none');
				parameters="param=AddOrderItem&orderId="+orderId+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+"&city="+city+
							"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+"&referenceId="+referenceId+
							"&itemCode="+createOrderItemCode+"&price="+createOrderPrice+"&priceUom="+createOrderPriceUom+"&orderedQty="+createOrderOrderedQty+"&stockingUom="+createOrderStockingUom;
				
				$.ajax({
				 	url:"../customerPortal/A_CP_ShopAction.jsp",
					type : "POST",
					dataType: "text",
					data: parameters,
					success: function (response) {
						$('#CreateOrderItemListModal').modal('hide');
						$('#CreateOrderErrorMsg').html(response);
						popupForCreateOrderItem();
					},
				 	failure: function (response) {
				    }
				});
			}
	   	}
		
        
        function popupForTemplateHeaderDetail(){
        	templateQuoteId="";
 			$('#templateAddressOne,#templateCity,#templateState,#templateZip,#templateShipVia,#templateCustomerPo').removeClass('is-invalid');
        	$("#templateUpdateQuoteHeaderBtn").hide();
        	$("#templateAddItemBtn").hide();
        	$('#templateCompleteBtn').show();
    		$('#templateCloseBtn').addClass('d-none');
        	
        	$('#templateShipToName').val('').focus();
			$('#templateAddressOne').val('');
			$('#templateAddressTwo').val('');
			$('#templateCity').val('');
			$('#templateState').val('');
			$('#templateZip').val('');
			$('#templateMemoOne').val('');
			$('#templateMemoTwo').val('');
			$('#templateShipVia').val('');
			$('#templateCustomerPo').val('');
			$('#templateReferenceId').val('');
			$('#templateAddressThree').val('');
			//$('#templateExpectedDeliveryDate').val('');
			$('#templateNotes').val('');
			$('#templateMessage').val('');
			
			$("#quoteIdForTemplateHeader").hide().text("");
			$('#templateQuoteId').val('');
			
			$('#templateAddressOne').prop('readonly', false);
			$('#templateAddressTwo').prop('readonly', false);
			$('#templateCity').prop('readonly', false);
			$('#templateState').prop('readonly', false);
			$('#templateZip').prop('readonly', false);
			$('#templateMemoOne').prop('readonly', false);
			$('#templateMemoTwo').prop('readonly', false);
			$('#templateNotes').prop('readonly', false);
			$('#templateMessage').prop('readonly', false);
        }

		
        function popupForTemplateItem(){
        	debugger;
        	$('#TemplateErrorMsg').html('');
        	addedItemArray=[];
 			var modalCustPORequired = $('#templateModalCustPORequired').val().trim();
			var shipVia = $('#templateShipVia').val().trim();
 			var customerPo = $('#templateCustomerPo').val().trim();
 			var addressOne = $('#templateAddressOne').val().trim();
 			var city = $('#templateCity').val().trim();
 			var state = $('#templateState').val().trim();
 			var zip = $('#templateZip').val().trim();
         	
 			$('#templateAddressOne,#templateCity,#templateState,#templateZip,#templateShipVia,#templateCustomerPo').removeClass('is-invalid');
        	if(addressOne === "") {
        		$('#templateAddressOne').addClass("is-invalid").focus();
				return false;
			}
        	else if(city === "") {
        		$('#templateCity').addClass("is-invalid").focus();
				return false;
			}
        	if(state === "") {
        		$('#templateState').addClass("is-invalid").focus();
				return false;
			}
        	else if(zip === "") {
        		$('#templateZip').addClass("is-invalid").focus();
				return false;
			}
 			
 			if(shipVia === "") {
 				$('#templateShipVia').addClass("is-invalid").focus();
		        $('.step-one').removeClass('d-none').addClass('d-block');
		        $('#templateBackBtn').addClass('d-none');
		        $('#templateNextBtn').removeClass('d-none');
		        $('#templateCompleteBtn').addClass('d-none');
		        return false;
			}
			else{
	 			$('#shipVia').removeClass('is-invalid');
			}
			
			$('#templateCustomerPoLabel .required-star').remove();
	        if(custPORequiredForOrderAndTemplate == 1) {
				$('#templateCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
			    if (customerPo == "") {
	 				$('#templateCustomerPo').addClass("is-invalid").focus();
			        $('.step-one').removeClass('d-none').addClass('d-block');
			        $('#templateBackBtn').addClass('d-none');
			        $('#templateNextBtn').removeClass('d-none');
			        $('#templateCompleteBtn').addClass('d-none');
			        return false;
			    } else {
		 			$('#templateCustomerPo').removeClass('is-invalid');
			        //$('.step-two').removeClass('d-block').addClass('d-none');
			        $('.step-one').removeClass('d-block').addClass('d-none');
			        $('.step-two').removeClass('d-none').addClass('d-block');
			        $('#templateBackBtn').removeClass('d-none');
			        $('#templateNextBtn').addClass('d-none');
			        $('#templateCompleteBtn').removeClass('d-none');
			    }
			}
	        else{
		        //$('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-block').addClass('d-none');
		        $('.step-two').removeClass('d-none').addClass('d-block');
		        $('#templateBackBtn').removeClass('d-none');
		        $('#templateNextBtn').addClass('d-none');
		        $('#templateCompleteBtn').removeClass('d-none');
	        }
			
			$('#CreateTemplateItemTable').DataTable().destroy();
        	$('#CreateTemplateItemTable tbody').empty();
        	
        	var urlStr="";
        	if(templateQuoteId !== ""){
        		$('#preloader').removeClass('d-none');
        		$('#templateCloseBtn').removeClass('d-none');
        		$('#templateDeleteHeader').remove();
        		$('#CreateTemplateItemTable thead tr').append(
        		        '<th id="templateDeleteHeader" width="7%" class="text-center">Delete</th>'
        		);        		
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=QuoteIdQuickList&quoteId="+templateQuoteId;
        	}
        	else{
        		$('#templateDeleteHeader').remove();
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList";
        	}

        	$('#templateUpdateQuoteHeaderBtn').addClass('d-none');
        	$('#preloader').removeClass('d-none');
        	$.ajax({
  				url : urlStr,
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="",checkboxTd="",deleteItemTd="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			if(templateQuoteId !== ""){
		        				addedItemArray.push(row.itemCode);
		        				checkboxTd = '<td></td>';
		        				deleteItemTd='<td class="text-center">'+
						        				'<button type="button" class="btn btn-outline-danger btn-sm delete-quote-btn" '+
							        				'data-quoteid="'+templateQuoteId+'" data-lineno="'+row.displaySeq+'">'+
						        					'<i class="icon-delete"></i> </button>'+
						    					'</td>';
							}
		        			else{
		        				checkboxTd = '<td align="left"><input type="checkbox" id="checkboxId" class="rowCheck"></td>';
		        			}

		        			itemRow = '<tr>'+checkboxTd+
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											'<td class="text-center">'+row.priceUOM+'</td>'+
											'<td class="text-center">'+row.UOM+'</td>'+deleteItemTd+
						   			   '</tr>';
							$('#CreateTemplateItemTable').append(itemRow);
						});
					}
					$('#CreateTemplateItemTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					$('#CreateTemplateItemTable').off('click', '.delete-quote-btn').on('click', '.delete-quote-btn', function() {
					    const quoteId = $(this).data('quoteid');
					    const lineNo = $(this).data('lineno');
					    deleteTemplateItem(quoteId, lineNo);
					});

					$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
        }
		
        var templateDatatableLength=[],templateItemCode=[],templatePrice=[],templatePriceUom=[],templateOrderedQty=[],templateStockingUom=[];
		function saveTemplate(){
	   		debugger;
 			$('#templateAddressOne,#templateCity,#templateState,#templateZip,#templateShipVia,#templateCustomerPo').removeClass('is-invalid');
	   		var parameters;
	   		var shipToSeq = document.getElementById('templateShipToSeq').value;
			var modalCustPORequired = document.getElementById('templateModalCustPORequired').value;
			var customerPo = document.getElementById('templateCustomerPo').value;
			var referenceId = document.getElementById('templateReferenceId').value;
			var message = document.getElementById('templateMessage').value;
			var notes = document.getElementById('templateNotes').value;
			var shipToName = document.getElementById('templateShipToName').value;
			var addressOne = document.getElementById('templateAddressOne').value;
			var addressTwo = document.getElementById('templateAddressTwo').value;
			var addressThree = document.getElementById('templateAddressThree').value;
			var shipVia = document.getElementById('templateShipVia').value;
			var city = document.getElementById('templateCity').value;
			var state = document.getElementById('templateState').value;
			var zip = document.getElementById('templateZip').value;
			var memoOne = document.getElementById('templateMemoOne').value;
			var memoTwo = document.getElementById('templateMemoTwo').value;
			var expectedDeliveryDate = document.getElementById('templateExpectedDeliveryDate').value;

			templateItemCode=[],templatePrice=[],templatePriceUom=[],templateOrderedQty=[],templateStockingUom=[];
			var oTable = $('#CreateTemplateItemTable').DataTable();
			var templateDatatableLength = oTable.data().toArray();
			for (var i = 0; i < templateDatatableLength.length; i++) {
			    var row = oTable.row(i);
			    var data = row.data();
			    var rowNode = row.node();
			    var checkbox = $(rowNode).find('input[type="checkbox"]');
			    if(checkbox.prop('checked')){
			    	templateItemCode.push(data[1]);
			    	templatePrice.push(parseFloat(data[4]));
			    	templatePriceUom.push(data[5]);
			    	templateStockingUom.push(data[6]);
			    }
			}			
			
			$('#templateCustomerPoLabel .required-star').remove();
			if(custPORequiredForOrderAndTemplate == 1){
				$('#templateCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
				if (customerPo === "" || customerPo === null) {
					$('#templateCustomerPo').addClass("is-invalid").focus();
					return false;
				}
			}
			
			if($('.rowCheck:checked').length === 0) {
				$('#TemplateErrorMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
				$('#preloader').removeClass('d-none');
				parameters="param=SaveTemplate&shipToSeq="+shipToSeq+"&customerPo="+customerPo+"&referenceId="+referenceId+"&message="+message+"&notes="+notes+
							"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+"&addressThree="+addressThree+"&shipVia="+shipVia+
							"&city="+city+"&state="+state+"&zip="+zip+"&memoOne="+memoOne+"&memoTwo="+memoTwo+"&expectedDeliveryDate="+expectedDeliveryDate+
							"&itemCode="+templateItemCode+"&price="+templatePrice+"&priceUom="+templatePriceUom+"&stockingUom="+templateStockingUom;
				
				$.ajax({
				 	url:"../customerPortal/A_CP_ShopAction.jsp",
					type : "POST",
					dataType: "text",
					data: parameters,
					success: function (response) {
						$('#CreateTemplateModal').modal('hide');
						$('#TemplateMessageModal').modal('show');
						$('#TemplateMessageModalErrorMsg').html(response);
						$('#preloader').addClass('d-none');
					},
				 	failure: function (response) {
				    }
				});
			}
		}
		
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

	   	function closeModal(){
			$('.step-one').removeClass('d-none').addClass('d-block');
      		$('.step-two').removeClass('d-block').addClass('d-none');
	        $('#createOrderUpdateHeaderBtn').removeClass('d-none');
	        $('#createOrderBackBtn').addClass('d-none');
	        $('#createOrderNextBtn').removeClass('d-none');
	        $('#createOrderCompleteBtn').addClass('d-none');
	        
	        $('#templateUpdateQuoteHeaderBtn').removeClass('d-none');
	        $('#templateBackBtn').addClass('d-none');
	        $('#templateNextBtn').removeClass('d-none');
	        $('#templateCompleteBtn').addClass('d-none');
	        $('#templateCloseBtn').addClass('d-none');
	        
	        $('#quoteEntryUpdateHeaderBtn').removeClass('d-none');
	        $('#quoteEntryBackBtn').addClass('d-none');
	        $('#quoteEntryNextBtn').removeClass('d-none');
	        $('#quoteEntryCompleteBtn').addClass('d-none');
	        
	        $('#backBtn').addClass('d-none');
	        $('#nextBtn').removeClass('d-none');
	        $('#completeBtn').addClass('d-none');
      		
	   		$('#CreateOrderModal').modal('hide');
	   		$('#CreateOrderMessageModal').modal('hide');
	   		$('#CreateOrderDeleteConfirmHeaderModal').modal('hide');
	   		$('#CreateTemplateModal').modal('hide');
	   		$('#TemplateMessageModal').modal('hide');
	   		$('#TemplateDeleteConfirmHeaderModal').modal('hide');
	   		$('#QuoteEntryModal').modal('hide');
	   		$('#QuoteEntryMessageModal').modal('hide');
	   		$('#QuoteEntryDeleteConfirmHeaderModal').modal('hide');
	   		
	   		$('#createOrder').modal('hide');
	   		$('#MessageModal').modal('hide');
	   		
	   		//window.location.reload();
		}
	   	

	   	function showHelpModal(){
	   		//$('#HelpModal').modal('show');
	   		
	   		$('#HelpModal').css('z-index', '1060').modal('show');

	   	    setTimeout(() => {
	   	        $('.modal-backdrop').last().css('z-index', '1055');
	   	    }, 10);

	   	}

	   	
	   	function closeHelpModal(){
	   		$('#HelpModal').modal('hide');
	   		
	   		//window.location.reload();
		}

	   	
	   	
	   	function closeMessageModal(){
	   		window.location.reload();
	   	}

	   	function closeProductModal(){
	   		$('#ProductModal').modal('hide');
	   	}
	   	
		function exit2(){
			parent.location='../customerPortal/A_CP_Logout.jsp';
		}
		
	   	function popupForUpdateTemplateHeader(quoteId){
	   		templateQuoteId=quoteId;
 			$('#templateAddressOne,#templateCity,#templateState,#templateZip,#templateShipVia,#templateCustomerPo').removeClass('is-invalid');

        	$('#templateUpdateQuoteHeaderBtn').show();
        	$('#templateAddItemBtn').show();
			$('#quoteIdForTemplateHeader').show();
			$('#templateCompleteBtn').hide();
			$('#templateCloseBtn').show();

        	$('#templateShipToName').val('');
			$('#templateAddressOne').val('');
			$('#templateAddressTwo').val('');
			$('#templateCity').val('');
			$('#templateState').val('');
			$('#templateZip').val('');
			$('#templateMemoOne').val('');
			$('#templateMemoTwo').val('');
			$('#templateShipVia').val('');
			$('#templateCustomerPo').val('');
			$('#templateReferenceId').val('');
			$('#templateAddressThree').val('');
			//$('#templateExpectedDeliveryDate').val('');
			$('#templateNotes').val('');
			$('#templateMessage').val('');
			
			$('#templateAddressOne').prop('readonly', true);
			$('#templateAddressTwo').prop('readonly', true);
			$('#templateCity').prop('readonly', true);
			$('#templateState').prop('readonly', true);
			$('#templateZip').prop('readonly', true);
			$('#templateMemoOne').prop('readonly', true);
			$('#templateMemoTwo').prop('readonly', true);
			$('#templateNotes').prop('readonly', true);
			$('#templateMessage').prop('readonly', true);

			$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_ShopAction.jsp?param=GetTemplateHeader&quoteId="+quoteId,
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#templateQuoteId').val(response.quoteId);
					$('#templateShipToName').val(response.shipToName);
					$('#templateAddressOne').val(response.addressOne);
					$('#templateAddressTwo').val(response.addressTwo);
					$('#templateCity').val(response.city);
					$('#templateState').val(response.state);
					$('#templateZip').val(response.zip);
					$('#templateMemoTwo').val(response.phone);
					$('#templateShipVia').val(response.shipVia);
					$('#templateCustomerPo').val(response.customerPO);
					$('#templateReferenceId').val(response.referenceId);
					$('#templateAddressThree').val(response.jobNo);
				},
				failure: function (response) {
				}
			});
			$('#quoteIdForTemplateHeader').html(quoteId);
			//$('#quoteId').val(quoteId);
        	$('#CreateTemplateModal').modal('show');
	   	}
	   	
	   	function updateTemplateHeader(){
	   		$('#TemplateErrorMsg').html('');
	   		var parameters;
	   		var quoteId = $.trim($('#templateQuoteId').val());
			var shipToName = $.trim($('#templateShipToName').val());
			var addressOne = $.trim($('#templateAddressOne').val());
			var addressTwo = $.trim($('#templateAddressTwo').val());
			var city = $.trim($('#templateCity').val());
			var state = $.trim($('#templateState').val());
			var zip = $.trim($('#templateZip').val());
			var shipVia = $.trim($('#templateShipVia').val());
			var customerPo = $.trim($('#templateCustomerPo').val());
			var referenceId = $.trim($('#templateReferenceId').val());
			var jobNo = $.trim($('#templateAddressThree').val());
			var expectedDeliveryDate = $.trim($('#templateExpectedDeliveryDate').val());

			parameters="param=UpdateTemplateHeader&quoteId="+quoteId+"&shipToName="+shipToName+"&shipVia="+shipVia+"&customerPo="+customerPo+
							"&referenceId="+referenceId+"&jobNo="+jobNo+"&expectedDeliveryDate="+expectedDeliveryDate;
			$.ajax({
			 	url:"../customerPortal/A_CP_ShopAction.jsp",
				type : "POST",
				dataType : 'text',
				data: parameters,
				success: function (response) {
					$('#TemplateErrorMsg').html(response);
				},
			 	failure: function (response) {
			    }
			});
	   	}
	   	
	   	
	   	function popupForNewTemplateItemList(){
	   		$('#preloader').removeClass('d-none');
	   		$('#TemplateItemListModalMsg').html('');
			$('#TemplateItemListTable').DataTable().destroy();
        	$('#TemplateItemListTable tbody').empty();
  			$.ajax({
  				url : "../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList",
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			var hideCheckbox = addedItemArray.includes(row.itemCode);
		        		    var checkboxTd = hideCheckbox ? '<td></td>' : '<td align="left"><input type="checkbox" class="rowCheck" ></td>';
		        		    itemRow = '<tr>'+
		        		    				checkboxTd +
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											'<td class="text-center">'+row.priceUOM+'</td>'+
											'<td class="text-center">'+row.UOM+'</td>'+
						   			   '</tr>';
							$('#TemplateItemListTable').append(itemRow);
						});
					}
					$('#TemplateItemListTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
	   	}

        /*function deleteTemplateHeader(quoteId){
			var result = window.confirm('Are you sure you want to delete this quote#?');
			if(result){
				window.location="../customerPortal/A_CP_ShopAction.jsp?param=DeleteTemplate&quoteId="+quoteId;
				return true;			
			} 
			else
				return false;			
		}*/
   	
	   	/*function deleteTemplateItem(quoteId,lineNo){
	   		debugger;
	   		var result = window.confirm('Are you sure you want to delete this item?');
			if(result){
				var parameters;
				parameters="param=DeleteTemplateItem&quoteId="+quoteId+"&lineNo="+lineNo;
				$.ajax({
				 	url:"../customerPortal/A_CP_ShopAction.jsp",
					type : "POST",
					dataType: "text",
					data: parameters,
					success: function (response) {
						$('#TemplateErrorMsg').html(response);
						popupForTemplateItem();
					},
				 	failure: function (response) {
				    }
				});
				
				return true;			
			} 
			else
				return false;			
		}*/
   	
		function deleteTemplateHeader(quoteId){
	   	    $('#TemplateDeleteConfirmHeaderModal').modal('show');
	   	    $('#templateConfirmDeleteHeaderBtn').off('click').on('click', function () {
				window.location="../customerPortal/A_CP_ShopAction.jsp?param=DeleteTemplate&quoteId="+quoteId;
				$('#TemplateDeleteConfirmHeaderModal').modal('hide');
				
	   	    });
		}

		function deleteTemplateItem(quoteId, lineNo) {
	   	    $('#TemplateDeleteConfirmItemModal').modal('show');
	   	    $('#templateConfirmDeleteItemBtn').off('click').on('click', function () {
	   	        var parameters = "param=DeleteTemplateItem&quoteId=" + quoteId + "&lineNo=" + lineNo;
	   	        $.ajax({
	   	            url: "../customerPortal/A_CP_ShopAction.jsp",
	   	            type: "POST",
	   	            dataType: "text",
	   	            data: parameters,
	   	            success: function (response) {
	   	                $('#TemplateErrorMsg').html(response);
	   	             	popupForTemplateItem();
	   	                $('#TemplateDeleteConfirmItemModal').modal('hide');
	   	            }
	   	        });
	   	    });
	   	}

	   	
	   	function addTemplateItem(){
	   		debugger;
	   		var parameters;
	   		var quoteId = $.trim($('#templateQuoteId').val());
			var shipToName = $.trim($('#templateShipToName').val());
			var addressOne = $.trim($('#templateAddressOne').val());
			var addressTwo = $.trim($('#templateAddressTwo').val());
			var city = $.trim($('#templateCity').val());
			var state = $.trim($('#templateState').val());
			var zip = $.trim($('#templateZip').val());
			var shipVia = $.trim($('#templateShipVia').val());
			var customerPo = $.trim($('#templateCustomerPo').val());
			var referenceId = $.trim($('#templateReferenceId').val());

			templateItemCode=[],templatePrice=[],templatePriceUom=[],templateOrderedQty=[],templateStockingUom=[];
			var oTable = $('#TemplateItemListTable').DataTable();
			var datatableLength = oTable.data().toArray();
			for (var i = 0; i < datatableLength.length; i++) {
			    var row = oTable.row(i);
			    var data = row.data();
			    var rowNode = row.node();
			    var checkbox = $(rowNode).find('input[type="checkbox"]');
			    if(checkbox.prop('checked')){
			    	templateItemCode.push(data[1]);
			    	templatePrice.push(parseFloat(data[4]));
			    	templatePriceUom.push(data[5]);
			    	templateStockingUom.push(data[6]);
			    }
			}			
			
			if($('.rowCheck:checked').length === 0) {
				$('#TemplateItemListModalMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
		   		$('#preloader').removeClass('d-none');
				parameters="param=AddItem&quoteId="+templateQuoteId+"&shipToName="+shipToName+"&customerPo="+customerPo+
								"&itemCode="+templateItemCode+"&price="+templatePrice+"&priceUom="+templatePriceUom+"&stockingUom="+templateStockingUom;
				
				$.ajax({
				 	url:"../customerPortal/A_CP_ShopAction.jsp",
					type : "POST",
					dataType: "text",
					data: parameters,
					success: function (response) {
						$('#TemplateItemListModal').modal('hide');
						$('#TemplateErrorMsg').html(response);
						popupForTemplateItem();
					},
				 	failure: function (response) {
				    }
				});
			}
	   	}
	   	
	   	
        function popupForQuoteEntryHeaderDetail(){
        	quoteEntryQuoteId="";
        	$('#QuoteEntryErrorMsg').html('');
 			$('#quoteEntryAddressOne,#quoteEntryCity,#quoteEntryState,#quoteEntryZip,#quoteEntryShipVia,#quoteEntryCustomerPo').removeClass('is-invalid');
        	$("#quoteEntryUpdateHeaderBtn").hide();
        	$("#quoteEntryAddItemBtn").hide();
        	
        	$('#quoteEntryShipToName').val('').focus();
			$('#quoteEntryAddressOne').val('');
			$('#quoteEntryAddressTwo').val('');
			$('#quoteEntryCity').val('');
			$('#quoteEntryState').val('');
			$('#quoteEntryZip').val('');
			$('#quoteEntryMemoOne').val('');
			$('#quoteEntryMemoTwo').val('');
			$('#quoteEntryShipVia').val('');
			$('#quoteEntryCustomerPo').val('');
			$('#quoteEntryReferenceId').val('');
			$('#quoteEntryAddressThree').val('');
			//$('#quoteEntryExpectedDeliveryDate').val('');
			$('#quoteEntryNotes').val('');
			$('#quoteEntryMessage').val('');
			
			$("#quoteIdForQuoteEntryHeader").hide().text("");
			$('#quoteEntryQuoteId').val('');
			
			$('#quoteEntryAddressOne').prop('readonly', false);
			$('#quoteEntryAddressTwo').prop('readonly', false);
			$('#quoteEntryCity').prop('readonly', false);
			$('#quoteEntryState').prop('readonly', false);
			$('#quoteEntryZip').prop('readonly', false);
			$('#quoteEntryMemoOne').prop('readonly', false);
			$('#quoteEntryMemoTwo').prop('readonly', false);
			$('#quoteEntryNotes').prop('readonly', false);
			$('#quoteEntryMessage').prop('readonly', false);
        }
	   	
        function popupForQuoteEntryItem(){
        	debugger;
        	addedQuoteEntryItemArray=[];
 			var modalCustPORequired = $('#quoteEntryModalCustPORequired').val().trim();
			var shipVia = $('#quoteEntryShipVia').val().trim();
 			var customerPo = $('#quoteEntryCustomerPo').val().trim();
 			var addressOne = $('#quoteEntryAddressOne').val().trim();
 			var city = $('#quoteEntryCity').val().trim();
 			var state = $('#quoteEntryState').val().trim();
 			var zip = $('#quoteEntryZip').val().trim();
         	
 			$('#quoteEntryAddressOne,#quoteEntryCity,#quoteEntryState,#quoteEntryZip,#quoteEntryShipVia,#quoteEntryCustomerPo').removeClass('is-invalid');
        	if(addressOne === "") {
        		$('#quoteEntryAddressOne').addClass("is-invalid").focus();
				return false;
			}
        	else if(city === "") {
        		$('#quoteEntryCity').addClass("is-invalid").focus();
				return false;
			}
        	if(state === "") {
        		$('#quoteEntryState').addClass("is-invalid").focus();
				return false;
			}
        	else if(zip === "") {
        		$('#quoteEntryZip').addClass("is-invalid").focus();
				return false;
			}
 			
 			if(shipVia === "") {
 				$('#quoteEntryShipVia').addClass("is-invalid").focus();
		        $('.step-one').removeClass('d-none').addClass('d-block');
		        $('#quoteEntryBackBtn').addClass('d-none');
		        $('#quoteEntryNextBtn').removeClass('d-none');
		        $('#quoteEntryCompleteBtn').addClass('d-none');
		        return false;
			}
			else{
	 			$('#quoteEntryShipVia').removeClass('is-invalid');
			}
			
			$('#quoteEntryCustomerPoLabel .required-star').remove();
	        if(custPORequiredForOrderAndTemplate == 1) {
				$('#quoteEntryCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
	        	if (customerPo == "") {
	 				$('#quoteEntryCustomerPo').addClass("is-invalid").focus();
			        $('.step-one').removeClass('d-none').addClass('d-block');
			        $('#quoteEntryBackBtn').addClass('d-none');
			        $('#quoteEntryNextBtn').removeClass('d-none');
			        $('#quoteEntryCompleteBtn').addClass('d-none');
			        return false;
			    } else {
		 			$('#quoteEntryCustomerPo').removeClass('is-invalid');
			        //$('.step-two').removeClass('d-block').addClass('d-none');
			        $('.step-one').removeClass('d-block').addClass('d-none');
			        $('.step-two').removeClass('d-none').addClass('d-block');
			        $('#quoteEntryBackBtn').removeClass('d-none');
			        $('#quoteEntryNextBtn').addClass('d-none');
			        $('#quoteEntryCompleteBtn').removeClass('d-none');
			    }
			}
	        else{
		        //$('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-block').addClass('d-none');
		        $('.step-two').removeClass('d-none').addClass('d-block');
		        $('#quoteEntryBackBtn').removeClass('d-none');
		        $('#quoteEntryNextBtn').addClass('d-none');
		        $('#quoteEntryCompleteBtn').removeClass('d-none');
	        }

			$('#QuoteEntryItemTable').DataTable().destroy();
        	$('#QuoteEntryItemTable tbody').empty();
        	
        	var urlStr="";
        	if(quoteEntryQuoteId !== ""){
        		$('#quoteEntryDeleteHeader').remove();
        		$('#quoteEntryExtPriceHeader').remove();
        		$('#QuoteEntryItemTable thead tr').append(
        		        '<th id="quoteEntryExtPriceHeader" width="7%" class="text-right">Ext Price</th>'
        		);        		
        		$('#QuoteEntryItemTable thead tr').append(
        		        '<th id="quoteEntryDeleteHeader" width="7%" class="text-center">Delete</th>'
        		);        		
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=QuoteIdQuickList&quoteId="+quoteEntryQuoteId;
        	}
        	else{
        		$('#quoteEntryDeleteHeader').remove();
        		$('#quoteEntryExtPriceHeader').remove();
        		urlStr="../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList";
        	}

        	$('#quoteEntryUpdateHeaderBtn').addClass('d-none');
        	$('#preloader').removeClass('d-none');
        	$.ajax({
  				url : urlStr,
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="",seqTd="",checkboxTd="",extPriceTd="",priceUOMTd="",qtyUOMTd="",qtyTd="",deleteItemTd="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			if(quoteEntryQuoteId !== ""){
		        				seqTd = ' data-seq="'+row.displaySeq+'" ';
		        				checkboxTd = '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        				priceUOMTd = '<td class="text-center">'+row.priceUOM+'</td>';
		        				qtyTd = '<td class="text-right"><input type="number" value='+Number(row.qty).toFixed(3)+' style="width:100px;" class="form-control form-control-sm"></td>';
		        				qtyUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				extPriceTd = '<td class="text-right" nowrap>'+Number(row.extPrice).toFixed(3)+'</td>';
		        				addedQuoteEntryItemArray.push(row.itemCode);
								deleteItemTd='<td class="text-center">'+
						        				'<button type="button" class="btn btn-outline-danger btn-sm delete-quote-btn" '+
							        				'data-quoteid="'+quoteEntryQuoteId+'" data-lineno="'+row.displaySeq+'">'+
						        					'<i class="icon-delete"></i> </button>'+
						    					'</td>';
		        			}else{
		        				seqTd = ' ';
		        				checkboxTd = '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        				priceUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				qtyTd = '<td class="text-right"><input type="number"  value="0" style="width:100px;" class="form-control form-control-sm"></td>';
		        				qtyUOMTd = '<td class="text-center">'+row.UOM+'</td>';
		        				extPriceTd='';
		        				deleteItemTd='';
		        			}
		        					
		        			itemRow = '<tr '+seqTd+'>'+checkboxTd+
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											priceUOMTd+qtyTd+qtyUOMTd+extPriceTd+deleteItemTd+
						   			   '</tr>';
							$('#QuoteEntryItemTable').append(itemRow);
						});
					}
					$('#QuoteEntryItemTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					setTimeout(function () {
					    $('#QuoteEntryItemTable tbody input[type="number"]:first').focus().select();
					}, 0);
					
					$('#QuoteEntryItemTable').off('click', '.delete-quote-btn').on('click', '.delete-quote-btn', function() {
					    const quoteId = $(this).data('quoteid');
					    const lineNo = $(this).data('lineno');
					    deleteQuoteEntryItem(quoteId, lineNo);
					});

					$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
        }
        
        $('#QuoteEntryItemTable').off('input', 'input[type="number"]').on('input', 'input[type="number"]', function () {
            const qty = Number($(this).val());
            const row = $(this).closest('tr');
            const checkbox = row.find('.rowCheck');
            if (qty > 0) {
                checkbox.prop('checked', true);
            } else {
                checkbox.prop('checked', false);
            }
            
        });
        
        var quoteEntryDatatableLength=[],quoteEntryItemSeq=[],quoteEntryItemCode=[],quoteEntryPrice=[],quoteEntryPriceUom=[],quoteEntryOrderedQty=[],quoteEntryStockingUom=[];
		function saveQuoteEntry(){
	   		debugger;
 			$('#quoteEntryAddressOne,#quoteEntryCity,#quoteEntryState,#quoteEntryZip,#quoteEntryShipVia,#quoteEntryCustomerPo').removeClass('is-invalid');
	   		var parameters;
        	var modalCustPORequired = $('#quoteEntryModalCustPORequired').val().trim();
	   		var shipToSeq = $('#quoteEntryShipToSeq').val().trim();
	   		var shipToName = $('#quoteEntryShipToName').val().trim();
			var addressOne = $('#quoteEntryAddressOne').val().trim();
			var addressTwo = $('#quoteEntryAddressTwo').val().trim();
			var city = $('#quoteEntryCity').val().trim();
			var state = $('#quoteEntryState').val().trim();
			var zip = $('#quoteEntryZip').val().trim();
			var contactName = $('#quoteEntryMemoOne').val().trim();
			var phone = $('#quoteEntryMemoTwo').val().trim();
			var shipVia = $('#quoteEntryShipVia').val().trim();
			var customerPo = $('#quoteEntryCustomerPo').val().trim();
			var referenceId = $('#quoteEntryReferenceId').val().trim();
			var jobNo = $('#quoteEntryAddressThree').val().trim();
			var expectedDeliveryDate = $('#quoteEntryExpectedDeliveryDate').val().trim();
			var notes = $('#quoteEntryNotes').val().trim();
			var message = $('#quoteEntryMessage').val().trim();

			quoteEntryItemSeq=[],quoteEntryItemCode=[],quoteEntryPrice=[],quoteEntryPriceUom=[],quoteEntryOrderedQty=[],quoteEntryStockingUom=[];
			var oTable = $('#QuoteEntryItemTable').DataTable();
			oTable.rows().every(function(rowIdx, tableLoop, rowLoop) {
			    var rowNode = this.node();
			    var $checkbox = $(rowNode).find('input[type="checkbox"]');
			    if ($checkbox.prop('checked')) {
			        var $cells = $(rowNode).find('td');
			        var qty = $(rowNode).find('input[type="number"]').val();
			        if (qty > 0) {
			        	quoteEntryItemSeq.push($(rowNode).data('seq'));
			        	quoteEntryItemCode.push($cells.eq(1).text().trim());
			        	quoteEntryPrice.push(parseFloat($cells.eq(4).text().trim()));
			        	quoteEntryPriceUom.push($cells.eq(5).text().trim());
			        	quoteEntryOrderedQty.push(qty);
			        	quoteEntryStockingUom.push($cells.eq(7).text().trim());
			        }
			    }
			});

			$('#quoteEntryCustomerPoLabel .required-star').remove();
			if(custPORequiredForOrderAndTemplate == 1){
				$('#quoteEntryCustomerPoLabel').append('<span class="text-danger small required-star">*</span>');
				if (customerPo == "" || customerPo == null) {
					$('#quoteEntryCustomerPo').addClass("is-invalid").focus();
					return false;
				}
			}
			
			if($('.rowCheck:checked').length == 0) {
				$('#QuoteEntryErrorMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
				if(quoteEntryQuoteId == ""){
					$('#preloader').removeClass('d-none');
					parameters="param=SaveQuoteEntry&shipToSeq="+shipToSeq+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+
								"&city="+city+"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+
								"&referenceId="+referenceId+"&jobNo="+jobNo+"&expectedDeliveryDate="+expectedDeliveryDate+"&notes="+notes+"&message="+message+
								"&itemCode="+quoteEntryItemCode+"&price="+quoteEntryPrice+"&priceUom="+quoteEntryPriceUom+"&orderedQty="+quoteEntryOrderedQty+"&stockingUom="+quoteEntryStockingUom;
					$.ajax({
					 	url:"../customerPortal/A_CP_ShopAction.jsp",
						type : "POST",
						dataType: "text",
						data: parameters,
						success: function (response) {
							$('#QuoteEntryModal').modal('hide');
							$('#QuoteEntryMessageModal').modal('show');
							$('#QuoteEntryMessageModalErrorMsg').html(response);
							$('#preloader').addClass('d-none');
						},
					 	failure: function (response) {
					    }
					});
				}else{
					parameters="param=QuoteEntryDetailsUpdate&orderId="+quoteEntryQuoteId+"&itemSeq="+quoteEntryItemSeq+"&itemCode="+quoteEntryItemCode+"&price="+quoteEntryPrice+"&priceUom="+quoteEntryPriceUom+"&orderedQty="+quoteEntryOrderedQty+"&stockingUom="+quoteEntryStockingUom;
					$.ajax({
					 	url:"../customerPortal/A_CP_ShopAction.jsp",
						type : "POST",
						dataType: "text",
						data: parameters,
						success: function (response) {
							popupForQuoteEntryItem();
						},
					 	failure: function (response) {
					    }
					});
				}
			}
		}
		
	   	function popupForUpdateQuoteEntryHeader(quoteId){
	   		quoteEntryQuoteId=quoteId;
	   		$('#QuoteEntryErrorMsg').html('');
 			$('#quoteEntryAddressOne,#quoteEntryCity,#quoteEntryState,#quoteEntryZip,#quoteEntryShipVia,#quoteEntryCustomerPo').removeClass('is-invalid');
        	$("#quoteEntryUpdateHeaderBtn").show();
        	$("#quoteEntryAddItemBtn").show();
        	$("#quoteIdForQuoteEntryHeader").show();
        	
        	$('#quoteEntryShipToName').val('');
			$('#quoteEntryAddressOne').val('');
			$('#quoteEntryAddressTwo').val('');
			$('#quoteEntryCity').val('');
			$('#quoteEntryState').val('');
			$('#quoteEntryZip').val('');
			$('#quoteEntryMemoOne').val('');
			$('#quoteEntryMemoTwo').val('');
			$('#quoteEntryShipVia').val('');
			$('#quoteEntryCustomerPo').val('');
			$('#quoteEntryReferenceId').val('');
			$('#quoteEntryAddressThree').val('');
			//$('#quoteEntryExpectedDeliveryDate').val('');
			$('#quoteEntryNotes').val('');
			$('#quoteEntryMessage').val('');
			
			$('#quoteEntryAddressOne').prop('readonly', true);
			$('#quoteEntryAddressTwo').prop('readonly', true);
			$('#quoteEntryCity').prop('readonly', true);
			$('#quoteEntryState').prop('readonly', true);
			$('#quoteEntryZip').prop('readonly', true);
			$('#quoteEntryMemoOne').prop('readonly', true);
			$('#quoteEntryMemoTwo').prop('readonly', true);
			$('#quoteEntryNotes').prop('readonly', true);
			$('#quoteEntryMessage').prop('readonly', true);
			
			$('#quoteEntryQuoteId').val(quoteEntryQuoteId);

			$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_ShopAction.jsp?param=GetTemplateHeader&quoteId="+quoteId,
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#quoteEntryQuoteId').val(response.orderId);
					$('#quoteEntryShipToName').val(response.shipToName);
					$('#quoteEntryAddressOne').val(response.addressOne);
					$('#quoteEntryAddressTwo').val(response.addressTwo);
					$('#quoteEntryCity').val(response.city);
					$('#quoteEntryState').val(response.state);
					$('#quoteEntryZip').val(response.zip);
					$('#quoteEntryMemoTwo').val(response.phone);
					$('#quoteEntryShipVia').val(response.shipVia);
					$('#quoteEntryCustomerPo').val(response.customerPO);
					$('#quoteEntryReferenceId').val(response.referenceId);
					$('#quoteEntryAddressThree').val(response.jobNo);
				},
				failure: function (response) {
				}
			});
			$('#quoteIdForQuoteEntryHeader').html(quoteEntryQuoteId);
        	$('#QuoteEntryModal').modal('show');
	   	}
	   	
	   	function updateQuoteEntryHeader(){
	   		$('#QuoteEntryErrorMsg').html('');
	   		var orderId = $('#quoteEntryQuoteId').val().trim();
	   		var shipToName = $('#quoteEntryShipToName').val().trim();
			var addressOne = $('#quoteEntryAddressOne').val().trim();
			var addressTwo = $('#quoteEntryAddressTwo').val().trim();
			var city = $('#quoteEntryCity').val().trim();
			var state = $('#quoteEntryState').val().trim();
			var zip = $('#quoteEntryZip').val().trim();
			var contactName = $('#quoteEntryMemoOne').val().trim();
			var phone = $('#quoteEntryMemoTwo').val().trim();
			var shipVia = $('#quoteEntryShipVia').val().trim();
			var customerPo = $('#quoteEntryCustomerPo').val().trim();
			var referenceId = $('#quoteEntryReferenceId').val().trim();
			var jobNo = $('#quoteEntryAddressThree').val().trim();
			var expectedDeliveryDate = $('#quoteEntryExpectedDeliveryDate').val().trim();
			var notes = $('#quoteEntryNotes').val().trim();
			var message = $('#quoteEntryMessage').val().trim();

			parameters="param=UpdateTemplateHeader&quoteId="+quoteEntryQuoteId+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+
						"&city="+city+"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+
						"&referenceId="+referenceId+"&jobNo="+jobNo+"&expectedDeliveryDate="+expectedDeliveryDate+"&notes="+notes+"&message="+message;
			$.ajax({
			 	url:"../customerPortal/A_CP_ShopAction.jsp",
				type : "POST",
				dataType : 'text',
				data: parameters,
				success: function (response) {
					$('#QuoteEntryErrorMsg').html(response);
				},
			 	failure: function (response) {
			    }
			});
	   	}

		
	   	function popupForNewQuoteEntryItemList(){
	   		$('#preloader').removeClass('d-none');
	   		$('#QuoteEntryItemListModalMsg').html('');
			$('#QuoteEntryItemListTable').DataTable().destroy();
        	$('#QuoteEntryItemListTable tbody').empty();
  			$.ajax({
  				url : "../customerPortal/A_CP_ShopAction.jsp?param=QuicklistPriceandAvailList",
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.QuoteItemList;
		        	var itemRow ="";
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			var hideCheckbox = addedQuoteEntryItemArray.includes(row.itemCode);
		        		    var checkboxTd = hideCheckbox ? '<td></td>' : '<td align="left"><input type="checkbox" class="rowCheck" tabindex="-1"></td>';
		        		    itemRow = '<tr>'+
		        		    				checkboxTd +
		        							'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemCode+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemDescription+'</td>'+
											'<td class="datatableBtnWrp" align="left" nowrap>'+row.itemSize+'</td>'+
											'<td class="text-right" nowrap>'+Number(row.grossPrice).toFixed(3)+'</td>'+
											'<td class="text-center">'+row.UOM+'</td>'+
											'<td class="text-right"><input type="number"  value="0" style="width:100px;" class="form-control form-control-sm"></td>'+
											'<td class="text-center">'+row.UOM+'</td>'+
						   			   '</tr>';
							$('#QuoteEntryItemListTable').append(itemRow);
						});
					}
					$('#QuoteEntryItemListTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					$('#QuoteEntryItemListTable tbody tr').each(function () {
				        if ($(this).find('.rowCheck').length === 0) {
				            $(this).find('input[type="number"]').attr('tabindex', '-1');
				        }
				    });
					
					$('#QuoteEntryItemListTable tbody tr').has('input.rowCheck').find('input[type="number"]').first().focus().select();
					
			   		$('#preloader').addClass('d-none');
		        },
 			 	failure: function (response) {
 			    }
 			});
	   	}

        $('#QuoteEntryItemListTable').off('input', 'input[type="number"]').on('input', 'input[type="number"]', function () {
            const qty = Number($(this).val());
            const row = $(this).closest('tr');
            const checkbox = row.find('.rowCheck');
            if (qty > 0) {
                checkbox.prop('checked', true);
            } else {
                checkbox.prop('checked', false);
            }
            
        });

		function deleteQuoteEntryHeader(quoteId){
	   	    $('#QuoteEntryDeleteConfirmHeaderModal').modal('show');
	   	    $('#quoteEntryConfirmDeleteHeaderBtn').off('click').on('click', function () {
				window.location="../customerPortal/A_CP_ShopAction.jsp?param=DeleteTemplate&quoteId="+quoteId;
				$('#QuoteEntryDeleteConfirmHeaderModal').modal('hide');
				
	   	    });
		}

		function deleteQuoteEntryItem(quoteId, lineNo) {
	   	    $('#QuoteEntryDeleteConfirmItemModal').modal('show');
	   	    $('#quoteEntryConfirmDeleteItemBtn').off('click').on('click', function () {
	   	        var parameters = "param=DeleteTemplateItem&quoteId="+quoteId+"&lineNo="+lineNo;
	   	        $.ajax({
	   	            url: "../customerPortal/A_CP_ShopAction.jsp",
	   	            type: "POST",
	   	            dataType: "text",
	   	            data: parameters,
	   	            success: function (response) {
	   	                $('#QuoteEntryErrorMsg').html(response);
	   	             	popupForQuoteEntryItem();
	   	                $('#QuoteEntryDeleteConfirmItemModal').modal('hide');
	   	            }
	   	        });
	   	    });
	   	}

	   	function addQuoteEntryItem(){
	   		debugger;
	   		var parameters;
	   		var quoteId = $('#quoteEntryQuoteId').val().trim();
	   		var shipToName = $('#quoteEntryShipToName').val().trim();
			var addressOne = $('#quoteEntryAddressOne').val().trim();
			var addressTwo = $('#quoteEntryAddressTwo').val().trim();
			var city = $('#quoteEntryCity').val().trim();
			var state = $('#quoteEntryState').val().trim();
			var zip = $('#quoteEntryZip').val().trim();
			var contactName = $('#quoteEntryMemoOne').val().trim();
			var phone = $('#quoteEntryMemoTwo').val().trim();
			var shipVia = $('#quoteEntryShipVia').val().trim();
			var customerPo = $('#quoteEntryCustomerPo').val().trim();
			var referenceId = $('#quoteEntryReferenceId').val().trim();
			var expectedDeliveryDate = $('#quoteEntryExpectedDeliveryDate').val().trim();
			
			quoteEntryItemCode=[],quoteEntryPrice=[],quoteEntryPriceUom=[],quoteEntryOrderedQty=[],quoteEntryStockingUom=[];
			var oTable = $('#QuoteEntryItemListTable').DataTable();
			oTable.rows().every(function(rowIdx, tableLoop, rowLoop) {
			    var rowNode = this.node();
			    var $checkbox = $(rowNode).find('input[type="checkbox"]');
			    if ($checkbox.prop('checked')) {
			        var $cells = $(rowNode).find('td');
			        var qty = $(rowNode).find('input[type="number"]').val();
			        if (qty > 0) {
			        	quoteEntryItemCode.push($cells.eq(1).text().trim());
			        	quoteEntryPrice.push(parseFloat($cells.eq(4).text().trim()));
			        	quoteEntryPriceUom.push($cells.eq(5).text().trim());
			        	quoteEntryOrderedQty.push(qty);
			        	quoteEntryStockingUom.push($cells.eq(7).text().trim());
			        }
			    }
			});
			
			if($('.rowCheck:checked').length === 0) {
				$('#QuoteEntryItemListModalMsg').html("Please select at least one item.");
		        return false;
		    }
			else{
		   		$('#preloader').removeClass('d-none');
				parameters="param=AddQuoteEntryItem&quoteId="+quoteEntryQuoteId+"&shipToName="+shipToName+"&addressOne="+addressOne+"&addressTwo="+addressTwo+"&city="+city+
							"&state="+state+"&zip="+zip+"&contactName="+contactName+"&phone="+phone+"&shipVia="+shipVia+"&customerPo="+customerPo+"&referenceId="+referenceId+"&expectedDeliveryDate="+expectedDeliveryDate+
							"&itemCode="+quoteEntryItemCode+"&price="+quoteEntryPrice+"&priceUom="+quoteEntryPriceUom+"&orderedQty="+quoteEntryOrderedQty+"&stockingUom="+quoteEntryStockingUom;
				
				$.ajax({
				 	url:"../customerPortal/A_CP_ShopAction.jsp",
					type : "POST",
					dataType: "text",
					data: parameters,
					success: function (response) {
						$('#QuoteEntryItemListModal').modal('hide');
						$('#QuoteEntryErrorMsg').html(response);
						popupForQuoteEntryItem();
					},
				 	failure: function (response) {
				    }
				});
			}
	   	}	   	
        

	   	
	   	
        function popupForHeaderDetail(quoteId,custPORequired){
			quoteIdVar=quoteId;
			custPORequiredVar=custPORequired;

			//console.log(document.getElementById("modalQuoteId"));
			document.getElementById('modalQuoteId').value=quoteIdVar;
			document.getElementById("modalCustPORequired").value=custPORequiredVar;
			
			$('#fileNameText').html('No file chosen');
			$('#customerPo').val('');
			$('#referenceId').val('');
			$('#message').val('');
			$('#notes').val('');
			$('#shipToName').val('');
			$('#addressOne').val('');
			$('#addressTwo').val('');
			$('#addressThree').val('');
			//$('#shipVia').val('');
			$('#city').val('');
			$('#state').val('');
			$('#zip').val('');
			$('#memoOne').val('');
			$('#memoTwo').val('');
			//$('#expectedDeliveryDate').val('');
        	$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_ShopAction.jsp?param=HeaderDetails&quoteId="+quoteId,
				dataType : 'json',
		        contentType : 'application/json',
				success : function (response) {
					$('#shipToName').val(response.shipToName);
					$('#addressOne').val(response.addressOne);
					$('#addressTwo').val(response.addressTwo);
					$('#addressThree').val(response.addressThree);
					//$('#shipVia').val(response.shipVia);
					$('#city').val(response.city);
					$('#state').val(response.state);
					$('#zip').val(response.zip);
					$('#memoOne').val(response.contactName);
					$('#memoTwo').val(response.phone);
					//$('#expectedDeliveryDate').val(response.expectedDeliveryDate);
				},
				failure: function (response) {
				}
			});
        	//$('#HeaderModal').modal('show');
        }

		
        function popupForProduct(){
        	debugger;
        	$('#addressOne,#city,#state,#zip,#shipViaNew,#customerPo').removeClass('is-invalid');
 			var modalCustPORequired = $('#modalCustPORequired').val().trim();
 			var addressOne = $('#addressOne').val().trim();
 			var city = $('#city').val().trim();
 			var state = $('#state').val().trim();
 			var zip = $('#zip').val().trim();
 			var shipVia = $('#shipViaNew').val().trim();
 			var customerPo = $('#customerPo').val().trim();
			var expectedDeliveryDate = $('#expectedDeliveryDate').val().trim();
         	
			const regex = /^(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])-\d{4}$/;
			
        	if(addressOne === "") {
        		$('#addressOne').addClass("is-invalid").focus();
				return false;
			}
        	else if(city === "") {
        		$('#city').addClass("is-invalid").focus();
				return false;
			}
        	else if(state === "") {
        		$('#state').addClass("is-invalid").focus();
				return false;
			}
        	else if(zip === "") {
        		$('#zip').addClass("is-invalid").focus();
				return false;
			}
 			if(shipVia === "") {
 				$('#shipViaNew').addClass("is-invalid").focus();
		        $('.step-one').removeClass('d-none').addClass('d-block');
		        $('#backBtn').addClass('d-none');
		        $('#nextBtn').removeClass('d-none');
		        $('#completeBtn').addClass('d-none');
		        return false;
			}
			else{
	 			$('#shipViaNew').removeClass('is-invalid');
			}
			
			$('#customerPOLabel .required-star').remove();
	        if(modalCustPORequired == 1) {
				$('#customerPOLabel').append('<span class="text-danger small required-star">*</span>');
	        	if (customerPo === "") {
	 				$('#customerPo').addClass("is-invalid").focus();
			        $('.step-one').removeClass('d-none').addClass('d-block');
			        $('#backBtn').addClass('d-none');
			        $('#nextBtn').removeClass('d-none');
			        $('#completeBtn').addClass('d-none');
			        return false;
			    } else {
		 			$('#customerPo').removeClass('is-invalid');
			        //$('.step-two').removeClass('d-block').addClass('d-none');
			        $('.step-one').removeClass('d-block').addClass('d-none');
			        $('.step-two').removeClass('d-none').addClass('d-block');
			        $('#backBtn').removeClass('d-none');
			        $('#nextBtn').addClass('d-none');
			        $('#completeBtn').removeClass('d-none');
			    }
			}
	        else{
		        //$('.step-two').removeClass('d-block').addClass('d-none');
		        $('.step-one').removeClass('d-block').addClass('d-none');
		        $('.step-two').removeClass('d-none').addClass('d-block');
		        $('#backBtn').removeClass('d-none');
		        $('#nextBtn').addClass('d-none');
		        $('#completeBtn').removeClass('d-none');
	        }

	        if(expectedDeliveryDate === "" || expectedDeliveryDate == null) {
	        	$('#expectedDeliveryDate').addClass("is-invalid").focus();
		        $('.step-one').removeClass('d-none').addClass('d-block');
		        $('.step-two').removeClass('d-block').addClass('d-none');
		        $('#backBtn').addClass('d-none');
		        $('#nextBtn').removeClass('d-none');
		        $('#completeBtn').addClass('d-none');
		        return false;
	        }
	        else{
	        	if (!regex.test(expectedDeliveryDate)) {
		        	$('#expectedDeliveryDate').addClass("is-invalid").focus();
			        $('.step-one').removeClass('d-none').addClass('d-block');
			        $('.step-two').removeClass('d-block').addClass('d-none');
			        $('#backBtn').addClass('d-none');
			        $('#nextBtn').removeClass('d-none');
			        $('#completeBtn').addClass('d-none');
			        return false;
	            } 
				else{
					$('#expectedDeliveryDate').removeClass('is-invalid');
				}
	        }

	        console.log("quoteIdVar >>>> " + quoteIdVar);
	        
			$('#CreateOrderTable').DataTable().destroy();
        	$('#CreateOrderTable tbody').empty();
  			$.ajax({
  				url : "../customerPortal/A_CP_ShopAction.jsp?param=CreateOrder&quoteId="+quoteIdVar,
  				type : 'POST',
 				dataType : 'json',
		        contentType : 'application/json',
		        success : function (response) {
		        	var data = response.Details;
		        	if(data.length != 0){
		        		$.each(data, function (key, row) {
		        			let priceUomCode=row.priceUomCode;
		        			var notesRow = '<tr>'+
												'<td class="datatableBtnWrp" align="left" nowrap>'+row.item+'</td>'+
												'<td class="datatableBtnWrp" align="left" nowrap>'+row.description+'</td>'+
												'<td class="datatableBtnWrp" align="left" nowrap>'+row.size+'</td>'+
												'<td class="text-right" nowrap>'+Number(row.price).toFixed(3)+'</td>'+
												'<td class="text-center">'+priceUomCode+'</td>'+
												'<td class="text-right"><input type="number" id="quantity" name="quantity" value='+row.quantity+' style="width:100px;" class="form-control form-control-sm"></td>'+
												'<td class="text-center">'+row.stockingUom+'</td>'+
						   				   '</tr>';
							$('#CreateOrderTable').append(notesRow);
						});
						//$('#CreateOrderTable').DataTable().ajax.reload();
					}
					$('#CreateOrderTable').DataTable({
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
						'scrollCollapse': true,
						'ordering': false
					});
					
					setTimeout(function () {
					    $('#CreateOrderTable tbody input[type="number"]:first').focus().select();
					}, 0);

		        },
 			 	failure: function (response) {
 			    }
 			});
        }
		
        
        function uploadPurchaseOrder(){
        	//window.open("../ar/A_DocumentUpload.jsp?moduleType=AR&queryname="+queryName+"&keywordIndexCustomer_0="+typeId, 'popup','width=1100,height=550,left=50,top=80,screenX=80,screenY=100,resizable=no,scrollbars=no');
        }
        
		
        var datatableLength=[],itemCode=[],price=[],priceUom=[],orderedQty=[],stockingUom=[];
	    function saveOrder(){
			debugger;
	   		$('#preloader').removeClass('d-none');
	   		var parameters;
	   		var modalQuoteId = document.getElementById('modalQuoteId').value;
			var modalCustPORequired = document.getElementById('modalCustPORequired').value;
			var customerPo = document.getElementById('customerPo').value;
			var referenceId = document.getElementById('referenceId').value;
			var message = document.getElementById('message').value;
			var notes = document.getElementById('notes').value;
			var shipToname = document.getElementById('shipToName').value;
			var addressOne = document.getElementById('addressOne').value;
			var addressTwo = document.getElementById('addressTwo').value;
			var addressThree = document.getElementById('addressThree').value;
			var shipVia = document.getElementById('shipViaNew').value;
			var city = document.getElementById('city').value;
			var state = document.getElementById('state').value;
			var zip = document.getElementById('zip').value;
			var memoOne = document.getElementById('memoOne').value;
			var memoTwo = document.getElementById('memoTwo').value;
			var expectedDeliveryDate = document.getElementById('expectedDeliveryDate').value;

			itemCode=[],price=[],priceUom=[],orderedQty=[],stockingUom=[];
			
			/*var row,data,rowNode,qty,table;
	   		var oTable = $('#CreateOrderTable').DataTable();
			datatableLength = oTable.fnGetData();
			for(i=0; i<datatableLength.length; i++){
				table = new DataTable('#CreateOrderTable');
				row = table.row(':eq('+i+')');
				data = row.data();
		   		rowNode=row.node();
		   		qty=$(rowNode).find('input').val();
				if(qty > 0){
					itemCode.push(data[0]);
					price.push(parseFloat(data[3]));
					priceUom.push(data[4]);
					orderedQty.push(qty);
					stockingUom.push(data[6]);
				}
			} */
			
			var oTable = $('#CreateOrderTable').DataTable();
			var datatableLength = oTable.data().toArray();
			for (var i = 0; i < datatableLength.length; i++) {
			    var row = oTable.row(i);
			    var data = row.data();
			    var rowNode = row.node();
			    var qty = $(rowNode).find('input').val();
			    if (qty > 0) {
			        itemCode.push(data[0]);
			        price.push(parseFloat(data[3]));
			        priceUom.push(data[4]);
			        orderedQty.push(qty);
			        stockingUom.push(data[6]);
			    }
			}			
	    	
			var formData = new FormData();
			formData.append("param", "SaveOrder");
			formData.append("quoteId", modalQuoteId);
			formData.append("customerPo", customerPo);
			formData.append("referenceId", referenceId);
			formData.append("message", message);
			formData.append("notes", notes);
			formData.append("shipToname", shipToname);
			formData.append("addressOne", addressOne);
			formData.append("addressTwo", addressTwo);
			formData.append("addressThree", addressThree);
			formData.append("shipVia", shipVia);
			formData.append("city", city);
			formData.append("state", state);
			formData.append("zip", zip);
			formData.append("memoOne", memoOne);
			formData.append("memoTwo", memoTwo);
			formData.append("expectedDeliveryDate", expectedDeliveryDate);
			formData.append("itemCode", itemCode);
			formData.append("price", price);
			formData.append("priceUom", priceUom);
			formData.append("orderedQty", orderedQty);
			formData.append("stockingUom", stockingUom);
			
			var fileInput = document.getElementById("documentFile");
			if (fileInput.files.length > 0) {
			    //formData.append("documentFile", fileInput.files[0]);
			    formData.append('documentFile',$('#documentFile').get(0).files[0]);
			}
			
			if(modalCustPORequired == 1){
				if (customerPo === "" || customerPo === null) {
					$('#customerPo').addClass("is-invalid").focus();
					return false;
				}
			}
			
			if(itemCode != null || itemCode != ""){
				$.ajax({
					url: 'ShopAction',
					type: 'POST',
					data: formData,
					dataType: 'text',
					enctype: 'multipart/form-data',
					//mimeType: 'multipart/form-data', 
					contentType: false,
					cache: false,
					processData: false,
					success: function(response){
						$('#createOrder').modal('hide');
						$('#MessageModal').modal('show');
						$('#errorMsg').html(response); // <- Important: Use html()
						$('#preloader').addClass('d-none');
					},
					error: function(jqXHR,status,error){
						/*$('#resultLoading').hide();
					    $('#msgDiv').text('Technical Failure!'); */
					}
				});
			}
		}
	    
	    
        function popupForOpenOrdersInquiry(soId){
		 	debugger;
       		inquiryHeader(soId);
			inquiryDetails(soId);
			soIdTemp=soId;
			$('#orderInformation').modal('show');
        }

        function inquiryHeader(soId){
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
			$('#orderTotalTile').text('');
			$('#totalSaleTile').text('');
			$.ajax({
				type : "POST",
				url : "../customerPortal/A_CP_OpenOrdersInquiryAction.jsp?param=InquiryHeader&soId="+soId,
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
					$('#orderTotalTile').text('$'+response.orderTotal);
					$('#totalSaleTile').text('$'+response.totalSale);
				},
				failure: function (response) {
				}
			});
        }
        
        function inquiryDetails(soId){
 	  		//var popupDataTable = new DataTable('#OpenOrdersInquiryDataTable');
 	  		//popupDataTable.clear().draw();

	   		$('#OpenOrdersInquiryDataTable').find('tbody').detach();
	    	$('#OpenOrdersInquiryDataTable').append($('<tbody>'));

        	let nf = new Intl.NumberFormat('en-US');
        	$.ajax({
				url : "../customerPortal/A_CP_OpenOrdersInquiryAction.jsp?param=InquiryDetails&soId="+soId,
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

	<script>
		var shipToNames = [
			<%
			ArrayList<HashMap<String, String>> shipToNameList2 = getShipToNameList2(custKey.trim());
			for (int i = 0; i < shipToNameList2.size(); i++) {
			    HashMap<String, String> mapData = shipToNameList2.get(i);
			    String name = mapData.get("label");
			    if (!"NA".equalsIgnoreCase(name)) {
			%>
			    {
			    	label: "<%= mapData.get("label") %>",
			        value: "<%= mapData.get("value") %>",
			        shipToSeq: "<%= mapData.get("shipToSeq") %>",
			        addressOne: "<%= mapData.get("addressOne") %>",
			        city: "<%= mapData.get("city") %>",
			        state: "<%= mapData.get("state") %>",
			        zip: "<%= mapData.get("zip") %>",
			        customerPO: "<%= mapData.get("customerPO") %>"
			    }<%= (i < shipToNameList2.size() - 1) ? "," : "" %>
			<%}}%>
		];
	
		$("#createOrderShipToName").autocomplete({
		    autoFocus: true,
		    appendTo: "#CreateOrderModal",
		    minLength: 0,
		    source: function (request, response) {
		        if (request.term.length >= 3) {
		            $.ajax({
		                url: "../customerPortal/getShipToName.jsp",
		                dataType: "json",
		                data: {
		                    term: request.term
		                },
		                success: function (data) {
		                    response(data);
		                }
		            });
		        } else {
		            response(shipToNames);
		        }
		    },
		    select: function (event, ui) {
		        $('#createOrderShipToName').val(ui.item.value);
		        $('#createOrderShipToSeq').val(ui.item.shipToSeq);
		        $('#createOrderAddressOne').val(ui.item.addressOne);
		        $('#createOrderCity').val(ui.item.city);
		        $('#createOrderState').val(ui.item.state);
		        $('#createOrderZip').val(ui.item.zip);
		        //$('#createOrderCustomerPo').val(ui.item.customerPO);
		        $('#createOrderModalCustPORequired').val(ui.item.customerPORequired);
		        return false;
		    }
		})
		.on("focus", function () {
		    $(this).autocomplete("search", "");
		});

		$("#templateShipToName").autocomplete({
		    autoFocus: true,
		    appendTo: "#CreateTemplateModal",
		    minLength: 0,
		    source: function (request, response) {
		        if (request.term.length >= 3) {
		            $.ajax({
		                url: "../customerPortal/getShipToName.jsp",
		                dataType: "json",
		                data: {
		                    term: request.term
		                },
		                success: function (data) {
		                    response(data);
		                }
		            });
		        } else {
		            response(shipToNames);
		        }
		    },
		    select: function (event, ui) {
		    	$('#templateShipToName').val(ui.item.value);
		        $('#templateShipToSeq').val(ui.item.shipToSeq);
		        $('#templateAddressOne').val(ui.item.addressOne);
		        $('#templateCity').val(ui.item.city);
		        $('#templateState').val(ui.item.state);
		        $('#templateZip').val(ui.item.zip);
		        //$('#templateCustomerPo').val(ui.item.customerPO);
   		        $('#templateModalCustPORequired').val(ui.item.customerPORequired);
		        return false;
		    }
		})
		.on("focus", function () {
		    $(this).autocomplete("search", "");
		});

		$("#quoteEntryShipToName").autocomplete({
		    autoFocus: true,
		    appendTo: "#QuoteEntryModal",
		    minLength: 0,
		    source: function (request, response) {
		        if (request.term.length >= 3) {
		            $.ajax({
		                url: "../customerPortal/getShipToName.jsp",
		                dataType: "json",
		                data: {
		                    term: request.term
		                },
		                success: function (data) {
		                    response(data);
		                }
		            });
		        } else {
		            response(shipToNames);
		        }
		    },
		    select: function (event, ui) {
		        $('#quoteEntryShipToName').val(ui.item.value);
		        $('#quoteEntryShipToSeq').val(ui.item.shipToSeq);
		        $('#quoteEntryAddressOne').val(ui.item.addressOne);
		        $('#quoteEntryCity').val(ui.item.city);
		        $('#quoteEntryState').val(ui.item.state);
		        $('#quoteEntryZip').val(ui.item.zip);
		        //$('#quoteEntryCustomerPo').val(ui.item.customerPO);
		        $('#quoteEntryModalCustPORequired').val(ui.item.customerPORequired);
		        return false;
		    }
		})
		.on("focus", function () {
		    $(this).autocomplete("search", "");
		});
		
		
		document.getElementById("documentFile").addEventListener("change", function () {
		    const fileName = this.files.length ? this.files[0].name : "No file chosen";
		    document.getElementById("fileNameText").textContent = fileName;
		});
		
	</script>

<%!

	public ArrayList<HashMap<String, String>> getCreateOrderList(String custKey) {	
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
						+" and sa.CREATED_BY='API' "
						+" and sh.so_status NOT IN('I','C') "
						+" ORDER BY sh.SO_ID ";
			Utils.log("CreateOrder Query >>>>>> "+sqlQuery);
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


	public ArrayList<HashMap<String, String>> getTemplateList(String customerId) {	
		String sqlQuery="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select qh.quote_id,qh.CREATED_BY,cs.CUST_PO_REQUIRED, sa.cust_name, sa.ADDRESS_1, sa.ADDRESS_2,sa.ADDRESS_3,sa.CITY, sa.STATE, sa.ZIP "
							+" from quote_header qh, cust_shipto cs, cust cu, SHIP_TO_ADDRESS sa "
							+" WHERE qh.CUST_SHIPTO_GUID=cs.CUST_SHIPTO_GUID " 
							+" and qh.CUST_GUID=cu.CUST_GUID "
							+" and qh.QUOTE_ID=sa.tran_id and sa.type='QU' "
							+" and cu.CUST_CODE='"+customerId+"' "
							+" AND (( qh.type = 'Master/Template' "
					        +" AND (qh.closed_date IS NULL OR qh.closed_date >= SYSDATE) "
					        +" AND qh.indefinite = 1 ) "
					    	+" OR ( qh.CREATED_BY = 'API' )) "
							+" ORDER BY qh.QUOTE_DATE ";		
			Utils.log("Template Query >>>>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector quoteIdVector = new Vector();
			Vector createdByVector = new Vector();
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
				createdByVector = (Vector) ht.get("CREATED_BY");
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
	        		temp.put("createdBy", createdByVector.get(i).toString());
	        		temp.put("custPORequired", custPORequiredVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("addressOne", addressOneVector.get(i).toString());
					temp.put("addressTwo", addressTwoVector.get(i).toString());
					temp.put("addressThree", addressThreeVector.get(i).toString());
					temp.put("city", cityVector.get(i).toString());
					temp.put("state", stateVector.get(i).toString());
					temp.put("zip", zipVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	
	
	public ArrayList<HashMap<String, String>> getQuoteEntryList(String customerId) {	
		String sqlQuery="";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select qh.quote_id,qh.CREATED_BY,cs.CUST_PO_REQUIRED, sa.cust_name, "
						+" sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO, qh.ORDER_TOTAL "  
						+" from quote_header qh, cust_shipto cs, cust cu, SHIP_TO_ADDRESS sa "
						+" WHERE qh.CUST_SHIPTO_GUID=cs.CUST_SHIPTO_GUID "  
						+" AND qh.CUST_GUID=cu.CUST_GUID  and qh.QUOTE_ID=sa.tran_id " 
						+" AND sa.type='QU' "  
						+" AND cu.CUST_CODE='"+customerId+"' "  
						+" AND (( qh.type = 'Regular'  AND (qh.closed_date >= SYSDATE)  AND qh.indefinite = 1 )  OR ( qh.CREATED_BY = 'API' )) " 
						+" ORDER BY qh.QUOTE_DATE ";		
			Utils.log("QuoteEntry Query >>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQueryPro2(sqlQuery);	
			Vector quoteIdVector = new Vector();
			Vector createdByVector = new Vector();
			Vector custPORequiredVector = new Vector();
			Vector custNameVector = new Vector();
			Vector shipToVector = new Vector();
			Vector orderTotalVector = new Vector();
			if (ht != null && ht.size() > 0) {
				quoteIdVector = (Vector) ht.get("QUOTE_ID");
				createdByVector = (Vector) ht.get("CREATED_BY");
				custPORequiredVector = (Vector) ht.get("CUST_PO_REQUIRED");
				custNameVector = (Vector) ht.get("CUST_NAME");
				shipToVector = (Vector) ht.get("SHIP_TO");
				orderTotalVector = (Vector) ht.get("ORDER_TOTAL");
			}
	        if (quoteIdVector.size() > 0) {
	        	for (int i = 0; i < quoteIdVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
	        		temp.put("quoteId", quoteIdVector.get(i).toString());
	        		temp.put("createdBy", createdByVector.get(i).toString());
	        		temp.put("custPORequired", custPORequiredVector.get(i).toString());
					temp.put("custName", custNameVector.get(i).toString());
					temp.put("shipTo", shipToVector.get(i).toString());
					temp.put("orderTotal", orderTotalVector.get(i).toString());
					listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}


	public ArrayList<HashMap<String, String>> getShipToNameList(String custKey) {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select SHIPTO_NAME from CUST_SHIPTO where CUST_KEY='"+custKey+"' ";
			Utils.log("SHIPTO_NAME Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);		
			Vector shipToNameVector=new Vector();
	    	if (ht != null && ht.size() != 0) {
	    		shipToNameVector = (Vector) ht.get("SHIPTO_NAME");
			}
			if (shipToNameVector.size() > 0) {
	        	for (int i = 0; i < shipToNameVector.size(); i++) {      	  
	        		temp=new HashMap<String, String>();
					temp.put("shipToName", shipToNameVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

	public ArrayList<HashMap<String, String>> getShipToNameList2(String custKey) {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query="select SEQ_NUM,SHIPTO_NAME,ADDRESS_1,ADDRESS_2,ADDRESS_3,CITY,STATE,ZIP,SHIP_VIA,CUST_PO_REQUIRED "
							+" from CUST_SHIPTO where CUST_KEY='"+custKey.trim()+"' ";
			Utils.log("SHIPTO_NAME Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);		
			Vector shipToSeqVector=new Vector();
			Vector shipToNameVector=new Vector();
			Vector addressOneVector=new Vector();
			Vector addressTwoVector=new Vector();
			Vector addressThreeVector=new Vector();
			Vector cityVector=new Vector();
			Vector stateVector=new Vector();
			Vector zipVector=new Vector();
			Vector shipViaVector=new Vector();
			Vector customerPORequiredVector=new Vector();
	    	if (ht != null && ht.size() != 0) {
	    		shipToSeqVector = (Vector) ht.get("SEQ_NUM");
	    		shipToNameVector = (Vector) ht.get("SHIPTO_NAME");
	    		addressOneVector = (Vector) ht.get("ADDRESS_1");
	    		addressTwoVector = (Vector) ht.get("ADDRESS_2");
	    		addressThreeVector = (Vector) ht.get("ADDRESS_3");
	    		cityVector = (Vector) ht.get("CITY");
	    		stateVector = (Vector) ht.get("STATE");
	    		zipVector = (Vector) ht.get("ZIP");
	    		shipViaVector = (Vector) ht.get("SHIP_VIA");
	    		customerPORequiredVector = (Vector) ht.get("CUST_PO_REQUIRED");
	    	}
			if (shipToNameVector.size() > 0) {
	        	for (int i = 0; i < shipToNameVector.size(); i++) {      	  
	        		temp=new HashMap<String, String>();
	        		temp.put("shipToSeq", shipToSeqVector.get(i).toString());
	        		temp.put("label", shipToNameVector.get(i).toString());   // what autocomplete shows
	        		temp.put("value", shipToNameVector.get(i).toString());   // what goes into input
	        		temp.put("addressOne", addressOneVector.get(i).toString());
	        		temp.put("addressTwo", addressTwoVector.get(i).toString());
	        		temp.put("addressThree", addressThreeVector.get(i).toString());
	        		temp.put("city", cityVector.get(i).toString());
	        		temp.put("state", stateVector.get(i).toString());
	        		temp.put("zip", zipVector.get(i).toString());
	        		temp.put("shipVia", shipViaVector.get(i).toString());
	        		temp.put("customerPORequired", customerPORequiredVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	

	public ArrayList<HashMap<String, String>> getAddressOneList(String custKey) {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select ADDRESS_1 from CUST_SHIPTO where CUST_KEY='"+custKey+"' ";
			Utils.log("ADDRESS_1 Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);		
			Vector addressOneVector=new Vector();
	    	if (ht != null && ht.size() != 0) {
	    		addressOneVector = (Vector) ht.get("ADDRESS_1");
			}
			if (addressOneVector.size() > 0) {
	        	for (int i = 0; i < addressOneVector.size(); i++) {      	  
	        		temp=new HashMap<String, String>();
					temp.put("addressOne", addressOneVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	
	
	
	public String getOrderStatus(String orderId,String customerId,String warehouse){
		String orderStatus="";
		try{
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
	        	        			orderStatus=obj.get("OrderStatus").toString().trim();
	        	        		}
	        				}
	        			}
	        		}
	        	}
			}
		}
		catch(Exception ex){
			ex.getMessage();
		}
		return orderStatus;
	}

%>
