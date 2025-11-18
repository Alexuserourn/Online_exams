package cn.itbaizhan.tyut.exam.sys.servlets;


import java.io.IOException;
import java.util.List;

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
import cn.itbaizhan.tyut.exam.common.Tools;
import cn.itbaizhan.tyut.exam.model.Subject;

import cn.itbaizhan.tyut.exam.sys.services.impl.SubjectService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.ISubjectService;


public class SubjectServlet extends HttpServlet {

	ISubjectService service = new SubjectService();
	@Override
	protected void service(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String cmd = request.getParameter("cmd");
		if(cmd.equals("add")){
			addsubject(request,response);
		}else if(cmd.equals("list")){
			 list(request,response);
		}else if(cmd.equals("toedit")){
			toedit(request,response);
		}else if(cmd.equals("edit")){
			edit(request,response);
		}else if(cmd.equals("delete")){
			delete(request,response);
		}
	}

	/**
	 * 修改试题功能
	 * @param request
	 * @param response
	 */
	private void edit(HttpServletRequest request, HttpServletResponse response) {
		
		Subject subject = new Subject();
		
		try {
			BeanUtils.populate(subject, request.getParameterMap());
			Integer rtn = service.edit(subject);
			if(rtn>0){			
				response.sendRedirect(Tools.Basepath(request, response)+"sys/subject?cmd=list");
			}else{
				request.setAttribute("msg", "编辑试题功能失败！");
				request.getRequestDispatcher("/sys/subject/edit.jsp").forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 初始化修改页面
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void toedit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		Subject subject = new Subject();
		subject.setSid(Integer.parseInt(request.getParameter("id")));
		subject = service.detail(subject);
		if(subject!=null){
			request.setAttribute("item",subject);
			request.getRequestDispatcher("/sys/subject/edit.jsp").forward(request, response);
		}else{
			request.setAttribute("msg", "需要修改的试题功能不存在。");
			request.getRequestDispatcher("/error.jsp").forward(request, response);
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
		
		String scontent = request.getParameter("scontent");
		Subject subject = new Subject();
		if(scontent!=null && !scontent.equals("")){
			subject.setScontent(scontent);
		}
		
		PageControl pc = new PageControl();
		Integer currindex = 1;
		if(request.getParameter("index")!=null){
			currindex = Integer.parseInt(request.getParameter("index"));
		}
		pc.setCurrentindex(currindex);		pc.setPagesize(10);
		
		Pager<Subject> pager = service.list(subject, pc);
		request.setAttribute("pager", pager);
		request.getRequestDispatcher("/sys/subject/list.jsp").forward(request, response);
	}

	/**
	 * 增加试题功能
	 * @param request
	 * @param response
	 */
	private void addsubject(HttpServletRequest request, HttpServletResponse response) {
		
		Subject subject = new Subject();
		try {
			// 添加调试信息
			System.out.println("=== 题目添加调试信息 ===");
			System.out.println("接收到的参数:");
			java.util.Map<String, String[]> paramMap = request.getParameterMap();
			for (String key : paramMap.keySet()) {
				String[] values = paramMap.get(key);
				System.out.println(key + " = " + java.util.Arrays.toString(values));
			}
			
			// 手动设置Subject对象的属性，根据题目类型处理不同的字段名称
			subject.setScontent(request.getParameter("scontent"));
			subject.setStype(request.getParameter("stype") != null ? Integer.parseInt(request.getParameter("stype")) : 1);
			subject.setScore(request.getParameter("score") != null ? Integer.parseInt(request.getParameter("score")) : 2);
			subject.setSstate(request.getParameter("sstate") != null ? Integer.parseInt(request.getParameter("sstate")) : 1);
			subject.setSkey(request.getParameter("skey"));
			subject.setStandardAnswer(request.getParameter("standardAnswer"));
			subject.setAnalysis(request.getParameter("analysis"));
			
			// 根据题目类型设置选项内容
			String stype = request.getParameter("stype");
			if (stype != null) {
				switch (stype) {
					case "1": // 单选题
						subject.setSa(request.getParameter("single_sa"));
						subject.setSb(request.getParameter("single_sb"));
						subject.setSc(request.getParameter("single_sc"));
						subject.setSd(request.getParameter("single_sd"));
						break;
					case "2": // 多选题
						subject.setSa(request.getParameter("multi_sa"));
						subject.setSb(request.getParameter("multi_sb"));
						subject.setSc(request.getParameter("multi_sc"));
						subject.setSd(request.getParameter("multi_sd"));
						subject.setSe(request.getParameter("multi_se"));
						subject.setSf(request.getParameter("multi_sf"));
						break;
					case "3": // 判断题
						subject.setSa(request.getParameter("judgment_sa"));
						subject.setSb(request.getParameter("judgment_sb"));
						break;
					case "4": // 填空题
						subject.setStandardAnswer(request.getParameter("fill_standardAnswer"));
						break;
					case "5": // 简答题
						subject.setStandardAnswer(request.getParameter("essay_standardAnswer"));
						break;
				}
			}
			
			// 打印Subject对象的值
			System.out.println("Subject对象值:");
			System.out.println("scontent: " + subject.getScontent());
			System.out.println("stype: " + subject.getStype());
			System.out.println("sa: " + subject.getSa());
			System.out.println("sb: " + subject.getSb());
			System.out.println("sc: " + subject.getSc());
			System.out.println("sd: " + subject.getSd());
			System.out.println("se: " + subject.getSe());
			System.out.println("sf: " + subject.getSf());
			System.out.println("skey: " + subject.getSkey());
			System.out.println("standardAnswer: " + subject.getStandardAnswer());
			System.out.println("score: " + subject.getScore());
			System.out.println("analysis: " + subject.getAnalysis());
			System.out.println("sstate: " + subject.getSstate());
			System.out.println("========================");
			
			Integer rtn = service.addsubject(subject);
			if(rtn>0){			
				response.sendRedirect(Tools.Basepath(request, response)+"sys/subject?cmd=list");
			}else{
				request.setAttribute("msg", "增加试题功能失败或请不要添加相同试题！");
				request.getRequestDispatcher("/sys/subject/add.jsp").forward(request, response);
			}
			
		} catch (Exception e) {
			System.out.println("添加题目时发生异常: " + e.getMessage());
			e.printStackTrace();
			request.setAttribute("msg", "添加题目失败：" + e.getMessage());
			try {
				request.getRequestDispatcher("/sys/subject/add.jsp").forward(request, response);
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}	
	}

	/**
	 * 删除试题
	 * @param request
	 * @param response
	 * @throws IOException 
	 * @throws ServletException 
	 */
	private void delete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 获取要删除的试题ID
		String idStr = request.getParameter("id");
		if (idStr != null && !idStr.isEmpty()) {
			try {
				Integer subjectId = Integer.parseInt(idStr);
				Subject subject = new Subject();
				subject.setSid(subjectId);
				
				// 调用服务层删除试题
				Integer result = service.delete(subject);
				
				if (result > 0) {
					// 设置成功通知
					request.getSession().setAttribute("notification", "试题删除成功！");
					request.getSession().setAttribute("notificationType", "success");
				} else {
					// 设置错误通知
					request.getSession().setAttribute("notification", "试题删除失败！");
					request.getSession().setAttribute("notificationType", "error");
				}
			} catch (NumberFormatException e) {
				// 设置错误通知
				request.getSession().setAttribute("notification", "试题ID格式错误！");
				request.getSession().setAttribute("notificationType", "error");
			}
		}
		
		// 重定向回试题列表页面
		response.sendRedirect(Tools.Basepath(request, response) + "sys/subject?cmd=list");
	}
	
}
