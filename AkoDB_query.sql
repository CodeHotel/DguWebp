
-- insert(paramerters) to akouser
--   id: max 20 char
--   password: SHA-256 hash value, varchar(256)
--   nickname: max 20 char
--   nullable: id_card, phone, campus, deparment, degree, student_id
--   id_card: location of id_card image, max 100 char
--   image: location of image, max 100 char
--   deparment: max 45 char
--   return: user_id(in DB)

-- registerUser(id, pw, nickname, image, id_card, phone, campus, deparment, degree, student_id):
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname, image, campus, deparment, degree, student_id)
    VALUES ($id, $pw, $nickname, $img, $campus, $deparment, $degree, $student_id) 
    RETURNING *
),
n_auth AS (
    INSERT INTO authentication (id_card, phone, user_id) 
    VALUES ($id_card, $phone, (SELECT id FROM n_user))
),
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT * FROM n_user;

-- example
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname, image, campus, deparment, degree, student_id)
    VALUES ('testid', '1234', 'test_user', 'test_img.png', 'seoul', 'computer science', 'undergraduate', '2020101010') 
    RETURNING *
), 
n_auth AS (
    INSERT INTO authentication (id_card, phone, user_id) 
    VALUES ('id_image_1', '01012345555', (SELECT id FROM n_user)) 
), 
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT * FROM n_user;



-- insert admin user to akouser 
--   pw: SHA-256 hash value, varchar(256)

-- registerAdmin(id, pw)
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname)
    VALUES ($id, $pw, 'admin') 
    RETURNING *
), 
n_auth AS (
    INSERT INTO authentication (user_id, authorized) 
    VALUES ((SELECT id FROM n_user), true)
), 
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT * FROM n_user;

-- example
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname)
    VALUES ('test_admin', '1234', 'admin') 
    RETURNING *
), 
n_auth AS (
    INSERT INTO authentication (user_id, authorized) 
    VALUES ((SELECT id FROM n_user), true) 
), 
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT * FROM n_user;



-- delete user from akouser
--   safely delete user

-- deleteUser(user_id):
DELETE FROM akouser WHERE id=$user_id;

-- example
DELETE FROM akouser WHERE id=11;



-- get full user data(including password and phone etc) for admin verification
--   return: json object

-- getFullUserData(nickname):
WITH result AS (
    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized
    FROM akouser, authentication auth
    WHERE akouser.nickname=$nickname AND akouser.id=auth.user_id
)
SELECT row_to_json(result) FROM result;

-- example
WITH result AS (
    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized
    FROM akouser akouser, authentication auth
    WHERE akouser.nickname='test_user' AND akouser.id=auth.user_id
)
SELECT row_to_json(result) FROM result;



-- get full user data but for all not yet verified users for admin
--   return: json object

-- getPendingUsers():
WITH result AS (
    SELECT u.*, auth.id_card, auth.phone
    FROM akouser u, authentication auth
    WHERE auth.authorized=false AND u.id=auth.user_id
)
SELECT row_to_json(result) FROM result;



-- change user verification status to true
--   user_id: user id (from DB)

-- verifyUser(user_id):
UPDATE authentication SET authorized=true WHERE user_id=$user_id;

-- example
UPDATE authentication SET authorized=true WHERE user_id=14;



-- compare if user login credentials are valid
--   login_id: id which is used on login
--   login_pw: hash value of password
--   return: user id (on success, null will be returned on fail)

-- userAuth(login_id, login_pw):
SELECT akouser.id FROM akouser WHERE login_id=$login_id AND login_pw=$login_pw;

-- example
SELECT akouser.id FROM akouser WHERE login_id='testid' AND login_pw='1234';



-- return non sensitive user data
--   user_id: user id (from DB)

-- getBriefUserData(user_id):
WITH result AS (
    SELECT u.*, trade.*, wish.*,
    FROM akouser u, list_trade trade, list_wish wish
    WHERE 
        id=$user_id AND 
        (trade.owner_id=u.id OR trade.buyer_id=u.id) AND
        (wish.owner_id=u.id OR wish.buyer_id=u.id)
)
SELECT row_to_json(result) FROM result;

-- example
WITH result AS (
    SELECT u.*, trade.*, wish.*,
        trade.id , wish.*
    FROM akouser u, list_trade trade, list_wish wish
    WHERE 
        u.id=14 AND 
        (trade.owner_id=u.id OR trade.buyer_id=u.id) AND
        (wish.owner_id=u.id OR wish.buyer_id=u.id)
)
SELECT row_to_json(result) FROM result;
