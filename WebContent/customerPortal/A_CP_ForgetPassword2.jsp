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
    <title>Sign In</title>
	<!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet">

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
	                        <h2 class="mb-3 font-weight-bold text-center">Reset Password</h2>
	                        <!-- <p class="text-center small text-secondary mb-3">You can reset your password here</p> -->
	                        <h6 style="color: red; text-align: center;"><%=message %></h6>
	                        <form class="pt-3" action="A_CP_UserProfileAction.jsp?param=ForgetPassword" method="post">
	                           <div class="row mt-2">
	                              <div class="col-lg-12">
	                                 <div class="form-group">
	                                    <label class="text-secondary">Email Address</label>
	                                    <input type="text" name="emailId" id="emailId" value="<%=emailId %>" placeholder="Email Address" class="form-control">
	                                 </div>
	                              </div>
	                           </div>
	                           <div class="row mt-2">                               
	                               <div class="col-lg-12 text-center">
	                                    <button type="submit" class="btn btn-danger btn-block mt-2">Reset Password</button>
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
    
    <!--<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
    	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>-->
    
</body>
</html>
