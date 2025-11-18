package cn.itbaizhan.tyut.exam.common.query;

import cn.itbaizhan.tyut.exam.model.Paper;

/**
 * 试卷查询适配器 - 适配器模式
 * 将Paper对象适配到统一的查询接口
 */
public class PaperQueryAdapter implements QueryAdapter {
    
    private Paper paper;
    
    /**
     * 构造函数
     * @param paper 试卷对象
     */
    public PaperQueryAdapter(Paper paper) {
        this.paper = paper;
    }
    
    @Override
    public String buildQuery(String baseQuery) {
        if(paper != null && paper.getPname() != null && !paper.getPname().equals("")) {
            // 对于GROUP BY查询需要特殊处理
            if (baseQuery.contains("GROUP BY")) {
                int groupByIndex = baseQuery.indexOf("GROUP BY");
                return baseQuery.substring(0, groupByIndex) + " WHERE pname LIKE ? " + baseQuery.substring(groupByIndex);
            } else {
                return baseQuery + " AND pname LIKE ?";
            }
        }
        return baseQuery;
    }
    
    @Override
    public Object[] getParameters() {
        if(paper != null && paper.getPname() != null && !paper.getPname().equals("")) {
            return new Object[]{"%" + paper.getPname() + "%"};
        }
        return new Object[0];
    }
} 