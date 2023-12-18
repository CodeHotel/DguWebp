package DataBeans;

import org.apache.catalina.Session;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/addwish")
public class AddWishListServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productId = request.getParameter("product");
        HttpSession session = request.getSession(true);
        Object uid = session.getAttribute("userId");
        if(uid!=null&&uid instanceof Integer){
            if(PostgreInterface.addWishList((Integer)uid, Integer.parseInt(productId))){
                response.getWriter().write("success");
            }else{
                response.getWriter().write("null");
            }
        }else{
            response.getWriter().write("null");
        }
    }
}
