package cn.itbaizhan.tyut.exam.sys.servlets;


import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.beanutils.BeanUtils;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.common.Tools;
import cn.itbaizhan.tyut.exam.model.Paper;
import cn.itbaizhan.tyut.exam.model.Studentpaper;
import cn.itbaizhan.tyut.exam.model.Subject;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.services.impl.PaperService;
import cn.itbaizhan.tyut.exam.sys.services.impl.StudentpaperService;
import cn.itbaizhan.tyut.exam.sys.services.impl.UserService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IPaperService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IStudentpaperService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IUserService;
import cn.itbaizhan.tyut.exam.sys.services.decorator.UINotificationDecorator;
import cn.itbaizhan.tyut.exam.common.DBUnitHelper;


public class UserServlet extends HttpServlet {

	IUserService service = new UserService();
	IPaperService paperService = new PaperService();
	IStudentpaperService spServece = new StudentpaperService();
	@Override
	protected void service(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String cmd= request.getParameter("cmd");
		if(cmd.equals("paperlist")){
			index(request,response);
		}else if(cmd.equals("login")){
			login(request,response);
		}else if(cmd.equals("init")){
			initpage(request,response);
		}else if(cmd.equals("logout")){
			logout(request,response);
		}else if(cmd.equals("list")){
			list(request,response);
		}else if(cmd.equals("add")){
			add(request,response);
		}else if(cmd.equals("toedit")){
			toedit(request,response);
		}else if(cmd.equals("edit")){
			edit(request,response);
		}else if(cmd.equals("toeditpwd")){
			toeditpwd(request,response);
		}else if(cmd.equals("editpwd")){
			editpwd(request,response);
		}else if(cmd.equals("paper")){
			paper(request,response);
		}else if(cmd.equals("stulogin")){
			stulogin(request,response);
		}else if(cmd.equals("answer")){
			answer(request,response);
		}else if(cmd.equals("delete")){
			delete(request,response);
		}
	}
	/**
	 * 跳转首页
	 * @param request
	 * @param response
	 */
	private void index(HttpServletRequest request, HttpServletResponse response) {
		Paper paper = new Paper();
		//String pname = request.getParameter("pname");
		//paper.setPname(pname);
		List<Paper> papers = paperService.list(paper);
		request.setAttribute("papers", papers);
		try {
			request.getRequestDispatcher("/user/index.jsp").forward(request, response);
		} catch (ServletException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	/**
	 * 修改用户功能
	 * @param request
	 * @param response
	 */
	private void edit(HttpServletRequest request, HttpServletResponse response) {
		// TODO Auto-generated method stub
		Sysuser user = new Sysuser();
		
		try {
			BeanUtils.populate(user, request.getParameterMap());
			Integer rtn = service.edit(user);
			if(rtn>0){			
				response.sendRedirect(Tools.Basepath(request, response)+"sys/user?cmd=list");
			}else{
				request.setAttribute("msg", "保存用户失败！");
				request.getRequestDispatcher("/sys/user/edit.jsp").forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	/**
	 * 用户初始化修改页面
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void toedit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		Sysuser user = new Sysuser();
		user.setUserid(Integer.parseInt(request.getParameter("id")));
		user = service.detail(user);
		if(user!=null){
			request.setAttribute("item",user);
			request.getRequestDispatcher("/sys/user/edit.jsp").forward(request, response);
		}else{
			request.setAttribute("msg", "需要修改的用户不存在。");
			request.getRequestDispatcher("/error.jsp").forward(request, response);
		}
	}
	/**
	 * 修改用户密码功能
	 * @param request
	 * @param response
	 */
	private void editpwd(HttpServletRequest request, HttpServletResponse response) {
		// TODO Auto-generated method stub
		Sysuser user = new Sysuser();
		
		try {
			BeanUtils.populate(user, request.getParameterMap());
			Integer rtn = service.editpwd(user);
			if(rtn>0){			
				response.sendRedirect(Tools.Basepath(request, response)+"sys/user?cmd=list");
			}else{
				request.setAttribute("msg", "保存用户失败！");
				request.getRequestDispatcher("/sys/user/editpwd.jsp").forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	/**
	 * 用户初始化密码修改页面
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void toeditpwd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		Sysuser user = new Sysuser();
		user.setUserid(Integer.parseInt(request.getParameter("id")));
		user = service.detail(user);
		if(user!=null){
			request.setAttribute("user",user);
			request.getRequestDispatcher("/sys/user/editpwd.jsp").forward(request, response);
		}else{
			request.setAttribute("msg", "需要修改的用户不存在。");
			request.getRequestDispatcher("/error.jsp").forward(request, response);
		}
	}
	/**
	 * 新增用户
	 * @param request
	 * @param response
	 */
	private void add(HttpServletRequest request, HttpServletResponse response) {
		// TODO Auto-generated method stub
		Sysuser user = new Sysuser();
		try {
			BeanUtils.populate(user, request.getParameterMap());
			Integer rtn = service.add(user);
			if(rtn>0){
				response.sendRedirect(Tools.Basepath(request, response)+"sys/user?cmd=list");
			}else{
				request.setAttribute("msg", "添加用户失败或请不要再重复添加");
				request.getRequestDispatcher("/sys/user/add.jsp").forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	/**
	 * 获取用户列表
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void list(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String sname = request.getParameter("sname");
		String schoolid = request.getParameter("schoolid");
		String classname = request.getParameter("classname");
		String grade = request.getParameter("grade");
		
		Sysuser user = new Sysuser();
		if(sname!=null && !sname.equals("")){
			user.setUsername("%"+sname+"%");
		}
		
		// 处理学号查询
		if(schoolid!=null && !schoolid.equals("")){
			user.setSchoolid(schoolid);
		}
		
		// 处理班级查询
		if(classname!=null && !classname.equals("")){
			user.setClassname(classname);
		}
		
		// 处理年级查询
		if(grade!=null && !grade.equals("")){
			user.setGrade(grade);
		}
		
		PageControl pc = new PageControl();
		Integer currindex = 1;
		if(request.getParameter("index")!=null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		pc.setPagesize(10);
		
		Pager<Sysuser> pager = service.list(user, pc);
		request.setAttribute("pager", pager);
		request.getRequestDispatcher("/sys/user/list.jsp").forward(request, response);
		
	}

	/**
	 * 注销
	 * @param request
	 * @param response
	 * @throws IOException 
	 */
	private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		HttpSession session = request.getSession();
		session.removeAttribute("user");
		// 清除所有通知相关的会话属性
		session.removeAttribute("notification");
		session.removeAttribute("notificationType");
		
		// 重定向到登录页面，并添加from=logout参数
		response.sendRedirect(Tools.Basepath(request, response)+"login.jsp?from=logout");
	}

	/**
	 * 初始化主页
	 * @param request
	 * @param response
	 */
	private void initpage(HttpServletRequest request, HttpServletResponse response) {
		
		HttpSession session = request.getSession(true);
		Sysuser user = (Sysuser)session.getAttribute("user");
		List<SysFunction> list = service.initpage(user);		
		try {
			request.setAttribute("list", list);
			// 保存list到session以便重定向后仍能访问
			session.setAttribute("list", list);
			// 使用重定向而不是forward
			response.sendRedirect(Tools.Basepath(request, response)+"index.jsp");
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}

	/**
	 * 用户登陆
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void login(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		Sysuser user = new Sysuser();
		user.setUsername(request.getParameter("username"));
		user.setUserpwd(request.getParameter("userpwd"));
		
		// 创建基本服务
		IUserService baseService = service;
		// 使用UI通知装饰器
		UINotificationDecorator notificationService = new UINotificationDecorator(baseService);
		
		// 调用装饰器的login方法
		user = notificationService.login(user);
		
		if(user==null){
			// 获取通知消息
			// 由于装饰器中stulogin方法在失败时使用了"学生用户登录失败"的消息
			// 这里覆盖为管理员登录失败消息
			request.setAttribute("msg", "管理员登录失败：用户名或密码错误。");
			
			// 添加通知类型，否则会导致通知样式不正确
			request.setAttribute("notificationType", "error");
			
			request.getRequestDispatcher("/login.jsp").forward(request, response);
			return;
		}else{
			// 登录成功处理
			// 获取通知消息
			String notificationMessage = notificationService.getNotificationMessage();
			String notificationType = notificationService.getNotificationType();
			
			HttpSession session = request.getSession(true);
			session.setAttribute("user", user);
			
			// 在会话中保存通知信息，供JSP页面使用
			session.setAttribute("notification", notificationMessage);
			session.setAttribute("notificationType", notificationType);
			
			// 重定向到系统主页
			response.sendRedirect(Tools.Basepath(request, response) + "sys/user?cmd=init");
		}
	}
	/**
	 * 学生获取试题内容
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void paper(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Paper paper = new Paper();
//		String pname = new String(request.getParameter("pname").getBytes("iso-8859-1"), "utf-8");
		String pname = new String(request.getParameter("pname"));
		
		// 获取当前用户ID
		HttpSession session = request.getSession();
		Integer userid = (Integer) session.getAttribute("userid");
		
		// 检查该学生是否已经参加过这个考试
		if (userid != null) {
			try {
				DBUnitHelper dbHelper = DBUnitHelper.getInstance();
				String checkSql = "SELECT id FROM paper_user WHERE pname = ? AND userid = ?";
				List<Map<String, Object>> existingRecord = dbHelper.executeRawQuery(checkSql, pname, userid);
				
				if (existingRecord != null && !existingRecord.isEmpty()) {
					// 学生已经参加过该考试，设置提示信息并重定向到试题列表页面
					session.setAttribute("notification", "您已经参加过该考试，不能重复参加！");
					session.setAttribute("notificationType", "warning");
					response.sendRedirect(Tools.Basepath(request, response) + "user?cmd=paperlist");
					return;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		paper.setPname(pname);
		List<Subject> subjects = paperService.subjectlist(paper);
		
		// 获取考试时间
		Integer examTime = 20; // 默认20分钟
		if (!subjects.isEmpty()) {
			Subject firstSubject = subjects.get(0);
			if (firstSubject.getExtraInfo() != null && firstSubject.getExtraInfo().containsKey("examTime")) {
				examTime = (Integer) firstSubject.getExtraInfo().get("examTime");
			}
		}
		
		request.setAttribute("subjects", subjects);
		request.setAttribute("pname", pname);
		request.setAttribute("examTime", examTime);
		request.getRequestDispatcher("/user/paper/paper.jsp").forward(request, response);
	}
	/**
	 * 提交回答问题
	 * @param request
	 * @param response
	 * @throws UnsupportedEncodingException 
	 */
	private void answer(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException {
		// 处理中文编码
		String pname = new String(request.getParameter("pname").getBytes("utf-8"), "utf-8");
		
		Studentpaper studentpaper = new Studentpaper();
		try {
			BeanUtils.populate(studentpaper, request.getParameterMap());
			studentpaper.setPname(pname);
			
			// 获取题目类型和分值
			String stypeParam = request.getParameter("stype");
			String scoreParam = request.getParameter("score");
			
			// 设置题目类型（默认为1，单选题）
			if (stypeParam != null && !stypeParam.isEmpty()) {
				studentpaper.setStype(Integer.parseInt(stypeParam));
			} else {
				studentpaper.setStype(1); // 默认为单选题
			}
			
			// 设置题目分值（默认为2分）
			if (scoreParam != null && !scoreParam.isEmpty()) {
				studentpaper.setScore(Integer.parseInt(scoreParam));
			} else {
				studentpaper.setScore(2); // 默认2分
			}
			
			// 处理不同题型的评分逻辑
			if (studentpaper.getStype() != null) {
				if (studentpaper.getStype() == 4) { // 填空题
					// 获取学生答案和题目ID
					String studentAnswer = studentpaper.getStudentkey();
					Integer sid = studentpaper.getSid();
					
					// 获取标准答案
					DBUnitHelper dbHelper = DBUnitHelper.getInstance();
					String query = "SELECT standard_answer FROM subject WHERE sid = ?";
					List<Map<String, Object>> results = dbHelper.executeRawQuery(query, sid);
					
					if (results != null && !results.isEmpty() && results.get(0).get("standard_answer") != null) {
						String standardAnswer = results.get(0).get("standard_answer").toString().trim();
						String studentAnswerTrimmed = (studentAnswer != null) ? studentAnswer.trim() : "";
						
						// 记录日志，帮助调试
						System.out.println("填空题判题 - 题目ID: " + sid + 
										", 学生答案: '" + studentAnswerTrimmed + 
										"', 标准答案: '" + standardAnswer + "'");
						
						// 比较答案
						if (studentAnswerTrimmed.equals(standardAnswer)) {
							studentpaper.setStudentstate(1); // 正确
							System.out.println("填空题判题结果: 正确");
						} else {
							studentpaper.setStudentstate(0); // 错误
							System.out.println("填空题判题结果: 错误");
						}
					} else {
						System.out.println("填空题判题 - 无法获取标准答案，题目ID: " + sid);
						studentpaper.setStudentstate(0); // 默认错误
					}
				} else if (studentpaper.getStype() == 5) {
					// 简答题需要人工评分
					studentpaper.setIsGraded(0); // 标记为未评分
					studentpaper.setStudentstate(0); // 初始状态为未评分
				}
			}
			
			// 保存学生答题记录
			Integer rtn = spServece.addPaper(studentpaper);
			
			if(rtn <= 0){
				System.out.println("保存学生答题记录失败：" + studentpaper.toString());
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("处理学生答题异常：" + e.getMessage());
		}
	}
	/**
	 * 学生登陆
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void stulogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		Sysuser user = new Sysuser();
		user.setUsername(request.getParameter("username"));
		user.setUserpwd(request.getParameter("userpwd"));
		
		// 创建基本服务
		IUserService baseService = service;
		// 使用UI通知装饰器
		UINotificationDecorator notificationService = new UINotificationDecorator(baseService);
		
		// 调用装饰器的stulogin方法
		user = notificationService.stulogin(user);
		
		if(user==null){
			// 获取通知消息
			String notificationMessage = notificationService.getNotificationMessage();
			request.setAttribute("msg", notificationMessage);
			// 添加通知类型为错误
			request.setAttribute("notificationType", "error");
			request.getRequestDispatcher("/login.jsp").forward(request, response);
			return;
		}else{
			// 登录成功处理
			// 获取通知消息
			String notificationMessage = notificationService.getNotificationMessage();
			String notificationType = notificationService.getNotificationType();
			
			HttpSession session = request.getSession(true);
			session.setAttribute("user", user);
			session.setAttribute("userid", user.getUserid());
			
			// 在会话中保存通知信息，供JSP页面使用
			session.setAttribute("notification", notificationMessage);
			session.setAttribute("notificationType", notificationType);
			
			// 重定向到用户首页
			response.sendRedirect(Tools.Basepath(request, response) + "user?cmd=paperlist");
		}
	}
	/**
	 * 删除用户
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void delete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 获取要删除的用户ID
		String idStr = request.getParameter("id");
		if (idStr != null && !idStr.isEmpty()) {
			try {
				Integer userId = Integer.parseInt(idStr);
				Sysuser user = new Sysuser();
				user.setUserid(userId);
				
				// 调用服务层删除用户
				Integer result = service.delete(user);
				
				if (result > 0) {
					// 设置成功通知
					HttpSession session = request.getSession();
					session.setAttribute("notification", "用户删除成功！");
					session.setAttribute("notificationType", "success");
				} else {
					// 设置错误通知
					HttpSession session = request.getSession();
					session.setAttribute("notification", "用户删除失败！");
					session.setAttribute("notificationType", "error");
				}
			} catch (NumberFormatException e) {
				// 设置错误通知
				HttpSession session = request.getSession();
				session.setAttribute("notification", "用户ID格式错误！");
				session.setAttribute("notificationType", "error");
			}
		}
		
		// 重定向回用户列表页面
		response.sendRedirect(Tools.Basepath(request, response) + "sys/user?cmd=list");
	}
}
