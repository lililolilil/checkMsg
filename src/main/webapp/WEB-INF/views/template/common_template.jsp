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
	<nav><tiles:insertAttribute name="top_nav" /></nav>
	<div class="container">
		<nav class="col-sm-3 side_nav">
			<tiles:insertAttribute name="side_nav"/>
		</nav>
		<section class="col-sm-9 content">
			<tiles:insertAttribute name="content" />
		</section>
		<footer>
			<tiles:insertAttribute name="footer" />
		</footer>
	</div>
</body>
</html>


