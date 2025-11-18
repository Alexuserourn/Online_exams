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

		<title>试题功能列表</title>
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.css">
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/theme.css">
		<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
		<style>
			.long-text {
				max-width: 200px;
				white-space: nowrap;
				overflow: hidden;
				text-overflow: ellipsis;
			}
			
			.type-badge {
				display: inline-block;
				padding: 2px 6px;
				border-radius: 3px;
				color: white;
				font-size: 12px;
				margin-right: 5px;
			}
			
			.type-1 { background-color: #428bca; } /* 单选题 */
			.type-2 { background-color: #5cb85c; } /* 多选题 */
			.type-3 { background-color: #f0ad4e; } /* 判断题 */
			.type-4 { background-color: #5bc0de; } /* 填空题 */
			.type-5 { background-color: #d9534f; } /* 简答题 */
		</style>
	</head>

	<body class="content1">
		<script>
    		$('#a_leader_txt', parent.document).html('试题详情');
		</script>
		<div class="container-fluid">
			<div class="row-fluid">
				<div class="well">
					<table class="table table-striped table-bordered">
						<thead>
							<tr>
								<th>题目ID</th>
								<th>题型</th>
								<th>题干</th>
								<th>选项内容</th>
								<th>标准答案</th>
								<th>分值</th>
								<th>解析</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${subjects}" var="item">
								<tr>
									<td>${item.sid}</td>
									<td>
										<c:choose>
											<c:when test="${item.stype == 1 || item.stype == null}">
												<span class="type-badge type-1">单选题</span>
											</c:when>
											<c:when test="${item.stype == 2}">
												<span class="type-badge type-2">多选题</span>
											</c:when>
											<c:when test="${item.stype == 3}">
												<span class="type-badge type-3">判断题</span>
											</c:when>
											<c:when test="${item.stype == 4}">
												<span class="type-badge type-4">填空题</span>
											</c:when>
											<c:when test="${item.stype == 5}">
												<span class="type-badge type-5">简答题</span>
											</c:when>
										</c:choose>
									</td>
									<td class="long-text" title="${item.scontent}">
										${item.scontent}
									</td>
									<td>
										<c:choose>
											<c:when test="${item.stype == 1 || item.stype == null || item.stype == 2}">
												<!-- 单选题和多选题显示所有选项 -->
												<div>A: ${item.sa}</div>
												<div>B: ${item.sb}</div>
												<div>C: ${item.sc}</div>
												<div>D: ${item.sd}</div>
												<c:if test="${not empty item.se}">
													<div>E: ${item.se}</div>
												</c:if>
												<c:if test="${not empty item.sf}">
													<div>F: ${item.sf}</div>
												</c:if>
											</c:when>
											<c:when test="${item.stype == 3}">
												<!-- 判断题只显示两个选项 -->
												<div>A: ${item.sa}</div>
												<div>B: ${item.sb}</div>
											</c:when>
											<c:otherwise>
												<!-- 填空题和简答题不显示选项 -->
												<span class="muted">无选项</span>
											</c:otherwise>
										</c:choose>
									</td>
									<td>
										<c:choose>
											<c:when test="${item.stype == 4 || item.stype == 5}">
												<!-- 填空题和简答题显示标准答案 -->
												<div class="long-text" title="${item.standardAnswer}">
													${item.standardAnswer}
												</div>
											</c:when>
											<c:otherwise>
												<!-- 其他题型显示选项答案 -->
												${item.skey}
											</c:otherwise>
										</c:choose>
									</td>
									<td>${item.score != null ? item.score : 2}</td>
									<td>
										<c:if test="${not empty item.analysis}">
											<div class="long-text" title="${item.analysis}">
												${item.analysis}
											</div>
										</c:if>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</body>
</html>
