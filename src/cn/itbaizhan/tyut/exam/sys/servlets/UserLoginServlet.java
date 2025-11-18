package cn.itbaizhan.tyut.exam.sys.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import cn.itbaizhan.tyut.exam.model.Sysuser;
import cn.itbaizhan.tyut.exam.sys.dao.impl.FunDao;
import cn.itbaizhan.tyut.exam.sys.services.decorator.UINotificationDecorator;
import cn.itbaizhan.tyut.exam.sys.services.impl.UserService;
import cn.itbaizhan.tyut.exam.sys.services.interfaces.IUserService;

/**
 * 用户登录Servlet - 演示装饰器模式的使用
 */
public class UserLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // 使用装饰器模式的服务实例
    private UINotificationDecorator userService;
    
    @Override
    public void init() throws ServletException {
        // 创建基础服务
        IUserService baseService = new UserService();
        // 使用装饰器添加UI通知功能
        userService = new UINotificationDecorator(baseService);
        
        // 初始化系统功能
        try {
            FunDao funDao = new FunDao();
            funDao.initSystemFunctions();
            System.out.println("系统功能初始化完成");
        } catch (Exception e) {
            System.err.println("系统功能初始化失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 设置请求编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 获取请求参数
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // 创建用户对象
        Sysuser user = new Sysuser();
        user.setUsername(username);
        user.setUserpwd(password);
        
        try {
            // 调用登录方法
            Sysuser loginUser = userService.login(user);
            
            // 获取通知消息和类型
            String notificationMessage = userService.getNotificationMessage();
            String notificationType = userService.getNotificationType();
            
            if (loginUser != null) {
                // 登录成功
                HttpSession session = request.getSession();
                session.setAttribute("loginUser", loginUser);
                
                // 初始化用户功能菜单
                session.setAttribute("menuList", userService.initpage(loginUser));
                
                // 将通知消息存储到会话，用于在页面上显示
                session.setAttribute("notification", notificationMessage);
                session.setAttribute("notificationType", notificationType);
                
                // 重定向到主页，用美化版弹窗显示成功消息
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<!DOCTYPE html><html><head>");
                response.getWriter().write("<meta charset='UTF-8'>");
                response.getWriter().write("<style>");
                response.getWriter().write(".custom-alert{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background-color:#fff;border-radius:8px;box-shadow:0 4px 15px rgba(0,0,0,0.2);width:320px;max-width:90%;padding:20px;z-index:1000;text-align:center;animation:fadeIn 0.3s;}");
                response.getWriter().write(".alert-success{border-top:6px solid #4CAF50;}");
                response.getWriter().write(".alert-error{border-top:6px solid #f44336;}");
                response.getWriter().write(".alert-warning{border-top:6px solid #ff9800;}");
                response.getWriter().write(".alert-info{border-top:6px solid #2196F3;}");
                response.getWriter().write(".alert-title{margin:0 0 10px;font-size:20px;font-weight:bold;}");
                response.getWriter().write(".alert-message{margin:15px 0;font-size:16px;line-height:1.4;}");
                response.getWriter().write(".btn-alert{display:inline-block;padding:8px 16px;margin-top:15px;background-color:#4CAF50;color:white;border:none;border-radius:4px;font-size:16px;cursor:pointer;transition:background 0.3s;}");
                response.getWriter().write(".btn-alert:hover{background-color:#45a049;}");
                response.getWriter().write(".btn-error{background-color:#f44336;}.btn-error:hover{background-color:#d32f2f;}");
                response.getWriter().write(".alert-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background-color:rgba(0,0,0,0.5);z-index:999;animation:fadeIn 0.3s;}");
                response.getWriter().write("@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}");
                response.getWriter().write("</style>");
                response.getWriter().write("</head><body>");
                response.getWriter().write("<div class='alert-overlay'></div>");
                response.getWriter().write("<div class='custom-alert alert-success'>");
                response.getWriter().write("<div class='alert-title'>登录成功</div>");
                response.getWriter().write("<div class='alert-message'>" + notificationMessage + "</div>");
                response.getWriter().write("<button class='btn-alert' onclick=\"window.location.href='" + request.getContextPath() + "/main.jsp'\">继续</button>");
                response.getWriter().write("</div>");
                response.getWriter().write("<script>");
                response.getWriter().write("setTimeout(function(){window.location.href='" + request.getContextPath() + "/main.jsp';}, 3000);"); // 3秒后自动跳转
                response.getWriter().write("</script>");
                response.getWriter().write("</body></html>");
            } else {
                // 登录失败
                request.setAttribute("errorMsg", notificationMessage);
                // 使用美化版弹窗显示失败消息
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<!DOCTYPE html><html><head>");
                response.getWriter().write("<meta charset='UTF-8'>");
                response.getWriter().write("<style>");
                response.getWriter().write(".custom-alert{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background-color:#fff;border-radius:8px;box-shadow:0 4px 15px rgba(0,0,0,0.2);width:320px;max-width:90%;padding:20px;z-index:1000;text-align:center;animation:fadeIn 0.3s;}");
                response.getWriter().write(".alert-success{border-top:6px solid #4CAF50;}");
                response.getWriter().write(".alert-error{border-top:6px solid #f44336;}");
                response.getWriter().write(".alert-warning{border-top:6px solid #ff9800;}");
                response.getWriter().write(".alert-info{border-top:6px solid #2196F3;}");
                response.getWriter().write(".alert-title{margin:0 0 10px;font-size:20px;font-weight:bold;}");
                response.getWriter().write(".alert-message{margin:15px 0;font-size:16px;line-height:1.4;}");
                response.getWriter().write(".btn-alert{display:inline-block;padding:8px 16px;margin-top:15px;background-color:#4CAF50;color:white;border:none;border-radius:4px;font-size:16px;cursor:pointer;transition:background 0.3s;}");
                response.getWriter().write(".btn-alert:hover{background-color:#45a049;}");
                response.getWriter().write(".btn-error{background-color:#f44336;}.btn-error:hover{background-color:#d32f2f;}");
                response.getWriter().write(".alert-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background-color:rgba(0,0,0,0.5);z-index:999;animation:fadeIn 0.3s;}");
                response.getWriter().write("@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}");
                response.getWriter().write("</style>");
                response.getWriter().write("</head><body>");
                response.getWriter().write("<div class='alert-overlay'></div>");
                response.getWriter().write("<div class='custom-alert alert-error'>");
                response.getWriter().write("<div class='alert-title'>登录失败</div>");
                response.getWriter().write("<div class='alert-message'>" + notificationMessage + "</div>");
                response.getWriter().write("<button class='btn-alert btn-error' onclick=\"window.location.href='" + request.getContextPath() + "/login.jsp'\">返回</button>");
                response.getWriter().write("</div>");
                response.getWriter().write("<script>");
                response.getWriter().write("setTimeout(function(){window.location.href='" + request.getContextPath() + "/login.jsp';}, 3000);"); // 3秒后自动跳转
                response.getWriter().write("</script>");
                response.getWriter().write("</body></html>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "系统错误，请稍后再试");
            // 使用美化版弹窗显示系统错误
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().write("<!DOCTYPE html><html><head>");
            response.getWriter().write("<meta charset='UTF-8'>");
            response.getWriter().write("<style>");
            response.getWriter().write(".custom-alert{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background-color:#fff;border-radius:8px;box-shadow:0 4px 15px rgba(0,0,0,0.2);width:320px;max-width:90%;padding:20px;z-index:1000;text-align:center;animation:fadeIn 0.3s;}");
            response.getWriter().write(".alert-success{border-top:6px solid #4CAF50;}");
            response.getWriter().write(".alert-error{border-top:6px solid #f44336;}");
            response.getWriter().write(".alert-warning{border-top:6px solid #ff9800;}");
            response.getWriter().write(".alert-info{border-top:6px solid #2196F3;}");
            response.getWriter().write(".alert-title{margin:0 0 10px;font-size:20px;font-weight:bold;}");
            response.getWriter().write(".alert-message{margin:15px 0;font-size:16px;line-height:1.4;}");
            response.getWriter().write(".btn-alert{display:inline-block;padding:8px 16px;margin-top:15px;background-color:#4CAF50;color:white;border:none;border-radius:4px;font-size:16px;cursor:pointer;transition:background 0.3s;}");
            response.getWriter().write(".btn-alert:hover{background-color:#45a049;}");
            response.getWriter().write(".btn-error{background-color:#f44336;}.btn-error:hover{background-color:#d32f2f;}");
            response.getWriter().write(".alert-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background-color:rgba(0,0,0,0.5);z-index:999;animation:fadeIn 0.3s;}");
            response.getWriter().write("@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}");
            response.getWriter().write("</style>");
            response.getWriter().write("</head><body>");
            response.getWriter().write("<div class='alert-overlay'></div>");
            response.getWriter().write("<div class='custom-alert alert-warning'>");
            response.getWriter().write("<div class='alert-title'>系统错误</div>");
            response.getWriter().write("<div class='alert-message'>系统错误，请稍后再试</div>");
            response.getWriter().write("<button class='btn-alert' style='background-color:#ff9800;' onclick=\"window.location.href='" + request.getContextPath() + "/login.jsp'\">返回</button>");
            response.getWriter().write("</div>");
            response.getWriter().write("<script>");
            response.getWriter().write("setTimeout(function(){window.location.href='" + request.getContextPath() + "/login.jsp';}, 3000);"); // 3秒后自动跳转
            response.getWriter().write("</script>");
            response.getWriter().write("</body></html>");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
} 