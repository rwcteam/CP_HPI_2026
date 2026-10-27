package com.etechlogix.distribution.utils;

import java.sql.Connection;
import javax.servlet.http.HttpSession;

public class DefaultDistUtilsWrapper implements DistUtilsWrapper {

	public Connection getConnection(HttpSession session) throws Exception {
		DistUtils du = DistUtils.getDistUtils(session);
		return du.getConnection();
	}

}
