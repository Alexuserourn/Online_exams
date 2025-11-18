package cn.itbaizhan.tyut.exam.common.query;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.DBUnitHelper;
import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;

/**
 * 查询上下文类 - 适配器模式的核心组件
 * 
 * 这个类在适配器模式中扮演"客户端"的角色，负责使用适配器接口执行实际查询操作。
 * 它是整个查询功能框架的关键组件，所有DAO层的查询操作都通过此类执行。
 * 
 * 设计要点：
 * 1. 封装了与数据库交互的细节，使DAO层不必直接操作DBUnitHelper
 * 2. 接收不同的查询适配器，支持各种查询策略的动态切换
 * 3. 提供统一的查询执行接口，隔离了查询条件构建和查询执行的职责
 * 4. 支持普通查询和分页查询两种方式
 * 
 * 使用方式：
 * 1. 创建适当的查询适配器（如UserQueryAdapter、KeywordQueryAdapter等）
 * 2. 实例化QueryContext并传入适配器
 * 3. 调用executeQuery或executePagedQuery方法执行查询
 * 
 * 本类体现了适配器模式的核心思想：将各种不同对象的查询条件（通过适配器）
 * 转换为统一的SQL查询语句和参数，然后执行查询操作。
 */
public class QueryContext {
    
    // 查询适配器，负责构建查询条件和提供参数
    private QueryAdapter adapter;
    // 数据库操作助手
    private DBUnitHelper dbHelper;
    
    /**
     * 构造函数
     * @param adapter 查询适配器，用于生成SQL查询条件和参数
     */
    public QueryContext(QueryAdapter adapter) {
        this.adapter = adapter;
        this.dbHelper = DBUnitHelper.getInstance();
    }
    
    /**
     * 设置查询适配器
     * 允许在对象创建后动态切换查询策略
     * 
     * @param adapter 查询适配器
     */
    public void setAdapter(QueryAdapter adapter) {
        this.adapter = adapter;
    }
    
    /**
     * 执行普通查询，返回结果列表
     * 
     * 工作流程：
     * 1. 使用适配器构建最终的查询语句
     * 2. 从适配器获取查询参数
     * 3. 执行查询并返回结果
     * 
     * @param baseQuery 基础查询语句，如"SELECT * FROM table WHERE 1=1"
     * @param cls 返回的对象类型，查询结果将被映射为此类型的对象
     * @return 查询结果列表
     */
    public <T> List<T> executeQuery(String baseQuery, Class<T> cls) {
        String finalQuery = adapter.buildQuery(baseQuery);
        Object[] params = adapter.getParameters();
        
        return dbHelper.executeQuery(finalQuery, cls, params);
    }
    
    /**
     * 执行分页查询，返回分页结果
     * 
     * @param baseQuery 基础查询语句
     * @param pc 分页控制对象
     * @param cls 返回的对象类型
     * @param pk 主键字段名
     * @return 分页查询结果
     */
    public <T> Pager<T> executePagedQuery(String baseQuery, PageControl pc, Class<T> cls, String pk) {
        String finalQuery = adapter.buildQuery(baseQuery);
        Object[] params = adapter.getParameters();
        
        return dbHelper.execlist(finalQuery, pc, cls, pk, params);
    }
} 