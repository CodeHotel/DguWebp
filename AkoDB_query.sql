
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
SELECT row_to_json(n_user) FROM n_user;

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
SELECT row_to_json(n_user) FROM n_user;



-- delete user from akouser
--   safely delete user

-- deleteUser(user_id):
DELETE FROM akouser WHERE id=$user_id;

-- example
DELETE FROM akouser WHERE id=17;



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
--   string_array(hashtag): '$hashtag1, $hashtag2, $hashtag3...'

-- addProduct(title, price, image, description, owner_id, string_array(hashtag))
WITH product_info AS (
    INSERT INTO product(title, price, image, description, owner_id) 
    VALUES ($title, $price, $image, $description, $owner_id)
    RETURNING id
)
INSERT INTO hashtag(tag, product_id)
SELECT x, (SELECT id FROM product_info)
FROM UNNEST(string_to_array($string_array(hashtag), ',')) x;


-- example
WITH product_info AS (
    INSERT INTO product(title, price, image, description, owner_id) 
    VALUES ('camera', 100000, 'img', 'desc', 13)
    RETURNING id
)
INSERT INTO hashtag(tag, product_id)
SELECT x, (SELECT id FROM product_info)
FROM UNNEST(string_to_array('camera,polaroid,trip,image', ',')) x;



-- modify product
--   product_id: product id (from DB)
--   string_array(hashtag): '$hashtag1, $hashtag2, $hashtag3...'

-- modifyProduct(product_id, title, price, image, description, string_array(hashtag))
WITH product_info AS (
    UPDATE product SET title=$title, price=$price, image=$image, description=$description 
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
    UPDATE product SET title='dummy', price=100000, image='book.png', description='real shit' 
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
    FROM product p WHERE p.owner_id=14
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
    'title', (SELECT title FROM product_info),
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
    'title', (SELECT title FROM product_info),
    'price', (SELECT price FROM product_info),
    'image', (SELECT image FROM product_info),
    'description', (SELECT description FROM product_info),
    'views', (SELECT views FROM product_info),
    'user_info', (SELECT row_to_json(user_info) FROM user_info),
    'hashtags', array_to_json(array(
        SELECT * FROM hashtags
    ))
);



-- add to wishlist

-- addWishList(user_id, product_id)
WITH info AS (
    SELECT p.id, p.owner_id, u.id AS user_id
    FROM product p, akouser u
    WHERE u.id=$user_id AND p.id=$product_id
)
INSERT INTO list_wish(owner_id, buyer_id, product_id)
SELECT
    (SELECT owner_id FROM info),
    (SELECT user_id FROM info), 
    (SELECT id FROM info)
WHERE NOT EXISTS (
    SELECT id FROM list_wish w
    WHERE
        w.product_id=(SELECT id FROM info) AND
        w.buyer_id=(SELECT user_id FROM info)
);

-- example
WITH info AS (
    SELECT p.id, p.owner_id, u.id AS user_id
    FROM product p, akouser u
    WHERE u.id=12 AND p.id=2
)
INSERT INTO list_wish(owner_id, buyer_id, product_id)
SELECT
    (SELECT owner_id FROM info),
    (SELECT user_id FROM info), 
    (SELECT id FROM info)
WHERE NOT EXISTS (
    SELECT id FROM list_wish w
    WHERE
        w.product_id=(SELECT id FROM info) AND
        w.buyer_id=(SELECT user_id FROM info)
);




-- get wishlist of products

-- getWishList(user_id)
WITH w_list AS (
    SELECT w.product_id FROM list_wish w WHERE w.buyer_id=$user_id
),
products AS (
    SELECT p.* FROM product p
    WHERE p.id=ANY(SELECT product_id FROM w_list)
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'user_info', (
            SELECT row_to_json(user_info) 
            FROM (
                SELECT u.id, u.nickname 
                FROM akouser u WHERE u.id=p.owner_id
            ) AS user_info),
        'hashtags', (
            SELECT array_to_json(array(
                SELECT h.tag
                FROM hashtag h WHERE h.product_id=p.id
            ))) 
    ) FROM products p
));

-- example
WITH products AS (
    SELECT p.* FROM product p 
    WHERE p.id=ANY(
        SELECT product_id FROM (
            SELECT w.product_id FROM list_wish w 
            WHERE w.buyer_id=14
        ) x
    )
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'user_info', (
            SELECT row_to_json(user_info) FROM (
                SELECT u.id, u.nickname 
                FROM akouser u WHERE u.id=p.owner_id
            ) AS user_info),
        'hashtags', (
            SELECT array_to_json(array(
                SELECT h.tag
                FROM hashtag h WHERE h.product_id=p.id
            ))) 
    ) FROM products p
));



-- list of search results
--   string_array(keyword): '$hashtag1, $hashtag2, $hashtag3...'
--   string(pattern): '$keyword1 & $keyword2'
--   weight: multiplier which will be applied to each section
--     - count of matching hashtag * h_weight
--     - title contains such keyword * t_weight
--     - description relevance value of comparing with the pattern * d_weight
--   keyword: finds the exact match in hashtag or title that contains such keywords
--   pattern: finds the pattern inside description

-- search(h_weight, t_weight, d_weight, string_array(keyword), string(pattern))
WITH search_result AS (
    WITH h_score AS (
        SELECT s.id, COUNT(s.id) AS score FROM (
            SELECT h.product_id AS id FROM hashtag h
            WHERE h.tag LIKE ANY(string_to_array($keyword, ','))
        ) s
        GROUP BY s.id
    ),
    t_score AS (
        SELECT id, 1 AS score FROM (
            SELECT p.id AS id FROM product p
            WHERE p.title ~ ANY(string_to_array($keyword, ','))
        ) t
    ),
    d_score AS (
        SELECT id, score FROM (
            SELECT ts_rank_cd(
                to_tsvector(p.description), 
                to_tsquery($pattern)
            ) AS score, p.id 
            FROM product p
        ) d
    ),
    product_ids AS (
        SELECT id FROM h_score UNION 
        SELECT id FROM t_score UNION 
        SELECT id FROM d_score
    )
    SELECT p.id, (
        (COALESCE((SELECT score FROM h_score WHERE h_score.id=p.id), 0) * h_weight) +
        (COALESCE((SELECT score FROM t_score WHERE t_score.id=p.id), 0) * t_weight) +
        (COALESCE((SELECT score FROM d_score WHERE d_score.id=p.id), 0) * d_weight)
    ) AS score FROM product_ids p
),
products AS (
    SELECT p.*, r.score FROM product p, search_result r
    WHERE p.id=ANY(SELECT id FROM search_result) AND p.id=r.id AND score > 0
    ORDER BY score DESC
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'user_info', (
            SELECT row_to_json(user_info) 
            FROM (
                SELECT u.id, u.nickname 
                FROM akouser u WHERE u.id=p.owner_id
            ) AS user_info),
        'hashtags', (
            SELECT array_to_json(array(
                SELECT h.tag
                FROM hashtag h WHERE h.product_id=p.id
            ))) 
    ) FROM products p
));

-- example
WITH search_result AS (
    WITH h_score AS (
        SELECT s.id, COUNT(s.id) AS score FROM (
            SELECT h.product_id AS id FROM hashtag h
            WHERE h.tag LIKE ANY(string_to_array('book,phone', ','))
        ) s
        GROUP BY s.id
    ),
    t_score AS (
        SELECT id, 1 AS score FROM (
            SELECT p.id AS id FROM product p
            WHERE p.title ~ ANY(string_to_array('book,phone', ','))
        ) t
    ),
    d_score AS (
        SELECT id, score FROM (
            SELECT ts_rank_cd(
                to_tsvector(p.description), 
                to_tsquery('desc|phone')
            ) AS score, p.id 
            FROM product p
        ) d
    ),
    product_ids AS (
        SELECT id FROM h_score UNION 
        SELECT id FROM t_score UNION 
        SELECT id FROM d_score
    )
    SELECT p.id, (
        (COALESCE((SELECT score FROM h_score WHERE h_score.id=p.id), 0) * 1) +
        (COALESCE((SELECT score FROM t_score WHERE t_score.id=p.id), 0) * 0.5) +
        (COALESCE((SELECT score FROM d_score WHERE d_score.id=p.id), 0) * 0.1)
    ) AS score FROM product_ids p
),
products AS (
    SELECT p.*, r.score FROM product p, search_result r
    WHERE p.id=ANY(SELECT id FROM search_result) AND p.id=r.id AND score > 0
    ORDER BY score DESC
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'user_info', (
            SELECT row_to_json(user_info) 
            FROM (
                SELECT u.id, u.nickname 
                FROM akouser u WHERE u.id=p.owner_id
            ) AS user_info),
        'hashtags', (
            SELECT array_to_json(array(
                SELECT h.tag
                FROM hashtag h WHERE h.product_id=p.id
            ))) 
    ) FROM products p
));



-- request for buy
--   user_id: user id (from DB)
--   product_id: product id (from DB)

-- buyRequest(user_id, product_id)
WITH info AS (
    SELECT p.id, p.owner_id, u.id AS buyer_id
    FROM product p, akouser u 
    WHERE u.id=$user_id AND p.id=$product_id
),
n_progress AS (
    INSERT INTO list_progress(owner_id, buyer_id, product_id, progress)
    SELECT
        (SELECT owner_id FROM info),
        (SELECT buyer_id FROM info), 
        (SELECT id FROM info),
        'applied'
    WHERE NOT EXISTS (
        SELECT id FROM list_progress p
        WHERE
            p.product_id=(SELECT id FROM info) AND
            p.buyer_id=(SELECT buyer_id FROM info)
    )
    RETURNING *
),
del_wish AS (
    DELETE FROM list_wish w
    WHERE 
        w.buyer_id=(SELECT buyer_id FROM n_progress) AND
        w.product_id=(SELECT product_id FROM n_progress)
),
n_chat AS (
    INSERT INTO list_chat(user1, user2)
    VALUES (
        (SELECT owner_id FROM n_progress),
        (SELECT buyer_id FROM n_progress)
    )
    RETURNING *
)
SELECT json_build_object(
    'id', (SELECT id FROM n_chat),
    'user1', (SELECT user1 FROM n_chat),
    'user2', (SELECT user2 FROM n_chat),
    'last_time', (SELECT last_time FROM n_chat)
);

-- example
WITH info AS (
    SELECT p.id, p.owner_id, u.id AS buyer_id
    FROM product p, akouser u 
    WHERE p.id=3 AND u.id=13
),
n_progress AS (
    INSERT INTO list_progress(owner_id, buyer_id, product_id, progress)
    SELECT
        (SELECT owner_id FROM info),
        (SELECT buyer_id FROM info), 
        (SELECT id FROM info),
        'applied'
    WHERE NOT EXISTS (
        SELECT id FROM list_progress p
        WHERE
            p.product_id=(SELECT id FROM info) AND
            p.buyer_id=(SELECT buyer_id FROM info)
    )
    RETURNING *
),
del_wish AS (
    DELETE FROM list_wish w
    WHERE 
        w.buyer_id=(SELECT buyer_id FROM n_progress) AND
        w.product_id=(SELECT product_id FROM n_progress)
),
n_chat AS (
    INSERT INTO list_chat(user1, user2)
    VALUES (
        (SELECT owner_id FROM n_progress),
        (SELECT buyer_id FROM n_progress)
    )
    RETURNING *
)
SELECT json_build_object(
    'id', (SELECT id FROM n_chat),
    'user1', (SELECT user1 FROM n_chat),
    'user2', (SELECT user2 FROM n_chat),
    'last_time', (SELECT last_time FROM n_chat)
);



-- get buy requests
--   user_id: user_id (from DB)

-- getBuyRequests(user_id)
WITH requests AS (
    SELECT r.id, r.buyer_id, r.product_id, r.progress
    FROM list_progress r
    WHERE r.owner_id=$user_id
),
p_info AS (
    SELECT p.id, p.title, p.price, p.image, p.description, p.views
    FROM product p 
    WHERE p.id IN (
        SELECT r.product_id FROM requests r
        WHERE r.progress='applied'
    )
)
SELECT json_build_object(
    'id', (SELECT id FROM requests),
    'buyer_id', (SELECT buyer_id FROM requests),
    'products', (SELECT row_to_json(p_info) FROM p_info)
);


-- example
WITH requests AS (
    SELECT r.id, r.buyer_id, r.product_id, r.progress
    FROM list_progress r
    WHERE r.owner_id=13
),
p_info AS (
    SELECT p.id, p.title, p.price, p.image, p.description, p.views
    FROM product p 
    WHERE p.id IN (
        SELECT r.product_id FROM requests r
        WHERE r.progress='applied'
    )
)
SELECT json_build_object(
    'id', (SELECT id FROM requests),
    'buyer_id', (SELECT buyer_id FROM requests),
    'products', (SELECT row_to_json(p_info) FROM p_info)
);



-- accept buy request
--   user_id: user id (from DB)
--   product_id: product id (from DB)

-- acceptBuyRequest(user_id, product_id)