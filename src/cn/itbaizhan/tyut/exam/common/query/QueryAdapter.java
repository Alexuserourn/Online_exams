package cn.itbaizhan.tyut.exam.common.query;

/**
 * 查询适配器接口 - 适配器模式
 * 将不同类型的查询对象适配到统一的查询接口
 */
public interface QueryAdapter {
    
    /**
     * 根据查询条件构建查询语句
     * @param baseQuery 基础查询语句
     * @return 添加了条件的查询语句
     */
    String buildQuery(String baseQuery);
    
    /**
     * 获取查询参数
     * @return 查询参数数组
     */
    Object[] getParameters();
} 