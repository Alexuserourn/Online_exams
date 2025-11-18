<%@ page language="java" import="java.sql.*,cn.itbaizhan.tyut.exam.common.DBUnitHelper" pageEncoding="UTF-8"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE HTML>
<html>
<head>
    <base href="<%=basePath%>">
    <title>统计功能测试</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f5f5f5; }
    </style>
    <script src="<%=basePath%>js/jquery.js"></script>
</head>

<body>
    <h1>统计功能测试</h1>
    
    <div id="result">
        <p>正在测试统计功能，请稍候...</p>
    </div>
    
    <div id="dataTest" style="margin-top: 30px;">
        <h2>数据格式测试</h2>
        <div id="dataTestResult"></div>
    </div>
    
    <script>
        $(document).ready(function() {
            // 直接调用统计Servlet的getStudentData方法
            $.ajax({
                url: '<%=basePath%>statistics?cmd=getStudentData',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let html = '<h3 class="success">成功获取数据</h3>';
                    html += '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
                    
                    if (!data || !data.labels || data.labels.length === 0) {
                        html += '<p class="error">警告：返回的数据为空或没有标签数据</p>';
                    } else {
                        html += '<p class="success">找到 ' + data.labels.length + ' 条成绩记录</p>';
                    }
                    
                    $('#result').html(html);
                    
                    // 测试数据格式
                    testDataFormat(data);
                },
                error: function(xhr, status, error) {
                    let html = '<h3 class="error">获取数据失败</h3>';
                    html += '<p>错误信息：' + error + '</p>';
                    html += '<p>状态码：' + xhr.status + '</p>';
                    
                    if (xhr.responseText) {
                        html += '<h4>响应内容：</h4>';
                        html += '<pre>' + xhr.responseText + '</pre>';
                    }
                    
                    $('#result').html(html);
                }
            });
        });
        
        // 测试数据格式
        function testDataFormat(data) {
            let html = '';
            
            if (!data) {
                html = '<p class="error">数据为空</p>';
                $('#dataTestResult').html(html);
                return;
            }
            
            html += '<h3>数据格式检查</h3>';
            
            // 检查labels数组
            html += '<h4>Labels 数组:</h4>';
            if (Array.isArray(data.labels)) {
                html += '<p class="success">✓ labels是一个数组，包含 ' + data.labels.length + ' 个元素</p>';
                
                if (data.labels.length > 0) {
                    html += '<table>';
                    html += '<tr><th>索引</th><th>值</th><th>类型</th></tr>';
                    
                    for (let i = 0; i < data.labels.length; i++) {
                        html += '<tr>';
                        html += '<td>' + i + '</td>';
                        html += '<td>' + data.labels[i] + '</td>';
                        html += '<td>' + typeof data.labels[i] + '</td>';
                        html += '</tr>';
                    }
                    
                    html += '</table>';
                }
            } else {
                html += '<p class="error">× labels不是一个数组</p>';
            }
            
            // 检查scores数组
            html += '<h4>Scores 数组:</h4>';
            if (Array.isArray(data.scores)) {
                html += '<p class="success">✓ scores是一个数组，包含 ' + data.scores.length + ' 个元素</p>';
                
                if (data.scores.length > 0) {
                    html += '<table>';
                    html += '<tr><th>索引</th><th>值</th><th>类型</th><th>是否为数字</th></tr>';
                    
                    for (let i = 0; i < data.scores.length; i++) {
                        html += '<tr>';
                        html += '<td>' + i + '</td>';
                        html += '<td>' + data.scores[i] + '</td>';
                        html += '<td>' + typeof data.scores[i] + '</td>';
                        html += '<td>' + (!isNaN(parseFloat(data.scores[i])) && isFinite(data.scores[i])) + '</td>';
                        html += '</tr>';
                    }
                    
                    html += '</table>';
                }
            } else {
                html += '<p class="error">× scores不是一个数组</p>';
            }
            
            // 检查数组长度是否匹配
            if (Array.isArray(data.labels) && Array.isArray(data.scores)) {
                if (data.labels.length === data.scores.length) {
                    html += '<p class="success">✓ labels和scores数组长度匹配</p>';
                } else {
                    html += '<p class="error">× labels和scores数组长度不匹配</p>';
                }
            }
            
            $('#dataTestResult').html(html);
        }
    </script>
</body>
</html> 