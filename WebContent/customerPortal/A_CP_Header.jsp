<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>

<% 
	DistUtils distUtils=new DistUtils();
	//String userIdForUserNameHeader = (String)session.getAttribute("userId");
	String customerPortalAdmin="",portalSo="",dashboard="",openOrder="",deliveryImages="",openInvoices="",pastInvoices="",statements="",payment="",userName="";
	
	HashMap<String, String> temp=getCustomerData((String)session.getAttribute("userId").toString().trim());
	if(temp != null && temp.size()>0){
		customerPortalAdmin=temp.get("customerPortalAdmin");
		portalSo=temp.get("portalSo");
		dashboard=temp.get("dashboard");
		openOrder=temp.get("openOrder");
		deliveryImages=temp.get("deliveryImages");
		openInvoices=temp.get("openInvoices");
		pastInvoices=temp.get("pastInvoices");
		statements=temp.get("statements");
		payment=temp.get("payment");
	}
	
	userName = Utils.removeNull(distUtils.getFieldInfo("SELECT FIRSTNAME||' '||MIDDLENAME||' '||LASTNAME as USERNAME FROM ETECHUSER WHERE DEPTID='"+(String)session.getAttribute("customerId").toString().trim()+"'"));	
	
	String userNameHeader="";
	if(userName.length()>30)
		userNameHeader = userName.substring(0, 28);
	else
		userNameHeader = userName;
	
	String pageName=request.getParameter("pageName");
	if(pageName == null || pageName.trim().equals(""))
		pageName="Dashboard";
%>
                    
<!DOCTYPE html>
<html>
<head>
	<meta name="referrer" content="strict-origin-when-cross-origin">

	
	<meta name="viewport" content="width=device-width, initial-scale=1">
    <title>RWC Building Products | Roofing Supply | Building Supplies | Roofers</title>   
    <link rel="shortcut icon" href="NewPortalAssets/assets/images/icons/rwc-favicon.png" type="image/x-icon" />
    
<!-- <link rel='stylesheet' href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/ui-lightness/jquery-ui.css" > -->
    <link rel="stylesheet" href="NewPortalAssets/css/jquery-ui.css" media="all">

	<!-- Image Viewer CSS-->
    <link rel="stylesheet" href="https://unpkg.com/bootstrap@4/dist/css/bootstrap.min.css" crossorigin="anonymous">
	<link rel="stylesheet" href="NewPortalAssets/assets/css/viewer.css">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css">
	
	<!-- Data Table CSS-->
	<link rel="stylesheet" href="NewPortalAssets/css/jquery.dataTables.min.css" media="all">
	<link rel="stylesheet" href="https://cdn.datatables.net/buttons/1.4.1/css/buttons.dataTables.min.css">
	
	<!-- Fontfaces CSS-->
	<!-- <link href="NewPortalAssets/css/font-face.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/font-awesome-4.7/css/font-awesome.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/font-awesome-5/css/fontawesome-all.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/mdi-font/css/material-design-iconic-font.min.css" rel="stylesheet" media="all"> -->
	
	<!-- Bootstrap CSS-->
	<link href="NewPortalAssets/vendor/bootstrap-4.1/bootstrap.min.css" rel="stylesheet" media="all">
	<!-- <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"> -->
	
	
	<!-- Vendor CSS-->
	<!-- <link href="NewPortalAssets/vendor/animsition/animsition.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/bootstrap-progressbar/bootstrap-progressbar-3.3.4.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/wow/animate.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/css-hamburgers/hamburgers.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/slick/slick.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/select2/select2.min.css" rel="stylesheet" media="all">
	<link href="NewPortalAssets/vendor/perfect-scrollbar/perfect-scrollbar.css" rel="stylesheet" media="all"> -->
	
	<!-- Main CSS-->
	<!-- <link rel="stylesheet" href="NewPortalAssets/css/theme.css" media="all"> -->

	<!-- User Profile CSS-->
	<!-- <link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet" media="all"> -->

	<!-- ImageViewer JS-->
	<script type="text/javascript" src="https://unpkg.com/bootstrap@4/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
	<script type="text/javascript" src="https://unpkg.com/jquery@3/dist/jquery.slim.min.js" crossorigin="anonymous"></script>
	<!--<script src="NewPortalAssets/assets/js/viewer.js"></script>-->
	
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Work+Sans:ital,wght@0,100..900;1,100..900&display=swap" rel="stylesheet">
	<link href="https://dev.iconly.io/public/6b1yxLiDkpKB/iconly.css" rel="stylesheet"/>
	<link rel="stylesheet" href="NewPortalAssets/css/style.css" media="all">
	    
</head>

<div id="preloader" aria-hidden="true">
	<div class="loader">
	    <svg class="roof-svg" viewBox="0 0 200 120" role="img" aria-label="Loading roofing content">
	      <!-- Roof outline -->
	      <path class="roof-line" d="M10 90 L100 25 L190 90" fill="none" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
	      <g class="shingles">
	        <!-- row 1 -->
	        <rect class="shingle s1" x="40" y="55" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s2" x="62" y="55" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s3" x="84" y="55" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s4" x="106" y="55" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s5" x="128" y="55" width="18" height="8" rx="1"></rect>
	        <!-- row 2 -->
	        <rect class="shingle s1" x="45" y="67" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s2" x="67" y="67" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s3" x="89" y="67" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s4" x="111" y="67" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s5" x="133" y="67" width="18" height="8" rx="1"></rect>
	        <!-- row 3 -->
	        <rect class="shingle s1" x="50" y="79" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s2" x="72" y="79" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s3" x="94" y="79" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s4" x="116" y="79" width="18" height="8" rx="1"></rect>
	        <rect class="shingle s5" x="138" y="79" width="18" height="8" rx="1"></rect>
	      </g>
	    </svg>
		<div class="loader-text">RWC Building Products</div>
  	</div>
</div>

<body class="animsition">
	<header class="header-area border-bottom position-sticky top-0 bg-white">
		<div class="dope-nav-container breakpoint-off">
			<div class="container-fluid">
				<div class="row">
					<div class="col-md-12 d-flex justify-content-between align-items-center">
 
					<a class="nav-brand" href="A_CP_Dashboard2.jsp?pageName=Dashboard" class="activeitem"><img src="NewPortalAssets/assets/images/logo.png" alt="RWC Building Products" width="100px"></a>
					<nav class="dope-navbar" id="dopeNav">
						<div class="dope-navbar-toggler">
							<span class="navbarToggler"><span></span><span></span><span></span></span>
						</div>
						<div class="dope-menu">
							<div class="dopecloseIcon">
								<div class="cross-wrap"><span class="top"></span><span class="bottom"></span></div>
							</div>
							<div class="dopenav">
							<ul id="nav" class="m-0 p-0">
		                        		<%if(dashboard.trim().equalsIgnoreCase("Y")){
		                        			if(pageName.equalsIgnoreCase("Dashboard")){ %>			                            
										<li>
			                                <a href="A_CP_Dashboard2.jsp?pageName=Dashboard" class="activeitem">
			                                    <i class="icon-home"></i>Dashboard
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_Dashboard2.jsp?pageName=Dashboard" >
			                                    <i class="icon-home"></i>Dashboard
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(deliveryImages.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("DeliveryImages")){ %>
			                            <li>
			                                <a href="A_CP_CustomerDelivery.jsp?pageName=DeliveryImages" class="activeitem">
			                                    <i class="icon-fast-delivery"></i>Delivery Images
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_CustomerDelivery.jsp?pageName=DeliveryImages" >
			                                    <i class="icon-fast-delivery"></i>Delivery Images
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(openOrder.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("OpenOrders")){ %>
			                            <li>
			                                <a href="A_CP_OpenOrders.jsp?pageName=OpenOrders" class="activeitem">
			                                    <i class="icon-orders"></i>Open Orders
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_OpenOrders.jsp?pageName=OpenOrders"  >
			                                    <i class="icon-orders"></i>Open Orders
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(openInvoices.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("OpenInvoices")){ %>
			                            <li>
			                                <a href="A_CP_OpenInvoices.jsp?pageName=OpenInvoices" class="activeitem">
			                                    <i class="icon-invoice"></i>Open Invoices
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_OpenInvoices.jsp?pageName=OpenInvoices"  >
			                                    <i class="icon-invoice"></i>Open Invoices
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(pastInvoices.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("PastInvoices")){ %>
			                            <li>
			                                <a href="A_CP_PastInvoices.jsp?pageName=PastInvoices" class="activeitem">
			                                    <i class="icon-invoice"></i>Past Invoices
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_PastInvoices.jsp?pageName=PastInvoices"  >
			                                    <i class="icon-invoice"></i>Past Invoices
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(statements.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("Statements")){ %>
			                            <li>
			                                <a href="A_CP_Statements.jsp?pageName=Statements" class="activeitem">
			                                    <i class="icon-statement"></i>Statements
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_Statements.jsp?pageName=Statements"  >
			                                    <i class="icon-statement"></i>Statements
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
		                        			if(payment.trim().equalsIgnoreCase("Y")){
		                        				if(pageName.equalsIgnoreCase("InvoicePayment")){ %>
			                            <li>
			                                <a href="A_CP_InvoicePayment.jsp?pageName=InvoicePayment" class="activeitem">
			                                    <i class="icon-payments"></i>Payment
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_InvoicePayment.jsp?pageName=InvoicePayment"  >
			                                    <i class="icon-payments"></i>Payment
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}
			                            if(portalSo.trim().equalsIgnoreCase("Y")){
				                            if(pageName.equalsIgnoreCase("Shop")){ %>
			                            <li>
			                                <a href="A_CP_Shop.jsp?pageName=Shop"  class="activeitem">
			                                    <i class="icon-orders"></i>Shop
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}else{%><li>
			                                <a href="A_CP_Shop.jsp?pageName=Shop"  >
			                                    <i class="icon-orders"></i>Shop
			                                    <span class="bot-line"></span>
			                                </a>
			                            </li><%}}%>
								</ul>
							</div>
						</div>
					</nav>
					<div class="user">
                    	<a href="javascript:void(0)"><span class="username"></span><i class="bi bi-person fs-4"></i></a>
			            <div class="user-dropdown rounded-0">
        	        		<a href="A_CP_UserProfile.jsp?pageName=UserProfile"><i class="icon-user mr-2 text-danger"></i> Profile</a>
			                <%if(customerPortalAdmin.trim().equalsIgnoreCase("Y")){ %>
                				<!-- <a href="A_CP_ChangeCustomer.jsp?pageName=ChangeCustomer"><i class="icon-setting mr-2 text-danger"></i> Change Customer</a> -->
		              			<a href="javascript:showChangeCustomerModal()"><i class="icon-setting mr-2 text-danger"></i> Change Customer</a>
		              		<%}%>
                		    <a href="javascript:exit2()"><i class="icon-sign-out mr-2 text-danger"></i> Logout</a>
			         	</div>
        			</div>
					<div class="overlay"></div>
					</div> 
				</div>
			</div>
		</div>
	</header>

<div class="modal" id="ChangeCustomerModal" data-backdrop="static"  data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="ChangePasswordModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
                <h5 class="modal-title" id="ChangeCustomerModalTitle"><img src="NewPortalAssets/assets/images/icons/changecustomer.png" width="30px" alt=""> Change Customer</h5>
                <button type="button" onclick="hideChangeCustomerModal()" class="close small opacity-100 text-dark" data-dismiss="modal" aria-label="Close"><i class="icon-close-flat small"></i></button>
            </div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0">
                    	<p class="m-0 text-center text-success p-2" id="msg"></p>
                        <form name="ChangeCustomerForm" id="ChangeCustomerForm" method="post">
	                        <div class="row"> 
		                        <div class="col-lg-12 col-md-12">
		                        	<label for="CustomerId">Customer# <span class="text-danger small">*</span></label>
		                            <div class="form-group position-relative">
			                            <input type="text" name="customerId" id="customerId" placeholder="Enter Customer#" class="form-control">
		                            	<div class="invalid-feedback">Please Enter Customer#</div>
		                            </div>
		                        </div>
	                        </div>
	                        <div class="text-right">                          
	                        	<button type="button" class="btn btn-danger mt-4" onclick="changeCustomerId()" id="changeCustomerBtn">Submit</button>
	                        </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%!

	public HashMap<String, String> getCustomerData(String userId) {
		HashMap<String, String> temp = new HashMap<String, String>();
		try {
			DistUtils du = new DistUtils();
			String sqlQuery = "SELECT CUSTOMERPORTALADMIN,PORTAL_SO,DASHBOARD,OPEN_ORDER,DELIVERY_IMAGES,OPEN_INVOICES,PAST_INVOICES, "
								+" STATEMENTS,PAYMENTS FROM ETECHUSER WHERE USERID='"+userId+"' ";
			Utils.log("ETECHUSER Query >>>> "+sqlQuery);
			Hashtable ht=du.getDataFromQuery(sqlQuery);	
			Vector customerPortalAdminVector = new Vector();
			Vector portalSoVector = new Vector();
			Vector dashboardVector = new Vector();
			Vector openOrderVector = new Vector();
			Vector deliveryImagesVector = new Vector();
			Vector openInvoicesVector = new Vector();
			Vector pastInvoicesVector = new Vector();
			Vector statementsVector = new Vector();
			Vector paymentVector = new Vector();
			if (ht != null && ht.size() > 0) {
				customerPortalAdminVector = (Vector) ht.get("CUSTOMERPORTALADMIN");
				portalSoVector = (Vector) ht.get("PORTAL_SO");
				dashboardVector = (Vector) ht.get("DASHBOARD");
				openOrderVector = (Vector) ht.get("OPEN_ORDER");
				deliveryImagesVector = (Vector) ht.get("DELIVERY_IMAGES");
				openInvoicesVector = (Vector) ht.get("OPEN_INVOICES");
				pastInvoicesVector = (Vector) ht.get("PAST_INVOICES");
				statementsVector = (Vector) ht.get("STATEMENTS");
				paymentVector = (Vector) ht.get("PAYMENTS");
			}
	        if (customerPortalAdminVector.size() > 0) {
	            temp.put("customerPortalAdmin", Utils.removeNull(customerPortalAdminVector.get(0).toString()).trim());
	            temp.put("portalSo", Utils.removeNull(portalSoVector.get(0).toString()).trim());
	            temp.put("dashboard", Utils.removeNull(dashboardVector.get(0).toString()).trim());
	            temp.put("openOrder", Utils.removeNull(openOrderVector.get(0).toString()).trim());
	            temp.put("deliveryImages", Utils.removeNull(deliveryImagesVector.get(0).toString()).trim());
	            temp.put("openInvoices", Utils.removeNull(openInvoicesVector.get(0).toString()).trim());
	            temp.put("pastInvoices", Utils.removeNull(pastInvoicesVector.get(0).toString()).trim());
	            temp.put("statements", Utils.removeNull(statementsVector.get(0).toString()).trim());
	            temp.put("payment", Utils.removeNull(paymentVector.get(0).toString()).trim());
	        }
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		
		return temp;
	}


%>
