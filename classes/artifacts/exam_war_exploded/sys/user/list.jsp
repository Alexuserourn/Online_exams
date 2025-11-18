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

		<title>用户管理</title>
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.css">
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/theme.css">
		<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
		<script type="text/javascript">
            function confirmDelete(userid, username) {
                var res = confirm("确定要删除用户 \"" + username + "\" 吗？");
                if (res) {
                    window.location.href = '<%=basePath%>sys/user?cmd=delete&id=' + userid;
                }
            }
		</script>
	</head>

	<body class="content1">
		<div class="container-fluid">
			<div class="row-fluid">
				<form class="form-inline" method="post"
					action="<%=basePath%>sys/user?cmd=list">
					<div class="search-box" style="margin-bottom: 10px;">
						<input class="input-medium" placeholder="用户名..." name="sname"
							type="text" value="${param.sname}">
						<input class="input-medium" placeholder="学号..." name="schoolid"
							type="text" value="${param.schoolid}">
						<input class="input-medium" placeholder="班级..." name="classname"
							type="text" value="${param.classname}">
						<input class="input-medium" placeholder="年级..." name="grade"
							type="text" value="${param.grade}">
						<input class="btn icon-search" type="submit" value="查询" />
						<a class="btn btn-primary"
							href="<%=basePath%>sys/user/add.jsp"> <i
							class="icon-plus"></i> 新增 </a>
					</div>
				</form>

				<div class="well">
					<table class="table">
						<thead>
							<tr>
								<th>
									角色ID
								</th>
								<th>
									用户名
								</th>
								<!--<th>
									用户密码
								</th>
								--><th>
									用户真实名字
								</th>
								<th>
									用户状态
								</th>
								<th>
									学号
								</th>
								<th>
									班级
								</th>
								<th>
									年级
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
										${item.roleid}
									</td>
									<td>
										${item.username}
									</td>
									<!--<td>
										${item.userpwd}
									</td>
									--><td>
										${item.usertruename}
									</td>
									<td>
										<c:choose>
											<c:when test="${item.userstate==\"1\"}">
												正常		
											</c:when>
											<c:otherwise>锁定</c:otherwise>
										</c:choose>
									</td>
									<td>
										${item.schoolid}
									</td>
									<td>
										${item.classname}
									</td>
									<td>
										${item.grade}
									</td>
									<td>
										<a href="<%=basePath%>sys/user?cmd=toedit&id=${item.userid}">编辑</a>
										<a href="javascript:void(0)" onclick="confirmDelete('${item.userid}', '${item.username}')" style="margin-left: 10px; color: #d9534f;">删除</a>
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
									<a href="<%=basePath%>sys/user?cmd=list&index=${pager.pagectrl.currentindex-1}&sname=${param.sname}&schoolid=${param.schoolid}&classname=${param.classname}&grade=${param.grade}">上一页</a>
								</c:if>
							</li>						
							
							<c:forEach begin="${pager.pagectrl.minpage}" step="1" end="${pager.pagectrl.maxpage}" var="index">
							<li>
								<c:if test="${pager.pagectrl.currentindex==index}" var="t">
									<a style="color:red;background-color:#bbb">${index}</a>
								</c:if>
								<c:if test="${!t}">
								<a href="<%=basePath%>sys/user?cmd=list&index=${index}&sname=${param.sname}&schoolid=${param.schoolid}&classname=${param.classname}&grade=${param.grade}">${index}</a>
								</c:if>
							</li>
							</c:forEach>
							
							<li>
								<c:if test="${pager.pagectrl.currentindex==pager.pagectrl.pagecount}" var="fp">
									<a style="disabled:true">下一页</a>
								</c:if>
								<c:if test="${!fp}">
									<a href="<%=basePath%>sys/user?cmd=list&index=${pager.pagectrl.currentindex+1}&sname=${param.sname}&schoolid=${param.schoolid}&classname=${param.classname}&grade=${param.grade}">下一页</a>
								</c:if>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
