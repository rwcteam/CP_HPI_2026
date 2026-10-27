package com.etechlogix.hibernate.ad.servlet;

import java.io.IOException;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Restrictions;

import com.etechlogix.distribution.utils.DistUtils;
import com.etechlogix.distribution.utils.HibernateUtil;
import com.etechlogix.hibernate.ad.entity.EtechUser;
import com.etechlogix.utils.InvalidParameterException;
import com.etechlogix.utils.ParameterNotFoundException;
import com.etechlogix.utils.ProcessingErrorException;
import com.etechlogix.utils.RecordNotFoundException;
import com.etechlogix.utils.Utils;

public class EtechUserProcess implements Serializable {
	Utils u = null;
	DistUtils du = null;
	final String labelFileName = "EtechUserLabel.properties";
	private SessionFactory sessionFactory = null;
	
	public EtechUserProcess(){
		this.sessionFactory = HibernateUtil.getSessionFactory();
	}

	public void updateRecord(HttpServletRequest request) throws Exception {
		boolean required = true;
		String userId = "";
		String userType = "";
		String groupId = "";
		String userInitials = "";
		String firstName = "";
		String middleName = "";
		String lastName = "";
		String address = "";
		String city = "";
		String state = "";
		String zip = "";
		String phone = "";
		String fax = "";
		String mobile = "";
		String password = "";
		Date passwordExpiryDate;
		String defaultPrinter = "";
		String defaultWarehouse = "";
		String x = "";
		String status = "";
		String showRebateCost = "";
		String defaultCompanyId = "";
		String allowChangeReceiptWhse = "";
		String defaultPersonalPrinter = "";
		String emailId = "";
		String empId = "";
		String phoneExt = "";
		String speedDial = "";
		String deptId = "";
		Date dateOfBirth;
		

		String creditCardNo;
		Date expiryDate;
		String costOverride;
		String allowChangePeriodJe;
		String showLoginPopUp;
		String financialEmail;
		String soHelp;
		String allowClosePaymentReceipt;
		String vehicleAdmin;
		Date datePasschange;
		String icrCorporate;
		String wrTransferAccess;
		String commPermission;
		String authorizedCode;
		
		String allowAuthorized;
		
		Double authorizedAmount;
		String allowPayTraceAllWhse;
		String cashReportPermission;
		String allowSugContractPricApproval;
		String newItemRequestEmail;
		String overrideDeliveryCost;
		Integer pinCode;
		String allowPODeliveryPrint;
		String twoWayAuth;

		//EtechUserDaoImpl userDaoImpl = new EtechUserDaoImpl();
		HttpSession session = request.getSession();
		du = DistUtils.getDistUtils(session);
		
		u = DistUtils.getUtils(session);
		// Update the record.
		try {
			
			userId = Utils.getParameterString("userId", required, request);
			userType = Utils.getParameterString("userType", required, request);
			groupId = Utils.getParameterString("groupId", required, request);
			userInitials = Utils.getParameterString("userInitials", required, request);
			firstName = Utils.getParameterString("firstName", required, request);
			middleName = Utils.getParameterString("middleName", request);
			lastName = Utils.getParameterString("lastName", required, request);
			address = Utils.getParameterString("address", request);
			city = Utils.getParameterString("city", request);
			state = Utils.getParameterString("state", request);
			zip = Utils.getParameterString("zip", request);
			phone = Utils.getParameterString("phone", request);
			fax = Utils.getParameterString("fax", request);
			mobile = Utils.getParameterString("mobile", request);
			password = Utils.getParameterString("password", request);
			showRebateCost = Utils.getParameterCheck("showRebateCost", request);
			defaultCompanyId = Utils.getParameterString("defaultCompanyId", request);
			allowChangeReceiptWhse = Utils.getParameterString("allowChangeReceiptWhse", request);
			defaultPersonalPrinter = Utils.getParameterString("defaultPersonalPrinter", request);
			emailId = Utils.getParameterString("emailId", request);
			empId = Utils.getParameterString("empId", request);
			phoneExt = Utils.getParameterString("phoneExt", request);
			speedDial = Utils.getParameterString("speedDial", request);
			
			creditCardNo = Utils.getParameterString("creditCardNo", request);
			expiryDate = getParameterDate("expiryDate", "standardDateFormat", request);
			costOverride = Utils.getParameterString("costOverride", request);
			allowChangePeriodJe = Utils.getParameterString("allowChangePeriodJe", request);
			showLoginPopUp = Utils.getParameterString("showLoginPopUp", request);
			financialEmail = Utils.getParameterString("financialEmail", request);
			soHelp = Utils.getParameterString("soHelp", request);
			allowClosePaymentReceipt = Utils.getParameterString("allowClosePaymentReceipt", request);
			vehicleAdmin = Utils.getParameterString("vehicleAdmin", request);
			icrCorporate = Utils.getParameterString("icrCorporate", request);
			wrTransferAccess = Utils.getParameterString("wrTransferAccess", request);
			commPermission = Utils.getParameterString("commPermission", request);
			authorizedCode = Utils.getParameterString("authorizedCode", request);
			allowAuthorized = Utils.getParameterString("allowAuthorized", request);
			authorizedAmount = Utils.getParameterDouble("authorizedAmount", 30, 2, request);
			allowPayTraceAllWhse = Utils.getParameterString("allowPayTraceAllWhse", request);
			cashReportPermission = Utils.getParameterString("cashReportPermission", request);
			allowSugContractPricApproval = Utils.getParameterString("allowSugContractPricApproval", request);
			newItemRequestEmail = Utils.getParameterString("newItemRequestEmail", request);
			overrideDeliveryCost = Utils.getParameterString("overrideDeliveryCost", request);
			allowPODeliveryPrint = Utils.getParameterString("allowPODeliveryPrint", request);
			twoWayAuth = Utils.getParameterString("twoWayAuth", request);		
			
			
			deptId = Utils.getParameterString("deptId", request);
			dateOfBirth = getParameterDate("dateOfBirth", "standardDateFormat", request);

			// passwordExpiryDate=Utils.getParameterSqlDate("passwordExpiryDate",request);
			passwordExpiryDate = getParameterDate("passwordExpiryDate", "standardDateFormat", request);

			defaultPrinter = Utils.getParameterString("defaultPrinter", request);
			defaultWarehouse = Utils.getParameterString("defaultWarehouse", required, request);
			x = Utils.getParameterString("x", request);
			status = Utils.getParameterString("status", required, request);
		}

		catch (Exception e) {
			Utils.log("<P>EtechUserMaintenance..updateRecord:error in form", e);
			throw new ProcessingErrorException(e, labelFileName);
		}
		try {
			
			EtechUser allData = null;
			
			Session sessionH = null;
			try {
				sessionH = sessionFactory.openSession();
				sessionH.beginTransaction();
				DetachedCriteria criteria = DetachedCriteria.forClass(EtechUser.class);
				criteria.add(Restrictions.eq("userId", userId));
				allData = (EtechUser) criteria.getExecutableCriteria(sessionH).uniqueResult();
			} catch (HibernateException he) {
				Utils.log("Error save : ", he);
				throw new Exception(he);
			} finally {
				sessionH.close();
			}

			Utils.log(" user Initials ########## " + userInitials);

			allData.setUserType(userType);
			allData.setGroupId(groupId); 
			allData.setUserInitials(userInitials); 
			allData.setFirstName(firstName); 
			allData.setMiddleName(middleName); 
			allData.setLastName(lastName); 
			allData.setAddress(address); 
			allData.setCity(city); 
			allData.setState(state); 
			allData.setZip(zip); 
			allData.setPhone(phone); 
			allData.setFax(fax);  
			allData.setMobile(mobile);  
			allData.setPassword(password);  
			allData.setPasswordExpiryDate(passwordExpiryDate);  
			allData.setDefaultPrinter(defaultPrinter);  
			allData.setDefaultWarehouse(defaultWarehouse);  
			allData.setX(x); 
			allData.setStatus(status); 
			allData.setShowRebateCost(showRebateCost);  
			allData.setDefaultCompanyId(defaultCompanyId);  
			allData.setAllowChangeReceiptWhse(allowChangeReceiptWhse);  
			allData.setDefaultPersonalPrinter(defaultPersonalPrinter);  
			allData.setEmailId(emailId);  
			allData.setEmpId(empId);  
			allData.setPhoneExt(phoneExt); 
			allData.setSpeedDial(speedDial); 
			
			allData.setCreditCardNo(creditCardNo); 
			allData.setExpiryDate(expiryDate); 
			allData.setCostOverride(costOverride); 
			allData.setAllowChangePeriodJe(allowChangePeriodJe); 
			allData.setShowLoginPopUp(showLoginPopUp); 
			allData.setFinancialEmail(financialEmail); 
			allData.setSoHelp(soHelp); 
			allData.setAllowClosePaymentReceipt(allowClosePaymentReceipt); 
			allData.setVehicleAdmin(vehicleAdmin); 
			allData.setIcrCorporate(icrCorporate); 
			allData.setWrTransferAccess(wrTransferAccess); 
			allData.setCommPermission(commPermission); 
			allData.setAuthorizedCode(authorizedCode); 
			allData.setAllowAuthorized(allowAuthorized); 
			allData.setAuthorizedAmount(authorizedAmount); 
			allData.setAllowPayTraceAllWhse(allowPayTraceAllWhse); 
			allData.setCashReportPermission(cashReportPermission); 
			allData.setAllowSugContractPricApproval(allowSugContractPricApproval); 
			allData.setNewItemRequestEmail(newItemRequestEmail); 
			allData.setOverrideDeliveryCost(overrideDeliveryCost); 
			allData.setAllowPODeliveryPrint(allowPODeliveryPrint); 
			allData.setTwoWayAuth(twoWayAuth); 
			
			
			
			allData.setDeptId(deptId); 
			allData.setDateOfBirth(dateOfBirth); 
			
			//userDaoImpl.updateRow(allData);
			
			try {
				sessionH = sessionFactory.openSession();
				sessionH.clear();
				sessionH.beginTransaction();
				sessionH.saveOrUpdate(allData);
				Serializable id = sessionH.getIdentifier(allData);
				sessionH.getTransaction().commit();
				Utils.log("User updated id "+ id);
			} catch (HibernateException he) {
				Utils.log("Error save : ", he);
				sessionH.getTransaction().rollback();
				throw new Exception(he);
			} finally {
				sessionH.close();
			}
			
		} catch (Exception e) {
			Utils.log("<P>ArglDistMaintenance.updateRecord: failed", e);
			throw new ProcessingErrorException(e, labelFileName);
		}
	}

	public void updatedBy(HttpServletRequest request) throws Exception {
		HttpSession session = request.getSession();
		du = DistUtils.getDistUtils(session);
		Connection con = null;
		Statement st = null;
		String userId = null;
		String updatedBy = null;
		String companyId = null;
		try {
			con = du.getDataConnection();
			updatedBy = DistUtils.getUserId(session);
			userId = Utils.getParameterString("userId", request);
			String mobile = Utils.getParameterString("mobile", request);
			companyId = (String) session.getAttribute("companyId");
			String query = "INSERT INTO USERUPDATEHISTORY (COMPANYID, USERID, UPDATEDBY, UPDATEDATE, "
					+ " UPDATETIME, MOBILE)VALUES ('" + companyId + "', '" + userId + "', '" + updatedBy
					+ "', SYSDATE, TO_CHAR(SYSDATE, 'HH12:MI:SS AM'), '" + mobile + "')";
			st = con.createStatement();
			st.executeUpdate(query);
		} catch (Exception e) {
			Utils.log("<P>EtechUserMaintenance.deleteRecord:", e);
		} finally {
			Utils.close(st);
			Utils.close(con);
		}
	}

	public void deleteRecord(HttpServletRequest request) throws Exception, ServletException, IOException {
		boolean required = true;
		String userId = "";
		HttpSession session = request.getSession();
		du = DistUtils.getDistUtils(session);
		u = DistUtils.getUtils(session);
		//EtechUserDaoImpl userDaoImpl = new EtechUserDaoImpl();
		try {
			
			userId = Utils.getParameterString("userId", required, request);
			//userDaoImpl.deleteRow(userId);
			
			Session sessionH = null;
			try {
				sessionH = sessionFactory.openSession();
				sessionH.beginTransaction();
				EtechUser user = (EtechUser) sessionH.load(EtechUser.class, userId);
				sessionH.delete(user);
				sessionH.getTransaction().commit();
				Serializable ids = sessionH.getIdentifier(user);
				Utils.log("User deleted id "+ ids);
			} catch (HibernateException he) {
				Utils.log("Error save : ", he);
				sessionH.getTransaction().rollback();
				throw new Exception(he);
			} finally {
				sessionH.close();
			}
			
		} catch (Exception e) {
			Utils.log("<P>EtechUserMaintenance.deleteRecord:", e);
			throw new ProcessingErrorException(e, labelFileName);
		}
	}

	public void createRecord(HttpServletRequest request) throws SQLException, ServletException, IOException, Exception {
		boolean required = true;
		String userId = "";
		String userType = "";
		String groupId = "";
		String userInitials = "";
		String firstName = "";
		String middleName = "";
		String lastName = "";
		String address = "";
		String city = "";
		String state = "";
		String zip = "";
		String phone = "";
		String fax = "";
		String mobile = "";
		String password = "";
		Date passwordExpiryDate;
		String defaultPrinter = "";
		String defaultWarehouse = "";
		String x = "";
		String status = "";
		String showRebateCost = "";
		String defaultCompanyId = "";
		String allowChangeReceiptWhse = "";
		String defaultPersonalPrinter = "";
		String emailId = "";
		String empId = "";
		String phoneExt = "";
		String speedDial = "";
		String deptId = "";
		Date dateOfBirth;

		HttpSession session = request.getSession();
		userId = (String) session.getAttribute("sessionId");
		du = DistUtils.getDistUtils(session);
		u = DistUtils.getUtils(session);

		try {
			//EtechUserDaoImpl userDaoImpl = new EtechUserDaoImpl();
			EtechUser etechUser = new EtechUser();
			etechUser.setUserId( Utils.getParameterString("userId", required, request));
			etechUser.setUserType(Utils.getParameterString("userType", required, request));
			etechUser.setGroupId(Utils.getParameterString("groupId", required, request));
			etechUser.setUserInitials(Utils.getParameterString("userInitials", required, request));
			etechUser.setFirstName(Utils.getParameterString("firstName", required, request));
			etechUser.setMiddleName(Utils.getParameterString("middleName", request));
			etechUser.setLastName(Utils.getParameterString("lastName", required, request));
			etechUser.setAddress(Utils.getParameterString("address", request));
			etechUser.setCity(Utils.getParameterString("city", request));
			etechUser.setState(Utils.getParameterString("state", request));
			etechUser.setZip(Utils.getParameterString("zip", request));
			etechUser.setPhone(Utils.getParameterString("phone", request));
			etechUser.setFax(Utils.getParameterString("fax", request));
			etechUser.setMobile(Utils.getParameterString("mobile", request));
			etechUser.setPassword(Utils.getParameterString("password", required, request));
			etechUser.setPasswordExpiryDate(getParameterDate("passwordExpiryDate", "standardDateFormat", request));
			etechUser.setDefaultPrinter(Utils.getParameterString("defaultPrinter", request));
			etechUser.setDefaultWarehouse(Utils.getParameterString("defaultWarehouse", required, request));
			etechUser.setX(Utils.getParameterString("x", request));
			etechUser.setStatus(Utils.getParameterString("status", required, request));
			etechUser.setShowRebateCost(Utils.getParameterCheck("showRebateCost", request));
			etechUser.setDefaultCompanyId(Utils.getParameterString("defaultCompanyId", request));
			etechUser.setAllowChangeReceiptWhse(Utils.getParameterString("allowChangeReceiptWhse", request));
			etechUser.setDefaultPersonalPrinter(Utils.getParameterString("defaultPersonalPrinter", request));
			etechUser.setEmailId(Utils.getParameterString("emailId", request));
			etechUser.setEmpId(Utils.getParameterString("empId", request));
			etechUser.setPhoneExt(Utils.getParameterString("phoneExt", request));
			etechUser.setSpeedDial(Utils.getParameterString("speedDial", request));
			
			etechUser.setCreditCardNo(Utils.getParameterString("creditCardNo", request));
			etechUser.setExpiryDate(getParameterDate("expiryDate", "standardDateFormat", request));
			etechUser.setCostOverride(Utils.getParameterString("costOverride", request));
			etechUser.setAllowChangePeriodJe(Utils.getParameterString("allowChangePeriodJe", request));
			etechUser.setShowLoginPopUp(Utils.getParameterString("showLoginPopUp", request));
			etechUser.setFinancialEmail(Utils.getParameterString("financialEmail", request));
			etechUser.setSoHelp(Utils.getParameterString("soHelp", request));
			etechUser.setAllowClosePaymentReceipt(Utils.getParameterString("allowClosePaymentReceipt", request));
			etechUser.setVehicleAdmin(Utils.getParameterString("vehicleAdmin", request));
			etechUser.setIcrCorporate(Utils.getParameterString("icrCorporate", request));
			etechUser.setWrTransferAccess(Utils.getParameterString("wrTransferAccess", request));
			etechUser.setCommPermission(Utils.getParameterString("commPermission", request));
			etechUser.setAuthorizedCode(Utils.getParameterString("authorizedCode", request));
			etechUser.setAllowAuthorized(Utils.getParameterString("allowAuthorized", request));
			etechUser.setAuthorizedAmount(Utils.getParameterDouble("authorizedAmount", 30, 2, request));
			etechUser.setAllowPayTraceAllWhse(Utils.getParameterString("allowPayTraceAllWhse", request));
			etechUser.setCashReportPermission(Utils.getParameterString("cashReportPermission", request));
			etechUser.setAllowSugContractPricApproval(Utils.getParameterString("allowSugContractPricApproval", request));
			etechUser.setNewItemRequestEmail(Utils.getParameterString("newItemRequestEmail", request));
			etechUser.setOverrideDeliveryCost(Utils.getParameterString("overrideDeliveryCost", request));
			etechUser.setAllowPODeliveryPrint(Utils.getParameterString("allowPODeliveryPrint", request));
			etechUser.setTwoWayAuth(Utils.getParameterString("twoWayAuth", request));			
			
			etechUser.setDeptId(Utils.getParameterString("deptId", request));
			etechUser.setDateOfBirth(getParameterDate("dateOfBirth", "standardDateFormat", request));
			//userDaoImpl.insertRow(etechUser);
			
			
			Session sessionH = null;
			try {
				sessionH = sessionFactory.openSession();
				sessionH.beginTransaction();
				sessionH.saveOrUpdate(etechUser);
				Serializable id = sessionH.getIdentifier(etechUser);
				// return new Long((Long)id).intValue();
				String userIdSaved = (String) id;
				Utils.log("userId Saved : "+userIdSaved);
				sessionH.getTransaction().commit();
			} catch (HibernateException he) {
				Utils.log("Error save : ", he);
				sessionH.getTransaction().rollback();
				throw new Exception(he);
			} finally {
				sessionH.close();
			}
			
		} catch (Exception e) {
			Utils.logError(e.getMessage(), e);
			throw new ProcessingErrorException(e, labelFileName);
		}
	}

	public EtechUserRestore setRestoreObject(HttpServletRequest request, EtechUserRestore tr) throws Exception {
		String userId = "";
		HttpSession session = request.getSession();
		u = DistUtils.getUtils(session);
		du = DistUtils.getDistUtils(session);
		//EtechUserDaoImpl userDaoImpl = new EtechUserDaoImpl();
		EtechUser etechUser = null;
		try {
			String standardDateFormat=(String)session.getAttribute("standardDateFormat");
			userId = Utils.getParameterString("userId", true, request);
			//etechUser = userDaoImpl.getRowById(userId);
			
			Session sessionH = null;
			try {
				sessionH = sessionFactory.openSession();
				sessionH.beginTransaction();
				DetachedCriteria criteria = DetachedCriteria.forClass(EtechUser.class);
				criteria.add(Restrictions.eq("userId", userId));
				etechUser = (EtechUser) criteria.getExecutableCriteria(sessionH).uniqueResult();
				
			} catch (HibernateException he) {
				Utils.log("Error save : ", he);
				throw new Exception(he);
			} finally {
				sessionH.close();
			}
			
			if(etechUser != null){
				tr.USERID= Utils.removeNull(etechUser.getUserId());
				tr.USERTYPE= Utils.removeNull(etechUser.getUserType());
				tr.GROUPID= Utils.removeNull(etechUser.getGroupId());
				tr.USERINITIALS= Utils.removeNull(etechUser.getUserInitials());
				tr.FIRSTNAME= Utils.removeNull(etechUser.getFirstName());
				tr.MIDDLENAME= Utils.removeNull(etechUser.getMiddleName());
				tr.LASTNAME= Utils.removeNull(etechUser.getLastName());
				tr.ADDRESS= Utils.removeNull(etechUser.getAddress());
				tr.CITY= Utils.removeNull(etechUser.getCity());
				tr.STATE=  Utils.removeNull(etechUser.getState());
				tr.ZIP=  Utils.removeNull(etechUser.getZip());
				tr.PHONE=  Utils.removeNull(etechUser.getPhone());
				tr.FAX= Utils.removeNull(etechUser.getFax());
				tr.MOBILE=  Utils.removeNull(etechUser.getMobile());
				tr.PASSWORD=  Utils.removeNull(etechUser.getPassword());
				tr.EMAILID= Utils.removeNull(etechUser.getEmailId());
				tr.SHOWREBATECOST= Utils.removeNull(etechUser.getShowRebateCost());
				tr.DATEOFBIRTH= getDateString( etechUser.getDateOfBirth(), standardDateFormat);

				tr.PASSWORDEXPIRYDATE= getDateString( etechUser.getPasswordExpiryDate(), standardDateFormat);
				tr.DEFAULTPRINTER= Utils.removeNull(etechUser.getDefaultPrinter());
				tr.DEFAULTWAREHOUSE= Utils.removeNull(etechUser.getDefaultWarehouse());
				tr.X= Utils.removeNull(etechUser.getX());
				tr.STATUS= (String) (etechUser.getStatus()!=null ? etechUser.getStatus().trim() : "I"); 
				tr.DEFAULTCOMPANYID= Utils.removeNull(etechUser.getDefaultCompanyId());
				tr.ALLOWCHANGERECEIPTWHSE= (String) (etechUser.getAllowChangeReceiptWhse()!=null ? etechUser.getAllowChangeReceiptWhse().trim() : "N"); 
				tr.DEFAULTPERSONALPRINTER= Utils.removeNull(etechUser.getDefaultPersonalPrinter());
				tr.EMPID= Utils.removeNull(etechUser.getEmpId());
				tr.PHONEEXT= Utils.removeNull(etechUser.getPhoneExt());
				tr.SPEEDDIAL= Utils.removeNull(etechUser.getSpeedDial());
				
				tr.CREDITCARDNO = Utils.removeNull(etechUser.getCreditCardNo());
				tr.EXPIRYDATE = getDateString( etechUser.getExpiryDate(), standardDateFormat); 
				tr.COSTOVERRIDE = (String) (etechUser.getCostOverride()!=null ? etechUser.getCostOverride().trim() : "N");
				tr.ALLOWCHANGEPERIODJE = (String) (etechUser.getAllowChangePeriodJe()!=null ? etechUser.getAllowChangePeriodJe().trim() : "N"); 
				tr.SHOWLOGINPOPUP = (String) (etechUser.getShowLoginPopUp()!=null ? etechUser.getShowLoginPopUp().trim() : "N"); 
				tr.FINANCIALEMAIL = (String) (etechUser.getFinancialEmail()!=null ? etechUser.getFinancialEmail().trim() : "N"); 
				tr.SOHELP = (String) (etechUser.getSoHelp()!=null ? etechUser.getSoHelp().trim() : "N"); 
				tr.ALLOWCLOSEPAYMENTRECEIPT  = (String) (etechUser.getAllowClosePaymentReceipt()!=null ? etechUser.getAllowClosePaymentReceipt().trim() : "N"); 
				tr.VEHICLEADMIN =(String) (etechUser.getVehicleAdmin()!=null ? etechUser.getVehicleAdmin().trim() : "N");  
				tr.ICRCORPORATE = (String) (etechUser.getIcrCorporate()!=null ? etechUser.getIcrCorporate().trim() : "N"); 
				tr.WRTRANSFERACCESS = (String) (etechUser.getWrTransferAccess()!=null ? etechUser.getWrTransferAccess().trim() : "N");
				tr.COMMPERMISSION = (String) (etechUser.getCommPermission()!=null ? etechUser.getCommPermission().trim() : "SLF");
				tr.AUTHORIZEDCODE =Utils.removeNull(etechUser.getAuthorizedCode());
				tr.ALLOWAUTHORIZED = (String) (etechUser.getAllowAuthorized()!=null ? etechUser.getAllowAuthorized().trim() : "N");
				tr.AUTHORIZEDAMOUNT = Utils.removeNull(etechUser.getAuthorizedAmount() + "");
				tr.ALLOWPAYTRACEALLWHSE = (String) (etechUser.getAllowPayTraceAllWhse()!=null ? etechUser.getAllowPayTraceAllWhse().trim() : "N"); 
				tr.CASHREPORTPERMISSION = (String) (etechUser.getCashReportPermission()!=null ? etechUser.getCashReportPermission().trim() : "N");
				tr.ALLOWSUGCONTRACTPRICAPPROVAL = (String) (etechUser.getAllowSugContractPricApproval()!=null ? etechUser.getAllowSugContractPricApproval().trim() : "N"); 
				tr.NEWITEMREQUESTEMAIL = (String) (etechUser.getNewItemRequestEmail()!=null ? etechUser.getNewItemRequestEmail().trim() : "N"); 
				tr.OVERRIDEDELIVERYCOST = (String) (etechUser.getOverrideDeliveryCost()!=null ? etechUser.getOverrideDeliveryCost().trim() : "N"); 
				tr.ALLOWPODELIVERYPRINT = (String) (etechUser.getAllowPODeliveryPrint()!=null ? etechUser.getAllowPODeliveryPrint().trim() : "N"); 
				tr.TWOWAYAUTH = (String) (etechUser.getTwoWayAuth()!=null ? etechUser.getTwoWayAuth().trim() : "N"); 
				
				tr.DEPTID= Utils.removeNull(etechUser.getDeptId());
			} else{
				throw new RecordNotFoundException("EtechUserKey","EtechUser");
			}
		} catch (Exception ex) {
			Utils.log("EtechUserProcess.setRestoreObject(): failed", ex);
			throw new ProcessingErrorException(ex, labelFileName);
		} 
		return tr;
	}
	
	/**
	 * returns a Date type Form parameter. if it does not exist, throws
	 * exception.
	 */
	public static Date getParameterDate(String paramName, String paramName1, HttpServletRequest request)
			throws ParameterNotFoundException, InvalidParameterException {
		String date1 = request.getParameter(paramName);
		String format = request.getParameter(paramName1);
		if (date1 == null)
			throw new ParameterNotFoundException(paramName);
		if (format == null)
			throw new ParameterNotFoundException(paramName1);
		date1 = date1.toLowerCase();
		format = format.toLowerCase().replace("m", "M");	
		Utils.log("Date1 : " + date1 + " Format :   " + format);
		date1 = date1.trim();
		format = format.trim();
		if (date1.equals("") || format.equals(""))
			return null;
		
		Date newDate = null;
		
		try {
			SimpleDateFormat df = new SimpleDateFormat(format);
			newDate = df.parse(date1);
		} catch (Exception e) {
			Utils.log("Error in date format: ", e);
			throw new InvalidParameterException(paramName + "&&" + format);
		}
		return newDate;
	}
	
	/**
	 * returns a String from date 
	 * exception.
	 */
	public static String getDateString(Date date1, String format) {
		
		if (date1 == null)
			return ""; 
		if (format == null)
			return ""; 
		Utils.log("date format coming "+ format);
		format = format.toLowerCase().replace("m", "M");	
		Utils.log("date format changed "+ format);
		String newDate = "";
		
		try {
			SimpleDateFormat df = new SimpleDateFormat(format);
			newDate = df.format(date1);
		} catch (Exception e) {
			Utils.log("Error in date format: to String", e);
		}
		return newDate;
	}
}
