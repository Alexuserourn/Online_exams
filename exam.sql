/*
SQLyog Ultimate v12.3.1 (64 bit)
MySQL - 5.7.31-log : Database - exam
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`exam` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `exam`;

/*Table structure for table `paper` */

DROP TABLE IF EXISTS `paper`;

CREATE TABLE `paper` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `pname` varchar(11) NOT NULL,
  `sid` int(11) NOT NULL,
  PRIMARY KEY (`pid`),
  KEY `sid` (`sid`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8;

/*Data for the table `paper` */

insert  into `paper`(`pid`,`pname`,`sid`) values 
(42,'期中',3),
(43,'期中',4),
(44,'期中',2),
(45,'期中',7),
(46,'期中',6);

/*Table structure for table `roleright` */

DROP TABLE IF EXISTS `roleright`;

CREATE TABLE `roleright` (
  `RRID` int(11) NOT NULL AUTO_INCREMENT,
  `FUNID` int(11) DEFAULT NULL,
  `ROLEID` int(11) DEFAULT NULL,
  PRIMARY KEY (`RRID`),
  KEY `FK_Relationship_1` (`FUNID`),
  KEY `FK_Relationship_2` (`ROLEID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=gbk;

/*Data for the table `roleright` */

insert  into `roleright`(`RRID`,`FUNID`,`ROLEID`) values 
(3,1,-1),
(4,5,-1),
(5,6,-1),
(6,7,-1),
(7,5,2),
(8,6,2),
(9,7,2);

/*Table structure for table `studentpaper` */

DROP TABLE IF EXISTS `studentpaper`;

CREATE TABLE `studentpaper` (
  `spid` varchar(15) NOT NULL,
  `USERID` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `studentkey` varchar(10) DEFAULT NULL,
  `studentstate` int(11) NOT NULL,
  `pname` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `studentpaper` */

insert  into `studentpaper`(`spid`,`USERID`,`sid`,`studentkey`,`studentstate`,`pname`) values 
('1689857671230',3,2,'B',0,'期中'),
('1689857671230',3,6,'B',1,'期中'),
('1689857671230',3,7,'B',0,'期中'),
('1689857671230',3,3,'B',0,'期中'),
('1689857671230',3,4,'B',1,'期中');

/*Table structure for table `subject` */

DROP TABLE IF EXISTS `subject`;

CREATE TABLE `subject` (
  `sid` int(11) NOT NULL AUTO_INCREMENT,
  `scontent` varchar(150) NOT NULL,
  `sa` varchar(100) NOT NULL,
  `sb` varchar(100) NOT NULL,
  `sc` varchar(100) NOT NULL,
  `sd` varchar(100) NOT NULL,
  `skey` varchar(10) NOT NULL,
  `sstate` int(11) NOT NULL,
  PRIMARY KEY (`sid`),
  UNIQUE KEY `scontent` (`scontent`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

/*Data for the table `subject` */

insert  into `subject`(`sid`,`scontent`,`sa`,`sb`,`sc`,`sd`,`skey`,`sstate`) values 
(1,'软件测试的目的是(___)','试验性运行软件','发现软件错误','证明软件正确','找出软件中全部错误','B',0),
(2,'在一个长度为n的顺序表的表尾插入一个新元素的渐进时间复杂度为','O (n)','O (1)','O (n2 )','O (log2 n)','A',1),
(3,'计算机系统中的存贮器系统是指','RAM存贮器','ROM存贮器','主存贮器','cache、主存贮器和外存贮器','D',1),
(4,'某机字长32位，其中1位符号位，31位表示尾数。若用定点小数表示，则最大正小数为','+（1 – 2-32）','+（1 – 2-31）','2-32','2-31','B',1),
(5,'算术 / 逻辑运算单元74181ALU可完成','16种算术运算功能','16种逻辑运算功能','16种算术运算功能和16种逻辑运算功能','4位乘法运算和除法运算功能','C',1),
(6,'存储单元是指','存放一个二进制信息位的存贮元','存放一个机器字的所有存贮元集合','存放一个字节的所有存贮元集合','存放两个字节的所有存贮元集合；','B',1),
(7,'相联存贮器是按______进行寻址的存贮器。','地址方式','堆栈方式','内容指定方式','地址方式与堆栈方式','C',1),
(8,'变址寻址方式中，操作数的有效地址等于______。','基值寄存器内容加上形式地址（位移量）','堆栈指示器内容加上形式地址（位移量）','变址寄存器内容加上形式地址（位移量）','程序记数器内容加上形式地址（位移量）','C',1),
(10,'会飞的速发货','A.随机地选取测试数据','B.取一切可能的输入数据作为测试数据','C.如图','D.选择发现错误可能性最大的数据作为测试用例','D',0);

/*Table structure for table `sysfunction` */

DROP TABLE IF EXISTS `sysfunction`;

CREATE TABLE `sysfunction` (
  `FUNID` int(11) NOT NULL AUTO_INCREMENT,
  `FUNNAME` varchar(20) DEFAULT NULL,
  `FUNURL` varchar(200) DEFAULT NULL,
  `FUNPID` int(11) DEFAULT NULL,
  `FUNSTATE` int(11) DEFAULT NULL,
  PRIMARY KEY (`FUNID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=gbk;

/*Data for the table `sysfunction` */

insert  into `sysfunction`(`FUNID`,`FUNNAME`,`FUNURL`,`FUNPID`,`FUNSTATE`) values 
(1,'系统功能',NULL,-1,1),
(3,'用户管理','sys/user?cmd=list',1,1),
(4,'角色管理','sys/role?cmd=list',1,1),
(5,'试题管理',NULL,-1,1),
(6,'题目管理','sys/subject?cmd=list',5,1),
(7,'试卷管理','sys/paper?cmd=list',5,1);

/*Table structure for table `sysrole` */

DROP TABLE IF EXISTS `sysrole`;

CREATE TABLE `sysrole` (
  `ROLEID` int(11) NOT NULL AUTO_INCREMENT,
  `ROLENAME` varchar(20) DEFAULT NULL,
  `ROLESTATE` int(11) DEFAULT NULL,
  `ROLEDESC` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`ROLEID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=gbk;

/*Data for the table `sysrole` */

insert  into `sysrole`(`ROLEID`,`ROLENAME`,`ROLESTATE`,`ROLEDESC`) values 
(-1,'超级管理员',1,'超级管理员'),
(1,'学生',1,'学生'),
(2,'试题管理员',1,'管理是试题与试卷');

/*Table structure for table `sysuser` */

DROP TABLE IF EXISTS `sysuser`;

CREATE TABLE `sysuser` (
  `USERID` int(11) NOT NULL AUTO_INCREMENT,
  `ROLEID` int(11) DEFAULT NULL,
  `USERNAME` varchar(20) DEFAULT NULL,
  `USERPWD` char(20) DEFAULT NULL,
  `USERTRUENAME` varchar(30) DEFAULT NULL,
  `USERSTATE` int(11) DEFAULT NULL,
  PRIMARY KEY (`USERID`),
  UNIQUE KEY `USERNAME` (`USERNAME`),
  KEY `FK_Relationship_3` (`ROLEID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=gbk;

/*Data for the table `sysuser` */

insert  into `sysuser`(`USERID`,`ROLEID`,`USERNAME`,`USERPWD`,`USERTRUENAME`,`USERSTATE`) values 
(2,-1,'admin','123456','管理员',1),
(3,1,'zs','11111','张三丰',1),
(4,2,'ls','12345','李四',1),
(5,1,'ww','12345','王五',1);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
