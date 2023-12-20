package Servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import DataBeans.ImageDB;

import javax.servlet.http.Part;

import static DataBeans.PostgreInterface.registerUser;

@WebServlet("/register")
@MultipartConfig
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	System.out.println("Registration attempt...");
        request.setCharacterEncoding("utf-8");

        String id = request.getParameter("regId");
        String pw = request.getParameter("regPw");
        String nickname = request.getParameter("regNickname");
        String campus = request.getParameter("regCampus");
        String major = request.getParameter("regMajor");
        String degree = request.getParameter("regType");
        String studentId = request.getParameter("regStudentId");
        String phone = request.getParameter("regPhone");
        Part idPic = request.getPart("regIdCard");
        String id_card = ImageDB.uploadFile(idPic);
        //String id_card ="img";
        Part profilePic = request.getPart("regPicture");
        String image = ImageDB.uploadFile(profilePic);
        //String image ="img";
        DataBeans.User res = registerUser(id, pw, nickname, image, id_card, phone, campus, major, degree, studentId);

        if(res!=null){
            response.sendRedirect("RegisterComplete.jsp?success=true&id="+res.getUid());
        }else{
            response.sendRedirect("RegisterComplete.jsp?success=false");
        }

    }
}
