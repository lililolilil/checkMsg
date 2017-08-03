<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<style>
.footer{
	clear: both;
}
</style>
<div class="footer"></div>
<div class="modal fade" id="progressbar" role="dialog">
	<div class="modal-dialog">
		<!-- Modal content-->
		<div class="modal-content">
			<div class="modal-body">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<p>요청하신 작업을 진행 중입니다.</p>
				<div id="myProgress" class="progress">
					<div id="myBar"
						class="progress-bar progress-bar-success progress-bar-striped active"
						role="progressbar"></div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="modal fade" id="loader" role="dialog">
	<div class="modal-dialog">
		<!-- Modal content-->

		<div class="modal-content">
			<div class="modal-body">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<p>요청하신 작업을 수행중입니다.</p>
				<div class="loader"></div>
			</div>
		</div>
	</div>
</div>
