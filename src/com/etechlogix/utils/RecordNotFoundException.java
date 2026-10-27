package com.etechlogix.utils;

/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author
 * @version 1.0
 */

public class RecordNotFoundException extends Exception{
  private String tableName;
  public RecordNotFoundException(String field){
    super(field);
  }

  public RecordNotFoundException(String field, String tableName){
    super(field);
    this.tableName=tableName;
  }
  public String getTableName(){
   return tableName;
  }
}