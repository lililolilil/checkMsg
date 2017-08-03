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
	if($.cookie("messagefileDir")){
		$("#standardMsgfileDir").val($.cookie("messagefileDir"));
	}else if($.cookie("standardMsgfileDir")){
		$("#standardMsgfileDir").val($.cookie("standardMsgfileDir"));
	}
	$(".resultContainer").hide(); 
}
var addEvent = function(){
	
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
	
	$("#using_form").on("submit", function(e){
		e.preventDefault();
		$.cookie("u_baseDir", $("#u_baseDir").val()); 		
		$.cookie("javafileDir", $("#javafileDir").val()); 		
		$.cookie("viewfileDir", $("#viewfileDir").val()); 		
		$.cookie("standardMsgfileDir", $("#standardMsgfileDir").val()); 		
		
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
		var form_data = {
			baseDir: $("#u_baseDir").val(),
			javafileDir: $("#javafileDir").val(),
			javaPatterns: javaPatternsList, 
			viewPatterns: viewPatternsList, 
			viewfileDir: $("#viewfileDir").val(),
			standardMsgfileDir: $("#standardMsgfileDir").val()
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
				if(data.err != null|| data.err !== "" ||data.err != undefined){
					displayUsingResult(data); 
				}else{
				    alert(data.err); 
				}
		    }
		});
		
		request.done(function(){
			util.progressBar("stop"); 
		})  
	});
}//addEvent

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

