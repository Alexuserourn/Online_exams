package cn.itbaizhan.tyut.exam.sys.services.decorator;

import cn.itbaizhan.tyut.exam.sys.services.interfaces.IUserService;

/**
 * 服务装饰器抽象类 - 装饰器模式
 * 用于在不修改原有服务类的情况下添加新功能
 */
public abstract class ServiceDecorator implements IUserService {
    
    // 被装饰的服务对象
    protected IUserService decoratedService;
    
    /**
     * 构造函数
     * @param decoratedService 被装饰的服务对象
     */
    public ServiceDecorator(IUserService decoratedService) {
        this.decoratedService = decoratedService;
    }
} 