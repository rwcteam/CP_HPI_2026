package com.etechlogix.distribution.mobileapp.servlet;

import java.io.*;
import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.LinkedHashMap;
import java.util.Scanner;
import java.util.Vector;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class AIDataStore extends HttpServlet {

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

		String requestUrl = request.getRequestURI();
		Utils.log(requestUrl);
		String name = requestUrl.substring("/mobileapp/".length());

		Person person = DataStore.getInstance().getPerson(name);

		if (person != null) {

			response.getOutputStream().println("VER-001 " + name);
		} else {
			// That person wasn't found, so return an empty JSON object. We could also
			// return an error.
			response.getOutputStream().println("{No Data Found}");
		}
	}

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		Utils.log("#AI Data Store #AppName=" + request.getHeader("X-Requested-With")+":"+request.getRemoteAddr());
		
		String query = "";
		String responseString = "";

		try {
			String jsonString = extractPostRequestBody(request);
			JSONObject obj = new JSONObject(jsonString);
			DistUtils du = new DistUtils();
			String token = obj.optString("TOKEN");
			query="select count(*) from dmsi_apitoken where module='AIDATASTORE' and token='"+token+"'";
			String token_valid=du.getFieldInfo(query);
			if(Integer.parseInt(token_valid)==0)
			{
				responseString = "{\"status\":\"error\", \"message\": \"Invalid Token\"}";
				Utils.log(responseString);
				response.getOutputStream().println(responseString);
				return;
				
			}
			String Method = obj.getString("METHOD");
			String value_type = obj.optString("VALUE_TYPE");
			if (Method.equals("QTY_TOTAL")) {
				if (value_type.equals("ITEM")) {
					String item = obj.getString("ITEM");
					query = "select system_id, item, item_sysid, qty_type, qty from qty_total  where item='" + item
							+ "'";
				} else if (value_type.equals("TODAY")) {
					query = "select system_id, item, item_sysid, qty_type, qty from qty_total where to_char(update_date,'MM-DD-YY')=to_char(current_date,'MM-DD-YY')";
				} else if (value_type.equals("ALL")) {
					query = "select system_id, item, item_sysid, qty_type, qty from qty_total";
				}
				
				Utils.log(query);
				
				JSONObject jo = du.getJSONDataFromQuery(query, "PRO2");
				responseString = jo.toString();
			}
			else if (Method.equals("ITEM_DETAIL")) {
				if (value_type.equals("TODAY")) {
					query = "select item,item_ptr,size_,description from item where to_char(update_date,'MM-DD-YY')=to_char(current_date,'MM-DD-YY')";
				} else if (value_type.equals("ALL")) {
					query = "select item,item_ptr,size_,description from item";
				}
				
				Utils.log(query);
				
				JSONObject jo = du.getJSONDataFromQuery(query, "PRO2");
				responseString = jo.toString();
			}
			
			else if (Method.equals("SALES_FACT") && value_type.equals("PER_SALES"))
			{
				query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM "
						+ " from sales_fact sf, item_dim it, sales_type_dim std "
						+ " where sf.item_key = it.item_key  "
						+ " and sf.summary_flag in ('S',' ') "
						+ " and sf.activity_date>=add_months(trunc(sysdate,'mm'),0) "
						+ " and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),0))  "
						+ " and sf.sales_type_key = std.sales_type_key "
						+ " and std.transfer <> 1 "
						+ " and std.sales_type  not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') "
						+ " group by sf.warehouse, it.item";
				JSONObject jo = du.getJSONDataFromQuery(query, "PRO2");
				responseString = jo.toString();
			}
			
			else if (Method.equals("SALES_FACT") && value_type.equals("SIX_MONTH"))
			{
				query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM "
						+ " from sales_fact sf, item_dim it, sales_type_dim std "
						+ " where sf.item_key = it.item_key  "
						+ " and sf.summary_flag in ('S',' ') "
						+ " and sf.activity_date>=add_months(trunc(sysdate,'mm'),-6) "
						+ " and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-1))  "
						+ " and sf.sales_type_key = std.sales_type_key "
						+ " and std.transfer <> 1 "
						+ " and std.sales_type  not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') "
						+ " group by sf.warehouse, it.item";
				JSONObject jo = du.getJSONDataFromQuery(query, "PRO2");
				responseString = jo.toString();
			}
			else if (Method.equals("ITEM_WISE") )
			{
				String item = obj.getString("ITEM");
				responseString=getJsonforSingleItem(item);
			}
			
			else if (Method.equals("REPORT_DETAIL"))
			{
				query="select REPORTID,REPORTNAME,PRODUCTS from AGILITYWHSEREPORT ORDER BY REPORTID";
				JSONObject jo = du.getJSONDataFromQuery(query, "ETECH");
				responseString = jo.toString();
			}
			else if (Method.equals("WAREHOUSE_DETAIL"))
			{
				query="select oldwhseno,newwhseno,whsename,whsestate from mob_whsemap";
				JSONObject jo = du.getJSONDataFromQuery(query, "ETECH");
				responseString = jo.toString();
			}
			else if (Method.equals("BUYER_DETAIL"))
			{
				query="select distinct item as ITEM , upper(buyer_id) as BUYERID from item_branch where upper(buyer_id)!='PURCHASE' and trim(buyer_id) is not null order by upper(buyer_id)";
				JSONObject jo = du.getJSONDataFromQuery(query, "PRO2");
				JSONArray ja=jo.getJSONArray("data");
				String itemlist="";
				String new_buyer="";
				String old_buyer="-1";
				JSONArray ja_new= new JSONArray();
				for(int i=0;i<ja.length();i++)
				{
					JSONObject j=ja.getJSONObject(i);
					new_buyer=j.getString("BUYERID");
					if(old_buyer.equals("-1"))
					{
						old_buyer=new_buyer;
					}
					if(new_buyer.equals(old_buyer))
					{
						if(itemlist.equals(""))
						{
							itemlist=j.getString("ITEM");
						}
						else
						{
							itemlist+=","+j.getString("ITEM");
						}
					}
					else
					{
						JSONObject j2=new JSONObject();
						j2.put(old_buyer,itemlist);
						ja_new.put(j2);
						old_buyer=new_buyer;
						itemlist=j.getString("ITEM");
						
					}
				}
				jo.put("data_list", ja_new);
				responseString = jo.toString();
			}
			else {
				responseString = "{\"status\":\"error\", \"message\": \"Parameter Mismatch\"}";
			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			Utils.log("Exception AI Data Store", e);
			responseString = "{\"status\":\"error\", \"message\": \" "+e.toString()+" \"}";
		}
		Utils.log(responseString);

		response.getOutputStream().println(responseString);

	}
public String getJsonforSingleItem(String ItemId) throws JSONException {
		
		
		Utils.log("IVRptWarehouseReportTwo.showWarehouseReport-");
		//Utils u=null;
		DistUtils du=null;
		//HttpSession session = request.getSession(true);
		String message = "";
		JSONObject mainObject = new JSONObject();
		JSONArray jsonArray = new JSONArray();
		
		Connection con = null;
		Statement st = null;
		ResultSet rs = null;
		
		Statement st2 = null;
		ResultSet rs2 = null;
		
		String reportDesc="";
		String products = ItemId;
		String query="";
		JSONArray jArray=new JSONArray();
		JSONObject returnJSON=new JSONObject();
		int manDate=0;
		int leadDays=0;
		JSONArray jArrayLead=new JSONArray();
		
		try {
			
			//du=DistUtils.getDistUtils(session);
			du=new DistUtils();
			//u=DistUtils.getUtils(session);
			//companyId=DistUtils.getCompanyId(session);
			
			Utils.log("manDate"+manDate);
			Utils.log("leadDays"+leadDays);
			
			//String reportCode="1001-Test";
			//Utils.log("reportCode.trim()[0]>>>"+ reportCode.trim().split("-")[0]);
			
			//query="select PRODUCTS from AGILITYWHSEREPORT where reportId = '"+reportCode+"'";
			//Utils.log("Query="+query);
			//products=du.getFieldInfo(query);
			//products="16527,16526,878,16525";
			//Utils.log("products>>>>>"+ products);
			String productArray[] = products.trim().split(",");
						
			StringBuilder allProducts = new StringBuilder();
			
			StringBuilder orderByIn = new StringBuilder(" order by case item ");
			for (int k=0; k < productArray.length; k++) {
				if(k == productArray.length - 1)
					allProducts.append("'"+productArray[k]+"'");
				else 
					allProducts.append("'"+productArray[k]+"',");
				
				int order = k + 1;
				orderByIn.append(" when '"+productArray[k]+"' then "+order+" ");
			}
			orderByIn.append(" end ");
			
			//String allProducts="'"+ItemId+"'";
			con = du.getDataConnectionPro2DataSource();
			JSONObject htmlStr= new JSONObject();
			//for (int k=0; k < productArray.length; k++) {
			
			
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),0) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),0))  and it.item in ("+allProducts+") and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type  not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') group by sf.warehouse, it.item";
			//Utils.log("Queey::salesPerUnit:::"+ query);
			Hashtable salesPerUnit = du.getDataFromQueryPro2(query);
			
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),-3) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-1))  and it.item in ("+allProducts+")  and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type  not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') group by sf.warehouse, it.item";
			//Utils.log("Queey::threePMOSalesForward:::"+ query);
			Hashtable threePMOSalesForward = du.getDataFromQueryPro2(query);
			
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),-11) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-9))  and it.item in ("+allProducts+")  and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type  not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') group by sf.warehouse, it.item";
			//Utils.log("Queey::threePMOSalesBackword:::"+ query);
			Hashtable threePMOSalesBackword = du.getDataFromQueryPro2(query);
			
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),-3) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-1))  and it.item in ("+allProducts+") and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type  in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT') group by sf.warehouse, it.item";
			//Utils.log("Queey::threeMODSale:::"+ query);
			Hashtable threeMODSale = du.getDataFromQueryPro2(query);
						
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),-6) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-1))  and it.item in ("+allProducts+") and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') group by sf.warehouse, it.item";
			//Utils.log("Query::sixPMOSalesForward:::"+ query);
			Hashtable sixPMOSalesForward = du.getDataFromQueryPro2(query);
			
			
			query="select ROUND(sum(sf.units),2) AS UNITS, sf.warehouse AS WAREHOUSE, it.item as ITEM from sales_fact sf, item_dim it, sales_type_dim std where sf.item_key = it.item_key  and sf.summary_flag in ('S',' ') and sf.activity_date>=add_months(trunc(sysdate,'mm'),-11) and sf.activity_date<=last_day(add_months(trunc(sysdate,'mm'),-6))  and it.item in ("+allProducts+") and sf.sales_type_key = std.sales_type_key and std.transfer <> 1 and std.sales_type not in ('10DIRECT', '80DIRECT', '90DIRECT', 'DIRECT', 'TRANSFER') group by sf.warehouse, it.item";
			//Utils.log("Query::sixPMOSalesBackword:::"+ query);
			Hashtable sixPMOSalesBackword = du.getDataFromQueryPro2(query);
			
			query="select PRICE, SYSTEM_ID, item_or_pricecode as item from pricing where item_or_pricecode_flag = 'I'and price_type = 'L' and level_ = 2 and item_or_pricecode in ("+allProducts+") and start_date < sysdate and end_date > sysdate";
			//Utils.log("Queey::rooferPriceHash:::"+ query);
			Hashtable rooferPriceHash = du.getDataFromQueryPro2(query);
			
			st = con.createStatement();
			
			query = "select distinct  nvl(itd.item, it.item) as item, nvl(itd.description, it.description) as description, "+
					   " nvl(itd.uom, it.costing_uom) as uom, nvl(itd.major_product_group, it.price_code_major) as major_product_group, "+
		               " nvl(itd.minor_product_group, it.price_code_minor) as minor_product_group, nvl(itd.size_, it.size_) as size_ "+
		               " from item_dim itd right outer join item it on itd.item = it.item "+
		               " where it.item in ("+allProducts+") "; 
			
			Utils.log("query>>>>>"+ query);
			rs = st.executeQuery(query);
			
			while(rs.next()) {
				
				String product = Utils.removeNull(rs.getString("item"));
				String uom = Utils.removeNull(rs.getString("uom"));
				//double stdpack = Double.parseDouble(Utils.removeNull(rs.getString("stdpack")));
				String stdpack = (du.getFieldInfoPro2("select distinct so_min_pack from item_content_def_branch where item = '"+product+"'"));
				double stdpack_d=Double. parseDouble(stdpack);
				String minpack = (du.getFieldInfoPro2("select min_pak from item it,item_supplier its where it.item in ('"+product+"') and it.item_ptr=its.item_ptr and its.system_id='00CORP' and its.primary_='1'"));
				
				stdpack= String.format("%.2f", stdpack_d); 
				String description = rs.getString("description");
				String productMajor = rs.getString("major_product_group");
				String productMinor = rs.getString("minor_product_group");
				String size = rs.getString("size_");
				
				String extDescription = du.getFieldInfoPro2("select ext_description from item where item='"+product+"'");
				if(extDescription.length()>65)
				extDescription=extDescription.substring(0,64);
				//System.out.println(size+":::"+extDescription);
			
				st2 = con.createStatement();
				//String query2 = "select * from qty_total where item in ("+allProducts+") and system_id='"+warehouse+"'";
				//String query2 = "select * from qty_total where item='"+product+"'";
				String query2="select system_id,item,qty_type, nvl(qty,0) as qty from qty_total where item='"+product+"'";
				Utils.log("query2>>>>>"+ query2);
				rs2 = st2.executeQuery(query2);
				
				String[] WareHouseName= {"PHX","MES","TUC","PRS","SCD","PLC","SNB","SNM","SPV","PSP","LEL","LSV","ALB"};
				
				
				JSONObject availableQty= new JSONObject();
				JSONObject onHandQty= new JSONObject();
				JSONObject committedQty= new JSONObject();
				JSONObject ooQty= new JSONObject();
				JSONObject boQty= new JSONObject();
				JSONObject salesPer= new JSONObject();
				JSONObject threePMOSales= new JSONObject();
				JSONObject threePMOSalesFwd= new JSONObject();
				JSONObject threePMOSalesBwd= new JSONObject();
				
				JSONObject threeMODSales= new JSONObject();
				JSONObject sixPMOSales= new JSONObject();
				JSONObject sixPMOSalesFwd= new JSONObject();
				JSONObject sixPMOSalesBwd= new JSONObject();
				
				JSONObject rooferPrice= new JSONObject();
				JSONObject activityCost= new JSONObject();
				JSONObject activityDate= new JSONObject();
				
				for(int i=0;i<WareHouseName.length;i++)
				{
					availableQty.put(WareHouseName[i],"0");
					onHandQty.put(WareHouseName[i],"0");
					committedQty.put(WareHouseName[i],"0");
					ooQty.put(WareHouseName[i],"0");
					boQty.put(WareHouseName[i],"0");
					salesPer.put(WareHouseName[i],"0");
					threePMOSales.put(WareHouseName[i],"X/X");
					threePMOSalesFwd.put(WareHouseName[i],"0");
					threePMOSalesBwd.put(WareHouseName[i],"0");
					threeMODSales.put(WareHouseName[i],"0");
					sixPMOSales.put(WareHouseName[i],"X/X");
					sixPMOSalesFwd.put(WareHouseName[i],"0");
					sixPMOSalesBwd.put(WareHouseName[i],"0");
					rooferPrice.put(WareHouseName[i],"0");
					activityCost.put(WareHouseName[i],"0.00");
					activityDate.put(WareHouseName[i],"");
				}
				
				
				while(rs2.next()) {
					boolean flag = false;
					String system_id =rs2.getString("system_id");
					if (rs2.getString("qty_type").equalsIgnoreCase("On Order")) {
						//totalOOQty += Double.parseDouble(Utils.removeNull(rs2.getString("qty")));
						for(int i=0;i<WareHouseName.length;i++)
						{
							if(system_id.contains(WareHouseName[i]))
							{
								ooQty.remove(WareHouseName[i]);
								//ooQty.put(WareHouseName[i],rs2.getString("qty"));
								ooQty.put(WareHouseName[i],Long.toString(Math.round(Double.parseDouble(rs2.getString("qty")))));
							}
						}
					}
					if (rs2.getString("qty_type").equalsIgnoreCase("Committed")) {
						
						for(int i=0;i<WareHouseName.length;i++)
						{
							if(system_id.contains(WareHouseName[i]))
							{
								committedQty.remove(WareHouseName[i]);
								//committedQty.put(WareHouseName[i],rs2.getString("qty"));
								committedQty.put(WareHouseName[i],Long.toString(Math.round(Double.parseDouble(rs2.getString("qty")))));
								//Utils.log(WareHouseName[i]+":"+rs2.getString("qty"));
							}
						}
						
					}
					
					
					
					
					
					
					if (rs2.getString("qty_type").equalsIgnoreCase("On Hand")) {
						
						for(int i=0;i<WareHouseName.length;i++)
						{
							if(system_id.contains(WareHouseName[i]))
							{
								onHandQty.remove(WareHouseName[i]);
								//onHandQty.put(WareHouseName[i],rs2.getString("qty"));
								onHandQty.put(WareHouseName[i],Long.toString(Math.round(Double.parseDouble(rs2.getString("qty")))));
							}
						}
						
					}
					if (rs2.getString("qty_type").equalsIgnoreCase("Backordered")) {
						
						for(int i=0;i<WareHouseName.length;i++)
						{
							if(system_id.contains(WareHouseName[i]))
							{
								boQty.remove(WareHouseName[i]);
								//boQty.put(WareHouseName[i],rs2.getString("qty"));
								boQty.put(WareHouseName[i],Long.toString(Math.round(Double.parseDouble(rs2.getString("qty")))));
							}
						}
						
					}
				}
				
				for(int i=0;i<WareHouseName.length;i++)
				{
					
					
					long available=0;
					available=Math.round(Double.parseDouble(onHandQty.get(WareHouseName[i]).toString())) - Math.round(Double.parseDouble(committedQty.get(WareHouseName[i]).toString()));
					availableQty.remove(WareHouseName[i]);
					availableQty.put(WareHouseName[i],Long.toString(available));
					
					
				}
				
				
				Utils.log("salesPerUnit>>>>"+ salesPerUnit.size());
				if (salesPerUnit!= null && salesPerUnit.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) salesPerUnit.get("ITEM");
					whse = (Vector) salesPerUnit.get("WAREHOUSE");
					units = (Vector) salesPerUnit.get("UNITS");
					Utils.log("whse>>>>"+ whse);
					if (whse != null) {
						Utils.log("whse size>>>>"+ whse.size());
						for(int i =0;i<whse.size();i++){
							if (item.get(i).toString().equals(product)) {
								//Utils.log("whse.get(i).toString()>>>"+ whse.get(i).toString());
								
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										salesPer.remove(WareHouseName[i2]);
										//salesPer.put(WareHouseName[i2],units.get(i).toString());
										salesPer.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
								
							}
						}
					}
				}
				
				// threePMOSalesForward
				if (threePMOSalesForward!= null && threePMOSalesForward.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) threePMOSalesForward.get("ITEM");
					whse = (Vector) threePMOSalesForward.get("WAREHOUSE");
					units = (Vector) threePMOSalesForward.get("UNITS");
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("threePMOSalesForward>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							if (item.get(i).toString().equals(product)) {
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										threePMOSalesFwd.remove(WareHouseName[i2]);
										//threePMOSalesFwd.put(WareHouseName[i2],units.get(i).toString());
										threePMOSalesFwd.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
							}
						}
					}
				}
				
				// threePMOSalesBackword
				if (threePMOSalesBackword!= null && threePMOSalesBackword.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) threePMOSalesBackword.get("ITEM");
					whse = (Vector) threePMOSalesBackword.get("WAREHOUSE");
					units = (Vector) threePMOSalesBackword.get("UNITS");
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("threePMOSalesBackword>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							if (item.get(i).toString().equals(product)) {
								
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										threePMOSalesBwd.remove(WareHouseName[i2]);
										//threePMOSalesBwd.put(WareHouseName[i2],units.get(i).toString());
										threePMOSalesBwd.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
							}
						}
					}
				}
				
				
				// threeMODSale
				if (threeMODSale!= null && threeMODSale.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) threeMODSale.get("ITEM");
					whse = (Vector) threeMODSale.get("WAREHOUSE");
					units = (Vector) threeMODSale.get("UNITS");
					Utils.log("ITEM="+item);
					Utils.log("whse="+whse);
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("threeMODSale>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							Utils.log("i="+i+" whse.size()="+whse.size()+" item.size()="+item.size());
							if (item.get(i).toString().equals(product)) {
								
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										threeMODSales.remove(WareHouseName[i2]);
										//threeMODSales.put(WareHouseName[i2],units.get(i).toString());
										Utils.log("i="+i+" i2="+i2);
										threeMODSales.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
								
							}
						}
					}
				}
				
				//sixPMOSalesForward
				
				if (sixPMOSalesForward!= null && sixPMOSalesForward.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) sixPMOSalesForward.get("ITEM");
					whse = (Vector) sixPMOSalesForward.get("WAREHOUSE");
					units = (Vector) sixPMOSalesForward.get("UNITS");
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("sixPMOSalesForward>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							if (item.get(i).toString().equals(product)) {
								
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										sixPMOSalesFwd.remove(WareHouseName[i2]);
										//Utils.log("units.get(i)"+units.get(i));
										/*
										String sdata=units.get(i).toString();
										long ddata=Math.round(Double.parseDouble(sdata));
										sixPMOSalesFwd.put(WareHouseName[i2],ddata);
										//sixPMOSalesFwd.put(WareHouseName[i2],units.get(i));
										*/
										sixPMOSalesFwd.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
							}
						}
					}
				}
				
				// sixPMOSalesBackword
				if (sixPMOSalesBackword!= null && sixPMOSalesBackword.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) sixPMOSalesBackword.get("ITEM");
					whse = (Vector) sixPMOSalesBackword.get("WAREHOUSE");
					units = (Vector) sixPMOSalesBackword.get("UNITS");
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("sixPMOSalesBackword>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							if (item.get(i).toString().equals(product)) {
								
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										sixPMOSalesBwd.remove(WareHouseName[i2]);
										//sixPMOSalesBwd.put(WareHouseName[i2],Math.round((float) units.get(i)));
										//sixPMOSalesBwd.put(WareHouseName[i2],units.get(i));
										/*
										String sdata=units.get(i).toString();
										long ddata=Math.round(Double.parseDouble(sdata));
										sixPMOSalesBwd.put(WareHouseName[i2],ddata);
										*/
										sixPMOSalesBwd.put(WareHouseName[i2],Long.toString(Math.round(Double.parseDouble(units.get(i).toString()))));
									}
								}
							}
						}
					}
				}
				
				// Roofer price::::::::::::
				
				
				if (rooferPriceHash!= null && rooferPriceHash.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector units = new Vector(1,1);
					Vector item = new Vector(1,1);
					item = (Vector) rooferPriceHash.get("ITEM");
					whse = (Vector) rooferPriceHash.get("SYSTEM_ID");
					units = (Vector) rooferPriceHash.get("PRICE");
					if (whse != null) {
						for(int i =0;i<whse.size();i++){
							//Utils.log("Roofer Price>>>>item.get(i).toString()>>>>>"+ item.get(i).toString());
							if (item.get(i).toString().equals(product)) {
								for(int i2=0;i2<WareHouseName.length;i2++)
								{
									if(whse.get(i).toString().contains(WareHouseName[i2]))
									{
										rooferPrice.remove(WareHouseName[i2]);
										rooferPrice.put(WareHouseName[i2],units.get(i).toString());
									}
								}
							}
						}
					}
				}
				
				for(int i=0;i<WareHouseName.length;i++)
				{
					String temp="";
					temp=(threePMOSalesFwd.get(WareHouseName[i])) +"/"+ (threePMOSalesBwd.get(WareHouseName[i]));
					threePMOSales.remove(WareHouseName[i]);
					threePMOSales.put(WareHouseName[i],temp);
					
					temp=(sixPMOSalesFwd.get(WareHouseName[i])) +"/ "+ (sixPMOSalesBwd.get(WareHouseName[i]));
					sixPMOSales.remove(WareHouseName[i]);
					sixPMOSales.put(WareHouseName[i],temp);
				}
				
				// Activity cost and date::::::::::::
				
				//Utils.log("Query::activityHash:::"+ "select distinct ia.system_id as SYSTEM_ID, ACTIVITY_DATE, nvl(ACTIVITY_COST,0) as ACTIVITY_COST from item_activity ia, item it where ia.item_ptr = it.item_ptr and ia.type='RV' and it.item='"+product+"' order by ia.system_id, ia.activity_date desc");
				Hashtable activityHash = du.getDataFromQueryPro2("select distinct ia.system_id as SYSTEM_ID, ACTIVITY_DATE, nvl(ACTIVITY_COST,0) as ACTIVITY_COST from item_activity ia, item it where ia.item_ptr = it.item_ptr and ia.type='RV' and it.item='"+product+"' order by ia.system_id, ia.activity_date desc");
				if (activityHash!= null && activityHash.size() > 0) {
					Vector whse = new Vector(1,1);
					Vector activityCostV = new Vector(1,1);
					Vector activityDateV = new Vector(1,1);
					whse = (Vector) activityHash.get("SYSTEM_ID");
					activityCostV = (Vector) activityHash.get("ACTIVITY_COST");
					activityDateV = (Vector) activityHash.get("ACTIVITY_DATE");
					if (whse != null) {
						String innerWhse = "";
						for(int i =0;i<whse.size();i++){
							if (!innerWhse.equals(whse.get(i).toString())) {
									for(int i2=0;i2<WareHouseName.length;i2++)
									{
										if(whse.get(i).toString().contains(WareHouseName[i2]))
										{
											
											activityCost.remove(WareHouseName[i2]);
											//activityCost.put(WareHouseName[i2],activityCostV.get(i));
											
											activityCost.put(WareHouseName[i2],Utils.getDoublePatternMaskNoParenthesis(Double.parseDouble(activityCostV.get(i).toString()),2));
											//Utils.getDoublePatternMaskNoParenthesis(Double.parseDouble(activityCostV.get(i).toString()),2)
											
											activityDate.remove(WareHouseName[i2]);
											activityDate.put(WareHouseName[i2],activityDateV.get(i));
										}
									}
							}
							innerWhse = whse.get(i).toString();
						}
					}
				}
				
				//Calculate Lead Days New Requirement
				JSONObject jLead =new JSONObject();
				jLead.put("Product",product);
				jLead.put("Description",description);
				jLead.put("Negative","F");
				//Description
				for(int i=0;i<WareHouseName.length;i++)
				{
					
					float oneDaySale=(float)threePMOSalesFwd.getInt(WareHouseName[i])/90;
					int addedDays=manDate+leadDays;
					int addedDaysSales=(int) (addedDays*oneDaySale);
					int shipQtyNeeded=(availableQty.getInt(WareHouseName[i])+ ooQty.getInt(WareHouseName[i])) -addedDaysSales;
					jLead.put(WareHouseName[i],Integer.toString(shipQtyNeeded));	
					
					//Utils.log("Product="+product+"\nWareHouseName="+WareHouseName[i]+"\naddedDay="+addedDays+"\noneDaySale="+oneDaySale+"\naddedDaysSales="+addedDaysSales+"\nshipQtyNeeded="+shipQtyNeeded);
					
				}
				
				// Total Calculation :::
				int totalAvailable=0;
				int totalOnHand=0;
				int totalCommited=0;
				int totalonOrder=0;
				int totalBackOrder=0;
				int totalSales=0;
				int total3PMOFwd=0;
				int total3PMOBwd=0;
				int total3MOD=0;
				int total6PMOFwd=0;
				int total6PMOBwd=0;
				int totalDays=0;
				//double totalRoofer=0;
				
				for(int i=0;i<WareHouseName.length;i++)
				{
					totalAvailable+=Integer.parseInt(availableQty.get(WareHouseName[i]).toString());
					totalOnHand+=Integer.parseInt(onHandQty.get(WareHouseName[i]).toString());
					totalCommited+=Integer.parseInt(committedQty.get(WareHouseName[i]).toString());
					totalonOrder+=Integer.parseInt(ooQty.get(WareHouseName[i]).toString());
					totalBackOrder+=Integer.parseInt(boQty.get(WareHouseName[i]).toString());
					
					totalSales+=Integer.parseInt(salesPer.get(WareHouseName[i]).toString());
					total3PMOFwd+=Integer.parseInt(threePMOSalesFwd.get(WareHouseName[i]).toString());
					total3PMOBwd+=Double.parseDouble(threePMOSalesBwd.get(WareHouseName[i]).toString());
					
					total3MOD+=Integer.parseInt(threeMODSales.get(WareHouseName[i]).toString());
					
					total6PMOFwd+=Integer.parseInt(sixPMOSalesFwd.get(WareHouseName[i]).toString());
					total6PMOBwd+=Integer.parseInt(sixPMOSalesBwd.get(WareHouseName[i]).toString());
					totalDays+=Integer.parseInt(jLead.get(WareHouseName[i]).toString());
				}
				//Handle Negative value of Lead Days
				for(int i=0;i<WareHouseName.length;i++)
				{
					if(Integer.parseInt(jLead.get(WareHouseName[i]).toString())<0)
					{
						jLead.put("Negative", "T");
					}
				}
				
				jLead.put("Total", Integer.toString(totalDays));
				availableQty.put("Total", Integer.toString(totalAvailable));
				onHandQty.put("Total", Integer.toString(totalOnHand));
				committedQty.put("Total", Integer.toString(totalCommited));
				ooQty.put("Total", Integer.toString(totalonOrder));
				boQty.put("Total", Integer.toString(totalBackOrder));
				salesPer.put("Total", Integer.toString(totalSales));
				threePMOSalesFwd.put("Total", Integer.toString(total3PMOFwd));
				threePMOSalesBwd.put("Total", Integer.toString(total3PMOBwd));
				threeMODSales.put("Total", Integer.toString(total3MOD));
				sixPMOSalesFwd.put("Total", Integer.toString(total6PMOFwd));
				sixPMOSalesBwd.put("Total", Integer.toString(total6PMOBwd));
				threePMOSales.put("Total", threePMOSalesFwd.get("Total")+"/"+threePMOSalesBwd.get("Total"));
				sixPMOSales.put("Total", sixPMOSalesFwd.get("Total")+"/ "+sixPMOSalesBwd.get("Total"));
				rooferPrice.put("Total", "");
				activityCost.put("Total", "");
				activityDate.put("Total", "");
				
				availableQty.put("Label", "Available");
				onHandQty.put("Label", "On Hand");
				committedQty.put("Label", "Committed");
				ooQty.put("Label", "O/O VEND");
				boQty.put("Label", "BO Qty");
				salesPer.put("Label", "PER SALES");
				threePMOSales.put("Label", "3/P-MO SALES");
				threeMODSales.put("Label", "3 MO D SALES");
				sixPMOSales.put("Label", "6/P-MO SALES");
				rooferPrice.put("Label", "ROOFER PRICE");
				activityCost.put("Label", "RECVD COST");
				activityDate.put("Label", "LST REC DT");
				
				// if(true)break;
				JSONObject jsonRecord=new JSONObject();
				Field changeMap = jsonRecord.getClass().getDeclaredField("map");
				
			      changeMap.setAccessible(true);
			      changeMap.set(jsonRecord, new LinkedHashMap<>());
			      changeMap.setAccessible(false);
			      
				jsonRecord.put("Product#", product);
				jsonRecord.put("UM", uom);
				jsonRecord.put("StdPack", stdpack);
				jsonRecord.put("MinPack", minpack);
				jsonRecord.put("Description", description);
				jsonRecord.put("ProductMajor", productMajor);
				jsonRecord.put("ProductMinor", productMinor);
				jsonRecord.put("Size", size);
				jsonRecord.put("DescriptionExt", extDescription);
				//jsonRecord.put("ReportName", reportCode);
				
				jsonRecord.put("Available", availableQty);
				jsonRecord.put("OnHand", onHandQty);
				jsonRecord.put("Committed", committedQty);
				jsonRecord.put("OnOrder", ooQty);
				jsonRecord.put("BackOrder", boQty);
				jsonRecord.put("SalesPer", salesPer);
				jsonRecord.put("3PMO", threePMOSales);
				jsonRecord.put("3MOD", threeMODSales);
				jsonRecord.put("6PMO", sixPMOSales);
				jsonRecord.put("RooferPrice", rooferPrice);
				jsonRecord.put("ActivityCost", activityCost);
				jsonRecord.put("ActivityDate", activityDate);
				
				
				
				jArray.put(jsonRecord);
				jArrayLead.put(jLead);
				
			}
			
			returnJSON.put("ProductData", jArray);
			returnJSON.put("ReportName", reportDesc);
			returnJSON.put("LeadData", jArrayLead);
			returnJSON.put("ManDate", manDate);
			returnJSON.put("LeadDays", leadDays);
			
			Utils.log("##JsonData##"+returnJSON);
			//mainObject.add(htmlStr.toString());
			Utils.close(st);
			Utils.close(rs);
			Utils.close(st2);
			Utils.close(rs2);
			Utils.close(con);
			
		} catch (Exception e) {
			System.out.println("##"+jsonArray);
			Utils.log("Exception ", e);
			e.printStackTrace();
		} finally {	  
			
			Utils.close(st);
			Utils.close(rs);
			Utils.close(st2);
			Utils.close(rs2);
			Utils.close(con);
			   
		}
		Utils.log("IVRptWarehouseReportTwo.showWarehouseReport");
		mainObject.put("message", message);
		mainObject.put("data", jsonArray);
		return returnJSON.toString();
		
		
		
	}

	static String extractPostRequestBody(HttpServletRequest request) throws Exception {
		if ("POST".equalsIgnoreCase(request.getMethod())) {
			Scanner s = new Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
			return s.hasNext() ? s.next() : "";
		}
		return "";
	}
}
