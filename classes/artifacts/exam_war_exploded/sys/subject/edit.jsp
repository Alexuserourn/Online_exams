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

		<title>编辑试题功能</title>
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.css">
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/theme.css">
		<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
		<style>
			.option-group {
				margin-bottom: 15px;
			}
			.hidden {
				display: none;
			}
		</style>
	</head>

	<body class="content1">
		<script>
    		$('#a_leader_txt', parent.document).html('试题编辑功能管理');
    		
    		// 根据题目类型显示/隐藏相应的选项
    		$(document).ready(function() {
    			// 初始化显示
    			var currentType = $('#stype').val() || "1";
    			showOptions(currentType);
    			console.log("当前题型: " + currentType + ", 标准答案: " + "${item.standardAnswer}");
    			
    			// 监听题目类型变化
    			$('#stype').change(function() {
    				showOptions($(this).val());
    			});
    		});
    		
    		function showOptions(type) {
    			// 隐藏所有选项组
    			$('.option-group').addClass('hidden');
    			
    			// 根据类型显示对应选项
    			switch(type) {
    				case "1": // 单选题
    					$('#single-choice-options').removeClass('hidden');
    					$('#answer-key').removeClass('hidden');
    					break;
    				case "2": // 多选题
    					$('#multi-choice-options').removeClass('hidden');
    					$('#answer-key').removeClass('hidden');
    					break;
    				case "3": // 判断题
    					$('#judgment-options').removeClass('hidden');
    					$('#answer-key').removeClass('hidden');
    					break;
    				case "4": // 填空题
    					$('#fill-blank-options').removeClass('hidden');
    					break;
    				case "5": // 简答题
    					$('#essay-options').removeClass('hidden');
    					break;
    			}
    		}
		</script>
		<div class="container-fluid">
			<div class="row-fluid">
				<form method="post" action="<%=basePath%>sys/subject?cmd=edit">
					<div class="btn-toolbar">
						<input type="submit" class="btn btn-primary" value="保存 ">
						<a href="<%=basePath%>sys/subject?cmd=list" class="btn">取消</a>
					</div>

					<div class="well">
						<div class="tab-pane active in">
							<input type="hidden" name="sid" value="${item.sid}" />
							
							<label>
								题干：
							</label>
							<input type="text" name="scontent" value="${item.scontent}" maxlength="100" class="span12"/>
							
							<label>
								题目类型：
							</label>
							<select name="stype" id="stype">
								<option value="1" ${item.stype == 1 || item.stype == null ? 'selected' : ''}>单选题</option>
								<option value="2" ${item.stype == 2 ? 'selected' : ''}>多选题</option>
								<option value="3" ${item.stype == 3 ? 'selected' : ''}>判断题</option>
								<option value="4" ${item.stype == 4 ? 'selected' : ''}>填空题</option>
								<option value="5" ${item.stype == 5 ? 'selected' : ''}>简答题</option>
							</select>
							
							<label>
								分值：
							</label>
							<input type="number" name="score" value="${item.score != null ? item.score : 2}" min="1" max="100">
							
							<!-- 单选题选项 -->
							<div id="single-choice-options" class="option-group">
								<label>A选项内容：</label>
								<input type="text" name="sa" value="${item.sa}" maxlength="100" class="span12">
								
								<label>B选项内容：</label>
								<input type="text" name="sb" value="${item.sb}" maxlength="100" class="span12">
								
								<label>C选项内容：</label>
								<input type="text" name="sc" value="${item.sc}" maxlength="100" class="span12">
								
								<label>D选项内容：</label>
								<input type="text" name="sd" value="${item.sd}" maxlength="100" class="span12">
							</div>
							
							<!-- 多选题选项 -->
							<div id="multi-choice-options" class="option-group hidden">
								<label>A选项内容：</label>
								<input type="text" name="sa" value="${item.sa}" maxlength="100" class="span12">
								
								<label>B选项内容：</label>
								<input type="text" name="sb" value="${item.sb}" maxlength="100" class="span12">
								
								<label>C选项内容：</label>
								<input type="text" name="sc" value="${item.sc}" maxlength="100" class="span12">
								
								<label>D选项内容：</label>
								<input type="text" name="sd" value="${item.sd}" maxlength="100" class="span12">
								
								<label>E选项内容：</label>
								<input type="text" name="se" value="${item.se}" maxlength="100" class="span12">
								
								<label>F选项内容：</label>
								<input type="text" name="sf" value="${item.sf}" maxlength="100" class="span12">
							</div>
							
							<!-- 判断题选项 -->
							<div id="judgment-options" class="option-group hidden">
								<label>A选项内容：</label>
								<input type="text" name="sa" value="${empty item.sa ? '正确' : item.sa}" maxlength="100" class="span12">
								
								<label>B选项内容：</label>
								<input type="text" name="sb" value="${empty item.sb ? '错误' : item.sb}" maxlength="100" class="span12">
							</div>
							
							<!-- 填空题选项 -->
							<div id="fill-blank-options" class="option-group hidden">
								<label>标准答案：</label>
								<input type="text" name="standardAnswer" value="${item.standardAnswer}" maxlength="500" class="span12">
							</div>
							
							<!-- 简答题选项 -->
							<div id="essay-options" class="option-group hidden">
								<label>标准答案：</label>
								<textarea name="standardAnswer" rows="5" class="span12">${item.standardAnswer}</textarea>
							</div>
							
							<!-- 选择题答案选项 -->
							<div id="answer-key" class="option-group">
								<label>
									标准答案选项：
								</label>
								<input type="text" name="skey" value="${item.skey}" maxlength="10" placeholder="单选题填A/B/C/D，多选题填组合如ABC">
							</div>
							
							<label>
								解析：
							</label>
							<textarea name="analysis" rows="3" class="span12">${item.analysis}</textarea>
							
							<label>
								试题状态：
							</label>
							<select name="sstate">
								<c:choose>
									<c:when test="${item.sstate==\"1\"}">
									<option value="1" selected="selected">正常</option>
									<option value="0">锁定</option>		
									</c:when>
									<c:otherwise>
									<option value="1">正常</option>
									<option value="0" selected="selected">锁定</option>	
									</c:otherwise>
								</c:choose>
							</select>
							<div style="color: red">
								${msg}
							</div>
						</div>
					</div>
				</form>
			</div>
		</div>
	</body>
</html>
