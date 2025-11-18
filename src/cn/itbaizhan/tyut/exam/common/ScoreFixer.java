package cn.itbaizhan.tyut.exam.common;

import java.util.List;
import java.util.Map;

/**
 * 分数修复工具类
 * 用于修复和更新studentpaper表中的分数
 */
public class ScoreFixer {

    /**
     * 更新试卷总分
     * @param spid 试卷ID
     * @param userid 学生ID
     * @return 成功返回true，失败返回false
     */
    public static boolean updatePaperScore(String spid, Integer userid) {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            System.out.println("开始更新分数 - 试卷ID: " + spid + ", 用户ID: " + userid);
            
            // 1. 查询该试卷所有题目的详细信息，确保获取所有必要字段
            String detailQuery = "SELECT sid, stype, score, studentstate, manual_score, is_graded FROM studentpaper WHERE spid = ? AND USERID = ?";
            List<Map<String, Object>> questions = dbHelper.executeRawQuery(detailQuery, spid, userid);
            
            if (questions == null || questions.isEmpty()) {
                System.out.println("没有找到试卷记录: " + spid + ", 用户ID: " + userid);
                return false;
            }
            
            System.out.println("题目数量: " + questions.size());
            
            // 2. 手动计算总分
            int totalScore = 0;
            int totalPossible = 0;
            int pendingGrading = 0;
            
            for (Map<String, Object> item : questions) {
                Integer stype = item.get("stype") != null ? ((Number)item.get("stype")).intValue() : 1;
                Integer score = item.get("score") != null ? ((Number)item.get("score")).intValue() : 0;
                Integer studentstate = item.get("studentstate") != null ? ((Number)item.get("studentstate")).intValue() : 0;
                Integer manualScore = item.get("manual_score") != null ? ((Number)item.get("manual_score")).intValue() : 0;
                Integer isGraded = item.get("is_graded") != null ? ((Number)item.get("is_graded")).intValue() : 0;
                
                // 调试输出
                System.out.println("题目详情 - 类型: " + stype + ", 分值: " + score + 
                                  ", 答题状态: " + studentstate + ", 人工评分: " + manualScore + 
                                  ", 是否已评分: " + isGraded);
                
                // 累加总分值
                if (score != null && score > 0) {
                    totalPossible += score;
                    System.out.println("累加总分值: " + totalPossible);
                }
                
                // 根据题型和状态计算得分
                if (stype == 5) { // 简答题
                    if (isGraded != null && isGraded == 1) {
                        // 简答题已评分，无论状态如何都使用人工评分分数
                        totalScore += (manualScore != null ? manualScore : 0);
                        System.out.println("简答题已评分，得分: " + manualScore + ", 累计得分: " + totalScore);
                    } else {
                        pendingGrading++;
                        System.out.println("简答题未评分");
                    }
                } else { // 客观题
                    if (studentstate != null && studentstate == 1) {
                        totalScore += (score != null ? score : 0);
                        System.out.println("客观题正确，得分: " + score + ", 累计得分: " + totalScore);
                    } else if (studentstate != null && studentstate == 2) { // 部分正确
                        // 部分正确的题目，使用人工评分分数
                        totalScore += (manualScore != null && manualScore > 0 ? manualScore : 0);
                        System.out.println("客观题部分正确，得分: " + manualScore + ", 累计得分: " + totalScore);
                    } else {
                        System.out.println("客观题错误，得分: 0");
                    }
                }
            }
            
            // 确保数据有效
            if (totalPossible <= 0) {
                System.out.println("警告：试卷总分值为0或负数，检查是否存在数据问题");
                
                // 获取试卷总分
                String scoreSql = "SELECT SUM(score) as total FROM studentpaper WHERE spid = ? AND USERID = ?";
                List<Map<String, Object>> scoreResult = dbHelper.executeRawQuery(scoreSql, spid, userid);
                if (scoreResult != null && !scoreResult.isEmpty() && scoreResult.get(0).get("total") != null) {
                    totalPossible = ((Number)scoreResult.get(0).get("total")).intValue();
                    System.out.println("从数据库获取的试卷总分: " + totalPossible);
                } 
                
                // 如果仍然为0，设置默认值
                if (totalPossible <= 0) {
                    totalPossible = 100; // 设置一个默认值，避免除以零的错误
                }
            }
            
            // 计算百分比得分
            double percentScore = (double) totalScore / totalPossible * 100;
            
            System.out.println("计算结果 - 总得分: " + totalScore + "/" + totalPossible + 
                              ", 百分比: " + percentScore + "%, 未评分题数: " + pendingGrading);
            
            // 3. 确保paper_user表存在
            ensurePaperUserTable();
            
            // 4. 更新学生的试卷记录
            try {
                // 先查询试卷名称
                String pnameQuery = "SELECT pname FROM studentpaper WHERE spid = ? LIMIT 1";
                List<Map<String, Object>> pnameResults = dbHelper.executeRawQuery(pnameQuery, spid);
                String pname = null;
                if (pnameResults != null && !pnameResults.isEmpty() && pnameResults.get(0).get("pname") != null) {
                    pname = pnameResults.get(0).get("pname").toString();
                    System.out.println("找到试卷名称: " + pname);
                } else {
                    System.out.println("错误：未找到试卷名称，无法更新分数记录");
                    return false;
                }
                
                // 检查是否已有记录 - 使用spid和userid作为唯一标识
                String checkRecordSql = "SELECT id FROM paper_user WHERE spid = ? AND userid = ?";
                System.out.println("检查paper_user记录SQL: " + checkRecordSql + ", 参数: spid=" + spid + ", userid=" + userid);
                List<Map<String, Object>> existingRecord = dbHelper.executeRawQuery(checkRecordSql, spid, userid);
                System.out.println("检查结果: " + (existingRecord != null && !existingRecord.isEmpty() ? "记录存在" : "记录不存在"));
                
                if (existingRecord != null && !existingRecord.isEmpty()) {
                    // 记录存在，更新
                    String updateScoreSql = "UPDATE paper_user SET pname = ?, score = ?, percent_score = ?, remaining_questions = ?, update_time = NOW() " +
                                         "WHERE spid = ? AND userid = ?";
                    System.out.println("更新paper_user记录SQL: " + updateScoreSql);
                    System.out.println("参数: pname=" + pname + ", score=" + totalScore + ", percent_score=" + percentScore + 
                                      ", remaining_questions=" + pendingGrading + ", spid=" + spid + ", userid=" + userid);
                    int result = dbHelper.executeUpdate(updateScoreSql, pname, totalScore, percentScore, pendingGrading, spid, userid);
                    System.out.println("更新已有分数记录，受影响行数: " + result);
                    
                    // 如果更新失败（受影响行数为0），尝试删除并重新插入
                    if (result == 0) {
                        System.out.println("更新失败，尝试删除并重新插入记录");
                        String deleteSql = "DELETE FROM paper_user WHERE spid = ? AND userid = ?";
                        dbHelper.executeUpdate(deleteSql, spid, userid);
                        
                        String insertSql = "INSERT INTO paper_user (spid, pname, userid, score, percent_score, remaining_questions) VALUES (?, ?, ?, ?, ?, ?)";
                        int insertResult = dbHelper.executeUpdate(insertSql, spid, pname, userid, totalScore, percentScore, pendingGrading);
                        System.out.println("删除后重新插入记录，受影响行数: " + insertResult);
                    }
                } else {
                    // 记录不存在，创建新记录
                    String insertSql = "INSERT INTO paper_user (spid, pname, userid, score, percent_score, remaining_questions) VALUES (?, ?, ?, ?, ?, ?)";
                    System.out.println("插入paper_user记录SQL: " + insertSql);
                    System.out.println("参数: spid=" + spid + ", pname=" + pname + ", userid=" + userid + ", score=" + totalScore + 
                                      ", percent_score=" + percentScore + ", remaining_questions=" + pendingGrading);
                    int result = dbHelper.executeUpdate(insertSql, spid, pname, userid, totalScore, percentScore, pendingGrading);
                    System.out.println("创建新分数记录，受影响行数: " + result);
                }
                
                System.out.println("已更新paper_user表 - 试卷ID: " + spid + ", 试卷名称: " + pname + ", 用户ID: " + userid);
            } catch (Exception ex) {
                System.out.println("更新分数记录失败: " + ex.getMessage());
                ex.printStackTrace();
                return false;
            }
            
            System.out.println("已完成试卷 " + spid + " 学生ID " + userid + " 的分数更新：" + totalScore + "/" + totalPossible + " 分");
            return true;
        } catch (Exception e) {
            System.err.println("更新试卷得分时出错：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 更新所有学生的所有试卷分数
     * @return 更新的记录数
     */
    public static int updateAllScores() {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 确保paper_user表存在
            ensurePaperUserTable();
            
            // 1. 获取所有不同的spid和userid组合，但只获取那些没有对应paper_user记录的
            String query = "SELECT DISTINCT sp.spid, sp.USERID " +
                         "FROM studentpaper sp " +
                         "LEFT JOIN paper_user pu ON sp.spid = pu.spid AND sp.USERID = pu.userid " +
                         "WHERE pu.id IS NULL " +
                         "ORDER BY sp.spid, sp.USERID";
                         
            List<Map<String, Object>> results = dbHelper.executeRawQuery(query);
            
            if (results == null || results.isEmpty()) {
                System.out.println("没有找到需要更新的试卷记录");
                return 0;
            }
            
            System.out.println("找到 " + results.size() + " 条学生试卷记录需要更新");
            
            // 2. 遍历每条记录并更新
            int successCount = 0;
            for (Map<String, Object> record : results) {
                String spid = (String) record.get("spid");
                Integer userid = ((Number) record.get("USERID")).intValue();
                
                if (updatePaperScore(spid, userid)) {
                    successCount++;
                }
            }
            
            System.out.println("成功更新 " + successCount + " 条记录");
            return successCount;
        } catch (Exception e) {
            System.err.println("批量更新分数时出错：" + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * 确保paper_user表存在
     */
    private static void ensurePaperUserTable() {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 检查paper_user表是否存在
            String checkTableSql = "SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'paper_user'";
            List<Map<String, Object>> tableExists = dbHelper.executeRawQuery(checkTableSql);
            
            if (tableExists == null || tableExists.isEmpty()) {
                // 表不存在，创建表
                String createTableSql = 
                    "CREATE TABLE paper_user (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  spid VARCHAR(100) NOT NULL COMMENT '试卷ID'," +
                    "  pname VARCHAR(100) NOT NULL COMMENT '试卷名称'," +
                    "  userid INT NOT NULL COMMENT '学生ID'," +
                    "  score INT DEFAULT 0 COMMENT '得分'," +
                    "  percent_score DECIMAL(5,2) DEFAULT 0 COMMENT '百分比分数'," +
                    "  remaining_questions INT DEFAULT 0 COMMENT '剩余未评分题目数'," +
                    "  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'," +
                    "  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'," +
                    "  KEY idx_userid (userid)," +
                    "  KEY idx_pname (pname)," +
                    "  KEY idx_spid (spid)," +
                    "  UNIQUE KEY uniq_spid_userid (spid, userid)" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生试卷得分记录表'";
                
                System.out.println("创建paper_user表SQL: " + createTableSql);
                dbHelper.executeUpdate(createTableSql);
                System.out.println("已创建paper_user表");
                
                // 初始化数据
                initializeScoreData();
            } else {
                // 检查是否需要修改表结构，增加spid列
                String checkColumnSql = "SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'paper_user' AND column_name = 'spid'";
                List<Map<String, Object>> columnExists = dbHelper.executeRawQuery(checkColumnSql);
                
                if (columnExists == null || columnExists.isEmpty()) {
                    // 需要添加spid列
                    String alterTableSql = "ALTER TABLE paper_user " +
                                          "ADD COLUMN spid VARCHAR(100) COMMENT '试卷ID' AFTER id, " +
                                          "ADD KEY idx_spid (spid), " +
                                          "DROP INDEX uniq_pname_userid, " +
                                          "ADD UNIQUE KEY uniq_spid_userid (spid, userid)";
                    System.out.println("修改paper_user表结构SQL: " + alterTableSql);
                    dbHelper.executeUpdate(alterTableSql);
                    System.out.println("已更新paper_user表结构，添加spid列");
                    
                    // 更新现有数据，填充spid值
                    String updateSql = "UPDATE paper_user pu " +
                                      "JOIN (SELECT DISTINCT spid, pname, userid FROM studentpaper) sp " +
                                      "ON pu.pname = sp.pname AND pu.userid = sp.userid " +
                                      "SET pu.spid = sp.spid";
                    System.out.println("更新paper_user表现有数据SQL: " + updateSql);
                    int updatedRows = dbHelper.executeUpdate(updateSql);
                    System.out.println("已更新paper_user表现有数据，填充spid值，受影响行数: " + updatedRows);
                }
                
                // 检查是否有缺少spid值的记录
                String checkMissingSpidSql = "SELECT COUNT(*) as missing_count FROM paper_user WHERE spid IS NULL OR spid = ''";
                List<Map<String, Object>> missingSpidResult = dbHelper.executeRawQuery(checkMissingSpidSql);
                if (missingSpidResult != null && !missingSpidResult.isEmpty() && missingSpidResult.get(0).get("missing_count") != null) {
                    int missingCount = ((Number)missingSpidResult.get(0).get("missing_count")).intValue();
                    if (missingCount > 0) {
                        System.out.println("发现 " + missingCount + " 条记录缺少spid值，尝试修复");
                        
                        // 更新缺少spid的记录
                        String fixMissingSpidSql = "UPDATE paper_user pu " +
                                                "JOIN (SELECT DISTINCT spid, pname, userid FROM studentpaper) sp " +
                                                "ON pu.pname = sp.pname AND pu.userid = sp.userid " +
                                                "SET pu.spid = sp.spid " +
                                                "WHERE pu.spid IS NULL OR pu.spid = ''";
                        int fixedRows = dbHelper.executeUpdate(fixMissingSpidSql);
                        System.out.println("已修复 " + fixedRows + " 条缺少spid值的记录");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("确保paper_user表存在时出错：" + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 初始化分数数据
     */
    private static void initializeScoreData() {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 获取所有不同的spid和userid组合
            String query = "SELECT DISTINCT spid, USERID FROM studentpaper";
            List<Map<String, Object>> results = dbHelper.executeRawQuery(query);
            
            if (results == null || results.isEmpty()) {
                System.out.println("没有找到需要初始化的试卷记录");
                return;
            }
            
            System.out.println("开始初始化 " + results.size() + " 条试卷记录的分数数据...");
            
            // 逐一处理每个试卷记录
            for (Map<String, Object> record : results) {
                String spid = (String) record.get("spid");
                Integer userid = ((Number) record.get("USERID")).intValue();
                
                updatePaperScore(spid, userid);
            }
            
            System.out.println("分数数据初始化完成");
        } catch (Exception e) {
            System.err.println("初始化分数数据时出错：" + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 修复studentpaper表中的已评分简答题状态
     */
    public static void fixEssayQuestionStatus() {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 将已评分且得分大于0的简答题标记为部分正确(2)，得分为0的标记为错误(0)
            String sql = "UPDATE studentpaper " +
                       "SET studentstate = CASE WHEN manual_score > 0 THEN 2 ELSE 0 END " +
                       "WHERE stype = 5 AND is_graded = 1";
            
            int count = dbHelper.executeUpdate(sql);
            System.out.println("已修复 " + count + " 条已评分简答题的状态");
        } catch (Exception e) {
            System.err.println("修复简答题状态时出错：" + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 更新所有已评分简答题对应的成绩记录
     * @return 更新的记录数
     */
    public static int updateAllGradedEssays() {
        try {
            DBUnitHelper dbHelper = DBUnitHelper.getInstance();
            
            // 确保paper_user表存在
            ensurePaperUserTable();
            
            // 1. 获取所有包含已评分简答题的试卷
            String query = "SELECT DISTINCT sp.spid, sp.userid " +
                         "FROM studentpaper sp " +
                         "WHERE sp.stype = 5 AND sp.is_graded = 1 " +
                         "ORDER BY sp.spid, sp.userid";
                         
            List<Map<String, Object>> results = dbHelper.executeRawQuery(query);
            
            if (results == null || results.isEmpty()) {
                System.out.println("没有找到已评分的简答题记录");
                return 0;
            }
            
            System.out.println("找到 " + results.size() + " 条包含已评分简答题的试卷记录");
            
            // 2. 遍历每条记录并更新
            int successCount = 0;
            for (Map<String, Object> record : results) {
                String spid = (String) record.get("spid");
                Integer userid = ((Number) record.get("userid")).intValue();
                
                System.out.println("更新已评分简答题的试卷 - 试卷ID: " + spid + ", 用户ID: " + userid);
                if (updatePaperScore(spid, userid)) {
                    successCount++;
                }
            }
            
            System.out.println("成功更新 " + successCount + " 条包含已评分简答题的试卷记录");
            return successCount;
        } catch (Exception e) {
            System.err.println("更新已评分简答题对应的成绩记录时出错：" + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * 主方法，可直接运行修复程序
     */
    public static void main(String[] args) {
        System.out.println("开始执行分数修复程序...");
        
        // 1. 修复已评分简答题的状态
        fixEssayQuestionStatus();
        
        // 2. 更新所有已评分简答题对应的成绩记录
        int gradedEssaysCount = updateAllGradedEssays();
        System.out.println("已更新 " + gradedEssaysCount + " 条包含已评分简答题的试卷记录");
        
        // 3. 更新所有学生的所有试卷分数
        int count = updateAllScores();
        
        System.out.println("分数修复程序执行完毕，共更新 " + count + " 条记录");
    }
} 