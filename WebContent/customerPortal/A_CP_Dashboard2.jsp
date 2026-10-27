<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.ad.servlet.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="net.sf.json.JSONObject" %>
<%@page import="net.sf.json.JSONArray" %>

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

	String firstTimeLogin = (String)session.getAttribute("firstTimeLogin");
	Utils.log("FIRSTTIMELOGIN >>>> " + firstTimeLogin);
	if(firstTimeLogin == null || firstTimeLogin.trim().equals("") || Integer.parseInt(firstTimeLogin.trim()) != 1 ){%>
		<jsp:forward page="../customerPortal/A_CP_ChangePassword.jsp"></jsp:forward>
	<%}

	/* String userName = Utils.removeNull(du.getFieldInfo("select firstname||' '||middleName||' '||lastname as userName from etechuser where DEPTID='"+(String)session.getAttribute("customerId").toString().trim()+"'"));
	String userNameHeader ="";
	if(userName.length()>30)
		userNameHeader = userName.substring(0, 28);
	else
		userNameHeader = userName;
	
	String customerPortalAdmin = Utils.removeNull(du.getFieldInfo(" select CUSTOMERPORTALADMIN from ETECHUSER where USERID='"+userId+"' ")); */
	
	/* String pageName=request.getParameter("pageName");
	if(pageName == null || pageName == "")
		pageName="Dashboard";*/ 

	String customerId = (String)session.getAttribute("customerId");
	Utils.log("customerId >>>> " + customerId);
	String custKey = (String)session.getAttribute("custKey");
	Utils.log("cust key >>>> " + custKey);
			
	final DecimalFormat df = new DecimalFormat("#,###,###,##0.00");
	
	//ACPDashboard dashboardObj=new ACPDashboard();
	String openInvoiceTileData="",openAmountTileData="";
	HashMap<String, String> invoiceMap = getInvoiceData(custKey);
	if(invoiceMap.size()>0){
		openInvoiceTileData=invoiceMap.get("totalInvoices").toString();
		openAmountTileData=invoiceMap.get("totalOpenAmount").toString();
	}
	
	String noOfOpenOrdersTileData="",totalOrderAmountTileData="";
	HashMap<String, String> ordersMap = getOrdersData(custKey);
	if(ordersMap.size()>0){
		noOfOpenOrdersTileData=ordersMap.get("totalOrders").toString();
		totalOrderAmountTileData=ordersMap.get("totalOrdersAmount").toString();
	}
	
	
	String ytdOrders="",ytdAmount="";
	HashMap<String, String> ytdMap = getYTDSalesData(customerId.trim());
	if(ytdMap.size()>0){
		ytdOrders=ytdMap.get("totalInvoices").toString();
		ytdAmount=ytdMap.get("totalSales").toString();
	}
	
	//String ytdSalesOrder=getYTDSalesOrder(customerId.trim());
	//String ytdSalesAmount=getYTDSalesAmount(customerId.trim());

	int totalInvoicesMonthlyCount=0;
	double totalInvoicesMonthlyAmount=0;

	HashMap<String, String> currentInvoicesMapData = getCurrentInvoices(custKey);
	String currentInvoicesCount="0",currentInvoicesAmount="0";
	if(currentInvoicesMapData.size()>0){
		currentInvoicesCount=currentInvoicesMapData.get("invoices").toString();
		currentInvoicesAmount=currentInvoicesMapData.get("invoiceAmount").toString();
		
		if(currentInvoicesAmount.trim().isEmpty()){
			currentInvoicesCount="0";
			currentInvoicesAmount="0";
		}
		
		totalInvoicesMonthlyCount=totalInvoicesMonthlyCount+Integer.parseInt(currentInvoicesCount);
		totalInvoicesMonthlyAmount=totalInvoicesMonthlyAmount+Double.parseDouble(currentInvoicesAmount);
		
		currentInvoicesAmount="$ "+df.format(Double.parseDouble(currentInvoicesAmount));
	}
	
	HashMap<String, String> oneToThirtyDaysInvoicesMapData = getOneToThirtyDaysInvoices(custKey);
	String oneToThirtyDaysInvoicesCount="0",oneToThirtyDaysInvoicesAmount="0";
	if(oneToThirtyDaysInvoicesMapData.size()>0){
		oneToThirtyDaysInvoicesCount=oneToThirtyDaysInvoicesMapData.get("invoices").toString();
		oneToThirtyDaysInvoicesAmount=oneToThirtyDaysInvoicesMapData.get("invoiceAmount").toString();

		if(oneToThirtyDaysInvoicesAmount.trim().isEmpty()){
			oneToThirtyDaysInvoicesCount="0";
			oneToThirtyDaysInvoicesAmount="0";
		}

		totalInvoicesMonthlyCount=totalInvoicesMonthlyCount+Integer.parseInt(oneToThirtyDaysInvoicesCount);
		totalInvoicesMonthlyAmount=totalInvoicesMonthlyAmount+Double.parseDouble(oneToThirtyDaysInvoicesAmount);

		oneToThirtyDaysInvoicesAmount="$ "+df.format(Double.parseDouble(oneToThirtyDaysInvoicesAmount));
	}
	
	HashMap<String, String> thirtyOneToSixtyDaysInvoicesMapData = getThirtyOneToSixtyDaysInvoices(custKey);
	String thirtyOneToSixtyDaysInvoicesCount="0",thirtyOneToSixtyDaysInvoicesAmount="0";
	if(thirtyOneToSixtyDaysInvoicesMapData.size()>0){
		thirtyOneToSixtyDaysInvoicesCount=thirtyOneToSixtyDaysInvoicesMapData.get("invoices").toString();
		thirtyOneToSixtyDaysInvoicesAmount=thirtyOneToSixtyDaysInvoicesMapData.get("invoiceAmount").toString();

		if(thirtyOneToSixtyDaysInvoicesAmount.trim().isEmpty()){
			thirtyOneToSixtyDaysInvoicesCount="0";
			thirtyOneToSixtyDaysInvoicesAmount="0";
		}

		totalInvoicesMonthlyCount=totalInvoicesMonthlyCount+Integer.parseInt(thirtyOneToSixtyDaysInvoicesCount);
		totalInvoicesMonthlyAmount=totalInvoicesMonthlyAmount+Double.parseDouble(thirtyOneToSixtyDaysInvoicesAmount);

		thirtyOneToSixtyDaysInvoicesAmount="$ "+df.format(Double.parseDouble(thirtyOneToSixtyDaysInvoicesAmount));
	}
	
	HashMap<String, String> sixtyOneToNinetyDaysInvoicesMapData = getSixtyOneToNinetyDaysInvoices(custKey);
	String sixtyOneToNinetyDaysInvoicesCount="0",sixtyOneToNinetyDaysInvoicesAmount="0";
	if(sixtyOneToNinetyDaysInvoicesMapData.size()>0){
		sixtyOneToNinetyDaysInvoicesCount=sixtyOneToNinetyDaysInvoicesMapData.get("invoices").toString();
		sixtyOneToNinetyDaysInvoicesAmount=sixtyOneToNinetyDaysInvoicesMapData.get("invoiceAmount").toString();

		if(sixtyOneToNinetyDaysInvoicesAmount.trim().isEmpty()){
			sixtyOneToNinetyDaysInvoicesCount="0";
			sixtyOneToNinetyDaysInvoicesAmount="0";
		}
		totalInvoicesMonthlyCount=totalInvoicesMonthlyCount+Integer.parseInt(sixtyOneToNinetyDaysInvoicesCount);
		totalInvoicesMonthlyAmount=totalInvoicesMonthlyAmount+Double.parseDouble(sixtyOneToNinetyDaysInvoicesAmount);

		sixtyOneToNinetyDaysInvoicesAmount="$ "+df.format(Double.parseDouble(sixtyOneToNinetyDaysInvoicesAmount));
	}
	
	HashMap<String, String> overNinetyDaysInvoicesMapData = getOverNinetyDaysInvoices(custKey);
	String overNinetyDaysInvoicesCount="0",overNinetyDaysInvoicesAmount="0";
	if(overNinetyDaysInvoicesMapData.size()>0){
		overNinetyDaysInvoicesCount=overNinetyDaysInvoicesMapData.get("invoices").toString();
		overNinetyDaysInvoicesAmount=overNinetyDaysInvoicesMapData.get("invoiceAmount").toString();

		if(overNinetyDaysInvoicesAmount.trim().isEmpty()){
			overNinetyDaysInvoicesCount="0";
			overNinetyDaysInvoicesAmount="0";
		}

		totalInvoicesMonthlyCount=totalInvoicesMonthlyCount+Integer.parseInt(overNinetyDaysInvoicesCount);
		totalInvoicesMonthlyAmount=totalInvoicesMonthlyAmount+Double.parseDouble(overNinetyDaysInvoicesAmount);

		overNinetyDaysInvoicesAmount="$ "+df.format(Double.parseDouble(overNinetyDaysInvoicesAmount));
	}
	
	String year="";
	StringBuffer yearBuffer=new StringBuffer();
	ArrayList<HashMap<String, String>> yearList = getYearList();
	for (int i=0; i< yearList.size();i++){
		HashMap mapData = (HashMap)yearList.get(i);
		yearBuffer.append("<option value='"+mapData.get("createdDate")+"'>"+mapData.get("createdDate")+"</option>");
	}
	year=yearBuffer.toString();
	
	List<HashMap<String, String>> listData = getInvoicesMonthWise(custKey);
	String[] invoiceArray=new String[listData.size()];
	String[] invoiceMonthArray=new String[listData.size()];
	String[] invoiceAmtArray=new String[listData.size()];
	for (int i=0; i< listData.size();i++){
		HashMap mapData = (HashMap)listData.get(i);
		invoiceArray[i]=mapData.get("invoices").toString();
		invoiceMonthArray[i]=mapData.get("invoiceMonth").toString();
		invoiceAmtArray[i]=mapData.get("invoiceAmount").toString();
	}
	
%>

<!-- HEADER-->
<%@ include file="A_CP_Header.jsp" %>
<!-- END HEADER-->

<style type="text/css">
    html,
    body {
        height: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
        background: #f9f9fc;
    }
</style>


<div class="page-wrapper">
    <div class="page-content--bgf7">
        <section class="py-4">
            <div class="container">
                <div class="row mb-0">
                    <div class="col-xl-6 col-lg-6 col-md-6 mb-3">
                        <h6 class="text-uppercase"><img src="NewPortalAssets/assets/images/icons/dashboard.png" width="40px" class="mr-2" alt=""> Dashboard</h6>
                    </div>
                    <div class="col-xl-6 col-lg-6 col-md-6 order-xl-1 mb-3 mb-md-0   d-flex justify-content-end align-items-start ">
                        <h6 class="m-0 py-2 px-3 rounded-pill text-danger font-weight-600 bg-danger-subtle text-center"><%=userNameHeader%></h6>
                    </div>
                    
                    <%-- <div class="col-xl-3 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-invoice display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <p class="mb-1">Open Invoices</p>
                                    <div class="d-flex flex-wrap justify-content-between">
                                        <h3 class="mb-0"><%=openInvoiceTileData%></h3>
                                        <h3 class="mb-0 text-danger">$<%=df.format(Double.parseDouble(openAmountTileData))%></h3>
                                    </div>
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
                                    <p class="mb-1">Open Orders</p>
                                    <div class="d-flex flex-wrap justify-content-between">
                                        <h3 class="mb-0"><%=noOfOpenOrdersTileData%></h3>
                                        <h3 class="mb-0 text-danger">$<%=df.format(Double.parseDouble(totalOrderAmountTileData))%></h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div> --%>                    
                
                </div>
                <div class="row mb-4 justify-content-center">
                	<div class="col-xl-4 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-invoice display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <p class="mb-1">Open Invoices</p>
                                    <div class="d-flex flex-wrap justify-content-between">
                                        <h3 class="mb-0"><%=openInvoiceTileData%></h3>
                                        <h3 class="mb-0 text-danger">$<%=df.format(Double.parseDouble(openAmountTileData))%></h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-orders display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <p class="mb-1">Open Orders</p>
                                    <div class="d-flex flex-wrap justify-content-between">
                                        <h3 class="mb-0"><%=noOfOpenOrdersTileData%></h3>
                                        <h3 class="mb-0 text-danger">$<%=df.format(Double.parseDouble(totalOrderAmountTileData))%></h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>                    
                    <div class="col-xl-4 col-lg-6 col-md-6 mb-3 mb-3 mb-lg-0">
                        <div class="card rounded-0 bg-danger-subtle border-0">
                            <div class="card-body p-1 d-sm-flex align-content-center justify-content-center justify-content-md-start align-items-center text-center text-sm-left">
                                <div class="icon text-danger px-md-3 py-3 py-sm-0">
                                    <i class="icon-ytd-calender display-4"></i>
                                </div>
                                <div class="bg-white p-2 w-100">
                                    <!-- <div class="d-flex flex-wrap justify-content-between mb-2">
                                        <p class="mb-0">YTD Sales</p>
                                        <p class="mb-0 text-danger"></p>
                                    </div>
                                    <div class="d-flex flex-wrap justify-content-between mt-1">
                                        <p class="mb-0">YTD Orders</p>
                                        <p class="mb-0 text-danger"></p>
                                    </div> --> 
						            <p class="mb-1">YTD Sales</p>
                                    <div class="d-flex flex-wrap justify-content-between">
                                        <h3 class="mb-0"><%=ytdOrders%></h3>
                                        <h3 class="mb-0 text-danger">$<%=df.format(Double.parseDouble(ytdAmount))%></h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>                    
                
                </div>
                
                <div class="row">
                    <div class="col-md-12">
                        <div class="card rounded-0 bg-white border-0 p-0">
                            <div class="row">
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">Current</p>
                                        <p class="mb-2"><%=currentInvoicesAmount%></p>
                                        <p class="mb-1 fw-600 text-danger"><%=currentInvoicesCount%></p>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">1-30 Days</p>
                                        <p class="mb-2"><%=oneToThirtyDaysInvoicesAmount%></p>
                                        <p class="mb-1 fw-600 text-danger"><%=oneToThirtyDaysInvoicesCount%></p>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">31-60 Days</p>
                                        <p class="mb-2"><%=thirtyOneToSixtyDaysInvoicesAmount%></p>
                                        <p class="mb-1 fw-600 text-danger"><%=thirtyOneToSixtyDaysInvoicesCount%></p>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">61-90 Days</p>
                                        <p class="mb-2"><%=sixtyOneToNinetyDaysInvoicesAmount%></p>
                                        <p class="mb-1 fw-600 text-danger"><%=sixtyOneToNinetyDaysInvoicesCount%></p>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">Over 90 Days</p>
                                        <p class="mb-2"><%=overNinetyDaysInvoicesAmount%></p>
                                        <p class="mb-1 fw-600 text-danger"><%=overNinetyDaysInvoicesCount%></p>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                                    <div class="total-balance p-3 text-center mb-3 mb-sm-0">
                                        <p class="mb-2 fw-600">Total Balance Due</p>
                                        <p class="mb-2">$<%=df.format(totalInvoicesMonthlyAmount) %></p>
                                        <p class="mb-1 fw-600 text-danger"><%=totalInvoicesMonthlyCount %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- <div class="col-md-12 mt-4">
                        <div class="card p-3 border-0 rounded-0">
                            <h3 class="mb-4">Total Invoices Monthly</h3>
                            <div id="chartContainer" style="height: 370px; width: 100%;"></div>
                        </div>
                    </div> -->
                    <div class="col-md-12 mt-4">
                        <div class="card p-3 border-0 rounded-0">
                            <h3 class="mb-4">Total Invoices Monthly</h3>
                            <canvas id="revenueChart" height="400"></canvas>
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
		  
		 
<script>

	var invoiceArr = [];
	<%for(int i=0; i<invoiceArray.length; i++){%>
		invoiceArr.push(<%=invoiceArray[i]%>);
	<%}%>
	
	<%
	    StringBuilder sb = new StringBuilder();
	    for(int i=0;i<invoiceMonthArray.length;i++) 
	        sb.append(invoiceMonthArray[i]+",");
	%>
	
	var temp="<%=sb.toString()%>";
	var arr = new Array();
	arr = temp.split(',','<%=invoiceMonthArray.length%>');
	
	var invoiceAmtArr = [];
	<%for(int i=0; i<invoiceAmtArray.length; i++){%>
		invoiceAmtArr.push(<%=invoiceAmtArray[i]%>);
	<%}%>
	
	var xArray = arr;
	var yArray = invoiceAmtArr;
	
	var dataPointsFinal = [];
	
	for (var i = 0; i < arr.length; i++) {
		dataPointsFinal.push({
			y: invoiceAmtArr[i],
			label: arr[i]
		  });
	}


    const ctx = document.getElementById('revenueChart').getContext('2d');

    const revenueChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: xArray,
            datasets: [{
                label: 'Total Revenue',
                data: yArray,
                borderColor: '#b2222b',
                backgroundColor: 'rgba(178, 34, 43, 0.2)',
                fill: true,
                tension: 0.4,
                borderWidth: 2,
                pointBackgroundColor: '#b2222b',
                pointBorderColor: '#fff',
                pointRadius: 5
            }]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let value = context.parsed.y;
                            return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
                        }
                    }
                },
                legend: {
                    labels: {
                        font: {
                            size: 14
                        }
                    }
                }
            },
            scales: {
                y: {
                    ticks: {
                        callback: function(value) {
                            return Number(value).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
                        }
                    },
                    beginAtZero: true
                }
            }
        }
    });

	function exit2(){
		parent.location='../customerPortal/A_CP_Logout.jsp';
	}


</script>
		 
<%! 

	public HashMap<String, String> getInvoiceData(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as TOTAL_INVOICES, nvl(sum(ar.OPEN_AMT),0) as TOTAL_OPEN_AMOUNT "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 " 
							+" and ar.cust_key='"+custKey+"' ";
			Utils.log("InvoiceData Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector totalInvoicesVector = new Vector();
			Vector totalOpenAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				totalInvoicesVector = (Vector) ht.get("TOTAL_INVOICES");
				totalOpenAmountVector = (Vector) ht.get("TOTAL_OPEN_AMOUNT");
			}
	        if (totalInvoicesVector.size() > 0) {
	        	for (int i = 0; i < totalInvoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("totalInvoices", totalInvoicesVector.get(i).toString());
					temp.put("totalOpenAmount", totalOpenAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	public HashMap<String, String> getOrdersData(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as TOTAL_ORDERS, nvl(sum(sh.TOTAL_SELL),0) as TOTAL_ORDER_AMOUNT "
								+" from (select distinct sh.SYSTEM_ID,sh.SO_ID,sh.ORDER_DATE, "
								+" sa.CUST_NAME, sa.ADDRESS_1 || sa.ADDRESS_2 ||' '|| sa.CITY ||' '|| sa.STATE ||' '|| sa.ZIP as SHIP_TO, sh.CUST_PO, "
								+" sh.SALE_TYPE,sh.ORDER_TOTAL,sh.TOTAL_SELL " 
								+" from SO_HEADER sh, SHIP_TO_ADDRESS sa " 
								+" where sh.SO_ID=sa.TRAN_ID(+) "
								+" and sh.cust_key='"+custKey+"' "
								+" and sh.so_status NOT IN('I','C')) sh";

			Utils.log("OrdersData Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector totalOrdersVector = new Vector();
			Vector totalOrdersAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				totalOrdersVector = (Vector) ht.get("TOTAL_ORDERS");
				totalOrdersAmountVector = (Vector) ht.get("TOTAL_ORDER_AMOUNT");
			}
	        if (totalOrdersVector.size() > 0) {
	        	for (int i = 0; i < totalOrdersVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("totalOrders", totalOrdersVector.get(i).toString());
					temp.put("totalOrdersAmount", totalOrdersAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	
	public HashMap<String, String> getYTDSalesData(String customerId) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = "select count(*) as TOTAL_INVOICES, nvl(sum(ar.AMOUNT),0) as TOTAL_SALES "
							+" from aropendt ar, aropen ao, cust cu "  
							+" where ar.ref_type in ('IN','CM','DM') "  
							+" and ar.cust_key=cu.cust_key "  
							+" and ar.REF_NUM=ao.REF_NUM " 
							+" and ar.cust_key=ao.cust_key " 
							+" and cu.cust_code='"+customerId+"' "
							+" and ao.REF_DATE>=TRUNC(SYSDATE, 'YEAR') and ao.REF_DATE<=ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), 12) - 1";

			Utils.log("YTDSalesData Query >>>> "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector totalInvoicesVector = new Vector();
			Vector totalSalesVector = new Vector();
			if (ht != null && ht.size() != 0) {
				totalInvoicesVector = (Vector) ht.get("TOTAL_INVOICES");
				totalSalesVector = (Vector) ht.get("TOTAL_SALES");
			}
	        if (totalInvoicesVector.size() > 0) {
	        	for (int i = 0; i < totalInvoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("totalInvoices", totalInvoicesVector.get(i).toString());
					temp.put("totalSales", totalSalesVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}

	
	public HashMap<String, String> getCurrentInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 "
							+" and ar.cust_key='"+custKey+"' "
							+" and ar.DUE_DATE-CURRENT_DATE>=0 ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	public HashMap<String, String> getOneToThirtyDaysInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 "
							+" and ar.cust_key='"+custKey+"' "
							+" and ar.DUE_DATE-CURRENT_DATE<=-1 and ar.DUE_DATE-CURRENT_DATE>=-30 ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	public HashMap<String, String> getThirtyOneToSixtyDaysInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 "
							+" and ar.cust_key='"+custKey+"' "
							+" and ar.DUE_DATE-CURRENT_DATE<=-31 and ar.DUE_DATE-CURRENT_DATE>=-60 ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	
	public HashMap<String, String> getSixtyOneToNinetyDaysInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 "
							+" and ar.cust_key='"+custKey+"' "
							+" and ar.DUE_DATE-CURRENT_DATE<=-61 and ar.DUE_DATE-CURRENT_DATE>=-90 ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	public HashMap<String, String> getOverNinetyDaysInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar, aropen ao, cust cu " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI','CA') " 
							+" and ar.cust_key=cu.cust_key " 
							+" and ar.REF_NUM=ao.REF_NUM "
							+" and ar.cust_key=ao.cust_key "
							+" and ar.open_amt!=0 "
							+" and ar.cust_key='"+custKey+"' "
							+" and ar.DUE_DATE-CURRENT_DATE<=-91 ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return temp;
	}
	
	
	public ArrayList<HashMap<String, String>> getYearList() {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select DISTINCT(extract(YEAR from CREATED_DATE)) as CREATED_DATE  from aropendt ORDER BY CREATED_DATE ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector createdDateVector = new Vector();
			if (ht != null && ht.size() != 0) {
				createdDateVector = (Vector) ht.get("CREATED_DATE");
			}
	        if (createdDateVector.size() > 0) {
	        	for (int i = 0; i < createdDateVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("createdDate", createdDateVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}
	
	
	
	public ArrayList<HashMap<String, String>> getInvoicesMonthWise(String custKey) {	
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,UPPER(to_char(ar.created_date, 'mon-YYYY')) as invoice_month,round(sum(ar.AMOUNT),0) as invoice_amount " 
								+" from aropendt ar "
								+" where ar.ref_type in ('IN','CM','DM','FC','CI') "  
								+" and ar.ref_num not like ('AD-%') "  
								+" and ar.created_date between TRUNC(ADD_MONTHS(sysdate, -12), 'MONTH') and TRUNC(sysdate, 'MONTH') -1 " 
								+" and ar.cust_key='"+custKey+"' " 
								+" group by to_char(ar.created_date, 'mon-YYYY') " 
								+" order by min(ar.created_date) ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQueryPro2(query);	
			Vector invoicesVector = new Vector();
			Vector invoiceMonthVector = new Vector();
			Vector invoiceAmountVector = new Vector();
			if (ht != null && ht.size() != 0) {
				invoicesVector = (Vector) ht.get("INVOICES");
				invoiceMonthVector = (Vector) ht.get("INVOICE_MONTH");
				invoiceAmountVector = (Vector) ht.get("INVOICE_AMOUNT");
			}
	        if (invoicesVector.size() > 0) {
	        	for (int i = 0; i < invoicesVector.size(); i++) {  
	        		temp=new HashMap<String, String>();
					temp.put("invoices", invoicesVector.get(i).toString());
					temp.put("invoiceMonth", invoiceMonthVector.get(i).toString());
					temp.put("invoiceAmount", invoiceAmountVector.get(i).toString());
					listData.add(temp);
	        	}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}


	public String getYTDSalesOrder(String customerId){	
		String sqlQuery="",ytdSalesOrder="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select nvl(count(*),0) as TOTAL_ORDER from SALES_FACT sf, CUSTOMER_DIM cu where cu.CUSTomer_key=sf.CUSTOMER_KEY and summary_flag ='S' " 
						+" and ACTIVITY_DATE >=TRUNC(SYSDATE, 'YEAR') and ACTIVITY_DATE <=ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), 12) - 1 and cu.CUSTOMER='"+customerId+"' and item_key not in "
					   	+" (30860,28354) and sf.sales_type_key < 129 "; 
 
			Utils.log("YTDSalesOrder Query >>>>>> "+sqlQuery);
			ytdSalesOrder=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return ytdSalesOrder;
	}

	
	public String getYTDSalesAmount(String customerId){	
		String sqlQuery="",ytdSalesAmount="";
		try {
			DistUtils du = new DistUtils();
			sqlQuery = "select nvl(sum(value_at_sell),0) as TOTAL_SALE from SALES_FACT sf, CUSTOMER_DIM cu where cu.CUSTomer_key=sf.CUSTOMER_KEY and summary_flag ='S' " 
							+" and ACTIVITY_DATE >=TRUNC(SYSDATE, 'YEAR') and ACTIVITY_DATE <=ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), 12) - 1 and cu.CUSTOMER='"+customerId+"' and item_key not in "
					   		+" (30860,28354) and sf.sales_type_key < 129 "; 
 
			Utils.log("YTDSalesAmount Query >>>> "+sqlQuery);
			ytdSalesAmount=Utils.removeNull(du.getFieldInfoPro2(sqlQuery));
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return ytdSalesAmount;
	}

	
%>