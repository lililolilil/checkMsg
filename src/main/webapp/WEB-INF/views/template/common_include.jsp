<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%request.setCharacterEncoding("UTF-8");%>
<c:set var="contextPath" value="<%= request.getContextPath()%>"></c:set> 
<script> var contextPath = "${contextPath}"</script>
<!-- jquery -->
<script type="text/javascript" src="<c:url value="/resources/plugins/jquery/jquery-2.1.4.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/plugins/jquery.cookie.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/common.js" />"></script>
 
<!-- bootstrap -->
<script src="<c:url value="/resources/plugins/bootstrap/js/bootstrap.min.js"/>"></script> 
<link rel="stylesheet" href="<c:url value="/resources/plugins/bootstrap/css/bootstrap.min.css" />" />
<link rel="stylesheet" href="<c:url value="/resources/plugins/bootstrap/css/bootstrap-theme.min.css" />" />
<!-- 공통 css/js  -->
<link rel="stylesheet" href="<c:url value="/resources/css/common.css" />" />
<script src="<c:url value="/resources/js/common.js"/>"></script> 

<!-- CDN  
jquery 
<script src="https://code.jquery.com/jquery-3.2.1.js"
	integrity="sha256-DZAnKJ/6XZ9si04Hgrsxu/8s717jcIzLy3oi35EouyE="
	crossorigin="anonymous"></script>

Latest compiled and minified CSS
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
	integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
	crossorigin="anonymous">

 
Optional theme
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
	integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp"
	crossorigin="anonymous">

Latest compiled and minified JavaScript
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
	integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa"
	crossorigin="anonymous"></script>
 -->
