package com.etechlogix.utils;

/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2000
 * Company:
 * @author
 * @version 1.0
 */

public class LoginException extends Exception {
    private int errorCode=0;
    // 0 = Invalid Login Data
    // 1 = User Account Disabled
    // 2 = User Account Expired
    // 3 = UserGroup Account Disabled
    // 4 = UserGroup Account Expired
		//
		//
		//
		//
    private String userId="", password="";
    LoginException(String msg) {
      super(msg);
    }

   public LoginException(String msg, LoginException le) {
			super(msg);
			this.userId = le.userId;
      this.password = le.password;
      this.errorCode = le.errorCode;
    }

    public LoginException(String msg, String userId, String password, int errorCode ) {
      super(msg);
      this.userId = userId;
      this.password = password;
      this.errorCode = errorCode;
    }

    public String getUserId() {return userId;}
    public String getPassword() {return password;}
    public int getErrorCode() {return errorCode;}
}