<%@ page import="DataBeans.*"%>
<%@ page import="java.util.ArrayList" %><%--
  Created by IntelliJ IDEA.
  User: mh7cp
  Date: 2023-12-18
  Time: 오후 6:01
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%request.setCharacterEncoding("UTF-8");%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아코마켓-검색</title>
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
            <td style="width:12%;margin:0;padding: 0;color:#4FC3F7; font-size:clamp(1px, 2.3vw,35px)" onclick="window.location.href = '${pageContext.request.contextPath}/Title.jsp';"> &nbsp;#아코마켓</td>
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
                                <button id="WishList" onclick="window.location.href = '${pageContext.request.contextPath}/WishList.jsp';" style="padding:0.2em; width:80%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                                    장바구니
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
    ArrayList<ProductData> searchResults = PostgreInterface.search(1.0, 0.5, 1.0,
            PostgreInterface.parseHashtag(request.getParameter("searchKeyWord")), request.getParameter("searchKeyWord"));
%>
<form id="searchForm" method="post" action="SearchResults.jsp?page=1" style="width: 100%; text-align: center;font-family: BaeMinHanna,system-ui">
    <div style="display: flex; justify-content: center; align-items: center; ">
    <div id="hashtagInput" contenteditable="true" style="padding-top: 1.0em; width: 55%; height: 1.9em; border-radius: 1.5em; border: solid 1px #717D7E; padding-left: 2em; background-color:#ffffff; font-family: BaeMinJua, system-ui; font-size: 1em; color: #273746;"></div>
    <input type="text" id="hiddenInput" name="searchKeyWord" style="display: none;">
    <input type="submit" value="G O !" style="width: 8%; height: 3em; border-radius: 1.5em; border: solid 1px #717D7E; font-family: BaeMinJua, system-ui; font-size: 1.1em; color: white; background-color: #D35400">
    </div>
        <div style="width:100%">
        <br>
        <input type="radio" name="orderOption" value="high">높은가격순
        <input type="radio" name="orderOption" value="old">낮은가격순
        <input type="radio" name="orderOption" value="new">최신등록순
        <input type="checkbox" name="seeAvailOnly">거래가능 상품만 보기
        <br>
        가격범위 설정: <input type="number" name="lowLimit" style="border-radius:0.5em;border:solid 1px gray;width:6em"> ~ <input type="number" name="highLimit" style="border-radius:0.5em;border:solid 1px gray;width:6em">
    </div>
</form>
<br><br><br>
<center>
    <%
        int pageLimit = 12;
        int pg = Integer.parseInt(request.getParameter("page"))-1;
        int from = pg*pageLimit/3;
        int to = from+pageLimit/3;
        if(searchResults.size()!=0){
    %>
    <table style="width: 80%; text-align: center;">
        <%
            for(int f = pg*pageLimit/3; (f<(searchResults.size()%3!=0?1:0) + searchResults.size()/3)&&f<to; f++){
        %>
        <tr style="height:auto;">
            <%
                for(int pd = 0; pd<3; pd++){
                    if(3*f+pd>=searchResults.size()) continue;
                    Product product = searchResults.get(3*f+pd).prodcut;
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
                <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2vw,40px);"><a style = "text-decoration: none; color: orangered;" onclick="fetch('/buyrequest?productId=<%=product.getId()%>')">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:clamp(1px, 2vw,40px);"><a style = "text-decoration: none; color: orangered;" onclick="fetch('/addwishlist?productId=<%=product.getId()%>')">장바구니</a></p>
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
    <h1 style="width: 100%; text-align:center;"> 검색 결과가 없습니다. </h1>
    <%
        }
    %>
</center>
<script>
    function gotoPage() {
        var form = document.getElementById('myForm');
        form.action = 'search.jsp?page=2';
        form.submit();
    }
</script>
<%
    if(searchResults.size()!=0){
%>
<center>
    <br><br>
    <div style="margin: 20px; text-align: center; background-color: transparent; border: none; font-family: BaeMinJua, system-ui;">
        <a href="#" style = "color: black; padding: 8px 16px; text-decoration: none; transition: color .3s; margin: 0 4px;">&lt&lt</a>
        <%
            for(int pgi = 0; pgi<(searchResults.size()-1)/12 + 1; pgi++){
                if(pgi==pg){
        %>
        <a href="#" onclick="var form=document.getElementById('searchForm'); form.action='SearchResults.jsp?page=<%=pgi+1%>'; form.submit();" style = "color: #D35400; padding: 8px 16px; text-decoration: none; transition: color .3s; margin: 0 4px;"><%=pgi+1%></a>
        <%
                }else{
        %>
        <a href="#" onclick="var form=document.getElementById('searchForm'); form.action='SearchResults.jsp?page=<%=pgi+1%>'; form.submit();" style = "color: black; padding: 8px 16px; text-decoration: none; transition: color .3s; margin: 0 4px;"><%=pgi+1%></a>
        <%
                }
            }
        %>
        <a href="#" style = "color: black; padding: 8px 16px; text-decoration: none; transition: color .3s; margin: 0 4px;">>></a>
    </div>
    <br><br>
    <center>
        <hr>
        동국대학교
        Copyright © 2023 · All Rights Reserved
    </center>
</center>
<%
    }
%>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const hashtagInput = document.getElementById('hashtagInput');
        const searchKeyword = '<%= request.getParameter("searchKeyWord") %>';

        // Set the initial value retrieved from the server-side parameter
        hashtagInput.innerHTML = searchKeyword;
    });
    const hashtagInput = document.getElementById('hashtagInput');
    const hiddenInput = document.getElementById('hiddenInput');
    let isComposing = false;

    hashtagInput.addEventListener('compositionstart', () => {
        isComposing = true;
    });

    hashtagInput.addEventListener('compositionend', () => {
        isComposing = false;
        formatHashtags(); // Call formatHashtags after composition ends
    });

    hashtagInput.addEventListener('input', () => {
        if (!isComposing) {
            formatHashtags(); // Call formatHashtags only if not in the middle of composition
        }
    });

    function formatHashtags() {
        if (!isComposing) { // Check if not composing
            const fullText = getTextFromDiv(hashtagInput);
            const caretPos = getCaretPosition(hashtagInput);

            // Set the value of the hidden input to the unformatted full text
            hiddenInput.value = fullText;

            hashtagInput.innerHTML = fullText.replace(/(#\S+)/g, '<span class="hashtag" style="color: lightblue;">$1</span>');
            setCaretPosition(hashtagInput, caretPos);
        }
    }

    function getTextFromDiv(div) {
        return Array.from(div.childNodes).reduce((text, node) => {
            return text + (node.nodeType === 3 ? node.nodeValue : node.innerText);
        }, '');
    }
    function getCaretPosition(element) {
        let position = 0;
        const selection = window.getSelection();
        if (selection.rangeCount !== 0) {
            const range = selection.getRangeAt(0);
            const preCaretRange = range.cloneRange();
            preCaretRange.selectNodeContents(element);
            preCaretRange.setEnd(range.endContainer, range.endOffset);
            position = preCaretRange.toString().length;
        }
        return position;
    }

    function setCaretPosition(element, position) {
        const range = document.createRange();
        const sel = window.getSelection();
        let currentPos = 0;
        let found = false;

        function setRange(node) {
            if (node.nodeType === Node.TEXT_NODE) {
                if (currentPos + node.length >= position) {
                    range.setStart(node, position - currentPos);
                    range.collapse(true);
                    found = true;
                } else {
                    currentPos += node.length;
                }
            } else if (node.nodeType === Node.ELEMENT_NODE) {
                for (const child of node.childNodes) {
                    setRange(child);
                    if (found) break;
                }
            }
        }

        for (const child of element.childNodes) {
            setRange(child);
            if (found) break;
        }

        if (found) {
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }

</script>
</body>
</html>