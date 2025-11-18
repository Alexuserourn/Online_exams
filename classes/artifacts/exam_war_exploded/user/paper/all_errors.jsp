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
    <title>错题集</title>
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
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .filter-section {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        
        .search-form {
            margin-top: 15px;
        }
    </style>
</head>

<body>
    <nav class="navbar navbar-default navbar-static-top">
        <div class="container-fluid">
            <!-- 品牌和切换按钮 -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="<%=basePath%>">教学辅助系统</a>
            </div>

            <!-- 导航链接 -->
            <div class="collapse navbar-collapse" id="navbar-collapse">
                <ul class="nav navbar-nav">
                    <li><a href="<%=basePath%>user?cmd=paperlist">试卷列表</a></li>
                    <li><a href="<%=basePath%>user/studentPaper?cmd=stupaper">我的试卷</a></li>
                    <li class="active"><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
                    <li><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
                    <li><a href="<%=basePath%>statistics?cmd=studentStats">成绩统计</a></li>
                </ul>
                
                <ul class="nav navbar-nav navbar-right">
				<c:choose>
					<c:when test="${!empty user}">
						<li class="dropdown">
							<a href="#" class="dropdown-toggle" data-toggle="dropdown">${user.username}<b class="caret"></b></a>
							<ul class="dropdown-menu">
								<li><a href="<%=basePath %>user?cmd=logout">退出登录</a></li>
							</ul>
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
                <h3 class="panel-title">错题集</h3>
            </div>
            <div class="panel-body">
                <div class="filter-section">
                    <!-- 题型筛选 -->
                    <form class="form-inline" method="get" action="<%=basePath%>user/studentPaper">
                        <input type="hidden" name="cmd" value="allErrors">
                        <div class="form-group">
                            <label for="typeFilter">按题型筛选：</label>
                            <select id="typeFilter" name="typeFilter" class="form-control">
                                <option value="0" ${selectedType == 0 ? 'selected' : ''}>全部题型</option>
                                <option value="1" ${selectedType == 1 ? 'selected' : ''}>单选题</option>
                                <option value="2" ${selectedType == 2 ? 'selected' : ''}>多选题</option>
                                <option value="3" ${selectedType == 3 ? 'selected' : ''}>判断题</option>
                                <option value="4" ${selectedType == 4 ? 'selected' : ''}>填空题</option>
                                <option value="5" ${selectedType == 5 ? 'selected' : ''}>简答题</option>
                            </select>
                        </div>
                        
                        <!-- 搜索功能 -->
                        <div class="form-group search-form">
                            <label for="keyword">关键字搜索：</label>
                            <input type="text" class="form-control" id="keyword" name="keyword" 
                                placeholder="输入题干关键字" value="${keyword}">
                            <button type="submit" class="btn btn-primary">搜索</button>
                        </div>
                    </form>
                </div>
                
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#errorList">错题列表</a>
                        </h4>
                    </div>
                    <div id="errorList" class="panel-collapse collapse in">
                        <div class="panel-body">
                            <c:choose>
                                <c:when test="${empty pager.list}">
                                    <div class="no-results">
                                        <h4>暂无错题记录</h4>
                                        <p>您目前没有任何错题记录，或者所有错题对应的题目已从题库中删除。</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
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
                                </c:otherwise>
                            </c:choose>
                            
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
                                            <a href="<%=basePath%>user/studentPaper?cmd=allErrors&index=${pager.pagectrl.currentindex-1}&typeFilter=${selectedType}&keyword=${keyword}">上一页</a>
                                        </c:if>
                                    </li>
                                    <c:forEach begin="${pager.pagectrl.minpage}" step="1" end="${pager.pagectrl.maxpage}" var="index">
                                        <li>
                                            <c:if test="${pager.pagectrl.currentindex==index}" var="t">
                                                <a style="color:red;background-color:#bbb">${index}</a>
                                            </c:if>
                                            <c:if test="${!t}">
                                                <a href="<%=basePath%>user/studentPaper?cmd=allErrors&index=${index}&typeFilter=${selectedType}&keyword=${keyword}">${index}</a>
                                            </c:if>
                                        </li>
                                    </c:forEach>
                                    <li>
                                        <c:if test="${pager.pagectrl.currentindex==pager.pagectrl.pagecount}" var="fp">
                                            <a style="disabled:true">下一页</a>
                                        </c:if>
                                        <c:if test="${!fp}">
                                            <a href="<%=basePath%>user/studentPaper?cmd=allErrors&index=${pager.pagectrl.currentindex+1}&typeFilter=${selectedType}&keyword=${keyword}">下一页</a>
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
    var basePath = '<%=basePath%>';
    
    $(function() {
        // 设置每次选择题型后自动提交表单
        $('#typeFilter').change(function() {
            $(this).closest('form').submit();
        });
        
        // 高亮正确答案和错误答案
        $('.subject').each(function(index) {
            var self = $(this);
            var type = self.data('type');
            
            // 只处理选择题类型的高亮
            if(type == 1 || type == 2 || type == 3 || type == null) {
                self.find('label').each(function() {
                    var label = $(this);
                    if(self.data('key') == label.data('value')) {
                        label.parent().addClass('correct');
                    }
                    if(self.data('skey') == label.data('value')) {
                        label.parent().addClass('error');
                    }
                });
            }
        });
    });
    </script>
</body>

</html> 