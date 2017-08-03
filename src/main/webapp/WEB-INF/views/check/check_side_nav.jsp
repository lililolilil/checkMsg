<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<script>
$(document).on("ready",function(){
	var menu = "${menu}"; 
	if (menu == null || menu === ""){
	    $(".side_nav").hide();
	    $(".content").removeClass("col-sm-10"); 
	    $(".container").css("width","70%"); 
	}else{
	    $(".${menu}").addClass("active"); 
	}
});
</script>

<div class="list-group">
	<a href="getAllMessage" class="list-group-item getAllMessage">
		<h4 class="list-group-item-heading">전체 메시지조회</h4>
		<p class="list-group-item-text"> 전체 메시지를 조회합니다.</p>
	</a> <a href="syncMessage" class="list-group-item syncMessage">
		<h4 class="list-group-item-heading">syncMessage</h4>
		<p class="list-group-item-text">각 메시지 파일을 비교해 줍니다.</p>
	</a> <a href="usingMessage" class="list-group-item usingMessage">
		<h4 class="list-group-item-heading">usingMessage</h4>
		<p class="list-group-item-text">java,view에서 사용하는 메시지와 정의된 메시지를
			비교합니다.</p>
	</a>
</div>
