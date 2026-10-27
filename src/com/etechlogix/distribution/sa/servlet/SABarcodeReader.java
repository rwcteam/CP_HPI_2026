package com.etechlogix.distribution.sa.servlet;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.Iterator;
import java.util.List;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.pdfbox.multipdf.Splitter;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.graphics.image.LosslessFactory;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.tools.imageio.ImageIOUtil;
import org.apache.pdfbox.util.Matrix;
import org.json.JSONArray;
import org.json.JSONObject;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import com.etechlogix.utils.Utils;
import com.etechlogix.distribution.utils.CustomerInvoiceMailSend;
import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.distribution.mobileapp.servlet.S3_Upload;

import java.sql.*;
import java.util.*;
import java.io.*;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;
import org.json.*;

public class SABarcodeReader {

	public static String mainFolder = "/home/tomcat/barcode_reader";
	public static String inFolder = "inbox";
	public static String outFolder = "outbox";
	public static String processedFolder = "processed";
	public static String exceptionFolder = "exception";

	public String barcodeReader(HttpServletRequest request,String method ) {

		Connection con = null;
		Statement smt = null;
		HttpSession session = request.getSession();
		int processedPage=0;
		try {
			String companyId = DistUtils.getCompanyId(session);
			//Utils.log("companyId"+companyId);
			Utils.log("method="+method);// BULK or SINGLE
			
				
			File directoryPath = new File(mainFolder);
			DistUtils du = new DistUtils();
			con = du.getConnection();
			smt = con.createStatement();
			String query = "";
			int filecount = 0;
			int valid = 0;
			int invalid = 0;
			String flag = "";
			String OrderId = "0";
			int ShipmentId = 0;

			
			String warehousename = "";
			String pdfPath = "";
			String imagePath = "";
			String cropPath = "";
			String batchPath = "";
			Utils.log("directoryPath=" + directoryPath);
			File inboxPath = new File(mainFolder + "/" + inFolder);
			File processedPath = new File(mainFolder + "/" + processedFolder);
			String outboxPath=mainFolder + "/" + outFolder;
			String exceptionPath=mainFolder + "/" + exceptionFolder;
			File batchList[] = inboxPath.listFiles();
			int aa=batchList.length;
			S3_Upload su = new S3_Upload();
			String batchFilename="";
					for (File batchname : batchList) {
						processedPage=0;
						if(batchname.isDirectory())
						{
							continue;
						}
						Utils.log("Folder path: " + batchname.getAbsolutePath());
						
						batchFilename=batchname.getName();
						

						
						Utils.log("inboxPath=" + inboxPath.toString() + ":" + batchList.length);
						
						// System.out.println(" Folder File path: "+file2.getAbsolutePath());
						valid = 0;
						invalid = 0;
						String filename = batchname.getAbsolutePath();
						Utils.log("batchname=" + batchname);
						String ext = FilenameUtils.getExtension(batchname.getName());
						String batchno = FilenameUtils.getBaseName(batchname.getName());
						
						batchPath = processedPath + "/" + batchno;
						pdfPath = processedPath + "/" + batchno + "/pdf-";
						imagePath = processedPath + "/" + batchno + "/Image-";
						cropPath = processedPath + "/" + batchno + "/crop-";
						
						
						
						
						
						if (!(ext.equalsIgnoreCase("pdf"))) {
							
							Utils.log(" File is not PDF Moved to Exception Folder");
							File exPath=new File(exceptionPath + "/" + batchname.getName());
							if(!exPath.exists())
							{
							Files.move(Paths.get(filename), Paths.get( exceptionPath + "/" + batchname.getName()));
							}
							else
							{
								Utils.log(batchname.getName()+" is already present in exception folder delete manualy");
							
							}
							continue;
						
						}
						

						query = "select * from DMSI_BATCH_HEADER where batchno='" + batchno + "' and companyId='"+companyId+"'";
						Utils.log(query);
						ResultSet rs = null;

						rs = smt.executeQuery(query);
						if (rs.next() == false) {
							// Utils.log("Not Found");

						} else {
							Utils.log(" Duplicate Batch Number Moved to Exception Folder");
							File exPath=new File(exceptionPath + "/" + batchname.getName());
							if(!exPath.exists())
							{
							Files.move(Paths.get(filename), Paths.get( exceptionPath + "/" + batchname.getName()));
							}
							else
							{
								Utils.log(batchname.getName()+" is already present in exception folder delete manualy");
							
							}
							continue;
						}
						
						warehousename=batchno.substring(0,3);
						Utils.log("warehousename="+warehousename);
						
						Path batchnamePath = Paths.get(processedPath + "/" + batchno);
						Files.createDirectories(batchnamePath);
						
						query="select count(*) from MOB_WHSEMAP where oldwhseno='"+warehousename+"'";
						Utils.log(query);
						String isValidWarehouse=du.getFieldInfo(query);
						String isWarehouse="0";
						if(!isValidWarehouse.equals("1"))
						{
							//Ware house not found in file name now need to read barcode to find ware house
							Utils.log("Invalid Warehouse");
							
							
							filecount = splitPDF(filename, pdfPath);
							

							int status = 0;
							String message = "";
							for (int i = 1; i <= filecount; i++) {
								status = convertToImage(pdfPath + i + ".pdf", imagePath + i + ".jpg");
								Utils.log(i + " Converted to image");
								status = cropImage(imagePath + i + ".jpg", cropPath + i + ".jpg");

								Utils.log("Image cropped");
								String barcode = readBarcode(cropPath + i + ".jpg");
								Utils.log(barcode);
								
								if(barcode!="")
								{
									warehousename=barcode.substring(0,3);
									query="select count(*) from MOB_WHSEMAP where oldwhseno='"+warehousename+"'";
									Utils.log(query);
									isWarehouse=du.getFieldInfo(query);
									Utils.log("isWarehouse="+isWarehouse);
									if(isWarehouse.equals("1"))
									{
										break;
									}
								}
							
							
							
							}
							if(isWarehouse.equals("0"))
							{
								Utils.log("No Warehouse found after reading PDF need to move it to exception folder");
								Files.move(Paths.get(filename), Paths.get( exceptionPath + "/" + batchname.getName()),StandardCopyOption.REPLACE_EXISTING);
								continue;	
							
							}
							
						}
						

						

						// System.out.println(filename + ":" + ext + " Batchno=" + batchno);
						query = "insert into DMSI_BATCH_HEADER (BATCHNO,WAREHOUSE,STATUS,ENTRYDATETIME,companyId) values('" + batchno
								+ "','" + warehousename + "','A',CURRENT_TIMESTAMP,'"+companyId+"')";
						smt.execute(query);
						

							filecount = splitPDF(filename, pdfPath);
							// System.out.println("Total Page=" + filecount + ":" + outpath);

							int status = 0;
							String message = "";
							for (int i = 1; i <= filecount; i++) {
								status = convertToImage(pdfPath + i + ".pdf", imagePath + i + ".jpg");
								Utils.log(i + " Converted to image");
								status = cropImage(imagePath + i + ".jpg", cropPath + i + ".jpg");

								Utils.log("Image cropped");
								String barcode = readBarcode(cropPath + i + ".jpg");
								Utils.log(barcode);
								if (barcode.equals("")) {
									rotateImage(pdfPath + i + ".pdf", imagePath + i + ".jpg", 180);
									cropImage(imagePath + i + ".jpg", cropPath + i + ".jpg");
									barcode = readBarcode(cropPath + i + ".jpg");
									if (barcode.equals("")) {
										rotateImage(pdfPath + i + ".pdf", imagePath + i + ".jpg", 180);
										cropImage(imagePath + i + ".jpg", cropPath + i + ".jpg");
									}

								}
								OrderId = "0";
								ShipmentId = 0;
								if (barcode.equals("")) {
									flag = "F";
									invalid++;

								} else if (barcode.length() == 17) {
									flag = "S";
									valid++;
									
										OrderId = barcode.substring(4, 13);
										ShipmentId = Integer.parseInt(barcode.substring(14, 17));
									

								}
								else
								{
									flag = "F";
									invalid++;
								}
								String filePath = processedFolder + "/" + batchno
										+ "/pdf-" + i + ".pdf";
								
								
								su.S3uploadImage(new File(pdfPath + i + ".pdf"), filePath, "barcodereader");
								
								query = "INSERT INTO DMSI_BATCH_DETAIL (BATCHNO,PAGENO,STATUS,BARCODE,ORDERNO,SHIPMENTNO,FILEPATH,ENTRYDATETIME,companyId)"
										+ "VALUES('" + batchno + "'," + i + ",'" + flag + "','" + barcode + "',"
										+ OrderId + "," + ShipmentId + ",'" + filePath + "',CURRENT_TIMESTAMP,'"+companyId+"')";
								Utils.log(query);
								smt.execute(query);
								query="update dmsi_dailyactivityprocessing set pdf='Y' where orderno="+OrderId+" and shipmentno="+ShipmentId  +" and companyId='"+companyId+"'";
								Utils.log(query);
								smt.execute(query);
								
								message += "\n" + i + ":" + barcode;
								

							}
							Utils.log(message);

						 

						query = "UPDATE DMSI_BATCH_HEADER SET TOTALPAGE=" + filecount + ",VALID=" + valid + ",INVALID="
								+ invalid + " WHERE BATCHNO='" + batchno + "'  and companyId='"+companyId+"'";;
						smt.executeUpdate(query);
						Utils.log("Upload to S3 outbox");
						su.S3uploadImage(new File (filename), outFolder+"/"+batchFilename, "barcodereader");
						Utils.log("OUT PATH="+outboxPath + "/" + batchname.getName());
						
						//Path temp = Files.move(Paths.get(filename), Paths.get( outboxPath + "/" + batchname.getName()));
						File f=new File (filename);
						f.delete();
						Utils.log("Deleted "+batchPath);
						FileUtils.deleteDirectory(new File (batchPath));
						processedPage=filecount;
						if(method.equals("SINGLE"))
						{
							break;
						}
						//break;

					} // for loop of file list

				
		} catch (Exception e) {
			Utils.log("Exception : br ", e);
		} finally {
			Utils.close(smt);
			Utils.close(con);
			Utils.log("Finnaly");
		}
		return processedPage+"";

	}

	public int splitPDF(String filepath, String outPath) {
		int filecount = 0;

		try {
			File pdffile = new File(filepath);
			PDDocument document = PDDocument.load(pdffile);
			Splitter splitting = new Splitter();
			List<PDDocument> Page = splitting.split(document);
			Iterator<PDDocument> iteration = Page.listIterator();
			int j = 1;
			while (iteration.hasNext()) {
				PDDocument pd = iteration.next();
				pd.save(outPath + j++ + ".pdf");
			}
			filecount = j - 1;
			Utils.log("Splitted Pdf Successfully.");
			document.close();
		} catch (Exception e) {

			e.printStackTrace();
		}

		return filecount;
	}

	public int convertToImage(String filepath, String outpath) {
		int status = 0;

		try {
			File file = new File(filepath);
			PDDocument document = PDDocument.load(file);

			PDFRenderer renderer = new PDFRenderer(document);
			BufferedImage image = renderer.renderImage(0);
			BufferedImage bim = renderer.renderImageWithDPI(0, 600, ImageType.RGB);
			ImageIOUtil.writeImage(bim, outpath, 600);
			document.close();
			status = 1;
		} catch (Exception e) {
			Utils.log("Exception", e);
		}
		return status;

	}

	public int cropImage(String filename, String outpath) {
		int status = 0;

		try {

			BufferedImage originalImg = ImageIO.read(new File(filename));
			Utils.log("Original Image Dimension: " + originalImg.getWidth() + "x" + originalImg.getHeight());

			BufferedImage SubImg = originalImg.getSubimage(3200, 200, 1800, 400);// x,y,w,h for 600 dpi
			Utils.log("Cropped Image Dimension: " + SubImg.getWidth() + "x" + SubImg.getHeight());
			File outputfile = new File(outpath);
			ImageIO.write(SubImg, "png", outputfile);
			status = 1;
		} catch (IOException e) {
			Utils.log("Exception", e);
		}
		return status;

	}

	public String readBarcode(String filenme) {
		String barcodeText = "";
		try {
			String path = filenme;

			BufferedImage bf = ImageIO.read(new FileInputStream(path));

			BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(new BufferedImageLuminanceSource(bf)));

			Result result = new MultiFormatReader().decode(bitmap);
			barcodeText = result.getText();
			// System.out.println(result.getBarcodeFormat());

		} catch (Exception e) {
			Utils.log("Exception Error in reading barcode ", e);
		}
		return barcodeText;
	}

	public int rotateImage(String filename, String outpath, double angle) {
		int status = 0;
		try {
			File file = new File(filename);
			PDDocument document = PDDocument.load(file);
			PDFRenderer renderer = new PDFRenderer(document);

			BufferedImage bim = renderer.renderImageWithDPI(0, 600, ImageType.RGB);
			double radian = Math.toRadians(angle);
			double sin = Math.abs(Math.sin(radian));
			double cos = Math.abs(Math.cos(radian));

			int width = bim.getWidth();
			int height = bim.getHeight();

			int nWidth = (int) Math.floor((double) width * cos + (double) height * sin);
			int nHeight = (int) Math.floor((double) height * cos + (double) width * sin);

			BufferedImage rotatedImage = new BufferedImage(nWidth, nHeight, BufferedImage.TYPE_INT_ARGB);

			Graphics2D graphics = rotatedImage.createGraphics();

			graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);

			graphics.translate((nWidth - width) / 2, (nHeight - height) / 2);
			// rotation around the center point
			graphics.rotate(radian, (double) (width / 2), (double) (height / 2));
			graphics.drawImage(bim, 0, 0, null);
			graphics.dispose();
			ImageIO.write(rotatedImage, "png", new FileOutputStream(outpath));
			status = 1;
		} catch (Exception e) {
			Utils.log("Exception", e);
		}
		return status;
	}

	public int convertTIFToPDF(String filepath, String outpath) {
		int status = 0;
		try {
			PDDocument document = new PDDocument();
			File file = new File(filepath); // Enter Tiff file path
			Path path = Paths.get(filepath);

			// call getFileName() and get FileName path object
			Path pathname = path.getFileName();
			String filename = pathname.toString();
			filename = filename.substring(0, filename.lastIndexOf("."));
			ImageInputStream isb = ImageIO.createImageInputStream(file);

			Iterator<ImageReader> iterator = ImageIO.getImageReaders(isb);
			if (iterator == null || !iterator.hasNext()) {
				status = 0;
				System.out.println("Image file format not supported by ImageIO: ");
			}

			ImageReader reader = (ImageReader) iterator.next();
			iterator = null;
			reader.setInput(isb);

			int nbPages = reader.getNumImages(true);

			System.out.println(nbPages);

			for (int p = 0; p < nbPages; p++) {
				BufferedImage bufferedImage = reader.read(p);

				PDPage page = new PDPage();
				document.addPage(page);

				PDImageXObject i = LosslessFactory.createFromImage(document, bufferedImage);

				PDPageContentStream content = new PDPageContentStream(document, page);
				content.drawImage(i, 0, 0, page.getMediaBox().getWidth(), page.getMediaBox().getHeight());

				content.close();
			}
			document.save(outpath + "/" + filename + ".pdf"); // Enter path to save your file with .pdf extension
			document.close();
		} catch (IOException e) {
			Utils.log("Exception", e);
		}
		return status;
	}

	public JSONObject getJSONDataFromQuery(String query, String dbtype) {

		JSONObject jsonReturn = new JSONObject();

		Statement st = null;
		ResultSet rs = null;
		Connection con = null;
		ResultSetMetaData rsMeta = null;

		try {
			DistUtils du = new DistUtils();
			if (dbtype.equals("PRO2")) {
				con = du.getDataConnectionPro2DataSource();
			} else if (dbtype.equals("ETECH")) {
				con = du.getConnection();
			}
			st = con.createStatement();
			Utils.log("query=" + query);
			rs = st.executeQuery(query);
			rsMeta = rs.getMetaData();
			JSONArray jArray = new JSONArray();
			while (rs.next()) {
				JSONObject jsonRow = new JSONObject();
				int columns = rsMeta.getColumnCount();
				for (int k = 1; k <= columns; k++) {
					String val = "";
					String name = rsMeta.getColumnName(k);
					String type = rsMeta.getColumnTypeName(k);

					if (type.equals("DATE"))
						val = Utils.changeDateFormat(rs.getDate(k));
					else
						val = removeNull(rs.getString(k));

					jsonRow.put(name, val);
				}
				jArray.put(jsonRow);
			}
			rs.close();
			st.close();
			con.close();
			jsonReturn.put("data", jArray);
		} catch (Exception e) {
			Utils.log("Exception", e);
			e.printStackTrace();
		}

		return jsonReturn;

	}

	public static String removeNull(String str) {
		if (str == null || str.equals(""))
			return "";
		else
			return (str.equals("null") ? "" : str);
	}

	public String signOffBarcode(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		try {
			String batchno = request.getParameter("batchno");
			query = "update DMSI_BATCH_HEADER set status='S', signoffby ='" + userId
					+ "', signoffdate= current_date where batchno='" + batchno + "'";
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "Record Signed Off Successfully";
	}
	public String lockBarcode(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		try {
			String batchno = request.getParameter("BatchNo");
			query = "update DMSI_BATCH_HEADER set  lockby ='" + userId
					+ "', locktime= current_date where batchno='" + batchno + "'";
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "Record Locked Successfully";
	}
	public String signOffSalesOrder(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		
		try {
			String created_date = request.getParameter("created_date");
			String whse_code = request.getParameter("whse_code");
			
			query = "update Dmsi_dailyactivitysummary set status='S', signoffby ='" + userId
					+ "', signoffdate= current_date where created_date=to_date('"+created_date+"','MM-DD-YY') and whse_code='"+whse_code+"'";
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "Record Signed Off Successfully";
	}
	public String deleteOrder(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		try {
			String batchno = request.getParameter("batchno");
			String pageno = request.getParameter("pageno");
			query = "delete from dmsi_batch_detail where batchno='"+batchno+"' and pageno="+pageno;
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "Record Signed Off Successfully";
	}
	
	public String reScanRecord(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		try {
			String batchno = request.getParameter("batchno");
			query = "DELETE FROM DMSI_BATCH_HEADER WHERE BATCHNO='"+batchno+"'";
			Utils.log(query);
			updateRecord(query);
			query = "DELETE FROM DMSI_BATCH_DETAIL WHERE BATCHNO='"+batchno+"'";
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "Record Signed Off Successfully";
	}

	public String assignOrderNo(HttpServletRequest request) {
		// need to remove

		String query = "";
		HttpSession session = request.getSession();
		String userId = (String) session.getAttribute("userId");
		try {
			DistUtils du = new DistUtils();
			String orderno = request.getParameter("txtOrderid");
			String shipmentno = request.getParameter("txtShipmentid");
			String batchno = request.getParameter("batchno");
			String pageno = request.getParameter("pageno");
			String rNo = request.getParameter("txtRNo");
			
			query = "SELECT WAREHOUSE FROM DMSI_BATCH_HEADER WHERE BATCHNO='" + batchno + "'";
			String warehouse = du.getFieldInfo(query);
			String barcode = warehouse + String.format("%010d", Integer.parseInt(orderno)) + "-"
					+ String.format("%03d", Integer.parseInt(shipmentno));
			query = "UPDATE  DMSI_BATCH_DETAIL SET STATUS='S', ORDERNO=" + orderno + ", SHIPMENTNO=" + shipmentno
					+ " ,BARCODE='" + barcode + "',RNO='"+rNo+"',signoffby='"+userId+"',signoffdate=current_date WHERE BATCHNO='" + batchno + "' AND PAGENO=" + pageno;
			Utils.log(query);
			updateRecord(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		}

		return "success";
	}
	
	public byte[] getReportExcel(HttpServletRequest request)
			 {
		Utils.log("Generating Excel..........");
		ByteArrayOutputStream documentBytes = new ByteArrayOutputStream();
		String query="";
		JSONObject mainObject=null;
		try {
			DistUtils du=new DistUtils();
			String start_date=request.getParameter("invStartDate");
			String end_date=request.getParameter("invEndDate");
			Utils.log("start_date="+start_date+" end_date="+end_date);
			query="select CREATED_DATE,WHSE_CODE,ORDERNO,SHIPMENTNO,MATCH_STATUS,SIGNATURE,REMARKS,MESSAGE,SUBJECT,MAILTO,PDF,MAILSENT_DATE,SALE_TYPE,SIGNOFFDATE,SIGNOFFBY,decode (match_status,'MT','Match','DO','Direct','DSY','Direct Shipping Yard','WC','Will Call','DS','Dispute','MS','Missing') as STATUS_NAME,to_date(sysdate)- to_date(created_date) as days,userid,username,useremail from dmsi_dailyactivityprocessing  where created_date between to_date('"+start_date+"','MM-DD-YY') and to_date('"+end_date+"','MM-DD-YY') and match_status in ('DS','MS') ";
			mainObject= getJSONDataFromQuery(query,"ETECH");

			int rownum=0;
			XSSFWorkbook workbook = new XSSFWorkbook();
			XSSFSheet sheet = workbook.createSheet("Report");
			sheet.setColumnWidth(0, 25 * 256);
			sheet.setColumnWidth(1, 10 * 256);
			sheet.setColumnWidth(2, 10 * 256);
			sheet.setColumnWidth(3, 10 * 256);
			sheet.setColumnWidth(4, 10 * 256);
			sheet.setColumnWidth(5, 10 * 256);
			sheet.setColumnWidth(6, 10 * 256);
			sheet.setColumnWidth(7, 10 * 256);
			sheet.setColumnWidth(8, 10 * 256);
			sheet.setColumnWidth(9, 10 * 256);
			sheet.setColumnWidth(10, 10 * 256);
			sheet.setColumnWidth(11, 10 * 256);
			sheet.setColumnWidth(12, 10 * 256);
			sheet.setColumnWidth(13, 10 * 256);
			sheet.setColumnWidth(14, 10 * 256);
			
			
			
			XSSFCellStyle headstyle = workbook.createCellStyle();
			XSSFCellStyle textstyle = workbook.createCellStyle();
			XSSFCellStyle topHeadStyle = workbook.createCellStyle();
			XSSFCellStyle leftHeadStyle = workbook.createCellStyle();
			
			XSSFFont font = workbook.createFont();
			font.setFontHeight(11);
			font.setBold(true);
			
			
			JSONArray jsonArray = mainObject.getJSONArray("data");
			
			
			
			headstyle.setAlignment(HorizontalAlignment.CENTER);
			headstyle.setFont(font);
			topHeadStyle.setAlignment(HorizontalAlignment.RIGHT);
			topHeadStyle.setFont(font);
			leftHeadStyle.setAlignment(HorizontalAlignment.LEFT);
			leftHeadStyle.setFont(font);
			
			
			XSSFRow row = sheet.createRow(rownum);
			rownum++;
			Cell cell0 = row.createCell(0);
			
			cell0.setCellValue("RWC BUILDING PRODUCTS : "+"From "+start_date+" To "+end_date);
			cell0.setCellStyle(headstyle);
			sheet.addMergedRegion(new CellRangeAddress(0,0,0,10));
			
			/*
			row = sheet.createRow(rownum);
			rownum++;
			cell0 = row.createCell(0);
			
			cell0.setCellValue("From "+start_date+" To "+end_date);
			cell0.setCellStyle(headstyle);
			sheet.addMergedRegion(new CellRangeAddress(0,0,0,10));
			*/
			XSSFFont baseFont = workbook.createFont();
			XSSFFont boldFont = workbook.createFont();
			boldFont.setBold(true);
			XSSFFont textFont = workbook.createFont();
			textFont.setBold(false);
			textstyle.setFont(textFont);
			
			documentBytes = new ByteArrayOutputStream();

			row = sheet.createRow(rownum);
			rownum++;
			
			cell0 = row.createCell(0);
			cell0.setCellValue("Invoice Date");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(1);
			cell0.setCellValue("Warehouse");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(2);
			cell0.setCellValue("Order No");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(3);
			cell0.setCellValue("Shipment No");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(4);
			cell0.setCellValue("Sale Type");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(5);
			cell0.setCellValue("Match Status");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(6);
			cell0.setCellValue("Remarks");
			cell0.setCellStyle(headstyle);
			
			cell0 = row.createCell(7);
			cell0.setCellValue("User Name");
			cell0.setCellStyle(headstyle);
			cell0 = row.createCell(8);
			cell0.setCellValue("User Email");
			cell0.setCellStyle(headstyle);
			
			cell0 = row.createCell(9);
			cell0.setCellValue("Pending Days");
			cell0.setCellStyle(headstyle);
			
			cell0 = row.createCell(10);
			cell0.setCellValue("Status Flag");
			cell0.setCellStyle(headstyle);
			
			String ordership="";
			for (int i=0;i<jsonArray.length();i++)
			{
				JSONObject j=jsonArray.getJSONObject(i) ;
				if(i>0)
					ordership+=",";
				
				ordership+="'"+j.getString("ORDERNO")+"-"+j.getString("SHIPMENTNO")+"'";
				
			}
			if(ordership=="")
				ordership="null";
			
			//query="select status_flag,so_id||'-'||shipment_num as orderid from shipments_header where so_id||'-'||shipment_num in ("+ordership+")";
			query="select status_flag,so_id||'-'||shipment_num as orderid,decode(status_flag,'S','Staged','L','Loaded','E','En-Route','D','Delivered','I','Invoiced') as status_name from shipments_header where so_id||'-'||shipment_num in (select SO_ID||'-'||SHIPMENT_NUM  from shipments_header where created_date between to_date('"+start_date+"','MM-DD-YY') and to_date('"+end_date+"','MM-DD-YY'))";
			 String ordershipJson=getJSONDataFromQuery(query,"PRO2").toString();
				//out.println(ordershipJson);
				
			 JSONObject jo = new JSONObject(ordershipJson);		
				JSONArray status_flagJA = jo.getJSONArray("data");
				
				
			
			for (int j = 0; j < jsonArray.length(); j++) {
				// textFont=new Font(getBaseFont(), 9, Font.NORMAL, Color.BLACK);
				JSONObject jsonObject = jsonArray.getJSONObject(j);
				ordership=jsonObject.getString("ORDERNO")+"-"+jsonObject.getString("SHIPMENTNO");
				String status_flag="No";
				for (int k=0;k<status_flagJA.length();k++)
				{
					JSONObject osj=status_flagJA.getJSONObject(k) ;
					
					if(ordership.equals(osj.getString("ORDERID")))
					{
						status_flag=osj.getString("STATUS_NAME");
						//out.println("<br>"+ordership+":"+osj.getString("ORDERID")+":"+status_flag);
					}
					
				}
				
				
				if(status_flag.equals("No"))
				{
					status_flag="";
					query="select distinct record_type from so_change_history where so_id="+jsonObject.getString("ORDERNO") +" and shipment_num="+jsonObject.getString("SHIPMENTNO");;
					
					String status_flagJson=getJSONDataFromQuery(query,"PRO2").toString();
					//out.println(ordershipJson);
					
				 jo = new JSONObject(status_flagJson);		
					JSONArray status_flagJA2 = jo.getJSONArray("data");
					
					
				
				for (int k = 0; k < status_flagJA2.length(); k++) {

					JSONObject jsonObject2 = status_flagJA2.getJSONObject(k);
					if(k>0)
					{
						status_flag+="/";
					}
					status_flag+=jsonObject2.getString("RECORD_TYPE");
				}
				status_flag="-"+status_flag+"-";
				}
				
				
				row = sheet.createRow(rownum);
				rownum++;
				
				
				cell0 = row.createCell(0);
				cell0.setCellValue(jsonObject.getString("CREATED_DATE"));
				cell0 = row.createCell(1);
				cell0.setCellValue(jsonObject.getString("WHSE_CODE"));
				
				cell0 = row.createCell(2);
				cell0.setCellValue(jsonObject.getString("ORDERNO"));
				cell0 = row.createCell(3);
				cell0.setCellValue(jsonObject.getString("SHIPMENTNO"));
				cell0 = row.createCell(4);
				cell0.setCellValue(jsonObject.getString("SALE_TYPE"));
				cell0 = row.createCell(5);
				
				cell0.setCellValue(jsonObject.getString("STATUS_NAME"));
				cell0 = row.createCell(6);
				cell0.setCellValue(jsonObject.getString("REMARKS"));
				
				cell0 = row.createCell(7);
				cell0.setCellValue(jsonObject.getString("USERNAME"));
				cell0 = row.createCell(8);
				cell0.setCellValue(jsonObject.getString("USEREMAIL"));
				
				cell0 = row.createCell(9);
				cell0.setCellValue(jsonObject.getString("DAYS"));
				
				cell0 = row.createCell(10);
				cell0.setCellValue(status_flag);
				
				//cell[0] = row2.createCell(0);
				
				
				
				
				
				// document.add(leadHeadRow2);
			
			}
			
			workbook.write(documentBytes);
			workbook.close();

		} catch (Exception e) {
			Utils.log("Exception",e);
		}
		return documentBytes.toByteArray();
	}
	
	
	public String sendNotificationMail(HttpServletRequest request)
	{
		
		try {
			DistUtils du=new DistUtils();
			String created_date = request.getParameter("created_date");
			String whse_code = request.getParameter("whse_code");
			String match_status = request.getParameter("match_status_param");
			String pagecode=Utils.removeNull(request.getParameter("pagecode_param")).trim();
			Utils.log(created_date+":"+whse_code+":"+match_status+"::"+pagecode);
			String query="";
			if(pagecode.equals("1"))
			{
			query="select orderno as SO_ID,shipmentno as SHIPMENT_NUM,MAILTO from dmsi_dailyactivityprocessing   where whse_code='"+whse_code
					+"' and created_date=to_date('"+created_date+"','MM-DD-YY') and match_status='"+match_status+"' order by mailto,orderno";;
			}
			else if(pagecode.equals("5"))
			{
			query="select orderno as SO_ID,shipmentno as SHIPMENT_NUM,MAILTO,SALE_TYPE from dmsi_dailyactivityprocessing   where to_date(to_char(created_date,'MM-DD-YY'),'MM-DD-YY')>=to_date('"+request.getParameter("start_date")+"','MM-DD-YY') and to_date(to_char(created_date,'MM-DD-YY'),'MM-DD-YY')<=to_date('"+request.getParameter("end_date")+"','MM-DD-YY') and whse_code='"+request.getParameter("whse_code")+"' and match_status='"+match_status+"'  order by mailto,orderno";;
			}
			Utils.log("query="+query);
			JSONObject json=du.getJSONDataFromQuery(query, "ETECH");
			//System.out.println(json);
			JSONArray ja=json.getJSONArray("data");
			
			JSONArray jaMail=new JSONArray();
			
			
			
			for(int i=0;i<ja.length();i++)
			{
				JSONObject j=ja.getJSONObject(i);
				
				JSONObject j2=new JSONObject();
				Utils.log("Sale type="+j.getString("SALE_TYPE"));
				if(j.getString("SALE_TYPE").contains("TRANSFER") || j.getString("SALE_TYPE").contains("SPCIAL"))
				{
					query="select status_flag from shipments_header where so_id="+j.get("SO_ID")+" and shipment_num="+j.get("SHIPMENT_NUM");
					String status_flag =du.getFieldInfoPro2(query);
					Utils.log(status_flag+"---"+query);
					if(!(status_flag.equals("I")))
					{
						Utils.log("CONTINUE----");
					continue;
					}
				}
				
				j2.put("MAILTO", j.get("MAILTO"));
				j2.put("SO_ID", j.get("SO_ID"));
				int s=checkJson(jaMail, j.get("MAILTO").toString());
				if(s==0)
				jaMail.put(j2);
				
				//System.out.println(j);
			}
			
			Utils.log("JaMail="+jaMail);
			JSONArray malingList=new JSONArray();
			for(int i=0;i<jaMail.length();i++)
			{
				JSONObject selectedJson=jaMail.getJSONObject(i);
				String mailSubject="Hello, <br>Below are the details of missing tickets<br>Order No Shipment No<br>";
				for(int j=0;j<ja.length();j++)
				{
					
					JSONObject allJson=ja.getJSONObject(j);
					if(allJson.getString("SALE_TYPE").contains("TRANSFER") || allJson.getString("SALE_TYPE").contains("SPCIAL"))
					{
						query="select status_flag from shipments_header where so_id="+allJson.get("SO_ID")+" and shipment_num="+allJson.get("SHIPMENT_NUM");
						String status_flag =du.getFieldInfoPro2(query);
						//Utils.log(status_flag+"---"+query);
						if(!(status_flag.equals("I")))
						{
							//Utils.log("CONTINUE----");
						continue;
						}
					}
					
					if(selectedJson.get("MAILTO").equals(allJson.get("MAILTO")))
					{
						mailSubject+=allJson.get("SO_ID").toString()+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+allJson.get("SHIPMENT_NUM")+"<br>";
					}
				}
				mailSubject+="<br><b>RWC Customer Service</b><br><img border='0' width='15%' src='https://reg2.rwc.org/rwcnewlogo.png'>";
				JSONObject jsonRow=new JSONObject();
				jsonRow.put("MAILTO", selectedJson.get("MAILTO"));
				jsonRow.put("MAILBODY", mailSubject);
				malingList.put(jsonRow);
				//System.out.println(selectedJson.get("MAILTO")+":\n"+mailSubject);
				
				//System.out.println(i);
			}
			Utils.log("malingList"+malingList.toString());
			for(int i=0;i<malingList.length();i++)
			{
				JSONObject j=malingList.getJSONObject(i);
				JSONObject reqBody=new JSONObject();
				reqBody.put("From", "salesaudit@rwc.org");
				reqBody.put("To", j.getString("MAILTO"));
				//reqBody.put("Cc", "shadab@rwc.org");
				reqBody.put("Bcc", "shadab@rwc.org");
				reqBody.put("Subject", "Detail of missing Ticket");
				//reqBody.put("Tag", tag);
				reqBody.put("HtmlBody", j.getString("MAILBODY"));
				reqBody.put("TextBody", j.getString("MAILBODY"));
				//reqBody.put("ReplyTo", replyTo);

				reqBody.put("MessageStream", "outbound");


				Utils.log("Request: "+reqBody);

				CustomerInvoiceMailSend customerInvoiceMailSend = new CustomerInvoiceMailSend();
				JSONObject mailResponse=customerInvoiceMailSend.EmailPostMarkApiCall(reqBody.toString(), "POST");
				Utils.log(mailResponse.toString());
				
			}
			
			for(int i=0;i<ja.length();i++)
			{
				JSONObject j=ja.getJSONObject(i);
				
				//JSONObject j2=new JSONObject();
				
				//j2.put("SO_ID", j.get("SO_ID"));
				
				if(j.getString("SALE_TYPE").contains("TRANSFER") || j.getString("SALE_TYPE").contains("SPCIAL"))
				{
					query="select status_flag from shipments_header where so_id="+j.get("SO_ID")+" and shipment_num="+j.get("SHIPMENT_NUM");
					String status_flag =du.getFieldInfoPro2(query);
					//Utils.log(status_flag+"---"+query);
					if(!(status_flag.equals("I")))
					{
						//Utils.log("CONTINUE----");
					continue;
					}
				}
				
				query="update dmsi_dailyactivityprocessing set mailsent_date=current_date where orderno="+j.get("SO_ID")+" and shipmentno="+j.get("SHIPMENT_NUM");
				Utils.log(query);
				updateRecord(query);
				
				//System.out.println(j);
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	public String sendNotificationMailDispute(HttpServletRequest request)
	{
		
		try {
			DistUtils du=new DistUtils();
			String created_date = request.getParameter("created_date");
			String whse_code = request.getParameter("whse_code");
			String match_status = request.getParameter("match_status_param");
			String pagecode=Utils.removeNull(request.getParameter("pagecode_param")).trim();
			Utils.log(created_date+":"+whse_code+":"+match_status+"::"+pagecode);
			String query="";
			if(pagecode.equals("1"))
			{
			query="select orderno as SO_ID,shipmentno as SHIPMENT_NUM,MAILTO,SALE_TYPE,remarks from dmsi_dailyactivityprocessing   where whse_code='"+whse_code
					+"' and created_date=to_date('"+created_date+"','MM-DD-YY') and match_status='"+match_status+"' order by mailto,orderno";;
			}
			else if(pagecode.equals("5"))
			{
			query="select orderno as SO_ID,shipmentno as SHIPMENT_NUM,MAILTO,SALE_TYPE,remarks from dmsi_dailyactivityprocessing   where to_date(to_char(created_date,'MM-DD-YY'),'MM-DD-YY')>=to_date('"+request.getParameter("start_date")+"','MM-DD-YY') and to_date(to_char(created_date,'MM-DD-YY'),'MM-DD-YY')<=to_date('"+request.getParameter("end_date")+"','MM-DD-YY') and whse_code='"+request.getParameter("whse_code")+"' and match_status='"+match_status+"'  order by mailto,orderno";;
			}
			Utils.log("query="+query);
			JSONObject json=du.getJSONDataFromQuery(query, "ETECH");
			Utils.log("json="+json);
			JSONArray ja=json.getJSONArray("data");
			
			JSONArray jaMail=new JSONArray();
			
			
			
			for(int i=0;i<ja.length();i++)
			{
				JSONObject j=ja.getJSONObject(i);
				
				JSONObject j2=new JSONObject();
				
				
				j2.put("MAILTO", j.get("MAILTO"));
				j2.put("SO_ID", j.get("SO_ID"));
				j2.put("SALE_TYPE", j.get("SALE_TYPE"));
				j2.put("REMARKS", j.get("REMARKS"));
				int s=checkJson(jaMail, j.get("MAILTO").toString());
				if(s==0)
				jaMail.put(j2);
				
				//System.out.println(j);
			}
			
			Utils.log("JaMail="+jaMail);
			JSONArray malingList=new JSONArray();
			for(int i=0;i<jaMail.length();i++)
			{
				JSONObject selectedJson=jaMail.getJSONObject(i);
				String mailSubject="Hello, <br>Below are the details of Disputed Tickets<br>Order No Shipment No Sale Type Remarks<br>";
				for(int j=0;j<ja.length();j++)
				{
					
					JSONObject allJson=ja.getJSONObject(j);
					
					
					if(selectedJson.get("MAILTO").equals(allJson.get("MAILTO")))
					{
						mailSubject+=allJson.get("SO_ID").toString()+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+allJson.get("SHIPMENT_NUM")+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+allJson.get("SALE_TYPE")+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+allJson.get("REMARKS")+"<br>";
					}
				}
				mailSubject+="<br><b>RWC Customer Service</b><br><img border='0' width='15%' src='https://reg2.rwc.org/rwcnewlogo.png'>";
				JSONObject jsonRow=new JSONObject();
				jsonRow.put("MAILTO", selectedJson.get("MAILTO"));
				jsonRow.put("MAILBODY", mailSubject);
				malingList.put(jsonRow);
				//System.out.println(selectedJson.get("MAILTO")+":\n"+mailSubject);
				
				//System.out.println(i);
			}
			Utils.log("malingList"+malingList.toString());
			for(int i=0;i<malingList.length();i++)
			{
				JSONObject j=malingList.getJSONObject(i);
				JSONObject reqBody=new JSONObject();
				reqBody.put("From", "salesaudit@rwc.org");
				reqBody.put("To", j.getString("MAILTO"));
				//reqBody.put("Cc", "shadab@rwc.org");
				reqBody.put("Bcc", "shadab@rwc.org");
				reqBody.put("Subject", "Detail of missing Ticket");
				//reqBody.put("Tag", tag);
				reqBody.put("HtmlBody", j.getString("MAILBODY"));
				reqBody.put("TextBody", j.getString("MAILBODY"));
				//reqBody.put("ReplyTo", replyTo);

				reqBody.put("MessageStream", "outbound");


				Utils.log("Request: "+reqBody);

				CustomerInvoiceMailSend customerInvoiceMailSend = new CustomerInvoiceMailSend();
				JSONObject mailResponse=customerInvoiceMailSend.EmailPostMarkApiCall(reqBody.toString(), "POST");
				Utils.log(mailResponse.toString());
				
			}
			
			for(int i=0;i<ja.length();i++)
			{
				JSONObject j=ja.getJSONObject(i);
				
				
				
				query="update dmsi_dailyactivityprocessing set mailsent_date=current_date where orderno="+j.get("SO_ID")+" and shipmentno="+j.get("SHIPMENT_NUM");
				Utils.log(query);
				updateRecord(query);
				
				
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	
	public static int checkJson(JSONArray ja,String mailto) throws Exception
	{
		int status=0;
		
		for(int i=0;i<ja.length();i++)
		{
			JSONObject j=ja.getJSONObject(i);
			
			if(j.get("MAILTO").equals(mailto))
			{
				status=1;
				break;
			}
			
		}
		
		return status;
	}
	public int updateRecord(String query) {
		// need to remove
		Connection con = null;
		Statement smt = null;
		int retval = 0;

		try {
			DistUtils du = new DistUtils();
			con = du.getConnection();

			smt = con.createStatement();
			retval = smt.executeUpdate(query);

		} catch (Exception e) {
			Utils.log("Exception", e);

		} finally {
			Utils.close(smt);
			Utils.close(con);
		}

		return retval;
	}

}
