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
	if($.cookie("s_baseDir")!= null || $.cookie("s_baseDir") != undefined){
		$("#s_baseDir").val($.cookie("s_baseDir")); 
	}else{ 
		$("#s_baseDir").val($.cookie("baseDir")); 
	}
	if($.cookie("s_messagefileDir")!= null || $.cookie("s_messagefileDir") != undefined){
		$("#s_messagefileDir").val($.cookie("s_messagefileDir")); 
	}else{ 
		$("#s_messagefileDir").val($.cookie("messagefileDir")); 
	}
	$(".resultContainer").hide(); 
	
}

var addEvent = function(){
    $(".choosefile").on("click", function(e) {
	    getMessageFile();
	});
	$("#sync_form").on("submit", function(e){
		e.preventDefault();
		getSyncResult(); 
	});
}

setCookieValue= function(val_baseDir, val_messageDir){
	
	//modal table 에 값을 넣고 
	var confirmbody = '<p> 전체 페이지의 기본 경로와 입력하신 기본 경로가 다릅니다. </p><p> 현재 입력하신 경로로 수정 하시려면 [기본경로수정] 버튼을 눌러주세요.</p>'
					+ '<table class="table table-striped"> <thead><colgroup><col width="20%"><col width="40%"><col width="40%"></colgruop><tr><th></th><th>Previous</th><th>YourInput</th></tr></thead>' 
	      			+'<tbody> <tr><th scope="row">기본 경로</th><td class="cookie_basedir">'+$.cookie("baseDir")+'</td><td class="now_basedir">'+val_baseDir+'</td></tr>' 
	      			+'<tr><th scope="row">메시지파일기본경로</th><td class="cookie_msgdir">'+$.cookie("messagefileDir")+'</td><td class="now_msgdir">'+val_messageDir+'</td></tr></tbody></table>'; 

	if($.cookie("baseDir")!== val_baseDir||$.cookie("messagefileDir")!== val_messageDir){
	    util.getConfirm("기본 설정 변경", confirmbody, function(result){
		    if(result){
				$.cookie("baseDir", val_baseDir);
				$.cookie("messagefileDir", val_messageDir);
		    }
		})	
	}
	$.cookie("s_baseDir", val_baseDir);
	$.cookie("s_messagefileDir", val_messageDir);

}

var getMessageFile = function() {
	util.progressBar("start");
	var val_baseDir = $("#s_baseDir").val().replace(/\\/gi, "/"), 
		val_messageDir = $("#s_messagefileDir").val().replace(/\\/gi, "/"); 
	
	setCookieValue(val_baseDir, val_messageDir); 
	
	var url = "${pageContext.request.contextPath}/checkMsg/getFilelist";
	var form_data = {
	    baseDir : val_baseDir, 
	    messagefileDir :val_messageDir
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
		    displayCheckbox(data);
		} else {
		    alert(data.err);
		}
	    }

	});
	util.progressBar("stop");
}
var displayCheckbox = function(data) {
	var checkboxArea = $(".checkboxArea").html("");
	var checkbox = $("<input type='checkbox'>"), label = $("<label></label>");
	div = $("<div></div>").addClass("checkbox checkbox-primary clearfix");
	messagefile = data.messagefile;
	
	$.each(messagefile, function(key, value) {
		var messageitem = div.clone().html(label.clone().attr("for", key.split(".")[0]).text(key)).prepend(checkbox.clone().attr({
			"id" : key.split(".")[0],
			"class" : "msgfile_cb styled",
			"name" : key.split(".")[0],
			"value" : value
		}));
		checkboxArea.append(messageitem).show();
	});	
}
var getSyncResult = function(){
    util.progressBar("start"); 
    
	var url = "${pageContext.request.contextPath}/checkMsg/syncMessage"; 
	var msgfileInfoList = [];
	var $messagefile = $(".msgfile_cb:checked");
	files = []; 
	$messagefile.each(function(e) {
	    var msgfileInfo = new Object;
	    msgfileInfo.filePath = $(this).val();
	    msgfileInfo.fileName = $(this).attr("name");
	    msgfileInfoList.push(msgfileInfo);
	    files.push( $(this).attr("name")); // 나중에 불러온 파일을 수정하기 위해 파라미터 생성 
	});
	
	var syncInfo = {  messagefileList : msgfileInfoList } ; 
	
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

<div id="container">
	<div class="well s_formContainer clearfix">
		<form id="sync_form" role="form" class="horizontal">
			<div class="form-group">
				<div class="col-sm-12">
					<label for="s_baseDir">baseDir:</label>
				</div>
				<div class="col-sm-12">
					<input type="text" class="form-control" id="s_baseDir" name="s_baseDir"
						placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
						required="required">
				</div>
			</div>
			<div class="form-group clearfix">
				<div class="col-sm-12">
					<label for="s_messagefileDir" class="control-label">messagefileFolder:</label>
				</div>
				<div class="col-sm-9">
					<input type="text" class="form-control " id="s_messagefileDir"
						name="s_messagefileDir"
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
					<label class="control-label">가져올 메시지 파일을 2개 이상 선택해 주세요:</label>
				</div>
				<div class="checkboxArea clearfix col-sm-12">
					<br />
					<p class="text-center">반드시 파일을 선택 한 후 조회 하세요.</p>
				</div>
			</div>
			<div class="btnArea clearfix col-sm-12">
				<button type="reset" class="btn btn-warning">Clear</button>
				<button type="submit" class="btn btn-success submitBtn">메시지
					조회</button>
			</div>

		</form>

	</div>
	<div id="sync_result" class="table-responsive syncMessage"></div>
</div>

