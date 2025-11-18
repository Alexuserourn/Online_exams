package cn.itbaizhan.tyut.exam.sys.dao.impl;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.Studentpaper;
import cn.itbaizhan.tyut.exam.model.Subject;

import cn.itbaizhan.tyut.exam.sys.dao.interfaces.IStudentpaperDao;
//学生试卷
public class StudentpaperDao implements IStudentpaperDao {
	// 使用单例模式
	private DBUnitHelper dbHelper;
	
	// 构造函数
	public StudentpaperDao() {
		// 从单例获取DBUnitHelper实例
		dbHelper = DBUnitHelper.getInstance();
	}

	public Pager<Subject> list(Studentpaper studentpaper,PageControl pc) {
		String sql = "SELECT subject.sid, subject.scontent, subject.sa, subject.sb, subject.sc, subject.sd, " +
				"subject.se, subject.sf, subject.skey, subject.stype, subject.score, " +
				"subject.standard_answer AS standardAnswer, subject.analysis, " +
				"studentpaper.studentkey, studentpaper.manual_score AS manualScore, " +
				"studentpaper.is_graded AS isGraded, studentpaper.comment " +
				"FROM studentpaper, subject " +
				"WHERE studentstate=0 AND subject.sid=studentpaper.sid " +
				"AND studentpaper.USERID = ? AND spid = ?";
		String sid="sid";
		Pager<Subject> pager;
		pager = dbHelper.execlist(sql, pc, Subject.class, sid,studentpaper.getUserid(),studentpaper.getSpid());	
		return pager;
	}

	@Override
	public Integer addPaper(Studentpaper studentpaper) {
		// 更新SQL，添加新字段
		String sql = "insert into studentpaper (spid, userid, sid, studentkey, studentstate, pname, stype, score, manual_score, is_graded) values(?,?,?,?,?,?,?,?,?,?)";
		Integer rtn = dbHelper.executeUpdate(sql, 
				studentpaper.getSpid(),
				studentpaper.getUserid(),
				studentpaper.getSid(),
				studentpaper.getStudentkey(),
				studentpaper.getStudentstate(),
				studentpaper.getPname(),
				studentpaper.getStype(),
				studentpaper.getScore(),
				studentpaper.getManualScore(),
				studentpaper.getIsGraded() == null ? 0 : studentpaper.getIsGraded()
		);
		return rtn;
	}

	@Override
	public List<Studentpaper> listByRightcount(Studentpaper studentpaper) {
		String sql = "SELECT COUNT(*) rightcount FROM studentpaper where studentstate=1 AND studentpaper.USERID = ? AND spid = ?";
		List<Studentpaper> list = dbHelper.executeQuery(sql,Studentpaper.class,studentpaper.getUserid(),studentpaper.getSpid());
		return list;
	}
	public List<Studentpaper> StudentPaperList(Studentpaper studentpaper) {
		String sql = "SELECT spid,userid,pname,count(if(studentstate=1,true,null)) AS rightcount,count(if(studentstate=0,true,null)) AS errorcount FROM studentpaper where userid = ? GROUP BY spid,pname ;";
		List<Studentpaper> list = dbHelper.executeQuery(sql,Studentpaper.class,studentpaper.getUserid());
		return list;
	}
	
	@Override
	public Pager<Subject> listAllDistinctErrors(Integer userid, Integer stype, String keyword, PageControl pc) {
		// 基础SQL查询 - 修复查询语句，确保正确获取错题且不显示重复题目
		StringBuilder sqlBuilder = new StringBuilder();
		sqlBuilder.append("SELECT DISTINCT s.sid, s.scontent, s.sa, s.sb, s.sc, s.sd, s.se, s.sf, ")
				.append("s.skey, s.stype, s.score, s.standard_answer AS standardAnswer, s.analysis, ")
				.append("MAX(sp.studentkey) AS studentkey ")
				.append("FROM studentpaper sp ")
				.append("INNER JOIN subject s ON sp.sid = s.sid ")
				.append("WHERE sp.studentstate = 0 AND s.sstate = 1 AND sp.userid = ? ");
		
		// 添加题型筛选条件
		if (stype != null) {
			sqlBuilder.append("AND s.stype = ? ");
		}
		
		// 添加关键字搜索条件
		if (keyword != null && !keyword.isEmpty()) {
			sqlBuilder.append("AND s.scontent LIKE ? ");
		}
		
		// 添加GROUP BY确保每个题目只出现一次
		sqlBuilder.append("GROUP BY s.sid ")
				.append("ORDER BY s.sid");
		
		String sql = sqlBuilder.toString();
		String sid = "sid";
		Pager<Subject> pager;
		
		// 根据条件确定查询参数
		if (stype != null && keyword != null && !keyword.isEmpty()) {
			// 有题型筛选和关键字搜索
			pager = dbHelper.execlist(sql, pc, Subject.class, sid, userid, stype, "%" + keyword + "%");
		} else if (stype != null) {
			// 只有题型筛选
			pager = dbHelper.execlist(sql, pc, Subject.class, sid, userid, stype);
		} else if (keyword != null && !keyword.isEmpty()) {
			// 只有关键字搜索
			pager = dbHelper.execlist(sql, pc, Subject.class, sid, userid, "%" + keyword + "%");
		} else {
			// 无筛选条件
			pager = dbHelper.execlist(sql, pc, Subject.class, sid, userid);
		}
		
		return pager;
	}
	
	/**
	 * 查询特定试卷中的简答题列表（用于评分）
	 * @param paperid 试卷ID
	 * @param pc 分页控制
	 * @return 简答题分页对象
	 */
	public Pager<Studentpaper> listEssays(Integer paperid, PageControl pc) {
		String sql = "SELECT sp.*, s.scontent, s.skey, s.stype, s.score, u.usertruename as studentName " +
				"FROM studentpaper sp " +
				"INNER JOIN subject s ON sp.sid = s.sid " +
				"INNER JOIN sysuser u ON sp.userid = u.userid " +
				"WHERE sp.spid = ? AND s.stype = 5 " +  // 5表示简答题
				"ORDER BY sp.spid";
		String sid = "spid";
		Pager<Studentpaper> pager;
		pager = dbHelper.execlist(sql, pc, Studentpaper.class, sid, paperid);
		return pager;
	}
}