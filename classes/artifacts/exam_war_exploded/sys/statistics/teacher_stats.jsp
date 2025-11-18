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
    <title>考试成绩统计</title>
    <link rel="stylesheet" href="<%=basePath%>css/bootstrap.min.css">
    <link rel="stylesheet" href="<%=basePath%>css/teacher.css">
    <style>
        .chart-container {
            width: 100%;
            max-width: 800px;
            height: 400px;
            margin: 0 auto;
            padding: 20px;
            box-sizing: border-box;
        }
        .select-container {
            width: 100%;
            max-width: 800px;
            margin: 20px auto;
            padding: 0 20px;
            box-sizing: border-box;
        }
        .title {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
            font-weight: normal;
        }
        .card {
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            margin-bottom: 20px;
            background-color: #fff;
            padding: 20px;
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
    </style>
</head>

<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="title">考试成绩统计分析</h3>
                    </div>
                    <div class="card-body">
                        <div class="select-container">
                            <div class="form-group">
                                <label for="paperSelect">选择试卷：</label>
                                <select class="form-control" id="paperSelect">
                                    <option value="">请选择试卷</option>
                                    <c:forEach items="${papers}" var="paper">
                                        <option value="${paper.pname}">${paper.pname}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        
                        <div class="chart-container">
                            <h4 class="title">成绩分布柱状图</h4>
                            <canvas id="scoreChart"></canvas>
                        </div>
                        
                        <div id="statsInfo" style="margin-top: 30px;">
                            <!-- 统计信息将在这里显示 -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="<%=basePath%>js/jquery.js"></script>
    <script src="<%=basePath%>js/bootstrap.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    <script>
        // 图表对象
        let scoreChart = null;
        
        // 页面加载完成后执行
        $(document).ready(function() {
            // 监听试卷选择变化
            $('#paperSelect').change(function() {
                const pname = $(this).val();
                if (pname) {
                    loadChartData(pname);
                } else {
                    // 如果没有选择试卷，清空图表
                    if (scoreChart) {
                        scoreChart.destroy();
                        scoreChart = null;
                    }
                    $('#statsInfo').html('');
                }
            });
        });
        
        // 加载图表数据
        function loadChartData(pname) {
            $.ajax({
                url: '<%=basePath%>statistics?cmd=getTeacherData',
                type: 'GET',
                data: { pname: pname },
                dataType: 'json',
                success: function(data) {
                    renderChart(data);
                    renderStats(data, pname);
                },
                error: function(xhr, status, error) {
                    alert('获取数据失败：' + error);
                }
            });
        }
        
        // 渲染图表
        function renderChart(data) {
            const ctx = document.getElementById('scoreChart').getContext('2d');
            
            // 如果图表已存在，先销毁
            if (scoreChart) {
                scoreChart.destroy();
            }
            
            // 创建新图表
            scoreChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: '学生人数',
                        data: data.counts,
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.6)',
                            'rgba(255, 159, 64, 0.6)',
                            'rgba(255, 205, 86, 0.6)',
                            'rgba(75, 192, 192, 0.6)',
                            'rgba(54, 162, 235, 0.6)'
                        ],
                        borderColor: [
                            'rgb(255, 99, 132)',
                            'rgb(255, 159, 64)',
                            'rgb(255, 205, 86)',
                            'rgb(75, 192, 192)',
                            'rgb(54, 162, 235)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: '学生人数'
                            },
                            ticks: {
                                precision: 0
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: '分数区间'
                            }
                        }
                    },
                    plugins: {
                        title: {
                            display: true,
                            text: '考试成绩分布'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.dataset.label + ': ' + context.raw + '人';
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // 渲染统计信息
        function renderStats(data, pname) {
            // 计算总人数
            const totalStudents = data.counts.reduce((a, b) => a + b, 0);
            
            // 计算及格人数（60分以上）
            const passCount = data.counts.slice(1).reduce((a, b) => a + b, 0);
            
            // 计算及格率
            const passRate = totalStudents > 0 ? ((passCount / totalStudents) * 100).toFixed(2) : 0;
            
            // 生成HTML
            var html = '<div class="card">' +
                '<div class="card-header">' +
                '<h4 class="title">统计分析 - ' + pname + '</h4>' +
                '</div>' +
                '<div class="card-body">' +
                '<div class="row">' +
                '<div class="col-md-6">' +
                '<table class="table table-bordered">' +
                '<tr>' +
                '<th>总考试人数</th>' +
                '<td>' + totalStudents + ' 人</td>' +
                '</tr>' +
                '<tr>' +
                '<th>及格人数</th>' +
                '<td>' + passCount + ' 人</td>' +
                '</tr>' +
                '<tr>' +
                '<th>及格率</th>' +
                '<td>' + passRate + '%</td>' +
                '</tr>' +
                '</table>' +
                '</div>' +
                '<div class="col-md-6">' +
                '<table class="table table-bordered">' +
                '<tr>' +
                '<th>分数段</th>' +
                '<th>人数</th>' +
                '<th>占比</th>' +
                '</tr>';
            
            // 使用传统的循环而不是ES6的箭头函数和模板字符串
            for (var i = 0; i < data.labels.length; i++) {
                var percentage = totalStudents > 0 ? ((data.counts[i] / totalStudents) * 100).toFixed(2) : 0;
                html += '<tr>' +
                    '<td>' + data.labels[i] + '</td>' +
                    '<td>' + data.counts[i] + ' 人</td>' +
                    '<td>' + percentage + '%</td>' +
                    '</tr>';
            }
            
            html += '</table>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>';
            
            $('#statsInfo').html(html);
        }
    </script>
</body>
</html> 