package com.etechlogix.distribution.ad.servlet;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.ws.rs.core.MediaType;

import com.etechlogix.utils.Utils;

import net.sf.json.JSONObject;

public class AgilityAPICalls {
	
	public JSONObject getContextIdTest(String userName, String password){
		
		String url = "https://api-1362-2.dmsi.com/AgilityPublic/rest/Session/Login";
		HashMap<String, String> headerMaps=new HashMap<String, String>();

		JSONObject childBody=new JSONObject();
		childBody.put("LoginID", userName);
		childBody.put("Password", password);
		
		JSONObject mainBody=new JSONObject();
		mainBody.put("request", childBody);
		
		String contentType=MediaType.APPLICATION_JSON;
		Utils.log("Login Request: "+mainBody);
		return apiCall(url, mainBody.toString(), "POST", contentType, headerMaps);
	}
	
	public JSONObject getContextIdProduction(String userName, String password){
		
		String url = "https://api-1362-1.dmsi.com/AgilityPublic/rest/Session/Login";
		HashMap<String, String> headerMaps=new HashMap<String, String>();

		JSONObject childBody=new JSONObject();
		childBody.put("LoginID", userName);
		childBody.put("Password", password);
		
		JSONObject mainBody=new JSONObject();
		mainBody.put("request", childBody);
		
		String contentType=MediaType.APPLICATION_JSON;
		Utils.log("Login Request: "+mainBody);
		return apiCall(url, mainBody.toString(), "POST", contentType, headerMaps);
	}

	
	
	
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
			Utils.log("Request Body : " + data);
			
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
	
				if(stringBuilder!=null && stringBuilder.length()>0) {
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

	public String changeDateFormatAgiltyAPI(String dateString){
		
		String dateStr ="";
    	if(dateString.matches("{1}[0-9]{4}[-]{1}[0-9]{2}[-][0-9]{2}")){
    		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    		try {
				Date d = sdf.parse(dateString);
				dateStr = sdf.format(d);
			} catch (Exception e) {
				Utils.log("Without Date Change Exception  " , e);
			}
    	}
    	else{
    		try{
    			String replaceString = dateString.replace('/','-');
    		    SimpleDateFormat dt = new SimpleDateFormat("dd-MM-yyyy");
    		    Date date = dt.parse(replaceString);
    		    SimpleDateFormat dt1 = new SimpleDateFormat("yyyy-MM-dd");
    		    dateStr = dt1.format(date);
    		}
    		catch (Exception e) {
    			e.printStackTrace();
    			Utils.log("With Date Change Exception :: " , e);
    		}
    	}
    	return dateStr;
		
	}


}
