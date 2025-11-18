package cn.itbaizhan.tyut.exam.common.query;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 组合适配器 - 适配器模式
 * 组合多个适配器，形成复杂查询条件
 */
public class CompositeAdapter implements QueryAdapter {
    
    private List<QueryAdapter> adapters = new ArrayList<>();
    
    /**
     * 构造函数
     * @param adapters 要组合的查询适配器
     */
    public CompositeAdapter(QueryAdapter... adapters) {
        this.adapters.addAll(Arrays.asList(adapters));
    }
    
    /**
     * 添加适配器
     * @param adapter 查询适配器
     */
    public void addAdapter(QueryAdapter adapter) {
        adapters.add(adapter);
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        String query = baseQuery;
        for (QueryAdapter adapter : adapters) {
            // 将baseQuery传给每个适配器，适配器添加自己的条件
            query = adapter.buildQuery(query);
        }
        return query;
    }
    
    @Override
    public Object[] getParameters() {
        List<Object> allParams = new ArrayList<>();
        
        // 收集所有适配器的参数
        for (QueryAdapter adapter : adapters) {
            Object[] params = adapter.getParameters();
            if (params != null && params.length > 0) {
                allParams.addAll(Arrays.asList(params));
            }
        }
        
        return allParams.toArray();
    }
} 