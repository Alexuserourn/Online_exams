package cn.itbaizhan.tyut.exam.sys.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.alibaba.fastjson.JSON;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.Tools;
import cn.itbaizhan.tyut.exam.model.Sysuser;

/**
 * 统计数据处理Servlet
 * 提供考试成绩统计功能
 */
public class StatisticsServlet extends HttpServlet {
    
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String cmd = request.getParameter("cmd");
        if (cmd == null) {
            cmd = "default";
        }
        
        switch (cmd) {
            case "teacherStats":
                // 老师查看考试成绩分布
                showTeacherStats(request, response);
                break;
            case "studentStats":
                // 学生查看个人成绩分布
                showStudentStats(request, response);
                break;
            case "getTeacherData":
                // 获取老师统计数据（AJAX请求）
                getTeacherStatsData(request, response);
                break;
            case "getStudentData":
                // 获取学生统计数据（AJAX请求）
                getStudentStatsData(request, response);
                break;
            default:
                // 默认显示统计页面
                showDefaultStats(request, response);
                break;
        }
    }
    
    /**
     * 显示默认统计页面
     */
    private void showDefaultStats(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取当前用户角色
        Sysuser user = (Sysuser) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(Tools.Basepath(request, response) + "login.jsp");
            return;
        }
        
        // 根据角色显示不同的统计页面
        if (user.getRoleid() == 1) { // 学生
            showStudentStats(request, response);
        } else { // 老师或管理员
            showTeacherStats(request, response);
        }
    }
    
    /**
     * 显示老师统计页面
     */
    private void showTeacherStats(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取所有试卷名称
        DBUnitHelper dbHelper = DBUnitHelper.getInstance();
        String sql = "SELECT DISTINCT pname FROM paper_user ORDER BY pname";
        List<Map<String, Object>> papers = dbHelper.executeRawQuery(sql);
        
        request.setAttribute("papers", papers);
        request.getRequestDispatcher("/sys/statistics/teacher_stats.jsp").forward(request, response);
    }
    
    /**
     * 显示学生统计页面
     */
    private void showStudentStats(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取当前用户ID
        Integer userid = (Integer) request.getSession().getAttribute("userid");
        if (userid == null) {
            response.sendRedirect(Tools.Basepath(request, response) + "login.jsp");
            return;
        }
        
        request.getRequestDispatcher("/user/statistics/student_stats.jsp").forward(request, response);
    }
    
    /**
     * 获取老师统计数据（JSON格式）
     */
    private void getTeacherStatsData(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取试卷名称参数
        String pname = request.getParameter("pname");
        if (pname == null || pname.trim().isEmpty()) {
            outputErrorJson(response, "试卷名称不能为空");
            return;
        }
        
        try {
            // 使用与学生统计相同的直接数据库连接方式
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            Connection conn = dbHelper.getConn();
            
            if (conn != null && !conn.isClosed()) {
            // 定义分数区间
            int[] scoreRanges = {0, 60, 70, 80, 90, 100};
            String[] rangeLabels = {"不及格(<60)", "及格(60-69)", "良好(70-79)", "优秀(80-89)", "优秀(90-100)"};
            
            // 统计每个分数区间的人数
            List<Integer> counts = new ArrayList<>();
                
            for (int i = 0; i < scoreRanges.length - 1; i++) {
                    String countSql;
                    PreparedStatement pstmt;
                
                if (i == scoreRanges.length - 2) { // 最后一个区间需要包含上限值
                    countSql = "SELECT COUNT(*) as count FROM paper_user WHERE pname = ? AND percent_score >= ? AND percent_score <= ?";
                        pstmt = conn.prepareStatement(countSql);
                        pstmt.setString(1, pname);
                        pstmt.setInt(2, scoreRanges[i]);
                        pstmt.setInt(3, scoreRanges[i+1]);
                    } else {
                        countSql = "SELECT COUNT(*) as count FROM paper_user WHERE pname = ? AND percent_score >= ? AND percent_score < ?";
                        pstmt = conn.prepareStatement(countSql);
                        pstmt.setString(1, pname);
                        pstmt.setInt(2, scoreRanges[i]);
                        pstmt.setInt(3, scoreRanges[i+1]);
                    }
                    
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        counts.add(rs.getInt("count"));
                } else {
                    counts.add(0);
                }
                    
                    rs.close();
                    pstmt.close();
            }
                
                // 关闭连接
                conn.close();
            
            // 构建返回数据
            Map<String, Object> data = new HashMap<>();
            data.put("labels", rangeLabels);
            data.put("counts", counts);
            
            // 返回JSON数据
            response.setContentType("application/json;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.print(JSON.toJSONString(data));
            out.flush();
            out.close();
            } else {
                outputErrorJson(response, "数据库连接失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            outputErrorJson(response, "获取统计数据失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取学生统计数据（JSON格式）
     */
    private void getStudentStatsData(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取当前用户ID
        Integer userid = (Integer) request.getSession().getAttribute("userid");
        if (userid == null) {
            outputErrorJson(response, "用户未登录");
            return;
        }
        
        try {
            // 使用与test.jsp相同的直接数据库连接方式
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            Connection conn = dbHelper.getConn();
            
            if (conn != null && !conn.isClosed()) {
                // 直接执行SQL查询paper_user表
                String sql = "SELECT pname, percent_score FROM paper_user WHERE userid = ? ORDER BY id";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userid);
                ResultSet rs = pstmt.executeQuery();
            
            // 提取试卷名称和分数
            List<String> pnames = new ArrayList<>();
            List<Double> scores = new ArrayList<>();
            
                while (rs.next()) {
                    String pname = rs.getString("pname");
                    Double score = rs.getDouble("percent_score");
                    pnames.add(pname);
                    scores.add(score);
                }
                
                // 关闭资源
                rs.close();
                pstmt.close();
                conn.close();
            
            // 构建返回数据
            Map<String, Object> data = new HashMap<>();
            data.put("labels", pnames);
            data.put("scores", scores);
            
            // 返回JSON数据
            response.setContentType("application/json;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.print(JSON.toJSONString(data));
            out.flush();
            out.close();
            } else {
                outputErrorJson(response, "数据库连接失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            outputErrorJson(response, "获取统计数据失败：" + e.getMessage());
        }
    }
    
    /**
     * 输出错误信息（JSON格式）
     */
    private void outputErrorJson(HttpServletResponse response, String errorMsg) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("error", true);
        errorData.put("message", errorMsg);
        
        response.setContentType("application/json;charset=utf-8");
        PrintWriter out = response.getWriter();
        out.print(JSON.toJSONString(errorData));
        out.flush();
        out.close();
    }
} 