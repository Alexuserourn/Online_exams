package cn.itbaizhan.tyut.exam.sys.servlets;


import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.beanutils.BeanUtils;

import com.jspsmart.upload.SmartUpload;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.common.ScoreFixer;
import cn.itbaizhan.tyut.exam.common.Tools;
import cn.itbaizhan.tyut.exam.model.Paper;
import cn.itbaizhan.tyut.exam.model.Studentpaper;
import cn.itbaizhan.tyut.exam.model.Subject;

import cn.itbaizhan.tyut.exam.sys.services.impl.StudentpaperService;
import cn.itbaizhan.tyut.exam.sys.services.impl.SubjectService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IStudentpaperService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.ISubjectService;


public class StudentpaperServlet extends HttpServlet {

	IStudentpaperService service = new StudentpaperService();
	@Override
	protected void service(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String cmd = request.getParameter("cmd");
//		if(cmd.equals("add")){
//			add(request,response);
//		}
//		else if(cmd.equals("list")){
//			list(request,response);
//		}
//		else if(cmd.equals("listByRightcount")){
//			listByRightcount(request,response);
//		}
		if(cmd.equals("list")){
			list(request,response);
		}else if(cmd.equals("score")){
			score(request,response);
		}else if(cmd.equals("stupaper")){
			StudentPaperList(request,response);
		}else if(cmd.equals("gradeEssays")){
			gradeEssays(request,response);
		}else if(cmd.equals("gradeEssay")){
			gradeEssay(request,response);
		}else if(cmd.equals("allErrors")){
			listAllDistinctErrors(request,response);
		}else if(cmd.equals("freePractice")){
			freePractice(request,response);
		}
	}
	
	/**
	 * 自由练习功能
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void freePractice(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		// 获取当前用户ID
		Integer userid = (Integer) request.getSession().getAttribute("userid");
		if (userid == null) {
			// 用户未登录，重定向到登录页面
			response.sendRedirect(Tools.Basepath(request, response) + "login.jsp");
			return;
		}
		
		// 获取筛选参数
		String typeFilter = request.getParameter("typeFilter");
		Integer selectedType = null;
		if (typeFilter != null && !typeFilter.isEmpty()) {
			try {
				selectedType = Integer.parseInt(typeFilter);
				// 如果选择了"全部题型"，不进行筛选
				if (selectedType == 0) {
					selectedType = null;
				}
			} catch (NumberFormatException e) {
				// 忽略无效的类型
			}
		}
		
		// 获取搜索关键字
		String keyword = request.getParameter("keyword");
		if (keyword != null) {
			keyword = keyword.trim();
			if (keyword.isEmpty()) {
				keyword = null;
			}
		}
		
		// 设置分页参数
		PageControl pc = new PageControl();
		
		// 设置每页显示10条记录
		pc.setPagesize(10);
		
		// 获取当前页码
		Integer currindex = 1;
		if(request.getParameter("index") != null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		
		try {
			// 使用DBUnitHelper直接执行SQL查询
			DBUnitHelper dbHelper = DBUnitHelper.getInstance();
			
			// 直接执行原始SQL查询，检查数据库中是否有数据
			String checkSql = "SELECT COUNT(*) FROM subject";
			List<Map<String, Object>> checkResult = dbHelper.executeRawQuery(checkSql);
			int totalCount = 0;
			if (checkResult != null && !checkResult.isEmpty()) {
				Object countObj = checkResult.get(0).values().iterator().next();
				if (countObj != null) {
					totalCount = Integer.parseInt(countObj.toString());
				}
			}
			
			// 如果数据库中没有数据，显示错误信息
			if (totalCount == 0) {
				request.setAttribute("error", "数据库中没有题目数据");
				request.getRequestDispatcher("/user/paper/free_practice.jsp").forward(request, response);
				return;
			}
			
			// 构建简化的查询语句
			String simpleSql = "SELECT * FROM subject";
			List<Map<String, Object>> rawData = null;
			
			// 根据筛选条件构建WHERE子句
			if (selectedType != null || (keyword != null && !keyword.isEmpty())) {
				simpleSql += " WHERE ";
				
				if (selectedType != null) {
					simpleSql += "stype = " + selectedType;
					
					if (keyword != null && !keyword.isEmpty()) {
						simpleSql += " AND scontent LIKE '%" + keyword + "%'";
					}
				} else if (keyword != null && !keyword.isEmpty()) {
					simpleSql += "scontent LIKE '%" + keyword + "%'";
				}
			}
			
			// 添加排序
			simpleSql += " ORDER BY stype, sid";
			
			// 获取总记录数
			String countSql = "SELECT COUNT(*) FROM (" + simpleSql + ") AS temp";
			List<Map<String, Object>> countResult = dbHelper.executeRawQuery(countSql);
			int count = 0;
			if (countResult != null && !countResult.isEmpty()) {
				Object countObj = countResult.get(0).values().iterator().next();
				if (countObj != null) {
					count = Integer.parseInt(countObj.toString());
				}
			}
			pc.setRscount(count);
			
			// 添加分页
			int offset = (currindex - 1) * pc.getPagesize();
			simpleSql += " LIMIT " + offset + ", " + pc.getPagesize();
			
			// 执行查询
			rawData = dbHelper.executeRawQuery(simpleSql);
			
			// 将原始数据转换为Subject对象列表
			List<Subject> subjectList = new ArrayList<>();
			if (rawData != null && !rawData.isEmpty()) {
				for (Map<String, Object> row : rawData) {
					Subject subject = new Subject();
					
					// 设置基本字段
					if (row.get("sid") != null) subject.setSid(Integer.valueOf(row.get("sid").toString()));
					if (row.get("scontent") != null) subject.setScontent(row.get("scontent").toString());
					if (row.get("sa") != null) subject.setSa(row.get("sa").toString());
					if (row.get("sb") != null) subject.setSb(row.get("sb").toString());
					if (row.get("sc") != null) subject.setSc(row.get("sc").toString());
					if (row.get("sd") != null) subject.setSd(row.get("sd").toString());
					if (row.get("se") != null) subject.setSe(row.get("se").toString());
					if (row.get("sf") != null) subject.setSf(row.get("sf").toString());
					if (row.get("skey") != null) subject.setSkey(row.get("skey").toString());
					if (row.get("sstate") != null) subject.setSstate(Integer.valueOf(row.get("sstate").toString()));
					if (row.get("stype") != null) subject.setStype(Integer.valueOf(row.get("stype").toString()));
					if (row.get("score") != null) subject.setScore(Integer.valueOf(row.get("score").toString()));
					
					// 处理可能的命名差异
					if (row.get("standard_answer") != null) {
						subject.setStandardAnswer(row.get("standard_answer").toString());
					} else if (row.get("standardAnswer") != null) {
						subject.setStandardAnswer(row.get("standardAnswer").toString());
					}
					
					if (row.get("analysis") != null) subject.setAnalysis(row.get("analysis").toString());
					
					subjectList.add(subject);
				}
			}
			
			// 创建Pager对象
			Pager<Subject> pager = new Pager<>();
			pager.setList(subjectList);
			
			// 处理分页控制
			pc = dealpage(pc);
			pager.setPagectrl(pc);
			
			// 设置请求属性
			request.setAttribute("pager", pager);
			request.setAttribute("selectedType", selectedType != null ? selectedType : 0);
			request.setAttribute("keyword", keyword != null ? keyword : "");
			request.setAttribute("debug_count", totalCount); // 添加调试信息
			
			// 转发到自由练习页面
			request.getRequestDispatcher("/user/paper/free_practice.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("error", "获取题目失败：" + e.getMessage());
			request.getRequestDispatcher("/user/paper/free_practice.jsp").forward(request, response);
		}
	}
	
	/**
	 * 处理分页参数
	 * @param pc
	 * @return
	 */
	private static PageControl dealpage(PageControl pc){
		//获取总页数
		Integer pagecount = pc.getRscount()/pc.getPagesize();
		if(pc.getRscount()%pc.getPagesize()>0){
			pagecount++;
		}
		pc.setPagecount(pagecount);
		
		//计算最大(最小)显示页数
		Integer showpcount = pc.getShowpcount();//分页一次显示多少页
		Integer maxpage = 0;//当前显示最大页码
		Integer minpage = 0;
		Integer index = pc.getCurrentindex();//当前第几页
		if(pagecount<=showpcount){//当总页数小于等于显示的页数时
			maxpage = pagecount;
			minpage = 1;
		}else{
			Integer buff = showpcount/2; //取中间数。maxpage=index+buff
			buff = index+buff;
			if(buff<=showpcount){
				maxpage = showpcount;
				minpage = 1;
			}else if(buff<pagecount){
				maxpage = buff;
				minpage = maxpage - showpcount + 1;
				
			}else if(buff>=pagecount){
				maxpage = pagecount;
				minpage = maxpage - showpcount + 1;
			}
		}
		pc.setMaxpage(maxpage);	
		pc.setMinpage(minpage);
		return pc;
	}
	
	/**
	 * 查询所有不重复的错题
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void listAllDistinctErrors(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		// 获取当前用户ID
		Integer userid = (Integer) request.getSession().getAttribute("userid");
		if (userid == null) {
			// 用户未登录，重定向到登录页面
			response.sendRedirect(Tools.Basepath(request, response) + "login.jsp");
			return;
		}
		
		// 获取筛选参数
		String typeFilter = request.getParameter("typeFilter");
		Integer selectedType = null;
		if (typeFilter != null && !typeFilter.isEmpty()) {
			try {
				selectedType = Integer.parseInt(typeFilter);
				// 如果选择了"全部题型"，不进行筛选
				if (selectedType == 0) {
					selectedType = null;
				}
			} catch (NumberFormatException e) {
				// 忽略无效的类型
			}
		}
		
		// 获取搜索关键字
		String keyword = request.getParameter("keyword");
		if (keyword != null) {
			keyword = keyword.trim();
			if (keyword.isEmpty()) {
				keyword = null;
			}
		}
		
		// 设置分页参数
		PageControl pc = new PageControl();
		
		// 设置每页显示10条记录
		pc.setPagesize(10);
		
		// 获取当前页码
		Integer currindex = 1;
		if(request.getParameter("index") != null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		
		// 查询所有不重复的错题，添加筛选和搜索条件
		Pager<Subject> pager = service.listAllDistinctErrors(userid, selectedType, keyword, pc);
		request.setAttribute("pager", pager);
		request.setAttribute("selectedType", selectedType != null ? selectedType : 0);
		request.setAttribute("keyword", keyword != null ? keyword : "");
		
		// 转发到错题集页面
		request.getRequestDispatcher("/user/paper/all_errors.jsp").forward(request, response);
	}
	
	/**
	 * 查询试卷得分
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void score(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// 获取试卷ID和用户ID
		Studentpaper stupaper = new Studentpaper();
		try {
			BeanUtils.populate(stupaper, request.getParameterMap());
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
		
		String spid = stupaper.getSpid();
		Integer userid = stupaper.getUserid();
		
		if (spid == null || userid == null) {
			response.setContentType("text/html;charset=utf-8");
			PrintWriter out = response.getWriter();
			out.println("错误：缺少必要的参数");
			out.flush();
			out.close();
			return;
		}
		
		// 仅更新当前试卷的分数，不影响其他试卷
		ScoreFixer.updatePaperScore(spid, userid);
		
		try {
			// 获取试卷名称
			DBUnitHelper dbHelper = DBUnitHelper.getInstance();
			String pnameQuery = "SELECT pname FROM studentpaper WHERE spid = ? LIMIT 1";
			List<Map<String, Object>> pnameResults = dbHelper.executeRawQuery(pnameQuery, spid);
			String pname = null;
			if (pnameResults != null && !pnameResults.isEmpty() && pnameResults.get(0).get("pname") != null) {
				pname = pnameResults.get(0).get("pname").toString();
			}
			
			if (pname == null) {
				response.setContentType("text/html;charset=utf-8");
				PrintWriter out = response.getWriter();
				out.println("错误：找不到试卷记录");
				out.flush();
				out.close();
				return;
			}
			
			// 从paper_user表获取分数信息
			String scoreQuery = "SELECT score, percent_score, remaining_questions, " +
							  "(SELECT SUM(score) FROM studentpaper WHERE spid = ? AND userid = ?) as total_possible " +
							  "FROM paper_user WHERE spid = ? AND userid = ?";
			List<Map<String, Object>> scoreResults = dbHelper.executeRawQuery(scoreQuery, spid, userid, spid, userid);
			
			// 输出总得分信息
			StringBuilder scoreInfo = new StringBuilder();
			
			if (scoreResults != null && !scoreResults.isEmpty()) {
				Map<String, Object> scoreData = scoreResults.get(0);
				Integer totalScore = scoreData.get("score") != null ? ((Number)scoreData.get("score")).intValue() : 0;
				Double percentScore = scoreData.get("percent_score") != null ? ((Number)scoreData.get("percent_score")).doubleValue() : 0.0;
				Integer pendingQuestions = scoreData.get("remaining_questions") != null ? ((Number)scoreData.get("remaining_questions")).intValue() : 0;
				Integer totalPossible = scoreData.get("total_possible") != null ? ((Number)scoreData.get("total_possible")).intValue() : 100;
				
				System.out.println("从paper_user表获取的分数 - 总分: " + totalScore + ", 满分: " + totalPossible + 
								", 百分比: " + percentScore + "%, 未评分题数: " + pendingQuestions);
				
				if (pendingQuestions > 0) {
					// 有未评分的简答题
					scoreInfo.append("您的当前得分: ").append(totalScore).append(" 分 (满分 ").append(totalPossible).append(" 分)<br>");
					scoreInfo.append("注意: 您有 ").append(pendingQuestions).append(" 道简答题尚未评分，最终成绩可能会变化。");
				} else {
					// 所有题目已评分
					scoreInfo.append("您的最终得分: ").append(totalScore).append(" 分 (满分 ").append(totalPossible).append(" 分)<br>");
					scoreInfo.append("正确率: ").append(String.format("%.1f", percentScore)).append("%");
				}
			} else {
				// 没有找到分数记录，可能是新试卷或尚未计算分数
				// 查询试卷的基本信息
				String paperInfoQuery = "SELECT COUNT(*) as total_questions, SUM(score) as total_possible, " +
									 "SUM(CASE WHEN stype = 5 THEN 1 ELSE 0 END) as essay_count " +
									 "FROM studentpaper WHERE spid = ? AND userid = ?";
				List<Map<String, Object>> paperInfo = dbHelper.executeRawQuery(paperInfoQuery, spid, userid);
				
				if (paperInfo != null && !paperInfo.isEmpty()) {
					Map<String, Object> info = paperInfo.get(0);
					Integer totalQuestions = info.get("total_questions") != null ? ((Number)info.get("total_questions")).intValue() : 0;
					Integer totalPossible = info.get("total_possible") != null ? ((Number)info.get("total_possible")).intValue() : 0;
					Integer essayCount = info.get("essay_count") != null ? ((Number)info.get("essay_count")).intValue() : 0;
					
					scoreInfo.append("试卷信息: 共").append(totalQuestions).append("道题目，满分").append(totalPossible).append("分<br>");
					
					if (essayCount > 0) {
						scoreInfo.append("您有").append(essayCount).append("道简答题尚未评分，请等待教师批阅。");
					} else {
						scoreInfo.append("系统正在处理您的分数，请稍后查看。");
					}
				} else {
					scoreInfo.append("未找到试卷信息，请联系管理员。");
				}
			}
			
			// 输出得分信息
			response.setContentType("text/html;charset=utf-8");
			PrintWriter out = response.getWriter();
			out.println(scoreInfo.toString());
			out.flush();
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
			response.setContentType("text/html;charset=utf-8");
			PrintWriter out = response.getWriter();
			out.println("查询分数时出错：" + e.getMessage());
			out.flush();
			out.close();
		}
	}
	
	/**
	 * 查询详细错题
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void list(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Studentpaper studentpaper = new Studentpaper();
		PageControl pc = new PageControl();
		Integer currindex = 1;
		if(request.getParameter("index")!=null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		//pc.setPagesize(5);
		
		// 获取用户ID和试卷ID
		Integer userid = (Integer) request.getSession().getAttribute("userid");
		String spid = request.getParameter("spid");
		
		studentpaper.setUserid(userid);
		studentpaper.setSpid(spid);
		
		// 查询错题列表
		Pager<Subject> pager = service.list(studentpaper, pc);
		request.setAttribute("pager", pager);
		request.setAttribute("spid", spid);
		
		// 获取试卷名称，用于在页面上显示
		if (spid != null && !spid.isEmpty()) {
			try {
				DBUnitHelper dbHelper = DBUnitHelper.getInstance();
				String query = "SELECT pname FROM studentpaper WHERE spid = ? LIMIT 1";
				List<Map<String, Object>> results = dbHelper.executeRawQuery(query, spid);
				if (results != null && !results.isEmpty() && results.get(0).get("pname") != null) {
					String pname = results.get(0).get("pname").toString();
					request.setAttribute("pname", pname);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		request.getRequestDispatcher("/user/paper/studenterror.jsp").forward(request, response);
	}

	/**
	 * 查询需要评分的简答题
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void gradeEssays(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 获取筛选参数
		String pname = request.getParameter("pname");
		String useridStr = request.getParameter("userid");
		Integer userid = null;
		if (useridStr != null && !useridStr.isEmpty()) {
			try {
				userid = Integer.parseInt(useridStr);
			} catch (NumberFormatException e) {
				// 忽略无效的userid
			}
		}
		
		// 分页参数
		PageControl pc = new PageControl();
		Integer currindex = 1;
		if (request.getParameter("index") != null) {
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		
		// 构建查询条件
		StringBuilder queryBuilder = new StringBuilder();
		queryBuilder.append("SELECT sp.spid, sp.userid, sp.sid, sp.studentkey, sp.studentstate, sp.pname, ")
				   .append("sp.stype, sp.score, sp.manual_score, sp.is_graded, ")
				   .append("s.scontent, s.standard_answer, u.usertruename as studentName ")
				   .append("FROM studentpaper sp ")
				   .append("JOIN subject s ON sp.sid = s.sid ")
				   .append("JOIN sysuser u ON sp.userid = u.userid ")
				   .append("WHERE sp.stype = 5 AND (sp.is_graded = 0 OR sp.is_graded IS NULL) ");
		
		// 添加筛选条件
		if (pname != null && !pname.isEmpty()) {
			queryBuilder.append("AND sp.pname = ? ");
		}
		if (userid != null) {
			queryBuilder.append("AND sp.userid = ? ");
		}
		
		// 添加排序
		queryBuilder.append("ORDER BY sp.pname, sp.userid, sp.sid");
		
		// 执行查询
		DBUnitHelper dbHelper = DBUnitHelper.getInstance();
		List<Studentpaper> ungradedEssays;
		
		if (pname != null && !pname.isEmpty() && userid != null) {
			ungradedEssays = dbHelper.executeQuery(queryBuilder.toString(), Studentpaper.class, pname, userid);
		} else if (pname != null && !pname.isEmpty()) {
			ungradedEssays = dbHelper.executeQuery(queryBuilder.toString(), Studentpaper.class, pname);
		} else if (userid != null) {
			ungradedEssays = dbHelper.executeQuery(queryBuilder.toString(), Studentpaper.class, userid);
		} else {
			ungradedEssays = dbHelper.executeQuery(queryBuilder.toString(), Studentpaper.class);
		}
		
		// 获取所有试卷名称（用于筛选）
		List<Paper> papers = dbHelper.executeQuery("SELECT DISTINCT pname FROM paper", Paper.class);
		
		// 获取所有学生（用于筛选）
		List<Studentpaper> students = dbHelper.executeQuery(
			"SELECT DISTINCT sp.userid, u.usertruename FROM studentpaper sp JOIN sysuser u ON sp.userid = u.userid",
			Studentpaper.class
		);
		
		// 设置请求属性
		request.setAttribute("ungradedEssays", ungradedEssays);
		request.setAttribute("papers", papers);
		request.setAttribute("students", students);
		
		// 转发到评分页面
		request.getRequestDispatcher("/sys/paper/grade_essays.jsp").forward(request, response);
	}
	
	/**
	 * 评分简答题
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void gradeEssay(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			// 获取参数
			String spid = request.getParameter("spid");
			Integer sid = Integer.parseInt(request.getParameter("sid"));
			Integer userid = Integer.parseInt(request.getParameter("userid"));
			Integer manualScore = Integer.parseInt(request.getParameter("manualScore"));
			// 仍然获取评语参数，但不在SQL中使用它
			// 这样保持API兼容，同时去除评语功能
			String comment = request.getParameter("comment");
			
			// 获取题目满分
			DBUnitHelper dbHelper = DBUnitHelper.getInstance();
			String scoreSql = "SELECT score FROM studentpaper WHERE spid = ? AND sid = ? AND userid = ?";
			List<Map<String, Object>> scoreResult = dbHelper.executeRawQuery(scoreSql, spid, sid, userid);
			Integer fullScore = 0;
			if (scoreResult != null && !scoreResult.isEmpty() && scoreResult.get(0).get("score") != null) {
				fullScore = ((Number)scoreResult.get(0).get("score")).intValue();
			}
			
			// 根据得分情况设置答题状态：
			// 如果得满分，则标记为正确(1)
			// 如果得分大于0但小于满分，则标记为部分正确(2)
			// 如果得分为0，则标记为错误(0)
			// 这样学生可以在错题记录中看到批改结果
			Integer studentstate = 0;
			if (manualScore >= fullScore) {
				studentstate = 1; // 满分，标记为正确
			} else if (manualScore > 0) {
				studentstate = 2; // 部分得分，标记为部分正确
			} else {
				studentstate = 0; // 零分，标记为错误
			}
			
			// 更新数据库
			String sql = "UPDATE studentpaper SET manual_score = ?, is_graded = 1, studentstate = ? WHERE spid = ? AND sid = ? AND userid = ?";
			
			dbHelper.executeUpdate(sql, manualScore, studentstate, spid, sid, userid);
			
			// 仅更新当前试卷的总分记录，避免影响其他试卷
			ScoreFixer.updatePaperScore(spid, userid);
			
			// 重定向回评分页面
			response.sendRedirect(Tools.Basepath(request, response) + "sys/paper?cmd=gradeEssays");
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("error", "评分失败：" + e.getMessage());
			request.getRequestDispatcher("/sys/paper/grade_essays.jsp").forward(request, response);
		}
	}

	private void StudentPaperList(HttpServletRequest request, HttpServletResponse response) {
		try {
			// 获取当前用户ID
			Integer userid = (Integer) request.getSession().getAttribute("userid");
			if (userid == null) {
				response.sendRedirect(Tools.Basepath(request, response) + "login.jsp");
				return;
			}
			
			// 使用DBUnitHelper直接执行SQL查询，联合studentpaper和paper_user表
			DBUnitHelper dbHelper = DBUnitHelper.getInstance();
			
			// 使用spid作为试卷的唯一标识，而不是pname
			// 从paper_user表直接查询所有试卷分数，确保使用spid作为连接条件
			String scoreQuery = "SELECT DISTINCT sp.spid, sp.pname, pu.score, pu.percent_score, " +
							   "SUM(CASE WHEN sp.studentstate != 1 THEN 1 ELSE 0 END) as errorcount " +
							   "FROM studentpaper sp " +
							   "LEFT JOIN paper_user pu ON sp.spid = pu.spid AND sp.userid = pu.userid " +
							   "WHERE sp.userid = ? " +
							   "GROUP BY sp.spid, sp.pname " +
							   "ORDER BY sp.spid DESC";
			
			System.out.println("执行查询SQL: " + scoreQuery + ", 参数: userid=" + userid);
			List<Map<String, Object>> paperResults = dbHelper.executeRawQuery(scoreQuery, userid);
			System.out.println("查询结果数量: " + (paperResults != null ? paperResults.size() : 0));
			
			// 强制更新所有试卷的分数
			for (Map<String, Object> paper : paperResults) {
				String spid = (String) paper.get("spid");
				System.out.println("更新分数记录 - 试卷ID: " + spid + ", 用户ID: " + userid);
				
				// 直接计算总分并更新paper_user表
				String totalScoreSql = "SELECT " +
								   "SUM(CASE WHEN stype = 5 AND is_graded = 1 THEN manual_score " +
								   "     WHEN studentstate = 1 THEN score " +
								   "     ELSE 0 END) as total_score, " +
								   "SUM(score) as total_possible, " +
								   "SUM(CASE WHEN stype = 5 AND (is_graded = 0 OR is_graded IS NULL) THEN 1 ELSE 0 END) as pending_grading " +
								   "FROM studentpaper " +
								   "WHERE spid = ? AND userid = ?";
				
				List<Map<String, Object>> scoreData = dbHelper.executeRawQuery(totalScoreSql, spid, userid);
				if (scoreData != null && !scoreData.isEmpty()) {
					Map<String, Object> data = scoreData.get(0);
					Integer totalScore = data.get("total_score") != null ? ((Number)data.get("total_score")).intValue() : 0;
					Integer totalPossible = data.get("total_possible") != null ? ((Number)data.get("total_possible")).intValue() : 100;
					Integer pendingGrading = data.get("pending_grading") != null ? ((Number)data.get("pending_grading")).intValue() : 0;
					
					// 计算百分比
					double percentScore = totalPossible > 0 ? (double)totalScore / totalPossible * 100 : 0;
					
					// 检查是否存在记录
					String checkSql = "SELECT id FROM paper_user WHERE spid = ? AND userid = ?";
					List<Map<String, Object>> existingRecord = dbHelper.executeRawQuery(checkSql, spid, userid);
					
					if (existingRecord != null && !existingRecord.isEmpty()) {
						// 更新记录
						String updateScoreSql = "UPDATE paper_user SET score = ?, percent_score = ?, remaining_questions = ? " +
										   "WHERE spid = ? AND userid = ?";
						int result = dbHelper.executeUpdate(updateScoreSql, totalScore, percentScore, pendingGrading, spid, userid);
						System.out.println("直接更新paper_user表结果，受影响行数: " + result);
					} else {
						// 创建新记录
						String insertSql = "INSERT INTO paper_user (spid, pname, userid, score, percent_score, remaining_questions) " +
									   "VALUES (?, ?, ?, ?, ?, ?)";
						int result = dbHelper.executeUpdate(insertSql, spid, (String) paper.get("pname"), userid, totalScore, percentScore, pendingGrading);
						System.out.println("直接插入paper_user表结果，受影响行数: " + result);
					}
				}
			}
			
			// 重新查询更新后的结果
			System.out.println("重新查询更新后的分数记录");
			// 使用新的查询，直接从paper_user表获取最新分数
			String updatedScoreQuery = "SELECT pu.spid, pu.pname, pu.score, pu.percent_score, " +
								   "(SELECT COUNT(*) FROM studentpaper sp WHERE sp.spid = pu.spid AND sp.userid = pu.userid AND sp.studentstate != 1) as errorcount " +
								   "FROM paper_user pu " +
								   "WHERE pu.userid = ? " +
								   "ORDER BY pu.spid DESC";
			paperResults = dbHelper.executeRawQuery(updatedScoreQuery, userid);
			System.out.println("更新后查询结果数量: " + (paperResults != null ? paperResults.size() : 0));
			
			// 如果没有结果，则使用原来的服务方法
			if (paperResults == null || paperResults.isEmpty()) {
				Studentpaper studentpaper = new Studentpaper();
				studentpaper.setUserid(userid);
				List<Studentpaper> paperList = service.StudentPaperList(studentpaper);
				request.setAttribute("papers", paperList);
			} else {
				// 将结果转换为Studentpaper对象列表
				List<Studentpaper> papers = new ArrayList<>();
				
				for (Map<String, Object> paper : paperResults) {
					Studentpaper sp = new Studentpaper();
					sp.setPname((String) paper.get("pname"));
					sp.setSpid((String) paper.get("spid"));
					sp.setErrorcount(paper.get("errorcount") != null ? ((Number) paper.get("errorcount")).intValue() : 0);
					
					// 设置得分信息
					Integer score = paper.get("score") != null ? ((Number) paper.get("score")).intValue() : 0;
					Double percentScore = paper.get("percent_score") != null ? ((Number) paper.get("percent_score")).doubleValue() : 0.0;
					
					// 在rightcount中存储分数，用于前端显示
					sp.setRightcount(score);
					
					// 添加到列表
					papers.add(sp);
				}
				
				request.setAttribute("papers", papers);
				request.setAttribute("useScoreFromDb", true);
			}
			
			request.getRequestDispatcher("/user/paper/studentpaper.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			try {
				request.setAttribute("error", "获取试卷列表失败：" + e.getMessage());
				request.getRequestDispatcher("/user/paper/studentpaper.jsp").forward(request, response);
			} catch (ServletException | IOException ex) {
				ex.printStackTrace();
			}
		}
	}
}
