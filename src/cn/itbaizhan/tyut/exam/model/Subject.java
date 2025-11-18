package cn.itbaizhan.tyut.exam.model;

import java.util.Map;

/**
 * @author 61780
 *
 */
public class Subject {
	private Integer sid;
	private Integer randomid;
	private String scontent;
	private String sa;
	private String sb;
	private String sc;
	private String sd;
	private String skey;
	private Integer sstate;
	private String studentkey;
	
	// 添加新字段
	private Integer stype;
	private String se;
	private String sf;
	private String standardAnswer;
	private Integer score;
	private String analysis;
	
	// 额外信息字段，用于存储非数据库字段的信息
	private Map<String, Object> extraInfo;
	
	public Integer getSid() {
		return sid;
	}
	public void setSid(Integer sid) {
		this.sid = sid;
	}
	public Integer getRandomid() {
		return randomid;
	}
	public void setRandomid(Integer randomid) {
		this.randomid = randomid;
	}
	public String getScontent() {
		return scontent;
	}
	public void setScontent(String scontent) {
		this.scontent = scontent;
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
	public String getSkey() {
		return skey;
	}
	public void setSkey(String skey) {
		this.skey = skey;
	}
	public Integer getSstate() {
		return sstate;
	}
	public void setSstate(Integer sstate) {
		this.sstate = sstate;
	}
	public String getStudentkey() {
		return studentkey;
	}
	public void setStudentkey(String studentkey) {
		this.studentkey = studentkey;
	}
	
	// 新增字段的getter和setter
	public Integer getStype() {
		return stype;
	}
	public void setStype(Integer stype) {
		this.stype = stype;
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
	public String getStandardAnswer() {
		return standardAnswer;
	}
	public void setStandardAnswer(String standardAnswer) {
		this.standardAnswer = standardAnswer;
	}
	public Integer getScore() {
		return score;
	}
	public void setScore(Integer score) {
		this.score = score;
	}
	public String getAnalysis() {
		return analysis;
	}
	public void setAnalysis(String analysis) {
		this.analysis = analysis;
	}
	
	// 额外信息的getter和setter
	public Map<String, Object> getExtraInfo() {
		return extraInfo;
	}
	public void setExtraInfo(Map<String, Object> extraInfo) {
		this.extraInfo = extraInfo;
	}
}
