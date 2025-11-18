package cn.itbaizhan.tyut.exam.sys.dao;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.Studentpaper;
import cn.itbaizhan.tyut.exam.common.DBUnitHelper;

public class StudentpaperDao {
    private DBUnitHelper dbHelper = DBUnitHelper.getInstance();

    public Pager<Studentpaper> listEssays(Integer paperid, PageControl pc) {
        String sql = "SELECT sp.*, s.scontent, s.skey, s.stype, s.score, u.usertruename as studentName " +
                "FROM studentpaper sp " +
                "INNER JOIN subject s ON sp.sid = s.sid " +
                "INNER JOIN user u ON sp.userid = u.userid " +
                "WHERE sp.pid = ? AND s.stype = 5 " +  // 5表示简答题
                "ORDER BY sp.spid";
        String sid = "spid";
        Pager<Studentpaper> pager;
        pager = dbHelper.execlist(sql, pc, Studentpaper.class, sid, paperid);
        return pager;
    }
} 