package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.model.Sysrole;

/**
 * 角色查询适配器 - 适配器模式
 * 将Sysrole对象适配到统一的查询接口
 */
public class RoleQueryAdapter implements QueryAdapter {
    
    private Sysrole role;
    
    /**
     * 构造函数
     * @param role 角色对象
     */
    public RoleQueryAdapter(Sysrole role) {
        this.role = role;
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        if(role != null && role.getRolename() != null && !role.getRolename().equals("")) {
            return baseQuery + " AND ROLENAME like ?";
        }
        return baseQuery;
    }
    
    @Override
    public Object[] getParameters() {
        if(role != null && role.getRolename() != null && !role.getRolename().equals("")) {
            return new Object[]{"%" + role.getRolename() + "%"};
        }
        return new Object[0];
    }
} 