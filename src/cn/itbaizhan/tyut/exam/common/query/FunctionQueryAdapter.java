package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.model.SysFunction;

/**
 * 功能查询适配器 - 适配器模式
 * 将SysFunction对象适配到统一的查询接口
 */
public class FunctionQueryAdapter implements QueryAdapter {
    
    private SysFunction function;
    
    /**
     * 构造函数
     * @param function 功能对象
     */
    public FunctionQueryAdapter(SysFunction function) {
        this.function = function;
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        if(function != null && function.getFunname() != null && !function.getFunname().equals("")) {
            return baseQuery + " AND FUNNAME like ?";
        }
        return baseQuery;
    }
    
    @Override
    public Object[] getParameters() {
        if(function != null && function.getFunname() != null && !function.getFunname().equals("")) {
            return new Object[]{"%" + function.getFunname() + "%"};
        }
        return new Object[0];
    }
} 