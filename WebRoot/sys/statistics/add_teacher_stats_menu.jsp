<%@ page language="java" import="java.sql.*,cn.itbaizhan.tyut.exam.common.DBUnitHelper" pageEncoding="UTF-8"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE HTML>
<html>
<head>
    <base href="<%=basePath%>">
    <title>添加教师统计功能菜单</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
        h1 { color: #333; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 5px; }
        .btn { 
            display: inline-block; 
            padding: 8px 16px; 
            background-color: #4CAF50; 
            color: white; 
            text-decoration: none; 
            border-radius: 4px;
            margin-top: 20px;
        }
    </style>
</head>

<body>
    <h1>添加教师统计功能菜单</h1>
    
    <%
        try {
            // 获取数据库连接
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            Connection conn = dbHelper.getConn();
            
            if (conn != null && !conn.isClosed()) {
                out.println("<p class='success'>✓ 数据库连接成功</p>");
                
                // 检查菜单是否已存在
                String checkSql = "SELECT COUNT(*) as count FROM sysfunction WHERE funname = '成绩统计' AND funurl = 'statistics?cmd=teacherStats'";
                Statement checkStmt = conn.createStatement();
                ResultSet checkRs = checkStmt.executeQuery(checkSql);
                
                boolean exists = false;
                if (checkRs.next()) {
                    exists = checkRs.getInt("count") > 0;
                }
                
                checkRs.close();
                checkStmt.close();
                
                if (exists) {
                    out.println("<p class='success'>✓ 教师统计功能菜单已存在，无需添加</p>");
                } else {
                    // 查找教师管理相关的父菜单ID
                    String findParentSql = "SELECT funid FROM sysfunction WHERE funname LIKE '%教师%' OR funname LIKE '%管理%' AND funpid = '-1' LIMIT 1";
                    Statement findStmt = conn.createStatement();
                    ResultSet findRs = findStmt.executeQuery(findParentSql);
                    
                    String parentId = "-1"; // 默认为顶层菜单
                    if (findRs.next()) {
                        parentId = findRs.getString("funid");
                    }
                    
                    findRs.close();
                    findStmt.close();
                    
                    // 获取最大的funid
                    String maxIdSql = "SELECT MAX(CAST(funid AS UNSIGNED)) as maxid FROM sysfunction";
                    Statement maxIdStmt = conn.createStatement();
                    ResultSet maxIdRs = maxIdStmt.executeQuery(maxIdSql);
                    
                    int newId = 1;
                    if (maxIdRs.next()) {
                        newId = maxIdRs.getInt("maxid") + 1;
                    }
                    
                    maxIdRs.close();
                    maxIdStmt.close();
                    
                    // 插入新菜单
                    String insertSql = "INSERT INTO sysfunction (funid, funname, funurl, funpid, funstate) VALUES (?, '成绩统计', 'statistics?cmd=teacherStats', ?, '1')";
                    PreparedStatement pstmt = conn.prepareStatement(insertSql);
                    pstmt.setString(1, String.valueOf(newId));
                    pstmt.setString(2, parentId);
                    
                    int result = pstmt.executeUpdate();
                    pstmt.close();
                    
                    if (result > 0) {
                        out.println("<p class='success'>✓ 成功添加教师统计功能菜单</p>");
                        out.println("<p>菜单ID: " + newId + "</p>");
                        out.println("<p>父菜单ID: " + parentId + "</p>");
                        
                        // 添加角色-功能关联
                        String roleMenuSql = "INSERT INTO sysrolefunction (roleid, funid) SELECT roleid, ? FROM sysrole WHERE roleid IN (2, 3)";
                        PreparedStatement roleMenuStmt = conn.prepareStatement(roleMenuSql);
                        roleMenuStmt.setString(1, String.valueOf(newId));
                        
                        int roleMenuResult = roleMenuStmt.executeUpdate();
                        roleMenuStmt.close();
                        
                        out.println("<p class='success'>✓ 成功为教师和管理员角色添加菜单权限，影响 " + roleMenuResult + " 行</p>");
                    } else {
                        out.println("<p class='error'>× 添加菜单失败</p>");
                    }
                }
                
                // 关闭资源
                conn.close();
            } else {
                out.println("<p class='error'>× 数据库连接失败</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>× 错误: " + e.getMessage() + "</p>");
            e.printStackTrace(new java.io.PrintWriter(out));
        }
    %>
    
    <a href="<%=basePath%>sys/statistics/teacher_stats.jsp" class="btn">访问教师统计页面</a>
</body>
</html> 