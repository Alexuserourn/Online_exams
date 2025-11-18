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
		<script type="text/javascript">
            function confirmDelete(sid, scontent) {
                var shortContent = scontent.length > 20 ? scontent.substring(0, 20) + "..." : scontent;
                var res = confirm("确定要删除题目 \"" + shortContent + "\" 吗？");
                if (res) {
                    window.location.href = '<%=basePath%>sys/subject?cmd=delete&id=' + sid;
                }
            }
		</script>
	</head>

	<body class="content1">

		<div class="container-fluid">
			<div class="row-fluid">
				<form class="form-inline" method="post"
					action="<%=basePath%>sys/subject?cmd=list">
					<input class="input-xlarge" placeholder="请输入题干..." name="scontent"
						type="text" value="${param.scontent}">
					<input class="btn icon-search" type="submit" value="查询" />
					<a class="btn btn-primary"
						href="<%=basePath%>sys/subject/add.jsp"> <i
						class="icon-plus"></i> 新增试题</a>
				</form>

				<div class="well">
					<table class="table">
						<thead>
							<tr>
								<th>
									题目ID
								</th>
								<th>
									题型
								</th>
								<th>
									题干
								</th>
								<th>
									A选项内容
								</th>
								<th>
									B选项内容
								</th>
								<th>
									C选项内容
								</th>
								<th>
									D选项内容
								</th>
								<th>
									标准答案
								</th>
								<th>
									题目状态
								</th>
								<th style="width: 120px;">
									操作
								</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${pager.list}" var="item">
								<tr>
									<td>
										${item.sid}
									</td>
									<td>
										<c:choose>
											<c:when test="${item.stype == 1 || item.stype == null}">单选题</c:when>
											<c:when test="${item.stype == 2}">多选题</c:when>
											<c:when test="${item.stype == 3}">判断题</c:when>
											<c:when test="${item.stype == 4}">填空题</c:when>
											<c:when test="${item.stype == 5}">简答题</c:when>
											<c:otherwise>未知</c:otherwise>
										</c:choose>
									</td>
									<td>
										${item.scontent}
									</td>
									<td>
										${item.sa}
									</td>
									<td>
										${item.sb}
									</td>
									<td>
										${item.sc}
									</td>
									<td>
										${item.sd}
									</td>
									<td>
										<c:choose>
											<c:when test="${item.stype == 4 || item.stype == 5}">
												${item.standardAnswer}
											</c:when>
											<c:otherwise>
												${item.skey}
											</c:otherwise>
										</c:choose>
									</td>
									<td>
										<c:choose>
											<c:when test="${item.sstate==\"1\"}">
												可用		
											</c:when>
											<c:otherwise>不可用</c:otherwise>
										</c:choose>
									</td>
									<td>
										<a href="<%=basePath%>sys/subject?cmd=toedit&id=${item.sid}">编辑</a>
										<a href="javascript:void(0)" onclick="confirmDelete('${item.sid}', '${item.scontent}')" style="margin-left: 10px; color: #d9534f;">删除</a>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
					<div class="pagination pagination-right">
						<ul>
							<li>
								<a>共计：${pager.pagectrl.pagecount}页/${pager.pagectrl.rscount}条记录</a>
							</li>
							
							<li>
								<c:if test="${pager.pagectrl.currentindex==1}" var="fp">
									<a style="disabled:true">上一页</a>
								</c:if>
								<c:if test="${!fp}">
									<a href="<%=basePath%>sys/subject?cmd=list&index=${pager.pagectrl.currentindex-1}">上一页</a>
								</c:if>
							</li>						
							
							<c:forEach begin="${pager.pagectrl.minpage}" step="1" end="${pager.pagectrl.maxpage}" var="index">
							<li>
								<c:if test="${pager.pagectrl.currentindex==index}" var="t">
									<a style="color:red;background-color:#bbb">${index}</a>
								</c:if>
								<c:if test="${!t}">
								<a href="<%=basePath%>sys/subject?cmd=list&index=${index}">${index}</a>
								</c:if>
							</li>
							</c:forEach>
							
							<li>
								<c:if test="${pager.pagectrl.currentindex==pager.pagectrl.pagecount}" var="fp">
									<a style="disabled:true">下一页</a>
								</c:if>
								<c:if test="${!fp}">
									<a href="<%=basePath%>sys/subject?cmd=list&index=${pager.pagectrl.currentindex+1}">下一页</a>
								</c:if>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
