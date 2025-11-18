package cn.itbaizhan.tyut.exam.common.query;

/**
 * 关键字查询适配器 - 适配器模式
 * 根据关键字进行模糊查询
 */
public class KeywordQueryAdapter implements QueryAdapter {
    
    private String field;
    private String keyword;
    
    /**
     * 构造函数
     * @param field 要查询的字段名
     * @param keyword 关键字
     */
    public KeywordQueryAdapter(String field, String keyword) {
        this.field = field;
        this.keyword = keyword;
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        // 添加模糊查询条件
        return baseQuery + " AND " + field + " LIKE ?";
    }
    
    @Override
    public Object[] getParameters() {
        // 返回模糊查询的参数
        return new Object[]{"%" + keyword + "%"};
    }
} 