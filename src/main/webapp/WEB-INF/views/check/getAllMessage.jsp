<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript"
	src="<c:url value="/resources/js/getAllMessage.js" />"></script>
<link rel="stylesheet"
	href="<c:url value="/resources/css/getAllMessage.css"/>" />

<script>
    $(document).ready(function() {
	// test(); 
	init();
	addEvent();
    })
</script>

<div id="container">
	<div class="well s_formContainer clearfix">
		<form id="sync_form" role="form" class="horizontal">
			<!-- <div class="form-group">
				<div class="col-sm-12">
					<label for="baseDir">baseDir:</label>
				</div>
				<div class="col-sm-12">
					<input type="text" class="form-control" id="baseDir" name="baseDir"
						placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
						required="required">
				</div>
			</div> -->
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
			<div class="input-group">
				<div id="radioBtn" class="btn-group">
					<a class="btn btn-primary btn-sm active" data-toggle="tooltip"
						data-name="opType" data-target="#edit_condition" data-title="edit">파일수정</a>
					<a class="btn btn-default btn-sm" data-toggle="tooltip"
						data-name="opType" data-target="#create_condition"
						data-title="create">파일생성</a>
				</div>
				<input type="hidden" name="opType" id="opType">
			</div>

			<div class="option_container">
				<div id="edit_condition" class="targetContainer">
					<div class="alert alert-info col-sm-12 clearfix">
						<div class="col-sm-3">
							<strong>파일 수정 </strong>
						</div>
						<div class="col-sm-9">
							각 파일에 존재하는 메시지 코드에 매칭되는 문자열 값을 변경합니다.
							<p class="text-danger">
								<strong>주의!</strong> 메시지를 추가할 수 없습니다.
							</p>
						</div>
					</div>
					<p class="notice col-sm-12">수정한 내용을 반영할 파일을 선택해 주세요.</p>
					<div class="editFile_cb clearfix col-sm-12"></div>
					<div class="form-group col-sm-12">
						<button type="button"
							class="btn btn-primary btn-block btn-editMsgfile">수정내용을
							반영하여 메시지 파일 생성</button>
					</div>
				</div>

				<div id="create_condition" class="targetContainer">
					<div class="alert alert-info col-sm-12 clearfix">
						<div class="col-sm-2">
							<strong>파일 생성</strong>
						</div>
						<div class="col-sm-9">
							하나의 파일을 선택하여 선택한 파일을 기준으로 나머지 파일을 생성합니다. <br> 기준이 되는 메시지리소스에
							메시지 키값이 존재하여야만 해당 키값으로 메시지 리소스를 추가 할 수있습니다.
						</div>
					</div>
					
					<div class="col-sm-6">
						<p class="notice col-sm-12">기준이 될 파일을 선택해 주세요.</p>
						<div class="fileBeStandard well col-sm-12"></div>
					</div>
					
					<div class="col-sm-6">
						<p class="notice col-sm-12"> 생성할 파일입니다.</p>
						<div id="newfileName_container" class="fileWillCreate well col-sm-12">
						</div>
					</div>
					<div class="col-sm-12">
							<div class="msgFileDir col-sm-6" style="word-wrap: break-word;">
								
							</div>
							<div class="col-sm-4">
							<input type="text" class="form-control " id="input_newfileName"
								placeholder="파일명을 입력해주세요">
							</div>
							<button type="button" data-item-name="newfileName"
							class="btn btn-default pull-right col-sm-2 addBtn">파일 추가</button>
					</div>
					<div class="form-group col-sm-12 clearfix">
						<button type="button"
							class="btn btn-warning btn-block btn-createMsgfile">하나의
							파일을 기준으로 메시지파일 생성</button>
					</div>
				</div>
				
			</div>

		</div>
		
	</div>
	<div id="result" class="table-responsive syncMessage"></div>
</div>
