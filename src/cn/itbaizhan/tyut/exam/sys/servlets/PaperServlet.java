package cn.itbaizhan.tyut.exam.sys.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.Map;

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
import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.dao.StudentpaperDao;
import cn.itbaizhan.tyut.exam.sys.services.impl.PaperService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IPaperService;

public class PaperServlet extends HttpServlet {
	IPaperService service = new PaperService();
	
	protected void service(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
	
		String cmd = request.getParameter("cmd");
		if(cmd.equals("add")){
			addsubject(request,response);
		}else if(cmd.equals("list")){
			list(request,response);
		}else if(cmd.equals("slist")){
			slist(request,response);
		}else if(cmd.equals("delete")){
			String pname = new String(request.getParameter("pname"));
			Paper paperDelete = new Paper();
			paperDelete.setPname(pname);
		service.delete(paperDelete);
			response.sendRedirect(Tools.Basepath(request, response)+"sys/paper?cmd=list");
		}else if(cmd.equals("gradeEssays")){
			gradeEssays(request,response);
		}else if(cmd.equals("gradeEssay")){
			gradeEssay(request,response);
		}else if(cmd.equals("showAddForm")){
			showAddForm(request,response);
		}
	}	
	
	/**
	 * 显示添加试卷表单，加载所有可用题目
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 获取所有可用题目
		List<Subject> subjects = service.getAllSubjects();
		
		// 添加日志输出
		System.out.println("显示添加试卷表单 - 加载题目数量: " + (subjects != null ? subjects.size() : 0));
		
		request.setAttribute("subjects", subjects);
		request.getRequestDispatcher("/sys/paper/add.jsp").forward(request, response);
	}
	
	/**
	 * 生成试题功能
	 * @param request
	 * @param response
	 */
	private void addsubject(HttpServletRequest request, HttpServletResponse response) {
		
		Paper paper = new Paper();
		try {
			BeanUtils.populate(paper,request.getParameterMap());
			
			// 添加日志输出，帮助调试
			System.out.println("添加试卷 - 试卷名称: " + paper.getPname());
			System.out.println("添加试卷 - 组卷方式: " + paper.getPaperType());
			if (paper.getPaperType() != null && paper.getPaperType() == 2) {
				System.out.println("添加试卷 - 手动选题数量: " + 
					(paper.getSelectedSubjects() != null ? paper.getSelectedSubjects().length : 0));
			} else {
				System.out.println("添加试卷 - 随机题目数量: " + paper.getScount());
			}
			
			Integer rtn = service.addpaper(paper);
			if(rtn>0){			
				response.sendRedirect(Tools.Basepath(request, response)+"sys/paper?cmd=list");
			}else{
				request.setAttribute("msg", "增加试题功能失败！");
				// 重新加载所有可用题目
				List<Subject> subjects = service.getAllSubjects();
				request.setAttribute("subjects", subjects);
				request.getRequestDispatcher("/sys/paper/add.jsp").forward(request, response);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			try {
				// 出错时提供更详细的错误信息
				request.setAttribute("msg", "增加试题失败：" + e.getMessage());
				List<Subject> subjects = service.getAllSubjects();
				request.setAttribute("subjects", subjects);
				request.getRequestDispatcher("/sys/paper/add.jsp").forward(request, response);
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}	
	}
	/**
	 * 查询试题列表
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void list(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		String pname = request.getParameter("pname");
		Paper paper = new Paper();
		if(pname!=null && !pname.equals("")){
			paper.setPname("%"+pname+"%");
//			paper.setPname(pname);
		}
		PageControl pc = new PageControl();
		Integer currindex = 1;
		if(request.getParameter("index")!=null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);
		pc.setPagesize(10);
		
		Pager<Paper> pager = service.list(paper, pc);
//		System.out.println(pager.getList());;
		request.setAttribute("pager", pager);
		request.getRequestDispatcher("/sys/paper/list.jsp").forward(request, response);
	}
	private void slist(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Paper paper = new Paper();
//		String pname = new String(request.getParameter("pname").getBytes("iso-8859-1"), "utf-8");
		String pname = new String(request.getParameter("pname"));

		paper.setPname(pname);
		List<Subject> subjects = service.subjectlist(paper);
		request.setAttribute("subjects", subjects);
		request.getRequestDispatcher("/sys/paper/subjects.jsp").forward(request, response);
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
		
		// 使用StudentpaperDao获取简答题列表
		StudentpaperDao studentpaperDao = new StudentpaperDao();
		
		// 先获取所有试卷名称（用于筛选）
		DBUnitHelper dbHelper = DBUnitHelper.getInstance();
		List<Paper> papers = dbHelper.executeQuery("SELECT DISTINCT pname FROM paper", Paper.class);
		
		// 获取所有学生（用于筛选）
		List<Sysuser> students = dbHelper.executeQuery(
			"SELECT DISTINCT u.userid, u.usertruename FROM studentpaper sp JOIN sysuser u ON sp.userid = u.userid WHERE u.roleid = 1",
			Sysuser.class
		);
		
		// 构建查询条件
		StringBuilder queryBuilder = new StringBuilder();
		queryBuilder.append("SELECT sp.spid, sp.userid, sp.sid, sp.studentkey, sp.studentstate, sp.pname, ")
				   .append("sp.stype, sp.score, sp.manual_score as manualScore, sp.is_graded as isGraded, ")
				   .append("s.scontent, s.skey, s.standard_answer as standardAnswer, ")
				   .append("u.usertruename as studentName ")
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
		Pager<Studentpaper> pager;
		if (pname != null && !pname.isEmpty() && userid != null) {
			pager = dbHelper.execlist(queryBuilder.toString(), pc, Studentpaper.class, "spid", pname, userid);
		} else if (pname != null && !pname.isEmpty()) {
			pager = dbHelper.execlist(queryBuilder.toString(), pc, Studentpaper.class, "spid", pname);
		} else if (userid != null) {
			pager = dbHelper.execlist(queryBuilder.toString(), pc, Studentpaper.class, "spid", userid);
		} else {
			pager = dbHelper.execlist(queryBuilder.toString(), pc, Studentpaper.class, "spid");
		}
		
		// 设置请求属性
		request.setAttribute("pager", pager);
		request.setAttribute("ungradedEssays", pager.getList());
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
			int updateResult = dbHelper.executeUpdate(sql, manualScore, studentstate, spid, sid, userid);
			System.out.println("更新简答题评分结果，受影响行数: " + updateResult);
			
			if (updateResult > 0) {
				// 更新成功，立即修复简答题状态并更新成绩
				System.out.println("开始更新试卷总分 - 试卷ID: " + spid + ", 用户ID: " + userid);
				
				// 1. 修复已评分简答题的状态
				String fixStatusSql = "UPDATE studentpaper " +
								   "SET studentstate = CASE WHEN manual_score >= score THEN 1 WHEN manual_score > 0 THEN 2 ELSE 0 END " +
								   "WHERE spid = ? AND userid = ? AND stype = 5 AND is_graded = 1";
				int fixResult = dbHelper.executeUpdate(fixStatusSql, spid, userid);
				System.out.println("修复简答题状态结果，受影响行数: " + fixResult);
				
				// 2. 使用ScoreFixer更新该试卷的总分记录
				boolean scoreUpdateResult = ScoreFixer.updatePaperScore(spid, userid);
				System.out.println("更新试卷总分结果: " + (scoreUpdateResult ? "成功" : "失败"));
				
				// 3. 如果更新失败，尝试直接更新paper_user表
				if (!scoreUpdateResult) {
					System.out.println("尝试直接更新paper_user表");
					
					// 计算总分
					String totalScoreSql = "SELECT " +
									   "SUM(CASE WHEN stype = 5 AND is_graded = 1 THEN manual_score " +
									   "     WHEN studentstate = 1 THEN score " +
									   "     ELSE 0 END) as total_score, " +
									   "SUM(score) as total_possible, " +
									   "SUM(CASE WHEN stype = 5 AND (is_graded = 0 OR is_graded IS NULL) THEN 1 ELSE 0 END) as pending_grading, " +
									   "pname " +
									   "FROM studentpaper " +
									   "WHERE spid = ? AND userid = ?";
					
					List<Map<String, Object>> scoreData = dbHelper.executeRawQuery(totalScoreSql, spid, userid);
					if (scoreData != null && !scoreData.isEmpty()) {
						Map<String, Object> data = scoreData.get(0);
						Integer totalScore = data.get("total_score") != null ? ((Number)data.get("total_score")).intValue() : 0;
						Integer totalPossible = data.get("total_possible") != null ? ((Number)data.get("total_possible")).intValue() : 100;
						Integer pendingGrading = data.get("pending_grading") != null ? ((Number)data.get("pending_grading")).intValue() : 0;
						String pname = data.get("pname") != null ? data.get("pname").toString() : "";
						
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
							int result = dbHelper.executeUpdate(insertSql, spid, pname, userid, totalScore, percentScore, pendingGrading);
							System.out.println("直接插入paper_user表结果，受影响行数: " + result);
						}
					}
				}
			}
			
			// 重定向回评分页面
			response.sendRedirect(Tools.Basepath(request, response) + "sys/paper?cmd=gradeEssays");
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("error", "评分失败：" + e.getMessage());
			request.getRequestDispatcher("/sys/paper/grade_essays.jsp").forward(request, response);
		}
	}
}
