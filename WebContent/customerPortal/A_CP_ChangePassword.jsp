<%@page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.etechlogix.utils.*" %>
<%@page import="com.etechlogix.distribution.utils.*" %>
<%@page import="com.etechlogix.distribution.mobileapp.servlet.S3_Upload" %>


<% 

	HttpSession sess = request.getSession(false);
	if(sess==null){
		%><jsp:forward page="../login.jsp" /><%
	}
	DistUtils du=new DistUtils();
	//du=DistUtils.getDistUtils();
	
	String companyId = (String)session.getAttribute("companyId");
	if (companyId == null){%><jsp:forward page="../login.jsp" /><%}

	String message=(String)request.getAttribute("message");
	if(message == null)
		message="";

%>

<!doctype html>
<html lang="en">
	<head>
	    <title>Change Password</title>
	    <!-- Required meta tags -->
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	
	    <!-- Bootstrap CSS -->
	    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
	    <link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet">
	    
	    <!-- Font Awesome Icons -->
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">


	<style type="text/css">
	
		.oldPassword-icon{
			position: absolute;
			top: 34%;
			right: 8%;
			cursor: pointer;
		}


		.newPassword-icon{
			position: absolute;
			top: 52%;
			right: 8%;
			cursor: pointer;
		}

		.confirmNewPassword-icon{
			position: absolute;
			top: 72%;
			right: 8%;
			cursor: pointer;
		}
	
	
	</style>

	<script type="text/javascript">

		function changePassword(){
			debugger;
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
				document.ChangePasswordForm.action="../customerPortal/A_CP_UserProfileAction.jsp";
				document.ChangePasswordForm.submit();	        
			}
		}
		
		/* function changePassword(){
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
				parameters="param=UpdatePassword&currentPassword="+currentPassword+"&newPassword="+newPassword+"&confirmNewPassword="+confirmNewPassword;
				$.ajax({
	 			 	url: "../customerPortal/A_CP_UserProfileAction.jsp",
	 				type : "POST",
	 				dataType: "text",
	 				data: parameters,
	 				success: function (response) {
						$('#errorMsg').html(response); 						
	 				},
	 			 	failure: function (response) {
	 			    }
	 			});
			}
		} */

	</script>


	</head>
<body>

	<div class="wrapper">
    	<section class="login-content">
        	<div class="container h-100">
            	<div class="row align-items-center justify-content-center h-100">
           			<div class="col-lg-5 col-md-8">
                  		<div class="card p-3">
                     		<div class="card-body">
                        		<div class="auth-logo text-center">
                           			<!-- <img src="NewPortalAssets/assets/images/logo.png" width="120" class="img-fluid rounded-normal light-logo" alt="logo"> -->
                        		</div>
                        		<h2 class="mb-3 font-weight-bold text-center">Change Password</h2>
                        		<h6 style="color: red; text-align: center;"><%=message %></h6>
                        		<form name="ChangePasswordForm" class="pt-3" method="post">
                           			<input type="hidden" name="param" id="param" value="UpdatePassword">
                           			<div class="row mt-2">
                              			<div class="col-lg-12">
                                 			<div class="form-group">
                                    			<label class="text-secondary">Old Password</label>
                                    			<input type="password" name="currentPassword" id="currentPassword" placeholder="Old Password" class="form-control" required>
                                 				<i id="toggleOldPassword" class="fa fa-eye oldPassword-icon"></i>
                                 			</div>
                              			</div> 
                           			</div>
                           			<div class="row mt-2">
                              			<div class="col-lg-12">
                                 			<div class="form-group">
                                    			<label class="text-secondary">New Password</label>
                                    			<input type="password" name="newPassword" id="newPassword" placeholder="New Password" class="form-control" required>
                                 				<i id="toggleNewPassword" class="fa fa-eye newPassword-icon"></i>
                                 			</div>
                              			</div>
                           			</div>
                           			<div class="row mt-2">
                              			<div class="col-lg-12">
                                 			<div class="form-group">
                                    			<label class="text-secondary">Confirm New Password</label>
                                    			<input type="password" name="confirmNewPassword" id="confirmNewPassword" placeholder="Confirm New Password" class="form-control" required>
                                 				<i id="toggleConfirmNewPassword" class="fa fa-eye confirmNewPassword-icon"></i>
                                 			</div>
                              			</div>
                           			</div>
                           			<div class="row mt-2">                               
                               			<div class="col-lg-12 text-center">
                                    		<button type="button" class="btn btn-danger btn-block mt-2" onclick="changePassword()">Submit</button>
                               			</div>                               
                           			</div>
                        		</form>
                     		</div>
                  		</div>
               		</div>
            	</div>
         	</div>
      	</section>
	</div>

    <!-- Option 1: Bootstrap Bundle with Popper -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.0/jquery.min.js" type="text/javascript"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Option 2: Separate Popper and Bootstrap JS -->
    <!--
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>
    -->
    
	<script>
		const toggleOldPassword=document.querySelector("#toggleOldPassword");
		const oldPassword=document.querySelector("#oldPassword");
		toggleOldPassword.addEventListener('click', function (e) {
			const type=oldPassword.getAttribute('type') === 'password' ? 'text' : 'password';
			oldPassword.setAttribute('type',type);
			this.classList.toggle('fa-eye-slash');
		});

		
		const toggleNewPassword=document.querySelector("#toggleNewPassword");
		const newPassword=document.querySelector("#newPassword");
		toggleNewPassword.addEventListener('click', function (e) {
			const type=newPassword.getAttribute('type') === 'password' ? 'text' : 'password';
			newPassword.setAttribute('type',type);
			this.classList.toggle('fa-eye-slash');
		});

		
		const toggleConfirmNewPassword=document.querySelector("#toggleConfirmNewPassword");
		const confirmNewPassword=document.querySelector("#confirmNewPassword");
		toggleConfirmNewPassword.addEventListener('click', function (e) {
			const type=confirmNewPassword.getAttribute('type') === 'password' ? 'text' : 'password';
			confirmNewPassword.setAttribute('type',type);
			this.classList.toggle('fa-eye-slash');
		})
    </script>
    
</body>
</html>
