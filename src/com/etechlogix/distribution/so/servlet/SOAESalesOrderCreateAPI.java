package com.etechlogix.distribution.so.servlet;

import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Properties;
import java.util.Scanner;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

import net.sf.json.JSONObject;

public class SOAESalesOrderCreateAPI extends HttpServlet {

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		String requestUrl = request.getRequestURI();
		Utils.log(requestUrl);

		response.getOutputStream().println("{No Data Found}");

	}

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		// Utils.log("#MobileLog#AppName="+request.getHeader("X-Requested-With"));
		Utils.log("#MiddleAPI# Method POST ");
		String responseString = "{\"status\":\"error\", \"message\": \" Exception Occured \"}";
		
		FileReader reader=new FileReader("eTechLogix.properties");
	    Properties prop=new Properties();  
	    prop.load(reader);    
	    String agilityUrl=prop.getProperty("AgilityUrl");
	    String systemId="",contextId ="";
	    String loginId="bfarooq",password="rwc";
	    
		try {
			DistUtils du = new DistUtils();
			String jsonString = extractPostRequestBody(request);
			Utils.log(jsonString);
			JSONObject json =JSONObject.fromObject(jsonString);
			
			JSONObject jsonReturn =new JSONObject();
			String filepath="/home/tomcat/support_file/salesordercreate_api/";
		    
				String query = "select max(slno)+1 from dmsi_aesalesorder";
				String slno = du.getFieldInfo(query);
				
				String fileName=filepath+"ORDER"+"-"+slno;
				
				BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
			    writer.write(jsonString);
			    writer.close();
				
				query = "insert into dmsi_aesalesorder (slno,filepath,api_name,entrydatetime) values (" + slno + ",'"+fileName+"','SALESORDERCREATE', current_timestamp)";
				int retval = du.updateRecord(query);
				String orderno = "";
				if (retval > 0) {
					Utils.log("Data Inserted Successfully");
					orderno = slno;
					//responseString = "{\"status\":\"success\", \"orderno\": \" " + slno + " \"}";
					SOAESalesOrderCreateAPI_Method sm=new SOAESalesOrderCreateAPI_Method();
					//systemId=sm.getSystemId(json);
					
					String loginUrl=agilityUrl+"Session/Login";
					HashMap<String, String> map = sm.getLoginCredentials(json);
					loginId=map.get("apiUserId");
					password=map.get("apiPassword");
					
					JSONObject loginRespObj = sm.getSystemId(loginUrl,loginId,password);
					Utils.log("Login Response >>>> "+loginRespObj);
					if(loginRespObj != null){
						JSONObject loginResp = (JSONObject)loginRespObj.get("response");
						contextId = loginResp.get("SessionContextId").toString();
						systemId = loginResp.get("InitialBranch").toString();
					}
					
					String createOrderUrl=agilityUrl+"Orders/SalesOrderCreate";
					jsonReturn=sm.agilityPublicAPICall(createOrderUrl,json,contextId,systemId);
					Utils.log(jsonReturn.toString());
					responseString=jsonReturn.toString();
					
				} else {
					Utils.log("Error In inserting Data");
					responseString = "{\"status\":\"error\", \"orderno\": \" 0 \"}";
					
					orderno = "0";
				}
			
		} catch (Exception e) {

			Utils.log("Exception", e);
		}

		response.getOutputStream().println(responseString);

	}

	static String extractPostRequestBody(HttpServletRequest request) throws IOException {
		if ("POST".equalsIgnoreCase(request.getMethod())) {
			Scanner s = new Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
			return s.hasNext() ? s.next() : "";
		}
		return "";
	}

}