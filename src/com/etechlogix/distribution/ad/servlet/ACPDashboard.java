package com.etechlogix.distribution.ad.servlet;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Vector;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

public class ACPDashboard {
	
	public HashMap<String, String> getInvoiceData(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as TOTAL_INVOICES, nvl(sum(ar.OPEN_AMT),0) as TOTAL_OPEN_AMOUNT "
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
							+" and ar.open_amt!=0 " 
							+" and ar.cust_key='"+custKey+"' ";
			Utils.log("Query :: "+query);
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
							+" from SO_HEADER sh, SHIP_TO_ADDRESS sa " 
							+" where sh.SO_ID=sa.TRAN_ID(+) " 
							+" and sh.so_status NOT IN('I','C') " 
							+" and sh.cust_key='"+custKey+"' ";
			Utils.log("Query :: "+query);
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

	public HashMap<String, String> getCurrentInvoices(String custKey) {	
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			String query = " select count(*) as invoices,nvl(sum(ar.OPEN_AMT),0) as invoice_amount "
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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
							+" from aropendt ar " 
							+" where ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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
							+" from aropendt ar, SO_HEADER sh, SHIP_TO_ADDRESS sa " 
							+" where ar.TRAN_ID=sh.so_id(+) "
							+" and ar.TRAN_ID=sa.TRAN_ID(+) "
							+" and ar.ref_type in ('IN','CM','DM','FC','CI') " 
							+" and ar.ref_num not like ( 'AD-%') " 
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

}
