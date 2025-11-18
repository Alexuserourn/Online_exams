<%@ page language="java" import="java.util.*,cn.itbaizhan.tyut.exam.common.*,java.sql.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
    // 获取参数
    String spid = request.getParameter("spid");
    Integer userid = (Integer) session.getAttribute("userid");
    
    // 只有在提供试卷ID和用户ID时才计算分数
    if (spid != null && !spid.isEmpty() && userid != null) {
        try {
            // 首先尝试使用ScoreFixer更新分数，确保分数是最新的
            ScoreFixer.updatePaperScore(spid, userid);
            
            // 使用DBUnitHelper查询paper_user表中的得分记录
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 1. 获取试卷名称
            String pnameQuery = "SELECT pname FROM studentpaper WHERE spid = ? LIMIT 1";
            List<Map<String, Object>> pnameResults = dbHelper.executeRawQuery(pnameQuery, spid);
            String pname = null;
            if (pnameResults != null && !pnameResults.isEmpty() && pnameResults.get(0).get("pname") != null) {
                pname = pnameResults.get(0).get("pname").toString();
            }
            
            if (pname != null) {
                // 2. 查询得分记录
                String scoreQuery = "SELECT score, percent_score, remaining_questions FROM paper_user WHERE pname = ? AND userid = ?";
                List<Map<String, Object>> scoreResults = dbHelper.executeRawQuery(scoreQuery, pname, userid);
                
                if (scoreResults != null && !scoreResults.isEmpty()) {
                    Map<String, Object> scoreData = scoreResults.get(0);
                    Integer score = scoreData.get("score") != null ? ((Number)scoreData.get("score")).intValue() : 0;
                    Double percentScore = scoreData.get("percent_score") != null ? ((Number)scoreData.get("percent_score")).doubleValue() : 0.0;
                    Integer pendingQuestions = scoreData.get("remaining_questions") != null ? ((Number)scoreData.get("remaining_questions")).intValue() : 0;
                    
                    // 设置请求属性
                    request.setAttribute("paper_score", score);
                    request.setAttribute("paper_percent", percentScore);
                    request.setAttribute("paper_pending", pendingQuestions);
                }
                
                // 3. 查询试卷满分
                String totalScoreQuery = "SELECT SUM(score) as totalPossible FROM studentpaper WHERE spid = ? AND USERID = ?";
                List<Map<String, Object>> totalResults = dbHelper.executeRawQuery(totalScoreQuery, spid, userid);
                if (totalResults != null && !totalResults.isEmpty() && totalResults.get(0).get("totalPossible") != null) {
                    Integer totalPossible = ((Number)totalResults.get(0).get("totalPossible")).intValue();
                    request.setAttribute("paper_total", totalPossible);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<c:if test="${paper_score != null && paper_total != null}">
    <div class="score-info panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">得分情况</h3>
        </div>
        <div class="panel-body">
            <c:choose>
                <c:when test="${paper_pending > 0}">
                    <!-- 有未评分题目 -->
                    <div class="alert alert-warning">
                        <strong>当前得分：${paper_score} 分 (满分 ${paper_total} 分)</strong><br>
                        <span>注意：您有 ${paper_pending} 道简答题尚未评分，最终成绩可能会变化。</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- 所有题目已评分 -->
                    <div class="alert alert-success">
                        <strong>最终得分：${paper_score} 分 (满分 ${paper_total} 分)</strong><br>
                        <span>正确率：<fmt:formatNumber value="${paper_percent}" pattern="#.##" />%</span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</c:if> 