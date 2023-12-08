
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
    RETURNING id, login_id, login_pw, nickname, image, campus, deparment, degree, student_id
),
n_auth AS (
    INSERT INTO authentication (id_card, phone, user_id) 
    VALUES ($id_card, $phone, (SELECT id FROM n_user))
),
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT row_to_json(n_user) FROM n_user;

-- example
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname, image, campus, deparment, degree, student_id)
    VALUES ('testid', '1234', 'test_user', 'test_img.png', 'seoul', 'computer science', 'undergraduate', '2020101010') 
    RETURNING id, login_id, login_pw, nickname, image, campus, deparment, degree, student_id
), 
n_auth AS (
    INSERT INTO authentication (id_card, phone, user_id) 
    VALUES ('id_image_1', '01012345555', (SELECT id FROM n_user)) 
), 
n_pay AS (
    INSERT INTO payment (user_id) 
    VALUES ((SELECT id FROM n_user))
)
SELECT row_to_json(n_user) FROM n_user;



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
DELETE FROM akouser WHERE id=15;



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



-- insert(paramerters) to product
--   image: varchar(45)
--   description: varchar(1200)
--   owner_id: user id (fromDB)

-- addProduct(price, image, description, owner_id, string_array(hashtag))
WITH product_info AS (
    INSERT INTO product(price, image, description, owner_id) 
    VALUES ($price, $image, $description, $owner_id)
    RETURNING id
)
INSERT INTO hashtag(tag, product_id)
SELECT x, (SELECT id FROM product_info)
FROM UNNEST(string_to_array($string_array(hashtag), ',')) x;


-- example
WITH product_info AS (
    INSERT INTO product(price, image, description, owner_id) 
    VALUES (100000, 'img', 'desc', 13)
    RETURNING id
)
INSERT INTO hashtag(tag, product_id)
SELECT x, (SELECT id FROM product_info)
FROM UNNEST(string_to_array('note,bicycle', ',')) x;



-- modify product
--   product_id: product id (from DB)

-- modifyProduct(product_id, price, image, description, string_array(hashtag))
WITH product_info AS (
    UPDATE product SET price=$price, image=$image, description=$description 
    WHERE product.id=$product_id
    RETURNING id
)
, tags AS (
    SELECT * FROM UNNEST(string_to_array(string_array(hashtag), ','))
)
, del AS (
    DELETE FROM hashtag 
    WHERE 
        product_id=(SELECT id FROM product_info) AND
        tag NOT IN (SELECT * FROM tags)
)
INSERT INTO hashtag(tag, product_id)
SELECT tags.* , (SELECT id FROM product_info)
FROM tags 
ON CONFLICT DO NOTHING;

-- example
WITH product_info AS (
    UPDATE product SET price=100000, image='book.png', description='real shit' 
    WHERE product.id=13
    RETURNING id
)
, tags AS (
    SELECT * FROM UNNEST(string_to_array('book,phone,laptop', ','))
)
, del AS (
    DELETE FROM hashtag 
    WHERE 
        product_id=(SELECT id FROM product_info) AND
        tag NOT IN (SELECT * FROM tags)
)
INSERT INTO hashtag(tag, product_id)
SELECT tags.* , (SELECT id FROM product_info)
FROM tags 
ON CONFLICT DO NOTHING;



-- delete product
--   safely delete product

-- deleteProduct(id)
DELETE FROM product WHERE product.id=$id;

-- example
DELETE FROM product WHERE product.id=11;



-- return non sensitive user data
--   user_id: user id (from DB)

-- getBriefUserData(user_id):
WITH user_info AS (
    SELECT * FROM akouser WHERE akouser.id=$user_id
),
product_list AS (
    SELECT p.id, p.price, p.image, p.description, p.views 
    FROM product p WHERE p.owner_id=$user_id
)
SELECT json_build_object(
    'id', (SELECT id FROM user_info),
    'image', (SELECT image FROM user_info),
    'campus', (SELECT campus FROM user_info),
    'deparment', (SELECT deparment FROM user_info),
    'degree', (SELECT degree FROM user_info),
    'student_id', (SELECT student_id FROM user_info),
    'rating', array_to_json((SELECT rating FROM user_info)),
    'products', array_to_json(array(
        SELECT row_to_json(product_list) FROM product_list
    ))
);

-- example
WITH user_info AS (
    SELECT * FROM akouser WHERE akouser.id=14
),
product_list AS (
    SELECT p.id, p.price, p.image, p.description, p.views 
    FROM product p WHERE p.owner_id=13
)
SELECT json_build_object(
    'id', (SELECT id FROM user_info),
    'image', (SELECT image FROM user_info),
    'campus', (SELECT campus FROM user_info),
    'deparment', (SELECT deparment FROM user_info),
    'degree', (SELECT degree FROM user_info),
    'student_id', (SELECT student_id FROM user_info),
    'rating', array_to_json((SELECT rating FROM user_info)),
    'products', array_to_json(array(
        SELECT row_to_json(product_list) FROM product_list
    ))
);



-- get product data
--   full data of product + seller data

-- getProductData(product_id)
WITH product_info AS (
    SELECT p.id, p.price, p.image, p.description, p.views, p.owner_id
    FROM product p WHERE p.id=$product_id
),
user_info AS (
    SELECT u.id, u.nickname, u.image, u.campus, u.deparment, u.degree, u.student_id
    FROM akouser u WHERE u.id=(SELECT owner_id FROM product_info)
),
hashtags AS (
    SELECT h.tag
    FROM hashtag h WHERE h.product_id=(SELECT id FROM product_info)
)
SELECT json_build_object(
    'id', (SELECT id FROM product_info),
    'price', (SELECT price FROM product_info),
    'image', (SELECT image FROM product_info),
    'description', (SELECT description FROM product_info),
    'views', (SELECT views FROM product_info),
    'user_info', (SELECT row_to_json(user_info) FROM user_info),
    'hashtags', array_to_json(array(
        SELECT * FROM hashtags
    ))
);

-- example
WITH product_info AS (
    SELECT p.id, p.price, p.image, p.description, p.views, p.owner_id
    FROM product p WHERE p.id=13
),
user_info AS (
    SELECT u.id, u.nickname, u.image, u.campus, u.deparment, u.degree, u.student_id
    FROM akouser u WHERE u.id=(SELECT owner_id FROM product_info)
),
hashtags AS (
    SELECT h.tag
    FROM hashtag h WHERE h.product_id=(SELECT id FROM product_info)
)
SELECT json_build_object(
    'id', (SELECT id FROM product_info),
    'price', (SELECT price FROM product_info),
    'image', (SELECT image FROM product_info),
    'description', (SELECT description FROM product_info),
    'views', (SELECT views FROM product_info),
    'user_info', (SELECT row_to_json(user_info) FROM user_info),
    'hashtags', array_to_json(array(
        SELECT * FROM hashtags
    ))
);



-- list of search results