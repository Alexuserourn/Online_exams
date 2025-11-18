package cn.itbaizhan.tyut.exam.sys.dao.impl;

import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.Paper;
import cn.itbaizhan.tyut.exam.model.Subject;
import cn.itbaizhan.tyut.exam.sys.dao.interfaces.IPaperDao;
import cn.itbaizhan.tyut.exam.common.query.QueryContext;
import cn.itbaizhan.tyut.exam.common.query.AdapterFactory;
import cn.itbaizhan.tyut.exam.common.query.QueryAdapter;

/**
 * 试卷DAO实现类 - 使用单例模式
 */
public class PaperDao implements IPaperDao {

	// 使用单例模式
	private DBUnitHelper dbHelper;
	
	// 构造函数
	public PaperDao() {
		// 从单例获取DBUnitHelper实例
		dbHelper = DBUnitHelper.getInstance();
	}

	@Override
	public Integer addpaper(Paper paper) {
		Integer rtn = 0;
		
		// 设置默认考试时间
		Integer examTime = paper.getExamTime() != null ? paper.getExamTime() : 20;
		
		// 根据组卷方式选择不同的SQL
		if (paper.getPaperType() == null || paper.getPaperType() == 1) {
			// 随机组卷
			String sql = "INSERT INTO paper(pname,sid,exam_time) SELECT ?,sid,? FROM " + 
				"subject where sstate = 1 ORDER BY rand() LIMIT ?";
			
			rtn = dbHelper.executeUpdate(sql, paper.getPname(), examTime, paper.getScount());
		} else if (paper.getPaperType() == 2 && paper.getSelectedSubjects() != null && paper.getSelectedSubjects().length > 0) {
			// 手动选题组卷
			for (String sidStr : paper.getSelectedSubjects()) {
				try {
					Integer sid = Integer.parseInt(sidStr);
					String sql = "INSERT INTO paper(pname,sid,exam_time) VALUES(?,?,?)";
					rtn += dbHelper.executeUpdate(sql, paper.getPname(), sid, examTime);
				} catch (NumberFormatException e) {
					// 忽略无效的ID
					continue;
				}
			}
		}
		
		return rtn;
	}
	
	public Pager<Paper> list(Paper paper, PageControl pc) {
		String baseQuery = "SELECT pname,count(*) scount FROM paper GROUP BY pname";
		String pid = "pid";
		
		// 使用适配器模式和策略模式
		QueryAdapter adapter = AdapterFactory.createPaperAdapter(paper);
		QueryContext queryContext = new QueryContext(adapter);
		return queryContext.executePagedQuery(baseQuery, pc, Paper.class, pid);
	}

	@Override
	public List<Subject> subjectlist(Paper paper) {
		// 更新SQL查询，加载所有题目字段，包括新增的字段
		String sql = "SELECT subject.sid, scontent, sa, sb, sc, sd, se, sf, skey, sstate, stype, score, standard_answer, analysis " +
				"FROM subject, paper WHERE paper.sid = subject.sid AND paper.pname = ?";
		List<Subject> list = dbHelper.executeQuery(sql, Subject.class, paper.getPname());
		
		// 获取试卷的考试时间
		Integer examTime = getExamTime(paper.getPname());
		
		// 创建一个Map来存储额外信息
		Map<String, Object> extraInfo = new HashMap<>();
		extraInfo.put("examTime", examTime);
		
		// 将额外信息附加到第一个Subject对象
		if (!list.isEmpty()) {
			Subject firstSubject = list.get(0);
			firstSubject.setExtraInfo(extraInfo);
		}
		
		return list;
	}
	
	/**
	 * 获取试卷的考试时间
	 * @param pname 试卷名称
	 * @return 考试时间（分钟）
	 */
	private Integer getExamTime(String pname) {
		Integer examTime = 20; // 默认20分钟
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		try {
			conn = dbHelper.getConn();
			String sql = "SELECT exam_time FROM paper WHERE pname = ? LIMIT 1";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, pname);
			rs = pstmt.executeQuery();
			
			if (rs.next()) {
				examTime = rs.getInt("exam_time");
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) rs.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return examTime;
	}
	
	@Override
	public List<Subject> getAllSubjects() {
		// 获取所有可用的题目
		String sql = "SELECT sid, scontent, sa, sb, sc, sd, se, sf, skey, sstate, stype, score, standard_answer AS standardAnswer, analysis " +
				"FROM subject WHERE sstate = 1 ORDER BY sid";
		List<Subject> list = dbHelper.executeQuery(sql, Subject.class);
		return list;
	}

	@Override
	public List<Paper> list(Paper paper) {
		// TODO Auto-generated method stub
		String sql = "SELECT pname,count(*) scount FROM paper GROUP BY pname" ;
		List<Paper> list = dbHelper.executeQuery(sql, Paper.class);
		return list;
	}
	@Override
	public int delete(Paper paper) {
		String sql = "DELETE FROM paper WHERE pname=?";
		return dbHelper.executeUpdate(sql, paper.getPname());
	}
}
