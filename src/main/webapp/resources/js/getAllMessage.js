/**
 * 
 */
var test = function() {

}

var init = function() {
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

    $(".btn-createMsgfile").on("click",function(e){
	createMsgfile(); 
    }); 

    $('#radioBtn a').on('click', function(){
	var sel = $(this).data('title');
	var name = $(this).data('name');
	var target =$(this).data('target');  

	$('#'+name).prop('value', sel);

	$('a[data-name="'+name+'"]').not('[data-title="'+sel+'"]').removeClass('btn-primary active').addClass('btn-default');
	$('a[data-name="'+name+'"][data-title="'+sel+'"]').removeClass('btn-default').addClass('btn-primary active');
	$(".targetContainer").hide(); 
	$(target).show(); 
    }); 
    $(".addBtn").on("click", function(e){
	// 새로운 item을 그위에 있는  container에 추가 한다. 
	var itemName = $(this).data("itemName");
	var $itemContainer = $("#"+itemName+"_container");  
	var itemValue = $("#input_"+itemName).val(); 
	var itemBox =  $("<div class='itemBox'><button type='button' class='btn deleteBox pull-right' data-role='button'>x</button></div>");
	var span = $("<span></span>").addClass(itemName).text(itemValue); 
	itemBox.prepend(span);  
	$itemContainer.append(itemBox); 
	$("#input_"+itemName).val("");
    }); 
    $(document).on("click", ".deleteBox", function(e){
	$(this).parent().remove(); 
    }); 
}
//데이터 가져온 다음에 요소에 이벤트를 주는 친구 
var addEvent_after = function() {
    // 수정버튼 클릭 
    $(".modifyMsg").on("click",	function(e) {
	var codeVal = $(this).parents("tr").data("code");
	var $codetr = $("tr[data-code='" + codeVal + "']");
	if ($codetr.hasClass("deleted")) {
	    alert("삭제한 메시지는 수정할 수 없습니다. 삭제를 취소하시고 다시 시도해 주세요.")
	} else if ($codetr.hasClass("edited")) {
	    //수정 취소 원래의 메시지로 돌아가자.. 
	    $(this).text("수정").removeClass("btn-warning").addClass("btn-default");

	    var tr = $("<tr></tr>"), td = $("<td></td>"), span = $("<span></span>");

	    $codetr.each(function(index) {
		var $span = $("<span></span>"); 
		var $input = $codetr.find("input"); 
		$input.each(function(index){
		    var valuestr = $(this).parents("tr").attr("valuestr"); 
		    $(this).replaceWith(span.clone().text(valuestr).addClass("valueString editable"));
		}); 

	    });//codetr.each
	    $codetr.removeClass("edited");

	} else {
	    //수정 버튼 클릭 했을 때 
	    $codetr.addClass("edited");
	    var $span = $("tr[data-code='" + codeVal + "']").find(".editable");
	    var input = $("<input>", {
		"type" : "text",
		"class" : "form-control"
	    });
	    $span.each(function(index) {
		var value = $(this).text();
		if ($(this).hasClass("fileNm")) {
		    //파일명 - 지금은 사용하지 않음. 
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
    var val_messageDir = $("#messagefileDir").val().replace(/\\/gi, "/"); 
    $.cookie("messagefileDir", val_messageDir);
    $(".msgFileDir").text(val_messageDir); 
    var url = contextPath + "/checkMsg/getFilelist";
    var form_data = {
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
    var radioArea = $(".fileBeStandard").html("");
    var checkbox = $("<input type='checkbox'>"), label = $("<label></label>");
    var radio = $("<input type='radio'>"), label = $("<label></label>");
    var div = $("<div></div>").addClass("clearfix");
    messagefile = data.messagefile;
    $.each(messagefile, function(key, value) {
	var fileName = key.split(".")[0]; 
	var messageitem = div.clone().addClass("checkbox checkbox-primary").html(label.clone().attr("for", fileName).text(key)).prepend(checkbox.clone().attr({
	    "id" : fileName,
	    "class" : "msgfile_cb styled",
	    "name" : fileName, 
	    "value" : value
	}));
	//파일 생성 시 기준 파일을 정하기 위한 라디오 버튼 
	var fileitem =  div.clone().addClass("radio radio-primary").css("padding-left","2em").html(label.clone().attr("for", "std_"+fileName).text(key)).prepend(radio.clone().attr({
	    "class" : "msgfile_std styled",
	    "name" : "standardfileName", 
	    "id"	: "std_"+fileName,
	    "data-fileName" : fileName, 
	    "data-filePath" : value
	}));
	// 파일 생성 시 파일을 생성하기 위한 파일 명컨테이너에도 넣어줌.
	var $newFileNmContainer = $("#newfileName_container"),
	    itemBox =  $("<div class='itemBox'><button type='button' class='btn deleteBox pull-right' data-role='button'>x</button></div>"),
	    span = $("<span></span>").addClass("newfileName").text(fileName); 
	itemBox.prepend(span);  
	
	checkboxArea.append(messageitem).show();
	radioArea.append(fileitem);
	$newFileNmContainer.append(itemBox); 


    });
    // radio 버튼도 필요할 것 같음. 

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

var getMessage = function() {
    util.progressBar("start");
    var url = contextPath+ "/checkMsg/getAllMessage";
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
    $('#radioBtn a').eq(0).click(); 
    var table = $("<table></table>"), caption = $("<caption></caption>"), thead = $("<thead></thead>"), tbody = $("<tbody></tbody>"), tr = $("<tr></tr>"), td = $("<td></td>"), span = $("<span></span>"), btn = $("<div class='clearfix'><button type='button' class='btn btn-danger deleteMsg pull-right' data-role='button'>삭제</button>"
	    + "<button type='button' class='btn btn-default modifyMsg pull-right'>수정</button></div>");
    var colgruop = $("<colgroup><col width='30%'/><col width='20%'/><col width='50%'/></colgroup>");
    var newTable = table.clone().addClass("table table-bordered table-striped").html(
	    thead.clone().html(tr.clone().html(td.clone().text("code")).append(td.clone().html("value").attr("colspan", "2"))));
    newTable.prepend(colgruop);
    var newBody = tbody.clone().html("");

    $.each(data, function(key, value) {
	var code = td.clone().text(key).attr("rowspan", files.length).addClass("bossNode").append(btn.clone());
	var first =  Object.keys(value)[0];
	$.each(value, function(fileNm, valueStr){
	    var newTr = tr.clone().html("").attr({"fileNm" : fileNm, "valueStr" : valueStr, "data-code": key.replace(/\./gi,"_")});  
	    if(fileNm === first){
		newTr.append(code)
	    }

	    if(valueStr.length == 0){
		newTr.append(td.clone().html(span.clone().text(fileNm).addClass("fileNm")))
		.append(td.clone().html(span.clone().text("").addClass("valueString editable"))); 
		newTr.addClass("danger"); 
	    }else{
		newTr.append(td.clone().html(span.clone().text(fileNm).addClass("fileNm")))
		.append(td.clone().html(span.clone().text(valueStr).addClass("valueString editable")));
	    }
	    newBody.append(newTr);
	});
    });//each 

    $("#result").append(newTable.append(newBody));
    $(".s_formContainer").hide();
}

var editMessagefile = function() {
    alert("edit");
    util.progressBar("start");
    var param = createEditData();
    var url = contextPath + "/checkMsg/editMsgfile";
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
var createEditData = function() {
    var deleteMessages = []; // code만 들어감. 

    $(".deleted").each(function(e) {
	deleteMessages.push($(this).data("code"));
    });
    var updateMessages = [];
    var param = {}; 

    $(".edited").each(function(index) {
	var message = new Object; // 파일별 메시지 
	message.code = $(this).data("code");
	message.fileName = $(this).attr("filenm");
	message.valueString = $(this).find(".valueString").val();
	updateMessages.push(message);
    })

    param.deletemsg = deleteMessages;  
    param.updatemsg = updateMessages; 
    param.folderPath = $("#messagefileDir");
    param.files = files; 

    return param;
}

var createMessagefile = function(){
    alert("edit");
    util.progressBar("start");
    var param = createEditData();
    var url = contextPath + "/checkMsg/editMsgfile";
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
var createMessageData = function() {
    var deleteMessages = []; // code만 들어감. 

    $(".deleted").each(function(e) {
	deleteMessages.push($(this).data("code"));
    });
    var messageMap = {}; 
    var param = {}; 
    param.deletemsg = deleteMessages;  
    param.updatemsg = updateMessages; 
    param.folderPath = $.cookie("messagefileDir");
    param.files = files; 

    return param;
}