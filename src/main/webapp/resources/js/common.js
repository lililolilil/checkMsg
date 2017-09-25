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
	},

	getConfirm : function(confirmTitle, confirmMessage, callback){
	    var confirmMessage = confirmMessage || ''; 
	    var confirmTitle = confirmTitle || ''; 

	    $("#confirmBox").modal({
		show: true, 
		backdrop: false, 
		keyboard: false
	    }); 
	    $("#confirmBody").html(confirmMessage);  
	    $("#confirmTitle").html(confirmTitle); 
	    $("#confirmNo").click(function(){
		$("#confirmBox").modal("hide");  
		if(callback) callback(false); 
	    }); 
	    $("#confirmYes").click(function(){
		$("#confirmBox").modal("hide"); 
		if(callback) callback(true);  
	    });
	},
	/**
	 * regex는 리터럴 $obj는 input 
	 */
	validateData : function($obj, regex){
	    if(regex === null || regex == undefined){
		regex = $obj.data("valid"); 
	    }
	    var regExp = new RegExp(regex,'gi');
	    var guide = $obj.attr("placeholder"); 
	    var data = $obj.val(); 
	    if(data.match(regExp)==null){
		alert(guide); 
		$obj.focus(); 
		return false
	    }else{
		return true
	    }
	}, 

	nullCheck : function($obj){
	    debugger; 
	}, 
	
	restoreDate : function(longDate){
	    date = new Date(longDate); 
	}, 
	
	Calendar : function(newDate){
		if(newDate == null){
			this.date = new Date(); 
		}

		this.date = newDate; 

		this.set = function(newDate) {
			this.date = newDate;
		};

		this.get = function() {
			return this.date;
		};

		this.getToday = function(){
			return new Date(); 
		}

		this.getLongTime = function() {
			return this.date.getTime();
		};

		this.setLongTime = function(millisec) {
			return this.date.setTime(millisec);
		};
		
		/**
		 * time_txt = 00:00:00 
		 */
		this.setTxtTime = function(time_txt){
			var time = time_txt.split(":"); 
			this.date.setHours(time[0]); 
			this.date.setMinutes(time[1]); 
			this.date.setSeconds(time[2]); 
		}
		
		this.getTxtTime = function(){
			return this.date.setHours() + ":" + this.date.setMinutes() +":" +this.date.setSeconds();
		}
		
		this.addDay = function( day ) {
			this.setLongTime(this.getLongTime() + day * 86400000);
		}

		this.getYear = function() {
			return this.date.getFullYear();
		};

		this.setYear = function(year) {
			this.date.setFullYear(year);
		};

		this.getMonth = function() {
			return this.date.getMonth()+1;
		};

		this.setMonth = function(month) {
			this.date.setMonth(month-1);
		};

		this.getDayOfMonth = function() {
			return this.date.getDate();
		};

		this.setDayOfMonth = function(dayOfMonth) {
			this.date.setDate(dayOfMonth);
		};

		this.getDayOfWeek = function() {
			return this.date.getDay();
		};

		this.getLastDay = function(){
			return new Date(this.date.getYear(), (this.date.getMonth())+1, 0); 
		}
		
		this.getStartDay = function(){
			return new Date(this.date.getYear(), (this.date.getMonth())+1, 1); 
		}

		this.setDayOfWeek = function(dayOfWeek) {
			this.addDay(this.getDayOfWeek() * -1);
			this.addDay(dayOfWeek);
		};	

		this.setDate = function( year, month, dayOfMonth ) {
			this.setYear(year);
			this.setMonth(month);
			this.setDayOfMonth(dayOfMonth);
		};

		this.getyyyyMMdd = function() {
			return this.getYear() + "-" + fillZero(this.getMonth(), 2) + "-" + fillZero(this.getDayOfMonth(), 2);
		};
		
		function fillZero(value, length) {
			var result = "" + value;

			for( var step = result.length; step < length; step++ ) {
				result = "0" + result;
			}

			return result;
		}
	}
}

