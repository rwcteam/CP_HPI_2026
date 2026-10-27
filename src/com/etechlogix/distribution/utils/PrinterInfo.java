package com.etechlogix.distribution.utils;
import com.etechlogix.distribution.utils.*;
import com.etechlogix.utils.*;

import java.util.*;
import java.sql.*;
import java.io.*;
/**
 * Title:        RWC
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:      eTechlogix  System India (P) Ltd
 * @author ashif ali
 * @version 1.0
 */

public class PrinterInfo implements Serializable{

  	private Vector allPrinterName;
		private Vector allPrinterAddress;
		private Vector allPrinterId;
		private Vector allPrinterLocation;
		private String printerName;
		private String printerAddress;


  public PrinterInfo()throws Exception {

    	allPrinterName=new Vector(1,1);
		allPrinterAddress=new Vector(1,1);
		allPrinterId=new Vector(1,1);
		allPrinterLocation=new Vector(1,1);
		printerName="";
		printerAddress="";
		setPrinterNames();


  }
  public PrinterInfo(String printerType)throws Exception {

  	allPrinterName=new Vector(1,1);
		allPrinterAddress=new Vector(1,1);
		allPrinterId=new Vector(1,1);
		allPrinterLocation=new Vector(1,1);
		printerName="";
		printerAddress="";
		setDotMatrixPrinterNames();


}

	/* method to get printer names from printer table */
  public void setPrinterNames()throws Exception{
     Statement st=null;
     Connection con=null;
     ResultSet rs=null;
      DistUtils du=new DistUtils();
      try{
        con=du.getDataConnection();
        st=con.createStatement();
        rs=st.executeQuery("select * from printer where printername is not null and printerType='L'");
        while(rs.next()){
          allPrinterName.add(rs.getString("printername"));
          allPrinterAddress.add(rs.getString("printeraddress"));
          allPrinterLocation.add(rs.getString("printerlocation"));
          allPrinterId.add(rs.getString("printerid"));
        }
		}
      catch(SQLException se){
				throw new Exception("Caught in PrintInfo:print Query"+se);
      }
      finally{
        Utils.close(rs);
        Utils.close(st);
        Utils.close(con);
     }
  }
  public void setDotMatrixPrinterNames()throws Exception{
	     Statement st=null;
	     Connection con=null;
	     ResultSet rs=null;
	      DistUtils du=new DistUtils();
	      try{
	        con=du.getDataConnection();
	        st=con.createStatement();
	        rs=st.executeQuery("select * from printer where printername is not null and printerType='D'");
	        while(rs.next()){
	          allPrinterName.add(rs.getString("printername"));
	          allPrinterAddress.add(rs.getString("printeraddress"));
	          allPrinterLocation.add(rs.getString("printerlocation"));
	          allPrinterId.add(rs.getString("printerid"));
	        }
			}
	      catch(SQLException se){
					throw new Exception("Caught in PrintInfo:print Query"+se);
	      }
	      finally{
	        Utils.close(rs);
	        Utils.close(st);
	        Utils.close(con);
	     }
	  }


       /**
    * Returns Printer Names
    * @param in void
    * @param out  Vector.
    *     * */

    public String getPrinterName(String printerId){
		  int index=allPrinterId.indexOf(printerId);
			printerName=(String)allPrinterName.get(index);
			return printerName;
    }

    public String getPrinterAddress(String printerId){
          int index=allPrinterId.indexOf(printerId);
          printerAddress=(String)allPrinterAddress.get(index);
          return printerAddress;
    }

    public Vector getPrinterLocation(){
      return allPrinterLocation;
    }

    public Vector getPrinterId(){
      return allPrinterId;
    }

    public String getUserDefPerPrinter(String userId)throws Exception{
        DistUtils du=new DistUtils();
        String userDefPerPrinter="";
        String query="";
        query="select defaultpersonalprinter from etechuser where userid='"+userId+"' ";
        userDefPerPrinter=du.getFieldInfo(query);
        return userDefPerPrinter;
    }

    public String getDefInvoicePrinter(String companyId,String warehouse)throws Exception{
        DistUtils du=new DistUtils();
        String defInvoicePrinter="";
        String query="";
        query="select defaultinvoiceprinter from warehouse where companyid='"+companyId+"' and warehouse='"+warehouse+"'  ";
        defInvoicePrinter=du.getFieldInfo(query);
        return defInvoicePrinter;
    }

    public Vector getAllPrinterForWarehouse(String companyId,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vPrinter=new Vector(5,5);
        Hashtable ht=new Hashtable();
        String query="";
        query="select printerId from Printer where companyid='"+companyId+"' and warehouse='"+warehouse+"'  and printerType='L'";
        ht=du.getDataFromQuery(query);
        if(ht!=null){
            vPrinter=(Vector)ht.get("PRINTERID");
        }
        return vPrinter;
    }
    public Vector getPickticketPrinter(String companyId,String userid,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vPrinter=new Vector(5,5);
        Hashtable ht=new Hashtable();
        String query="";
        if(warehouse.equalsIgnoreCase("All")){
        	warehouse="'PHX','ALB','MES','LSV','MCW','PLC','PRS','PSP','SCD','SNB','SNM','SPV','TUC'";
        }else{
        	warehouse="'"+warehouse+"'";
        }
        query="select printerId from Printer where companyid='"+companyId+"' and warehouse in("+warehouse+")  and printertype='L' ";
        ht=du.getDataFromQuery(query);
        if(ht!=null){
            vPrinter=(Vector)ht.get("PRINTERID");
        }
        return vPrinter;
    }
    
    public Vector getPickticketPrinterOE1(String companyId,String userid,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vPrinter=new Vector(5,5);
        Hashtable ht=new Hashtable();
        String query="";
        if(warehouse.equalsIgnoreCase("All")){
        	warehouse="'PHX','ALB','MES','LSV','MCW','PLC','PRS','PSP','SCD','SNB','SNM','SPV','TUC'";
        }
        
     /*   else{
        	warehouse="'"+warehouse+"'";
        }*/
        query="select printerId from Printer where companyid='"+companyId+"' and warehouse in("+warehouse+")  and printertype='L' ";
        ht=du.getDataFromQuery(query);
        if(ht!=null){
            vPrinter=(Vector)ht.get("PRINTERID");
        }
        return vPrinter;
    }
    
    public Vector getAllDotMatrixPrinterForWarehouse(String companyId,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vPrinter=new Vector(5,5);
        Hashtable ht=new Hashtable();
        String query="";
        query="select printerId from Printer where companyid='"+companyId+"' and warehouse='"+warehouse+"'  and printerType='D' ";
        ht=du.getDataFromQuery(query);
        if(ht!=null){
            vPrinter=(Vector)ht.get("PRINTERID");
        }
        return vPrinter;
    }
    public Vector getAllPrinterInOEFormat(String companyId,String userId,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vFinalPrinter=new Vector(5,5);
        String defInvoicePrinter="";
        String defUserPrinter="";
        Vector vWarehousePrinter=new Vector(5,5);
        Vector vAllPrinter=new Vector(5,5);
//fetching default invoice printer from warehouse
     //   defInvoicePrinter = Utils.removeNull(getDefInvoicePrinter(companyId,warehouse));
//fetching all printer for given warehouse
        vWarehousePrinter = getAllPrinterForWarehouse(companyId,warehouse);
//fetching default personal printer for user
    //    defUserPrinter=Utils.removeNull(getUserDefPerPrinter(userId));
//fetch all printer from printer table
    //    vAllPrinter=getPrinterId();
//adding default invoice printer in final
     //   if(!defInvoicePrinter.equals("")) {
     //       vFinalPrinter.add(defInvoicePrinter);
     //   }
//        Utils.log("userId " +userId);
//        Utils.log("warehouse " +warehouse);
//        Utils.log("defInvoicePrinter "+defInvoicePrinter);

        if(vWarehousePrinter!=null){
        int size=vWarehousePrinter.size();
        for(int i=0;i<size;i++){
            if(!defInvoicePrinter.equals(Utils.removeNull((String)vWarehousePrinter.get(i)))){
//                Utils.log("adding in final for warehouse "+(String)vWarehousePrinter.get(i));
                vFinalPrinter.add(Utils.removeNull((String)vWarehousePrinter.get(i)));
            } //end of if
        } //end of for
        }//end of vWarehousePrinter null
//        Utils.log("defUserPrinter "+defUserPrinter);
        if(!defUserPrinter.equals("")) {
        int size=vFinalPrinter.size();
        boolean temp=true;
        for(int i=0;i<size;i++){
            if(defUserPrinter.equals(Utils.removeNull((String)vFinalPrinter.get(i)))){
                temp=false;
            } //end of if
        } //end of for
        if(temp==true){
//            Utils.log("adding for user "+defUserPrinter);
            vFinalPrinter.add(defUserPrinter);
        }
        }

        if(vAllPrinter!=null){
        int size=vAllPrinter.size();
//        Utils.log("size "+size);
        for(int i=0;i<size;i++){
            int finalSize= vFinalPrinter.size();
            boolean temp=true;
            for(int j=0;j<finalSize;j++){
//                Utils.log("compare in all");
//                Utils.log("(String)vFinalPrinter.get(j) "+(String)vFinalPrinter.get(j));
//                Utils.log("Utils.removeNull((String)vAllPrinter.get(i)) "+Utils.removeNull((String)vAllPrinter.get(i)));

                if((Utils.removeNull((String)vFinalPrinter.get(j))).equals(Utils.removeNull((String)vAllPrinter.get(i)))){
//                    Utils.log("same");
                    temp=false;
                    break;
                } //end of if
            }
            if(temp==true){
//                Utils.log("adding in final for all "+(String)vAllPrinter.get(i));
                vFinalPrinter.add(Utils.removeNull((String)vAllPrinter.get(i)));
            }
        } //end of for
       }//end of vWarehousePrinter null

        return vFinalPrinter;
    }
    public Vector getAllDotMatrixPrinter(String companyId,String userId,String warehouse) throws Exception{
        DistUtils du=new DistUtils();
        Vector vFinalPrinter=new Vector(5,5);
        String defInvoicePrinter="";
        String defUserPrinter="";
        Vector vWarehousePrinter=new Vector(5,5);
        Vector vAllPrinter=new Vector(5,5);
//fetching default invoice printer from warehouse
        defInvoicePrinter = Utils.removeNull(getDefInvoicePrinter(companyId,warehouse));
//fetching all printer for given warehouse
        vWarehousePrinter = getAllDotMatrixPrinterForWarehouse(companyId,warehouse);
//fetching default personal printer for user
        defUserPrinter=Utils.removeNull(getUserDefPerPrinter(userId));
//fetch all printer from printer table
        vAllPrinter=getPrinterId();
//adding default invoice printer in final
        if(!defInvoicePrinter.equals("")) {
            vFinalPrinter.add(defInvoicePrinter);
        }
//        Utils.log("userId " +userId);
//        Utils.log("warehouse " +warehouse);
//        Utils.log("defInvoicePrinter "+defInvoicePrinter);

        if(vWarehousePrinter!=null){
        int size=vWarehousePrinter.size();
        for(int i=0;i<size;i++){
            if(!defInvoicePrinter.equals(Utils.removeNull((String)vWarehousePrinter.get(i)))){
//                Utils.log("adding in final for warehouse "+(String)vWarehousePrinter.get(i));
                vFinalPrinter.add(Utils.removeNull((String)vWarehousePrinter.get(i)));
            } //end of if
        } //end of for
        }//end of vWarehousePrinter null
//        Utils.log("defUserPrinter "+defUserPrinter);
        if(!defUserPrinter.equals("")) {
        int size=vFinalPrinter.size();
        boolean temp=true;
        for(int i=0;i<size;i++){
            if(defUserPrinter.equals(Utils.removeNull((String)vFinalPrinter.get(i)))){
                temp=false;
            } //end of if
        } //end of for
        if(temp==true){
//            Utils.log("adding for user "+defUserPrinter);
            vFinalPrinter.add(defUserPrinter);
        }
        }

        if(vAllPrinter!=null){
        int size=vAllPrinter.size();
//        Utils.log("size "+size);
        for(int i=0;i<size;i++){
            int finalSize= vFinalPrinter.size();
            boolean temp=true;
            for(int j=0;j<finalSize;j++){
//                Utils.log("compare in all");
//                Utils.log("(String)vFinalPrinter.get(j) "+(String)vFinalPrinter.get(j));
//                Utils.log("Utils.removeNull((String)vAllPrinter.get(i)) "+Utils.removeNull((String)vAllPrinter.get(i)));

                if((Utils.removeNull((String)vFinalPrinter.get(j))).equals(Utils.removeNull((String)vAllPrinter.get(i)))){
//                    Utils.log("same");
                    temp=false;
                    break;
                } //end of if
            }
            if(temp==true){
//                Utils.log("adding in final for all "+(String)vAllPrinter.get(i));
                vFinalPrinter.add(Utils.removeNull((String)vAllPrinter.get(i)));
            }
        } //end of for
       }//end of vWarehousePrinter null

        return vFinalPrinter;
    }

    }