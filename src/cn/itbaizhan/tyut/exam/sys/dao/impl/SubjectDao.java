package cn.itbaizhan.tyut.exam.sys.dao.impl;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.common.query.KeywordQueryAdapter;
import cn.itbaizhan.tyut.exam.common.query.QueryContext;
import cn.itbaizhan.tyut.exam.common.query.SimpleQueryAdapter;
import cn.itbaizhan.tyut.exam.common.query.AdapterFactory;
import cn.itbaizhan.tyut.exam.common.query.QueryAdapter;
import cn.itbaizhan.tyut.exam.model.Subject;

import cn.itbaizhan.tyut.exam.sys.dao.interfaces.ISubjectDao;

/**
 * 试题DAO实现类 - 使用单例和适配器模式
 */
public class SubjectDao implements ISubjectDao {

	// 使用单例模式
	private DBUnitHelper dbHelper;
	
	// 构造函数
	public SubjectDao() {
		// 从单例获取DBUnitHelper实例
		dbHelper = DBUnitHelper.getInstance();
	}

	public Integer addsubject(Subject subject) {
		// 更新SQL语句，支持新增字段
		String sql = "INSERT INTO SUBJECT(SCONTENT, SA, SB, SC, SD, SKEY, SSTATE, STYPE, SE, SF, STANDARD_ANSWER, SCORE, ANALYSIS)" +
				" VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		
		// 为判断题提供默认的SC和SD值，因为数据库字段是NOT NULL
		String sa = subject.getSa() != null ? subject.getSa() : "";
		String sb = subject.getSb() != null ? subject.getSb() : "";
		String sc = subject.getSc() != null ? subject.getSc() : "";
		String sd = subject.getSd() != null ? subject.getSd() : "";
		
		// 如果是判断题，为SC和SD提供默认值
		if (subject.getStype() != null && subject.getStype() == 3) {
			sc = sc.isEmpty() ? "不适用" : sc;
			sd = sd.isEmpty() ? "不适用" : sd;
		}
		
		Integer rtn = dbHelper.executeUpdate(sql, 
				subject.getScontent(),
				sa,
				sb,
				sc,
				sd,
				subject.getSkey(),
				subject.getSstate(),
				subject.getStype() == null ? 1 : subject.getStype(), // 默认为单选题
				subject.getSe(),
				subject.getSf(),
				subject.getStandardAnswer(),
				subject.getScore() == null ? 2 : subject.getScore(), // 默认2分
				subject.getAnalysis());		
		return rtn;
	}

	public Pager<Subject> list(Subject subject, PageControl pc) {
		// 更新查询语句，包含新增字段
		String baseQuery = "SELECT SID as sid, SCONTENT as scontent, SA as sa, SB as sb, SC as sc, SD as sd, SKEY as skey, SSTATE as sstate, " + 
		"STYPE as stype, SE as se, SF as sf, STANDARD_ANSWER as standardAnswer, SCORE as score, ANALYSIS as analysis FROM " +
		" SUBJECT WHERE SID>0 ";
		
		// 使用适配器模式
		QueryAdapter adapter;
		String sid = "sid";
		
		if(subject.getScontent() != null && !subject.getScontent().equals("")) {
			// 使用关键字查询适配器
			adapter = new KeywordQueryAdapter("SCONTENT", subject.getScontent());
		} else {
			// 使用简单查询适配器
			adapter = AdapterFactory.createSimpleAdapter();
		}
		
		// 执行查询
		QueryContext queryContext = new QueryContext(adapter);
		return queryContext.executePagedQuery(baseQuery, pc, Subject.class, sid);
	}

	public Integer edit(Subject subject) {
		// 更新SQL语句，支持新增字段
		String sql = "UPDATE SUBJECT SET SCONTENT=?, SA=?, SB=?, SC=?, SD=?, SKEY=?, SSTATE=?, " +
				"STYPE=?, SE=?, SF=?, STANDARD_ANSWER=?, SCORE=?, ANALYSIS=? WHERE SID=?";
		Integer rtn = dbHelper.executeUpdate(sql, 
				subject.getScontent(),
				subject.getSa(),
				subject.getSb(),
				subject.getSc(),
				subject.getSd(),
				subject.getSkey(),
				subject.getSstate(),
				subject.getStype() == null ? 1 : subject.getStype(), // 默认为单选题
				subject.getSe(),
				subject.getSf(),
				subject.getStandardAnswer(),
				subject.getScore() == null ? 2 : subject.getScore(), // 默认2分
				subject.getAnalysis(),
				subject.getSid());
		return rtn;
	}

	public Subject detail(Subject subject) {
		String sql = "SELECT SID as sid, SCONTENT as scontent, SA as sa, SB as sb, SC as sc, SD as sd, SKEY as skey, SSTATE as sstate, " + 
		"STYPE as stype, SE as se, SF as sf, STANDARD_ANSWER as standardAnswer, SCORE as score, ANALYSIS as analysis " +
		"FROM SUBJECT WHERE SID=?";
		List<Subject> list = dbHelper.executeQuery(sql, Subject.class, subject.getSid());
		return list.get(0);
	}
	
	public Integer delete(Subject subject) {
		String sql = "DELETE FROM SUBJECT WHERE SID=?";
		return dbHelper.executeUpdate(sql, subject.getSid());
	}
}


	

	



