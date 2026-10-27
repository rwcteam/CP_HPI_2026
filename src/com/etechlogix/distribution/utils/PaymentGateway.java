package com.etechlogix.distribution.utils;


import java.io.*;
import java.net.*;
import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;

import com.etechlogix.utils.Utils;

public class PaymentGateway {
	String branchWarehouse="";
	public  PaymentGateway(){
		
	}
	public  PaymentGateway(String whse){
		branchWarehouse=whse;
	}
	 String returnResult = "";
	public String processPaymentBykey(String companyId, String ccNo, String expMon, String expYr, double amount, String zip, String docNo, String orderExt, String email, String phone, String desc, String userId, String transType ) throws Exception{
		String parmList = "|method~processtranx|tranxtype~"+transType+"|terms~Y|CC~"+ccNo+"|expmnth~"+expMon+"|expyr~"+expYr+"|amount~"+amount+"|bzip~"+zip+"|Document Number~"+docNo+":"+orderExt+"|email~"+Utils.removeNull(email).trim()+"|phone~"+Utils.removeNull(phone).trim()+"|description~"+desc+"|User Initials~"+userId+"|";
		try{
			Utils.log("Whse"+branchWarehouse);
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;

	}
	public String processPaymentBySwipe(String companyId,String swipe, double amount,  String docNo, String orderExt, String zip, String email, String phone, String desc, String userId, String transType ) throws Exception{
		String parmList = "|method~processtranx|tranxtype~"+transType+"|terms~Y|swipe~"+swipe+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|bzip~"+zip+"|email~"+Utils.removeNull(email).trim()+"|phone~"+Utils.removeNull(phone).trim()+"|description~"+desc+"|User Initials~"+userId+"|";
		try{
			Utils.log("Whse"+branchWarehouse);
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;

	}
	public String processPaymentByCustomer(String companyId,String customerId, double amount,  String docNo, String orderExt, String userId, String transType ) throws Exception{
		String parmList = "|method~processtranx|tranxtype~"+transType+"|terms~Y|custid~"+customerId+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|";
		try{
			Utils.log("Whse"+branchWarehouse);
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;

	}
	
	public String processRefundByTransId(String companyId, double amount,  String docNo, String orderExt, String userId ) throws Exception{
		String parmList = "|method~processtranx|tranxtype~Refund|terms~Y|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|";
		try{
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		parmList=parmList+getRefundTransId(docNo, orderExt, companyId);
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;
	}
	public JSONObject getPayTraceCustomerList(String companyId,   String docNo, String orderExt, String userId) throws Exception {
	 	
		JSONObject json = new JSONObject();
		String parmList = "|method~ExportCustomers|terms~Y|";
		String strError="";
		String []subResponseArry;
		try {
			parmList=getUserPass(docNo, orderExt, companyId)+parmList;
			returnResult= payTraceProcess(parmList);
			
	    	 if(!returnResult.equals("") && returnResult.indexOf("|")>0 && returnResult.indexOf("~")>0)
	    	 {
	    	 String [] responseArry=returnResult.split("\\|",-1);
	    	 for(int i=0;i<responseArry.length;i++){
	    		 JSONArray itemjson = new JSONArray();
	    		 Utils.log("i"+i+responseArry[i]);
	    		  String []arrPair = responseArry[i].split("~",-1); 
	    		  if(arrPair[0].equals("ERROR"))
	    		   strError = strError + arrPair[1];
	    		  else if(arrPair[0].equals("CUSTOMERRECORD")){ 
	    			  subResponseArry = arrPair[1].split("\\+",-1);
	    			  Utils.log(arrPair[1]);
	    		  for(int j=0;j<subResponseArry.length;j++){
	    			  String []arrPairSub = subResponseArry[j].split("\\=",-1); 
	    			  Utils.log(subResponseArry[j]);
	    			  if(arrPairSub[0].equals("CUSTID"))
	    				  itemjson.put(arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("SNAME"))
	    				  itemjson.put(arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("BNAME"))
	    				  itemjson.put(arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("CC"))
	    				  itemjson.put(arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("EXPMNTH"))
	    				  itemjson.put(arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("EXPYR"))
	    				  itemjson.put(arrPairSub[1]);
	    			  
	    		  }
	    		  json.append("aaData", itemjson);
	    		  }
	    		  }
	    		  
	    	 }
	    	 else
	    		 throw new Exception(strError  + "The response from the PayTrace was invalid.");
	    	 if(!strError.equals(""))
	    		 throw new Exception(strError);
			
			
		} catch (Exception e) {
			Utils.logError("Error", e);
			throw new Exception("Error:"+ e.getMessage());
		} 

		return json;
	}
	public String processVoidByTransId(String companyId,String transId,   String docNo, String orderExt, String userId ) throws Exception{
		
		String parmList = "|method~processtranx|tranxtype~void|terms~Y|tranxid~"+transId+"|invoice~"+docNo+":"+orderExt+"|user~"+userId+"|";		
		try{
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		Utils.log(parmList);
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;
	}
	
	
	public String processRefundByTransId(String companyId, double amount,  String docNo, String orderExt, String userId,String transacionId,String emailId ) throws Exception{
		String method="";
		String parmList="";
		DistUtils du=new DistUtils();
		Vector returnOrderVec=new Vector();
		returnOrderVec=du.getFieldInfo("select  orderno, orderext from paymentinfo where transstatus='"+transacionId+"'",2);
		String origOrderNo=(String)returnOrderVec.get(0);
		String origOrderExt=(String)returnOrderVec.get(1);
		int checktodayOrder=Utils.parseInt(du.getFieldInfo("select count(*) from orderheader where orderno='"+origOrderNo+"' and orderext="+origOrderExt+" and to_char(shipdate,'MM-DD-YY')=to_char(sysdate,'MM-DD-YY')"));
		if(checktodayOrder>0){
		//parmList = "|method~adjustamount|terms~Y|tranxid~"+transacionId+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|email~"+emailId;
			returnResult="Pending";
		}else{
			parmList = "|method~processtranx|tranxtype~Refund|terms~Y|tranxid~"+transacionId+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|email~"+emailId;
			
			Utils.log(parmList);
			try{
			if(orderExt.equals("99999"))
			parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
			else
			parmList=getUserPass(docNo, orderExt, companyId)+parmList;
			//parmList=parmList+getRefundTransId(docNo, orderExt, companyId);
			returnResult= payTraceProcess(parmList);
			}
			catch(Exception e){
				Utils.log("error in payment",e);
				throw new Exception(e);
			}
		
		}
		return returnResult;
	}
	
	public String processPendingRefundByTransId(String companyId, double amount,  String docNo, String orderExt, String userId,String transacionId,String emailId ) throws Exception{
		String method="";
		String parmList="";
		DistUtils du=new DistUtils();
	/*	Vector returnOrderVec=new Vector();
		returnOrderVec=du.getFieldInfo("select  orderno, orderext from paymentinfo where transstatus='"+transacionId+"'",2);
		String origOrderNo=(String)returnOrderVec.get(0);
		String origOrderExt=(String)returnOrderVec.get(1);*/
		//int checktodayOrder=Utils.parseInt(du.getFieldInfo("select count(*) from orderheader where orderno='"+origOrderNo+"' and orderext="+origOrderExt+" and to_char(shipdate,'MM-DD-YY')=to_char(sysdate,'MM-DD-YY')"));
		//if(checktodayOrder>0)
		//parmList = "|method~adjustamount|terms~Y|tranxid~"+transacionId+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|email~"+emailId;
		//else
		parmList = "|method~processtranx|tranxtype~Refund|terms~Y|tranxid~"+transacionId+"|amount~"+amount+"|Document Number~"+docNo+":"+orderExt+"|User Initials~"+userId+"|email~"+emailId;
		Utils.log(parmList);
		try{
		if(orderExt.equals("99999"))
		parmList=getUserPass(branchWarehouse, orderExt, companyId)+parmList;
		else
		parmList=getUserPass(docNo, orderExt, companyId)+parmList;
		//parmList=parmList+getRefundTransId(docNo, orderExt, companyId);
		returnResult= payTraceProcess(parmList);
		}
		catch(Exception e){
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
		return returnResult;
	}
	
	private String getUserPass(String orderNo, String orderExt, String companyId){
		String initWhse="";
		String userPassParam="";
		try{
		DistUtils du=new DistUtils();
		if(orderExt.equals("99999"))
		initWhse=orderNo;
		else		
		initWhse=du.getFieldInfo("select initwhse from orderheader where orderNo='"+orderNo +"' and orderExt="+orderExt+" and companyId='"+companyId+"'");
		userPassParam=du.getFieldInfo("select 'un~'||paytraceuser||'|pswd~'||paytracepass from warehouse where companyid='"+companyId+"' and warehouse='"+initWhse+"'");
		}
		catch(Exception e){
			Utils.log("paytrace pass"+userPassParam,e);
		}
		Utils.log("paytrace pass"+userPassParam);
		return userPassParam;
	}
	private String getRefundTransId(String orderNo, String orderExt, String companyId){
		String transstatus="";
		String returnOrderNo="";
		String returnOrderExt="";
		try{
		DistUtils du=new DistUtils();
		Vector returnOrderVec=du.getFieldInfo("select distinct returnorderno, returnorderext from orderdetail where orderNo='"+orderNo +"' and orderExt="+orderExt+" and companyId='"+companyId+"' and confirmshipqty<0 and returnorderno is not null and returnorderno!='RWCRET'",2);
		returnOrderNo=(String)returnOrderVec.get(0);
		returnOrderExt=(String)returnOrderVec.get(1);
		transstatus=du.getFieldInfo("select 'tranxid~'||transstatus||'|' from paymentinfo where orderNo='"+returnOrderNo +"' and orderExt="+returnOrderExt+" and companyId='"+companyId+"' and creditcardamount>0");		
		}
		catch(Exception e){
			
		}
		return transstatus;
	}
	public String getRefundTransStatus(String orderNo, String orderExt, String companyId){
		String transstatus="";
		String returnOrderNo="";
		String returnOrderExt="";
		try{
		DistUtils du=new DistUtils();
		Vector returnOrderVec=du.getFieldInfo("select distinct returnorderno, returnorderext from orderdetail where orderNo='"+orderNo +"' and orderExt="+orderExt+" and companyId='"+companyId+"' and confirmshipqty<0 and returnorderno is not null and returnorderno!='RWCRET'",2);
		returnOrderNo=(String)returnOrderVec.get(0);
		returnOrderExt=(String)returnOrderVec.get(1);
		transstatus=du.getFieldInfo("select transstatus from paymentinfo where orderNo='"+returnOrderNo +"' and orderExt="+returnOrderExt+" and companyId='"+companyId+"' and creditcardamount>0");		
		}
		catch(Exception e){
			
		}
		return transstatus;
	}
	

	 private String payTraceProcess(String parmList) throws Exception{
		
		StringBuilder resultResp = new StringBuilder();
		HttpURLConnection conn = null;
		try {
		    // Construct data
			String jsonStr = URLEncoder.encode("parmList", "UTF-8") + "=" + URLEncoder.encode(parmList, "UTF-8");//new JSONObject().put("parmList",parmList).toString();  
			System.out.println("json>>>>>>>"+ jsonStr);
	    	URL url = new URL("http://reg2.rwc.org:8080/PaymentAuth/PaymentAuthotication");
			conn = (HttpURLConnection) url.openConnection();
			conn.setConnectTimeout(10000);
			conn.setDoOutput(true);
	        conn.setDoInput(true);
			conn.setRequestMethod("POST");
			//conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			//conn.setRequestProperty("Authorization", "Token token=028cb5506717161ef9e14c45a5cb13b1");

			OutputStreamWriter os = new OutputStreamWriter(conn.getOutputStream());
	        os.write(jsonStr);
	        os.close();
	        
	        InputStream in = new BufferedInputStream(conn.getInputStream());
	        BufferedReader reader = new BufferedReader(new InputStreamReader(in));
	        String line;
	        while((line = reader.readLine()) != null) {
	        	resultResp.append(line);
	        }
	     
	         in.close();
	         System.out.println(">>>result>>>>"+ resultResp.toString());
			returnResult= resultResp.toString();
		} catch (Exception e) {
			
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
			    return returnResult;

	}
	
	private String payTraceProcessTest(String parmList) throws Exception{
		String returnResult = "";
		//String ptUrl = "https://paytrace.com/api/default.pay";
		//String ptUrl = "https://legacy.paytrace.com/api/default.pay";
		String ptUrl = "https://beta.paytrace.com/api/default.pay";
		String parmName = "PARMLIST";
		
		try {
		    // Construct data
		    String data = URLEncoder.encode(parmName, "UTF-8") + "=" + URLEncoder.encode(parmList, "UTF-8");
		    // Send data
		    URL url = new URL(ptUrl);
		    HttpURLConnection conn = (HttpURLConnection)url.openConnection();
		    Utils.log("url connected"+conn);
		    conn.setDoOutput(true);  
		    conn.setDoInput(true);  
		    conn.setRequestMethod("POST");  
		    conn.setAllowUserInteraction(false);  
		    OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
		    Utils.log("get output stream from con");
		    wr.write(data);
		    Utils.log("Data sent");
		    wr.flush();
		    Utils.log("Data cleared");
		    Utils.log("Data"+data);
		    // Get the response
		    BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
		    Utils.log("response buffer "+rd);
		    String line;
		    while ((line = rd.readLine()) != null) {
		    	Utils.log("response line "+line);
		        returnResult+=line;
		    }
		    wr.close();
		    rd.close();
		} catch (Exception e) {
			
			Utils.log("error in payment",e);
			throw new Exception(e);
		}
			    return returnResult;

	}
	
	public JSONArray getPayTraceBatches(String companyId,   String startDate, String endDate, String userId,String initWhse) throws Exception {
	 	
		
		//String parmList = "|method~ExportCustomers|terms~Y|";
		String parmList="|TERMS~Y|METHOD~exportbatches|SDATE~"+startDate.trim()+"|EDATE~"+endDate.trim()+"|";
		String strError="";
		String []subResponseArry;
		JSONArray jsonArray= new JSONArray();
		try {
			DistUtils du=new DistUtils();
			String userPassParam=du.getFieldInfo("select 'un~'||paytraceuser||'|pswd~'||paytracepass from warehouse where companyid='"+companyId+"' and warehouse='"+initWhse+"'");
			Utils.log("parmList>1>>>>"+ parmList);
			parmList=userPassParam+parmList;
			Utils.log("parmList>2>>>>"+ parmList);
			returnResult= payTraceProcess(parmList);
			Utils.log("returnResult>>>>"+ returnResult);
			
			//i25BATCHRECORD~BATCHNUM=9549+WHEN=8/30/2017+TRANXCOUNT=78+NETAMOUNT=$49,143.42+SALESCOUNT=74+SALESAMOUNT=$49,406.23+REFUNDCOUNT=4+REFUNDAMOUNT=$262.81
		
			
	    	 if(!returnResult.equals("") && returnResult.indexOf("|")>0 && returnResult.indexOf("~")>0)
	    	 {
	    	 String [] responseArry=returnResult.split("\\|",-1);
	    		Utils.log("responseArry.length>>>>>>"+ responseArry.length);
	    	 for(int i=0;i<responseArry.length;i++){
	    		 JSONObject itemjson = new JSONObject();
	    		 Utils.log("i"+i+responseArry[i]);
	    		  String []arrPair = responseArry[i].split("~",-1); 
	    		  if(arrPair[0].equals("ERROR"))
	    		   strError = strError + arrPair[1];
	    		  else if(arrPair[0].equals("BATCHRECORD")){ 
	    			  //JSONObject json = new JSONObject();
	    			  subResponseArry = arrPair[1].split("\\+",-1);
	    			  Utils.log(arrPair[1]);
	    			 // double salesAmount=0;
	    			 // double refundAmount=0;
	    		  for(int j=0;j<subResponseArry.length;j++){
	    			  String []arrPairSub = subResponseArry[j].split("\\=",-1); 
	    			  Utils.log(subResponseArry[j]);
	    			  if(arrPairSub[0].equals("TRANXCOUNT"))
	    				  itemjson.put("TRANXCOUNT",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("NETAMOUNT"))
	    				  itemjson.put("NETAMOUNT",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("SALESCOUNT"))
	    				  itemjson.put("SALESCOUNT",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("SALESAMOUNT"))
	    			 // {
	    				  itemjson.put("SALESAMOUNT",arrPairSub[1]);
	    				  //Utils.log("arrPairSub[1].length()>>>>>>"+arrPairSub[1].length());
	    				  //String abc=arrPairSub[1].substring(1, arrPairSub[1].length());
	    				  //Utils.log("abc>>>>>>"+abc);
	    				  //String xyz=abc.trim().replaceAll(",","");
	    				  //Utils.log("xyz>>>>>>"+xyz);
	    				 // salesAmount=salesAmount+Double.parseDouble(xyz);
	    				 // Utils.log("salesAmount>>>>>>"+ salesAmount);
	    			  //}
	    			  else if(arrPairSub[0].equals("REFUNDCOUNT"))
	    				  itemjson.put("REFUNDCOUNT",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("REFUNDAMOUNT"))
	    			  //{
	    				  itemjson.put("REFUNDAMOUNT",arrPairSub[1]);
	    				 // Utils.log("arrPairSub[1].length()>>>>>>"+arrPairSub[1].length());
	    				 // String abc=arrPairSub[1].substring(1, arrPairSub[1].length());
	    				 // Utils.log("abc>>>>>>"+abc);
	    				 // String xyz=abc.trim().replaceAll(",","");
	    				 // Utils.log("xyz>>>>>>"+xyz);
	    				 // refundAmount=refundAmount+Double.parseDouble(xyz);
	    			 // }
	    			  else if(arrPairSub[0].equals("WHEN"))
	    				  itemjson.put("WHEN",arrPairSub[1]);
	    			  
	    		  }
	    		  //json.append("aaData", itemjson);
	    		  //Utils.log("salesAmoun>>>>"+ String.valueOf(salesAmount));
	    		  
	    		  //Utils.log("salesAmount-refundAmount>>>>"+ String.valueOf((long) Math.pow((salesAmount-refundAmount), 2)));
	    		  //itemjson.put("TOTALAMOUNT","$"+String.valueOf((Math.round((salesAmount-refundAmount)*100)/100)));
	    		  
	    		  if(!itemjson.has("TRANXCOUNT")){
	    			  itemjson.put("TRANXCOUNT","");
  				    } 
	    		  if(!itemjson.has("NETAMOUNT")){
	    			  itemjson.put("NETAMOUNT","");
  				    }
	    		  if(!itemjson.has("SALESCOUNT")){
	    			  itemjson.put("SALESCOUNT","");
  				    }
	    		  if(!itemjson.has("SALESAMOUNT")){
	    			  itemjson.put("SALESAMOUNT","");
  				    }
	    		  if(!itemjson.has("REFUNDCOUNT")){
	    			  itemjson.put("REFUNDCOUNT","");
  				    }
	    		  if(!itemjson.has("REFUNDAMOUNT")){
	    			  itemjson.put("REFUNDAMOUNT","");
  				    }
	    		  if(!itemjson.has("WHEN")){
	    			  itemjson.put("WHEN","");
  				    }
	    		  
	    		  jsonArray.put(itemjson);
	    		  }
	    	 }
	    		  
	    	 }
	    	 else
	    		 throw new Exception(strError  + "The response from the PayTrace was invalid.");
	    	 if(!strError.equals(""))
	    		 throw new Exception(strError);
			
			
		} catch (Exception e) {
			Utils.logError("Error", e);
			throw new Exception("Error:"+ e.getMessage());
		} 

		return jsonArray;
	}
	
	
	
	public JSONArray getPayTraceTransactions(String companyId,   String startDate, String endDate, String userId,String initWhse) throws Exception {
	 	
		
		//String parmList = "|method~ExportCustomers|terms~Y|";
		String parmList="|TERMS~Y|RETURNBIN~Y|METHOD~ExportTranx|SDATE~"+startDate.trim()+"|EDATE~"+endDate.trim()+"|";
		String strError="";
		String []subResponseArry;
		JSONArray jsonArray= new JSONArray();
		JSONArray jsonArray2= new JSONArray();
		try {
			DistUtils du=new DistUtils();
			String userPassParam=du.getFieldInfo("select 'un~'||paytraceuser||'|pswd~'||paytracepass from warehouse where companyid='"+companyId+"' and warehouse='"+initWhse+"'");
			Utils.log("parmList>1>>>>"+ parmList);
			parmList=userPassParam+parmList;
			Utils.log("parmList>2>>>>"+ parmList);
			returnResult= payTraceProcess(parmList);
			Utils.log("returnResult>>>>"+ returnResult);
			
			//i25BATCHRECORD~BATCHNUM=9549+WHEN=8/30/2017+TRANXCOUNT=78+NETAMOUNT=$49,143.42+SALESCOUNT=74+SALESAMOUNT=$49,406.23+REFUNDCOUNT=4+REFUNDAMOUNT=$262.81
		
			
	    	 if(!returnResult.equals("") && returnResult.indexOf("|")>0 && returnResult.indexOf("~")>0)
	    	 {
	    		 Utils.log(">>>returnResult>>>"+returnResult);
	    	 String [] responseArry=returnResult.split("\\|",-1);
	    		Utils.log("responseArry.length>>>>>>"+ responseArry.length);
	    		double visaTotal=0;
	    		double masterCardTotal=0;
	    		double americanCardTotal=0;
	    		double discoverTotal=0;
	    		double totalSale=0;
	    		double totalRefund=0;
	    		double netAmount=0;
	    		double cardTotal=0;
	    		double subTotalCard=0;
	    		double directFromPaytrace=0;
	    		double orderEntrySale=0;
	    		double oePrepaidSale=0;
	    		double arsale=0;
	    		double totalSaleByEntries=0;
	    		JSONObject itemjson2 = new JSONObject();
	    	 for(int i=0;i<responseArry.length;i++){
	    		 JSONObject itemjson = new JSONObject();
	    		 Utils.log("i"+i+responseArry[i]);
	    		  String []arrPair = responseArry[i].split("~",-1); 
	    		  if(arrPair[0].equals("ERROR"))
	    		   strError = strError + arrPair[1];
	    		  else if(arrPair[0].equals("TRANSACTIONRECORD")){ 
	    			  //JSONObject json = new JSONObject();
	    			  subResponseArry = arrPair[1].split("\\+",-1);
	    			  Utils.log(arrPair[1]);
	    			  String creditCardType="";
	    			  String status="";
	    			  String taxType="";
	    			  double amount=0;
	    			  String methodType="";
	    			  String documentNo="";
	    		  for(int j=0;j<subResponseArry.length;j++){
	    			  String []arrPairSub = subResponseArry[j].split("\\=",-1); 
	    			  Utils.log(subResponseArry[j]);
	    			  if(arrPairSub[0].equals("TRANXID"))
	    				  itemjson.put("TRANXID",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("CC")){
	    				  itemjson.put("CC",arrPairSub[1]);
	    				   creditCardType=cCType(arrPairSub[1]);
	    				  itemjson.put("CCTYPE",creditCardType);
	    			  }else if(arrPairSub[0].equals("EXPMNTH"))
	    				  itemjson.put("EXPMNTH",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("EXPYR"))
	    				  itemjson.put("EXPYR",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("TRANXTYPE")){
	    				  itemjson.put("TRANXTYPE",arrPairSub[1]);
	    				  taxType=arrPairSub[1];
	    			  }
	    			  else if(arrPairSub[0].equals("AMOUNT")){
	    				  itemjson.put("AMOUNT",arrPairSub[1]);
	    				  amount=amount+Double.parseDouble(arrPairSub[1]);
	    			  }
	    			  else if(arrPairSub[0].equals("BZIP"))
	    				  itemjson.put("BZIP",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("Document Number")){
	    				  itemjson.put("Document",arrPairSub[1]);
	    				  documentNo=arrPairSub[1];
	    			  } else if(arrPairSub[0].equals("User Initials"))
	    				  itemjson.put("User_Initials",arrPairSub[1]);
	    			  else if(arrPairSub[0].equals("WHEN"))
	    				  itemjson.put("WHEN",arrPairSub[1]);	
	    			  else if(arrPairSub[0].equals("METHOD")){
	    				  methodType=arrPairSub[1].substring(0, 3);
	    				  if(methodType.equals("API"))
	    					  itemjson.put("METHOD",arrPairSub[1]);	
	    				  else
	    					  itemjson.put("METHOD","Paytrace");
	    				  
	    			  }else if(arrPairSub[0].equals("STATUS")){
	    				  status=arrPairSub[1];
	    				  itemjson.put("STATUS",status);	
	    			  }
	    			   
	    			  
	    		  }
	    		  
	    		  if(!itemjson.has("TRANXID")){
	    			  itemjson.put("TRANXID","");
  				    } 
	    		  if(!itemjson.has("CCTYPE")){
	    			  itemjson.put("CCTYPE","");
  				    }
	    		  if(!itemjson.has("CC")){
	    			  itemjson.put("CC","");
  				    }
	    		  if(!itemjson.has("EXPMNTH")){
	    			  itemjson.put("EXPMNTH","");
  				    }
	    		  if(!itemjson.has("EXPYR")){
	    			  itemjson.put("EXPYR","");
  				    }
	    		  if(!itemjson.has("TRANXTYPE")){
	    			  itemjson.put("TRANXTYPE","");
  				    }
	    		  if(!itemjson.has("AMOUNT")){
	    			  itemjson.put("AMOUNT","");
  				    }
	    		  
	    		  if(!itemjson.has("BZIP")){
	    			  itemjson.put("BZIP","");
  				    } 
	    		  if(!itemjson.has("Document")){
	    			  itemjson.put("Document","");
  				    }
	    		  if(!itemjson.has("User_Initials")){
	    			  itemjson.put("User_Initials","");
  				    }
	    		  if(!itemjson.has("WHEN")){
	    			  itemjson.put("WHEN","");
  				    }
	    		  if(!itemjson.has("METHOD")){
	    			  itemjson.put("METHOD","");
  				    }
	    			  
	    		  Utils.log("methodType>>>>>>>"+ methodType);
	    		  Utils.log("documentNo>>>>>>>"+ documentNo);
	    		  Utils.log("documentNo.substring(Math.max(documentNo.length() - 2, 0))>>>>>>>"+ documentNo.substring(Math.max(documentNo.length() - 2, 0)));
	    		  if(!methodType.trim().equals("API") && taxType.equals("SALE")){
	    			  directFromPaytrace=directFromPaytrace+amount;
	    			  totalSaleByEntries=totalSaleByEntries+amount;
	    		  }
	    		  /*else if(!methodType.trim().equals("API") && taxType.equals("REFUND")  && !status.equals("N")){
	    			  if(directFromPaytrace>amount)
	    				  directFromPaytrace=directFromPaytrace-amount;
	    				else
	    				  directFromPaytrace=amount-directFromPaytrace;
	    			  if(totalSaleByEntries>amount)
	    				  totalSaleByEntries=totalSaleByEntries-amount;
	    			  else
	    				  totalSaleByEntries=amount-totalSaleByEntries;
	    				  
	    		  }*/
	    		  else if(documentNo.substring(Math.max(documentNo.length() - 2, 0)).equals(":1") && taxType.equals("SALE")  && !status.equals("N")){
	    		  		orderEntrySale=orderEntrySale+amount;
	    		  		totalSaleByEntries=totalSaleByEntries+amount;
	    		  }
	    		/*  else if(documentNo.substring(Math.max(documentNo.length() - 2, 0)).equals(":1") && taxType.equals("REFUND")  && !status.equals("N")){
	    			  if(orderEntrySale>amount)
	    				  orderEntrySale=orderEntrySale-amount;
	    		  	  else
	    				  orderEntrySale=amount-orderEntrySale;
	    			  if(totalSaleByEntries>amount)
	    				  totalSaleByEntries=totalSaleByEntries-amount;
	    			  else
	    		  	 	  totalSaleByEntries=amount-totalSaleByEntries;
	    			  
	    		  }*/
	    		  else if(documentNo.contains("OE") && taxType.equals("SALE") && !status.equals("N")){
	    			    oePrepaidSale=oePrepaidSale+amount;
	    			    totalSaleByEntries=totalSaleByEntries+amount;
	    	 	  }
	    		 /* else if(documentNo.contains("OE") && taxType.equals("REFUND") && !status.equals("N")){
		    	 		 if(oePrepaidSale>amount)
		    	 			 oePrepaidSale=oePrepaidSale-amount;
		    	 		 else
		    	 			oePrepaidSale=amount-oePrepaidSale;
		    	 		 if(totalSaleByEntries>amount)	 
		    	 			totalSaleByEntries=totalSaleByEntries-amount;
		    	 		 else
		    	 			totalSaleByEntries=amount-totalSaleByEntries;
	    	 		 
	    	 	  }*/
	    	 	  else if(taxType.equals("SALE") && !status.equals("N")){
	    			  arsale=arsale+amount;
	    			  totalSaleByEntries=totalSaleByEntries+amount;
	    		  
	    	 	  }
	    	 	/*  else if(taxType.equals("REFUND") && !status.equals("N")){
	    	 		  if(arsale>amount)
	    	 			  arsale=arsale-amount;
	    	 		  else
	    	 			  arsale=amount-arsale;
	    	 		  if(totalSaleByEntries>amount)
	    	 		  	  totalSaleByEntries=totalSaleByEntries-amount;
	    	 		  else
	    	 		  	  totalSaleByEntries=amount-totalSaleByEntries;
	    	 		  
	    	 	  }*/
	    		  
	    		// Utils.log("creditCardType>>>>"+ creditCardType +">>>>taxType>>>>"+taxType );
	    		  if(creditCardType.equals("Visa") && taxType.equals("SALE") && !status.equals("N")){
	    			  visaTotal=visaTotal+amount;
	    			  cardTotal=cardTotal+amount;
	    			  subTotalCard=subTotalCard+amount;
	    		  }
	    		 /* else if(creditCardType.equals("Visa") && taxType.trim().equals("REFUND")){
	    			  if(visaTotal>amount)
	    				  visaTotal=visaTotal-amount;
	    			  else
	    				  visaTotal=amount-visaTotal;
	    			  if(cardTotal>amount)
		    			  cardTotal=cardTotal-amount;
	    			  else
	    				  cardTotal=amount-cardTotal;
	    			  if(subTotalCard>amount)
		    			  subTotalCard=subTotalCard-amount;
	    			  else
	    				  subTotalCard=amount-subTotalCard; 
	    		  }*/
	    		  
	    		 
	    		  if(creditCardType.equals("MasterCard") && taxType.trim().equals("SALE") && !status.equals("N")){
	    			  Utils.log("amount>>>>"+ amount + "taxType.trim()>>>"+ taxType.trim() +">>>masterCardTotal>>"+ masterCardTotal);
	    			  masterCardTotal=masterCardTotal+amount;
	    			  cardTotal=cardTotal+amount;
	    			  subTotalCard=subTotalCard+amount;
	    		  }
	    		  /*else if(creditCardType.equals("MasterCard") && taxType.trim().equals("REFUND")){
	    			  Utils.log("amount>>>>"+ amount + "taxType.trim()>>>"+ taxType.trim() +">>>masterCardTotal>>"+ masterCardTotal);
	    			  //if(masterCardTotal>amount)
	    				  //masterCardTotal=masterCardTotal-amount;
	    			  //else
	    			//	  masterCardTotal=amount-masterCardTotal;
	    			  if(cardTotal>amount)
		    			  cardTotal=cardTotal-amount;
	    			  else
	    				  cardTotal=amount-cardTotal;
	    			  if(subTotalCard>amount)
		    			  subTotalCard=subTotalCard-amount;
	    			  else
	    				  subTotalCard=amount-subTotalCard; 
	    		  }*/
	    		  
	    		  
	    		  if(creditCardType.equals("American Express") && taxType.trim().equals("SALE") && !status.equals("N")){
	    			  americanCardTotal=americanCardTotal+amount;
	    			  cardTotal=cardTotal+amount;
	    		  }
	    		  /*else  if(creditCardType.equals("American Express") && taxType.trim().equals("REFUND")){
	    			  if(americanCardTotal>amount)
	    				  americanCardTotal=americanCardTotal-amount;
	    			  else
	    				  americanCardTotal=amount-americanCardTotal;
	    			  if(cardTotal>amount)
		    			  cardTotal=cardTotal-amount;
	    			  else
	    				  cardTotal=amount-cardTotal;
	    			 
	    		  }*/
	    		  
	    		  if(creditCardType.equals("Discover") && taxType.trim().equals("SALE") && !status.equals("N")){
	    			  discoverTotal=discoverTotal+amount;
	    			  cardTotal=cardTotal+amount;
	    			  subTotalCard=subTotalCard+amount;
	    		  }
	    		  /*else if(creditCardType.equals("Discover") && taxType.trim().equals("REFUND")){
	    			  if(discoverTotal>amount)
	    				  discoverTotal=discoverTotal-amount;
	    			  else
	    				  discoverTotal=amount-discoverTotal;
	    			  if(cardTotal>amount)
		    			  cardTotal=cardTotal-amount;
	    			  else
	    				  cardTotal=amount-cardTotal;
	    			  if(subTotalCard>amount)
		    			  subTotalCard=subTotalCard-amount;
	    			  else
	    				  subTotalCard=amount-subTotalCard; 
	    		  }*/
	    		  
	    		  
	    		  if(taxType.equals("SALE")  && !status.equals("N")){
	    			  totalSale=totalSale+amount;
	    		  }else if(taxType.equals("REFUND")  && !status.equals("N")){
	    			  totalRefund=totalRefund+amount;
	    			  orderEntrySale=orderEntrySale-amount;
	    			  totalSaleByEntries=totalSaleByEntries-amount;
	    		  }
	    		  
	    		 if(!status.equals("N"))
	    			 jsonArray2.put(itemjson);
	    		 
	    		  }
	    	 }
	    	 itemjson2.put("dataVal", jsonArray2);
	    	  netAmount=netAmount+(totalSale-totalRefund);
	    	 // itemjson2.put("dataVal", itemjson) ;
	    	 itemjson2.put("visaTotal",visaTotal);
   		  	 itemjson2.put("masterCardTotal",masterCardTotal);
   		  	 itemjson2.put("americanCardTotal",americanCardTotal);
   		     itemjson2.put("discoverTotal",discoverTotal);
   		     itemjson2.put("totalSale",totalSale);
		  	 itemjson2.put("totalRefund",totalRefund);
		  	 itemjson2.put("netAmount",netAmount);
		  	 itemjson2.put("subTotalCard",subTotalCard);
		  	 itemjson2.put("cardTotal",cardTotal);
		  	 
		  	 itemjson2.put("directFromPaytrace",directFromPaytrace);
 		  	 itemjson2.put("orderEntrySale",orderEntrySale);
 		  	 itemjson2.put("oePrepaidSale",oePrepaidSale);
 		  	 itemjson2.put("arsale",arsale);
 		  	 itemjson2.put("totalSaleByEntries",totalSaleByEntries);
 		  	 
 		  	
		  	 
	    	 jsonArray.put(itemjson2);
	    		  
	    	 }
	    	 else
	    		 throw new Exception(strError  + "The response from the PayTrace was invalid.");
	    	 if(!strError.equals(""))
	    		 throw new Exception(strError);
			
			
		} catch (Exception e) {
			Utils.logError("Error", e);
			throw new Exception("Error:"+ e.getMessage());
		} 

		return jsonArray;
	}
	
	public static String cCType (String cC) throws Exception{
	    if (cC.startsWith("4")){
	        return "Visa";
	    }
	    else if (cC.startsWith("51") || cC.startsWith("52") || cC.startsWith("53") || cC.startsWith("54") ||cC.startsWith("55")){
	        return "MasterCard";
	    }
	    else if (cC.startsWith("6011")){
	        return "Discover";
	    }
	    else if (cC.startsWith("37") || cC.startsWith("34")){
	          return "American Express";
	    }
	   /* else if (cC.startsWith("300") || cC.startsWith("301") || cC.startsWith("302") || cC.startsWith("303") ||cC.startsWith("304") ||cC.startsWith("305")){
	        return "Diners Club";
	    }
	    else if (cC.startsWith("38")){
	        return "Carte Blanche";
	    }
	    else if (cC.startsWith("2014") || cC.startsWith("2149")){
	        return "EnRoute";
	  }
	    else if (cC.startsWith("2131") || cC.startsWith("1800")){
	        return "JCB";
	  }*/
	    else 
	        throw new Exception("Not a valid Credit Card Type");
	}
}
