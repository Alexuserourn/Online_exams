package cn.itbaizhan.tyut.exam.sys.services.impl;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysrole;
import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.dao.impl.UserDao;
import cn.itbaizhan.tyut.exam.sys.dao.interfaces.IUserDao;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IUserService;
import cn.itbaizhan.tyut.exam.common.query.AdapterFactory;
import cn.itbaizhan.tyut.exam.common.query.CompositeAdapter;
import cn.itbaizhan.tyut.exam.common.query.KeywordQueryAdapter;
import cn.itbaizhan.tyut.exam.common.query.QueryAdapter;
import cn.itbaizhan.tyut.exam.common.query.QueryContext;

/**
 * 用户服务实现类
 */
public class UserService implements IUserService {

	// 直接创建DAO对象实例
	private IUserDao dao = new UserDao();
	
	public Sysuser login(Sysuser user) {
		return dao.login(user);
	}

	public List<SysFunction> initpage(Sysuser user) {
		return dao.initpage(user);
	}
	
	public Pager<Sysuser> list(Sysuser user, PageControl pc) {
		return dao.list(user, pc);
	}

	public Integer add(Sysuser user) {
		try{
			return dao.add(user);
		}catch(Exception e){
			throw new RuntimeException();
		}
	}
	
	public Sysuser detail(Sysuser user) {
		return dao.detail(user);
	}
	
	public Integer edit(Sysuser user) {
		return dao.edit(user);
	}

	public Integer editpwd(Sysuser user) {
		return dao.editpwd(user);
	}
	
	public Sysuser stulogin(Sysuser user) {
		return dao.stulogin(user);
	}
	
	public Integer delete(Sysuser user) {
		return dao.delete(user);
	}

	/**
	 * 使用多条件查询搜索用户
	 * 演示适配器模式的应用
	 * @param user 用户基本信息
	 * @param keyword 关键字
	 * @param pc 分页控制
	 * @return 用户分页数据
	 */
	public Pager<Sysuser> advancedSearch(Sysuser user, String keyword, PageControl pc) {
		String baseQuery = "SELECT A.USERID,A.USERNAME,A.USERSTATE,A.USERTRUENAME," +
				"B.ROLENAME,A.ROLEID,A.SCHOOLID,A.CLASS AS CLASSNAME,A.GRADE FROM SYSUSER A " +
				"INNER JOIN SYSROLE B ON A.ROLEID=B.ROLEID " +
				"WHERE 1=1 ";
		
		QueryAdapter adapter;
		
		if (keyword != null && !keyword.isEmpty()) {
			// 使用组合查询适配器
			CompositeAdapter compositeAdapter = new CompositeAdapter();
			
			// 添加用户名和真实姓名的关键字查询适配器
			compositeAdapter.addAdapter(new KeywordQueryAdapter("A.USERNAME", keyword));
			compositeAdapter.addAdapter(new KeywordQueryAdapter("A.USERTRUENAME", keyword));
			
			adapter = compositeAdapter;
		} else {
			// 使用用户查询适配器
			adapter = AdapterFactory.createUserAdapter(user);
		}
		
		// 执行查询
		QueryContext queryContext = new QueryContext(adapter);
		return queryContext.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
	}
}
