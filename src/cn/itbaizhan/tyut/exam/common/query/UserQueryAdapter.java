package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.model.Sysuser;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户查询适配器 - 适配器模式
 * 将Sysuser对象适配到统一的查询接口
 */
public class UserQueryAdapter implements QueryAdapter {
    
    private Sysuser user;
    
    /**
     * 构造函数
     * @param user 用户对象
     */
    public UserQueryAdapter(Sysuser user) {
        this.user = user;
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        StringBuilder queryBuilder = new StringBuilder(baseQuery);
        
        // 用于存储查询条件
        List<String> conditions = new ArrayList<>();
        
        // 添加用户名查询条件
        if(user != null && user.getUsername() != null && !user.getUsername().equals("")) {
            conditions.add("USERNAME like ?");
        }
        
        // 添加学号查询条件
        if(user != null && user.getSchoolid() != null && !user.getSchoolid().equals("")) {
            conditions.add("A.SCHOOLID like ?");
        }
        
        // 添加班级查询条件
        if(user != null && user.getClassname() != null && !user.getClassname().equals("")) {
            conditions.add("A.CLASS like ?");
        }
        
        // 添加年级查询条件
        if(user != null && user.getGrade() != null && !user.getGrade().equals("")) {
            conditions.add("A.GRADE like ?");
        }
        
        // 将所有条件添加到查询语句中
        if(!conditions.isEmpty()) {
            for(String condition : conditions) {
                queryBuilder.append(" AND ").append(condition);
            }
        }
        
        return queryBuilder.toString();
    }
    
    @Override
    public Object[] getParameters() {
        List<Object> params = new ArrayList<>();
        
        // 添加用户名参数
        if(user != null && user.getUsername() != null && !user.getUsername().equals("")) {
            params.add("%" + user.getUsername() + "%");
        }
        
        // 添加学号参数
        if(user != null && user.getSchoolid() != null && !user.getSchoolid().equals("")) {
            params.add("%" + user.getSchoolid() + "%");
        }
        
        // 添加班级参数
        if(user != null && user.getClassname() != null && !user.getClassname().equals("")) {
            params.add("%" + user.getClassname() + "%");
        }
        
        // 添加年级参数
        if(user != null && user.getGrade() != null && !user.getGrade().equals("")) {
            params.add("%" + user.getGrade() + "%");
        }
        
        return params.toArray();
    }
} 