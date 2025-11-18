package cn.itbaizhan.tyut.exam.sys.services.decorator;

import java.util.List;

import cn.itbaizhan.tyut.exam.common.PageControl;
import cn.itbaizhan.tyut.exam.common.Pager;
import cn.itbaizhan.tyut.exam.model.SysFunction;
import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IUserService;

/**
 * UI通知装饰器 - 装饰器模式
 * 为用户提供UI层面的反馈，如登录成功/失败的提示消息
 */
public class UINotificationDecorator extends ServiceDecorator {
    
    // 存储最近的通知消息
    private String notificationMessage;
    // 通知类型：success, error, warning, info
    private String notificationType;
    
    /**
     * 构造函数
     * @param decoratedService 被装饰的服务对象
     */
    public UINotificationDecorator(IUserService decoratedService) {
        super(decoratedService);
        this.notificationMessage = "";
        this.notificationType = "info";
    }
    
    /**
     * 获取当前通知消息
     * @return 通知消息
     */
    public String getNotificationMessage() {
        return notificationMessage;
    }
    
    /**
     * 获取通知类型
     * @return 通知类型
     */
    public String getNotificationType() {
        return notificationType;
    }
    
    /**
     * 设置成功通知
     * @param message 成功消息
     */
    private void setSuccessNotification(String message) {
        this.notificationMessage = message;
        this.notificationType = "success";
    }
    
    /**
     * 设置错误通知
     * @param message 错误消息
     */
    private void setErrorNotification(String message) {
        this.notificationMessage = message;
        this.notificationType = "error";
    }
    
    /**
     * 设置警告通知
     * @param message 警告消息
     */
    private void setWarningNotification(String message) {
        this.notificationMessage = message;
        this.notificationType = "warning";
    }
    
    /**
     * 设置信息通知
     * @param message 信息消息
     */
    private void setInfoNotification(String message) {
        this.notificationMessage = message;
        this.notificationType = "info";
    }
    
    /**
     * 清除通知
     */
    public void clearNotification() {
        this.notificationMessage = "";
        this.notificationType = "info";
    }
    
    @Override
    public Sysuser login(Sysuser user) {
        // 先调用原始服务的登录方法
        Sysuser result = decoratedService.login(user);
        
        // 根据登录结果设置通知消息
        if (result != null) {
            setSuccessNotification("欢迎回来，" + user.getUsername() + "！登录成功。");
        } else {
            setErrorNotification("登录失败：用户名或密码错误。");
        }
        
        return result;
    }

    @Override
    public List<SysFunction> initpage(Sysuser user) {
        setInfoNotification("正在加载功能菜单...");
        List<SysFunction> result = decoratedService.initpage(user);
        setSuccessNotification("功能菜单已加载完成。");
        return result;
    }

    @Override
    public Pager<Sysuser> list(Sysuser user, PageControl pc) {
        setInfoNotification("正在查询用户列表...");
        Pager<Sysuser> result = decoratedService.list(user, pc);
        setSuccessNotification("用户列表加载完成，共找到 " + result.getPagectrl().getRscount() + " 条记录。");
        return result;
    }

    @Override
    public Integer add(Sysuser user) {
        setInfoNotification("正在添加新用户...");
        Integer result = decoratedService.add(user);
        
        if (result > 0) {
            setSuccessNotification("用户 " + user.getUsername() + " 添加成功！");
        } else {
            setErrorNotification("用户添加失败，可能用户名已存在。");
        }
        
        return result;
    }

    @Override
    public Sysuser detail(Sysuser user) {
        setInfoNotification("正在查询用户详情...");
        Sysuser result = decoratedService.detail(user);
        
        if (result != null) {
            setSuccessNotification("已加载用户详情。");
        } else {
            setWarningNotification("未找到指定用户的详细信息。");
        }
        
        return result;
    }

    @Override
    public Integer edit(Sysuser user) {
        setInfoNotification("正在更新用户信息...");
        Integer result = decoratedService.edit(user);
        
        if (result > 0) {
            setSuccessNotification("用户信息更新成功！");
        } else {
            setErrorNotification("用户信息更新失败。");
        }
        
        return result;
    }

    @Override
    public Integer editpwd(Sysuser user) {
        setInfoNotification("正在修改密码...");
        Integer result = decoratedService.editpwd(user);
        
        if (result > 0) {
            setSuccessNotification("密码修改成功！");
        } else {
            setErrorNotification("密码修改失败。");
        }
        
        return result;
    }

    @Override
    public Sysuser stulogin(Sysuser user) {
        // 先调用原始服务的登录方法
        Sysuser result = decoratedService.stulogin(user);
        
        // 根据登录结果设置通知消息
        if (result != null) {
            setSuccessNotification("学生用户登录成功！欢迎，" + user.getUsername() + "。");
        } else {
            setErrorNotification("学生用户登录失败：用户名或密码错误。");
        }
        
        return result;
    }
    
    @Override
    public Integer delete(Sysuser user) {
        setInfoNotification("正在删除用户...");
        Integer result = decoratedService.delete(user);
        
        if (result > 0) {
            setSuccessNotification("用户删除成功！");
        } else {
            setErrorNotification("用户删除失败，可能该用户不存在或已被删除。");
        }
        
        return result;
    }
} 