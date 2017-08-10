<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<script>
$(document).ready(function(){
   // test(); 
    init(); 
    addEvent(); 
})

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
 	if($.cookie("u_baseDir")){
 		$("#u_baseDir").val($.cookie("u_baseDir")); 
 	}else if($.cookie("baseDir")){
		$("#u_baseDir").val($.cookie("baseDir")); 
 	}
	// 귀찮으니까 테스트 할때는 박아놓자 
	$("#javafileDir").val($.cookie("javafileDir"));
	$("#viewfileDir").val($.cookie("viewfileDir"));
	
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
	
	$(".btn_editCookie").on("click", function(){
		    
	}); 
	
	$(".addBtn").on("click", function(e){
	    // 새로운 정규식 추가 
	    var newReg = $(this).prev().val();
	   	var regBox = $("<span class='patternBox'><button type='button' class='btn deletePT' data-role='button'>x</button></span>");
		var addValue = $(this).data("addvalue"); 
	   	var span = $("<span></span>").addClass(addValue).text(newReg); 
		regBox.prepend(span);  
		$(this).prevAll("[id$=_basicPatterns]").append(regBox); 
	}); 
	
	$("#using_form").on("submit", function(e){
		e.preventDefault();
		getUsingResult(); 
	});
	
	// 동적으로 생기는 버튼들.. 
	$(document).on("click", ".deletePT", function(e){
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
var setCookieValue = function(u_baseDir, u_msgDir){
   
		
	//modal table 에 값을 넣고 
	var confirmbody = '<p> 전체 페이지의 기본 경로와 입력하신 기본 경로가 다릅니다. </p><p> 현재 입력하신 경로로 수정 하시려면 [기본경로수정] 버튼을 눌러주세요.</p>'
					+ '<table class="table table-striped"> <thead><colgroup><col width="20%"><col width="40%"><col width="40%"></colgruop><tr><th></th><th>Previous</th><th>YourInput</th></tr></thead>' 
	      			+'<tbody> <tr><th scope="row">기본 경로</th><td class="cookie_basedir">'+$.cookie("baseDir")+'</td><td class="now_basedir">'+u_baseDir+'</td></tr>' 
	      			+'<tr><th scope="row">메시지파일기본경로</th><td class="cookie_msgdir">'+$.cookie("messagefileDir")+'</td><td class="now_msgdir">'+u_msgDir+'</td></tr></tbody></table>'; 

	if($.cookie("baseDir")!== u_baseDir||$.cookie("messagefileDir")!== u_msgDir){
	    util.getConfirm("기본 설정 변경", confirmbody, function(result){
		    if(result){
				$.cookie("baseDir", u_baseDir);
				$.cookie("messagefileDir", u_msgDir);
		    }
		})	
	}
	$.cookie("u_baseDir", u_baseDir);
	$.cookie("u_messagefileDir", u_msgDir);
	
} 
	
var getMessageFile = function() {
	util.progressBar("start");
	 var u_baseDir =  $("#u_baseDir").val().replace(/\\/gi, "/"), 
	     u_msgDir = $("#u_messagefileDir").val().replace(/\\/gi, "/"); 
	 
	setCookieValue(u_baseDir, u_msgDir);  
	
	var url = "${pageContext.request.contextPath}/checkMsg/getFilelist";
	var form_data = {
	    baseDir : u_baseDir,
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
	    // modal창에 표시 할 체크 박스 
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
	$.cookie("javafileDir", $("#javafileDir").val().replace(/\\/gi, "/")); 		
	$.cookie("viewfileDir", $("#viewfileDir").val().replace(/\\/gi, "/")); 		
	
	var url = "${pageContext.request.contextPath}/checkMsg/usingMessage"; 
	var javaPatternsList = [], viewPatternsList = [];
	var javaPatternsArray = $(".javaPatterns"), 
	viewPatternsArray=$(".viewPatterns");  
	
	for(var i = 0; i<javaPatternsArray.length; i++){
	    javaPatternsList.push(javaPatternsArray[i].innerText); 
	}
	for(i = 0; i<viewPatternsArray.length; i++){
	    viewPatternsList.push(viewPatternsArray[i].innerText); 
	}
	var standardfile = $(".msgfile_r:checked").val();
	
	var form_data = {
		baseDir: $("#u_baseDir").val(),
		javafileDir: $("#javafileDir").val(),
		javaPatterns: javaPatternsList, 
		viewPatterns: viewPatternsList, 
		viewfileDir: $("#viewfileDir").val(),
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
	var url = "${pageContext.request.contextPath}/checkMsg/editMsgfile";
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
	param.folderPath = $.cookie("u_baseDir") + $.cookie("u_messagefileDir");
	param.files = files; 

	return param;
}
</script>

<div id="u_container">
	<div class="well u_formContainer">
		<form id="using_form" role="form">
			<div class="form-group">
				<label for="u_baseDir">baseDir:</label> <input type="text"
					class="form-control" id="u_baseDir" name="u_baseDir"
					placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
					required="required">
			</div>
			<div class="form-group">
				<label for="javafileDir">javafileDir:</label> <input type="text"
					class="form-control"
					placeholder="java파일디렉터리를 입력해 주세요.(Path) ex) /src/main/java/com/dbs/mcare"
					id="javafileDir" name="javafileDir">
			</div>
			<div class="form-group">
				<label for="javaPattern">javaPattern:</label>
				<div id="java_basicPatterns">
					<span class="patternBox"><span class="javaPatterns">Exception\(\"([a-z0-9]+[.]([a-z0-9]+[.]?)+)\",</span>
					<button type="button" class="btn deletePT" data-role="button">x</button></span>
					<span class="patternBox"><span class="javaPatterns">getMessage\(\"([^>\"']+)\",</span>
					<button type="button" class="btn deletePT" data-role="button">x</button></span>
				</div>
				<input type="text" class="col-sm-8 form-control input_pattern"
					placeholder="추가 하실 패턴을 입력해 주세요 " id="javaPattern"
					name="javaPattern">
				<button type="button" class="col-sm-1 btn btn-default addBtn"
					data-addvalue="javaPatterns">+</button>
			</div>

			<div class="form-group">
				<label for="viewfileDir">viewfileDir:</label> <input type="text"
					class="form-control" id="viewfileDir" name="viewfileDir"
					placeholder="view파일디렉터리를 입력해 주세요.(Path) ex) /WebContent/WEB-INF ">
			</div>

			<div class="form-group">
				<label for="viewPattern">viewPattern:</label>
				<div id="view_basicPatterns">
					<span class="patternBox"><span class="viewPatterns">
							s:message[ ]+code=[\"']?([^>\"']+)[\"']?[^>]*</span>
					<button type="button" class="btn deletePT" data-role="button">x</button></span>
				</div>
				<input type="text" class="col-sm-8 form-control input_pattern"
					id="viewPattern" name="viewPattern"
					placeholder="추가 하실 패턴을 정규식으로 입력해 주세요.">
				<button type="button" class="col-sm-1 btn btn-default addBtn" data-addvalue>+</button>
			</div>

			<div class="form-group row clearfix">
				<label for="u_messagefileDir" class="col-sm-12 control-label">messagefileFolder:</label>
				<div class="col-sm-9">
					<input type="text" class="form-control " id="u_messagefileDir"
						name="u_messagefileDir"
						placeholder="메시지리소스 디렉터리를 입력해 주세요. ex)/WebContent/WEB-INF/messages"
						required="required">
				</div>
				<div class="col-sm-3">
					<button type="button" class="btn btn-default btn-block choosefile">
						choose file</button>
				</div>

			</div>
			<div class="checkboxContainer">
				<div class="col-sm-12">
					<label class="control-label"> 기준이 되는 메시지 파일을 하나만 선택해 주세요:</label>
				</div>
				<div class="myContainer radioArea clearfix col-sm-12">
					<br/> <p class="text-center">반드시 파일을 선택 한 후 조회 하세요.</p>
				</div>
			</div>
			
			<button type="reset" class="btn btn-warning">Clear form</button>
			<button type="submit" class="btn btn-success submitBtn">Submit</button>
		</form>
	</div>
	<div id="using_result" class="table-responsive resultContainer"><div class="well"> <p> 안타깝게도..메시지 추가 서비스는 아직 준비되지 않았습니다. <br> 필요없는 메시지 삭제는 가능합니다.</p> </div></div>
	
	<div id="chooseFileModal" class="modal fade" role="dialog">
	  <div class="modal-dialog">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal">&times;</button>
	        <h4 class="modal-title"> 선택한 메시지를 삭제할 파일 선택 </h4>
	      </div>
	      <div class="modal-body">
	      	<p> 선택한 파일에서 메시지가 삭제 됩니다. 신중히 선택해 주세요.. 이전 파일은 폴더에 *_bak.properties로 저장 됩니다. </p>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-warning btn_editMsgFile" data-dismiss="modal"> 파일 수정</button>
	        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
	      </div>
	    </div>
	  </div>
	</div>
	
</div>

