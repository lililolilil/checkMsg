<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script type="text/javascript"
	src="<c:url value="/resources/js/usingMessage.js" />"></script>
<link rel="stylesheet"
	href="<c:url value="/resources/css/usingMessage.css"/>" />

<script>
    $(document).ready(function() {
	// test(); 
	init();
	addEvent();
    })
</script>
	<div class="well u_formContainer">
		<form id="using_form" role="form">
			<!-- <div class="form-group">
				<label for="u_baseDir">baseDir:</label> <input type="text"
					class="form-control" id="u_baseDir" name="u_baseDir"
					placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
					required="required">
			</div> -->
			<div class="form-group">
				<label for="input_javaDir" class="col-sm-12">javafileDir:</label>
				<div id="javaDir_container"></div>
				<div class="col-sm-11">
					<input type="text" class="form-control input_item"
						placeholder="java파일 최상위 디렉터리를 입력해 주세요. 여러개 추가 가능."
						id="input_javaDir">
				</div>
				<div class="col-sm-1">
					<button type="button" class="btn btn-default btn-block addBtn"
						data-item-name="javaDir">+</button>
				</div>
			</div>
			<div class="form-group">
				<label for="input_javaPattern" class="col-sm-12">javaPattern:</label>
				<div id="javaPattern_container">
					<!--  기본값  -->
					<span class="itemBox"><span class="javaPattern">Exception\(\"([a-z0-9]+[.]([a-z0-9]+[.]?)+)\",</span>
						<button type="button" class="btn deleteBox" data-role="button">x</button></span>
					<span class="itemBox"><span class="javaPattern">getMessage\(\"([^>\"']+)\",</span>
						<button type="button" class="btn deleteBox" data-role="button">x</button></span>
				</div>
				<div class="col-sm-11">
					<input type="text" class="form-control input_item"
						placeholder="추가 하실 패턴을 입력해 주세요 " id="input_javaPattern">
				</div>
				<div class="col-sm-1">
					<button type="button" class="btn btn-default btn-block saddBtn"
						data-item-name="javaPattern">+</button>
				</div>
			</div>
			<div class="form-group">
				<label for="input_viewDir" class="col-sm-12">viewfileDir:</label>
				<div id="viewDir_container"></div>
				<div class="col-sm-11">
					<input type="text" class="form-control input_item"
						id="input_viewDir" placeholder="view파일 최상위 디렉터리를 입력해 주세요.">
				</div>
				<div class="col-sm-1">
					<button type="button" class="btn btn-default btn-block addBtn"
						data-item-name="viewDir">+</button>
				</div>
			</div>
			<div class="form-group">
				<label for="input_viewPattern" class="col-sm-12">viewPattern:</label>
				<div id="viewPattern_container">
					<span class="itemBox"><span class="viewPattern">
							s:message[ ]+code=[\"']?([^>\"']+)[\"']?[^>]*</span>
						<button type="button" class="btn deleteBox" data-role="button">x</button></span>
				</div>
				<div class="col-sm-11">
					<input type="text" class="form-control input_item"
						id="input_viewPattern" placeholder="추가 하실 패턴을 정규식으로 입력해 주세요.">
				</div>
				<div class="col-sm-1">
					<button type="button" class="btn btn-default btn-block addBtn"
						data-item-name="viewPattern">+</button>
				</div>
			</div>
			<div class="form-group">
				<label for="u_messagefileDir" class="col-sm-12">messagefileFolder:</label>
				<div class="col-sm-9">
					<input type="text" class="form-control" id="u_messagefileDir"
						name="u_messagefileDir" placeholder="메시지리소스 폴더 경로를 입력해 주세요."
						required="required">
				</div>
				<div class="col-sm-3">
					<button type="button" class="btn btn-default btn-block choosefile">
						choose file</button>
				</div>
			</div>

			<div class="checkboxContainer col-sm-12">
				<div class="col-sm-12">
					<label class="control-label"> 기준이 되는 메시지 파일을 하나만 선택해 주세요:</label>
				</div>
				<div class="myContainer radioArea col-sm-12">
					<br />
					<p class="text-center">반드시 파일을 선택 한 후 조회 하세요.</p>
				</div>
			</div>
			<div class="btnArea clearfix col-sm-12">
					<button type="reset" class="btn btn-warning clearfix clearBtn">Clear form</button>
			<button type="submit" class="btn btn-success clearfix submitBtn">Submit</button>
			</div>
	
		</form>
	</div>
	
	<div id="using_result" class="table-responsive resultContainer">
		<div class="well">
			<p>
				안타깝게도..메시지 추가 서비스는 아직 준비되지 않았습니다. <br> 필요없는 메시지 삭제는 가능합니다.
			</p>
		</div>
	</div>

	<div id="chooseFileModal" class="modal fade" role="dialog">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title">선택한 메시지를 삭제할 파일 선택</h4>
				</div>
				<div class="modal-body">
					<p>선택한 파일에서 메시지가 삭제 됩니다. 신중히 선택해 주세요.. 이전 파일은 폴더에
						*_bak.properties로 저장 됩니다.</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-warning btn_editMsgFile"
						data-dismiss="modal">파일 수정</button>
					<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>

</div>

