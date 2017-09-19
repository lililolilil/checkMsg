<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<nav class="navbar navbar-inverse">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse"
				data-target="#myNavbar">
				<span class="icon-bar"></span> <span class="icon-bar"></span> <span
					class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="/simple">Simple</a>
		</div>
		<div class="collapse navbar-collapse" id="myNavbar">
			<ul class="nav navbar-nav">
				<li class=""><a href="${pageContext.request.contextPath}">Home</a></li>
				<li class="dropdown"><a class="dropdown-toggle"
					data-toggle="dropdown" href="#">checkMsg<span class="caret"></span></a>
					<ul class="dropdown-menu">
						<li><a href="${pageContext.request.contextPath}/checkMsg/getAllMessage">전체메시지조회</a></li>
						<li><a href="${pageContext.request.contextPath}/checkMsg/syncMessage">메시지간 싱크맞추기</a></li>
						<li><a href="${pageContext.request.contextPath}/checkMsg/usingMessage">필요한 메시지 조회</a></li>
					</ul></li>
			</ul>


			<form class="navbar-form navbar-right">
				<div class="form-group">
					<input type="text" class="form-control" placeholder="Search">
				</div>
				<button type="submit" class="btn btn-default">Submit</button>
			</form>

		</div>
	</div>
</nav>