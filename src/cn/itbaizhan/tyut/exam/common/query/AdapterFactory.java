package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.model.Paper;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysrole;
import cn.itbaizhan.tyut.exam.model.Sysuser;

/**
 * 适配器工厂类 - 工厂模式
 * 用于创建不同类型的查询适配器
 */
public class AdapterFactory {
    
    /**
     * 创建用户查询适配器
     * @param user 用户对象
     * @return 用户查询适配器
     */
    public static QueryAdapter createUserAdapter(Sysuser user) {
        return new UserQueryAdapter(user);
    }
    
    /**
     * 创建角色查询适配器
     * @param role 角色对象
     * @return 角色查询适配器
     */
    public static QueryAdapter createRoleAdapter(Sysrole role) {
        return new RoleQueryAdapter(role);
    }
    
    /**
     * 创建试卷查询适配器
     * @param paper 试卷对象
     * @return 试卷查询适配器
     */
    public static QueryAdapter createPaperAdapter(Paper paper) {
        return new PaperQueryAdapter(paper);
    }
    
    /**
     * 创建关键字查询适配器
     * @param field 字段名
     * @param keyword 关键字
     * @return 关键字查询适配器
     */
    public static QueryAdapter createKeywordAdapter(String field, String keyword) {
        return new KeywordQueryAdapter(field, keyword);
    }
    
    /**
     * 创建简单查询适配器
     * @return 简单查询适配器
     */
    public static QueryAdapter createSimpleAdapter() {
        return new SimpleQueryAdapter();
    }
    
    /**
     * 创建组合查询适配器
     * @param adapters 要组合的查询适配器
     * @return 组合查询适配器
     */
    public static QueryAdapter createCompositeAdapter(QueryAdapter... adapters) {
        return new CompositeAdapter(adapters);
    }
    
    /**
     * 根据查询条件自动选择适当的适配器
     * @param queryObject 查询对象
     * @return 适合该对象的查询适配器
     */
    public static QueryAdapter createAdapter(Object queryObject) {
        if (queryObject instanceof Sysuser) {
            return new UserQueryAdapter((Sysuser) queryObject);
        } else if (queryObject instanceof Sysrole) {
            return new RoleQueryAdapter((Sysrole) queryObject);
        } else if (queryObject instanceof Paper) {
            return new PaperQueryAdapter((Paper) queryObject);
        } else {
            // 默认使用简单查询适配器
            return new SimpleQueryAdapter();
        }
    }
} 