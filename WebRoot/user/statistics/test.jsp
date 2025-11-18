<%@ page language="java" import="java.sql.*,cn.itbaizhan.tyut.exam.common.DBUnitHelper" pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
    <title>试卷成绩数据测试</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f5f5f5; }
        .success { color: green; }
        .error { color: red; }
        h1 { color: #333; }
    </style>
</head>

<body>
    <h1>试卷成绩数据测试</h1>
    
    <%
        try {
            // 获取数据库连接
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            Connection conn = dbHelper.getConn();
            
            if (conn != null && !conn.isClosed()) {
                out.println("<p class='success'>✓ 数据库连接成功</p>");
                
                // 执行查询
                String sql = "SELECT * FROM paper_user ORDER BY userid";
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                
                // 显示数据表格
                out.println("<table>");
                out.println("<tr>");
                out.println("<th>ID</th>");
                out.println("<th>试卷ID</th>");
                out.println("<th>试卷名称</th>");
                out.println("<th>用户ID</th>");
                out.println("<th>分数</th>");
                out.println("<th>百分比分数</th>");
                out.println("<th>剩余题目</th>");

                out.println("</tr>");

                int count = 0;
                while (rs.next()) {
                    count++;
                    out.println("<tr>");
                    out.println("<td>" + rs.getInt("id") + "</td>");
                    out.println("<td>" + rs.getLong("spid") + "</td>");
                    out.println("<td>" + rs.getString("pname") + "</td>");
                    out.println("<td>" + rs.getInt("userid") + "</td>");
                    out.println("<td>" + rs.getInt("score") + "</td>");
                    out.println("<td>" + rs.getDouble("percent_score") + "</td>");
                    out.println("<td>" + rs.getInt("remaining_questions") + "</td>");

                    out.println("</tr>");
                }
                out.println("</table>");
                
                out.println("<p>总共显示 " + count + " 条记录</p>");
                
                // 关闭资源
                rs.close();
                stmt.close();
                conn.close();
            } else {
                out.println("<p class='error'>× 数据库连接失败</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>× 错误: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
</body>
</html>