package DataBeans;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAccessType;

@XmlRootElement(name = "ChatListXml")
@XmlAccessorType(XmlAccessType.FIELD)
public class ChatListXml {
    @XmlElement public int id;
    @XmlElement public int user1;
    @XmlElement public int user2;
    @XmlElement public int user1_read;
    @XmlElement public int user2_read;
    @XmlElement public String last_msg;
    @XmlElement public int last_idx;
    @XmlElement public String time;
    @XmlElement public String userNickname;

    public ChatListXml(){}
    public ChatListXml(int id, int user1, int user2, int user1_read, int user2_read, String last_msg, int last_idx, String time) {
        this.id = id;
        this.user1 = user1;
        this.user2 = user2;
        this.user1_read = user1_read;
        this.user2_read = user2_read;
        this.last_msg = last_msg;
        this.last_idx = last_idx;
        this.time = time;
    }

    public ChatListXml(Chatlist fromChatList) {
        this.id = fromChatList.id;
        this.user1 = fromChatList.user1.getUid();
        this.user2 = fromChatList.user2.getUid();
        this.user1_read = fromChatList.user1_read;
        this.user2_read = fromChatList.user2_read;
        this.last_msg = fromChatList.last_msg;
        this.last_idx = fromChatList.last_idx;
        this.time = fromChatList.time.split("T")[1].substring(0, 5);
    }
    public static ChatListXml[] ChatListConvert(Chatlist[] from){
        ChatListXml[] ret = new ChatListXml[from.length];
        for(int i=0; i< from.length; i++){
            ret[i] = new ChatListXml(from[i]);
        }
        return ret;
    }
}
