<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
    <title>简答题评分</title>
    <link rel="stylesheet" href="<%=basePath%>css/pintuer.css">
    <link rel="stylesheet" href="<%=basePath%>css/admin.css">
    <script src="<%=basePath%>js/jquery.js"></script>
    <script src="<%=basePath%>js/pintuer.js"></script>
    <style>
        .essay-content {
            max-height: 200px;
            overflow-y: auto;
            background-color: #f9f9f9;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .standard-answer {
            background-color: #f0f7ff;
            padding: 10px;
            border: 1px solid #d0e3ff;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .grade-form {
            margin-top: 15px;
            padding: 15px;
            border: 1px solid #eee;
            border-radius: 4px;
        }
    </style>
</head>

<body>
    <div class="panel admin-panel">
        <div class="panel-head"><strong><span class="icon-pencil-square-o"></span> 简答题评分</strong></div>
        <div class="padding border-bottom">
            <ul class="search" style="padding-left:10px;">
                <li>
                    <select name="pname" class="input" style="width:200px; line-height:17px;" onchange="changeFilter(this.value)">
                        <option value="">选择试卷</option>
                        <c:forEach items="${papers}" var="paper">
                            <option value="${paper.pname}" ${param.pname == paper.pname ? 'selected' : ''}>${paper.pname}</option>
                        </c:forEach>
                    </select>
                </li>
                <li>
                    <select name="userid" class="input" style="width:200px; line-height:17px;" onchange="changeUserFilter(this.value)">
                        <option value="">选择学生</option>
                        <c:forEach items="${students}" var="student">
                            <option value="${student.userid}" ${param.userid == student.userid ? 'selected' : ''}>${student.usertruename}</option>
                        </c:forEach>
                    </select>
                </li>
                <li>
                    <a href="javascript:void(0)" class="button border-main icon-search" onclick="applyFilters()"> 搜索</a>
                </li>
            </ul>
        </div>
        
        <c:if test="${empty ungradedEssays}">
            <div class="padding border-bottom">
                <div class="alert alert-yellow">当前没有需要评分的简答题。</div>
            </div>
        </c:if>
        
        <c:forEach items="${ungradedEssays}" var="essay" varStatus="status">
            <div class="grade-form">
                <h3>题目 #${status.index + 1}</h3>
                <div class="form-group">
                    <div class="label"><label>学生姓名：</label></div>
                    <div class="field">
                        <strong>${essay.studentName}</strong>
                    </div>
                </div>
                <div class="form-group">
                    <div class="label"><label>试卷名称：</label></div>
                    <div class="field">
                        ${essay.pname}
                    </div>
                </div>
                <div class="form-group">
                    <div class="label"><label>题目内容：</label></div>
                    <div class="field">
                        <div class="essay-content">${essay.scontent}</div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="label"><label>标准答案：</label></div>
                    <div class="field">
                        <div class="standard-answer">${essay.standardAnswer}</div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="label"><label>学生答案：</label></div>
                    <div class="field">
                        <div class="essay-content">${essay.studentkey}</div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="label"><label>分值：</label></div>
                    <div class="field">
                        <strong>${essay.score}分</strong>
                    </div>
                </div>
                <form method="post" action="<%=basePath%>sys/paper?cmd=gradeEssay">
                    <input type="hidden" name="spid" value="${essay.spid}">
                    <input type="hidden" name="sid" value="${essay.sid}">
                    <input type="hidden" name="userid" value="${essay.userid}">
                    <div class="form-group">
                        <div class="label"><label>评分：</label></div>
                        <div class="field">
                            <input type="number" class="input" name="manualScore" min="0" max="${essay.score}" required>
                            <div class="tips">请输入0-${essay.score}之间的分数</div>
                        </div>
                    </div>
                    <!-- 保留comment字段但设为隐藏 -->
                    <input type="hidden" name="comment" value="">
                    <div class="form-group">
                        <div class="label"></div>
                        <div class="field">
                            <button class="button bg-main icon-check-square-o" type="submit"> 提交评分</button>
                        </div>
                    </div>
                </form>
            </div>
        </c:forEach>
        
        <div class="padding border-bottom">
            <div class="pages">
                <c:if test="${pager.pagectrl.pagecount > 1}">
                    <a href="?cmd=gradeEssays&index=1&pname=${param.pname}&userid=${param.userid}" class="first">首页</a>
                    <c:if test="${pager.pagectrl.currentindex > 1}">
                        <a href="?cmd=gradeEssays&index=${pager.pagectrl.currentindex - 1}&pname=${param.pname}&userid=${param.userid}" class="prev">上一页</a>
                    </c:if>
                    <c:forEach begin="${pager.pagectrl.minpage}" end="${pager.pagectrl.maxpage}" var="p">
                        <c:choose>
                            <c:when test="${p == pager.pagectrl.currentindex}">
                                <span class="current">${p}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?cmd=gradeEssays&index=${p}&pname=${param.pname}&userid=${param.userid}">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${pager.pagectrl.currentindex < pager.pagectrl.pagecount}">
                        <a href="?cmd=gradeEssays&index=${pager.pagectrl.currentindex + 1}&pname=${param.pname}&userid=${param.userid}" class="next">下一页</a>
                    </c:if>
                    <a href="?cmd=gradeEssays&index=${pager.pagectrl.pagecount}&pname=${param.pname}&userid=${param.userid}" class="last">尾页</a>
                </c:if>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function changeFilter(value) {
            // 保存选择的试卷名称
            if (value) {
                localStorage.setItem('selectedPaper', value);
            } else {
                localStorage.removeItem('selectedPaper');
            }
        }
        
        function changeUserFilter(value) {
            // 保存选择的学生ID
            if (value) {
                localStorage.setItem('selectedStudent', value);
            } else {
                localStorage.removeItem('selectedStudent');
            }
        }
        
        function applyFilters() {
            var pname = $('select[name="pname"]').val() || '';
            var userid = $('select[name="userid"]').val() || '';
            
            window.location.href = '<%=basePath%>sys/paper?cmd=gradeEssays&pname=' + encodeURIComponent(pname) + '&userid=' + userid;
        }
        
        // 页面加载时恢复之前的选择
        $(document).ready(function() {
            var savedPaper = localStorage.getItem('selectedPaper');
            var savedStudent = localStorage.getItem('selectedStudent');
            
            if (savedPaper && !$('select[name="pname"]').val()) {
                $('select[name="pname"]').val(savedPaper);
            }
            
            if (savedStudent && !$('select[name="userid"]').val()) {
                $('select[name="userid"]').val(savedStudent);
            }
        });
    </script>
</body>
</html> 