<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<style>
.submitBtn {
	float: right;
}

.table-responsive>table {
	table-layout: fixed;
	word-break: break-all;
}

.form-control.input_pattern {
	display: inline-block;
	width: 93%;
}

.addBtn {
	width: 7%;
}

.patternBox {
	background-color: #FAFAD2;
	border-radius: 0.5em;
	border: 1px solid #FFE65A;
	padding: 0.2em;
	font-size: 0.8em;
	color: #3c3c3c;
}

div[id$="_basicPatterns"] {
	padding-bottom: 0.2em;
}

.btn.deletePT {
	display: inline-block;
	min-width: 10px;
	padding: 0.1em 0.2em;
	font-weight: 700;
	line-height: 1;
	color: #fff;
	text-align: center;
	white-space: nowrap;
	vertical-align: middle;
	font-size: 0.6em;
	background-color: #FFA01E;
	border-radius: 50%;
}

.loader {
	border: 16px solid #f3f3f3; /* Light grey */
	border-top: 16px solid #3498db; /* Blue */
	border-radius: 50%;
	width: 120px;
	height: 120px;
	animation: spin 2s linear infinite;
}

@
keyframes spin { 0% {
	transform: rotate(0deg);
}

100%
{
transform
:
 
rotate
(360deg);
 
}
}
#myProgress {
	width: 80%;
	background-color: grey;
}

#myBar {
	width: 1%;
	height: 30px;
}

.progress {
	margin: 2em 1em;
}
</style>
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
	serviceName = "syncMessage";
	// 초기 값은 syncMessage로 한다...  이게 전역이 되어 버리는거 같네 
	$("#u_container").hide(); 
	$("#s_container").show(); 
	// 귀찮으니까 테스트 할때는 박아놓자 
	$("#s_baseDir").val("C:/javaide/test"); 
	$("#messagefileDir").val("/simple/src/main/webapp/WEB-INF/message");
	
	$("#u_baseDir").val("C:/Users/suyeon/git/mcare-catholic-daegu"); 
	$("#javafileDir").val("/src/main/java/com/dbs/mcare");
	$("#viewfileDir").val("/WebContent/WEB-INF");
	$("#standardMsgfileDir").val("/WebContent/WEB-INF/messages/message.properties")
	$(".resultContainer").hide(); 
	
}
var addEvent = function(){
	$(".service").on("click", function(e){
		$(".service").removeClass("active"); 
		$(this).addClass("active"); 
		serviceName = $(this).data("serviceName");
		if(serviceName === "usingMessage"){
		    //service가 usingMessage일 때 
		    $("#u_container").show(); 
		    $("#s_container").hide(); 
		    $(".u_formContainer").show(); 
		}else{
		    //service가 syncMessage일 때 
		    $("#u_container").hide(); 
		    $("#s_container").show(); 
		    $(".s_formContainer").show();
		}
	});
	$(document).on("click", ".deletePT", function(e){
		$(this).parent().remove(); 
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
	$("#sync_form").on("submit", function(e){
		e.preventDefault();
		var url = "${pageContext.request.contextPath}/checkMsg/"+serviceName; 
		var form_data = {baseDir: $("#s_baseDir").val(),messagefileDir: $("#messagefileDir").val()}
		progressBar("start"); 
		var request = $.ajax({
		    method: "GET",
		    url: url,
		    contentType:"application/json", 
		    //messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
		    data: form_data,
		    error: function(xhr, status, error){
			alert(error); 
		    },
		    success: function(data){
				if(data.msg != null|| data.msg !== "" ||data.msg != undefined){
					displaySyncResult(data.result); 
				}else{
				    alert(data.msg); 
				}
		    }
		})
		request.done(function(){
		   progressBar("stop");
		});
		 
	});
	$("#using_form").on("submit", function(e){
		e.preventDefault();
		var url = "${pageContext.request.contextPath}/checkMsg/"+serviceName; 
		var javaPatternsList = [], viewPatternsList = [];
		var javaPatternsArray = $(".javaPatterns"), 
		viewPatternsArray=$(".viewPatterns");  
		for(var i = 0; i<javaPatternsArray.length; i++){
		    javaPatternsList.push(javaPatternsArray[i].innerText); 
		}
		for(i = 0; i<viewPatternsArray.length; i++){
		    viewPatternsList.push(viewPatternsArray[i].innerText); 
		}
		var form_data = {
			baseDir: $("#u_baseDir").val(),
			javafileDir: $("#javafileDir").val(),
			javaPatterns: javaPatternsList, 
			viewPatterns: viewPatternsList, 
			viewfileDir: $("#viewfileDir").val(),
			standardMsgfileDir: $("#standardMsgfileDir").val()
		}
		progressBar("start");
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
				if(data.msg != null|| data.msg !== "" ||data.msg != undefined){
					displayUsingResult(data); 
				}else{
				    alert(data.msg); 
				}
		    }
		});
		
		request.done(function(){
			progressBar("stop"); 
		})  
	});
}//addEvent
var progressBar = function(order){
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

var displaySyncResult =  function(data){
    $("#sync_result").html(""); 
    var table = $("<table><colgroup><col width='30%'/><col width='70%'/></colgroup></table>"),
    	caption = $("<caption></caption>"), 
    	thead = $("<thead></thead>"), 
    	tbody = $("<tbody></tbody>"), 
    	tr = $("<tr></tr>"), 
    	td = $("<td></td>"); 
	$.each(data, function(key,value){
		$("#sync_result").append("<h3>"+key+"</h3>");
		var newTable = table.clone().addClass("table table-bordered table-striped").html(thead.clone().html(tr.clone().html(
			td.clone().addClass("danger").text(key+"에서 필요한 메시지 입니다.").attr("colspan", "2"))));
		var newBody = tbody.clone().html(""); 
		var value_key = value; 
		$.each(value_key, function(key,value){
		    newBody.append(tr.clone().html(td.clone().html(key)).append(td.clone().html(value))); 
		    newTable.append(newBody); 
	 	});
		$("#sync_result").append(newTable); 
    });
    $(".s_formContainer").hide(); 
}
var displayUsingResult =  function(data){
    $("#using_result").html("result~!!!!"); 
    $(".u_formContainer").hide();
    $("#using_result").html(""); 
    var table = $("<table><colgroup><col width='30%'/><col width='70%'/></colgroup></table>"),
	caption = $("<caption></caption>"), 
	thead = $("<thead></thead>"), 
	tbody = $("<tbody></tbody>"), 
	tr = $("<tr></tr>"), 
	td = $("<td></td>"),
	pTag = $("<p></p>"),
	span = $("<span></span>"); 
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
		    var newTr = tr.clone().html(td.clone().html(key.split("\n")[0]).append(pTag.clone().html(key.split("\n")[1]))); 
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
		newTable_2.append(caption.clone().html("사용하지 않는 메시지를 확인하세요.."))
		 $("#using_result").append(newTable_2);
}

</script>
<div id="s_container">
	<div class="well s_formContainer">
		<form id="sync_form" role="form">
			<div class="form-group">
				<label for="s_baseDir">baseDir:</label> <input type="text"
					class="form-control" id="s_baseDir" name="s_baseDir"
					placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
					required="required">
			</div>
			<div class="form-group">
				<label for="messagefileDir">messagefileDir:</label> <input
					type="text" class="form-control" id="messagefileDir"
					name="messagefileDir"
					placeholder="메시지리소스 디렉터리를 입력해 주세요. ex)/WebContent/WEB-INF/messages"
					required="required">
			</div>
			<button type="reset" class="btn btn-warning">Clear form</button>
			<button type="submit" class="btn btn-success submitBtn">Submit</button>
		</form>

	</div>
	<div id="sync_result" class="table-responsive syncMessage"></div>
</div>
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
				<input type="text" class="form-control input_pattern"
					placeholder="추가 하실 패턴을 입력해 주세요 " id="javaPattern"
					name="javaPattern">
				<button type="button" class="btn btn-default addBtn"
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
				<input type="text" class="form-control input_pattern"
					id="viewPattern" name="viewPattern"
					placeholder="추가 하실 패턴을 정규식으로 입력해 주세요.">
				<button type="button" class="btn btn-default addBtn" data-addvalue>+</button>
			</div>

			<div class="form-group">
				<label for="standardMsgfileDir">standardMsgfileDir:</label> <input
					type="text" class="form-control" id="standardMsgfileDir"
					name="standardMsgfileDir"
					placeholder="비교 메시지리 파일 경로를 입력해 주세요. ex)/WebContent/WEB-INF/messages/message.properties"
					required="required">
			</div>
			<button type="reset" class="btn btn-warning">Clear form</button>
			<button type="submit" class="btn btn-success submitBtn">Submit</button>
		</form>
	</div>
	<div id="using_result" class="table-responsive usingMessage"></div>
</div>

