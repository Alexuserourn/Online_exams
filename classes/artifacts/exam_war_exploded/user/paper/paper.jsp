<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
		+ request.getServerName() + ":" + request.getServerPort()
		+ path + "/";
%>

<!DOCTYPE HTML>
<html>

<head>
	<base href="<%=basePath%>">
	<title>在线答题</title>
	<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="<%=basePath%>css/paper.css">
	<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
	<script src="<%=basePath%>js/bootstrap.js"></script>
	<script src="<%=basePath%>layer/layer.js"></script>
	<!-- 内联layer样式，避免依赖外部CSS -->
	<style>
		/* Layer基本样式 */
		.layui-layer-dialog .layui-layer-content {
			position: relative;
			padding: 20px;
			line-height: 24px;
			word-break: break-all;
			overflow: hidden;
			font-size: 14px;
			overflow-x: hidden;
			overflow-y: auto;
		}
		.layui-layer-ico {
			background: url(<%=basePath%>layer/theme/default/icon.png) no-repeat;
		}
		.layui-layer-ico16 {
			background-position: -240px -0px;
		}
		.layui-layer-btn a {
			height: 28px;
			line-height: 28px;
			margin: 5px 5px 0;
			padding: 0 15px;
			border: 1px solid #dedede;
			background-color: #fff;
			color: #333;
			border-radius: 2px;
			font-weight: 400;
			cursor: pointer;
			text-decoration: none;
			display: inline-block;
		}
		.layui-layer {
			-webkit-animation-fill-mode: both;
			animation-fill-mode: both;
			-webkit-animation-duration: .3s;
			animation-duration: .3s;
			-webkit-animation-name: layer-bounceIn;
			animation-name: layer-bounceIn;
			border-radius: 2px;
			-webkit-animation-duration: 0.3s;
			animation-duration: 0.3s;
			-webkit-animation-fill-mode: both;
			animation-fill-mode: both;
			position: fixed;
			_position: absolute;
			pointer-events: auto;
			background-color: #fff;
			-webkit-background-clip: content;
			border-radius: 2px;
			box-shadow: 1px 1px 50px rgba(0,0,0,.3);
		}
		.layui-layer-title {
			padding: 0 80px 0 20px;
			height: 42px;
			line-height: 42px;
			border-bottom: 1px solid #eee;
			font-size: 14px;
			color: #333;
			overflow: hidden;
			background-color: #F8F8F8;
			border-radius: 2px 2px 0 0;
		}
		.layui-layer-setwin {
			position: absolute;
			right: 15px;
			top: 15px;
			font-size: 0;
			line-height: initial;
		}
		.layui-layer-btn {
			text-align: right;
			padding: 0 15px 12px;
			pointer-events: auto;
			user-select: none;
			-webkit-user-select: none;
		}
		.layui-layer-btn a {
			height: 28px;
			line-height: 28px;
			margin: 5px 5px 0;
			padding: 0 15px;
			border: 1px solid #dedede;
			background-color: #fff;
			color: #333;
			border-radius: 2px;
			font-weight: 400;
			cursor: pointer;
			text-decoration: none;
		}
		.layui-layer-btn .layui-layer-btn0 {
			border-color: #1E9FFF;
			background-color: #1E9FFF;
			color: #fff;
		}
		.layui-layer-shade {
			background-color: #000;
			opacity: 0.3;
			filter: alpha(opacity=30);
			pointer-events: auto;
		}
		.layui-layer-shade, .layui-layer {
			position: fixed;
			_position: absolute;
			pointer-events: auto;
		}
		.layui-layer-dialog .layui-layer-ico {
			position: absolute;
			top: 16px;
			left: 15px;
			_left: -40px;
			width: 30px;
			height: 30px;
		}
		.layui-layer-ico1 {
			background-position: -30px 0
		}
		.layui-layer-ico2 {
			background-position: -60px 0
		}
		.layui-layer-ico3 {
			background-position: -90px 0
		}
		.layui-layer-ico4 {
			background-position: -120px 0
		}
		.layui-layer-ico5 {
			background-position: -150px 0
		}
		.layui-layer-ico6 {
			background-position: -180px 0
		}
		.layui-layer-rim {
			border: 6px solid #8D8D8D;
			border: 6px solid rgba(0,0,0,.3);
			border-radius: 5px;
			box-shadow: none
		}
		.layui-layer-msg {
			min-width: 180px;
			border: 1px solid #D3D4D3;
			box-shadow: none
		}
		.layui-layer-dialog .layui-layer-content {
			position: relative;
			padding: 20px 20px 20px 60px !important; /* 左侧留出足够空间给图标 */
			line-height: 24px;
			word-break: break-all;
			overflow: hidden;
			font-size: 14px;
			overflow-x: hidden;
			overflow-y: auto;
			min-height: 40px !important;
		}
		.layui-layer-dialog .layui-layer-content .layui-layer-ico {
			position: absolute !important;
			left: 20px !important;
			top: 50% !important;
			margin-top: -15px !important;
		}
		.layui-layer-page .layui-layer-content {
			position: relative;
			overflow: auto;
		}
		.layui-layer-nobg {
			background: 0 0;
		}
		.layui-layer-iframe .layui-layer-content {
			position: relative;
			overflow: visible;
		}
		.layui-layer-load {
			background: url(<%=basePath%>layer/theme/default/loading-0.gif) center center no-repeat #fff;
		}
		.layui-layer-load-1 {
			width: 37px;
			height: 37px;
			background: url(<%=basePath%>layer/theme/default/loading-1.gif) center center no-repeat;
		}
		.layui-layer-load-2 {
			width: 32px;
			height: 32px;
			background: url(<%=basePath%>layer/theme/default/loading-2.gif) center center no-repeat;
		}
		/* 弹出层动画 */
		@keyframes layer-bounceIn {
			0% {
				opacity: 0;
				transform: scale(.5);
			}
			100% {
				opacity: 1;
				transform: scale(1);
			}
		}
		@keyframes layer-bounceOut {
			100% {
				opacity: 0;
				transform: scale(.7);
			}
			30% {
				transform: scale(1.05);
			}
			0% {
				transform: scale(1);
			}
		}
		.layer-anim-close {
			animation-name: layer-bounceOut;
			animation-duration: .2s;
		}
		/* 确保弹窗居中 */
		.layui-layer-page {
			top: 50% !important;
			left: 50% !important;
			transform: translate(-50%, -50%);
		}
		.layui-layer-dialog {
			top: 50% !important;
			left: 50% !important;
			transform: translate(-50%, -50%);
		}
	</style>
</head>

<body>
	<nav class="navbar navbar-default" role="navigation">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#">教学辅助系统</a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse navbar-ex1-collapse">
			<ul class="nav navbar-nav">
				<li><a href="<%=basePath%>user?cmd=paperlist">试题列表</a></li>
				<li><a href="<%=basePath%>user/studentPaper?cmd=stupaper">查看错题</a></li>
				<li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
				<li><a href="<%=basePath%>statistics?cmd=studentStats">成绩统计</a></li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<c:choose>
					<c:when test="${userid!=null}">
						<li>
							<a>
								<c:out value="${sessionScope.user.usertruename}" />
							</a>
						</li>
						<li>
							<a href="<%=basePath%>user?cmd=logout">注销</a>
						</li>
					</c:when>
					<c:otherwise>
						<li><a href="login.jsp">登录</a></li>

					</c:otherwise>
				</c:choose>

			</ul>
		</div>
		<!-- /.navbar-collapse -->
	</nav>

	<main class="container">
		<div class="panel panel-default">
			<div class="panel-heading text-center">
				<h3 class="panel-title">
					<c:out value="${pname}"></c:out>
				</h3>
			</div>
			<div class="panel-body">
				<form action="" method="POST" role="form">
					<!-- 直接遍历所有题目，根据类型显示，避免ArrayList连接问题 -->
					<c:set var="singleChoiceCount" value="0"/>
					<c:set var="multiChoiceCount" value="0"/>
					<c:set var="judgmentCount" value="0"/>
					<c:set var="fillBlankCount" value="0"/>
					<c:set var="essayCount" value="0"/>
					
					<!-- 统计各类型题目数量 -->
					<c:forEach items="${subjects}" var="item">
						<c:choose>
							<c:when test="${item.stype == 1 || item.stype == null}">
								<c:set var="singleChoiceCount" value="${singleChoiceCount + 1}"/>
							</c:when>
							<c:when test="${item.stype == 2}">
								<c:set var="multiChoiceCount" value="${multiChoiceCount + 1}"/>
							</c:when>
							<c:when test="${item.stype == 3}">
								<c:set var="judgmentCount" value="${judgmentCount + 1}"/>
							</c:when>
							<c:when test="${item.stype == 4}">
								<c:set var="fillBlankCount" value="${fillBlankCount + 1}"/>
							</c:when>
							<c:when test="${item.stype == 5}">
								<c:set var="essayCount" value="${essayCount + 1}"/>
							</c:when>
						</c:choose>
					</c:forEach>
					
					<!-- 单选题 -->
					<c:if test="${singleChoiceCount > 0}">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#accordion" href="#singleChoice">单选题</a>
								</h4>
							</div>
							<div id="singleChoice" class="panel-collapse collapse in">
								<div class="panel-body">
									<ol>
										<c:forEach items="${subjects}" var="item" varStatus="status">
											<c:if test="${item.stype == 1 || item.stype == null}">
												<div class="subject" data-i="${status.index}" data-answer="false" data-sid="${item.sid}" data-key="${item.skey}" data-state="0" data-skey data-type="1" data-score="${item.score}">
													<li> ${item.scontent} <span class="badge">${item.score}分</span></li>
													<ol>
														<li><label><input type="radio" value="A" name="${item.sid}">${item.sa}</label></li>
														<li><label><input type="radio" value="B" name="${item.sid}">${item.sb}</label></li>
														<li><label><input type="radio" value="C" name="${item.sid}">${item.sc}</label></li>
														<li><label><input type="radio" value="D" name="${item.sid}">${item.sd}</label></li>
													</ol>
												</div>
											</c:if>
										</c:forEach>
									</ol>
								</div>
							</div>
						</div>
					</c:if>
					
					<!-- 多选题 -->
					<c:if test="${multiChoiceCount > 0}">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#accordion" href="#multiChoice">多选题</a>
								</h4>
							</div>
							<div id="multiChoice" class="panel-collapse collapse in">
								<div class="panel-body">
									<ol>
										<c:forEach items="${subjects}" var="item" varStatus="status">
											<c:if test="${item.stype == 2}">
												<div class="subject" data-i="${status.index}" data-answer="false" data-sid="${item.sid}" data-key="${item.skey}" data-state="0" data-skey="" data-type="2" data-score="${item.score}">
													<li> ${item.scontent} <span class="badge">${item.score}分</span></li>
													<ol>
														<li><label><input type="checkbox" value="A" name="${item.sid}_option">${item.sa}</label></li>
														<li><label><input type="checkbox" value="B" name="${item.sid}_option">${item.sb}</label></li>
														<li><label><input type="checkbox" value="C" name="${item.sid}_option">${item.sc}</label></li>
														<li><label><input type="checkbox" value="D" name="${item.sid}_option">${item.sd}</label></li>
														<c:if test="${not empty item.se}">
															<li><label><input type="checkbox" value="E" name="${item.sid}_option">${item.se}</label></li>
														</c:if>
														<c:if test="${not empty item.sf}">
															<li><label><input type="checkbox" value="F" name="${item.sid}_option">${item.sf}</label></li>
														</c:if>
													</ol>
													<input type="hidden" name="${item.sid}" id="${item.sid}_value">
												</div>
											</c:if>
										</c:forEach>
									</ol>
								</div>
							</div>
						</div>
					</c:if>
					
					<!-- 判断题 -->
					<c:if test="${judgmentCount > 0}">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#accordion" href="#judgment">判断题</a>
								</h4>
							</div>
							<div id="judgment" class="panel-collapse collapse in">
								<div class="panel-body">
									<ol>
										<c:forEach items="${subjects}" var="item" varStatus="status">
											<c:if test="${item.stype == 3}">
												<div class="subject" data-i="${status.index}" data-answer="false" data-sid="${item.sid}" data-key="${item.skey}" data-state="0" data-skey data-type="3" data-score="${item.score}">
													<li> ${item.scontent} <span class="badge">${item.score}分</span></li>
													<ol>
														<li><label><input type="radio" value="A" name="${item.sid}">${item.sa}</label></li>
														<li><label><input type="radio" value="B" name="${item.sid}">${item.sb}</label></li>
													</ol>
												</div>
											</c:if>
										</c:forEach>
									</ol>
								</div>
							</div>
						</div>
					</c:if>
					
					<!-- 填空题 -->
					<c:if test="${fillBlankCount > 0}">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#accordion" href="#fillBlank">填空题</a>
								</h4>
							</div>
							<div id="fillBlank" class="panel-collapse collapse in">
								<div class="panel-body">
									<ol>
										<c:forEach items="${subjects}" var="item" varStatus="status">
											<c:if test="${item.stype == 4}">
												<div class="subject" data-i="${status.index}" data-answer="false" data-sid="${item.sid}" data-key="${item.standardAnswer}" data-state="0" data-skey data-type="4" data-score="${item.score}">
													<li> ${item.scontent} <span class="badge">${item.score}分</span></li>
													<div class="form-group">
														<input type="text" class="form-control" name="${item.sid}" placeholder="请输入答案">
													</div>
												</div>
											</c:if>
										</c:forEach>
									</ol>
								</div>
							</div>
						</div>
					</c:if>
					
					<!-- 简答题 -->
					<c:if test="${essayCount > 0}">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#accordion" href="#essay">简答题</a>
								</h4>
							</div>
							<div id="essay" class="panel-collapse collapse in">
								<div class="panel-body">
									<ol>
										<c:forEach items="${subjects}" var="item" varStatus="status">
											<c:if test="${item.stype == 5}">
												<div class="subject" data-i="${status.index}" data-answer="false" data-sid="${item.sid}" data-key="${item.standardAnswer}" data-state="0" data-skey data-type="5" data-score="${item.score}">
													<li> ${item.scontent} <span class="badge">${item.score}分</span></li>
													<div class="form-group">
														<textarea class="form-control" name="${item.sid}" rows="5" placeholder="请输入答案"></textarea>
													</div>
												</div>
											</c:if>
										</c:forEach>
									</ol>
								</div>
							</div>
						</div>
					</c:if>
					
					<button class="btn btn-success" type="submit">交卷</button>
				</form>
			</div>
		</div>
	</main>
	<aside class="processor">
		<section class="time" id="time">
			00时00分00秒
		</section>
		<section class="timu">
			<c:forEach items="${subjects}" var="item" varStatus="status">
				<div data-i="${ status.index}">${ status.index + 1}</div>
			</c:forEach>
		</section>
	</aside>

	<script>
		// 获取题目数量
		var len = $('.subject').length;
		var unanswer = len;
		
		// 获取basePath 
		var basePath = '<%=basePath%>'
		
		// 生成全局唯一的试卷ID
		var timestamp = new Date().getTime();
		
		// 添加鼠标离开页面检测
		var mouseLeaveCount = 0; // 记录鼠标离开次数
		var mouseLeaveTimer = null; // 计时器
		var mouseLeaveWarningShown = false; // 是否已显示警告
		var mouseLeaveSeconds = 0; // 记录鼠标离开时间（秒）
		
		// 监听鼠标离开页面事件
		$(document).on('mouseleave', function() {
			// 如果已经达到3次，不再处理
			if (mouseLeaveCount >= 3) return;
			
			// 清除之前的计时器
			clearInterval(mouseLeaveTimer);
			mouseLeaveSeconds = 0;
			mouseLeaveWarningShown = false;
			
			// 开始计时
			mouseLeaveTimer = setInterval(function() {
				mouseLeaveSeconds++;
				
				// 如果超过5秒且未显示警告
				if (mouseLeaveSeconds >= 5 && !mouseLeaveWarningShown) {
					mouseLeaveWarningShown = true;
					mouseLeaveCount++;
					
					// 根据离开次数显示不同提示
					if (mouseLeaveCount < 3) {
						// 前两次显示警告
						layer.open({
							type: 0,
							title: '警告',
							content: '您已离开考试页面 ' + mouseLeaveCount + ' 次，第3次将自动交卷！',
							icon: 0,
							offset: 'auto',
							area: ['350px', 'auto']
						});
					} else {
						// 第三次自动交卷
						layer.open({
							type: 0,
							title: '警告',
							content: '您已离开考试页面3次，系统将自动交卷！',
							icon: 0,
							offset: 'auto',
							area: ['350px', 'auto'],
							end: function() {
								// 自动交卷
								postAnswer();
							}
						});
					}
				}
			}, 1000); // 每秒检查一次
		});
		
		// 监听鼠标返回页面事件
		$(document).on('mouseenter', function() {
			// 清除计时器
			clearInterval(mouseLeaveTimer);
			mouseLeaveTimer = null;
		});
					
		// 监听单选题和判断题选项点击
		$('.subject[data-type="1"] ol li label, .subject[data-type="3"] ol li label').click(function () {
			// 获得本题的div
			var sub = $(this).parent().parent().parent()
			var indexs = sub.data('i')
			// 判断此题是否回答过
			if(sub.data('answer') == false){
				// 没有回答过给processor下的指定题号添加answered样式
				$('.timu').children().eq(indexs).addClass('answered');
				// 未答题目－1
				unanswer--
				sub.data('answer',true)
			}
			// 判断选项是否正确
			if($(this).find(':input').val() == sub.data('key')){
				// 正确给data-state赋值1
				sub.data('state',1)
			}else{
				// 不正确给data-state赋值0
				sub.data('state',0)
			}
			sub.data('skey',$(this).find(':input').val())
			// siblings() 获得匹配集合中每个元素的同胞，通过选择器进行筛选是可选的。
			$(this).parent().addClass('checked').siblings().removeClass('checked')
		});
		
		// 监听多选题选项点击
		$('.subject[data-type="2"] ol li label').click(function () {
			// 获得本题的div
			var sub = $(this).parent().parent().parent();
			var indexs = sub.data('i');
			var sid = sub.data('sid');
			
			// 标记为已回答
			if(sub.data('answer') == false){
				$('.timu').children().eq(indexs).addClass('answered');
				unanswer--;
				sub.data('answer', true);
			}
			
			// 获取所有选中的选项
			var selectedOptions = [];
			sub.find('input[type="checkbox"]:checked').each(function() {
				selectedOptions.push($(this).val());
			});
			
			// 按字母顺序排序选项
			selectedOptions.sort();
			var selectedKey = selectedOptions.join('');
			
			// 更新隐藏字段的值
			$('#' + sid + '_value').val(selectedKey);
			
			// 判断答案是否正确
			if(selectedKey == sub.data('key')){
				sub.data('state', 1);
			} else {
				sub.data('state', 0);
			}
			
			// 更新学生答案
			sub.data('skey', selectedKey);
		});
		
		// 监听填空题输入
		$('.subject[data-type="4"] input').on('input', function() {
			var sub = $(this).closest('.subject');
			var indexs = sub.data('i');
			
			// 标记为已回答（只要有输入就算作答）
			if(sub.data('answer') == false && $(this).val().trim() !== ''){
				$('.timu').children().eq(indexs).addClass('answered');
				unanswer--;
				sub.data('answer', true);
			} else if($(this).val().trim() === '') {
				// 如果清空了答案，标记为未回答
				$('.timu').children().eq(indexs).removeClass('answered');
				unanswer++;
				sub.data('answer', false);
			}
			
			// 更新学生答案
			sub.data('skey', $(this).val());
			
			// 判断答案是否正确（填空题需要精确匹配）
			// 转换为字符串并去除两端空格后比较
			var studentAnswer = $(this).val().toString().trim();
			var correctAnswer = (sub.data('key') || '').toString().trim();
			
			console.log('填空题比较 - 学生答案:', studentAnswer, '标准答案:', correctAnswer);
			
			if(studentAnswer === correctAnswer){
				sub.data('state', 1);
				console.log('答案正确');
			} else {
				sub.data('state', 0);
				console.log('答案错误');
			}
		});
		
		// 监听简答题输入
		$('.subject[data-type="5"] textarea').on('input', function() {
			var sub = $(this).closest('.subject');
			var indexs = sub.data('i');
			
			// 标记为已回答（只要有输入就算作答）
			if(sub.data('answer') == false && $(this).val().trim() !== ''){
				$('.timu').children().eq(indexs).addClass('answered');
				unanswer--;
				sub.data('answer', true);
			} else if($(this).val().trim() === '') {
				// 如果清空了答案，标记为未回答
				$('.timu').children().eq(indexs).removeClass('answered');
				unanswer++;
				sub.data('answer', false);
			}
			
			// 更新学生答案
			sub.data('skey', $(this).val());
			
			// 简答题需要人工评分，先标记为0
			sub.data('state', 0);
		});
		
		// 交卷功能
		// (1)判断是否有未答题目
		function unAnswer(){
			if(unanswer != 0){
				layer.open({
					type: 0,
					title:'提示', 
					content: "还有"+unanswer+"道题目未做，是否继续作答？",
					icon: 0,
					offset: 'auto', // 设置为auto使弹窗居中显示
					area: ['350px', 'auto'], // 设置宽度，避免文字重叠
					btn: ['继续作答', '直接交卷'], // 添加两个按钮选项
					yes: function(index){
						// 点击继续作答，关闭弹窗
						layer.close(index);
					},
					btn2: function(index){
						// 点击直接交卷，关闭弹窗并提交
						layer.close(index);
						postAnswer();
					}
				});
			}else{
				// 全部题目已完成，直接提交
				postAnswer();
			}
		}
		
		// (2)计算得分
		function getScore(){
			var loadingIndex = layer.load(1, {shade: [0.3, '#fff']});
			// 使用全局变量timestamp作为spid
			$.ajax({
		        url: basePath + 'user/studentPaper?cmd=score&userid='+'${userid}'+'&spid='+ timestamp,
		        type: 'POST',
		        contentType: false,
		        processData: false,
		        success: function(res) {
		            console.log(res);
		            layer.close(loadingIndex);
		            layer.open({
						type: 0,
						title:'得分', 
						content: res,
						icon: 1,
						offset: 'auto', // 设置为auto使弹窗居中显示
						area: ['350px', 'auto'], // 设置宽度，避免文字重叠
						end:function(){
							location.href = basePath+'user/studentPaper?cmd=stupaper';
						}
					});
		        },
		        error: function(res) {
		            console.log('error');
		            layer.close(loadingIndex);
		            layer.alert('获取得分失败，请稍后查看成绩', {
		                icon: 2,
		                offset: 'auto'
		            });
		        }
		    });
		}
		
		// (3)提交答案的post请求
		function postAnswer(){
			var loadingIndex = layer.load(1, {shade: [0.3, '#fff']});
			var pname = '${pname}';
			var userid = '${userid}';
			var completed = 0;
			
			$('.subject').each(function(index){
				var self = $(this);
				var type = self.data('type');
				var score = self.data('score') || 2; // 默认2分
				
				// 针对不同类型题目获取答案
				if(type == 2) { // 多选题
					// 多选题答案已经在点击时更新到隐藏字段
					var studentkey = $('#' + self.data('sid') + '_value').val() || '';
					self.data('skey', studentkey);
				} else if(type == 4) { // 填空题
					var studentkey = self.find('input').val() || '';
					self.data('skey', studentkey);
					
					// 重新判断答案是否正确
					var studentAnswer = studentkey.toString().trim();
					var correctAnswer = (self.data('key') || '').toString().trim();
					
					if(studentAnswer === correctAnswer){
						self.data('state', 1); // 正确
					} else {
						self.data('state', 0); // 错误
					}
				} else if(type == 5) { // 简答题
					var studentkey = self.find('textarea').val() || '';
					self.data('skey', studentkey);
				}
				
				// 准备提交数据
				var data = {
					userid: userid,
					sid: self.data('sid'),
					studentkey: self.data('skey') || '',
					studentstate: self.data('state') || 0,
					pname: pname,
					spid: timestamp, // 使用全局timestamp
					stype: type,
					score: score
				};
				
				$.ajax({
					url: basePath+'/user?cmd=answer&'+ $.param(data),
					type: 'POST',
					contentType: false,
					processData: false,
					success:function(){
						completed++;
						if(completed >= len){
							layer.close(loadingIndex);
							getScore();
						}
					},
					error:function(){
						completed++;
						if(completed >= len){
							layer.close(loadingIndex);
							getScore();
						}
					}
				});
			});
		}
		
		// (4)点击交卷
		$('form').submit(function(ev) {
			ev.preventDefault();
			unAnswer();
		});
		
		// 倒计时功能
		//小于10的数字前面补0
		function p(n){
			return n<10?'0'+n:n;
		}
		//获取当前时间
		var now = new Date();
		//获取结束时间
		var endDate = new Date();
		//设置考试时间（单位分钟）
		var examTime = parseInt("${examTime != null ? examTime : 20}"); // 使用后端传来的考试时间，默认20分钟
		endDate.setMinutes(now.getMinutes()+examTime)
		function getTime(){           
			var startDate = new Date();
			var countDown = (endDate.getTime()-startDate.getTime())/1000;
			var h = parseInt(countDown/(60*60)%24);
			var m = parseInt(countDown/60%60);
			var s = parseInt(countDown%60);                
			$('.time').html(p(h)+'时'+p(m)+'分'+p(s)+'秒');
			if(countDown<=0){
				document.getElementById('time').innerHTML='考试结束';
				layer.open({
					type: 0,
					title:'提示', 
					content: '考试时间到，试卷将被提交！',
					icon: 0,
					offset: 'auto', // 设置为auto使弹窗居中显示
					area: ['350px', 'auto'], // 设置宽度，避免文字重叠
					end:function(){
						postAnswer();
					}
				})
			}else{
				setTimeout('getTime()',500);
			}              
		}
		getTime();
	</script>
</body>

</html>