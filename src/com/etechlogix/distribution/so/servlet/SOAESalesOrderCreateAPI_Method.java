package com.etechlogix.distribution.so.servlet;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.Vector;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.ws.rs.core.MediaType;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class SOAESalesOrderCreateAPI_Method
{
	public JSONObject getSystemId(String url,String loginId,String password)
	{
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		JSONObject childBody=new JSONObject();
		childBody.put("LoginID", loginId);
		childBody.put("Password", password);
		JSONObject mainBody=new JSONObject();
		mainBody.put("request", childBody);
		Utils.log("Login Request Object :: " + mainBody);
		
		String contentType=MediaType.APPLICATION_JSON;
		Utils.log("Login Request: "+mainBody);
		return apiCall(url, mainBody.toString(), "POST", contentType, headerMaps);
	}
	
	public JSONObject agilityPublicAPICall(String url,JSONObject requestObject,String contextId,String systemId)
	{
		HashMap<String, String> headerMaps=new HashMap<String, String>();
		headerMaps.put("ContextId", contextId);
		headerMaps.put("Branch", systemId);
		String contentType=MediaType.APPLICATION_JSON;
		Utils.log("Request: "+requestObject);
		return apiCall(url, requestObject.toString(), "POST", contentType, headerMaps);
	}

	
	public HashMap<String,String> getLoginCredentials(JSONObject json)
	{
		String customerId="",query="";
		HashMap<String,String> temp=new HashMap<String,String>();
		try {
			JSONObject req = (JSONObject)json.get("request");
			JSONObject dsOrderHeaderRequest = (JSONObject)req.get("dsOrderHeaderRequest");
			JSONArray dtOrderHeaderRequestArray = (JSONArray)dsOrderHeaderRequest.get("dtOrderHeaderRequest");

			DistUtils du=new DistUtils();
			for(int i=0;i<dtOrderHeaderRequestArray.size();i++){
				JSONObject obj = (JSONObject)dtOrderHeaderRequestArray.get(i);
				customerId = obj.get("CustomerID").toString();
			}
			
			Utils.log("customerId="+customerId);
			query="select distinct APIUSERID,APIPASSWORD from ETECHUSER where DEPTID='"+customerId+"'"; 
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector apiUserIdVector = new Vector();
			Vector apiPasswordVector = new Vector();
			if (ht != null && ht.size() != 0) {
				apiUserIdVector = (Vector) ht.get("APIUSERID");
				apiPasswordVector = (Vector) ht.get("APIPASSWORD");
			}
	        if (apiUserIdVector.size() > 0) {
	        	for (int i = 0; i < apiUserIdVector.size(); i++) {  
	    			temp=new HashMap<String, String>();
	    			temp.put("apiUserId", apiUserIdVector.get(i).toString());
					temp.put("apiPassword", apiPasswordVector.get(i).toString());
				}
			}
		} 
		catch (Exception e) {
			Utils.log("Exception =",e);
		}
		
		return temp;
	}

	
	/*public String getSystemId(JSONObject json)
	{
		String orderedBy="";
		String system_id="";
		String query="";
		try {
			JSONObject req = (JSONObject)json.get("request");
			JSONObject dsOrderHeaderRequest = (JSONObject)req.get("dsOrderHeaderRequest");
			JSONArray dtOrderHeaderRequestArray = (JSONArray)dsOrderHeaderRequest.get("dtOrderHeaderRequest");

			DistUtils du=new DistUtils();
			for(int i=0;i<dtOrderHeaderRequestArray.size();i++){
				JSONObject obj = (JSONObject)dtOrderHeaderRequestArray.get(i);
				orderedBy = obj.get("OrderedBy").toString();
			}
			
			Utils.log("orderedBy="+orderedBy);
			query="select default_branch from user_ctl where user_or_group_id='"+orderedBy+"'";
			Utils.log(query);
			system_id=du.getFieldInfoPro2(query);
			Utils.log(system_id);
		} catch (Exception e) {
			Utils.log("Exception =",e);
		}
		
		return system_id;
	}*/
	
	
	public JSONObject apiCall(String url,String data,String method,String contentType,HashMap<String, String> headerMaps){
		
		JSONObject jsonObj = new JSONObject();
		String inputLine = "";
		HttpsURLConnection httpsCon =null;
		HttpURLConnection httpCon =null;
		InputStream ins = null;
		InputStreamReader isr = null;
		BufferedReader in = null;
		try {
			Utils.log("URL : " + url);
			Utils.log("Data : " + data);
			
			String protocall[]= url.split("://");
			if("http".equalsIgnoreCase(protocall[0])) {
	
				URL myurl = new URL(url);
				httpCon = (HttpURLConnection) myurl.openConnection();
				httpCon.setRequestMethod(method);
	
				httpCon.setReadTimeout(180000);
				httpCon.setConnectTimeout(180000);
				httpCon.setUseCaches(false);
				httpCon.setRequestProperty("Content-Type", contentType);
	
				if(headerMaps!=null) {
					for (Map.Entry<String, String> entry : headerMaps.entrySet()) {
						httpCon.setRequestProperty(entry.getKey(), entry.getValue());
						
						Utils.log(entry.getKey()+" : "+entry.getValue());
					}
				}
	
				if(!"GET".equalsIgnoreCase(method)){
					httpCon.setDoOutput(true);
					DataOutputStream wr = new DataOutputStream(httpCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
	
				StringBuilder stringBuilder = new StringBuilder();
				int responseCode = httpCon.getResponseCode();
	
				if(responseCode<400) {
					ins = httpCon.getInputStream();
				}else {
					ins=httpCon.getErrorStream();
				}
				isr = new InputStreamReader(ins);
				in = new BufferedReader(isr);
	
				while ((inputLine = in.readLine()) != null) {
					stringBuilder.append(inputLine);
				}
				
				Utils.log("Log : "+stringBuilder);
				
				if(stringBuilder!=null && stringBuilder.length()>0) {
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					jsonObj=JSONObject.fromObject(output);
				}
	
			}else {
	
				// Create a trust manager that does not validate certificate chains
				TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
					public java.security.cert.X509Certificate[] getAcceptedIssuers() {
						return null;
					}
	
					public void checkClientTrusted(X509Certificate[] certs, String authType) {
					}
	
					public void checkServerTrusted(X509Certificate[] certs, String authType) {
					}
				} };
	
				// Install the all-trusting trust manager
				SSLContext sc = SSLContext.getInstance("SSL");
				sc.init(null, trustAllCerts, new java.security.SecureRandom());
				HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
	
				// Create all-trusting host name verifier
				HostnameVerifier allHostsValid = new HostnameVerifier() {
					public boolean verify(String hostname, SSLSession session) {
						return true;
					}
				};
	
				// Install the all-trusting host verifier
				HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
				URL myurl = new URL(url);
				httpsCon = (HttpsURLConnection) myurl.openConnection();
				httpsCon.setRequestMethod(method);
				httpsCon.setRequestProperty("Content-Type", contentType);
				httpsCon.setReadTimeout(180000);
				httpsCon.setConnectTimeout(180000);
				httpsCon.setUseCaches(false);
				if(headerMaps!=null) {
					for (Map.Entry<String, String> entry : headerMaps.entrySet()) {
						httpsCon.setRequestProperty(entry.getKey(), entry.getValue());
						
						Utils.log(entry.getKey()+" : "+entry.getValue());
					}
				}
				if(!"GET".equalsIgnoreCase(method)){
					httpsCon.setDoInput(true);
					httpsCon.setDoOutput(true);
					DataOutputStream wr = new DataOutputStream(httpsCon.getOutputStream());
					wr.writeBytes(data);
					wr.flush();
					wr.close();
				}
	
				StringBuilder stringBuilder = new StringBuilder();
				int responseCode = httpsCon.getResponseCode();
	
				Utils.log("Status code : "+responseCode);
				
				if(responseCode<400) {
					ins = httpsCon.getInputStream();
				}else {
					ins=httpsCon.getErrorStream();
				}
				isr = new InputStreamReader(ins);
				in = new BufferedReader(isr);
	
				while ((inputLine = in.readLine()) != null) {
					stringBuilder.append(inputLine);
				}
				
				Utils.log("Log : "+stringBuilder);
	
				if(stringBuilder!=null && stringBuilder.length()>0){
					String output=stringBuilder.toString();
					output=output.replaceAll("null", "0");
					jsonObj=JSONObject.fromObject(output);
				}
			}
			return jsonObj;
	
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return null;
		}finally {
	
			try {
				if(httpCon!=null)
					httpCon.disconnect();
				if(httpsCon!=null)
					httpsCon.disconnect();
				if(ins!=null)
					ins.close();
				if(isr!=null)
					isr.close();
				if(in!=null)
					in.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return null;
			}
		}
	}
}