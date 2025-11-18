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

		<title>新增试卷</title>
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.css">
		<link rel="stylesheet" type="text/css" href="<%=basePath%>css/theme.css">
		<script src="<%=basePath%>js/jquery.js" type="text/javascript"></script>
		<style>
			.subject-list {
				max-height: 500px;
				overflow-y: auto;
				border: 1px solid #ddd;
				padding: 10px;
				margin-top: 10px;
			}
			.subject-item {
				padding: 8px;
				border-bottom: 1px solid #eee;
				margin-bottom: 5px;
			}
			.subject-item:hover {
				background-color: #f9f9f9;
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
			.form-section {
				margin-bottom: 20px;
				padding-bottom: 20px;
				border-bottom: 1px solid #eee;
			}
			.subject-count {
				margin-top: 10px;
				font-weight: bold;
			}
		</style>
	</head>

	<body class="content1">
		<script>
    		$('#a_leader_txt', parent.document).html('新增试卷');
    		
    		$(document).ready(function() {
    			// 初始化显示/隐藏相应的选项
    			togglePaperTypeOptions();
    			
    			// 监听组卷方式变化
    			$('input[name="paperType"]').change(function() {
    				togglePaperTypeOptions();
    			});
    			
    			// 全选/取消全选
    			$('#selectAll').click(function() {
    				$('.subject-checkbox').prop('checked', $(this).prop('checked'));
    				updateSelectedCount();
    			});
    			
    			// 单个选择框变化时更新计数
    			$(document).on('change', '.subject-checkbox', function() {
    				updateSelectedCount();
    			});
    			
    			// 按题型筛选
    			$('#typeFilter').change(function() {
    				var selectedType = $(this).val();
    				if (selectedType === "0") {
    					// 显示所有题目
    					$('.subject-item').show();
    				} else {
    					// 只显示选中类型的题目
    					$('.subject-item').hide();
    					$('.subject-item[data-type="' + selectedType + '"]').show();
    				}
    			});
    			
    			// 表单提交前的验证
    			$('form').submit(function(e) {
    				var paperType = $('input[name="paperType"]:checked').val();
    				
    				if (paperType == "1") {
    					// 随机组卷 - 验证试卷名称、题目数量和考试时间
    					var pname = $('input[name="pname"]').val();
    					var scount = $('input[name="scount"]').val();
    					var examTime = $('input[name="examTime"]').val();
    					
    					if (!pname || !scount) {
    						alert("请输入试卷名称和题目数量！");
    						e.preventDefault();
    						return false;
    					}
    					
    					if (!examTime || examTime < 1 || examTime > 180) {
    						alert("考试时间必须在1-180分钟之间！");
    						e.preventDefault();
    						return false;
    					}
    				} else {
    					// 手动选题 - 验证试卷名称、考试时间和是否选择了题目
    					var pname = $('input[name="pname"]').val();
    					var examTime = $('input[name="examTime"]').val();
    					var selectedCount = $('.subject-checkbox:checked').length;
    					
    					if (!pname) {
    						alert("请输入试卷名称！");
    						e.preventDefault();
    						return false;
    					}
    					
    					if (!examTime || examTime < 1 || examTime > 180) {
    						alert("考试时间必须在1-180分钟之间！");
    						e.preventDefault();
    						return false;
    					}
    					
    					if (selectedCount === 0) {
    						alert("请至少选择一道题目！");
    						e.preventDefault();
    						return false;
    					}
    				}
    			});
    		});
    		
    		// 根据组卷方式显示/隐藏相应的选项
    		function togglePaperTypeOptions() {
    			var paperType = $('input[name="paperType"]:checked').val();
    			
    			if (paperType == "1") {
    				// 随机组卷
    				$('#randomOptions').show();
    				$('#manualOptions').hide();
    			} else {
    				// 手动选题
    				$('#randomOptions').hide();
    				$('#manualOptions').show();
    			}
    		}
    		
    		// 更新已选题目数量
    		function updateSelectedCount() {
    			var selectedCount = $('.subject-checkbox:checked').length;
    			$('#selectedCount').text(selectedCount);
    		}
		</script>
		<div class="container-fluid">
			<div class="row-fluid">
				<form method="post" action="<%=basePath%>sys/paper?cmd=add">
					<div class="btn-toolbar">
						<input type="submit" class="btn btn-primary" value="保存">
						<a href="<%=basePath%>sys/paper?cmd=list" class="btn">取消</a>
					</div>

					<div class="well">
						<div class="tab-pane active in">
							<div class="form-section">
								<label>试卷名称：</label>
								<input type="text" name="pname" maxlength="10" class="span6">
							</div>
							
							<div class="form-section">
								<label>考试时间（分钟）：</label>
								<input type="number" name="examTime" min="1" max="180" value="20" class="span2">
								<span class="help-inline">默认为20分钟，可设置范围1-180分钟</span>
							</div>
							
							<div class="form-section">
								<label>组卷方式：</label>
								<label class="radio inline">
									<input type="radio" name="paperType" value="1" checked> 随机组卷
								</label>
								<label class="radio inline">
									<input type="radio" name="paperType" value="2"> 手动选题
								</label>
							</div>
							
							<!-- 随机组卷选项 -->
							<div id="randomOptions" class="form-section">
								<label>随机抽取题目数量：</label>
								<input type="text" name="scount" maxlength="10" class="span2">
							</div>
							
							<!-- 手动选题选项 -->
							<div id="manualOptions" style="display: none;">
								<div class="form-section">
									<label>按题型筛选：</label>
									<select id="typeFilter" class="span2">
										<option value="0">全部题型</option>
										<option value="1">单选题</option>
										<option value="2">多选题</option>
										<option value="3">判断题</option>
										<option value="4">填空题</option>
										<option value="5">简答题</option>
									</select>
									
									<div class="pull-right">
										<label class="checkbox inline">
											<input type="checkbox" id="selectAll"> 全选/取消全选
										</label>
										<span class="subject-count">已选择题目：<span id="selectedCount">0</span> 题</span>
									</div>
								</div>
								
								<div class="subject-list">
									<c:forEach items="${subjects}" var="subject">
										<div class="subject-item" data-type="${subject.stype == null ? 1 : subject.stype}">
											<label class="checkbox">
												<input type="checkbox" name="selectedSubjects" value="${subject.sid}" class="subject-checkbox">
												<c:choose>
													<c:when test="${subject.stype == 1 || subject.stype == null}">
														<span class="type-badge type-1">单选题</span>
													</c:when>
													<c:when test="${subject.stype == 2}">
														<span class="type-badge type-2">多选题</span>
													</c:when>
													<c:when test="${subject.stype == 3}">
														<span class="type-badge type-3">判断题</span>
													</c:when>
													<c:when test="${subject.stype == 4}">
														<span class="type-badge type-4">填空题</span>
													</c:when>
													<c:when test="${subject.stype == 5}">
														<span class="type-badge type-5">简答题</span>
													</c:when>
												</c:choose>
												${subject.scontent}
												<span class="badge">${subject.score}分</span>
											</label>
										</div>
									</c:forEach>
								</div>
							</div>
							
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
