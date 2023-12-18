import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import DataBeans.ImageDB;
import DataBeans.PostgreInterface;
import DataBeans.Product;
import DataBeans.ProductData;

import static DataBeans.PostgreInterface.registerUser;

@WebServlet("/modproduct")
@MultipartConfig
public class ModifyProductServlet extends HttpServlet {
    public static String[] parse(String tags) {
        List<String> tagList = new ArrayList<>();
        String regex = "#\\S+";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(tags);

        while (matcher.find()) {
            tagList.add(matcher.group());
        }

        // Convert the list to an array
        String[] tagArray = new String[tagList.size()];
        tagArray = tagList.toArray(tagArray);
        return tagArray;
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        try {
            String title = request.getParameter("title");
            String tags = request.getParameter("tag");
            String description = request.getParameter("description");
            int price = Integer.parseInt(request.getParameter("price"));
            Part image = request.getPart("image");
            String imagePath = ImageDB.uploadFile(image);
            HttpSession session = request.getSession(true);
            Object uid = session.getAttribute("userId");
            String[] tag = parse(tags);

            ProductData t = PostgreInterface.getProductData(Integer.parseInt(request.getParameter("product")));
            if(t==null) throw new Exception("nullProduct Fail");
            if(t.user.getUid()!=(Integer)uid) throw new Exception("Unauth");

            if(!PostgreInterface.modifyProduct(Integer.parseInt(request.getParameter("product")), title, price, imagePath,
                    description, tag)) throw new Exception("Sql Fail");

            response.sendRedirect(request.getContextPath()+"/Product.jsp?product="+t.prodcut.getId());
        }catch(Exception e){
            response.sendRedirect(request.getContextPath() + "/Error.jsp");
        }
    }
}
