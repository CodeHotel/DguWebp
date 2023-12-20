package Servlets;

import DataBeans.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import java.io.IOException;
import java.io.StringWriter;

@WebServlet("/chatroomservlet")
public class ChatRoomServlet extends HttpServlet {
    public String chatsToXML(ChatsXml chatArray) {
        try {
            JAXBContext context = JAXBContext.newInstance(ChatsXml.class);
            Marshaller marshaller = context.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

            StringWriter sw = new StringWriter();
            marshaller.marshal(chatArray, sw);
            return sw.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int cid = Integer.parseInt(request.getParameter("roomId"));
        Chat[] chatarr = PostgreInterface.getChat(cid, uid);
        ChatsXml chats = new ChatsXml(chatarr, uid);
        String xaml = this.chatsToXML(chats);

        response.setContentType("application/xml");
        response.getWriter().write(xaml);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");
        int cid = Integer.parseInt(request.getParameter("roomId"));
        Chat[] chatarr = PostgreInterface.getChat(cid, uid);
        ChatsXml chats = new ChatsXml(chatarr, uid);
        String xaml = this.chatsToXML(chats);

        response.setContentType("application/xml");
        response.getWriter().write(xaml);
    }
}
