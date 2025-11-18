package cn.itbaizhan.tyut.exam.sys.dao.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.common.query.AdapterFactory;
import cn.itbaizhan.tyut.exam.common.query.QueryAdapter;
import cn.itbaizhan.tyut.exam.common.query.QueryContext;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.sys.dao.interfaces.IFunDao;

/**
 * 系统功能DAO实现类
 * @author Administrator
 *
 */
public class FunDao implements IFunDao {

	private DBUnitHelper dbHelper;
	
	public FunDao() {
		dbHelper = DBUnitHelper.getInstance();
	}
	
	@Override
	public Integer addfun(SysFunction fun) {
		String sql = "INSERT INTO SYSFUNCTION(FUNNAME,FUNURL,FUNPID,FUNSTATE) VALUES(?,?,?,?)";
		Integer rtn = dbHelper.executeUpdate(sql, fun.getFunname(),
				fun.getFunurl(), fun.getFunpid(), fun.getFunstate());
		return rtn;
	}

	@Override
	public Pager<SysFunction> list(SysFunction fun, PageControl pc) {
		String baseQuery = "SELECT A.FUNID,A.FUNNAME,A.FUNURL,A.FUNPID,A.FUNSTATE, " +
				"B.FUNNAME AS FUNPNAME FROM SYSFUNCTION A " +
				"LEFT OUTER JOIN SYSFUNCTION B ON A.FUNPID=B.FUNID " +
				"WHERE 1=1 ";
				
		String funid = "funid";
		
		// 使用适配器模式和策略模式
		QueryAdapter adapter = AdapterFactory.createAdapter(fun);
		QueryContext queryContext = new QueryContext(adapter);
		return queryContext.executePagedQuery(baseQuery, pc, SysFunction.class, funid);
	}

	@Override
	public SysFunction detail(SysFunction fun) {
		String sql = "SELECT A.FUNID,A.FUNNAME,A.FUNURL,A.FUNPID,A.FUNSTATE," +
		"(CASE WHEN B.FUNNAME IS NULL THEN '无' ELSE B.FUNNAME END) AS FUNPNAME" +
		" FROM SYSFUNCTION A " +
		"LEFT OUTER JOIN SYSFUNCTION B ON A.FUNPID=B.FUNID WHERE A.FUNID=? ";
		
		List<SysFunction> list = dbHelper.executeQuery(sql, SysFunction.class, fun.getFunid());		
		if(list.size() > 0){
			return list.get(0);
		} else {
			return null;
		}
	}

	@Override
	public Integer edit(SysFunction fun) {
		String sql = "UPDATE SYSFUNCTION SET FUNNAME=?,FUNURL=?,FUNPID=?,FUNSTATE=? WHERE FUNID=?";
		Integer rtn = dbHelper.executeUpdate(sql, fun.getFunname(), fun.getFunurl(), 
				fun.getFunpid(), fun.getFunstate(), fun.getFunid());
		return rtn;
	}
	
	@Override
	public List<SysFunction> getALL() {
		String sql = "SELECT FUNID,FUNNAME,FUNURL,FUNPID,FUNSTATE FROM SYSFUNCTION WHERE FUNSTATE=1";
		return dbHelper.executeQuery(sql, SysFunction.class);
	}

	@Override
	public void initSystemFunctions() {
		// 检查是否已经初始化
		String checkSql = "SELECT COUNT(*) as count FROM SYSFUNCTION WHERE FUNNAME = '成绩统计'";
		List<Map<String, Object>> result = dbHelper.executeRawQuery(checkSql);
		if (result != null && result.size() > 0 && result.get(0).get("count") != null && 
		    ((Number)result.get(0).get("count")).intValue() > 0) {
			// 已经存在，不需要再初始化
			return;
		}
		
		// 添加成绩统计功能
		String sql = "INSERT INTO SYSFUNCTION(FUNNAME, FUNURL, FUNPID, FUNSTATE) VALUES('成绩统计', 'sys/statistics?cmd=teacherStats', 5, 1)";
		dbHelper.executeUpdate(sql);
		
		// 获取新添加的功能ID
		String getIdSql = "SELECT FUNID FROM SYSFUNCTION WHERE FUNNAME = '成绩统计'";
		List<Map<String, Object>> result2 = dbHelper.executeRawQuery(getIdSql);
		if (result2 != null && result2.size() > 0 && result2.get(0).get("FUNID") != null) {
			Integer funId = ((Number)result2.get(0).get("FUNID")).intValue();
			
			// 为管理员和试题管理员添加权限
			String addRightSql = "INSERT INTO ROLERIGHT(FUNID, ROLEID) VALUES(?, -1), (?, 2)";
			dbHelper.executeUpdate(addRightSql, funId, funId);
		}
	}
}