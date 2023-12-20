package Servlets;

import DataBeans.Chat;
import DataBeans.ChatListXml;
import DataBeans.ChatListXmlWrapper;
import DataBeans.PostgreInterface;

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

@WebServlet("/chatpreview")
public class ChatPreviewServlet extends HttpServlet {

    public String chatsToXML(ChatListXml[] chatArray) {
        try {
            ChatListXmlWrapper wrapper = new ChatListXmlWrapper(chatArray);
            JAXBContext context = JAXBContext.newInstance(ChatListXmlWrapper.class);
            Marshaller marshaller = context.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

            StringWriter sw = new StringWriter();
            marshaller.marshal(wrapper, sw);
            return sw.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");

        String xaml = chatsToXML(ChatListXml.ChatListConvert(PostgreInterface.getChatPreview(uid)));

        response.setContentType("application/xml");
        response.getWriter().write(xaml);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        int uid = (int)session.getAttribute("userId");

        String xaml = chatsToXML(ChatListXml.ChatListConvert(PostgreInterface.getChatPreview(uid)));

        response.setContentType("application/xml");
        response.getWriter().write(xaml);
    }
}
