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
	util.progressBar("start");
	getMessageFile();
	util.progressBar("stop");

    });
    // 전체 메시지 가져오기 
    $("#sync_form").on("submit", function(e) {
	e.preventDefault();
	util.progressBar("start");
	getMessage(); 
	util.progressBar("stop");
    });
    $(".reloadData").on("click", function(e){
	util.progressBar("start");
	getMessage(); 
	util.progressBar("stop");
    })
    // 메시지 파일 저장 버튼 클릭 
    $(".btn-editMsgfile").on("click", function(e) {
	util.progressBar("start");
	editMessagefile();
	util.progressBar("stop");
    });

    $(".btn-createMsgfile").on("click",function(e){
	var stdFileNm = $(".msgfile_std:checked").data("filename");
	var $dangerCode= $(".danger[filenm='"+stdFileNm+"'"); 

	if($dangerCode.length>0){
	    var table = '<table class="table table-striped"><thead><colgroup><col width="30%"><col width="60%"></colgruop><tr><th>파일명</th><th>코드</th></tr></thead><tbody>'
		$dangerCode.each(function(e){
		    var code = $(this).data("code"); 
		    var fileName = $(this).attr("filenm"); 
		    table+='<tr><td>'+fileName+'</td><td>'+code+'</td></tr>'; 
		}); 
	    table+='</tbody><table>'
		var confirmbody = '<div class="alert alert-danger"><p class="text-danger">'+"<strong>주의!!</strong>선택하신 파일에 없는 메시지 코드가 있습니다. " + "</p>"; 
	    confirmbody += "<p> 해당파일 기준으로 메시지 파일을 생성했을 경우 없는 메시지 코드는 삭제 됩니다."+"</p></div>"; 
	    confirmbody += table;
	    confirmbody += '<p>'+ "파일 생성을 진행하시겠습니까?"+"</p>"; 

	    util.getConfirm("파일 생성 경고!", confirmbody, function(result){
		if(!result){
		    return null; 
		}else{
		    util.progressBar("start");
		    createMessagefile(); 
		    util.progressBar("stop");
		}
	    })
	}else{
	    util.progressBar("start");
	    createMessagefile(); 
	    util.progressBar("stop");
	}

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
	if($(".msgfile_std:checked").size()==0){
	    alert("기준이 될 파일을 선택하셔야 합니다."); 
	    return null; 
	}
	var 	itemName = $(this).data("itemName"), 
	$itemContainer = $("#"+itemName+"_container"), 
	$itemInput = $("#input_"+itemName); 

	var itemValue = $itemInput.val(); 

	if(itemValue === "" || itemValue == null || itemValue == undefined){
	    alert("파일명을 입력해 주세요."); 
	    $itemInput.focus(); 
	    return null; 
	}
	// 생성. 
	var itemBox =  $("<div class='itemBox'><button type='button' class='btn deleteBox pull-right' data-role='button'>x</button></div>");
	itemBox.attr("itemvalue",itemValue); 
	var span = $("<span></span>").addClass(itemName).text(itemValue); 
	itemBox.prepend(span);  
	$itemContainer.append(itemBox); 
	$itemInput.val("");
	addTr(itemValue); 
    }); 

    $(document).on("click", ".deleteBox", function(e){
	var fileNm = $(this).parent().attr("itemvalue"); 
	if($(this).hasClass("initfile")){
	    var $radioBtnDiv = $("#std_"+fileNm).parent("div");
	    $radioBtnDiv.remove(); 
	}
	deleteTr(fileNm);
	$(this).parent().remove(); 
    }); 
}

var addTr = function(newFileNm){
    var $boss = $(".bossNode"); 
    var row = Number($boss.eq(0).attr("rowspan")); 
    var newFileNm = newFileNm; 
    row += 1; 
    $boss.attr("rowspan",row); 
    var stdMsgfileNm = $(".msgfile_std:checked").data("filename");

    $stdFile = $("tr[filenm='"+stdMsgfileNm+"']"); 
    $stdFile.each(function(e){
	$this = $(this);  
	$clonedTr = $this.clone(); 
	if($clonedTr.find(".bossNode").size()>0){
	    $clonedTr.find(".bossNode").remove(); 
	}
	$clonedTr.find(".fileNm").text(newFileNm); 
	$clonedTr.attr("filenm",newFileNm); 
	$this.after($clonedTr); 
    });	
}
var deleteTr = function(fileNm){
    var $fileTr = $("tr[filenm='"+fileNm+"']"); 
    var $boss = $(".bossNode"); 
    var row = Number($boss.eq(0).attr("rowspan")); 
    row -= 1 ; 
    $boss.attr("rowspan",row); 
    $fileTr.each(function(e){
	$this = $(this); 
	if($this.find("td.bossNode").size()>0){
	    var $cloned_boss = $this.find("td.bossNode").clone();  
	    $this.next("tr").prepend($cloned_boss); 
	}
    })

    $fileTr.remove(); 
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
	var codeVal = $(this).parents("tr").data("code");
	var $codetr = $("tr[data-code='" + codeVal + "']");
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
    $input_Dir = $("#messagefileDir"); 
    if(!util.validateData($input_Dir)){
	return false; 
    } 
    
    var val_messageDir = $input_Dir.val(); 
    $.cookie("messagefileDir", val_messageDir);
    $(".msgFileDir").text(val_messageDir); 
    var url = contextPath + "/checkMsg/getFilelist";
    var form_data = {
	    messagefileDir:val_messageDir
    }
    $.ajax({ 
	method : "POST",
	url : url,
	contentType : "application/json",
	//messagefileDir = C:/Users/suyeon/git/mcare-catholic-daegu/WebContent/WEB-INF/messages
	data : JSON.stringify(form_data),
	error : function(xhr, status, error) {
	    alert(error);
	},
	success : function(data) {
	    if (data.err != null || data.err !== "" || data.err != undefined) {
		displayCheckbox(data);
	    } else {
		alert(data.err);
	    }
	}

    });
}
var displayRadio = function(files){
    var radioArea = $(".fileBeStandard").html(""),
    	radio = $("<input type='radio'>"), 
    	label = $("<label></label>"),
    	div = $("<div></div>").addClass("clearfix"), 
    	$newFileNmContainer = $("#newfileName_container").html("");
    
    $.each(files, function(index, value) {
	var fileName = value; 
	//파일 생성 시 기준 파일을 정하기 위한 라디오 버튼 
	var fileitem =  div.clone().addClass("radio radio-primary").css("padding-left","2em").html(label.clone().attr("for", "std_"+fileName).text(fileName)).prepend(radio.clone().attr({
	    "class" : "msgfile_std styled",
	    "name" : "standardfileName", 
	    "id"	: "std_"+fileName,
	    "data-fileName" : fileName
	}));
	// 파일 생성 시 파일을 생성하기 위한 파일 명컨테이너에도 넣어줌.
	itemBox =  $("<div class='itemBox' itemvalue='"+fileName+"'><button type='button' class='btn deleteBox pull-right initfile' data-role='button'>x</button></div>"),
	span = $("<span></span>").addClass("newfileName").text(fileName); 
	itemBox.prepend(span);  
	radioArea.append(fileitem);
	$newFileNmContainer.append(itemBox); 
    }); 
}; 
var displayCheckbox = function(data) {
    var checkboxArea = $(".checkboxArea").html("");
    var checkbox = $("<input type='checkbox'>"), label = $("<label></label>");
    var div = $("<div></div>").addClass("clearfix");
    messagefile = data.messagefile;
    $.each(messagefile, function(index, value) {
	var fileName = value.fileName.split(".")[0]; 
	var messageitem = div.clone().addClass("checkbox checkbox-primary").html(label.clone().attr("for", fileName).text(value.fileName)).prepend(checkbox.clone().attr({
	    "id" : fileName,
	    "class" : "msgfile_cb styled",
	    "name" : fileName, 
	    "value" : value.filePath
	}));
	checkboxArea.append(messageitem).show();
    });
    // radio 버튼도 필요할 것 같음. 

}


var getMessage = function() {
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

    displayRadio(files); 

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
    var dangerCode = []; 
    var warning = []; 
    $.each(data, function(key, value) {
	var code = td.clone().text(key).attr("rowspan", files.length).addClass("bossNode").append(btn.clone());
	var first =  Object.keys(value)[0];
	$.each(value, function(fileNm, valueStr){
	    var code_val = key.replace(/\./gi,"_"); 
	    var newTr = tr.clone().html("").attr({"fileNm" : fileNm, "valueStr" : valueStr, "data-code": code_val});  
	    if(fileNm === first){
		newTr.append(code)
	    }
	    if(valueStr.length == 0){
		newTr.append(td.clone().html(span.clone().text(fileNm).addClass("fileNm")))
		.append(td.clone().html(span.clone().text("").addClass("valueString editable"))); 
		newTr.addClass("warning"); 
		warning.push(code_val); 
	    }else if(valueStr === "NoCode"){
		newTr.append(td.clone().html(span.clone().text(fileNm).addClass("fileNm")))
		.append(td.clone().html(span.clone().text("").addClass("valueString editable"))); 
		newTr.addClass("danger"); 
		dangerCode.push(code_val); 
	    }else{
		newTr.append(td.clone().html(span.clone().text(fileNm).addClass("fileNm")))
		.append(td.clone().html(span.clone().text(valueStr).addClass("valueString editable")));
	    }
	    newBody.append(newTr);
	});
    });//each 

    $("#result").append(newTable.append(newBody));
    $.each(warning, function(index,data){
	$("tr[data-code='"+data+"']").prependTo(newTable); 
    });
    $.each(dangerCode, function(index, data){
	$("tr[data-code='"+data+"']").prependTo(newTable); 
    });
    $(".s_formContainer").hide();
}

var editMessagefile = function() {
    alert("edit");
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
		var alertTxt = null; 
		$.each(data,function(key,value){
		    alertTxt+= value + '<br>'; 
		})
		if(alertTxt!=null){
		    alert(alertTxt);
		}
	    }
	}
    });
}
var createEditData = function() {
    var deleteMessages = []; // code만 들어감. 

    $(".deleted").each(function(e) {
	deleteMessages.push($(this).data("code").replace(/\_/gi,"."));
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
    param.folderPath = $("#messagefileDir").val();
    param.files = files; 

    return param;
}

var createMessagefile = function(){
    alert("메시지 파일 생성을 시작합니다."); 
    var param = createMessageData();
    var url = contextPath + "/checkMsg/createMsgfile" ;
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
	    if (data.err != null || data.err != undefined) {
		alert(data.err);
	    } else {
		var text = ""; 
		$.each(data,function(key,value){
		    text+= value + '\n'; 
		})
		if(text!=null){
		    alert(text);
		}
	    }
	}
    });
}
var createMessageData = function() {
    var deleteMessages = []; // code만 들어감. 

    $(".deleted").each(function(e) {
	deleteMessages.push($(this).data("code").replace(/\_/gi,"."));
    });

    var fileMap = {}; 
    var fileList = []; 
    var param = {}; 
    var $itemBox = $("#newfileName_container").find(".itemBox"); 
    $itemBox.each(function(e){
	var fileName = $(this).attr("itemvalue"); 
	var messageMap = {}; 
	var $tr = $("tr[filenm='"+fileName+"'"); 
	$tr.each(function(e){
	    var code = $(this).data("code").replace(/\_/gi,"."), 
	    value = ""; 
	    if($(this).hasClass("edited")){
		value = $(this).find(".valueString").val();  
	    }else{
		value = $(this).find(".valueString").text();  
	    }
	    /*if(value.length!=0){
		messageMap[code]= value; 
	    }*/
	    messageMap[code]=value; 
	}); 
	fileMap[fileName] = messageMap; 
	fileList.push(fileName); 
    }); 

    var stdFileNm = $(".msgfile_std:checked").data("filename");

    param.folderPath = $("#messagefileDir").val();
    param.fileList = fileList;
    param.standardFile = stdFileNm; 
    param.fileMessageMap = fileMap;  
    param.deletemsg = deleteMessages;  

    return param;
}