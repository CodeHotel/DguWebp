<%--
  Created by IntelliJ IDEA.
  User: mh7cp
  Date: 2023-12-18
  Time: 오후 3:49
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아코마켓</title>
    <link rel="stylesheet" type="text/css" href="resources/css/ako-main.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body style="margin:0px;">
<script>
    $(document).ready(function() {
        $("#loginForm").submit(function(event) {
            event.preventDefault(); // Prevent the form from submitting via the browser.

            var loginId = $("#loginId").val();
            var loginPw = $("#loginPw").val();

            $.ajax({
                url: 'path/to/your/login/endpoint', // Replace with your endpoint URL.
                type: 'POST',
                data: {loginId: loginId, loginPw: loginPw},
                success: function(response) {
                    // Handle success. If response is not null, set session and refresh.
                    if(response !== null) {
                        // Set session and refresh page logic here.
                        window.location.reload(); // Example of a page refresh.
                    } else {
                        // Handle login failure.
                        alert("Invalid credentials");
                    }
                },
                error: function() {
                    // Handle error.
                    alert("Error in login");
                }
            });
        });
    });
</script>
<div id="topMenuBar" class="topMenu">
    <table style="width:100%;height:100%;table-layout: fixed">
        <tr>
            <td style="width:calc(var(--topMenu-height)*0.8); height:calc(var(--topMenu-height)*0.8); padding:0px; margin:0px">
                <img style="width:auto;height:calc(var(--topMenu-height) * 0.8);display:block;margin:0;padding:0" src="resources/images/AkoFace.png">
            </td>
            <td style="width:12%;margin:0;padding: 0;color:#4FC3F7;" onclick="window.location.href = '${pageContext.request.contextPath}';"> &nbsp;#아코마켓</td>
            <td style="width:10%;margin:0;padding: 0" onclick="window.location.href = '${pageContext.request.contextPath}';">중고구매</td>
            <td style="width:10%;margin:0;padding: 0">중고판매</td>
            <td></td>
            <td id="loginCell" style="width:7%;margin:0;padding: 0" onmouseenter=" document.getElementById('loginMenu').style.display = 'block';"
                onmouseleave=" document.getElementById('loginMenu').style.display = 'none';">로그인
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
                            <input type="submit" value="로그인" style="padding:0.2em; width:40%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                            <input type="button" value="회원가입" style="padding:0.2em; width:55%;border-radius:0.5em;font-family: BaeMinHanna;border:solid 1px white;background-color:#D35400;color:white">
                        </form>
                    </center>
                </div>
            </td>
        </tr>
    </table>
</div>
<div style="position: relative; width: 100%; background-image: url('resources/images/TitleBackground.png'); background-size: 100% auto; background-repeat: no-repeat; padding-top: 56.25%;">
    <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; flex-direction: column; justify-content: center; align-items: center;">
        <div style="font-family: BaeMinJua, system-ui; font-size: 6em;">아 코 마 켓</div><br>
        <div style="font-family: BaeMinJua, system-ui; font-size: 1.5em; color: #0000FF;">#멀리_찾지_말고 &nbsp;&nbsp;&nbsp;#학교에서_거래해</div>
        <form method="post" action="" style="width: 100%; text-align: center;">
            <input type="text" name="searchKeyWord" style="width: 55%; height: 3em; border-radius: 1.5em; border: solid 1px #717D7E; padding-left: 2em; font-family: BaeMinJua, system-ui; font-size: 1em; color: #273746" placeholder="#교과서 #공대 #겨울옷">
            <input type="submit" value="G O !" style="width: 8%; height: 3em; border-radius: 1.5em; border: solid 1px #717D7E; font-family: BaeMinJua, system-ui; font-size: 1.1em; color: white; background-color: #D35400">
        </form>
    </div>
</div>
<center>
    <div style="font-family: BaeMinHanna, system-ui; font-size: 3em; color: #4FC3F7;"><br>#인기상품 #핫한상품</div><br><br>
    <table style="width: 80%; text-align: center;">
        <tr>
            <td style="width: 30%; height:auto; display: inline-block; margin: 10px; border: 1px solid #ccc; padding: 10px; box-sizing: border-box; text-align: center;">
                <img style = "width: 70%; height: 30%; margin-bottom: 5px;" src="resources/images/AkoFace.png" alt="상품 이미지" class="product-image">
                <hr>
                <h2 style="font-family: BaeMinHanna, system-ui; font-size:20px"><a style = "text-decoration: none; color: black;" href="상품1_상세페이지_URL">상품1</a></h2>
                <p style = "font-family: BaeMinJua, system-ui; white-space: nowrap; overflow: hidden; overflow: hidden;">상품 설명이 여기에 들어갑니다. 상품 설명을 넣어 주세요.</p>
                <p style = "font-family: BaeMinJua, system-ui;"> #1 #2 </p>
                <p style = "font-family: BaeMinJua, system-ui;"> 가격 </p>
                <hr>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
            </td>
            <td style="width: 30%; height:auto; display: inline-block; margin: 10px; border: 1px solid #ccc; padding: 10px; box-sizing: border-box; text-align: center;">
                <img style = "width: 70%; height: 30%; margin-bottom: 5px;" src="resources/images/AkoFace.png" alt="상품 이미지" class="product-image">
                <hr>
                <h2 style="font-family: BaeMinHanna, system-ui; font-size:20px"><a style = "text-decoration: none; color: black;" href="상품1_상세페이지_URL">상품1</a></h2>
                <p style = "font-family: BaeMinJua, system-ui; white-space: nowrap; overflow: hidden; overflow: hidden;">상품 설명이 여기에 들어갑니다. 상품 설명을 넣어 주세요.</p>
                <p style = "font-family: BaeMinJua, system-ui;"> #1 #2 </p>
                <p style = "font-family: BaeMinJua, system-ui;"> 가격 </p>
                <hr>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
            </td>
            <td style="width: 30%; height:auto; display: inline-block; margin: 10px; border: 1px solid #ccc; padding: 10px; box-sizing: border-box; text-align: center;">
                <img style = "width: 70%; height: 30%; margin-bottom: 5px;" src="resources/images/AkoFace.png" alt="상품 이미지" class="product-image">
                <hr>
                <h2 style="font-family: BaeMinHanna, system-ui; font-size:20px"><a style = "text-decoration: none; color: black;" href="상품1_상세페이지_URL">상품1</a></h2>
                <p style = "font-family: BaeMinJua, system-ui; white-space: nowrap; overflow: hidden; overflow: hidden;">상품 설명이 여기에 들어갑니다. 상품 설명을 넣어 주세요.</p>
                <p style = "font-family: BaeMinJua, system-ui;"> #1 #2 </p>
                <p style = "font-family: BaeMinJua, system-ui;"> 가격 </p>
                <hr>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
            </td>
            <td style="width: 30%; height:auto; display: inline-block; margin: 10px; border: 1px solid #ccc; padding: 10px; box-sizing: border-box; text-align: center;">
                <img style = "width: 70%; height: 30%; margin-bottom: 5px;" src="resources/images/AkoFace.png" alt="상품 이미지" class="product-image">
                <hr>
                <h2 style="font-family: BaeMinHanna, system-ui; font-size:20px"><a style = "text-decoration: none; color: black;" href="상품1_상세페이지_URL">상품1</a></h2>
                <p style = "font-family: BaeMinJua, system-ui; white-space: nowrap; overflow: hidden; overflow: hidden;">상품 설명이 여기에 들어갑니다. 상품 설명을 넣어 주세요.</p>
                <p style = "font-family: BaeMinJua, system-ui;"> #1 #2 </p>
                <p style = "font-family: BaeMinJua, system-ui;"> 가격 </p>
                <hr>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
            </td>
            <td style="width: 30%; height:auto; display: inline-block; margin: 10px; border: 1px solid #ccc; padding: 10px; box-sizing: border-box; text-align: center;">
                <img style = "width: 70%; height: 30%; margin-bottom: 5px;" src="resources/images/AkoFace.png" alt="상품 이미지" class="product-image">
                <hr>
                <h2 style="font-family: BaeMinHanna, system-ui; font-size:20px"><a style = "text-decoration: none; color: black;" href="상품1_상세페이지_URL">상품1</a></h2>
                <p style = "font-family: BaeMinJua, system-ui; white-space: nowrap; overflow: hidden; overflow: hidden;">상품 설명이 여기에 들어갑니다. 상품 설명을 넣어 주세요.</p>
                <p style = "font-family: BaeMinJua, system-ui;"> #1 #2 </p>
                <p style = "font-family: BaeMinJua, system-ui;"> 가격 </p>
                <hr>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="구매_URL">구매하기</a></p>
                <p style="font-family: BaeMinJua, system-ui; font-size:15px"><a style = "text-decoration: none; color: orangered;" href="장바구니_URL">장바구니</a></p>
            </td>
        </tr>
    </table>
    <br><br>
</center>
<center>
    <hr>
    동국대학교
    Copyright © 2023 · All Rights Reserved
</center>
</body>
</html>
