
var test = function(){
    var javaPatternsList = [], viewPatternsList = [];
	var javaPatternsArray = $(".javaPatterns"), 
	viewPatternsArray=$(".viewPatterns");  
	for(var i = 0; i<javaPatternsArray.length; i++){
	    javaPatternsList.push(javaPatternsArray[i].innerText); 
	}
	for(i = 0; i<viewPatternsArray.length; i++){
	    viewPatternsList.push(viewPatternsArray[i].innerText); 
	}
}

var init = function(){
 	/*if($.cookie("u_baseDir")){
 		$("#u_baseDir").val($.cookie("u_baseDir")); 
 	}else if($.cookie("baseDir")){
		$("#u_baseDir").val($.cookie("baseDir")); 
 	}*/

 	$("#input_javaDir").val($.cookie("javafileDir"));
	$("#input_viewDir").val($.cookie("viewfileDir"));
	
	if($.cookie("u_messagefileDir")!= null || $.cookie("u_messagefileDir") != undefined){
		$("#u_messagefileDir").val($.cookie("u_messagefileDir")); 
	}else{ 
		$("#u_messagefileDir").val($.cookie("messagefileDir")); 
	}
	$(".resultContainer").hide(); 
}

var addEvent = function(){
	
	$(".choosefile").on("click", function(e) {
	    getMessageFile();
	});
	
	/*$(".btn_editCookie").on("click", function(){
		    
	}); */
	
	$(".addBtn").on("click", function(e){
	    // 새로운 item을 그위에 있는  container에 추가 한다. 
	    var itemName = $(this).data("itemName");
	    var $itemContainer = $("#"+itemName+"_container");  
	    var itemValue = $("#input_"+itemName).val(); 
	    var itemBox =  $("<span class='itemBox'><button type='button' class='btn deleteBox' data-role='button'>x</button></span>");
	    var span = $("<span></span>").addClass(itemName).text(itemValue); 
	    itemBox.prepend(span);  
	    $itemContainer.append(itemBox); 
	    $("#input_"+itemName).val("");
	}); 
	
	$("#using_form").on("submit", function(e){
		e.preventDefault();
		getUsingResult(); 
	});
	
	// 동적으로 생기는 버튼들.. 
	$(document).on("click", ".deleteBox", function(e){
		$(this).parent().remove(); 
	}); 
	$(document).on("click", ".deleteMsg", function(e) {
	    var $code = $(this).parents("td");
	    if ($code.hasClass("deleted")) {// 삭제 취소 버튼이니까 삭제를 취소 해줘야 함. 
		$code.removeClass("deleted");
		$(this).text("삭제");
	    } else {
		$code.addClass("deleted");
		$(this).text("삭제취소");
	    }
	});
	$(document).on("click",".btn_editMsgFile", function(){
	    var $messagefile = $(".msgfile_cb:checked");
		files = []; 
		$messagefile.each(function(e) {
		    files.push( $(this).val()); // 나중에 불러온 파일을 수정하기 위해 파라미터 생성 
		});
		editMessagefile();
	});
}//addEvent
var setCookieValue = function(u_msgDir){
//var setCookieValue = function(u_baseDir, u_msgDir){
	//modal table 에 값을 넣고 
	var confirmbody = '<p> 전체 페이지의 기본 경로와 입력하신 기본 경로가 다릅니다. </p><p> 현재 입력하신 경로로 수정 하시려면 [기본경로수정] 버튼을 눌러주세요.</p>'
				+ '<table class="table table-striped"> <thead><colgroup><col width="20%"><col width="40%"><col width="40%"></colgruop><tr><th></th><th>Previous</th><th>YourInput</th></tr></thead>' 
	      			+'<tbody>'
	      			//+'<tr><th scope="row">기본 경로</th><td class="cookie_basedir">'+$.cookie("baseDir")+'</td><td class="now_basedir">'+u_baseDir+'</td></tr>' 
	      			+'<tr><th scope="row">메시지파일기본경로</th><td class="cookie_msgdir">'+$.cookie("messagefileDir")+'</td><td class="now_msgdir">'+u_msgDir+'</td></tr>'
	      			+'</tbody></table>'; 

	if($.cookie("messagefileDir")!== u_msgDir){
	//if($.cookie("baseDir")!== u_baseDir||$.cookie("messagefileDir")!== u_msgDir){
	    util.getConfirm("기본 설정 변경", confirmbody, function(result){
		    if(result){
				//$.cookie("baseDir", u_baseDir);
				$.cookie("messagefileDir", u_msgDir);
		    }
		})	
	}
	//$.cookie("u_baseDir", u_baseDir);
	$.cookie("u_messagefileDir", u_msgDir);
	
} 
	
var getMessageFile = function() {
	util.progressBar("start");
	 // var u_baseDir =  $("#u_baseDir").val().replace(/\\/gi, "/"), 
	var u_msgDir = $("#u_messagefileDir").val().replace(/\\/gi, "/"); 
	 
	//setCookieValue(u_baseDir, u_msgDir);  
	 setCookieValue(u_msgDir);  
	
	var url = contextPath+"/checkMsg/getFilelist";
	var form_data = {
	    baseDir : "",
	    messagefileDir : u_msgDir
	}
	$.ajax({
	    method : "POST",
	    url : url,
	    contentType : "application/json",
	    //messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
	    data : JSON.stringify(form_data),
	    error : function(xhr, status, error) {
		alert(error);
		util.progressBar("stop");
	    },
	    success : function(data) {
			if (data.err != null || data.err !== "" || data.err != undefined) {
			    displayRadio(data);
			} else {
			    alert(data.err);
			}
	    }

	});
	util.progressBar("stop");
}
var displayRadio = function(data) {
	var radioArea = $(".radioArea").html("");
	var radio = $("<input type='radio'>"), label = $("<label></label>");
	var checkbox = $("<input type='checkbox'>"), label = $("<label></label>");
	var div = $("<div></div>").addClass("clearfix");
	messagefile = data.messagefile;
	var $modalBody = $("#chooseFileModal").find(".modal-body"); 
	$.each(messagefile, function(key, value) {
	    var fileName =  key.split(".")[0]; 
	    var messageitem = div.clone().addClass("radio radio-primary").html(label.clone().attr("for", key.split(".")[0]).text(key)).prepend(radio.clone().attr({
		"id" : fileName,
		"class" : "msgfile_r styled",
		"name" : "standardMsg", 
		"value" : value
	    }));
	    // 메시지를 삭제할 메시지 파일을 modal창에 표시 할 체크 박스 
	    var fileItem =  div.clone().css("padding","0 3em").addClass("checkbox checkbox-primary").html(label.clone().attr("for", "edit_"+key.split(".")[0]).text(key)).prepend(checkbox.clone().attr({
		"class" : "msgfile_cb styled",
		"name" : "eidtfiles", 
		"id"	: "edit_"+fileName, 
		"value" : fileName
	    }));
	    $modalBody.append(fileItem); 
	    radioArea.append(messageitem).show();
	});
}
var getUsingResult = function(){
    debugger;
	/*$.cookie("javafileDir", $("#input_javaDir").val().replace(/\\/gi, "/")); 		
	$.cookie("viewfileDir", $("#input_viewDir").val().replace(/\\/gi, "/")); */		

	var url = contextPath+"/checkMsg/usingMessage"; 
	var javaDirList = [$("#input_javaDir").val()], viewDirList = [$("#input_viewDir").val()];
	var javaPatternsList = [], viewPatternsList = [];
	
	$.each( $(".javaPattern"), function(index,value){
	    javaPatternsList.push(this.innerText); 
	})
	$.each($(".viewPattern"), function(index,value){
	    viewPatternsList.push(this.innerText); 
	})
	$.each($(".javaDir"), function(index, value){
	    javaDirList.push(this.innerText); 
	}); 
	$.each($(".viewDir"), function(index,value){
	    viewDirList.push(this.innerText); 
	})
	
	var standardfile = $(".msgfile_r:checked").val();
	
	var form_data = {
		baseDir: "",
		javafileDirs: javaDirList,
		javaPatterns: javaPatternsList, 
		viewPatterns: viewPatternsList, 
		viewfileDirs: viewDirList,
		standardMsgfileDir: standardfile
	}
	
	util.progressBar("start");
	
	var request = $.ajax({
	    method: "POST",
	    url: url,
	    contentType:"application/json; charset=UTF-8",
	    //messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
	    data:JSON.stringify(form_data),
	    error: function(xhr, status, error){
		alert(error);
	    },
	    success: function(data){
			if(data.err != null ||data.err != undefined){
			    alert(data.err); 
			}else{
			    displayUsingResult(data); 
			    $(".resultContainer").show(); 
			}
	    }
	    
	});
	util.progressBar("stop"); 
}
var displayUsingResult =  function(data){
    $(".u_formContainer").hide();
    var table = $("<table><colgroup><col width='30%'/><col width='70%'/></colgroup></table>"),
	caption = $("<caption></caption>"), 
	thead = $("<thead></thead>"), 
	tbody = $("<tbody></tbody>"), 
	tr = $("<tr></tr>"), 
	td = $("<td></td>"),
	pTag = $("<p></p>"),
	span = $("<span></span>"); 
    // 삭제만 제공 
    var btn = $("<div class='clearfix'><button type='button' class='btn btn-danger deleteMsg pull-right' data-role='button'>삭제</button></div>");
    
    var newTable = table.clone().addClass("table table-bordered table-striped table-condensed").html(thead.clone().html(tr.clone().html(
		td.clone().text("code")).append(td.clone().text("파일 정보 (사용한 codeline)"))));
    var newBody = tbody.clone().html(""); 
	    $.each(data.haveToAdd, function(key,value){
		newBody.append(tr.clone().addClass("danger").html(td.clone().html(key))
			//tr에 td append  
			.append(td.clone().html(value.split("\n")[0])
				.append(pTag.clone().text( value.split("\n")[1])))); 
		    newTable.append(newBody); 
		}); 
		newTable.append(caption.clone().html("추가해야 하는 messageCode 확인하세요."));
		
	 $("#using_result").append(newTable);
	 
	var newTable_2 = table.clone().addClass("table table-bordered table-striped table-condensed").html(thead.clone().html(tr.clone().html(
		td.clone().text("code")).append(td.clone().text("java"))));
	var newBody_2 = tbody.clone().html(""); 
		$.each(data.mappedMsg, function(key,value){
		    var newTr = tr.clone().html(td.clone().html(pTag.clone().addClass("code").html(key.split("\n")[0])).append(pTag.clone().addClass("valueString").html(key.split("\n")[1])).append(btn.clone())); 
			var newTd = td.clone().html(""); 
			if(value === "" || value == undefined || value == null){
			    newTd.append(pTag.clone().text("사용하지 않는 메시지 입니다.")); 
			    newBody_2.prepend(newTr.append(newTd).addClass("warning"));
			}else{
			    var valArr = value.split("\n");  
			    $.each(valArr, function(idx, arr_val){
					newTd.append(pTag.clone().text(arr_val)); 
			    }); 
			    newBody_2.append(newTr.append(newTd));
			}
		}); 
		newTable_2.append(newBody_2);  
		newTable_2.append(caption.clone().html("사용하지 않는 메시지를 확인하세요.."));  
		var editBtn = $("<div class='form-group col-sm-12'> <button type='button' class='btn btn-primary btn-block' data-toggle='modal' data-target='#chooseFileModal'> 선택한 메시지를 삭제한 파일 생성</button> </div>"); 
		$("#using_result").append(editBtn).append(newTable_2);
}


var editMessagefile = function() {
	alert("edit");
	util.progressBar("start");
	var param = createData();
	var url = contextPath+"/checkMsg/editMsgfile";
	var request = $.ajax({
		    method : "POST",
		    url : url,
		    contentType : "application/json",
		    //messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
		    data : JSON.stringify(param),
		    error : function(xhr, status, error) {
			alert(error);
		    },
		    success : function(data) {
				if (data.err != null || data.err !== "" || data.err != undefined) {
				    alert(data.result);
				    //TODO  " 메시지를 다시 불러오시겠습니까 ? "
				} else {
				    alert(data.err);
				}
	   		}
	});

	util.progressBar("stop");
}

var createData = function() {
	var deleteMessages = []; // code만 들어감. 

	$(".deleted").each(function(e) {
	    deleteMessages.push($(this).find(".code").text());
	});
	// update 기능 지원 안함.. 
	var updateMessages = [];
	var param = {}; 
	
	param.deletemsg = deleteMessages;  
	param.updatemsg = updateMessages; 
	param.folderPath = $("#u_messagefileDir").val();
	param.files = files; 

	return param;
}