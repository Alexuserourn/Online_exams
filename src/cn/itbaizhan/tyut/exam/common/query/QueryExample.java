package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.Paper;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysrole;
import cn.itbaizhan.tyut.exam.model.Sysuser;
import java.util.List;

/**
 * 查询示例类
 * 演示如何使用适配器模式
 */
public class QueryExample {
    
    /**
     * 示例1：简单的用户查询
     */
    public static Pager<Sysuser> simpleUserQuery(Sysuser user, PageControl pc) {
        String baseQuery = "SELECT * FROM SYSUSER WHERE 1=1";
        
        // 使用适配器工厂创建适配器
        QueryAdapter adapter = AdapterFactory.createUserAdapter(user);
        
        // 使用查询上下文执行查询
        QueryContext context = new QueryContext(adapter);
        return context.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
    }
    
    /**
     * 示例2：组合查询
     */
    public static Pager<Sysuser> compositeUserQuery(Sysuser user, String keyword, PageControl pc) {
        String baseQuery = "SELECT * FROM SYSUSER WHERE 1=1";
        
        // 创建组合适配器
        CompositeAdapter composite = new CompositeAdapter();
        
        // 添加用户适配器
        composite.addAdapter(AdapterFactory.createUserAdapter(user));
        
        // 添加关键字查询适配器
        if (keyword != null && !keyword.isEmpty()) {
            composite.addAdapter(new KeywordQueryAdapter("USERNAME", keyword));
        }
        
        // 使用查询上下文执行查询
        QueryContext context = new QueryContext(composite);
        return context.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
    }
    
    /**
     * 示例3：根据对象类型自动选择适配器
     */
    public static <T> Pager<T> autoAdapterQuery(Object queryObject, String baseQuery, PageControl pc, Class<T> cls, String pk) {
        // 使用适配器工厂根据对象类型自动选择适配器
        QueryAdapter adapter = AdapterFactory.createAdapter(queryObject);
        
        // 使用查询上下文执行查询
        QueryContext context = new QueryContext(adapter);
        return context.executePagedQuery(baseQuery, pc, cls, pk);
    }
    
    /**
     * 示例4：动态切换适配器
     */
    public static Pager<Sysuser> dynamicAdapterQuery(Object queryCondition, PageControl pc) {
        String baseQuery = "SELECT * FROM SYSUSER WHERE 1=1";
        QueryAdapter adapter;
        
        // 根据条件对象类型动态选择适配器
        if (queryCondition instanceof Sysuser) {
            adapter = AdapterFactory.createUserAdapter((Sysuser) queryCondition);
        } else if (queryCondition instanceof Sysrole) {
            // 基于角色的用户查询
            adapter = new QueryAdapter() {
                @Override
                public String buildQuery(String baseQuery) {
                    return baseQuery + " AND ROLEID = ?";
                }
                
                @Override
                public Object[] getParameters() {
                    return new Object[]{((Sysrole) queryCondition).getRoleid()};
                }
            };
        } else if (queryCondition instanceof String) {
            // 基于关键字的用户查询
            adapter = new KeywordQueryAdapter("USERNAME", (String) queryCondition);
        } else {
            // 默认使用简单查询适配器
            adapter = AdapterFactory.createSimpleAdapter();
        }
        
        // 使用查询上下文执行查询
        QueryContext context = new QueryContext(adapter);
        return context.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
    }
    
    /**
     * 示例5：角色查询 - 展示RoleQueryAdapter的使用
     * 实体适配器示例1
     */
    public static Pager<Sysrole> roleQuery(Sysrole role, PageControl pc) {
        String baseQuery = "SELECT * FROM SYSROLE WHERE 1=1";
        
        // 使用RoleQueryAdapter实体适配器
        QueryAdapter adapter = AdapterFactory.createRoleAdapter(role);
        
        // 查询上下文执行查询
        QueryContext context = new QueryContext(adapter);
        return context.executePagedQuery(baseQuery, pc, Sysrole.class, "roleid");
    }
    
    /**
     * 示例6：试卷查询 - 展示PaperQueryAdapter的使用
     * 实体适配器示例2
     */
    public static Pager<Paper> paperQuery(Paper paper, PageControl pc) {
        String baseQuery = "SELECT pname, count(*) scount FROM paper GROUP BY pname";
        
        // 使用PaperQueryAdapter实体适配器
        QueryAdapter adapter = AdapterFactory.createPaperAdapter(paper);
        
        // 执行查询
        QueryContext context = new QueryContext(adapter);
        return context.executePagedQuery(baseQuery, pc, Paper.class, "pid");
    }
    
    /**
     * 示例7：系统功能查询 - 已移除
     * 由于系统功能管理功能已被删除，此示例不再可用
     */
    public static List<SysFunction> functionQuery(SysFunction function) {
        String baseQuery = "SELECT * FROM SYSFUNCTION WHERE 1=1";
        
        // 使用简单适配器替代已删除的FunctionQueryAdapter
        QueryAdapter adapter = AdapterFactory.createSimpleAdapter();
        
        // 执行非分页查询
        QueryContext context = new QueryContext(adapter);
        return context.executeQuery(baseQuery, SysFunction.class);
    }
    
    /**
     * 示例8：多实体组合查询
     * 展示多个实体适配器组合使用
     */
    public static Pager<Sysuser> multiEntityQuery(Sysuser user, Sysrole role, PageControl pc) {
        String baseQuery = "SELECT u.* FROM SYSUSER u " +
                           "JOIN SYSROLE r ON u.ROLEID = r.ROLEID " +
                           "WHERE 1=1";
        
        // 创建组合适配器，同时使用UserQueryAdapter和RoleQueryAdapter
        CompositeAdapter composite = new CompositeAdapter();
        
        // 添加用户适配器 - 处理用户相关查询条件
        composite.addAdapter(AdapterFactory.createUserAdapter(user));
        
        // 添加角色适配器 - 处理角色相关查询条件
        composite.addAdapter(new QueryAdapter() {
            @Override
            public String buildQuery(String baseQuery) {
                if (role != null && role.getRolename() != null && !role.getRolename().equals("")) {
                    return baseQuery + " AND r.ROLENAME LIKE ?";
                }
                return baseQuery;
            }
            
            @Override
            public Object[] getParameters() {
                if (role != null && role.getRolename() != null && !role.getRolename().equals("")) {
                    return new Object[]{"%" + role.getRolename() + "%"};
                }
                return new Object[0];
            }
        });
        
        // 执行查询
        QueryContext context = new QueryContext(composite);
        return context.executePagedQuery(baseQuery, pc, Sysuser.class, "userid");
    }
} 