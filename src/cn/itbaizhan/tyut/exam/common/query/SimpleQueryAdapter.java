package cn.itbaizhan.tyut.exam.common.query;

/**
 * 简单查询适配器 - 适配器模式
 * 不添加任何条件的查询适配器
 */
public class SimpleQueryAdapter implements QueryAdapter {
    
    @Override
    public String buildQuery(String baseQuery) {
        // 直接返回基础查询语句，不添加任何条件
        return baseQuery;
    }
    
    @Override
    public Object[] getParameters() {
        // 无参数
        return new Object[0];
    }
} 