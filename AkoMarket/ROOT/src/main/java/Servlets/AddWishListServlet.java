package Servlets;

import DataBeans.PostgreInterface;
import org.apache.catalina.Session;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/addwishlist")
public class AddWishListServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int pid = Integer.parseInt(request.getParameter("productId"));
        PostgreInterface.addWishList(uid,pid);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int pid = Integer.parseInt(request.getParameter("productId"));
        PostgreInterface.addWishList(uid,pid);
    }
}
