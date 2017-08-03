<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@include file="common_include.jsp"%>
</head>
<body>
	<header>
		<tiles:insertAttribute name="header" />
	</header>
	<div class="container">
		<nav class="col-sm-2">
			<tiles:insertAttribute name="hello" />
		</nav>
		<section class="col-sm-10">
			<tiles:insertAttribute name="content" />
		</section>
		<footer>
			<tiles:insertAttribute name="footer" />
		</footer>
	</div>
</body>
</html>


