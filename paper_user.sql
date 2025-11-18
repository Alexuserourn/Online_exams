-- 创建paper_user表，用于存储学生试卷分数记录
CREATE TABLE IF NOT EXISTS paper_user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pname VARCHAR(100) NOT NULL COMMENT '试卷名称',
  userid INT NOT NULL COMMENT '学生ID',
  score INT DEFAULT 0 COMMENT '得分',
  percent_score DECIMAL(5,2) DEFAULT 0 COMMENT '百分比分数',
  remaining_questions INT DEFAULT 0 COMMENT '剩余未评分题目数',
  KEY idx_userid (userid),
  KEY idx_pname (pname),
  UNIQUE KEY uniq_pname_userid (pname, userid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生试卷得分记录表';

-- 初始化数据：从已有的studentpaper表中计算得分并插入到paper_user表
INSERT IGNORE INTO paper_user (pname, userid, score, percent_score, remaining_questions)
SELECT 
  sp.pname,
  sp.USERID,
  -- 计算总分：客观题正确得分 + 简答题已评分得分
  SUM(CASE 
      WHEN sp.stype = 5 AND sp.is_graded = 1 THEN sp.manual_score 
      WHEN sp.stype != 5 AND sp.studentstate = 1 THEN sp.score 
      ELSE 0 
  END) AS score,
  -- 计算百分比
  (SUM(CASE 
      WHEN sp.stype = 5 AND sp.is_graded = 1 THEN sp.manual_score 
      WHEN sp.stype != 5 AND sp.studentstate = 1 THEN sp.score 
      ELSE 0 
  END) * 100.0 / SUM(sp.score)) AS percent_score,
  -- 剩余未评分题目
  SUM(CASE WHEN sp.stype = 5 AND (sp.is_graded = 0 OR sp.is_graded IS NULL) THEN 1 ELSE 0 END) AS remaining_questions
FROM 
  studentpaper sp
GROUP BY 
  sp.pname, sp.USERID;

-- 修复studentpaper表中的已评分简答题状态
-- 将已评分且得分大于0的简答题标记为部分正确(2)，得分为0的标记为错误(0)
UPDATE studentpaper 
SET studentstate = CASE WHEN manual_score > 0 THEN 2 ELSE 0 END
WHERE stype = 5 AND is_graded = 1; 