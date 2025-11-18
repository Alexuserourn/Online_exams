package cn.itbaizhan.tyut.exam.model;

public class Paper {
	private String pname;
	private Integer sid;
	private Integer scount;
	private Integer paperType; // 组卷方式：1-随机组卷，2-手动选题
	private String[] selectedSubjects; // 手动选择的题目ID数组
	private Integer examTime; // 考试时间（分钟）
	
	public String getPname() {
		return pname;
	}
	public void setPname(String pname) {
		this.pname = pname;
	}
	public Integer getSid() {
		return sid;
	}
	public void setSid(Integer sid) {
		this.sid = sid;
	}
	public Integer getScount() {
		return scount;
	}
	public void setScount(Integer scount) {
		this.scount = scount;
	}
	public Integer getPaperType() {
		return paperType;
	}
	public void setPaperType(Integer paperType) {
		this.paperType = paperType;
	}
	public String[] getSelectedSubjects() {
		return selectedSubjects;
	}
	public void setSelectedSubjects(String[] selectedSubjects) {
		this.selectedSubjects = selectedSubjects;
	}
	public Integer getExamTime() {
		return examTime;
	}
	public void setExamTime(Integer examTime) {
		this.examTime = examTime;
	}
}
