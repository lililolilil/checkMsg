<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<style>
.btndiv {
	margin-top: 1em;
}

.deleted {
	text-decoration: line-through;
	color: red;
	font-weight: bold;
}
</style>
<script>
    $(document).ready(function() {
	// test(); 
	init();
	addEvent();

    })

    var test = function() {

    }

    var init = function() {
		$("#baseDir").val($.cookie("baseDir"));
		$("#messagefileDir").val($.cookie("messagefileDir"));
		$(".resultContainer").hide();
    }

    var addEvent = function() {
	// 가져올 메시지 파일 선택 하기 
	$(".choosefile").on("click", function(e) {
	    getMessageFile();
	});
	// 전체 메시지 가져오기 
	$("#sync_form").on("submit", function(e) {
	    e.preventDefault();
	    getMessage();
	});

	// 메시지 파일 저장 버튼 클릭 
	$(".btn-editMsgfile").on("click", function(e) {
	    editMessagefile();
	});
    }
    // 데이터 가져온 다음에 요소에 이벤트를 주는 친구 
    var addEvent_after = function() {
	// 수정버튼 클릭 

	$(".modifyMsg").on("click",	function(e) {
		    var codeVal = $(this).parents("tr").attr("codevalue");
		    var $codetr = $("tr[codevalue='" + codeVal + "']");
		    if ($codetr.hasClass("deleted")) {
			alert("삭제한 메시지는 수정할 수 없습니다. 삭제를 취소하시고 다시 시도해 주세요.")
		    } else if ($codetr.hasClass("edited")) {
			//수정 취소 원래의 메시지로 돌아가자.. 
			$(this).text("수정").removeClass("btn-warning").addClass("btn-default");

			var tr = $("<tr></tr>"), td = $("<td></td>"), span = $("<span></span>");

			$codetr.each(function(index) {
			    var codevalue = codeVal.replace(/_/gi, ".");
			    var message = messageList[codevalue][index];
			    var $nowtr = $(this);
			    if (message != null || message != undefined) {
				$.each(message, function(key, value) {
				    if (index == 0) {
					$nowtr.find("td:not(.bossNode)").remove(); //boseNode만 빼고 remove함. 
					$nowtr.append(td.clone().html(span.clone().text(key).addClass("fileNm"))).append(
						td.clone().html(span.clone().text(value).addClass("valueString editable")));
				    } else {
					$nowtr.html("").append(td.clone().html(span.clone().text(key).addClass("fileNm"))).append(
						td.clone().html(span.clone().text(value).addClass("valueString editable")));
				    }
				});
			    } else { //없을때 
				$nowtr.html("").append(td.clone().html(span.clone().text("없음").addClass("fileNm"))).append(
					td.clone().html(span.clone().text("-").addClass("valueString editable")));
			    }
			});//codetr.each
			$codetr.removeClass("edited");

		    } else {
			//수정 버튼 클릭 했을 때 
			$codetr.addClass("edited");
			var $span = $("tr[codevalue='" + codeVal + "']").find(".editable");
			var input = $("<input>", {
			    "type" : "text",
			    "class" : "form-control"
			});
			$span.each(function(index) {
			    var value = $(this).text();
			    if ($(this).hasClass("fileNm")) {
				//파일명
				$(this).replaceWith(input.clone().addClass("fileNm").val(value));
			    } else {
				//valuestring 
				$(this).replaceWith(input.clone().addClass("valueString").val(value));
			    }
			});
			//this= button
			$(this).text("수정취소").addClass("btn-warning").removeClass("btn-default");
		    }

		});

	// 삭제 버튼 클릭 
	$(".deleteMsg").on("click", function(e) {
	    var codeVal = $(this).parents("tr").attr("codevalue");
	    var $codetr = $("tr[codevalue='" + codeVal + "']");
	    if ($codetr.hasClass("edited")) {
		alert("수정중인 메시지는 삭제할 수 없습니다. 수정 취소 후 삭제 해주세요. ");
	    } else if ($codetr.hasClass("deleted")) {// 삭제 취소 버튼이니까 삭제를 취소 해줘야 함. 
		$codetr.removeClass("deleted");
		$(this).text("삭제");
	    } else {
		$codetr.addClass("deleted");
		$(this).text("삭제취소");
	    }
	});
    }
    var getMessageFile = function() {
		util.progressBar("start");
		var val_baseDir = $("#baseDir").val().replace(/\\/gi, "/"), 
			val_messageDir = $("#messagefileDir").val().replace(/\\/gi, "/"); 
		$.cookie("baseDir", val_baseDir);
		$.cookie("messagefileDir", val_messageDir);
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

    var getMessage = function() {
		util.progressBar("start");
		var url = "${pageContext.request.contextPath}/checkMsg/getAllMessage";
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
		var form_data = {
		    messagefileList : msgfileInfoList
		};
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
			    displayResult(data.result);
			    messageList = data.result;
			    addEvent_after();
			} else {
			    alert(data.err);
			}
		    }
	
		});
		util.progressBar("stop");
    }
    var displayResult = function(data) {
		$("#result").html("");
		$(".after-btnArea").show();
		var table = $("<table></table>"), caption = $("<caption></caption>"), thead = $("<thead></thead>"), tbody = $("<tbody></tbody>"), tr = $("<tr></tr>"), td = $("<td></td>"), span = $("<span></span>"), btn = $("<div class='clearfix'><button type='button' class='btn btn-danger deleteMsg pull-right' data-role='button'>삭제</button>"
			+ "<button type='button' class='btn btn-default modifyMsg pull-right'>수정</button></div>");
		var colgruop = $("<colgroup><col width='30%'/><col width='20%'/><col width='50%'/></colgroup>");
		var newTable = table.clone().addClass("table table-bordered table-striped").html(
			thead.clone().html(tr.clone().html(td.clone().text("code")).append(td.clone().html("value").attr("colspan", "2"))));
		newTable.prepend(colgruop);
		var newBody = tbody.clone().html("");
	
		$.each(data, function(key, value) {
		    var blankTr = tr.clone().attr("codevalue", key.replace(/\./gi, "_")).addClass("danger").html(
			    td.clone().html(span.clone().text("없음").addClass("fileNm"))).append(
			    td.clone().html(span.clone().text("-").addClass("valueString editable")));
		    var valuelist = value;
		    for (var i = 0; i < valuelist.length; i++) {
			var newTr = tr.clone().attr("codevalue", key.replace(/\./gi, "_")).html("");
			var message = valuelist[i];
			var code = td.clone().text(key).attr("rowspan", valuelist.length).addClass("bossNode").append(btn.clone());
			if (message != null || message != undefined) {
			    $.each(message, function(key, value) {
				newTr.attr("fileNm", key);
				if (i == 0) {
				    newTr.append(code).append(td.clone().html(span.clone().text(key).addClass("fileNm"))).append(
					    td.clone().html(span.clone().text(value).addClass("valueString editable")));
				} else {
				    newTr.html("").append(td.clone().html(span.clone().text(key).addClass("fileNm"))).append(
					    td.clone().html(span.clone().text(value).addClass("valueString editable")));
				}
				newBody.append(newTr);
			    });//each
			} else {
			    newBody.append(blankTr);
			}
	
		    }//for문 끝 
	
		});//each 
	
		$("#result").append(newTable.append(newBody));
		$(".s_formContainer").hide();
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
		    deleteMessages.push($(this).attr("codevalue"));
		});
		var updateMessages = [];
		var param = {}; 
		
		$(".edited").each(function(index) {
		    var message = new Object; // 파일별 메시지 
		    message.code = $(this).attr("codevalue");
		    message.fileName = $(this).attr("filenm");
		    message.valueString = $(this).find(".valueString").val();
		    updateMessages.push(message);
		})
		
		param.deletemsg = deleteMessages;  
		param.updatemsg = updateMessages; 
		param.folderPath = $.cookie("baseDir") + $.cookie("messagefileDir");
		param.files = files; 
	
		return param;
    }
</script>
<style>
.checkboxArea {
	background-color: white;
	clear: both;
	min-height: 3em;
	border-radius: 1em;
	padding: 1em 4em;
	margin: 0 1em 1em 1em;
	width: 95%;
}
</style>
<div id="container">
	<div class="well s_formContainer clearfix">
		<form id="sync_form" role="form" class="horizontal">
			<div class="form-group">
				<div class="col-sm-12">
					<label for="baseDir">baseDir:</label>
				</div>
				<div class="col-sm-12">
					<input type="text" class="form-control" id="baseDir" name="baseDir"
						placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
						required="required">
				</div>
			</div>
			<div class="form-group clearfix">
				<div class="col-sm-12">
					<label for="messagefileDir" class="control-label">messagefileFolder:</label>
				</div>
				<div class="col-sm-9">
					<input type="text" class="form-control " id="messagefileDir"
						name="messagefileDir"
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
	<div class="row">
		<div class="after-btnArea" style="display: none;">
			<div class="form-group col-sm-12">
				<button type="button"
					class="btn btn-primary btn-block btn-editMsgfile">수정내용을
					반영하여 메시지 파일 생성</button>
			</div>
		</div>
	</div>
	<div id="result" class="table-responsive syncMessage"></div>
</div>
