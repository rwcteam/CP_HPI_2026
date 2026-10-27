package com.db;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public final class DBConnection {
	
	private DBConnection(){}

	public synchronized static Connection getConnection() throws Exception {     

		Connection con=null;	
		try{
			con=getConnectionWithoutPool();
		}catch(Exception ex){
			ex.printStackTrace();		 
		}
		return con;
	}

	public static Connection getConnectionWithoutPool() throws Exception {
		Connection con = null;
		String username = "",password = "",url = "",driver = "";
		try{          
			driver="com.microsoft.sqlserver.jdbc.SQLServerDriver"; 
			url="jdbc:sqlserver://localhost:1433;databasename=test_db;sendStringParametersAsUnicode=false"; 
			username="sa";
			password="master";
			Class.forName(driver);
			con= DriverManager.getConnection(url,username,password);
		}catch(Exception ex){
			ex.printStackTrace();	
		}
		return con;
	}
	/**close Connection*/
	public synchronized static void closeCon(Connection con,ResultSet rs,Statement stmt,PreparedStatement pstmt, CallableStatement cstmt){
		try{	
			if(stmt!=null)
				stmt.close();
			if(pstmt!=null)
				pstmt.close();
			if(cstmt!=null)
				cstmt.close();
			if(rs!=null)
				rs.close();
			if(con!=null)
			con.close();			
		
		}catch (Exception Ex){
			System.out.println("Error is closing the connection");
			con=null;
		}
	}
}