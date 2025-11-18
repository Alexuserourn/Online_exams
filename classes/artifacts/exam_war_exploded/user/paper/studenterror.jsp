<%@ page language="java" import="java.util.*,cn.itbaizhan.tyut.exam.common.*,java.sql.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
			
    // 获取试卷ID和用户ID
    String spid = request.getParameter("spid");
    Integer userid = (Integer) session.getAttribute("userid");
    
    // 从paper_user表获取分数信息
    if (spid != null && userid != null) {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 获取试卷名称
            String pnameQuery = "SELECT pname FROM studentpaper WHERE spid = ? LIMIT 1";
            List<Map<String, Object>> pnameResults = dbHelper.executeRawQuery(pnameQuery, spid);
            String pname = null;
            if (pnameResults != null && !pnameResults.isEmpty() && pnameResults.get(0).get("pname") != null) {
                pname = pnameResults.get(0).get("pname").toString();
                request.setAttribute("pname", pname);
                
                // 直接使用spid查询分数记录，而不是pname
                String scoreQuery = "SELECT score, percent_score, remaining_questions FROM paper_user WHERE spid = ? AND userid = ?";
                List<Map<String, Object>> scoreResults = dbHelper.executeRawQuery(scoreQuery, spid, userid);
                
                if (scoreResults != null && !scoreResults.isEmpty()) {
                    Map<String, Object> scoreData = scoreResults.get(0);
                    Integer score = scoreData.get("score") != null ? ((Number)scoreData.get("score")).intValue() : 0;
                    Double percentScore = scoreData.get("percent_score") != null ? ((Number)scoreData.get("percent_score")).doubleValue() : 0.0;
                    Integer pendingQuestions = scoreData.get("remaining_questions") != null ? ((Number)scoreData.get("remaining_questions")).intValue() : 0;
                    
                    // 设置请求属性
                    request.setAttribute("paper_score", score);
                    request.setAttribute("paper_percent", percentScore);
                    request.setAttribute("paper_pending", pendingQuestions);
                    
                    // 获取试卷总分
                    String totalScoreQuery = "SELECT SUM(score) as totalPossible FROM studentpaper WHERE spid = ? AND USERID = ?";
                    List<Map<String, Object>> totalResults = dbHelper.executeRawQuery(totalScoreQuery, spid, userid);
                    if (totalResults != null && !totalResults.isEmpty() && totalResults.get(0).get("totalPossible") != null) {
                        Integer totalPossible = ((Number)totalResults.get(0).get("totalPossible")).intValue();
                        request.setAttribute("paper_total", totalPossible);
                    }
                } else {
                    // 如果没有找到分数记录，则更新一次
                    cn.itbaizhan.tyut.exam.common.ScoreFixer.updatePaperScore(spid, userid);
                    
                    // 再次尝试获取分数
                    scoreResults = dbHelper.executeRawQuery(scoreQuery, spid, userid);
                    
                    if (scoreResults != null && !scoreResults.isEmpty()) {
                        Map<String, Object> scoreData = scoreResults.get(0);
                        Integer score = scoreData.get("score") != null ? ((Number)scoreData.get("score")).intValue() : 0;
                        Double percentScore = scoreData.get("percent_score") != null ? ((Number)scoreData.get("percent_score")).doubleValue() : 0.0;
                        Integer pendingQuestions = scoreData.get("remaining_questions") != null ? ((Number)scoreData.get("remaining_questions")).intValue() : 0;
                        
                        // 设置请求属性
                        request.setAttribute("paper_score", score);
                        request.setAttribute("paper_percent", percentScore);
                        request.setAttribute("paper_pending", pendingQuestions);
                        
                        // 获取试卷总分
                        String totalScoreQuery = "SELECT SUM(score) as totalPossible FROM studentpaper WHERE spid = ? AND USERID = ?";
                        List<Map<String, Object>> totalResults = dbHelper.executeRawQuery(totalScoreQuery, spid, userid);
                        if (totalResults != null && !totalResults.isEmpty() && totalResults.get(0).get("totalPossible") != null) {
                            Integer totalPossible = ((Number)totalResults.get(0).get("totalPossible")).intValue();
                            request.setAttribute("paper_total", totalPossible);
                        }
                    }
                }
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
    <title>在线答题</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/paper.css">
    <script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
    <script src="<%=basePath%>js/bootstrap.js"></script>
    <style>
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
        
        .analysis {
            margin-top: 10px;
            padding: 8px;
            background-color: #f8f8f8;
            border-left: 4px solid #5cb85c;
        }
        
        .standard-answer {
            font-weight: bold;
            color: #5cb85c;
        }
        
        .your-answer {
            font-weight: bold;
            color: #d9534f;
        }
        
        /* 增加题目间距 */
        .subject {
            margin-bottom: 30px;
            padding: 15px;
            border: 1px solid #eee;
            border-radius: 5px;
            background-color: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        /* 增加选项间距 */
        .subject ol li {
            margin-bottom: 8px;
        }
        
        /* 题干样式 */
        .subject > li {
            font-weight: bold;
            margin-bottom: 15px;
            font-size: 16px;
        }
        
        /* 标准答案和用户答案样式 */
        .standard-answer, .your-answer {
            margin: 10px 0;
            padding: 5px 0;
        }
        
        /* 分数信息样式 */
        .score-info {
            margin-bottom: 20px;
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
                <li class="active"><a href="<%=basePath%>user/studentPaper?cmd=stupaper">查看错题</a></li>
                <li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
                <li><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
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
                <h3 class="panel-title">
                    <c:out value="${pname}"></c:out>
                </h3>
            </div>
            <div class="panel-body">
                <!-- 得分信息显示区域 -->
                <c:if test="${paper_score != null && paper_total != null}">
                    <div class="score-info panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">得分情况</h3>
                        </div>
                        <div class="panel-body">
                            <c:choose>
                                <c:when test="${paper_pending > 0}">
                                    <!-- 有未评分题目 -->
                                    <div class="alert alert-warning">
                                        <strong>当前得分：${paper_score} 分 (满分 ${paper_total} 分)</strong><br>
                                        <span>注意：您有 ${paper_pending} 道简答题尚未评分，最终成绩可能会变化。</span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- 所有题目已评分 -->
                                    <div class="alert alert-success">
                                        <strong>最终得分：${paper_score} 分 (满分 ${paper_total} 分)</strong><br>
                                        <span>正确率：<fmt:formatNumber value="${paper_percent}" pattern="#.##" />%</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
                
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#errorList">错题库</a>
                        </h4>
                    </div>
                    <div id="errorList" class="panel-collapse collapse in">
                        <div class="panel-body">
                            <ol>
                                <c:forEach items="${pager.list}" var="item">
                                    <div class="subject" data-sid="${item.sid}" data-key="${item.skey}" data-skey="${item.studentkey}" data-type="${item.stype}">
                                        <li>
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
                                            ${item.scontent}
                                            <span class="badge">${item.score}分</span>
                                        </li>
                                        
                                        <!-- 根据题型显示不同的内容 -->
                                        <c:choose>
                                            <c:when test="${item.stype == 1 || item.stype == null}">
                                                <!-- 单选题 -->
                                                <ol>
                                                    <li><label data-value="A">${item.sa}</label></li>
                                                    <li><label data-value="B">${item.sb}</label></li>
                                                    <li><label data-value="C">${item.sc}</label></li>
                                                    <li><label data-value="D">${item.sd}</label></li>
                                                </ol>
                                            </c:when>
                                            <c:when test="${item.stype == 2}">
                                                <!-- 多选题 -->
                                                <ol>
                                                    <li><label data-value="A">${item.sa}</label></li>
                                                    <li><label data-value="B">${item.sb}</label></li>
                                                    <li><label data-value="C">${item.sc}</label></li>
                                                    <li><label data-value="D">${item.sd}</label></li>
                                                    <c:if test="${not empty item.se}">
                                                        <li><label data-value="E">${item.se}</label></li>
                                                    </c:if>
                                                    <c:if test="${not empty item.sf}">
                                                        <li><label data-value="F">${item.sf}</label></li>
                                                    </c:if>
                                                </ol>
                                            </c:when>
                                            <c:when test="${item.stype == 3}">
                                                <!-- 判断题 -->
                                                <ol>
                                                    <li><label data-value="A">${item.sa}</label></li>
                                                    <li><label data-value="B">${item.sb}</label></li>
                                                </ol>
                                            </c:when>
                                            <c:when test="${item.stype == 4}">
                                                <!-- 填空题 -->
                                                <div class="standard-answer">标准答案：${item.standardAnswer}</div>
                                                <div class="your-answer">您的答案：${item.studentkey}</div>
                                            </c:when>
                                            <c:when test="${item.stype == 5}">
                                                <!-- 简答题 -->
                                                <div class="standard-answer">标准答案：${item.standardAnswer}</div>
                                                <div class="your-answer">您的答案：${item.studentkey}</div>
                                            </c:when>
                                        </c:choose>
                                        
                                        <!-- 显示解析 -->
                                        <c:if test="${not empty item.analysis}">
                                            <div class="analysis">
                                                <strong>解析：</strong>${item.analysis}
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </ol>
                            <div>
                                <ul class="pagination pagination-right">
                                    <li>
                                        <a>共计：${pager.pagectrl.pagecount}页/${pager.pagectrl.rscount}条记录</a>
                                    </li>
                                    <li>
                                        <c:if test="${pager.pagectrl.currentindex==1}" var="fp">
                                            <a style="disabled:true">上一页</a>
                                        </c:if>
                                        <c:if test="${!fp}">
                                            <a href="<%=basePath%>user/studentPaper?cmd=list&spid=${spid}&index=${pager.pagectrl.currentindex-1}">上一页</a>
                                        </c:if>
                                    </li>
                                    <c:forEach begin="${pager.pagectrl.minpage}" step="1" end="${pager.pagectrl.maxpage}" var="index">
                                        <li>
                                            <c:if test="${pager.pagectrl.currentindex==index}" var="t">
                                                <a style="color:red;background-color:#bbb">${index}</a>
                                            </c:if>
                                            <c:if test="${!t}">
                                                <a href="<%=basePath%>user/studentPaper?cmd=list&spid=${spid}&index=${index}">${index}</a>
                                            </c:if>
                                        </li>
                                    </c:forEach>
                                    <li>
                                        <c:if test="${pager.pagectrl.currentindex==pager.pagectrl.pagecount}" var="fp">
                                            <a style="disabled:true">下一页</a>
                                        </c:if>
                                        <c:if test="${!fp}">
                                            <a href="<%=basePath%>user/studentPaper?cmd=list&spid=${spid}&index=${pager.pagectrl.currentindex+1}">下一页</a>
                                        </c:if>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </main>
    <script>
    // 获取basePath 
    var basePath = '<%=basePath%>'
    $(function(ev) {
        var len = $('.subject').length;
        $('.subject').each(function(index){
            var i = index
            var self = $(this)
            var type = self.data('type')
            
            // 只处理选择题类型的高亮
            if(type == 1 || type == 2 || type == 3 || type == null) {
                self.find('label').each(function(){
                    var label = $(this)
                    if(self.data('key')==label.data('value')){
                        label.parent().addClass('correct')
                    }
                    if(self.data('skey')==label.data('value')){
                        label.parent().addClass('error')
                    }
                })
            }
        })
    })
    </script>
</body>

</html>