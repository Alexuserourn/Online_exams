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
    <title>自由练习</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/paper.css">
    <script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
    <script src="<%=basePath%>js/bootstrap.js"></script>
    <script src="<%=basePath%>layer/layer.js"></script>
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
        
        /* 答题区样式 */
        .answer-area {
            margin-top: 10px;
        }
        
        .answer-form {
            margin-top: 10px;
        }
        
        .answer-input {
            width: 100%;
            margin-top: 5px;
        }
        
        .answer-btn {
            margin-top: 10px;
        }
        
        .answer-result {
            margin-top: 10px;
            padding: 10px;
            border-radius: 4px;
            display: none;
        }
        
        .answer-correct {
            background-color: #dff0d8;
            color: #3c763d;
        }
        
        .answer-wrong {
            background-color: #f2dede;
            color: #a94442;
        }
        
        .answer-explanation {
            margin-top: 10px;
            padding: 10px;
            background-color: #f5f5f5;
            border-left: 4px solid #5bc0de;
            display: none;
        }
        
        /* 选项样式 */
        .option-list {
            list-style-type: none;
            padding-left: 0;
        }
        
        .option-list li {
            margin-bottom: 5px;
        }
        
        .option-list label {
            display: block;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            border: 1px solid transparent;
            transition: all 0.2s ease;
        }
        
        .option-list label:hover {
            background-color: #f5f5f5;
            border-color: #ddd;
        }
        
        .option-list input[type="radio"],
        .option-list input[type="checkbox"] {
            margin-right: 10px;
        }
        
        /* 增强选中效果 */
        .option-list input[type="radio"]:checked + span,
        .option-list input[type="checkbox"]:checked + span {
            font-weight: bold;
        }
        
        .option-list input[type="radio"]:checked ~ label,
        .option-list input[type="checkbox"]:checked ~ label {
            background-color: #e8f4ff;
            border-color: #b8d8ff;
            box-shadow: 0 0 5px rgba(0,123,255,0.25);
        }
        
        /* 正确和错误选项的样式 */
        .correct {
            background-color: #dff0d8 !important;
            border: 1px solid #5cb85c !important;
            box-shadow: 0 0 5px rgba(92,184,92,0.5) !important;
        }
        
        .error {
            background-color: #f2dede !important;
            border: 1px solid #d9534f !important;
            box-shadow: 0 0 5px rgba(217,83,79,0.5) !important;
        }
        
        /* 确保选项内容垂直居中对齐 */
        .option-list label {
            display: flex;
            align-items: center;
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
                    <li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
                    <li class="active"><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
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
                <h3 class="panel-title">自由练习</h3>
            </div>
            <div class="panel-body">
                <div class="filter-section">
                    <!-- 题型筛选 -->
                    <form class="form-inline" method="get" action="<%=basePath%>user/studentPaper">
                        <input type="hidden" name="cmd" value="freePractice">
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
                            <a data-toggle="collapse" data-parent="#accordion" href="#practiceList">练习题列表</a>
                        </h4>
                    </div>
                    <div id="practiceList" class="panel-collapse collapse in">
                        <div class="panel-body">
                            <c:choose>
                                <c:when test="${empty pager.list}">
                                    <div class="no-results">
                                        <h4>暂无题目</h4>
                                        <p>当前没有符合条件的题目，请尝试更改筛选条件。</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <ol>
                                        <c:forEach items="${pager.list}" var="item">
                                            <div class="subject" data-sid="${item.sid}" data-key="${item.skey}" data-type="${item.stype}" data-score="${item.score}">
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
                                                <div class="answer-area">
                                                    <c:choose>
                                                        <c:when test="${item.stype == 1 || item.stype == null}">
                                                            <!-- 单选题 -->
                                                            <ul class="option-list single-choice" data-sid="${item.sid}">
                                                                <li><label><input type="radio" name="option-${item.sid}" value="A"><span>${item.sa}</span></label></li>
                                                                <li><label><input type="radio" name="option-${item.sid}" value="B"><span>${item.sb}</span></label></li>
                                                                <li><label><input type="radio" name="option-${item.sid}" value="C"><span>${item.sc}</span></label></li>
                                                                <li><label><input type="radio" name="option-${item.sid}" value="D"><span>${item.sd}</span></label></li>
                                                            </ul>
                                                        </c:when>
                                                        <c:when test="${item.stype == 2}">
                                                            <!-- 多选题 -->
                                                            <ul class="option-list multi-choice" data-sid="${item.sid}">
                                                                <li><label><input type="checkbox" name="option-${item.sid}" value="A"><span>${item.sa}</span></label></li>
                                                                <li><label><input type="checkbox" name="option-${item.sid}" value="B"><span>${item.sb}</span></label></li>
                                                                <li><label><input type="checkbox" name="option-${item.sid}" value="C"><span>${item.sc}</span></label></li>
                                                                <li><label><input type="checkbox" name="option-${item.sid}" value="D"><span>${item.sd}</span></label></li>
                                                                <c:if test="${not empty item.se}">
                                                                    <li><label><input type="checkbox" name="option-${item.sid}" value="E"><span>${item.se}</span></label></li>
                                                                </c:if>
                                                                <c:if test="${not empty item.sf}">
                                                                    <li><label><input type="checkbox" name="option-${item.sid}" value="F"><span>${item.sf}</span></label></li>
                                                                </c:if>
                                                            </ul>
                                                        </c:when>
                                                        <c:when test="${item.stype == 3}">
                                                            <!-- 判断题 -->
                                                            <ul class="option-list judgment" data-sid="${item.sid}">
                                                                <li><label><input type="radio" name="option-${item.sid}" value="A"><span>${item.sa}</span></label></li>
                                                                <li><label><input type="radio" name="option-${item.sid}" value="B"><span>${item.sb}</span></label></li>
                                                            </ul>
                                                        </c:when>
                                                        <c:when test="${item.stype == 4}">
                                                            <!-- 填空题 -->
                                                            <div class="form-group fill-blank" data-sid="${item.sid}">
                                                                <input type="text" class="form-control answer-input" placeholder="请输入答案">
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${item.stype == 5}">
                                                            <!-- 简答题 -->
                                                            <div class="form-group essay" data-sid="${item.sid}">
                                                                <textarea class="form-control answer-input" rows="3" placeholder="请输入答案"></textarea>
                                                            </div>
                                                        </c:when>
                                                    </c:choose>
                                                    
                                                    <button class="btn btn-primary btn-sm answer-btn" data-sid="${item.sid}" data-type="${item.stype}" data-key="${item.skey}" data-standard="${item.standardAnswer}">提交答案</button>
                                                    
                                                    <div class="answer-result" id="result-${item.sid}"></div>
                                                    
                                                    <div class="answer-explanation" id="explanation-${item.sid}">
                                                        <strong>标准答案：</strong>
                                                        <c:choose>
                                                            <c:when test="${item.stype == 4 || item.stype == 5}">
                                                                ${item.standardAnswer}
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${item.skey}
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${not empty item.analysis}">
                                                            <div class="analysis">
                                                                <strong>解析：</strong>${item.analysis}
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </div>
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
                                            <a href="<%=basePath%>user/studentPaper?cmd=freePractice&index=${pager.pagectrl.currentindex-1}&typeFilter=${selectedType}&keyword=${keyword}">上一页</a>
                                        </c:if>
                                    </li>
                                    <c:forEach begin="${pager.pagectrl.minpage}" step="1" end="${pager.pagectrl.maxpage}" var="index">
                                        <li>
                                            <c:if test="${pager.pagectrl.currentindex==index}" var="t">
                                                <a style="color:red;background-color:#bbb">${index}</a>
                                            </c:if>
                                            <c:if test="${!t}">
                                                <a href="<%=basePath%>user/studentPaper?cmd=freePractice&index=${index}&typeFilter=${selectedType}&keyword=${keyword}">${index}</a>
                                            </c:if>
                                        </li>
                                    </c:forEach>
                                    <li>
                                        <c:if test="${pager.pagectrl.currentindex==pager.pagectrl.pagecount}" var="fp">
                                            <a style="disabled:true">下一页</a>
                                        </c:if>
                                        <c:if test="${!fp}">
                                            <a href="<%=basePath%>user/studentPaper?cmd=freePractice&index=${pager.pagectrl.currentindex+1}&typeFilter=${selectedType}&keyword=${keyword}">下一页</a>
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
        
        // 答题按钮点击事件
        $('.answer-btn').click(function() {
            var btn = $(this);
            var sid = btn.data('sid');
            var type = btn.data('type');
            var key = btn.data('key');
            var standardAnswer = btn.data('standard');
            var resultDiv = $('#result-' + sid);
            var explanationDiv = $('#explanation-' + sid);
            var userAnswer = '';
            var isCorrect = false;
            
            // 根据题型获取用户答案
            if (type == 1 || type == 3) {
                // 单选题或判断题
                userAnswer = $('input[name="option-' + sid + '"]:checked').val() || '';
                isCorrect = (userAnswer === key);
            } else if (type == 2) {
                // 多选题
                var selectedOptions = [];
                $('input[name="option-' + sid + '"]:checked').each(function() {
                    selectedOptions.push($(this).val());
                });
                // 按字母顺序排序
                selectedOptions.sort();
                userAnswer = selectedOptions.join('');
                isCorrect = (userAnswer === key);
            } else if (type == 4) {
                // 填空题
                userAnswer = $('.fill-blank[data-sid="' + sid + '"] .answer-input').val().trim();
                isCorrect = (userAnswer === standardAnswer);
            } else if (type == 5) {
                // 简答题
                userAnswer = $('.essay[data-sid="' + sid + '"] .answer-input').val().trim();
                // 简答题不进行自动判断，只显示参考答案
                explanationDiv.show();
                resultDiv.removeClass('answer-correct answer-wrong').hide();
                return;
            }
            
            // 显示答案结果
            if (isCorrect) {
                resultDiv.html('<strong>正确！</strong>').removeClass('answer-wrong').addClass('answer-correct').show();
            } else {
                resultDiv.html('<strong>错误！</strong>').removeClass('answer-correct').addClass('answer-wrong').show();
            }
            
            // 显示解析
            explanationDiv.show();
            
            // 高亮显示正确答案和用户选择
            if (type == 1 || type == 2 || type == 3) {
                // 选择题类型
                var optionList = $('ul[data-sid="' + sid + '"]');
                
                // 清除之前的样式
                optionList.find('li').removeClass('correct error');
                
                // 标记正确答案
                if (type == 1 || type == 3) {
                    // 单选题或判断题
                    optionList.find('input[value="' + key + '"]').parent().parent().addClass('correct');
                    if (!isCorrect && userAnswer) {
                        optionList.find('input[value="' + userAnswer + '"]').parent().parent().addClass('error');
                    }
                } else if (type == 2) {
                    // 多选题
                    var correctOptions = key.split('');
                    var userOptions = userAnswer.split('');
                    
                    // 标记正确选项
                    $.each(correctOptions, function(index, option) {
                        optionList.find('input[value="' + option + '"]').parent().parent().addClass('correct');
                    });
                    
                    // 标记错误选项
                    $.each(userOptions, function(index, option) {
                        if (correctOptions.indexOf(option) === -1) {
                            optionList.find('input[value="' + option + '"]').parent().parent().addClass('error');
                        }
                    });
                }
            }
        });
    });
    </script>
</body>

</html> 