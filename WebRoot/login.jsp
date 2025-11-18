<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
	
	// 获取通知消息（如果有）
	String notification = (String)session.getAttribute("notification");
	String notificationType = (String)session.getAttribute("notificationType");
	
	// 清除会话中的通知，避免刷新时重复显示
	session.removeAttribute("notification");
	session.removeAttribute("notificationType");
	
	// 获取来源参数，判断是否是从登出操作跳转过来的
	String fromLogout = request.getParameter("from");
	// 如果是从登出操作跳转过来的，清除通知消息
	if ("logout".equals(fromLogout)) {
		notification = null;
		notificationType = null;
	}
	
	// 调试信息
	System.out.println("Debug - notification: " + notification);
	System.out.println("Debug - notificationType: " + notificationType);
%>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/admin.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/pintuer.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath%>css/bootstrap.css">
    <title>学生登录</title>
    
    <!-- Toast通知样式 -->
    <style>
        /* Toast通知样式 */
        .toast-container{position:fixed;top:20px;right:20px;z-index:9999;}
        .toast{background-color:#fff;border-radius:6px;box-shadow:0 3px 10px rgba(0,0,0,0.15);margin-bottom:10px;overflow:hidden;animation:slideIn 0.5s;}
        .toast-success{border-left:6px solid #4CAF50;}
        .toast-error{border-left:6px solid #f44336;}
        .toast-warning{border-left:6px solid #ff9800;}
        .toast-info{border-left:6px solid #2196F3;}
        .toast-header{display:flex;justify-content:space-between;align-items:center;padding:10px 15px;background-color:#f8f9fa;}
        .toast-title{font-weight:bold;font-size:16px;margin:0;}
        .toast-close{background:none;border:none;font-size:20px;cursor:pointer;color:#aaa;line-height:0.8;}
        .toast-close:hover{color:#555;}
        .toast-body{padding:15px;font-size:14px;}
        .toast-success .toast-title{color:#4CAF50;}
        .toast-error .toast-title{color:#f44336;}
        .toast-warning .toast-title{color:#ff9800;}
        .toast-info .toast-title{color:#2196F3;}
        @keyframes slideIn{from{transform:translateX(100%);opacity:0;}to{transform:translateX(0);opacity:1;}}
        @keyframes fadeOut{from{opacity:1;}to{opacity:0;}}
        
        /* 登录面板增强 */
        .loginbox {
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }
        .loginbox:hover {
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
        }
        .input-big:focus {
            border-color: #4CAF50;
            box-shadow: 0 0 8px rgba(76, 175, 80, 0.4);
        }
        .button-block {
            transition: background 0.3s ease;
        }
        .button-block:hover {
            background-color: #3c8c40 !important;
        }
        .notification-message {
            padding: 10px 15px;
            margin: 10px 0;
            border-radius: 4px;
            font-weight: bold;
        }
        .notification-success {
            background-color: #e8f5e9;
            color: #4CAF50;
            border-left: 4px solid #4CAF50;
        }
        .notification-error {
            background-color: #ffebee;
            color: #f44336;
            border-left: 4px solid #f44336;
        }
    </style>
</head>

<body>
    <div class="bg"></div>
    <div class="container">
        <div class="line bouncein">
            <div class="xs6 xm4 xs3-move xm4-move">
                <div style="height:80px;"></div>
                <div class="media media-y margin-big-bottom">
                </div>
                <form action="<%=basePath%>user?cmd=stulogin" method="post" class="login-form">
                    <div class="panel loginbox">
                        <div class="text-center margin-big padding-big-top">
                            <h1>教学辅助系统</h1>
                            <div class="form-top-left">
                                <a data-type="student" href="javascript:void(0);" style="color: red;">学生登录</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;
                                <a data-type="admin" href="javascript:void(0);">管理员登录</a><br>
                                <br>
                                <!-- 显示错误消息 -->
                                <% if (request.getAttribute("msg") != null && !request.getAttribute("msg").toString().isEmpty()) { %>
                                <div class="notification-message notification-<%= request.getAttribute("notificationType") != null ? request.getAttribute("notificationType") : "error" %>" id="msg">${msg}</div>
                                <% } else { %>
                                <p id="mes" style="color: red;"></p>
                                <% } %>
                            </div>
                        </div>
                        <div class="panel-body" style="padding:30px; padding-bottom:10px; padding-top:10px;">
                            <div class="form-group">
                                <div class="field field-icon-right">
                                    <input type="text" class="input input-big" name="username" placeholder="登录账号" data-validate="required:请填写账号" />
                                    <span class="icon icon-user margin-small"></span>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="field field-icon-right">
                                    <input type="password" class="input input-big" name="userpwd" placeholder="登录密码" data-validate="required:请填写密码" />
                                    <span class="icon icon-key margin-small"></span>
                                </div>
                            </div>
                        </div>
                        <div style="padding:30px;"><button type="submit" class="button button-block bg-main text-big input-big">登录</button></div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="<%=basePath%>js/jquery.js"></script>
    <script src="<%=basePath%>js/bootstrap.js"></script>
    <script src="<%=basePath%>js/pintuer.js"></script>
    <script>
		var basePath = '<%=basePath%>'
		$('.form-top-left a').click(function () {
		    $('.form-top-left').children().removeAttr("style");
		    var type = $(this).css('color', 'red').attr("data-type");
		    if (type == 'student') {
		        $(document).attr("title", "学生登录");
		        $("#mes").html('');
		        $("#msg").hide();
		        $(".login-form").attr("action", basePath + "user?cmd=stulogin");
		    }else {
		        $(document).attr("title", "管理员登录");
		        $("#register").html('');
		        $("#mes").html('');
		        $("#msg").hide();
		        $(".login-form").attr("action", basePath + "sys/user?cmd=login");
		    }
		})
	</script>
	
	<!-- 通知消息处理 -->
	<% if (notification != null && !notification.isEmpty()) { %>
	<div class="toast-container">
	    <div class="toast toast-<%= notificationType != null ? notificationType : "info" %>">
	        <div class="toast-header">
	            <div class="toast-title">
	                <% if ("success".equals(notificationType)) { %>
	                成功
	                <% } else if ("error".equals(notificationType)) { %>
	                错误
	                <% } else if ("warning".equals(notificationType)) { %>
	                警告
	                <% } else { %>
	                信息
	                <% } %>
	            </div>
	            <button class="toast-close" id="toast-close-btn">&times;</button>
	        </div>
	        <div class="toast-body"><%= notification %></div>
	    </div>
	</div>
	
	<script>
	    // 处理通知消息关闭
	    document.addEventListener('DOMContentLoaded', function() {
	        var closeBtn = document.getElementById('toast-close-btn');
	        if(closeBtn) {
	            closeBtn.addEventListener('click', function() {
	                var toast = document.querySelector('.toast');
	                if(toast) {
	                    toast.style.animation = 'fadeOut 0.5s';
	                    setTimeout(function() {
	                        var container = document.querySelector('.toast-container');
	                        if(container) container.remove();
	                    }, 500);
	                }
	            });
	        }
	        
	        // 5秒后自动关闭
	        setTimeout(function() {
	            var toast = document.querySelector('.toast');
	            if(toast) {
	                toast.style.animation = 'fadeOut 0.5s';
	                setTimeout(function() {
	                    var container = document.querySelector('.toast-container');
	                    if(container) container.remove();
	                }, 500);
	            }
	        }, 5000);
	    });
	</script>
	<% } %>
</body>

</html>