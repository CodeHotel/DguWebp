<%@ page import="DataBeans.User" %>
<%@ page import="DataBeans.PostgreInterface" %>
<%@ page import="DataBeans.Chatlist" %><%--
  Created by IntelliJ IDEA.
  User: mh7cp
  Date: 2023-12-18
  Time: 오후 6:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>아코마켓-채팅</title>
  <style>
    .selectedRoom {
      background-color: blanchedalmond;
    }
  </style>
  <link rel="stylesheet" type="text/css" href="resources/css/ako-main.css">
  <link rel="stylesheet" type="text/css" href="resources/css/ako-chat.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.0.0/crypto-js.min.js"></script>
  <script>
    function loginSubmit() {
      event.preventDefault();

      // Hash the password using SHA-256
      var hashedPassword = CryptoJS.SHA256($("#loginPw").val()).toString();

      $.ajax({
        type: "POST",
        url: "/login",
        data: {
          loginId: $("#loginId").val(),
          loginPw: hashedPassword
        },
        success: function(response) {
          if (response=="success") {
            window.location.reload();
          } else {
            alert("로그인 실패!");
          }
        },
        error: function(error) {
          alert("로그인 실패!");
        }
      });
    }
  </script>

</head>
<body style="margin:0px;">

<div id="topMenuBar" class="topMenu">
  <table style="width:100%;height:100%;table-layout: fixed">
    <tr>
      <td style="width:calc(var(--topMenu-height)*0.8); height:calc(var(--topMenu-height)*0.8); padding:0px; margin:0px">
        <img style="width:auto;height:calc(var(--topMenu-height) * 0.8);display:block;margin:0;padding:0" src="resources/images/AkoFace.png">
      </td>
      <td style="width:12%;margin:0;padding: 0;color:#4FC3F7;" onclick="window.location.href = '${pageContext.request.contextPath}/Title.jsp';"> &nbsp;#아코마켓</td>
      <td style="width:10%;margin:0;padding: 0" onclick="window.location.href = '${pageContext.request.contextPath}/Title.jsp';">중고구매</td>
      <td style="width:10%;margin:0;padding: 0"onclick="window.location.href = '${pageContext.request.contextPath}/NewProduct.jsp';">중고판매</td>
      <td></td>
      <td id="loginCell" style="width:7%;margin:0;padding: 0" onmouseenter=" document.getElementById('loginMenu').style.display = 'block';"
          onmouseleave=" document.getElementById('loginMenu').style.display = 'none';">
        <%
          // Check if the user is logged in by looking for a session attribute
          Integer userId = (Integer) session.getAttribute("userId");
          if (userId != null) {
            // User is logged in
        %>
        <%
          DataBeans.UserData data = PostgreInterface.getBriefUserData(userId);
          DataBeans.User t = data.user;
        %>
        <%=t.getNickName()%>
        <div id="loginMenu" style="display:none; position:absolute; right:1em; background-color:white; padding:0.5em; width:12%;border-radius:1em;background-color: #D35400;border:solid 1px white">
          <center style="width:100%; font-size:0.8em;font-family:'BaeMinHanna', system-ui ;color:white">
            <table>
              <tr style="width:90%">

                <%=t.getNickName()%>님 환영합니다

              </tr><br>
              <tr style="width:90%">
                <button id="myPage" onclick="window.location.href = '${pageContext.request.contextPath}/MyPage.jsp?<%=userId%>';" style="padding:0.2em; width:80%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                  마이페이지
                </button>
              </tr><br>
              <tr style="width:90%">
                <button id="chat" onclick="window.location.href = '${pageContext.request.contextPath}/Chat.jsp?<%=userId%>';" style="padding:0.2em; width:80%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                  채 팅
                </button>
              </tr><br>
              <tr style="width:90%">
                <button id="logout" onclick="window.location.href = '${pageContext.request.contextPath}/logout';" style="padding:0.2em; width:80%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                  로그아웃
                </button>
              </tr>
            </table>
          </center>
        </div>
        <%
        } else {
        %>
        로그인
        <div id="loginMenu" style="display:none; position:absolute; right:1em; background-color:white; padding:0.5em; width:12%;border-radius:1em;background-color: #D35400;border:solid 1px white">
          <center>
            <form id="loginForm" method="post" style="width:100%; font-size:0.8em;font-family:'BaeMinHanna', system-ui ;color:white">
              <table>
                <tr style="width:90%">
                  <td>ID:</td>
                  <td><input type="text" id="loginId" name="loginId" style="width:100%;border-radius:0.5em;border:solid 1px white"></td>
                </tr>
                <tr style="width:90%">
                  <td>PW:</td>
                  <td><input type="password" id="loginPw" name="loginPw" style="width:100%;border-radius:0.5em;border:solid 1px white"></td>
                </tr>
              </table>
              <input id="loginSubmit" type="button" value="로그인" style="padding:0.2em; width:40%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
              <input type="button" value="회원가입" style="padding:0.2em; width:55%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white" onclick="window.location.href = '${pageContext.request.contextPath}/Register.jsp';">
            </form>
          </center>
        </div>
        <%
          }
        %>

      </td>
    </tr>
  </table>
</div>
<div style="position: relative; padding-top: 8.25%;">
  <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; flex-direction: column; justify-content: center; align-items: center;">

  </div>
</div>
<%
  Chatlist[] chatlists = PostgreInterface.getChatPreview(userId);
  System.out.print(chatlists.length);
%>
<div style = "width: 70%; margin: 20px auto; border: 1px solid #ccc; border-radius: 5px; overflow: hidden;">
  <div style = "float: left; width: 35%; height:600px; overflow-y: auto; border-right: 1px solid #ccc;" id="chatRoomList">
  </div>
  <div style = "float: right; width: 64%; height:600px; border-left: 1px solid #ccc;">
    <div style="display: flex; align-items: center; background-color: #f9f9f9;">
      <img src="resources/images/AkoFace.png" alt="profile image" style="width: 50px; height: 60px; border-radius: 50%; margin-right: 10px;">
      상대 프로필
    </div>
    <div style="padding: 20px; height: 445px; overflow-y: auto; display: flex; flex-direction: column;" id="chat-messages">
      <!-- 메시지 -->
      <div class = "message">안녕하세요!</div>
      <div class = "message self">안녕하세요! </div>
    </div>
    <div class="message-input">
      <input type="text" id="message-input" placeholder="메시지를 입력하세요...">
      <button id="send-button">전송</button>
    </div>
  </div>
</div>
<center>
  <br><br>
  <hr>
  동국대학교
  Copyright © 2023 · All Rights Reserved
</center>

<script>
  const messageInput = document.getElementById('message-input');
  const sendButton = document.getElementById('send-button');
  const chatMessages = document.getElementById('chat-messages');
  function parseChatXML(xmlString) {
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlString, "text/xml");
    const chatNodes = xmlDoc.getElementsByTagName("chats");
    const chats = [];

    for (let chat of chatNodes) {
      let chatObj = {
        message: chat.getElementsByTagName("message")[0].textContent,
        iSent: chat.getElementsByTagName("iSent")[0].textContent === 'true',
        time: chat.getElementsByTagName("time")[0].textContent,
        system: chat.getElementsByTagName("system")[0].textContent,
        id: parseInt(chat.getElementsByTagName("id")[0].textContent, 10),
        idx: parseInt(chat.getElementsByTagName("idx")[0].textContent, 10)
      };
      chats.push(chatObj);
    }

    return chats;
  }

  function displayMessage(message, sender, time, system) {
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', sender);

    const messageText = document.createElement('p');
    messageText.classList.add('message-text');
//create type sys_msg_t as enum ('none', 'request', 'accept', 'give', 'got', 'cancel');
    if (system == 'none') {
      messageText.innerHTML = message + ' <span class="message-time" style="color: gray;">(<small>' + time + '</small>)</span>';
    } else if (system == 'request') {
      messageText.innerHTML = '거래를 신청했어요!<br><button onclick="fetch(\'/acceptbuyrequest?' + message + '\').then(response => console.log(response)).catch(error => console.error(error))">수락하기</button>';
    } else if (system == 'accept') {
      messageText.innerHTML = '거래를 수락했어요!<br><button onclick="fetch(\'/cancelbuyrequest?productId=' + message + '\').then(response => console.log(response)).catch(error => console.error(error))">취소하기</button><br><button onclick="fetch(\'/confirmgive?productId=' + message + '\').then(response => console.log(response)).catch(error => console.error(error))">인계확인</button>';
    } else if (system == 'cancel') {
      messageText.innerHTML = 'System:상품거래가 취소되었습니다.';
    } else if (system == 'give') {
      messageText.innerHTML = '상품인계를 확인했어요!<br><button onclick="fetch(\'/confirmgot?productId=' + message + '\').then(response => console.log(response)).catch(error => console.error(error))">인수확인</button>';
    } else if (system == 'got') {
      messageText.innerHTML = '<br>System:상품 거래가 종료되었습니다.';
    }

    messageDiv.appendChild(messageText);
    chatMessages.appendChild(messageDiv);
  }

  function fetchAndDisplayMessages(roomId) {
    chatMessages.innerHTML = '';
    chatMessages.scrollTop = chatMessages.scrollHeight;
    fetch(`chatroomservlet?roomId=`+roomId)
            .then(response => response.text())
            .then(xmlString => {
              const parser = new DOMParser();
              const xmlDoc = parser.parseFromString(xmlString, "text/xml");
              const chatNodes = xmlDoc.getElementsByTagName("chats");

              for (let chat of chatNodes) {
                const message = chat.getElementsByTagName("message")[0].textContent;
                const iSent = chat.getElementsByTagName("iSent")[0].textContent === 'true';
                const time = chat.getElementsByTagName("time")[0].textContent;
                const system = chat.getElementsByTagName("system")[0].textContent;
                if (iSent) {
                  displayMessage(message, 'self', time, system);
                } else {
                  displayMessage(message, 'message.self', time, system);
                }
              }
            })
            .catch(error => console.error('Error fetching chat messages:', error));
  }

  function fillChatRoom(chatRoomId) {
    fetch('/chatroom?room=' + chatRoomId)
            .then(response => response.text())
            .then(str => (new window.DOMParser()).parseFromString(str, "text/xml"))
            .then(data => {
              const chats = data.documentElement.childNodes;
              for (let i = 0; i < chats.length; i++) {
                const chatNode = chats[i];
                if (chatNode.nodeType === Node.ELEMENT_NODE) {
                  const message = chatNode.getElementsByTagName('message')[0].textContent;
                  const sender = chatNode.getElementsByTagName('sender')[0].textContent;
                  const time = chatNode.getElementsByTagName('time')[0].textContent;
                  const system = chatNode.getElementsByTagName('system')[0].textContent;
                  const id = chatNode.getElementsByTagName('id')[0].textContent;
                  const idx = chatNode.getElementsByTagName('idx')[0].textContent;

                }
              }
            })
            .catch(error => {
              console.error('Error fetching chat messages:', error);
            });

  }
  function selectChatRoom(roomElement, roomId) {
    const selectedRooms = document.querySelectorAll('.selectedRoom');
    selectedRooms.forEach(room => room.classList.remove('selectedRoom'));


    roomElement.classList.add('selectedRoom');


    fetchAndDisplayMessages(roomId);
  }

  let globalChatData = [];
  let lastIdxMap = new Map();

  function fetchAndParseXML() {
    fetch('/chatpreview')
            .then(response => response.text())
            .then(xmlString => {
              const parser = new DOMParser();
              const xmlDoc = parser.parseFromString(xmlString, "text/xml");

              const chatLists = xmlDoc.getElementsByTagName("chatList");
              const parsedChats = [];

              for (let chat of chatLists) {
                const id = parseInt(chat.getElementsByTagName("id")[0].textContent, 10);
                const last_idx = parseInt(chat.getElementsByTagName("last_idx")[0].textContent, 10);

                let chatObj = {
                  id: id,
                  user1: parseInt(chat.getElementsByTagName("user1")[0].textContent, 10),
                  user2: parseInt(chat.getElementsByTagName("user2")[0].textContent, 10),
                  user_read: parseInt(chat.getElementsByTagName("user_read")[0].textContent, 10),
                  last_msg: chat.getElementsByTagName("last_msg")[0].textContent,
                  last_idx: last_idx,
                  time: chat.getElementsByTagName("time")[0].textContent,
                  userNickname: chat.getElementsByTagName("userNickname")[0].textContent
                };

                // Check if the last_idx has changed
                if (lastIdxMap.has(id) && lastIdxMap.get(id) !== last_idx) {
                  // Trigger notification for this chatroom
                  notifyChatRoomUpdate(chatObj);
                }

                // Update lastIdxMap after checking for changes
                lastIdxMap.set(id, last_idx);

                parsedChats.push(chatObj);
              }


              globalChatData = parsedChats;
              console.log(globalChatData); // Now stored in globalChatData
              updateChatRooms();
            })
            .catch(error => console.error('Error fetching XML:', error));
  }

  function notifyChatRoomUpdate(chatRoom) {
    if (!("Notification" in window)) {
      console.log("This browser does not support desktop notification");
    } else if (Notification.permission === "granted") {
      // If it's okay to show notifications
      const notification = new Notification(chatRoom.userNickname+' : '+chatRoom.last_msg);
    } else if (Notification.permission !== "denied") {
      Notification.requestPermission().then(permission => {
        if (permission === "granted") {
          const notification = new Notification(chatRoom.userNickname+' : '+chatRoom.last_msg);
        }
      });
    }
  }


  // Call this function initially and also set up polling
  fetchAndParseXML();
  setInterval(fetchAndParseXML, 5000); // Adjust the interval as needed

  function updateChatRooms() {
    const chatRoomList = document.getElementById('chatRoomList');

    globalChatData.forEach(chat => {
      let chatDiv = document.getElementById('chat_' + chat.id);

      if (!chatDiv) {
        // Create new chat room div
        chatDiv = document.createElement('div');
        chatDiv.id = 'chat_' + chat.id;
        chatDiv.setAttribute('data-room-id', chat.id); // Store room ID in a data attribute
        chatDiv.className = 'chat-room'; // Assign a class for easier selection
        chatDiv.style = "padding: 20px; cursor: pointer; border-bottom: 1px solid #ccc;";
        chatRoomList.appendChild(chatDiv);

        // Add click event listener
        chatDiv.addEventListener('click', function() {
          selectChatRoom(this, this.getAttribute('data-room-id'));
        });
      }

      // Update chat room info
      chatDiv.innerHTML = chat.userNickname + ' : ' + chat.last_msg + '  ' + chat.time + '    (' + (chat.last_idx-chat.user_read)+')';
    });
  }



  // Call this function whenever you need to update the chat rooms
  updateChatRooms();

  // Optional: set up polling to keep globalChatData updated
  setInterval(updateChatRooms, 300); // Adjust the interval as needed




</script>
</body>
</html>