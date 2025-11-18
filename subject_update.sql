-- 更新subject表，添加新字段
ALTER TABLE `subject`
ADD COLUMN `stype` INT DEFAULT 1 COMMENT '题目类型：1-单选题，2-多选题，3-判断题，4-填空题，5-简答题',
ADD COLUMN `se` VARCHAR(100) DEFAULT NULL COMMENT '选项E（用于多选题）',
ADD COLUMN `sf` VARCHAR(100) DEFAULT NULL COMMENT '选项F（用于多选题）',
ADD COLUMN `standard_answer` TEXT DEFAULT NULL COMMENT '标准答案（用于填空题和简答题）',
ADD COLUMN `score` INT DEFAULT 2 COMMENT '题目分值',
ADD COLUMN `analysis` TEXT DEFAULT NULL COMMENT '题目解析';

-- 更新studentpaper表，添加新字段
ALTER TABLE `studentpaper`
ADD COLUMN `manual_score` INT DEFAULT NULL COMMENT '人工评分',
ADD COLUMN `is_graded` INT DEFAULT 0 COMMENT '是否已评分：0-未评分，1-已评分',
ADD COLUMN `stype` INT DEFAULT 1 COMMENT '题目类型，冗余字段，便于查询',
ADD COLUMN `score` INT DEFAULT 2 COMMENT '题目分值，冗余字段，便于计算总分';

-- 更新现有题目为单选题
UPDATE `subject` SET `stype` = 1, `score` = 2 WHERE `stype` IS NULL;

-- 添加示例多选题
INSERT INTO `subject` (`scontent`, `sa`, `sb`, `sc`, `sd`, `se`, `sf`, `skey`, `sstate`, `stype`, `score`, `analysis`)
VALUES 
('以下哪些是Java的基本数据类型？', 'int', 'String', 'boolean', 'char', 'float', 'Object', 'ADE', 1, 2, 3, '基本数据类型包括byte、short、int、long、float、double、boolean和char，而String和Object是引用类型。');

-- 添加示例判断题
INSERT INTO `subject` (`scontent`, `sa`, `sb`, `sc`, `sd`, `skey`, `sstate`, `stype`, `score`, `analysis`)
VALUES 
('Java是一种解释型语言。', '正确', '错误', '', '', 'A', 1, 3, 2, 'Java既是编译型语言又是解释型语言。Java源代码先被编译成字节码，然后由JVM解释执行。');

-- 添加示例填空题
INSERT INTO `subject` (`scontent`, `sa`, `sb`, `sc`, `sd`, `skey`, `sstate`, `stype`, `score`, `standard_answer`, `analysis`)
VALUES 
('Java中用于定义常量的关键字是_______。', '', '', '', '', '', 1, 4, 2, 'final', 'Java中使用final关键字定义常量，如：final int MAX_VALUE = 100;');

-- 添加示例简答题
INSERT INTO `subject` (`scontent`, `sa`, `sb`, `sc`, `sd`, `skey`, `sstate`, `stype`, `score`, `standard_answer`, `analysis`)
VALUES 
('简述Java中的多态性及其实现方式。', '', '', '', '', '', 1, 5, 5, '多态是指同一个行为具有多个不同表现形式的能力。在Java中，多态性通过方法重写（override）和方法重载（overload）来实现。\n\n方法重写是指子类重新定义父类的方法，要求方法名、参数列表和返回类型相同。\n\n方法重载是指在同一个类中定义多个同名的方法，但要求参数列表不同，与返回类型无关。\n\n多态的实现需要满足三个条件：继承、重写和父类引用指向子类对象。', '多态是面向对象编程的三大特性之一，其他两个是封装和继承。多态提高了代码的灵活性和可扩展性。'); 