<%@ page import="DataBeans.User" %>
<%@ page import="DataBeans.PostgreInterface" %>
<%@ page import="DataBeans.ProductData" %>
<%@ page import="DataBeans.UserData" %><%--
  Created by IntelliJ IDEA.
  User: mh7cp
  Date: 2023-12-19
  Time: 오전 5:49
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아코마켓</title>
    <link rel="stylesheet" type="text/css" href="resources/css/ako-main.css">
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
                <%= t.getNickName() %>
                <div id="loginMenu" style="display:none; position:absolute; right:1em; background-color:white; padding:0.5em; width:12%;border-radius:1em;background-color: #D35400;border:solid 1px white">
                    <center style="width:100%; font-size:0.8em;font-family:'BaeMinHanna', system-ui ;color:white">
                        <table>
                            <tr style="width:90%">
                                <%= t.getNickName() %>님 환영합니다

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
<h1 style="width: 100%; text-align:left;padding-left:1em"> 상품 등록</h1>
<form action="/newproduct" method="post" enctype="multipart/form-data" style="width: 100%; text-align:left;padding-left:1em">
    이미지:<input type="file" name="image" accept="image/*"><br><br>
    상품명:<input type="text" name="title"><br><br>
    해시태그:<input type="text" name="tag"><br><br>
    설명:<br>
    <textarea id="description" name="description" rows="4" cols="50"></textarea><br><br>
    가격:<input type="number" id="price" name="price" min="0"><br><br>

    <input type="submit" value="상품 등록">
</form>
<center>
    <br><br>
    <hr>
    동국대학교
    Copyright © 2023 · All Rights Reserved
</center>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        document.getElementById("loginSubmit").addEventListener("click", loginSubmit);
    });

</script>
</body>
</html>
