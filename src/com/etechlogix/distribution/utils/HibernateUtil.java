/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etechlogix.distribution.utils;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

import com.etechlogix.utils.Utils;

/**
 * Hibernate Utility class with a convenient method to get Session Factory
 * object.
 *
 * @author Admin
 */
public class HibernateUtil {

	private static SessionFactory sessionFactory;
	
	private HibernateUtil(){}
	
	public static SessionFactory getSessionFactory() {
		Utils.log("Inside Hibernate getSessionFactory");     
		if(sessionFactory != null)
			return sessionFactory;
		else {
			try {
				/*Configuration configuration = new Configuration();
				configuration.configure("/hibernate.cfg.xml");
				Utils.log("Hibernate Annotation Configuration loaded");        	
				ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder().applySettings(configuration.getProperties()).build();
				Utils.log("Hibernate Annotation serviceRegistry created");       
				sessionFactory = configuration.buildSessionFactory(serviceRegistry);	 */
				sessionFactory = new Configuration().configure("/hibernate.cfg.xml").buildSessionFactory();
				   
			} catch (Throwable ex) {
				Utils.log("Initial SessionFactory creation failed." + ex);
				throw new ExceptionInInitializerError(ex);
			}
			return sessionFactory;
		}
	} 

}
