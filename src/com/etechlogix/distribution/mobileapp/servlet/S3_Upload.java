package com.etechlogix.distribution.mobileapp.servlet;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.HttpMethod;
import com.amazonaws.SdkClientException;
import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.transfer.MultipleFileDownload;
import com.amazonaws.services.s3.transfer.TransferManager;
import com.amazonaws.util.IOUtils;
import com.etechlogix.utils.Utils;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.util.Matrix;
import org.ow2.util.base64.Base64;

public class S3_Upload {

    public String S3uploadImage(File sourcePath,String destinationPath) throws IOException {
        Regions clientRegion = Regions.US_EAST_1;
        
        Utils.log("sourcePath="+sourcePath);
        Utils.log("destinationPath"+destinationPath);
        String message="error";
      String fileObjKeyName = destinationPath;
        //String fileName = sourcePath;
             try {
            	 FileReader reader=new FileReader("MobileApp.properties");  
         	    Properties p=new Properties();  
         	    p.load(reader);    
         	   String S3BucketName=p.getProperty("S3BucketName");
         	   
            AmazonS3 s3Client = AmazonS3ClientBuilder.standard().withRegion(clientRegion).build();
            PutObjectRequest request = new PutObjectRequest(S3BucketName, fileObjKeyName, sourcePath);
            s3Client.putObject(request);
            message="success";
            
        } catch (Exception e) {
           Utils.log("Exception=",e);
           message="error";
            
        } 
        return message;
    }
    public String S3uploadImage(File sourcePath,String destinationPath,String S3BucketName) throws IOException {
        Regions clientRegion = Regions.US_EAST_1;
        
        Utils.log("sourcePath="+sourcePath);
        Utils.log("destinationPath"+destinationPath);
        Utils.log("S3BucketName="+S3BucketName);
        String message="error";
      String fileObjKeyName = destinationPath;
        //String fileName = sourcePath;
             try {
            	 
         	   
            AmazonS3 s3Client = AmazonS3ClientBuilder.standard().withRegion(clientRegion).build();
            PutObjectRequest request = new PutObjectRequest(S3BucketName, fileObjKeyName, sourcePath);
            s3Client.putObject(request);
            message="success";
            
        } catch (Exception e) {
           Utils.log("Exception=",e);
           message="error";
            
        } 
        return message;
    }
    public String downloadImageinBase64( String S3path)
    {
    	String base64String="";
    	Regions clientRegion = Regions.US_EAST_1;
        

        try {
        	FileReader reader=new FileReader("MobileApp.properties");  
     	    Properties p=new Properties();  
     	    p.load(reader);    
     	   String S3BucketName=p.getProperty("S3BucketName");
        	
            AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                    .withCredentials(new ProfileCredentialsProvider())
                    .withRegion(clientRegion)
                    .build();
            
			
			
			S3Object s3Object = s3Client.getObject(S3BucketName, S3path);
            InputStream sis=s3Object.getObjectContent();
			byte[] bar = IOUtils.toByteArray(sis);
            char[] encodedString = Base64.encode(bar);
		    base64String = new String(encodedString);
			
		
           
        } catch (Exception e) {
            Utils.log("Exception",e);
        } 
    	
    	return base64String;
    	
    	}
    
    public String getTempURL(String S3Path)
    {
    	Regions clientRegion = Regions.US_EAST_1;
        //String bucketName = "rwcuseast1";
        //String objectKey = "MobileService/OrderImage/1-695763-1/1-695763-1-55.jpg";
        String objectKey = S3Path;
        String tempURL="";
        Utils.log(S3Path);
        try {
        	FileReader reader=new FileReader("MobileApp.properties");  
     	    Properties p=new Properties();  
     	    p.load(reader);    
     	   String S3BucketName=p.getProperty("S3BucketName");
        	
            AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                    .withRegion(clientRegion)
                    .withCredentials(new ProfileCredentialsProvider())
                    .build();

            // Set the presigned URL to expire after one hour.
            java.util.Date expiration = new java.util.Date();
            long expTimeMillis = Instant.now().toEpochMilli();
            Utils.log(expTimeMillis+"");
            expTimeMillis += 1000  60  5; //5 min
            expiration.setTime(expTimeMillis);
            Utils.log(expTimeMillis+"");
            // Generate the presigned URL.
            //System.out.println("Generating pre-signed URL.");
            GeneratePresignedUrlRequest generatePresignedUrlRequest =
                    new GeneratePresignedUrlRequest(S3BucketName, objectKey)
                            .withMethod(HttpMethod.GET)
                            .withExpiration(expiration);
            URL url = s3Client.generatePresignedUrl(generatePresignedUrlRequest);

            Utils.log("Pre-Signed URL: " + url.toString());
            tempURL=url.toString();
        
        } catch (Exception e) {
           Utils.log("Exception ",e);
        }
    	
    	return tempURL;
    }
    public String getTempURL(String S3Path,String S3BucketName)
    {
    	Regions clientRegion = Regions.US_EAST_1;
        //String bucketName = "rwcuseast1";
        //String objectKey = "MobileService/OrderImage/1-695763-1/1-695763-1-55.jpg";
        String objectKey = S3Path;
        String tempURL="";
        Utils.log(S3Path);
        try {
            AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                    .withRegion(clientRegion)
                    .withCredentials(new ProfileCredentialsProvider())
                    .build();

            // Set the presigned URL to expire after one hour.
            java.util.Date expiration = new java.util.Date();
            long expTimeMillis = Instant.now().toEpochMilli();
            Utils.log(expTimeMillis+"");
            expTimeMillis += 1000  60  5; //5 min
            expiration.setTime(expTimeMillis);
            Utils.log(expTimeMillis+"");
            // Generate the presigned URL.
            //System.out.println("Generating pre-signed URL.");
            GeneratePresignedUrlRequest generatePresignedUrlRequest =
                    new GeneratePresignedUrlRequest(S3BucketName, objectKey)
                            .withMethod(HttpMethod.GET)
                            .withExpiration(expiration);
            URL url = s3Client.generatePresignedUrl(generatePresignedUrlRequest);
            Utils.log("Pre-Signed URL: " + url.toString());
            tempURL=url.toString();
        
        } catch (Exception e) {
           Utils.log("Exception ",e);
        }
    	
    	return tempURL;
    }
   
    
    public ArrayList<String> downloadImageinBase64_Array( ArrayList<String> ImageNameList,String folderName)
    {
    	ArrayList<String> base64String=new ArrayList<String>(); 
    	Regions clientRegion = Regions.US_EAST_1;
    	String S3FolderPath="";
       String S3Path="";

        try {
        	FileReader reader=new FileReader("MobileApp.properties");  
     	    Properties p=new Properties();  
     	    p.load(reader);    
     	   String S3BucketName=p.getProperty("S3BucketName");
     	  S3Path=p.getProperty("S3Path");
        	
        	S3FolderPath=S3Path+folderName;
        	 
        	TransferManager transferManager = new TransferManager(new DefaultAWSCredentialsProviderChain());
        	Utils.log("Download start..."+S3FolderPath);
        	 File dir = Files.createTempDirectory(folderName).toFile();
        	MultipleFileDownload download =  transferManager.downloadDirectory(S3BucketName, S3FolderPath, dir);
        	download.waitForCompletion();
        	Utils.log("Download End...");
        	Utils.log("Temporary Directory created at:\n" + dir.toString());
        	//String folderpath=dir.toString()+"\\MobileService\\OrderImage\\"+folderName;
        	//System.out.println(folderpath);
        	
        	
        	for(int j=0;j<ImageNameList.size();j++)
			{
			System.out.println(j+" "+ImageNameList.get(j));
			String filepath=dir.toString()+"/"+S3Path+folderName+"/"+ImageNameList.get(j);
			Utils.log(filepath);
			File ImageFile= new File(filepath);
			if(ImageFile.exists())
			{
		    byte[] fileContent = FileUtils.readFileToByteArray(ImageFile);
		    char[] encodedString = Base64.encode(fileContent);
		    String LogoEncoded = new String(encodedString);
		    base64String.add(LogoEncoded);
		    ImageFile.delete();
			}
			else
			{
				Utils.log("File Not Found "+filepath);
			
			}
			}
        	
        	//dir.deleteOnExit();
        	FileUtils.deleteDirectory(dir);
            
           
        } catch (Exception e) {
           Utils.log("Exception=", e);
        }   
        
    	return base64String;
    	
    	}
    
    public String downloadDirectoryFromS3( String folderName)
    {
    	ArrayList<String> base64String=new ArrayList<String>(); 
    	Regions clientRegion = Regions.US_EAST_1;
    	String S3FolderPath="";
       String S3Path="";
       String folderPath="Error";
        try {
        	FileReader reader=new FileReader("MobileApp.properties");  
     	    Properties p=new Properties();  
     	    p.load(reader);    
     	   String S3BucketName=p.getProperty("S3BucketName");
     	  S3Path=p.getProperty("S3Path");
        	
        	S3FolderPath=S3Path+folderName;
        	 
        	TransferManager transferManager = new TransferManager(new DefaultAWSCredentialsProviderChain());
        	Utils.log("Download start..."+S3FolderPath);
        	 File dir = Files.createTempDirectory(folderName).toFile();
        	MultipleFileDownload download =  transferManager.downloadDirectory(S3BucketName, S3FolderPath, dir);
        	download.waitForCompletion();
        	Utils.log("Download End...");
        	Utils.log("Temporary Directory created at:\n" + dir.toString());
        	folderPath=dir.toString();
        	//String folderpath=dir.toString()+"\\MobileService\\OrderImage\\"+folderName;
        	//System.out.println(folderpath);
        	
            
           
        } catch (Exception e) {
           Utils.log("Exception=", e);
        }   
    	
    	return folderPath;
    	
    	}
    
    public String getBase64String(String folderPath,String folderName,String imagename)
    {
    String base64String="Error"; 
    	
     

        try {
        	
			String filepath=folderPath+"/"+folderName+"/"+imagename;
			Utils.log(filepath);
			File ImageFile= new File(filepath);
			if(ImageFile.exists())
			{
		    byte[] fileContent = FileUtils.readFileToByteArray(ImageFile);
		    char[] encodedString = Base64.encode(fileContent);
		    base64String = new String(encodedString);
		    base64String="<img width='200px' src='data:image/jpeg;base64,"+base64String+"' >";
			}
			else
			{
				Utils.log("File Not Found "+filepath);
				base64String="<li><img src='image/noimage.jpg' alt ='No Image Found' ></li>";
			
			}
			
        	
            
           
        } catch (Exception e) {
           Utils.log("Exception=", e);
        }   
    	
    	return base64String;
    	
    	}
    public String rotate_PDF(String pdfPath,String S3BucketName)
    {
    	//String filename="D:\\test\\pdf\\20230720121601789_0021_R.pdf";
    	String status="Error";
    	String folderPath="/home/tomcat/barcode_reader/rotate_temp";
		try {
			
			AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                    .withCredentials(new ProfileCredentialsProvider())
                    .withRegion(Regions.US_EAST_1)
                    .build();
            
			s3Client.getObject(new GetObjectRequest(S3BucketName, pdfPath),new File(folderPath+"/file.pdf"));
			
			S3Object s3Object = s3Client.getObject(S3BucketName, pdfPath);
            InputStream sis=s3Object.getObjectContent();
			
			
			
			File pdffile = new File(folderPath+"/file.pdf");
			
			PDDocument document = PDDocument.load(pdffile);
			PDPage page = document.getDocumentCatalog().getPages().get(0);
			PDPageContentStream cs = new PDPageContentStream(document, page, PDPageContentStream.AppendMode.PREPEND, false, false); 
			PDRectangle cropBox = page.getCropBox();
			float tx = (cropBox.getLowerLeftX() + cropBox.getUpperRightX()) / 2;
			float ty = (cropBox.getLowerLeftY() + cropBox.getUpperRightY()) / 2;
			cs.transform(Matrix.getTranslateInstance(tx, ty));
			cs.transform(Matrix.getRotateInstance(Math.toRadians(180), 0, 0));
			cs.transform(Matrix.getTranslateInstance(-tx, -ty));
			
			cs.close();
			document.save(folderPath+"/file_R.pdf");
			//System.out.println("Success");
			S3uploadImage(new File(folderPath+"/file_R.pdf"),pdfPath,S3BucketName);
			status="success";
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			Utils.log("Error",e);
		}
    	return status;
    }

}
