<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>
<%@page import="java.text.DecimalFormat"%>

<% 
	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();

	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}
	String userId = (String)session.getAttribute("userId");
	
	String firstName = (String)session.getAttribute("firstName");
	String middleName = (String)session.getAttribute("middleName");
	String lastName = (String)session.getAttribute("lastName");
	String address = (String)session.getAttribute("address");
	String state = (String)session.getAttribute("state");
	String city = (String)session.getAttribute("city");
	String zip = (String)session.getAttribute("zip");
	String phone = (String)session.getAttribute("phone");
	String emailId = (String)session.getAttribute("emailId");
	
	String message = (String)request.getAttribute("message");
	if( message == null)
		message="";
	
	String stateList="";
	ArrayList<HashMap<String, String>> listData = getStateList();
	for (int i=0; i< listData.size();i++){
		HashMap mapData = (HashMap)listData.get(i);
		stateList+="<option value='"+mapData.get("stateId")+"'>"+mapData.get("stateId")+"</option>";
	}

%>

<!-- HEADER-->
<%@ include file="A_CP_Header.jsp" %>
<!-- END HEADER-->

<style>
    html,
    body {
        height: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
    }
    
    #ChangePasswordForm .form-group i {
	    position: absolute;
	    top: 18px;
	    transform: translateY(-50%);
	    right: 15px;
    }
    
    #ChangePasswordForm .form-control.is-invalid{
    	background-image:none;
    }
</style>

<section class="py-5 profile-page">
	<div class="container">
    	<div class="row">
        	<div class="col-xl-7 col-lg-9 col-md-12 mx-auto">
		    	<div class="card border-0 shadow-sm bg-white">
		        	<div class="card-body p-4 p-lg-5">
		            	<h6 class="text-uppercase mb-0"><img src="NewPortalAssets/assets/images/icons/userprofile.png" width="40px" alt=""> User Profile</h6>
		                <p class="m-0 text-center text-success p-2"><%=message %></p>
		                <form name="UserProfileForm" class="pt-4" method="post">
		                	<div class="row mt-2">
		                    	<div class="col-lg-4 col-md-4">
		                        	<input type="hidden" name="param" id="param" value="SaveOrUpdateUserDetails">
		                            <div class="form-group">
		                            	<label>First Name</label>
		                                <input type="text" name="firstName" id="firstName" value="<%=firstName %>" class="form-control">
		              				</div>
		            			</div>
		                		<div class="col-lg-4 col-md-4">
		                        	<div class="form-group">
		                            	<label>Middle Name</label>
		                           		<input type="text" name="middleName" id="middleName" value="<%=middleName %>" class="form-control">
		                          	</div>
		                  		</div>
		                       	<div class="col-lg-4 col-md-4">
		                        	<div class="form-group">
		                            	<label>Last Name</label>
		                                <input type="text" name="lastName" id="lastName" value="<%=lastName %>" class="form-control">
		                       		</div>
		                		</div>
		           			</div>
		                    <div class="row mt-2"> 
		                    	<div class="col-lg-12">
		                        	<div class="form-group">
		                            	<label>Address</label>
		                                <input type="text" name="address" id="address" value="<%=address %>" class="form-control">
		                      		</div>
		               			</div>
		            		</div>
		                    <div class="row mt-2">
		                    	<div class="col-lg-4 col-md-4">
		                        	<div class="form-group">
		                            	<label>City</label>
		                                <input type="text" name="city" id="city" value="<%=city %>" class="form-control">
		                   			</div>
		                		</div>
		           				<div class="col-lg-4 col-md-4">
		                        	<div class="form-group">
		                            	<label>State</label>
										<select name="state" id="state" class="form-control" required="">
											<option value="<%=state %>" selected><%=state %></option>
											<%=stateList %>
										</select>
		                     		</div>
		               			</div>
		                        <div class="col-lg-4 col-md-4">
		                        	<div class="form-group">
		                            	<label>Zip</label>
		                                <input type="text" name="zip" id="zip" value="<%=zip %>" class="form-control">
		                       		</div>
		                  		</div>
		        			</div>
		                    <div class="row mt-2"> 
		                    	<div class="col-lg-6 col-md-6">
		                        	<div class="form-group">
		                            	<label>Phone#</label>
		                                <input type="text" name="phone" id="phone" value="<%=phone %>" class="form-control">
		                       		</div>
		               			</div>
		                 		<div class="col-lg-6 col-md-6">
		                        	<div class="form-group">
		                            	<label>Email</label>
		                                <input type="text" name="emailId" id="emailId" value="<%=emailId %>" class="form-control">
		                            </div>
		                         </div>                             
		               		</div>
		                    <div class="row mt-2 justify-content-between">
                            	<div class="col-md-4 order-md-1">                   
                                	<button type="button" class="btn btn-danger mt-2 w-100" onclick="saveDetails()">Submit</button>
                       			</div>
                                <div class="col-md-4">
                                	<button type="button" class="btn btn-outline-danger mt-2 w-100" onclick="popupForChangePassword()">Change Password</button>                                            
                               	</div>         
		                  	</div>
		                    <!-- <div class="col-lg-12 mt-4">
		                    	<p class="mb-0 text-center">Do you have an account? <a href="CustomerLogin.jsp">Log In</a></p>
		           			</div> -->
		   				</form>
		   			</div>
				</div>
			</div>
		</div>
	</div>
</section>

<div class="modal" id="ChangePasswordModal" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="ChangePasswordModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content rounded-0">
            <div class="modal-header">
                <h5 class="modal-title" id="ChangePasswordModalTitle"><img src="NewPortalAssets/assets/images/icons/changepassword.png" width="30px" alt=""> Change Password</h5>
                <button type="button" onclick="" class="close small opacity-100 text-dark" data-dismiss="modal" aria-label="Close"><i class="icon-close-flat small"></i></button>
            </div>
            <div class="modal-body">
				<div class="card rounded-0 border-0 w-100">
                    <div class="card-body p-0">
                    	<p class="m-0 text-center text-success p-2" id="msg"></p>
                        <form name="ChangePasswordForm" id="ChangePasswordForm" method="post">
	                        <div class="row"> 
		                        <div class="col-lg-12 col-md-12">
		                        	<label for="currentPassword">Current Password <span class="text-danger small">*</span></label>
		                            <div class="form-group position-relative">
			                            <input type="password" name="currentPassword" id="currentPassword" placeholder="Current Password" class="form-control">
			                            <i id="toggleCurrentPassword" class="icon-visible"></i>
		                            	<div class="invalid-feedback">Please Enter Current Password</div>
		                            </div>
		                        </div>
    							<div class="col-lg-12 col-md-12">
    								<label for="newPassword">New Password <span class="text-danger small">*</span></label>
		                            <div class="form-group position-relative">
	                       				<input type="password" name="newPassword" id="newPassword" placeholder="New Password" class="form-control">
	                   					<i id="toggleNewPassword" class="icon-visible"></i>
			                            <div class="invalid-feedback">Please Enter New Password</div>
									</div>
	                        	</div>
                       			<div class="col-lg-12 col-md-12">
    								<label for="confirmNewPassword">Confirm New Password <span class="text-danger small">*</span></label>
	                       			<div class="form-group position-relative">
		                       			<input type="password" name="confirmNewPassword" id="confirmNewPassword" placeholder="Confirm New Password" class="form-control">
		                   				<i id="toggleConfirmNewPassword" class="icon-visible"></i>
										<div class="invalid-feedback">Please Enter Confirm New Password</div>
    								</div>
	                   			</div>
	                        </div>
	                        <div class="text-right">                          
	                        	<button type="button" class="btn btn-danger mt-4" onclick="changePassword()" id="changePassBtn">Submit</button>
	                        </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- START FOOTER-->
<%@ include file="A_CP_Footer.jsp" %>
<!-- END FOOTER-->

<script>
$(document).ready(function () {
    var email = $('#emailId').val();

    if (email.length > 6) {
        var maskedEmail = email.substring(0, 3) +
                          '*'.repeat(email.length - 6) +
                          email.substring(email.length - 3);

        $('#emailId').val(maskedEmail);
    }
});
</script>



<script type="text/javascript">

	function saveDetails(){
		debugger;
		var firstName = document.getElementById('firstName').value;
		var middleName = document.getElementById('middleName').value;
		var lastName = document.getElementById('lastName').value;
		var emailId = document.getElementById('emailId').value;
		var address = document.getElementById('address').value;
		var city = document.getElementById('city').value;
		var state = document.getElementById('state').value;
		var zip = document.getElementById('zip').value;
		var phone = document.getElementById('phone').value;
			
		if(firstName == "" || firstName == null ){
			alert("Please Enter First Name");
			return false;
		}
		else if(middleName == "" || middleName == null ){
			alert("Please Enter Middle Name");
			return false;
		}
		else if(lastName == "" || lastName == null ){
			alert("Please Enter Last Name");
			return false;
		}
		else if(emailId == "" || emailId == null ){
			alert("Please Enter Email");
			return false;
		}
		else if(address == "" || address == null ){
			alert("Please Enter Address");
			return false;
		}
		else if(city == "" || city == null ){
			alert("Please Enter City");
			return false;
		}
		else if(state == "" || state == null ){
			alert("Please Enter State");
			return false;
		}
		else if(zip == "" || zip == null ){
			alert("Please Enter Zip");
			return false;
		}
		else if(phone == "" || phone == null ){
			alert("Please Enter Phone");
			return false;
		}
		else{
			document.UserProfileForm.action="../customerPortal/A_CP_UserProfileAction.jsp";
			document.UserProfileForm.submit();	        
		}
	}

	function popupForChangePassword(){
		//window.open("../customerPortal/A_CP_ChangePassword.jsp", 'popup','width=750,height=500,left=250,top=100,screenX=300,screenY=100,resizable=no,scrollbars=no');
		$('#msg').html('');
		$('#ChangePasswordModal').modal('show');
	}

	function changePassword(){
		debugger;
		var parameters;
		var currentPassword = document.getElementById('currentPassword').value;
		var currentPasswordTextBox = document.getElementById('currentPassword');
		var newPassword = document.getElementById('newPassword').value;
		var newPasswordTextBox = document.getElementById('newPassword');
		var confirmNewPassword = document.getElementById('confirmNewPassword').value;
		var confirmNewPasswordTextBox = document.getElementById('confirmNewPassword');
		
		if(currentPassword == "" || currentPassword == null ){
			currentPasswordTextBox.classList.add("is-invalid");
			currentPasswordTextBox.focus();
			return false;
		}
		else if(newPassword == "" || newPassword == null ){
			newPasswordTextBox.classList.add("is-invalid");
			newPasswordTextBox.focus();
			return false;
		}
		else if(confirmNewPassword == "" || confirmNewPassword == null ){
			confirmNewPasswordTextBox.classList.add("is-invalid");
			confirmNewPasswordTextBox.focus();
			return false;
		}
		else{
			parameters="param=ChangePassword&currentPassword="+currentPassword+"&newPassword="+newPassword+"&confirmNewPassword="+confirmNewPassword;
			$.ajax({
 			 	url: "../customerPortal/A_CP_UserProfileAction.jsp",
 				type : "POST",
 				dataType: "text",
 				data: parameters,
 				success: function (response) {
					$('#msg').html(response); 						
 				},
 			 	failure: function (response) {
 			    }
 			});
		}
	}


	const toggleCurrentPassword=document.querySelector("#toggleCurrentPassword");
	const currentPassword=document.querySelector("#currentPassword");
	toggleCurrentPassword.addEventListener('click', function (e) {
		const type=currentPassword.getAttribute('type') === 'password' ? 'text' : 'password';
		currentPassword.setAttribute('type',type);
		this.classList.toggle('icon-eyehide');
	});

	
	const toggleNewPassword=document.querySelector("#toggleNewPassword");
	const newPassword=document.querySelector("#newPassword");
	toggleNewPassword.addEventListener('click', function (e) {
		const type=newPassword.getAttribute('type') === 'password' ? 'text' : 'password';
		newPassword.setAttribute('type',type);
		this.classList.toggle('icon-eyehide');
	});

	
	const toggleConfirmNewPassword=document.querySelector("#toggleConfirmNewPassword");
	const confirmNewPassword=document.querySelector("#confirmNewPassword");
	toggleConfirmNewPassword.addEventListener('click', function (e) {
		const type=confirmNewPassword.getAttribute('type') === 'password' ? 'text' : 'password';
		confirmNewPassword.setAttribute('type',type);
		this.classList.toggle('icon-eyehide');
	})

		
	function exit2(){
		parent.location='../customerPortal/A_CP_Logout.jsp';
	}
	
</script>

<%!
	public ArrayList<HashMap<String, String>> getStateList(){
		String query="",filterString = "";
		ArrayList<HashMap<String, String>> listData = new ArrayList<HashMap<String,String>>();
		HashMap<String, String> temp = null;
		try {
			DistUtils du = new DistUtils();
			query=" select STATEID,NAME from STATE ";
			Utils.log("Query :: "+query);
			Hashtable ht=du.getDataFromQuery(query);	
			Vector stateIdVector = new Vector();
			Vector stateNameVector = new Vector();
			if (ht != null && ht.size() != 0) {
				stateIdVector = (Vector) ht.get("STATEID");
				stateNameVector = (Vector) ht.get("NAME");
			}
	        if (stateIdVector.size() > 0) {
	        	for (int i = 0; i < stateIdVector.size(); i++) {  
	        		temp = new HashMap<String,String>();
	        		temp.put("stateId", stateIdVector.get(i).toString());
	        		temp.put("stateName", stateNameVector.get(i).toString());
	        		listData.add(temp);
				}
			}
		}
		catch(Exception exception) {
			Utils.log("Exception" ,exception);	
		}
		return listData;
	}

%>

