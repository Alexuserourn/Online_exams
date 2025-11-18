<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>

<!DOCTYPE HTML>
<html>
<head>
    <base href="<%=basePath%>">
    <title>个人成绩统计</title>
    <link rel="stylesheet" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" href="<%=basePath%>css/paper.css">
    <style>
        .chart-container {
            width: 100%;
            max-width: 800px;
            height: 400px;
            margin: 0 auto;
            padding: 20px;
            box-sizing: border-box;
        }
        .title {
            text-align: center;
            margin-bottom: 20px;
        }
        .container {
            padding: 20px;
        }
        .card {
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            background-color: #fff;
        }
        .card-header {
            padding: 15px;
            border-bottom: 1px solid #eee;
            font-weight: bold;
            background-color: #f8f9fa;
        }
        .card-body {
            padding: 20px;
        }
        .navbar {
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        /* 自定义徽章样式 */
        .badge {
            display: inline-block;
            min-width: 10px;
            padding: 3px 7px;
            font-size: 12px;
            font-weight: 700;
            line-height: 1;
            color: #fff;
            text-align: center;
            white-space: nowrap;
            vertical-align: middle;
            background-color: #777;
            border-radius: 10px;
        }
        .badge-primary {
            background-color: #337ab7;
        }
        .badge-success {
            background-color: #5cb85c;
        }
        .badge-info {
            background-color: #5bc0de;
        }
        .badge-warning {
            background-color: #f0ad4e;
        }
        .badge-danger {
            background-color: #d9534f;
        }
        .badge-default {
            background-color: #777;
        }
        .pull-right {
            float: right;
        }
    </style>
</head>

<body>
    <!-- 导航栏 -->
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false">
                    <span class="sr-only">切换导航</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="<%=basePath%>user/index.jsp">教学辅助系统</a>
            </div>
            <div class="collapse navbar-collapse" id="navbar">
                <ul class="nav navbar-nav">
                    <li><a href="<%=basePath%>user?cmd=paperlist">试题列表</a></li>
                    <li><a href="<%=basePath%>user/studentPaper?cmd=stupaper">我的试卷</a></li>
                    <li><a href="<%=basePath%>user/studentPaper?cmd=allErrors">错题集</a></li>
                    <li><a href="<%=basePath%>user/studentPaper?cmd=freePractice">自由练习</a></li>
                    <li class="active"><a href="<%=basePath%>statistics?cmd=studentStats">成绩统计</a></li>
                </ul>
                <ul class="nav navbar-nav navbar-right">
                    <li><a href="#">欢迎, ${user.usertruename}</a></li>
                    <li><a href="<%=basePath%>sys/user?cmd=logout">退出</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="card">
            <div class="card-header">
                <h3>个人成绩统计</h3>
            </div>
            <div class="card-body">
                <div class="chart-container">
                    <h4 class="title">历次考试成绩折线图</h4>
                    <canvas id="scoreChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>成绩分析</h3>
            </div>
            <div class="card-body">
                <div id="statsInfo">
                    <p>请稍候，正在加载成绩数据...</p>
                </div>
            </div>
        </div>
    </div>

    <script src="<%=basePath%>js/jquery.js"></script>
    <script src="<%=basePath%>js/bootstrap.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    <script>
        // 图表对象
        let scoreChart = null;
        
        // 页面加载完成后执行
        $(document).ready(function() {
            loadChartData();
        });
        
        // 加载图表数据
        function loadChartData() {
            $.ajax({
                url: '<%=basePath%>statistics?cmd=getStudentData',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    // 检查数据是否为空
                    if (!data || !data.labels || data.labels.length === 0) {
                        $('#statsInfo').html('<div class="alert alert-warning">暂无考试成绩数据</div>');
                        $('#scoreChart').parent().html('<div class="alert alert-info">暂无考试成绩数据</div>');
                        return;
                    }
                    renderChart(data);
                    renderStats(data);
                },
                error: function(xhr, status, error) {
                    console.error('获取数据失败:', error);
                    $('#statsInfo').html('<div class="alert alert-danger">获取数据失败：' + error + '</div>');
                    $('#scoreChart').parent().html('<div class="alert alert-danger">获取数据失败</div>');
                }
            });
        }
        
        // 渲染图表
        function renderChart(data) {
            if (!data.labels || data.labels.length === 0) {
                $('#scoreChart').parent().html('<div class="alert alert-info">暂无考试成绩数据</div>');
                return;
            }
            
            const ctx = document.getElementById('scoreChart').getContext('2d');
            
            // 创建新图表
            scoreChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: '成绩(百分制)',
                        data: data.scores,
                        fill: false,
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1,
                        pointBackgroundColor: 'rgb(75, 192, 192)',
                        pointBorderColor: '#fff',
                        pointHoverBackgroundColor: '#fff',
                        pointHoverBorderColor: 'rgb(75, 192, 192)'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: false,
                            min: 0,
                            max: 100,
                            title: {
                                display: true,
                                text: '分数'
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: '试卷'
                            }
                        }
                    },
                    plugins: {
                        title: {
                            display: true,
                            text: '历次考试成绩趋势'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return '成绩: ' + context.raw + '分';
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // 渲染统计信息
        function renderStats(data) {
            if (!data.scores || data.scores.length === 0) {
                $('#statsInfo').html('<div class="alert alert-info">暂无考试成绩数据</div>');
                return;
            }
            
            // 确保scores数组中的所有元素都是数字
            const numericScores = data.scores.map(score => parseFloat(score));
            
            // 计算平均分
            const sum = numericScores.reduce((a, b) => a + b, 0);
            const avg = (sum / numericScores.length).toFixed(2);
            
            // 找出最高分和最低分
            const max = Math.max(...numericScores).toFixed(2);
            const min = Math.min(...numericScores).toFixed(2);
            
            // 计算及格率
            const passCount = numericScores.filter(score => score >= 60).length;
            const passRate = ((passCount / numericScores.length) * 100).toFixed(2);
            
            // 计算趋势
            let trend = '稳定';
            if (numericScores.length > 1) {
                const firstHalf = numericScores.slice(0, Math.floor(numericScores.length / 2));
                const secondHalf = numericScores.slice(Math.floor(numericScores.length / 2));
                
                const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
                const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
                
                if (secondAvg > firstAvg + 5) {
                    trend = '上升';
                } else if (secondAvg < firstAvg - 5) {
                    trend = '下降';
                }
            }
            
            // 生成HTML
            let html = '';
            html += '<div class="row">';
            html += '<div class="col-md-6">';
            html += '<h4>基本统计</h4>';
            html += '<ul class="list-group">';
            html += '<li class="list-group-item">考试次数 <span class="badge badge-primary pull-right">' + numericScores.length + '</span></li>';
            html += '<li class="list-group-item">平均分 <span class="badge badge-primary pull-right">' + avg + '</span></li>';
            html += '<li class="list-group-item">最高分 <span class="badge badge-success pull-right">' + max + '</span></li>';
            html += '<li class="list-group-item">最低分 <span class="badge badge-warning pull-right">' + min + '</span></li>';
            html += '</ul>';
            html += '</div>';
            html += '<div class="col-md-6">';
            html += '<h4>成绩分析</h4>';
            html += '<ul class="list-group">';
            html += '<li class="list-group-item">及格率 <span class="badge badge-info pull-right">' + passRate + '%</span></li>';
            
            let trendBadgeClass = 'badge-default';
            if (trend === '上升') {
                trendBadgeClass = 'badge-success';
            } else if (trend === '下降') {
                trendBadgeClass = 'badge-danger';
            }
            
            html += '<li class="list-group-item">成绩趋势 <span class="badge ' + trendBadgeClass + ' pull-right">' + trend + '</span></li>';
            html += '</ul>';
            html += '</div>';
            html += '</div>';
            
            $('#statsInfo').html(html);
        }
    </script>
</body>
</html> 