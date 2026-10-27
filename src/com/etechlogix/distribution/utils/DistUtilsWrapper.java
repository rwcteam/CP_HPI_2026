package com.etechlogix.distribution.utils;

import java.sql.*;
import javax.servlet.http.*;

public interface DistUtilsWrapper {

	public Connection getConnection(HttpSession session) throws Exception;
	
}
