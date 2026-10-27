

	<!-- COPYRIGHT-->
<section class="py-2 bg-danger text-center mt-auto bg-light">
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="copyright">
                    <p class="m-0"><a href="https://www.rwc.org" target="_blank" class="text-white border-bottom">RWC Building Products</a></p>
                </div>
            </div>
        </div>
    </div>
</section>
	<!-- END COPYRIGHT-->



	<!-- Jquery JS-->
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js" ></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js" ></script>

	<!-- Jquery JS-->
	<!-- <script src="NewPortalAssets/vendor/jquery-3.2.1.min.js"></script> -->

	<!-- ImageViewer JS-->
	<!--<script type="text/javascript" src="https://unpkg.com/bootstrap@4/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
	<script type="text/javascript" src="https://unpkg.com/jquery@3/dist/jquery.slim.min.js" crossorigin="anonymous"></script>-->
	<script src="NewPortalAssets/assets/js/viewer.js"></script>

	<!-- DataTable JS-->
	<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.3.1/js/dataTables.buttons.min.js"></script> 
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>

	<!-- Bootstrap JS-->
	<script src="NewPortalAssets/vendor/bootstrap-4.1/popper.min.js"></script>
	<script src="NewPortalAssets/vendor/bootstrap-4.1/bootstrap.min.js"></script>
	<!-- <script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script> -->

	<!-- Vendor JS -->
	<script src="NewPortalAssets/vendor/slick/slick.min.js"></script>
	<script src="NewPortalAssets/vendor/wow/wow.min.js"></script>
	<script src="NewPortalAssets/vendor/animsition/animsition.min.js"></script>
	<script src="NewPortalAssets/vendor/bootstrap-progressbar/bootstrap-progressbar.min.js"></script>
	<script src="NewPortalAssets/vendor/counter-up/jquery.waypoints.min.js"></script>
	<script src="NewPortalAssets/vendor/counter-up/jquery.counterup.min.js"></script>
	<script src="NewPortalAssets/vendor/circle-progress/circle-progress.min.js"></script>
	<script src="NewPortalAssets/vendor/perfect-scrollbar/perfect-scrollbar.js"></script>
	<script src="NewPortalAssets/vendor/chartjs/Chart.bundle.min.js"></script>
	<script src="NewPortalAssets/vendor/select2/select2.min.js"></script>
	<script src="NewPortalAssets/vendor/dopeNav.js"></script>

	<!-- Chart JS-->
	<script src="https://cdn.canvasjs.com/canvasjs.min.js"></script>
	<!-- <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.js"></script> -->

	<!-- Main JS-->
	<!-- <script src="NewPortalAssets/js/main.js"></script> -->

	<script type="text/javascript">
		$('#dopeNav').dopeNav();
	</script>
	
	<script>
		/* When the user clicks on the button, 
		toggle between hiding and showing the dropdown content */
		function myFunction() {
		  document.getElementById("myDropdown").classList.toggle("show");
		}
		
		// Close the dropdown if the user clicks outside of it
		window.onclick = function(event) {
		  if (!event.target.matches('.dropbtn')) {
		    var dropdowns = document.getElementsByClassName("dropdown-content");
		    var i;
		    for (i = 0; i < dropdowns.length; i++) {
		      var openDropdown = dropdowns[i];
		      if (openDropdown.classList.contains('show')) {
		        openDropdown.classList.remove('show');
		      }
		    }
		  }
		}

	    /*This is for Datatables default search place holder*/
	    $('.dataTables_filter input').attr('placeholder', 'Search items...');

	   	function showChangeCustomerModal(){
	   		$('#ChangeCustomerModal').modal().show();
		}
		
	   	function hideChangeCustomerModal(){
	   		$('#ChangeCustomerModal').modal().hide();	
	   		window.location.reload();
	   	}

		function changeCustomerId(){
			var customerId = document.getElementById('customerId').value;
			var customerIdBox = document.getElementById('customerId');
			if(customerId == "" || customerId == null ){
				customerIdBox.classList.add("is-invalid");
				customerIdBox.focus();
				return false;
			}
			else{
				$.ajax({
				 	url:"../customerPortal/A_CP_ChangeCustomerAction.jsp?param=ChangeCustomerId&customerId="+customerId,
					type : "POST",
					dataType: "text",
					success: function (response) {
						$('#msg').html(response);
					},
				 	failure: function (response) {
				    }
				});
			}
		}		
	

	        window.addEventListener('load', function () {
			$('#preloader').addClass('d-none');
       		});
	
	</script>
</body>
</html>
