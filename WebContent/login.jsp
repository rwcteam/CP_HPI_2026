<% 
	String message=(String)request.getAttribute("message");
	if(message == null || message == "")
		message="";
		
%>

<!doctype html>
<html lang="en">
  <head>
    <title>JHPI Sign In</title> 
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="NewPortalAssets/assets/css/profile_style.css" rel="stylesheet">

   	<script>

		$(document).ready(function() {
			setFoc();
  		});

 		$('#loginUserID').keypress(function(event){
	  		if(event.keyCode == 13){
	    		$('#image1').click();
	  		}
		});


		function newWindow(file,window){
			msgWindow=open(file,window,'resizable=no, scrollbars=yes, width=440,height=270');
			if(msgWindow.opener==null) 
				msgWindow.opener = self;
		}

		function chageCompanyId(){
			if(!MandatoryInput("Company Id", document.Login.companyId))
				return false
			document.Login.Submit.value="ChangeCompany";
			document.Login.submit();
		}

		function chagePassword(){
			if(!MandatoryInput("Password", document.Login.password))
				return false
			document.Login.Submit.value="GetCompanies";
			document.Login.submit();
		}

		function checkValue(){
			if(!MandatoryInput("User Id", document.Login.userId)){
				document.applets.msg.repaint();
				return false
			}
			else if(!MandatoryInput("Password", document.Login.password)){
				document.applets.msg.repaint();
				return false
			}
			else if(!MandatoryInput("Company Id", document.Login.companyId)){
				document.applets.msg.repaint();
				return false
			}
			else if(document.Login.warehouse.value=="" || document.Login.warehouse.value==" "){
				document.applets.msg.repaint();
				return false
			}
			else
				return true;
		}

		function onEnter(){
			if(event.keyCode==13){		
				if(checkValue())
					submitPage();
			}
		}


		function submitPage(){
			document.Login.Submit.value="Sign In";
			if(checkValue())
				document.Login.submit();
		}

		function menusGo(){
		}

		function showMessage1(message){
			//var show=document.applets.msg;
			if(trim(message)!=""){
				//document.all.Page.style.pixelTop=40;
				document.all.emessage.innerText='';
				document.all.emessage.innerHTML='<table width=100%><tr height="30"><td class="errorMessage">'+message+'</td></tr></table>';
				document.all.emessage.style.visibility="visible";
				//show.setMessage(message);
			}
		}

		
		function setFoc(){
			if(document.forms[0].companyId.value=="")
				document.forms[0].userId.focus();  //setFocus();
			else
				document.forms[0].image1.focus();
		}

		function showmsg(){
			setTimeout("showMessage1('<!--message-->')", 500)
		}

	</script>
	
  </head>
  <body onload="getCookieData()">

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
                        <h2 class="mb-3 font-weight-bold text-center">Sign In</h2>
                        <h7 class="mb-3 font-weight-bold text-center"  style="color: red;"><%=message%></h7>
                        <!-- <p class="text-center">To Keep connected with us please login with your personal info</p> -->
                        
                        <!-- <form class="pt-3" action="../customerPortal/A_CP_OpenInvoices.jsp" method="post"> -->
						<form name="Login" class="pt-3" action="login" method="post">
                           <div class="row mt-2">
                              <div class="col-lg-12">
                                 <div class="form-group">
                                    <label class="text-secondary">User Id</label>
                                    <input class="form-control" type="text" name="userId" id="userId" placeholder="User Id" onBlur="capLostFocus(this)">
                                 </div>
                              </div>                              
                           </div>
                           <div class="row mt-2">
                              <div class="col-lg-12">
                                 <div class="form-group">
                                    <label class="text-secondary">Password</label>
                                    <input class="form-control" type="password" name="password" id="password" placeholder="Password" onChange="capLostFocus(this);chagePassword()">
                                 </div>
                              </div>
                           </div>
                           <div class="row mt-2">
                               <div class="col-lg-6">
                                  <div class="form-group">
                                   <div class="checkbox">
                                      <label>
                                        <input type="checkbox" name="check_box" class="checkbox_type" onclick="setCookie()" >
                                        <i class="helper"></i>Remember Me</label>
                                    </div>
                                  </div>
                              </div>
                               <div class="col-lg-6 m-auto text-center">
                                    <a href="../customerPortal/A_CP_ForgetPassword.jsp" target="_blank" class="float-end">Forgot Password?</a>
                               </div>                               
                           </div>
                           <div class="form-group">
          						<!-- <input type="hidden" name="companyId" value="1"> -->      
          						<!-- <input type="hidden" name="warehouse" value="PHX"> -->  
          						
	           					<input type="hidden" name="websiteId" value="distribution">
          						<input type="hidden" name="actionCode" value="Login">
          						<input type="hidden" name="tempPoNumber" >
          						<input type="hidden" name="priceMask">          
          						<input type="hidden" name="standardDateFormat">          
          						<input type="hidden" name="allowNonStock">          
          						<input type="hidden" name="deptId">   		  
		  						<input type="hidden" name="Submit" value="Sign In">
		  						<input type="hidden" name="deliveryValue" value="CustomerDeliveryPortal">						
                           </div>							
                           <div class="row mt-2">
                               <div class="col-lg-12 text-center">
                                    <button type="submit" onClick="submitPage()" class="btn btn-danger btn-block mt-2">Sign In</button>
                               </div>                               
                           </div>
                           <div class="col-lg-12 mt-4">
                                <p class="mb-0 text-center">Don't have an account? <a href="../customerPortal/A_CP_SignUp.jsp" target="_blank">Request for Sign Up</a></p>
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

    
    
	    <script type="text/javascript">
			
			function setCookie() {
				var u = document.getElementById('userId').value;
				var p = document.getElementById('password').value;
				
				document.cookie="username="+u+";path=http://portaltest.rwc.org/";
				document.cookie="password="+p+";path=http://portaltest.rwc.org/";
				
			}
	
			function getCookieData() {
				//alert(document.cookie);
				//console.log(document.cookie);
				//var user=getCookie('usrname');
				//var pwd=getCookie('pswd');
				
				const username = getUsernameFromCookie();
				const password = getPasswordFromCookie();
				document.getElementById('userId').value = username;
				document.getElementById('password').value = password;
			}
			
			function getCookie(cname){
				var name = cname + "=";
				var decodeCookie = decodeURIComponent(document.cookie);
				var ca = decodeCookie.split(';');
				for(var i=0; i<ca.length; i++){
					var c = ca[i];
					while(c.charAt(0) == ''){
						c = c.substring(1);
					}
					if(c.indexOf(name) == 0){
						return c.substring(name.length, c.length);
					}
				}
				return "";
			}
			
			// Get the value of the 'username' cookie
			function getUsernameFromCookie() {
				const cookies = document.cookie.split(';');
			  	for (var i = 0; i < cookies.length; i++) {
				    const cookie = cookies[i].trim();
				    // Check if the cookie starts with 'username='
				    if (cookie.startsWith('username=')) {
				    	return cookie.substring('username='.length, cookie.length);
			    	}
				}
			  	// If 'username' cookie not found, return null
				return null;
			}
			
			
			// Get the value of the 'password' cookie
			function getPasswordFromCookie() {
				const cookies = document.cookie.split(';');
			  	for (var i = 0; i < cookies.length; i++) {
				    const cookie = cookies[i].trim();
				    // Check if the cookie starts with 'password='
				    if (cookie.startsWith('password=')) {
				    	return cookie.substring('password='.length, cookie.length);
			    	}
				}
			  	// If 'password' cookie not found, return null
			  	return null;
			}

			
		</script>
	</body>
</html>

<% 
	session.setAttribute("loginstatus","true");
%>
