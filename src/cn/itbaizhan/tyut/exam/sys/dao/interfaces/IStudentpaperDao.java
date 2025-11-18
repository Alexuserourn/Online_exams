package cn.itbaizhan.tyut.exam.sys.dao.interfaces;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.Studentpaper;
import cn.itbaizhan.tyut.exam.model.Subject;



public interface IStudentpaperDao {

	
	/**
	 * 查询全部错误试题列表
	 * @param studentpaper
	 * @return
	 */
	public Pager<Subject> list(Studentpaper studentpaper,PageControl pc);
	
	/**
	 * 查询全部正确试题数量(为计算总分)
	 * @param studentpaper
	 * @return
	 */
	public List<Studentpaper>  listByRightcount(Studentpaper studentpaper);
	
	/**
	 * 学生提交答案
	 * @param studentpaper
	 * @return
	 */
	public Integer addPaper(Studentpaper studentpaper);
	
	/**
	 * 学生查看已经做过试卷列表
	 * @param studentpaper
	 * @return
	 */
	public List<Studentpaper> StudentPaperList(Studentpaper studentpaper);
	
	/**
	 * 获取学生所有不重复的错题，并与题库关联确保题目存在
	 * @param userid 学生ID
	 * @param stype 题目类型（可选，null表示全部类型）
	 * @param keyword 搜索关键字（可选，null表示不按关键字筛选）
	 * @param pc 分页控制
	 * @return 题目分页对象
	 */
	public Pager<Subject> listAllDistinctErrors(Integer userid, Integer stype, String keyword, PageControl pc);
}
