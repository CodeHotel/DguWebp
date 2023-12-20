
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
    VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
    RETURNING id, login_id, login_pw, nickname, image, campus, deparment, degree, student_id
), 
n_auth AS (
    INSERT INTO authentication (id_card, phone, user_id) 
    VALUES (?, ?, (SELECT id FROM n_user)) 
), 
n_pay AS (
    INSERT INTO payment (user_id, point) 
    VALUES ((SELECT id FROM n_user), 50000)
)
SELECT row_to_json(n_user) FROM n_user;



-- check if id is duplicated

-- isIdExists(id)
SELECT u.id FROM akouser u WHERE u.id=?;



-- check if nickname is duplicated

-- isNickExists(nick)
SELECT u.nickname FROM akouser u WHERE u.nickname=?;


-- insert admin user to akouser 
--   pw: SHA-256 hash value, varchar(256)

-- registerAdmin(id, pw)
WITH n_user AS (
    INSERT INTO akouser (login_id, login_pw, nickname)
    VALUES (?, ?, ?) 
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
DELETE FROM akouser WHERE id=17;



-- get full user data(including password and phone etc) for admin verification
--   return: json object

-- getFullUserData(nickname):
WITH result AS (
    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized
    FROM akouser akouser, authentication auth
    WHERE akouser.nickname=? AND akouser.id=auth.user_id
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
UPDATE authentication SET authorized=true WHERE user_id=14;



-- compare if user login credentials are valid
--   login_id: id which is used on login
--   login_pw: hash value of password
--   return: user id (on success, null will be returned on fail)

-- userAuth(login_id, login_pw):
SELECT akouser.id FROM akouser WHERE login_id=? AND login_pw=?;



-- insert(paramerters) to product
--   image: varchar(45)
--   description: varchar(1200)
--   owner_id: user id (fromDB)
--   string_array(hashtag): '$hashtag1, $hashtag2, $hashtag3...'

-- addProduct(title, price, image, description, owner_id, string_array(hashtag))
WITH product_info AS (
    INSERT INTO product(title, price, image, description, owner_id) 
    VALUES (?, ?, ?, ?, ?)
    RETURNING *
), 
hashtags AS (
    SELECT * FROM UNNEST(string_to_array(?, ','))
),
n_hashtag AS (
    INSERT INTO hashtag(tag, product_id)
    SELECT x.*, (SELECT id FROM product_info)
    FROM hashtags x
)
SELECT json_build_object(
    'id', (SELECT id FROM product_info),
    'title', (SELECT title FROM product_info),
    'price', (SELECT price FROM product_info),
    'image', (SELECT image FROM product_info),
    'description', (SELECT description FROM product_info),
    'views', (SELECT views FROM product_info),
    'progress', (SELECT progress FROM product_info),
    'hashtags', array_to_json(array(
        SELECT * FROM hashtags
    ))
);



-- modify product
--   product_id: product id (from DB)
--   string_array(hashtag): '$hashtag1, $hashtag2, $hashtag3...'

-- modifyProduct(product_id, title, price, image, description, string_array(hashtag))
WITH product_info AS (
    UPDATE product SET title=?, price=?, image=?, description=? 
    WHERE product.id=?
    RETURNING id
), 
tags AS (
    SELECT * FROM UNNEST(string_to_array(?, ','))
), 
del AS (
    DELETE FROM hashtag 
    WHERE 
        product_id=(SELECT id FROM product_info) AND
        tag NOT IN (SELECT * FROM tags)
),
n_tags AS (
    INSERT INTO hashtag(tag, product_id)
    SELECT tags.* , (SELECT id FROM product_info)
    FROM tags 
    ON CONFLICT DO NOTHING
)
SELECT id FROM product_info;



-- delete product
--   safely delete product

-- deleteProduct(id)
DELETE FROM product WHERE product.id=?;



-- return non sensitive user data
--   user_id: user id (from DB)

-- getBriefUserData(user_id):
WITH user_info AS (
    SELECT * FROM akouser WHERE akouser.id=?
),
product_list AS (
    SELECT p.id, p.price, p.image, p.description, p.views 
    FROM product p WHERE p.owner_id=(SELECT id FROM user_info)
)
SELECT json_build_object(
    'id', (SELECT id FROM user_info),
    'login_id', (SELECT login_id FROM user_info),
    'nickname', (SELECT nickname FROM user_info),
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
    UPDATE product SET views=views+1
    WHERE product.id=?
    RETURNING *
),
user_info AS (
    SELECT u.id, u.nickname, u.image, u.campus, u.department, u.degree, u.student_id
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
    'progress', (SELECT progress FROM product_info),
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
    WHERE u.id=? AND p.id=?
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
WITH products AS (
    SELECT p.* FROM product p 
    WHERE p.id=ANY(
        SELECT product_id FROM (
            SELECT w.product_id FROM list_wish w 
            WHERE w.buyer_id=?
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
        'progress', p.progress,
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
            WHERE h.tag LIKE ANY(string_to_array(?, ','))
        ) s
        GROUP BY s.id
    ),
    t_score AS (
        SELECT id, 1 AS score FROM (
            SELECT p.id AS id FROM product p
            WHERE p.title ~ ANY(string_to_array(?, ','))
        ) t
    ),
    d_score AS (
        SELECT id, score FROM (
            SELECT ts_rank_cd(
                to_tsvector(p.description), 
                to_tsquery(?)
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
        (COALESCE((SELECT score FROM h_score WHERE h_score.id=p.id), 0) * ?) +
        (COALESCE((SELECT score FROM t_score WHERE t_score.id=p.id), 0) * ?) +
        (COALESCE((SELECT score FROM d_score WHERE d_score.id=p.id), 0) * ?)
    ) AS score FROM product_ids p
),
products AS (
    SELECT p.*, r.score FROM product p, search_result r
    WHERE p.id=ANY(SELECT id FROM search_result) AND p.id=r.id AND score > 0
    ORDER BY score DESC, p.views DESC
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'progress', p.progress,
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



-- create chat room

-- createChatRoom(user1_id, user2_id)
WITH info AS (
    SELECT ? AS user1, ? AS user2
)
INSERT INTO list_chat(user1, user2)
SELECT
    (SELECT user1 FROM info),
    (SELECT user2 FROM info)
WHERE NOT EXISTS (
    SELECT * FROM list_chat l
    WHERE
        (l.user1=(SELECT user1 FROM info) AND l.user2=(SELECT user2 FROM info)) OR
        (l.user2=(SELECT user1 FROM info) AND l.user1=(SELECT user2 FROM info))
);



-- request for buy
--   user_id: user id (from DB)
--   product_id: product id (from DB)

-- buyRequest(user_id, product_id, message)
WITH info AS (
    SELECT p.id, p.price, p.owner_id, u.id AS buyer_id
    FROM product p, akouser u 
    WHERE u.id=? AND p.id=?
),
n_progress AS (
    INSERT INTO list_trade(owner_id, buyer_id, product_id, progress)
    SELECT
        (SELECT owner_id FROM info),
        (SELECT buyer_id FROM info), 
        (SELECT id FROM info),
        'applied'
    WHERE NOT EXISTS (
        SELECT id FROM list_trade p
        WHERE
            p.product_id=(SELECT id FROM info) AND
            p.buyer_id=(SELECT buyer_id FROM info)
    )
    RETURNING *
),
user_pay AS (
    UPDATE payment SET point=payment.point-(SELECT price FROM info)
    WHERE payment.user_id=(SELECT buyer_id FROM info)
),
del_wish AS (
    DELETE FROM list_wish w
    WHERE 
        w.buyer_id=(SELECT buyer_id FROM n_progress) AND
        w.product_id=(SELECT product_id FROM n_progress)
),
l_chat AS (
    UPDATE list_chat AS c
    SET 
        last_chat_idx=c.last_chat_idx+1,
        last_chat=?,
        user1_read=
            CASE WHEN user1=(SELECT buyer_id FROM info)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT buyer_id FROM info)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE
        (user1=(SELECT owner_id FROM INFO) AND user2=(SELECT buyer_id FROM INFO)) OR
        (user2=(SELECT owner_id FROM INFO) AND user1=(SELECT buyer_id FROM INFO))
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender, system)
VALUES (
    (SELECT id FROM l_chat),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT last_chat FROM l_chat),
    (SELECT buyer_id FROM info),
    'request'::sys_msg_t
);



-- get buy requests
--   user_id: user_id (from DB)

-- getBuyRequests(user_id)
WITH requests AS (
    SELECT r.id, r.buyer_id, r.product_id, r.progress
    FROM list_trade r
    WHERE r.owner_id=? AND r.progress='applied'
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', r.id,
        'buyer', (
            SELECT row_to_json(u) FROM akouser u
            WHERE u.id=r.buyer_id
        ),
        'product', (
            SELECT row_to_json(p) FROM product p
            WHERE p.id=r.product_id
        ),
        'progress', r.progress
    ) FROM requests r
));


-- accept buy request
--   user_id: user id (from DB)
--   product_id: product id (from DB)

-- acceptBuyRequest(user_id, product_id, message)
WITH req_product AS (
    SELECT p.* FROM product p WHERE p.id=?
),
prog AS (
    UPDATE list_trade AS p SET progress='inprogress'
    WHERE 
        p.owner_id=(SELECT owner_id FROM req_product) AND
        p.buyer_id=? AND
        p.product_id=(SELECT id FROM req_product) AND
        p.progress='applied'::progress_t
    RETURNING *
),
u_product AS (
    UPDATE product AS p SET progress='inprogress'
    WHERE p.id=(SELECT product_id FROM prog)
),
l_chat AS (
    UPDATE list_chat AS c
    SET 
        last_chat_idx=c.last_chat_idx+1,
        last_chat=?,
        user1_read=
            CASE WHEN user1=(SELECT owner_id FROM prog)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT owner_id FROM prog)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE
        (c.user1=(SELECT owner_id FROM prog) AND c.user2=(SELECT buyer_id FROM prog)) OR
        (c.user2=(SELECT owner_id FROM prog) AND c.user1=(SELECT buyer_id FROM prog))
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender, system)
VALUES (
    (SELECT id FROM l_chat),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT last_chat FROM l_chat),
    (SELECT owner_id FROM prog),
    'accept'
);



-- cancel buy request
--   user_id: user id (from DB)
--   product_id: product id (from DB)

-- cancleBuyRequest(user_id, product_id)
WITH req AS (
    SELECT u.id, p.id AS product_id 
    FROM akouser u, product p
    WHERE u.id=? AND p.id=?
),
prog AS (
    DELETE FROM list_trade p
    WHERE (
        p.owner_id=(SELECT id FROM req) OR 
        p.buyer_id=(SELECT id FROM req)
        ) AND p.product_id=(SELECT product_id FROM req)
    RETURNING *
), 
can_product AS (
    UPDATE product AS p SET progress='none'::progress_t
    WHERE p.id=(SELECT product_id FROM prog)
    RETURNING *
),
buyer_pay AS (
    UPDATE payment SET point=payment.point+(SELECT price FROM can_product)
    WHERE payment.user_id=(SELECT buyer_id FROM prog)
),
l_chat AS (
    UPDATE list_chat AS c
    SET 
        last_chat_idx=c.last_chat_idx+1,
        last_chat=?,
        user1_read=
            CASE WHEN user1=(SELECT id FROM req)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT id FROM req)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE
        (c.user1=(SELECT owner_id FROM prog) AND c.user2=(SELECT buyer_id FROM prog)) OR
        (c.user2=(SELECT owner_id FROM prog) AND c.user1=(SELECT buyer_id FROM prog))
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender, system)
VALUES (
    (SELECT id FROM l_chat),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT last_chat FROM l_chat),
    (SELECT id FROM req),
    'cancel'::sys_msg_t
);



-- confirm give

-- confirmGive(product_id)
WITH req AS (
    UPDATE list_trade SET progress='sellergive'
    WHERE progress='inprogress' AND product_id=?
    RETURNING *
),
u_product AS (
    UPDATE product AS p SET progress='sellergive'
    WHERE p.id=(SELECT product_id FROM req)
),
l_chat AS (
    UPDATE list_chat AS c
    SET
        last_chat_idx=c.last_chat_idx+1,
        last_chat=?,
        user1_read=
            CASE WHEN user1=(SELECT owner_id FROM req)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT owner_id FROM req)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE c.user1=(SELECT owner_id FROM req) OR c.user2=(SELECT owner_id FROM req)
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender, system)
VALUES (
    (SELECT id FROM l_chat),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT last_chat FROM l_chat),
    (SELECT owner_id FROM req),
    'give'::sys_msg_t
);



-- confirm got

-- confirmGot(product_id, message)
WITH req AS (
    UPDATE list_trade AS s SET progress='soldout'
    WHERE s.progress='sellergive' AND s.product_id=?
    RETURNING *
),
l_chat AS (
    UPDATE list_chat AS c
    SET
        last_chat_idx=c.last_chat_idx+1,
        last_chat=?,
        user1_read=
            CASE WHEN user1=(SELECT buyer_id FROM req)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT buyer_id FROM req)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE
        (c.user1=(SELECT owner_id FROM req) AND c.user2=(SELECT buyer_id FROM req)) OR
        (c.user2=(SELECT owner_id FROM req) AND c.user1=(SELECT buyer_id FROM req))
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender, system)
VALUES (
    (SELECT id FROM l_chat),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT last_chat FROM l_chat),
    (SELECT owner_id FROM req),
    'got'::sys_msg_t
);



-- get chatroom list and preview data in json

-- getChatPreview
WITH l_chat AS (
    SELECT c.* FROM list_chat c
    WHERE c.user1=? OR c.user2=?
    ORDER BY c.last_time DESC
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', c.id,
        'user1', (
            SELECT row_to_json(u) FROM akouser u
            WHERE u.id=c.user1
        ),
        'user2', (
            SELECT row_to_json(u) FROM akouser u
            WHERE u.id=c.user2
        ),
        'user1_read', c.user1_read,
        'user2_read', c.user2_read,
        'last_chat', c.last_chat,
        'last_chat_idx', c.last_chat_idx,
        'last_time', c.last_time
    ) FROM l_chat c
));



-- get chat list

-- getChat(chat_id)
WITH l_chat AS (
    SELECT * FROM chat c WHERE id=?
    ORDER BY c.time 
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', c.id,
        'idx', c.idx,
        'message', c.message,
        'sender', c.sender,
        'time', c.time,
        'system', c.system
    ) FROM l_chat c
));



-- send chat

-- sendChat(user_id, chat_id, message)
WITH req AS (
    SELECT u.id, c.id AS chat_id, ? AS msg
    FROM akouser u, list_chat c
    WHERE u.id=? AND c.id=?
),
l_chat AS (
    UPDATE list_chat AS c
    SET
        last_chat_idx=c.last_chat_idx+1,
        last_chat=(SELECT msg FROM req),
        user1_read=
            CASE WHEN user1=(SELECT id FROM req)
            THEN c.last_chat_idx+1
            ELSE user1_read END,
        user2_read=
            CASE WHEN user2=(SELECT id FROM req)
            THEN c.last_chat_idx+1
            ELSE user2_read END
    WHERE c.id=(SELECT chat_id FROM req)
    RETURNING *
)
INSERT INTO chat(id, idx, message, sender)
VALUES (
    (SELECT chat_id FROM req),
    (SELECT last_chat_idx FROM l_chat),
    (SELECT msg FROM req),
    (SELECT id FROM req)
);



-- get popular items

-- getPopularItems()
WITH products AS (
    SELECT * FROM product
    ORDER BY views DESC
    LIMIT 3
)
SELECT array_to_json(array(
    SELECT json_build_object(
        'id', p.id,
        'title', p.title,
        'price', p.price,
        'image', p.image,
        'description', p.description,
        'views', p.views,
        'progress', p.progress,
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



-- add rating

-- addRating(rating, buyerId, sellerId)
UPDATE akouser SET rating = array_append(
    rating, ROW(?, ?)::rating_t
)
WHERE akouser.id=?;