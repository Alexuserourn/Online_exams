-- 更新subject表结构，添加缺失的字段
-- 用于修复题目添加功能中除单选题外其他题型选项无法保存的问题

USE exam;

-- 添加新字段到subject表
ALTER TABLE `subject` 
ADD COLUMN `stype` int(11) DEFAULT 1 COMMENT '题目类型：1-单选题，2-多选题，3-判断题，4-填空题，5-简答题',
ADD COLUMN `se` varchar(100) DEFAULT NULL COMMENT 'E选项内容（多选题用）',
ADD COLUMN `sf` varchar(100) DEFAULT NULL COMMENT 'F选项内容（多选题用）',
ADD COLUMN `standard_answer` varchar(500) DEFAULT NULL COMMENT '标准答案（填空题和简答题用）',
ADD COLUMN `score` int(11) DEFAULT 2 COMMENT '题目分值',
ADD COLUMN `analysis` text DEFAULT NULL COMMENT '题目解析';

-- 更新现有数据的默认值
UPDATE `subject` SET 
    `stype` = 1,
    `score` = 2
WHERE `stype` IS NULL;

-- 验证表结构
DESCRIBE `subject`;
