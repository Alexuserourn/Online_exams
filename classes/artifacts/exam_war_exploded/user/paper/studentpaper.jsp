<%@ page language="java" import="java.util.*,cn.itbaizhan.tyut.exam.common.*,java.sql.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
			
    // 获取当前用户ID
    Integer userid = (Integer) session.getAttribute("userid");
    
    // 获取分数信息但不更新所有分数
    if (userid != null) {
        try {
            // 查询所有试卷的paper_user表得分记录，使用spid作为唯一标识
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            String scoreQuery = "SELECT pu.spid, pu.score, pu.percent_score " +
                              "FROM paper_user pu " +
                              "WHERE pu.userid = ?";
            
            List<Map<String, Object>> scoreResults = dbHelper.executeRawQuery(scoreQuery, userid);
            
            // 将分数信息保存到请求属性中，用于在页面上直接显示
            if (scoreResults != null && !scoreResults.isEmpty()) {
                Map<String, Object> scoreMap = new HashMap<>();
                Map<String, Object> percentMap = new HashMap<>();
                
                for (Map<String, Object> score : scoreResults) {
                    String spid = (String) score.get("spid");
                    Integer scoreValue = score.get("score") != null ? ((Number) score.get("score")).intValue() : 0;
                    Double percentValue = score.get("percent_score") != null ? ((Number) score.get("percent_score")).doubleValue() : 0.0;
                    
                    scoreMap.put(spid, scoreValue);
                    percentMap.put(spid, percentValue);
                }
                
                request.setAttribute("paperScores", scoreMap);
                request.setAttribute("paperPercents", percentMap);
                request.setAttribute("hasScores", true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE HTML>
<html>

<head>
    <base href="<%=basePath%>">
    <title>我的试卷 - 教学辅助系统</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/paper.css">
    <script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
    <script src="<%=basePath%>js/bootstrap.js"></script>
    <style>
        /* 整体页面样式 */
        body {
            background-color: #f5f5f5;
        }
        
        .container {
            max-width: 1100px;
        }
        
        /* 表格样式 */
        .table thead th {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }
        
        .table-hover tbody tr:hover {
            background-color: #f2f9ff;
        }
        
        /* 数据显示样式 */
        .error-count {
            color: #d9534f;
            font-weight: bold;
        }
        
        .score {
            color: #5cb85c;
            font-weight: bold;
            font-size: 16px;
        }
        
        .percent-score {
            color: #337ab7;
            font-size: 0.9em;
            margin-left: 5px;
        }
        
        .time {
            color: #777;
            font-size: 0.9em;
        }
        
        .paper-name {
            font-weight: 600;
            color: #337ab7;
        }
        
        /* 按钮样式 */
        .btn-view {
            white-space: nowrap;
        }
        
        /* 响应式调整 */
        @media (max-width: 768px) {
            .container {
                padding: 0 10px;
            }
            
            .table {
                font-size: 14px;
            }
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
                <li class="active"><a href="<%=basePath%>user/studentPaper?cmd=stupaper">我的试卷</a></li>
                <li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
                <li><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
                <li><a href="<%=basePath%>statistics?cmd=studentStats">成绩统计</a></li>
            </ul>
            <ul class="nav navbar-nav navbar-right">
                <c:choose>
					<c:when test="${userid!=null}">
						<li><a><c:out  value="${sessionScope.user.usertruename}"/></a></li>
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
				<h3 class="panel-title">我的试卷列表</h3>
			</div>
			<div class="panel-body">
				<!-- 错误消息显示 -->
				<c:if test="${not empty error}">
					<div class="alert alert-danger">
						${error}
					</div>
				</c:if>
				
				<div class="table-responsive">
					<table class="table table-striped table-hover">
						<thead>
							<tr>
								<th width="40%">试卷名称</th>
								<th width="20%">错题数目</th>
								<th width="20%">得分</th>
								<th width="20%">操作</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${papers}" var="item">
								<tr>
									<td class="paper-name">
										${item.pname}
									</td>
									<td class="error-count">
										${item.errorcount}
									</td>
									<td class="score">
										<c:choose>
											<c:when test="${hasScores == true && paperScores[item.spid] != null}">
												<strong>${paperScores[item.spid]}</strong> 分
												<span class="percent-score">
													(<fmt:formatNumber value="${paperPercents[item.spid]}" pattern="#.##" />%)
												</span>
											</c:when>
											<c:when test="${useScoreFromDb == true}">
												<strong>${item.rightcount}</strong> 分
											</c:when>
											<c:otherwise>
												<strong>${item.rightcount}</strong> 分
											</c:otherwise>
										</c:choose>
									</td>
									<td class="btn-view">
										<a href="<%=basePath%>user/studentPaper?cmd=list&spid=${item.spid}" class="btn btn-sm btn-info">
                                            查看详情
                                        </a>
									</td>
								</tr>
							</c:forEach>
							
							<c:if test="${empty papers}">
								<tr>
									<td colspan="5" class="text-center">
										<p class="text-muted" style="padding: 20px 0;">暂无试卷记录</p>
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>
			</div>
		</div>
    </main>
    <script>
    // 获取basePath 
    var basePath = '<%=basePath%>'
    </script>
</body>

</html>