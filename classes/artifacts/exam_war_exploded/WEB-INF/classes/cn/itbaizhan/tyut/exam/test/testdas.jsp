<%@ page language="java" import="java.util.*,java.sql.*,cn.itbaizhan.tyut.exam.common.DBUnitHelper" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>

<!DOCTYPE HTML>
<html>
<head>
    <base href="<%=basePath%>">
    <title>Paper User表数据测试</title>
    <link rel="stylesheet" href="<%=basePath%>css/bootstrap.min.css">
    <style>
        body { padding: 20px; }
        .container { max-width: 1200px; }
        table { margin-top: 20px; }
        .panel { margin-top: 20px; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 5px; }
    </style>
</head>

<body>
    <div class="container">
        <h1>Paper User表数据测试</h1>
        <p>此页面用于测试从paper_user表中读取成绩数据，并按用户ID分类。</p>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">数据库连接测试</h3>
            </div>
            <div class="panel-body">
                <%
                    boolean connectionSuccess = false;
                    try {
                        DBUnitHelper dbHelper = DBUnitHelper.getInstance();
                        Connection conn = dbHelper.getConn();
                        if (conn != null && !conn.isClosed()) {
                            connectionSuccess = true;
                            conn.close();
                        }
                    } catch (Exception e) {
                        out.println("<div class='alert alert-danger'>数据库连接失败: " + e.getMessage() + "</div>");
                        e.printStackTrace();
                    }
                    
                    if (connectionSuccess) {
                        out.println("<div class='alert alert-success'>数据库连接成功!</div>");
                    }
                %>
            </div>
        </div>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">Paper User表测试</h3>
            </div>
            <div class="panel-body">
                <%
                    try {
                        DBUnitHelper dbHelper = DBUnitHelper.getInstance();
                        
                        // 检查表是否存在
                        String tableCheckSql = "SHOW TABLES LIKE 'paper_user'";
                        List<Map<String, Object>> tableCheck = dbHelper.executeRawQuery(tableCheckSql);
                        if (tableCheck == null || tableCheck.isEmpty()) {
                            out.println("<div class='alert alert-danger'>paper_user表不存在!</div>");
                        } else {
                            out.println("<div class='alert alert-success'>paper_user表存在!</div>");
                            
                            // 获取表结构
                            String descSql = "DESCRIBE paper_user";
                            List<Map<String, Object>> tableDesc = dbHelper.executeRawQuery(descSql);
                            
                            if (tableDesc != null && !tableDesc.isEmpty()) {
                                out.println("<h4>表结构:</h4>");
                                out.println("<table class='table table-bordered table-striped'>");
                                out.println("<thead><tr><th>字段名</th><th>类型</th><th>可为空</th><th>键</th><th>默认值</th><th>额外</th></tr></thead>");
                                out.println("<tbody>");
                                
                                for (Map<String, Object> column : tableDesc) {
                                    out.println("<tr>");
                                    out.println("<td>" + column.get("Field") + "</td>");
                                    out.println("<td>" + column.get("Type") + "</td>");
                                    out.println("<td>" + column.get("Null") + "</td>");
                                    out.println("<td>" + column.get("Key") + "</td>");
                                    out.println("<td>" + (column.get("Default") == null ? "NULL" : column.get("Default")) + "</td>");
                                    out.println("<td>" + (column.get("Extra") == null ? "" : column.get("Extra")) + "</td>");
                                    out.println("</tr>");
                                }
                                
                                out.println("</tbody></table>");
                            }
                            
                            // 获取记录总数
                            String countSql = "SELECT COUNT(*) as count FROM paper_user";
                            List<Map<String, Object>> countResult = dbHelper.executeRawQuery(countSql);
                            int totalCount = 0;
                            
                            if (countResult != null && !countResult.isEmpty()) {
                                totalCount = ((Number)countResult.get(0).get("count")).intValue();
                                out.println("<div class='alert alert-info'>paper_user表中共有 " + totalCount + " 条记录</div>");
                            }
                            
                            // 如果有记录，显示所有记录
                            if (totalCount > 0) {
                                String allRecordsSql = "SELECT * FROM paper_user ORDER BY userid, create_time";
                                List<Map<String, Object>> allRecords = dbHelper.executeRawQuery(allRecordsSql);
                                
                                if (allRecords != null && !allRecords.isEmpty()) {
                                    out.println("<h4>所有记录:</h4>");
                                    out.println("<table class='table table-bordered table-striped'>");
                                    out.println("<thead><tr>");
                                    
                                    // 动态生成表头
                                    Map<String, Object> firstRow = allRecords.get(0);
                                    for (String key : firstRow.keySet()) {
                                        out.println("<th>" + key + "</th>");
                                    }
                                    out.println("</tr></thead>");
                                    out.println("<tbody>");
                                    
                                    // 显示所有记录
                                    for (Map<String, Object> record : allRecords) {
                                        out.println("<tr>");
                                        for (String key : firstRow.keySet()) {
                                            out.println("<td>" + (record.get(key) == null ? "NULL" : record.get(key)) + "</td>");
                                        }
                                        out.println("</tr>");
                                    }
                                    
                                    out.println("</tbody></table>");
                                    
                                    // 按用户ID分组统计
                                    String groupBySql = "SELECT userid, COUNT(*) as record_count, " +
                                                      "GROUP_CONCAT(pname) as paper_names, " +
                                                      "AVG(percent_score) as avg_score, " +
                                                      "MAX(percent_score) as max_score, " +
                                                      "MIN(percent_score) as min_score " +
                                                      "FROM paper_user GROUP BY userid";
                                    List<Map<String, Object>> groupByResults = dbHelper.executeRawQuery(groupBySql);
                                    
                                    if (groupByResults != null && !groupByResults.isEmpty()) {
                                        out.println("<h4>按用户ID分组统计:</h4>");
                                        out.println("<table class='table table-bordered table-striped'>");
                                        out.println("<thead><tr><th>用户ID</th><th>记录数</th><th>试卷名称</th><th>平均分</th><th>最高分</th><th>最低分</th></tr></thead>");
                                        out.println("<tbody>");
                                        
                                        for (Map<String, Object> group : groupByResults) {
                                            out.println("<tr>");
                                            out.println("<td>" + group.get("userid") + "</td>");
                                            out.println("<td>" + group.get("record_count") + "</td>");
                                            out.println("<td>" + group.get("paper_names") + "</td>");
                                            out.println("<td>" + (group.get("avg_score") == null ? "N/A" : String.format("%.2f", ((Number)group.get("avg_score")).doubleValue())) + "</td>");
                                            out.println("<td>" + (group.get("max_score") == null ? "N/A" : String.format("%.2f", ((Number)group.get("max_score")).doubleValue())) + "</td>");
                                            out.println("<td>" + (group.get("min_score") == null ? "N/A" : String.format("%.2f", ((Number)group.get("min_score")).doubleValue())) + "</td>");
                                            out.println("</tr>");
                                        }
                                        
                                        out.println("</tbody></table>");
                                    }
                                    
                                    // 测试当前登录用户的数据
                                    Integer currentUserId = (Integer) session.getAttribute("userid");
                                    if (currentUserId != null) {
                                        String currentUserSql = "SELECT * FROM paper_user WHERE userid = ? ORDER BY create_time";
                                        List<Map<String, Object>> currentUserResults = dbHelper.executeRawQuery(currentUserSql, currentUserId);
                                        
                                        out.println("<h4>当前用户(ID: " + currentUserId + ")的成绩数据:</h4>");
                                        
                                        if (currentUserResults != null && !currentUserResults.isEmpty()) {
                                            out.println("<div class='alert alert-success'>找到 " + currentUserResults.size() + " 条记录</div>");
                                            
                                            out.println("<table class='table table-bordered table-striped'>");
                                            out.println("<thead><tr><th>试卷名称</th><th>分数</th><th>百分比分数</th><th>创建时间</th></tr></thead>");
                                            out.println("<tbody>");
                                            
                                            for (Map<String, Object> record : currentUserResults) {
                                                out.println("<tr>");
                                                out.println("<td>" + record.get("pname") + "</td>");
                                                out.println("<td>" + record.get("score") + "</td>");
                                                out.println("<td>" + record.get("percent_score") + "</td>");
                                                out.println("<td>" + record.get("create_time") + "</td>");
                                                out.println("</tr>");
                                            }
                                            
                                            out.println("</tbody></table>");
                                            
                                            // 生成JSON数据，用于前端图表
                                            out.println("<h4>用于图表的JSON数据:</h4>");
                                            out.println("<pre>");
                                            out.println("{");
                                            out.println("  \"labels\": [");
                                            
                                            boolean first = true;
                                            for (Map<String, Object> record : currentUserResults) {
                                                if (!first) out.println(",");
                                                out.println("    \"" + record.get("pname") + "\"");
                                                first = false;
                                            }
                                            
                                            out.println("  ],");
                                            out.println("  \"scores\": [");
                                            
                                            first = true;
                                            for (Map<String, Object> record : currentUserResults) {
                                                if (!first) out.println(",");
                                                out.println("    " + record.get("percent_score"));
                                                first = false;
                                            }
                                            
                                            out.println("  ]");
                                            out.println("}");
                                            out.println("</pre>");
                                        } else {
                                            out.println("<div class='alert alert-warning'>当前用户没有成绩数据</div>");
                                            
                                            // 尝试使用大写的USERID查询
                                            String upperCaseSql = "SELECT * FROM paper_user WHERE USERID = ? ORDER BY create_time";
                                            List<Map<String, Object>> upperCaseResults = dbHelper.executeRawQuery(upperCaseSql, currentUserId);
                                            
                                            if (upperCaseResults != null && !upperCaseResults.isEmpty()) {
                                                out.println("<div class='alert alert-info'>使用大写的USERID字段找到 " + upperCaseResults.size() + " 条记录</div>");
                                            } else {
                                                out.println("<div class='alert alert-danger'>使用大写的USERID字段也没有找到记录</div>");
                                            }
                                        }
                                    } else {
                                        out.println("<div class='alert alert-warning'>当前没有登录用户</div>");
                                    }
                                }
                            } else {
                                out.println("<div class='alert alert-warning'>paper_user表中没有记录</div>");
                            }
                        }
                    } catch (Exception e) {
                        out.println("<div class='alert alert-danger'>查询失败: " + e.getMessage() + "</div>");
                        e.printStackTrace();
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>