package com.etechlogix.distribution.so.servlet;

import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


//@WebServlet("/OrderDeliveryImageSearch")
public class OrderDeliveryImageSearchController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public void init( ){
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, java.io.IOException {
		
		try {
			String param = request.getParameter("param");
			
			if (param.equalsIgnoreCase("CustomersList")) {

				String result = "fail";
				String customerId = request.getParameter("customerId");
				if (customerId == null || customerId.equals("")) 
					customerId="";
				String orderId = request.getParameter("orderId");
				if (orderId == null || orderId.equals("")) 
					orderId="";
				String shipmentId = request.getParameter("shipmentId");
				if (shipmentId == null || shipmentId.equals("")) 
					shipmentId="";
				String fromDate = request.getParameter("fromDate");
				String toDate = request.getParameter("toDate");

				try {	
					OrderDeliveryImageSearchDao dao = new OrderDeliveryImageSearchDao();
					List<HashMap<String, String>> customerList = dao.getCustomerDetailsWithDistUtils(request,orderId,shipmentId);
					request.setAttribute("data", customerList);
					result = "success";

				} catch(Exception ex) {
					ex.printStackTrace();
				}

				if (result.equalsIgnoreCase("success")) { 
					RequestDispatcher rd = request.getRequestDispatcher("A_SOOrderDeliveryImageSearch.jsp");
			        rd.forward(request, response);
				}
				
			}
			else if (param.equalsIgnoreCase("fetchImages")) {

				PrintWriter out=response.getWriter();	
				String output="";
				String orderNo = request.getParameter("orderNo");
				String shipmentNo = request.getParameter("shipmentNo");
				
				OrderDeliveryImageSearchDao dao = new OrderDeliveryImageSearchDao();
				List<HashMap<String, Object>> imageList = dao.getImageListWithDistUtils(request,orderNo,shipmentNo);

				if(imageList==null || imageList.size()<=0){
					output="invalid";
				}
				else 
				{
					StringBuffer imageListBuffer=new StringBuffer();
					for(int i=0;i<imageList.size();i++){ 
						HashMap<String, Object> map=imageList.get(i);
						imageListBuffer.append("<li onclick=\"thumbsChange('"+map.get("documentFileName")+"')\"><img src='"+map.get("documentFileName")+"'></li>");
					}
					output=imageListBuffer.toString();
				}
				out.print(output);
				out.close();

			}
			
		} catch (Exception e) {
			e.getMessage();
		}
	
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, java.io.IOException {

		throw new ServletException("GET method used with " +
				getClass( ).getName( )+": POST method required.");
	}
}
