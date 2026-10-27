<% 
	String message=(String)request.getAttribute("message");
	if(message == null)
		message="";

	String emailId=(String)request.getAttribute("emailId");
	if(emailId == null)
		emailId="";

%>

<!doctype html>
<html lang="en">
<head>
    <title>Request for Sign Up of Customer Portal</title>
	<!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet">

	<script type="text/javascript">
	    
		function signUpRequest(){
			debugger;
			var companyName = document.getElementById('companyName').value;
			var rwcCustomerId = document.getElementById('rwcCustomerId').value;
			var firstName = document.getElementById('firstName').value;
			var lastName = document.getElementById('lastName').value;
			var emailId = document.getElementById('emailId').value;
			var phoneNo = document.getElementById('phoneNo').value;
			var recaptchaResponse = grecaptcha.getResponse();

			if(companyName == "" || companyName == null ){
				alert("Please Enter Company Name");
				return false;
			}
			else if(rwcCustomerId == "" || rwcCustomerId == null ){
				alert("Please Enter RWC Customer Id");
				return false;
			}
			else if(firstName == "" || firstName == null ){
				alert("Please Enter First Name");
				return false;
			}
			else if(lastName == "" || lastName == null ){
				alert("Please Enter Last Name");
				return false;
			}
			else if(emailId == "" || emailId == null ){
				alert("Please Enter Email Address");
				return false;
			}
			else if(recaptchaResponse.length == 0){
				alert("Please complete the reCAPTCHA");
				return false;
			}
			else{
				const re = /\S+@\S+\.\S+/;
				if(!re.test(emailId)){
					alert("Please Enter Valid Email Address");
					return false;
				}
				else{
					if(phoneNo == "" || phoneNo == null ){
						alert("Please Enter Phone Number");
						return false;
					}
					else{
						var phno=/^\d{10}$/;
						if(!phoneNo.match(phno)){
							alert("Phone no must be ten digit");
							return false;
						}
						else{
							document.SignUpForm.action="A_CP_UserProfileAction.jsp?param=SignUp";
							document.SignUpForm.submit();	        
						}
					}
				}
			}
		}
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
	                           <img src="NewPortalAssets/assets/images/logo.png" width="120" class="img-fluid rounded-normal light-logo" alt="logo">
	                        </div>
	                        <h6 class="mb-3 font-weight-bold text-center">Sign up Request for Customer Portal Access</h6>
							<h7><p style="text-align: center;"><i style="color:red; text-align: center;">All fields are mandatory</i></p></h7>
							<!-- <p class="text-center small text-secondary mb-3">You can reset your password here</p> -->
	                        <h6 style="color: red; text-align: center;"><%=message %></h6>
	                        <form name="SignUpForm" class="pt-3" action="" method="post">
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">COMPANY NAME</label>
	                                    <input type="text" name="companyName" id="companyName" value="" placeholder="Company Name" class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">RWC CUSTOMER#</label>
	                                    <input type="text" name="rwcCustomerId" id="rwcCustomerId" value="" placeholder="RWC Customer Id" class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>	                           
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">FIRST NAME</label>
	                                    <input type="text" name="firstName" id="firstName" value="" placeholder="First Name" class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">LAST NAME</label>
	                                    <input type="text" name="lastName" id="lastName" value="" placeholder="Last Name" class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">EMAIL ID</label>
	                                    <input type="text" name="emailId" id="emailId" value="" placeholder="Email Address" class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">PHONE NO</label>
	                                    <input type="number" name="phoneNo" id="phoneNo" value="" placeholder="Phone No." class="form-control" required>
	                                 </div>
	                              </div>
	                           </div>
	                           
	                           <div class="row mt-2">                               
	                               <div class="col-lg-12 text-center">
	                                    <div class="g-recaptcha" data-sitekey="6LdChiwsAAAAAAnjDqHAdE47uQvN7Sl8R70F8R15"></div>
	                                    <button type="button"  onclick="signUpRequest()" class="btn btn-danger btn-block mt-2">Submit</button>
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

    <!-- reCaptcha -->
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>

    <!-- Option 2: Separate Popper and Bootstrap JS -->
    <!--<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
    	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>-->
    
</body>
</html>
