<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
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
    <title>欢迎使用教学辅助系统</title>
    <link rel="stylesheet" href="<%=basePath%>css/bootstrap.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Microsoft YaHei', Arial, sans-serif;
            padding: 20px;
        }
        
        .welcome-container {
            max-width: 900px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            padding: 30px;
            text-align: center;
        }
        
        .logo-area {
            margin-bottom: 30px;
        }
        
        .logo-circle {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #4CAF50, #2196F3);
            border-radius: 50%;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 48px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        
        .welcome-title {
            font-size: 28px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
            margin-top: 20px;
        }
        
        .welcome-subtitle {
            font-size: 18px;
            color: #666;
            margin-bottom: 30px;
        }
        
        .feature-row {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            margin: 20px 0;
        }
        
        .feature-box {
            width: 200px;
            margin: 15px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .feature-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .feature-icon {
            font-size: 36px;
            margin-bottom: 15px;
            color: #4CAF50;
        }
        
        .feature-title {
            font-size: 16px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .feature-desc {
            font-size: 14px;
            color: #666;
        }
        
        .quote-section {
            margin-top: 40px;
            padding: 20px;
            background-color: #f0f7ff;
            border-radius: 8px;
            font-style: italic;
            color: #555;
        }
        
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #999;
            font-size: 14px;
        }
        
        /* 图标字体 */
        @font-face {
            font-family: 'iconfont';
            src: url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.eot');
            src: url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.eot?#iefix') format('embedded-opentype'),
                url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.woff2') format('woff2'),
                url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.woff') format('woff'),
                url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.ttf') format('truetype'),
                url('//at.alicdn.com/t/font_1788044_0dwu4guekcwr.svg#iconfont') format('svg');
        }
        
        .icon {
            font-family: "iconfont" !important;
            font-size: 36px;
            font-style: normal;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
    </style>
</head>

<body>
    <div class="welcome-container">
        <div class="logo-area">
            <div class="logo-circle">教</div>
        </div>
        
        <h1 class="welcome-title">欢迎使用教学辅助系统</h1>
        <p class="welcome-subtitle">提升教学效率，助力学生成长</p>
        
        <div class="feature-row">
            <div class="feature-box">
                <div class="icon">&#xe645;</div>
                <div class="feature-title">试题管理</div>
                <div class="feature-desc">创建、编辑和管理各类试题</div>
            </div>
            
            <div class="feature-box">
                <div class="icon">&#xe67a;</div>
                <div class="feature-title">学生管理</div>
                <div class="feature-desc">管理学生信息</div>
            </div>
            
            <div class="feature-box">
                <div class="icon">&#xe6ad;</div>
                <div class="feature-title">成绩统计</div>
                <div class="feature-desc">分析学生成绩和学习情况</div>
            </div>
        </div>
        
        <div class="quote-section">
            <p>"教育不是灌输，而是点燃火焰。" — 苏格拉底</p>
        </div>
        
        <div class="footer">
            <p>© <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> 教学辅助系统 - 版权所有</p>
        </div>
    </div>
</body>
</html> 