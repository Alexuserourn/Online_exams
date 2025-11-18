package cn.itbaizhan.tyut.exam.sys.dao.impl;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysrole;
import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.dao.interfaces.IUserDao;
import cn.itbaizhan.tyut.exam.common.query.QueryContext;
import cn.itbaizhan.tyut.exam.common.query.AdapterFactory;
import cn.itbaizhan.tyut.exam.common.query.QueryAdapter;

/**
 * 用户DAO实现类 - 使用单例模式
 */
public class UserDao implements IUserDao {

	// 使用单例模式
	private DBUnitHelper dbHelper;
	
	// 构造函数
	public UserDao() {
		// 从单例获取DBUnitHelper实例
		dbHelper = DBUnitHelper.getInstance();
	}

	public Sysuser login(Sysuser user) {
		String sql = "SELECT USERID,A.ROLEID,USERNAME,USERPWD,USERTRUENAME,USERSTATE, "
				+ "B.ROLENAME,A.SCHOOLID,A.CLASS AS CLASSNAME,A.GRADE FROM SYSUSER A "
				+ "INNER JOIN SYSROLE B ON A.ROLEID=B.ROLEID "
				+ "WHERE USERSTATE=1 AND USERNAME=? AND USERPWD=? ";
		List<Sysuser> list = dbHelper.executeQuery(sql, Sysuser.class, user
				.getUsername(), user.getUserpwd());
		if (list.size() > 0) {
			user = list.get(0);
		} else {
			user = null;
		}
		return user;
	}

	public List<SysFunction> initpage(Sysuser user) {
		List<SysFunction> list = null;

		if (user.getRoleid().equals(-1)) {
			String sql = "SELECT A.FUNID,A.FUNNAME,A.FUNURL,A.FUNPID FROM SYSFUNCTION A WHERE A.FUNSTATE=1";
			list = dbHelper.executeQuery(sql, SysFunction.class);
		} else {
			String sql = "SELECT A.FUNID,A.FUNNAME,A.FUNURL,A.FUNPID FROM SYSFUNCTION A "
					+ "INNER JOIN ROLERIGHT B ON A.FUNID=B.FUNID WHERE B.ROLEID=? AND A.FUNSTATE=1";
			list = dbHelper.executeQuery(sql, SysFunction.class, user
					.getRoleid());
		}
		return list;
	}

	public Pager<Sysuser> list(Sysuser user, PageControl pc) {
		String baseQuery = "SELECT A.USERID,A.USERNAME,A.USERSTATE,A.USERTRUENAME," +
				"B.ROLENAME,A.ROLEID,A.SCHOOLID,A.CLASS AS CLASSNAME,A.GRADE FROM SYSUSER A " +
				"INNER JOIN SYSROLE B ON A.ROLEID=B.ROLEID " +
				"WHERE 1=1 ";
		
		// 使用适配器模式和策略模式
		QueryAdapter adapter = AdapterFactory.createUserAdapter(user);
		QueryContext queryContext = new QueryContext(adapter);
		return queryContext.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
	}

	public Integer add(Sysuser user) {
		String sql = "INSERT INTO SYSUSER(ROLEID,USERNAME,USERPWD,USERTRUENAME,USERSTATE,SCHOOLID,CLASS,GRADE) " +
				"VALUES (?,?,?,?,?,?,?,?)";
		return dbHelper.executeUpdate(sql, user.getRoleid(), user.getUsername(), 
		        user.getUserpwd(), user.getUsertruename(), user.getUserstate(), 
		        user.getSchoolid(), user.getClassname(), user.getGrade());
	}

	public Sysuser detail(Sysuser user) {
		String sql = "SELECT USERID, ROLEID, USERNAME, USERPWD, USERTRUENAME, USERSTATE, SCHOOLID, CLASS AS CLASSNAME, GRADE FROM SYSUSER WHERE USERID=? ";
		List<Sysuser> list = dbHelper.executeQuery(sql, Sysuser.class, user.getUserid());
		return list.get(0);
	}

	public Integer edit(Sysuser user) {
		String sql = "UPDATE SYSUSER SET ROLEID=?,USERNAME=?," +
		"USERPWD=?,USERTRUENAME=?,USERSTATE=?,SCHOOLID=?,CLASS=?,GRADE=? WHERE USERID=?";
		Integer rtn = dbHelper.executeUpdate(sql, user.getRoleid(),
		user.getUsername(), user.getUserpwd(), user.getUsertruename(), user.getUserstate(), 
		user.getSchoolid(), user.getClassname(), user.getGrade(), user.getUserid());
		return rtn;
	}

	public Integer toedit(Sysuser user) {
		String sql = "UPDATE SYSUSER SET USERPWD=? WHERE USERID=?";
		Integer rtn = dbHelper.executeUpdate(sql, user.getUserpwd(), user.getUserid());
		return rtn;
	}
	
	public Integer editpwd(Sysuser user) {
		String sql = "UPDATE SYSUSER SET USERPWD=? WHERE USERID=?";
		Integer rtn = dbHelper.executeUpdate(sql, user.getUserpwd(), user.getUserid());
		return rtn;
	}

	public Integer toeditpwd(Sysuser user) {
		String sql = "UPDATE SYSUSER SET USERPWD=? WHERE USERID=?";
		Integer rtn = dbHelper.executeUpdate(sql, user.getUserpwd(), user.getUserid());
		return rtn;
	}
	
	public Sysuser stulogin(Sysuser user) {
		String sql = "SELECT USERID,A.ROLEID,USERNAME,USERPWD,USERTRUENAME,USERSTATE, "
				+ "B.ROLENAME,A.SCHOOLID,A.CLASS AS CLASSNAME,A.GRADE FROM SYSUSER A "
				+ "INNER JOIN SYSROLE B ON A.ROLEID=B.ROLEID "
				+ "WHERE USERSTATE=1 AND USERNAME=? AND USERPWD=? ";
		List<Sysuser> list = dbHelper.executeQuery(sql, Sysuser.class, user
				.getUsername(), user.getUserpwd());
		if (list.size() > 0) {
			user = list.get(0);
		} else {
			user = null;
		}
		return user;
	}
	
	public Integer delete(Sysuser user) {
		String sql = "DELETE FROM SYSUSER WHERE USERID=?";
		return dbHelper.executeUpdate(sql, user.getUserid());
	}
}
