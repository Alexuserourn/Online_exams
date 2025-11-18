package cn.itbaizhan.tyut.exam.model;

import java.util.Date;

public class Studentpaper {
	private String spid;
	private Integer userid;
	private Integer sid;
	private String studentkey;
	private Integer studentstate;
	private String pname;
	private Integer rightcount;
	private Integer errorcount;
	
	// 新增字段
	private Integer manualScore; // 人工评分
	private Integer isGraded;    // 是否已评分：0-未评分，1-已评分
	private Integer stype;       // 题目类型，冗余字段，便于查询
	private Integer score;       // 题目分值，冗余字段，便于计算总分
	private String studentName;  // 学生姓名
	
	// 题目内容字段（从Subject表关联获取）
	private String scontent;     // 题目内容
	private String skey;         // 题目答案
	private String standardAnswer; // 标准答案（填空题和简答题）
	private String analysis;     // 题目解析
	private String sa;           // 选项A
	private String sb;           // 选项B
	private String sc;           // 选项C
	private String sd;           // 选项D
	private String se;           // 选项E
	private String sf;           // 选项F
	
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
	public Integer getUserid() {
		return userid;
	}
	public void setUserid(Integer userid) {
		this.userid = userid;
	}
	public String getStudentkey() {
		return studentkey;
	}
	public void setStudentkey(String studentkey) {
		this.studentkey = studentkey;
	}
	public Integer getStudentstate() {
		return studentstate;
	}
	public void setStudentstate(Integer studentstate) {
		this.studentstate = studentstate;
	}
	public void setRightcount(Integer rightcount) {
		this.rightcount = rightcount;
	}
	public Integer getRightcount() {
		return rightcount;
	}
	
	public Integer getErrorcount() {
		return errorcount;
	}
	public void setErrorcount(Integer errorcount) {
		this.errorcount = errorcount;
	}
	public String getSpid() {
		return spid;
	}
	public void setSpid(String spid) {
		this.spid = spid;
	}
	
	// 新增字段的getter和setter
	public Integer getManualScore() {
		return manualScore;
	}
	public void setManualScore(Integer manualScore) {
		this.manualScore = manualScore;
	}
	public Integer getIsGraded() {
		return isGraded;
	}
	public void setIsGraded(Integer isGraded) {
		this.isGraded = isGraded;
	}
	public Integer getStype() {
		return stype;
	}
	public void setStype(Integer stype) {
		this.stype = stype;
	}
	public Integer getScore() {
		return score;
	}
	public void setScore(Integer score) {
		this.score = score;
	}
	
	public String getStudentName() {
		return studentName;
	}
	public void setStudentName(String studentName) {
		this.studentName = studentName;
	}
	
	// 题目内容字段的getter和setter
	public String getScontent() {
		return scontent;
	}
	public void setScontent(String scontent) {
		this.scontent = scontent;
	}
	public String getSkey() {
		return skey;
	}
	public void setSkey(String skey) {
		this.skey = skey;
	}
	public String getStandardAnswer() {
		return standardAnswer;
	}
	public void setStandardAnswer(String standardAnswer) {
		this.standardAnswer = standardAnswer;
	}
	public String getAnalysis() {
		return analysis;
	}
	public void setAnalysis(String analysis) {
		this.analysis = analysis;
	}
	public String getSa() {
		return sa;
	}
	public void setSa(String sa) {
		this.sa = sa;
	}
	public String getSb() {
		return sb;
	}
	public void setSb(String sb) {
		this.sb = sb;
	}
	public String getSc() {
		return sc;
	}
	public void setSc(String sc) {
		this.sc = sc;
	}
	public String getSd() {
		return sd;
	}
	public void setSd(String sd) {
		this.sd = sd;
	}
	public String getSe() {
		return se;
	}
	public void setSe(String se) {
		this.se = se;
	}
	public String getSf() {
		return sf;
	}
	public void setSf(String sf) {
		this.sf = sf;
	}
	
	@Override
	public String toString() {
		return "Studentpaper [pname=" + pname + ", rightcount=" + rightcount
				+ ", sid=" + sid + ", spid=" + spid + ", studentkey="
				+ studentkey + ", studentstate=" + studentstate + ", userid="
				+ userid + ", manualScore=" + manualScore + ", isGraded=" + isGraded
				+ ", stype=" + stype + ", score=" + score + ", scontent=" + scontent + "]";
	}
}
