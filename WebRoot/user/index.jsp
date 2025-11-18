<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
			
	// 获取通知消息（如果有）
	String notification = (String)session.getAttribute("notification");
	String notificationType = (String)session.getAttribute("notificationType");
	
	// 清除会话中的通知，避免刷新时重复显示
	session.removeAttribute("notification");
	session.removeAttribute("notificationType");
%>

<!DOCTYPE HTML>
<html lang="zh-CN">

<head>
	<base href="<%=basePath%>">
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>教学辅助系统</title>
	<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="<%=basePath%>css/paper.css">
	<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
	<script src="<%=basePath%>js/bootstrap.js"></script>
	
	<!-- Toast通知样式 -->
	<style>
		/* Toast通知样式 */
		.toast-container{position:fixed;top:20px;right:20px;z-index:9999;}
		.toast{background-color:#fff;border-radius:6px;box-shadow:0 3px 10px rgba(0,0,0,0.15);margin-bottom:10px;overflow:hidden;animation:slideIn 0.5s;}
		.toast-success{border-left:6px solid #4CAF50;}
		.toast-error{border-left:6px solid #f44336;}
		.toast-warning{border-left:6px solid #ff9800;}
		.toast-info{border-left:6px solid #2196F3;}
		.toast-header{display:flex;justify-content:space-between;align-items:center;padding:10px 15px;background-color:#f8f9fa;}
		.toast-title{font-weight:bold;font-size:16px;margin:0;}
		.toast-close{background:none;border:none;font-size:20px;cursor:pointer;color:#aaa;line-height:0.8;}
		.toast-close:hover{color:#555;}
		.toast-body{padding:15px;font-size:14px;}
		.toast-success .toast-title{color:#4CAF50;}
		.toast-error .toast-title{color:#f44336;}
		.toast-warning .toast-title{color:#ff9800;}
		.toast-info .toast-title{color:#2196F3;}
		@keyframes slideIn{from{transform:translateX(100%);opacity:0;}to{transform:translateX(0);opacity:1;}}
		@keyframes fadeOut{from{opacity:1;}to{opacity:0;}}
		
		/* 页面优化样式 */
		body {
			background-color: #f5f5f5;
			padding-bottom: 30px;
		}
		.jumbotron {
			background-color: #fff;
			border-radius: 6px;
			box-shadow: 0 2px 10px rgba(0,0,0,0.05);
			position: relative;
			overflow: hidden;
		}
		.jumbotron:before {
			content: "";
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 5px;
			background: linear-gradient(to right, #4CAF50, #2196F3);
		}
		.feature-box {
			background-color: #fff;
			border-radius: 6px;
			padding: 20px;
			margin-bottom: 20px;
			box-shadow: 0 2px 10px rgba(0,0,0,0.05);
			transition: transform 0.3s ease, box-shadow 0.3s ease;
		}
		.feature-box:hover {
			transform: translateY(-5px);
			box-shadow: 0 5px 15px rgba(0,0,0,0.1);
		}
		.feature-title {
			font-size: 22px;
			font-weight: 500;
			margin-bottom: 15px;
			color: #333;
		}
		.feature-description {
			color: #666;
			margin-bottom: 20px;
		}
		.btn-feature {
			margin-top: 10px;
			padding: 8px 20px;
		}
		.navbar {
			box-shadow: 0 2px 10px rgba(0,0,0,0.05);
		}
	</style>
</head>

<body>
	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<nav class="navbar navbar-default">
					<div class="container-fluid">
						<div class="navbar-header">
							<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
								<span class="sr-only">Toggle navigation</span>
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
							</button>
							<a class="navbar-brand" href="<%=basePath%>user/index.jsp">教学辅助系统</a>
						</div>
						<div id="navbar" class="navbar-collapse collapse">
							<ul class="nav navbar-nav">
								<li><a href="<%=basePath%>user?cmd=paperlist">试题列表</a></li>
								<li><a href="<%=basePath%>user/studentPaper?cmd=stupaper">我的试卷</a></li>
								<li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
								<li><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
								<li><a href="<%=basePath%>statistics?cmd=studentStats">成绩统计</a></li>
							</ul>
							<ul class="nav navbar-nav navbar-right">
								<li><a href="#">欢迎, ${user.usertruename}</a></li>
								<li><a href="<%=basePath%>sys/user?cmd=logout">退出</a></li>
							</ul>
						</div>
					</div>
				</nav>
			</div>
		</div>
		
		<div class="row">
			<div class="col-md-12">
				<div class="jumbotron">
					<h1>欢迎使用教学辅助系统</h1>
					<p>这是一个教学辅助系统，您可以在这里参加考试、查看错题、进行自由练习，以及查看您的成绩统计分析。</p>
				</div>
			</div>
		</div>
		
		<div class="row">
			<!-- 试题列表 -->
			<div class="col-md-12">
				<h2 class="text-center" style="margin-bottom: 30px;">可用试题列表</h2>
				<div class="table-responsive">
					<table class="table table-striped table-hover">
						<thead>
							<tr>
								<th width="70%">试卷名称</th>
								<th width="15%">题目数量</th>
								<th width="15%">操作</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${papers}" var="item">
								<tr>
									<td>${item.pname}</td>
									<td>${item.scount}</td>
									<td>
										<a href="<%=basePath%>user?cmd=paper&pname=${item.pname}" class="btn btn-sm btn-primary">开始答题</a>
									</td>
								</tr>
							</c:forEach>
							<c:if test="${empty papers}">
								<tr>
									<td colspan="3" class="text-center">
										<p class="text-muted" style="padding: 20px 0;">暂无可用试题</p>
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		
		<div class="row" style="margin-top: 30px;">
			<div class="col-md-3">
				<div class="feature-box text-center">
					<h3 class="feature-title">试题列表</h3>
					<p class="feature-description">查看所有可用的试题并开始答题</p>
					<a class="btn btn-primary btn-feature" href="<%=basePath%>user?cmd=paperlist" role="button">查看试题</a>
				</div>
			</div>
			<div class="col-md-3">
				<div class="feature-box text-center">
					<h3 class="feature-title">我的试卷</h3>
					<p class="feature-description">查看您已完成的试卷及成绩</p>
					<a class="btn btn-info btn-feature" href="<%=basePath%>user/studentPaper?cmd=stupaper" role="button">我的试卷</a>
				</div>
			</div>
			<div class="col-md-3">
				<div class="feature-box text-center">
					<h3 class="feature-title">错题集</h3>
					<p class="feature-description">查看您的错题并进行复习</p>
					<a class="btn btn-danger btn-feature" href="<%=basePath%>user/studentPaper?cmd=allErrors" role="button">错题集</a>
				</div>
			</div>
			<div class="col-md-3">
				<div class="feature-box text-center">
					<h3 class="feature-title">成绩统计</h3>
					<p class="feature-description">查看您的成绩统计分析</p>
					<a class="btn btn-success btn-feature" href="<%=basePath%>statistics?cmd=studentStats" role="button">成绩统计</a>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 通知消息处理 -->
	<% if (notification != null && !notification.isEmpty()) { %>
	<div class="toast-container">
		<div class="toast toast-<%= notificationType != null ? notificationType : "info" %>">
			<div class="toast-header">
				<div class="toast-title">
					<% if ("success".equals(notificationType)) { %>
					成功
					<% } else if ("error".equals(notificationType)) { %>
					错误
					<% } else if ("warning".equals(notificationType)) { %>
					警告
					<% } else { %>
					信息
					<% } %>
				</div>
				<button class="toast-close" id="toast-close-btn">&times;</button>
			</div>
			<div class="toast-body"><%= notification %></div>
		</div>
	</div>
	
	<script>
		// 自动隐藏通知
		setTimeout(function() {
			$('.toast').css('animation', 'fadeOut 0.5s forwards');
			setTimeout(function() {
				$('.toast-container').remove();
			}, 500);
		}, 5000);
		
		// 点击关闭按钮
		$('#toast-close-btn').click(function() {
			$('.toast').css('animation', 'fadeOut 0.5s forwards');
			setTimeout(function() {
				$('.toast-container').remove();
			}, 500);
		});
	</script>
	<% } %>
</body>
</html>