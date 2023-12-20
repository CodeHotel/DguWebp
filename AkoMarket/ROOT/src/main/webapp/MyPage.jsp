<%@ page import="DataBeans.*" %><%--
  Created by IntelliJ IDEA.
  User: mh7cp
  Date: 2023-12-18
  Time: 오후 6:01
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아코마켓-판매자</title>
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
            <td style="width:12%;margin:0;padding: 0;color:#4FC3F7; font-size:clamp(1px, 2.3vw,35px);" onclick="window.location.href = '${pageContext.request.contextPath}/Title.jsp';"> &nbsp;#아코마켓</td>
            <td style="width:10%;margin:0;padding: 0; font-size:clamp(1px, 2.0vw,35px);" onclick="window.location.href = '${pageContext.request.contextPath}/Title.jsp';">중고구매</td>
            <td style="width:10%;margin:0;padding: 0; font-size:clamp(1px, 2.0vw,35px);"onclick="window.location.href = '${pageContext.request.contextPath}/NewProduct.jsp';">중고판매</td>
            <td></td>
            <td id="loginCell" style="width:7%;margin:0;padding: 0; font-size:clamp(1px, 2.0vw,35px);" onmouseenter=" document.getElementById('loginMenu').style.display = 'block';"
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
<center>
    <h2 style = "font-family: BaeMinHanna, system-ui;">MyPage</h2><br>
    <table style = "width: 70%;">
        <tr style = "text-align: center; height: 200px; border: 1px solid #ddd;">
            <%
                UserData user = PostgreInterface.getBriefUserData(userId);
                User usr = PostgreInterface.getFullUserData(userId);
                Rating[] rate = user.user.getRating();
                double rating = 0;
                for(int t = 0; t<rate.length; t++){
                    rating+=rate[t].rating;
                }
                if(rate.length!=0) rating/=rate.length;
            %>
            <td style = "border: 1px solid #ddd; width: 30%"><img style ="margin-top: 30px; width: 50px; height: 50px; border-radius: 50%; object-fit: cover; margin-bottom: 10px;" src="<%=ImageDB.getImageUrl(usr.getImage())%>" alt="resource/images/AkoFace.png">
                <h2 style = "font-family: BaeMinHanna, system-ui; font-size:clamp(1px, 3.5vw,55px)">내 정보</h2>
                <button style="border: 1px solid #D35400; background-color: transparent; color: #D35400; padding: 3px 8px; border-radius: 5px; vertical-align: middle; font-family: BaeMinJua, system-ui; width:clamp(1px, 10.0vw,150px); height:clamp(0.5px, 3.8vh, 70px); font-size:clamp(0.5px, 1.5vw,20px);" onclick="window.location.href = '${pageContext.request.contextPath}/'">정보 수정</button>
                <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 1.5vw,35px)">평점: <%=rating%></p>
            </td>
            <td style = "border: 1px solid #ddd;">
                <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2.0vw,40px)">캠퍼스: <%=usr.getCampus()%></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2.0vw,40px)">학과: <%=usr.getDepartment()%></p>
            </td>
        </tr>
    </table>
    <br><br>

    <h3 style = "font-family: BaeMinHanna, system-ui; font-size:clamp(1px, 3.0vw,55px)">거래 상품</h3>
    <br>
    <center>
        <%
            if(user.products.length!=0){
        %>
        <table style="width: 80%; text-align: center;">
            <%
                for(int f = 0; f<(user.products.length%3!=0?1:0) + user.products.length/3; f++){
            %>
            <tr style="height:auto;">
                <%
                    for(int pd = 0; pd<3; pd++){
                        if(3*f+pd>=user.products.length) continue;
                        Product product = user.products[3*f+pd];
                        StringBuilder hashtagStr = new StringBuilder();
                        for (String hashtag : product.getHashtags()) {
                            hashtagStr.append("#").append(hashtag).append("  ");
                        }
                %>
                <td style="width: 30%; height:auto; display: inline-block; margin: 1.6%; border: 1px solid #ccc; padding: 1.6%; box-sizing: border-box; text-align: center;">
                    <div style="width:100%;height:25vh">
                        <img style = "max-width: 100%; max-height: 100%; margin-bottom: 5px;" src="<%=ImageDB.getImageUrl(product.getImage())%>" alt="상품 이미지" class="product-image">
                    </div>
                    <hr>
                    <h2 style="font-family: BaeMinHanna, system-ui; font-size:clamp(1px, 2.5vw,50px);max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><a style = "text-decoration: none; color: black;" href="Product.jsp?product=<%=product.getId()%>"><%=product.getTitle()%></a></h2>
                    <p style = "font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2vw,40px); max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%=product.getDescription()%></p>
                    <p style = "font-family: BaeMinJua, system-ui;color:#4FC3F7; font-size:clamp(1px, 2vw,40px);max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%=hashtagStr.toString() %></p>
                    <p style = "font-family: BaeMinJua, system-ui;font-size:clamp(1px, 2vw,40px);max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%=product.getPrice() %></p>
                    <hr>
                    <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2vw,40px);"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                    <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2vw,40px);"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
                </td>
                <%
                    }
                %>
            </tr>
            <%
                }
            %>
        </table>
        <%
        }
        else{
        %>
        <br><br><br><br>
        <h1 style="width: 100%; text-align:center;"> 업로드한 상품이 없어요!. </h1>
        <%
            }
        %>
    </center>
</center>
<center>
    <hr>
    동국대학교
    Copyright © 2023 · All Rights Reserved
</center>
</body>
</html>