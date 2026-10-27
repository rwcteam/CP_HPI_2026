package com.etechlogix.utils;

import java.util.*;
import java.io.*;

public class AppletTag {
  Properties apppletProperties = new Properties();

  /** Creates an object after loading the default parameters from
  the properties file
  */
  public AppletTag(String absoluteName)
   throws Exception {
    loadFromFile(absoluteName);
  }

/** Loads the property file.  This method is called by the
constructor.
*/
  public void loadFromFile(String absoluteName)
   throws Exception {
    FileInputStream in =
          new FileInputStream(new File(absoluteName));
    apppletProperties.load(in);
  }

/** Overrides the inherited toString() to return the
corresponding HTML code for the applet.
*/
  public String toString() {
   String elements="", params="";
   String p;
   for (Enumeration e = apppletProperties.propertyNames() ;
    e.hasMoreElements() ;) {
    p = e.nextElement().toString();
    if (p.startsWith("param-") || p.startsWith("paramA-"))
     params += "\n\t" + getParamHtml(p);
    else
     elements += " " + getElementHtml(p);
   } // for
   return "\n<applet "+elements+" MAYSCRIPT> "
          +params
          +"\n</applet>";
  }

  private String getParamHtml(String str) {
  String res ="<param name=";

    if (str.startsWith("paramA-"))
      res += str.substring(7)+" value="+"\""+apppletProperties.getProperty(str)+"\">";
    else
      res += str.substring(6)+" value="+apppletProperties.getProperty(str) +">";
    return res;
  }

/** Returns the value of an element of the appplet.
*/
  private String getElementHtml(String str) {
   return str+"="+apppletProperties.getProperty(str);
  }

/** Returns the value of an element of the appplet.
*
  private String getNoValue(String str) {
   return str.substring(8);
  }
*/

/** Returns the value of an applet-parameter.
*/
  public String getParam(String name){
   return apppletProperties.getProperty("param-"+name);

  }
/** Sets the value of an applet-paramerter.
*/
  public void setParam(String name, String value){
   apppletProperties.setProperty("param-"+name, value);
  }

/** Returns the value of an applet-element.
*/
  public String getElement(String name){
   return apppletProperties.getProperty(name);
  }
/** Sets the value of an applet-element.
*/
  public void setElement(String name, String value){
   apppletProperties.setProperty(name, value);
  }

  public static void main(String[] args) {
    try {
     AppletTag appletTag = new AppletTag("C:\\weblogic\\myserver\\public_html\\CustomersGA.properties");
     appletTag.invokedStandalone = true;

     System.out.println("\nMain-> "+appletTag+"<--Done.");
    } catch (Exception e) {
          System.out.println("Inside main(): " + e);
    }
  }
  private boolean invokedStandalone = false;
}