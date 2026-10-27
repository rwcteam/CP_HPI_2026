package com.etechlogix.distribution.so.servlet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.utils.Utils;

public class OrderDeliveryImageSearchDao {

	private DistUtils du=null;
	
	public List<HashMap<String, String>> getCustomerDetailsWithDistUtils(HttpServletRequest request,String orderId,String shipmentId) 
	{
		HttpSession session = request.getSession();
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		List<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		
		try {
			du=DistUtils.getDistUtils(session);
			con=du.getPro2DataConnection();
			sqlQuery = "select sh.so_id, sh.SHIPMENT_NUM,sh.driver, sa.CUST_NAME, sa.ADDRESS_1, sa.ADDRESS_2, sa.city, sa.ZIP, sh.SHIP_DATE, sh.SHIP_VIA "
					+ " from shipments_header sh, SHIP_TO_ADDRESS sa "
					+ " where sh.SHIPMENTS_HEADER_GUID=sa.TRAN_guID and sh.SO_ID=? and sh.SHIPMENT_NUM=? " ;
			Utils.log("Query " + sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, orderId);
			pstmt.setString(2, shipmentId);
			rs=pstmt.executeQuery();
			Utils.log("Result Set " + rs);

			
			while(rs.next()) {
				temp=new HashMap<String, String>();
				temp.put("soId", rs.getString(1));
				temp.put("shipmentNo", rs.getString(2));
				temp.put("driver", rs.getString(3));
				temp.put("customerName", rs.getString(4));
				temp.put("addressOne", rs.getString(5));
				temp.put("addressTwo", rs.getString(6));
				temp.put("city", rs.getString(7));
				temp.put("zip", rs.getString(8));
				temp.put("shipDate", rs.getString(9));
				temp.put("shipVia", rs.getString(10));
				listData.add(temp);
			}
		
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}finally {
			Utils.close(con);
			Utils.close(rs);
			Utils.close(pstmt);				
		}
		return listData;
	}

	public List<HashMap<String, Object>> getImageListWithDistUtils(HttpServletRequest request,String orderNo,String shipmentNo)
	{
		String sqlQuery="";
		Connection con = null;
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		HttpSession session = request.getSession();
		
		List<HashMap<String, Object>> imageList=new ArrayList<HashMap<String,Object>>();
		HashMap<String, Object> mapData=null;
		String imgUrl = "https://reg2.rwc.org/MobileService/OrderImage/1-531909-1/1-531909-1-0";
		int i = 0;
		
		try {
			du=DistUtils.getDistUtils(session);
			con=du.getConnection();
			sqlQuery=" select COMPANYID,USERID,IMGTYPE,DELIMG,CREATED,SLNO "
					+ " from MOB_CONFIRM_IMG where ORDERID=? and SHIPMENTID=? " ;
			Utils.log("Query " + sqlQuery);
			pstmt = con.prepareStatement(sqlQuery); 
			pstmt.setString(1, orderNo);
			pstmt.setString(2, shipmentNo);
			rs=pstmt.executeQuery();
			Utils.log("Result Set " + rs);

			while(rs.next()) {
				mapData=new HashMap<String, Object>();
				mapData.put("companyId", rs.getString("COMPANYID"));
				mapData.put("userId", rs.getString("USERID"));
				mapData.put("imgType", rs.getString("IMGTYPE"));

				String j = i+"";
				String finalImgUrl = imgUrl+j+".jpg";
				
				mapData.put("delImg", finalImgUrl);
				mapData.put("created", rs.getString("CREATED"));
				mapData.put("slNo", rs.getString("SLNO"));
				imageList.add(mapData);
				i++;
			}
			
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}finally {
			Utils.close(con);
			Utils.close(rs);
			Utils.close(pstmt);				
		}
		return imageList;

	}

	
	
	
}
