<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page session="false"%>


<script>

$(document).ready(function(){
   // test(); 
    init(); 
    addEvent(); 
})
</script>

<div id="u_container">
	<div class="well u_formContainer">
		<form id="using_form" role="form">
			<!--
			// base dir 이 있으니까 불편하네.. 
			 <div class="form-group">
				<label for="u_baseDir">baseDir:</label> <input type="text"
					class="form-control" id="u_baseDir" name="u_baseDir"
					placeholder="베이스 디렉터리를 입력해 주세요  ex)C:/Users/git/mcare-hospital"
					required="required">
			</div> -->
			<div class="form-group">
				<label for="input_javaDir">javafileDir:</label> 
				<div id="javaDir_container">
				</div>
				<input type="text"
					class="form-control"
					placeholder="java파일 최상위 디렉터리를 입력해 주세요. 여러개 추가 가능." id="input_javaDir">
				<button type="button" class="btn btn-default addBtn"
					data-item_name="javaDir">+</button>
			</div>
			<div class="form-group">
				<label for="input_javaPattern">javaPattern:</label>
				<div id="javaPatterns_container">
				<!--  기본값  -->
					<span class="itemBox"><span class="javaPattern">Exception\(\"([a-z0-9]+[.]([a-z0-9]+[.]?)+)\",</span>
					<button type="button" class="btn deleteBox" data-role="button">x</button></span>
					<span class="itemBox"><span class="javaPattern">getMessage\(\"([^>\"']+)\",</span>
					<button type="button" class="btn deleteBox" data-role="button">x</button></span>
				</div>
				<input type="text" class="form-control input_pattern"
					placeholder="추가 하실 패턴을 입력해 주세요 " id="input_javaPattern">
				<button type="button" class="btn btn-default addBtn"
					data-item_name="javaPattern">+</button>
			</div>

			<div class="form-group">
				<label for="input_viewDir">viewfileDir:</label> 
				<div id="viewDir_container">
				</div>
				<input type="text"
					class="form-control" id="input_viewDir" 
					placeholder="view파일 최상위 디렉터리를 입력해 주세요.">
				<button type="button" class="btn btn-default addBtn"
					data-item_name="viewDir">+</button>
			</div>

			<div class="form-group">
				<label for="input_viewPattern">viewPattern:</label>
				<div id="viewPattern_container">
					<span class="itemBox"><span class="viewPattern">
							s:message[ ]+code=[\"']?([^>\"']+)[\"']?[^>]*</span>
					<button type="button" class="btn deletePT" data-role="button">x</button></span>
				</div>
				<input type="text" class="form-control input_pattern"
					id="input_viewPattern" placeholder="추가 하실 패턴을 정규식으로 입력해 주세요.">
				<button type="button" class="btn btn-default addBtn" data-item_name="viewPattern">+</button>
			</div>

			<div class="form-group">
				<label for="standardMsgfileDir">standardMsgfileDir:</label> <input
					type="text" class="form-control" id="standardMsgfileDir"
					name="standardMsgfileDir"
					placeholder="비교 메시지를 가져올 폴더의 경로를 입력해 주세요. "
					required="required">
			</div>
			<button type="reset" class="btn btn-warning">Clear form</button>
			<button type="submit" class="btn btn-success submitBtn">Submit</button>
		</form>
	</div>
	<div id="using_result" class="table-responsive usingMessage"></div>
</div>

