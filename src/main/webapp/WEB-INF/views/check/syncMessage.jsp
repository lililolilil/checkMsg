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
   
}
var init = function(){
	// 귀찮으니까 테스트 할때는 박아놓자 
	$("#s_baseDir").val($.cookie("baseDir")); 
	$("#messagefileDir").val($.cookie("messagefileDir")); 
	$(".resultContainer").hide(); 
	
}
var addEvent = function(){

	$("#sync_form").on("submit", function(e){
		e.preventDefault();
		$.cookie("baseDir", $("#s_baseDir").val().replace(/\\/gi,"/")); 
		$.cookie("messagefileDir", $("#messagefileDir").val().replace(/\\/gi,"/")); 
		var url = "${pageContext.request.contextPath}/checkMsg/syncMessage"; 
		var syncInfo = {baseDir: $("#s_baseDir").val(),messagefileDir: $("#messagefileDir").val()}
		util.progressBar("start"); 
		var request = $.ajax({
		    method: "POST",
		    url: url,
		    contentType:"application/json", 
		    //messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
		    data: JSON.stringify(syncInfo),
		    error: function(xhr, status, error){
			alert(error); 
		    },
		    success: function(data){
				if(data.err != null|| data.err !== "" ||data.err != undefined){
					displaySyncResult(data.result); 
				}else{
				    alert(data.err); 
				}
		    }
		})
		request.done(function(){
		   util.progressBar("stop");
		});
		 
	});
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

