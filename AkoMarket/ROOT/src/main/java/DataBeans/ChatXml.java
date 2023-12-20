package DataBeans;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAccessType;

@XmlRootElement(name = "ChatListXml")
@XmlAccessorType(XmlAccessType.FIELD)
public class ChatXml {
    @XmlElement private String message;
    @XmlElement private boolean iSent;
    @XmlElement private String time;
    @XmlElement private boolean system;
    @XmlElement private int id;
    @XmlElement private int idx;

    public ChatXml(){}
    public ChatXml(String message, boolean iSent, String time, boolean system, int id, int idx){
        this.message = message;
        this.iSent = iSent;
        this.time = time.split("T")[1].substring(0, 5);
        this.system = system;
        this.id = id;
        this.idx = idx;
    }
    public ChatXml(Chat from, int uid){
        this.message = from.getMessage();
        this.iSent = from.getSender() == uid;
        this.time = from.getTime().split("T")[1].substring(0, 5);
        this.system = from.isSystem();
        this.id = from.getId();
        this.idx = from.getIdx();
    }
}
