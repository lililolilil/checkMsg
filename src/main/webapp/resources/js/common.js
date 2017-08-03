"use strict"; 

    var util = {
	   /**
	    * 파라미터를 변환해줌. 
	    */
	getParameter :  function(){
		try{
			var paramObj = new Object();
			
			var query = window.location.search.substring(1),
				vars = query.split("&");
			
			for( var i=0; i < vars.length; i++ ){
			     var pair = vars[i].split("=");

			     paramObj[ pair[0] ] = pair[1];
			}
			
			return paramObj;
		} catch(e) {
		    alert("파라미터 오류 "); 
		}
	}, 
	progressBar : function(order){
	    var $mybar = $("#myBar"); 
	    var everyms, after5, after10; 
	    if(order === "start"){
			$("#progressbar").modal("show"); 
			var width = 1;  
			$mybar.removeClass("progress-bar-danger").removeClass("progress-bar-warning").addClass("progress-bar-success");
			everyms = setInterval(frame, 10); 
		    after5 = setTimeout(warning, 1000*5);// 5초 이후에 warning으로 바꾸자... 
		    after10 = setTimeout(danger, 1000*10);
		    
	    }else{
			$("#progressbar").modal("hide"); 
			clearInterval(everyms);
			clearInterval(after5);
			clearInterval(after10);
	    }
	    
	    function frame(){
			if(width >= 100){
			    clearInterval(everyms); 
			}
			++width; 
		 	$mybar.width(width+"%");
		}
		function warning(){
			$mybar.removeClass("progress-bar-success").addClass("progress-bar-warning"); 
		}
		function danger(){
			$mybar.removeClass("progress-bar-warning").addClass("progress-bar-danger"); 
		}
	}
	

    }
