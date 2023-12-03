--
-- DROP TABLES
--

DROP TABLE IF EXISTS list_wish;
DROP TABLE IF EXISTS list_tag;
DROP TABLE IF EXISTS list_sale;
DROP TABLE IF EXISTS list_purchase;
DROP TABLE IF EXISTS chat;
DROP TABLE IF EXISTS list_chat;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS hashtag;
DROP TABLE IF EXISTS akouser;
DROP TABLE IF EXISTS student;
DROP TYPE IF EXISTS degree_t;
DROP TYPE IF EXISTS campus_t;

--
-- CREATE TABLE `student`
--

CREATE TYPE campus_t AS enum('seoul','goyang','WISE');
CREATE TYPE degree_t AS enum('undergraduate','postgraduate','professor') ;
CREATE TABLE student (
  sid int check (sid > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  campus campus_t DEFAULT NULL,
  deparment varchar(45) DEFAULT NULL,
  degree degree_t DEFAULT NULL,
  student_id char(10) DEFAULT NULL,
  PRIMARY KEY (sid)
)  ;

--
-- CREATE TABLE `user`
--

CREATE TABLE akouser (
  uid int check (uid > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  id varchar(20) NOT NULL,
  pw varchar(256) NOT NULL,
  nickname varchar(20) NOT NULL,
  student_info int check (student_info > 0) NOT NULL,
  phone varchar(11) DEFAULT NULL,
  id_card varchar(100) DEFAULT NULL,
  image varchar(100) DEFAULT NULL,
  rating double precision NOT NULL DEFAULT '0',
  auth smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (uid)
,
  CONSTRAINT akouser_ibfk_1 FOREIGN KEY (student_info) REFERENCES student (sid) ON DELETE CASCADE
)  ;

CREATE INDEX akouser_ibfk_1 ON akouser (student_info);

--
-- CREATE TABLE `hashtag`
--

CREATE TABLE hashtag (
  hid int check (hid > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  tag varchar(50) DEFAULT NULL,
  PRIMARY KEY (hid)
) ;

--
-- CREATE TABLE `product`
--

CREATE TABLE product (
  pid int check (pid > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  price int check (price > 0) NOT NULL,
  image varchar(45) DEFAULT NULL,
  description varchar(200) DEFAULT NULL,
  soldout smallint NOT NULL DEFAULT '0',
  views bigint check (views > 0) NOT NULL DEFAULT '0',
  owner_id int check (owner_id > 0) NOT NULL,
  PRIMARY KEY (pid)
,
  CONSTRAINT fk_uid FOREIGN KEY (owner_id) REFERENCES akouser (uid)
)  ;

CREATE INDEX fk_uid ON product (owner_id);

--
-- CREATE TABLE `list_chat`
--

CREATE TABLE list_chat (
  id bigint check (id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  user1 int check (user1 > 0) NOT NULL,
  user2 int check (user2 > 0) NOT NULL,
  last_chat varchar(200) DEFAULT NULL,
  last_time timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
,
  CONSTRAINT list_chat_ibfk_1 FOREIGN KEY (user1) REFERENCES akouser (uid),
  CONSTRAINT list_chat_ibfk_2 FOREIGN KEY (user2) REFERENCES akouser (uid)
) ;

CREATE INDEX user1 ON list_chat (user1);
CREATE INDEX user2 ON list_chat (user2);

--
-- CREATE TABLE `chat`
--

CREATE TABLE chat (
  chat_id bigint check (chat_id > 0) NOT NULL,
  idx bigint check (idx > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  message varchar(200) NOT NULL,
  sender smallint NOT NULL,
  time timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idx,chat_id)
,
  CONSTRAINT chat_ibfk_1 FOREIGN KEY (chat_id) REFERENCES list_chat (id) ON DELETE CASCADE
) ;

CREATE INDEX chat_ibfk_1 ON chat (chat_id);

--
-- CREATE TABLE `list_purchase`
--

CREATE TABLE list_purchase (
  order_id bigint check (order_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  owner_id int check (owner_id > 0) NOT NULL,
  buyer_id int check (buyer_id > 0) NOT NULL,
  product_id int check (product_id > 0) NOT NULL,
  PRIMARY KEY (order_id)
,
  CONSTRAINT list_purchase_product_pid_fk FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE,
  CONSTRAINT list_purchase_user_uid_fk FOREIGN KEY (owner_id) REFERENCES akouser (uid),
  CONSTRAINT list_purchase_user_uid_fk2 FOREIGN KEY (buyer_id) REFERENCES akouser (uid)
) ;

CREATE INDEX list_purchase_product_pid_fk ON list_purchase (product_id);
CREATE INDEX list_purchase_user_uid_fk ON list_purchase (owner_id);
CREATE INDEX list_purchase_user_uid_fk2 ON list_purchase (buyer_id);

--
-- CREATE TABLE `list_sale`
--

CREATE TABLE list_sale (
  order_id bigint check (order_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  owner_id int check (owner_id > 0) NOT NULL,
  buyer_id int check (buyer_id > 0) NOT NULL,
  product_id int check (product_id > 0) NOT NULL,
  PRIMARY KEY (order_id)
,
  CONSTRAINT list_sale_product_pid_fk FOREIGN KEY (product_id) REFERENCES product (pid),
  CONSTRAINT list_sale_user_uid_fk FOREIGN KEY (owner_id) REFERENCES akouser (uid),
  CONSTRAINT list_sale_user_uid_fk2 FOREIGN KEY (buyer_id) REFERENCES akouser (uid)
) ;

CREATE INDEX list_sale_user_uid_fk ON list_sale (owner_id);
CREATE INDEX list_sale_user_uid_fk2 ON list_sale (buyer_id);
CREATE INDEX list_sale_product_pid_fk ON list_sale (product_id);

--
-- CREATE TABLE `list_tag`
--

CREATE TABLE list_tag (
  tag_id int check (tag_id > 0) NOT NULL,
  product_id int check (product_id > 0) NOT NULL,
  PRIMARY KEY (tag_id,product_id)
,
  CONSTRAINT list_tag_ibfk_1 FOREIGN KEY (tag_id) REFERENCES hashtag (hid) ON DELETE CASCADE,
  CONSTRAINT list_tag_ibfk_2 FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE
) ;

CREATE INDEX list_tag_ibfk_2 ON list_tag (product_id);

--
-- CREATE TABLE `list_wish`
--

CREATE TABLE list_wish (
  order_id bigint check (order_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  owner_id int check (owner_id > 0) NOT NULL,
  buyer_id int check (buyer_id > 0) NOT NULL,
  product_id int check (product_id > 0) NOT NULL,
  PRIMARY KEY (order_id)
,
  CONSTRAINT FK_product_id FOREIGN KEY (product_id) REFERENCES product (pid),
  CONSTRAINT list_wish_product_pid_fk FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE,
  CONSTRAINT list_wish_user_uid_fk FOREIGN KEY (owner_id) REFERENCES akouser (uid),
  CONSTRAINT list_wish_user_uid_fk2 FOREIGN KEY (buyer_id) REFERENCES akouser (uid)
) ;

CREATE INDEX list_wish_product_pid_fk ON list_wish (product_id);
CREATE INDEX list_wish_user_uid_fk ON list_wish (owner_id);
CREATE INDEX list_wish_user_uid_fk2 ON list_wish (buyer_id);
