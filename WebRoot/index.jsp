<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
	
	// 从session中获取菜单列表
	List list = (List)session.getAttribute("list");
	pageContext.setAttribute("list", list);
%>
<!DOCTYPE HTML>
<html lang="zh-CN">
<head>
    <base href="<%=basePath%>">
    <base target="main" />
    <title>教学辅助系统</title>
    <link rel="stylesheet" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" href="<%=basePath%>css/pintuer.css">
    <link rel="stylesheet" href="<%=basePath%>css/admin.css">
    <link rel="stylesheet" href="<%=basePath%>css/teacher.css">
    <script src="<%=basePath%>js/jquery.js"></script>
    
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
    </style>

</head>

<body style="background-color:#f5f5f5;">
    <div class="header">
        <div class="logo">
            <h1>教学辅助系统</h1>
        </div>
        <div class="head-l">
            <a class="button button-little bg-blue"><span class="icon-user"></span> ${user.usertruename}(${user.rolename})</a> &nbsp;&nbsp;
            <a class="button button-little bg-red" href="<%=basePath%>sys/user?cmd=logout" target="_self"><span class="icon-power-off"></span> 退出登录</a>
        </div>
    </div>
    <div class="leftnav">
        <div class="leftnav-title"><strong><span class="icon-list"></span> 功能菜单</strong></div>
        <c:forEach items="${list}" var="top">
            <c:if test="${top.funpid==\"-1\"}">
                <h2><span class="icon-briefcase"></span> ${top.funname}</h2>
                <ul id="menu${top.funid}" class="nav nav-list collapse" style="display:block">
                    <c:forEach items="${list}" var="child">
                        <c:if test="${child.funpid==top.funid}">
                            <li>
                                <a href="<%=basePath%>${child.funurl}" target="right"><span class="icon-caret-right"></span> ${child.funname}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                </ul>
            </c:if>
        </c:forEach>
    </div>
    <script type="text/javascript">
        $(function(){
            $(".leftnav h2").click(function(){
                $(this).next().slideToggle(200);	
                $(this).toggleClass("on"); 
            })
            $(".leftnav ul li a").click(function(){
                $("#a_leader_txt").text($(this).text());
                $(".leftnav ul li a").removeClass("on");
                $(this).addClass("on");
            })
        });
    </script>
    <ul class="bread">
        <li><a href="javascript:void(0);" target="right" id="a_leader_txt">系统信息</a></li>
    </ul>
    <div class="admin">
        <iframe scrolling="auto" rameborder="0" src="welcome.jsp" name="right" width="100%" height="100%"></iframe>
    </div>
    
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