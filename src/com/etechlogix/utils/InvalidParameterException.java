package com.etechlogix.utils;

/**
 * Title:        Standard Catalog 2.0
 * Description:
 * Copyright:    Copyright (c) 2000
 * Company:      eTechLogix Inc.
 * @author Zeeshan Ghalib
 * @version 1.0
 */

public class InvalidParameterException extends Exception {
  public InvalidParameterException(String parameterName) {
   super(parameterName);
  }
}