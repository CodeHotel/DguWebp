package Servlets;

import DataBeans.PostgreInterface;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/cancelbuyrequest")
public class CancelBuyRequestServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int pid = Integer.parseInt(request.getParameter("productId"));

        boolean result = PostgreInterface.cancelBuyRequest(uid, pid, Integer.toString(pid));

        if(result) {
            response.getWriter().write("success");
        } else {
            response.getWriter().write("null");
        }
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int pid = Integer.parseInt(request.getParameter("productId"));

        boolean result = PostgreInterface.cancelBuyRequest(uid, pid, Integer.toString(pid));

        if(result) {
            response.getWriter().write("success");
        } else {
            response.getWriter().write("null");
        }
    }
}
