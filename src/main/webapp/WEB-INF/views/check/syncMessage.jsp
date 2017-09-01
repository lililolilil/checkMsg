<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript"
	src="<c:url value="/resources/js/syncMessage.js" />"></script>
<link rel="stylesheet"
	href="<c:url value="/resources/css/syncMessage.css"/>" />

<div id="container">
	<div class="well s_formContainer clearfix">
		<form id="sync_form" role="form" class="horizontal">
			<!-- <div class="form-group">
				<div class="col-sm-12">
					<label for="s_baseDir">baseDir:</label>
				</div>
				<div class="col-sm-12">
					<input type="text" class="form-control" id="s_baseDir" name="s_baseDir"
						placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
						required="required">
				</div>
			</div> -->
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

<script>
$(document).ready(function(){
   // test(); 
    init(); 
    addEvent(); 
})
</script>
