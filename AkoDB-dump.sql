--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4 (Ubuntu 15.4-1ubuntu1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_akouser_uid_fk;
ALTER TABLE IF EXISTS ONLY public.list_wish DROP CONSTRAINT IF EXISTS list_wish_user_uid_fk2;
ALTER TABLE IF EXISTS ONLY public.list_wish DROP CONSTRAINT IF EXISTS list_wish_user_uid_fk;
ALTER TABLE IF EXISTS ONLY public.list_wish DROP CONSTRAINT IF EXISTS list_wish_product_pid_fk;
ALTER TABLE IF EXISTS ONLY public.list_trade DROP CONSTRAINT IF EXISTS list_trade_user_uid_fk2;
ALTER TABLE IF EXISTS ONLY public.list_trade DROP CONSTRAINT IF EXISTS list_trade_user_uid_fk;
ALTER TABLE IF EXISTS ONLY public.list_trade DROP CONSTRAINT IF EXISTS list_trade_product_pid_fk;
ALTER TABLE IF EXISTS ONLY public.list_tag DROP CONSTRAINT IF EXISTS list_tag_ibfk_2;
ALTER TABLE IF EXISTS ONLY public.list_tag DROP CONSTRAINT IF EXISTS list_tag_ibfk_1;
ALTER TABLE IF EXISTS ONLY public.list_chat DROP CONSTRAINT IF EXISTS list_chat_ibfk_2;
ALTER TABLE IF EXISTS ONLY public.list_chat DROP CONSTRAINT IF EXISTS list_chat_ibfk_1;
ALTER TABLE IF EXISTS ONLY public.product DROP CONSTRAINT IF EXISTS fk_uid;
ALTER TABLE IF EXISTS ONLY public.list_wish DROP CONSTRAINT IF EXISTS fk_product_id;
ALTER TABLE IF EXISTS ONLY public.chat DROP CONSTRAINT IF EXISTS chat_ibfk_1;
ALTER TABLE IF EXISTS ONLY public.authentication DROP CONSTRAINT IF EXISTS authentication_akouser_uid_fk;
DROP INDEX IF EXISTS public.user2;
DROP INDEX IF EXISTS public.user1;
DROP INDEX IF EXISTS public.list_wish_user_uid_fk2;
DROP INDEX IF EXISTS public.list_wish_user_uid_fk;
DROP INDEX IF EXISTS public.list_wish_product_pid_fk;
DROP INDEX IF EXISTS public.list_trade_user_uid_fk2;
DROP INDEX IF EXISTS public.list_trade_user_uid_fk;
DROP INDEX IF EXISTS public.list_trade_product_pid_fk;
DROP INDEX IF EXISTS public.list_tag_ibfk_2;
DROP INDEX IF EXISTS public.fk_uid;
DROP INDEX IF EXISTS public.chat_ibfk_1;
ALTER TABLE IF EXISTS ONLY public.product DROP CONSTRAINT IF EXISTS product_pkey;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_pkey;
ALTER TABLE IF EXISTS ONLY public.list_wish DROP CONSTRAINT IF EXISTS list_wish_pkey;
ALTER TABLE IF EXISTS ONLY public.list_trade DROP CONSTRAINT IF EXISTS list_trade_pkey;
ALTER TABLE IF EXISTS ONLY public.list_tag DROP CONSTRAINT IF EXISTS list_tag_pkey;
ALTER TABLE IF EXISTS ONLY public.list_chat DROP CONSTRAINT IF EXISTS list_chat_pkey;
ALTER TABLE IF EXISTS ONLY public.hashtag DROP CONSTRAINT IF EXISTS hashtag_pkey;
ALTER TABLE IF EXISTS ONLY public.chat DROP CONSTRAINT IF EXISTS chat_pkey;
ALTER TABLE IF EXISTS ONLY public.authentication DROP CONSTRAINT IF EXISTS authentication_pkey;
ALTER TABLE IF EXISTS ONLY public.akouser DROP CONSTRAINT IF EXISTS akouser_pkey;
DROP TABLE IF EXISTS public.product;
DROP TABLE IF EXISTS public.payment;
DROP TABLE IF EXISTS public.list_wish;
DROP TABLE IF EXISTS public.list_tag;
DROP TABLE IF EXISTS public.list_trade;
DROP TABLE IF EXISTS public.list_chat;
DROP TABLE IF EXISTS public.hashtag;
DROP TABLE IF EXISTS public.chat;
DROP TABLE IF EXISTS public.authentication;
DROP TABLE IF EXISTS public.akouser;
DROP TYPE IF EXISTS public.rating_t;
DROP TYPE IF EXISTS public.progress_t;
DROP TYPE IF EXISTS public.degree_t;
DROP TYPE IF EXISTS public.campus_t;
--
-- Name: campus_t; Type: TYPE; Schema: public; Owner: akomarket
--

CREATE TYPE public.campus_t AS ENUM (
    'seoul',
    'goyang',
    'WISE'
);


ALTER TYPE public.campus_t OWNER TO akomarket;

--
-- Name: degree_t; Type: TYPE; Schema: public; Owner: akomarket
--

CREATE TYPE public.degree_t AS ENUM (
    'undergraduate',
    'postgraduate',
    'professor',
    'staff'
);


ALTER TYPE public.degree_t OWNER TO akomarket;

--
-- Name: progress_t; Type: TYPE; Schema: public; Owner: akomarket
--

CREATE TYPE public.progress_t AS ENUM (
    'null',
    'applied',
    'inprogress',
    'soldout'
);


ALTER TYPE public.progress_t OWNER TO akomarket;

--
-- Name: rating_t; Type: TYPE; Schema: public; Owner: akomarket
--

CREATE TYPE public.rating_t AS (
	rating double precision,
	user_id integer
);


ALTER TYPE public.rating_t OWNER TO akomarket;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: akouser; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.akouser (
    id integer NOT NULL,
    login_id character varying(20) NOT NULL,
    login_pw character varying(256) NOT NULL,
    nickname character varying(20) NOT NULL,
    image character varying(100) DEFAULT NULL::character varying,
    campus public.campus_t,
    deparment character varying(45),
    degree public.degree_t,
    student_id character(10),
    rating public.rating_t[] DEFAULT ARRAY[]::public.rating_t[],
    admin boolean DEFAULT false NOT NULL,
    CONSTRAINT akouser_uid_check CHECK ((id > 0))
);


ALTER TABLE public.akouser OWNER TO akomarket;

--
-- Name: akouser_uid_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.akouser ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.akouser_uid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: authentication; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.authentication (
    id integer NOT NULL,
    id_card character varying(100),
    phone character(11),
    authorized boolean DEFAULT false,
    user_id integer NOT NULL,
    CONSTRAINT authentication_auth_id_check CHECK ((id > 0))
);


ALTER TABLE public.authentication OWNER TO akomarket;

--
-- Name: authentication_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.authentication ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.authentication_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: chat; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.chat (
    id bigint NOT NULL,
    idx bigint NOT NULL,
    message character varying(200) NOT NULL,
    sender smallint NOT NULL,
    "time" timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    system boolean DEFAULT false NOT NULL,
    CONSTRAINT chat_chat_id_check CHECK ((id > 0)),
    CONSTRAINT chat_idx_check CHECK ((idx > 0))
);


ALTER TABLE public.chat OWNER TO akomarket;

--
-- Name: chat_idx_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.chat ALTER COLUMN idx ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.chat_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hashtag; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.hashtag (
    id integer NOT NULL,
    tag character varying(50) DEFAULT NULL::character varying,
    CONSTRAINT hashtag_hid_check CHECK ((id > 0))
);


ALTER TABLE public.hashtag OWNER TO akomarket;

--
-- Name: hashtag_hid_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.hashtag ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.hashtag_hid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: list_chat; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.list_chat (
    id bigint NOT NULL,
    user1 integer NOT NULL,
    user2 integer NOT NULL,
    user1_read bigint DEFAULT 0 NOT NULL,
    user2_read bigint DEFAULT 0 NOT NULL,
    last_chat character varying(200) DEFAULT NULL::character varying,
    last_time timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT list_chat_id_check CHECK ((id > 0)),
    CONSTRAINT list_chat_user1_check CHECK ((user1 > 0)),
    CONSTRAINT list_chat_user2_check CHECK ((user2 > 0))
);


ALTER TABLE public.list_chat OWNER TO akomarket;

--
-- Name: list_chat_id_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.list_chat ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.list_chat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: list_trade; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.list_trade (
    id bigint NOT NULL,
    owner_id integer NOT NULL,
    buyer_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT list_trade_buyer_id_check CHECK ((buyer_id > 0)),
    CONSTRAINT list_trade_order_id_check CHECK ((id > 0)),
    CONSTRAINT list_trade_owner_id_check CHECK ((owner_id > 0)),
    CONSTRAINT list_trade_product_id_check CHECK ((product_id > 0))
);


ALTER TABLE public.list_trade OWNER TO akomarket;

--
-- Name: list_purchase_order_id_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.list_trade ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.list_purchase_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: list_tag; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.list_tag (
    tag_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT list_tag_product_id_check CHECK ((product_id > 0)),
    CONSTRAINT list_tag_tag_id_check CHECK ((tag_id > 0))
);


ALTER TABLE public.list_tag OWNER TO akomarket;

--
-- Name: list_wish; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.list_wish (
    id bigint NOT NULL,
    owner_id integer NOT NULL,
    buyer_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT list_wish_buyer_id_check CHECK ((buyer_id > 0)),
    CONSTRAINT list_wish_order_id_check CHECK ((id > 0)),
    CONSTRAINT list_wish_owner_id_check CHECK ((owner_id > 0)),
    CONSTRAINT list_wish_product_id_check CHECK ((product_id > 0))
);


ALTER TABLE public.list_wish OWNER TO akomarket;

--
-- Name: list_wish_order_id_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.list_wish ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.list_wish_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    point integer DEFAULT 0 NOT NULL,
    account character varying(50) DEFAULT NULL::character varying,
    credit character varying(50) DEFAULT NULL::character varying,
    phone character varying(50) DEFAULT NULL::character varying,
    user_id integer NOT NULL,
    CONSTRAINT payment_payment_id_check CHECK ((id > 0))
);


ALTER TABLE public.payment OWNER TO akomarket;

--
-- Name: payment_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.payment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.payment_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: akomarket
--

CREATE TABLE public.product (
    id integer NOT NULL,
    price integer NOT NULL,
    image character varying(45) DEFAULT NULL::character varying,
    description character varying(1200) DEFAULT NULL::character varying,
    progress public.progress_t DEFAULT 'null'::public.progress_t NOT NULL,
    views bigint DEFAULT '0'::bigint NOT NULL,
    owner_id integer NOT NULL,
    CONSTRAINT product_owner_id_check CHECK ((owner_id > 0)),
    CONSTRAINT product_pid_check CHECK ((id > 0)),
    CONSTRAINT product_price_check CHECK ((price > 0)),
    CONSTRAINT product_views_check CHECK ((views > 0))
);


ALTER TABLE public.product OWNER TO akomarket;

--
-- Name: product_pid_seq; Type: SEQUENCE; Schema: public; Owner: akomarket
--

ALTER TABLE public.product ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_pid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: akouser akouser_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.akouser
    ADD CONSTRAINT akouser_pkey PRIMARY KEY (id);


--
-- Name: authentication authentication_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.authentication
    ADD CONSTRAINT authentication_pkey PRIMARY KEY (id);


--
-- Name: chat chat_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (idx, id);


--
-- Name: hashtag hashtag_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.hashtag
    ADD CONSTRAINT hashtag_pkey PRIMARY KEY (id);


--
-- Name: list_chat list_chat_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_chat
    ADD CONSTRAINT list_chat_pkey PRIMARY KEY (id);


--
-- Name: list_tag list_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_tag
    ADD CONSTRAINT list_tag_pkey PRIMARY KEY (tag_id, product_id);


--
-- Name: list_trade list_trade_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_trade
    ADD CONSTRAINT list_trade_pkey PRIMARY KEY (id);


--
-- Name: list_wish list_wish_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_wish
    ADD CONSTRAINT list_wish_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: chat_ibfk_1; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX chat_ibfk_1 ON public.chat USING btree (id);


--
-- Name: fk_uid; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX fk_uid ON public.product USING btree (owner_id);


--
-- Name: list_tag_ibfk_2; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_tag_ibfk_2 ON public.list_tag USING btree (product_id);


--
-- Name: list_trade_product_pid_fk; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_trade_product_pid_fk ON public.list_trade USING btree (product_id);


--
-- Name: list_trade_user_uid_fk; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_trade_user_uid_fk ON public.list_trade USING btree (owner_id);


--
-- Name: list_trade_user_uid_fk2; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_trade_user_uid_fk2 ON public.list_trade USING btree (buyer_id);


--
-- Name: list_wish_product_pid_fk; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_wish_product_pid_fk ON public.list_wish USING btree (product_id);


--
-- Name: list_wish_user_uid_fk; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_wish_user_uid_fk ON public.list_wish USING btree (owner_id);


--
-- Name: list_wish_user_uid_fk2; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX list_wish_user_uid_fk2 ON public.list_wish USING btree (buyer_id);


--
-- Name: user1; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX user1 ON public.list_chat USING btree (user1);


--
-- Name: user2; Type: INDEX; Schema: public; Owner: akomarket
--

CREATE INDEX user2 ON public.list_chat USING btree (user2);


--
-- Name: authentication authentication_akouser_uid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.authentication
    ADD CONSTRAINT authentication_akouser_uid_fk FOREIGN KEY (user_id) REFERENCES public.akouser(id) ON DELETE CASCADE;


--
-- Name: chat chat_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_ibfk_1 FOREIGN KEY (id) REFERENCES public.list_chat(id) ON DELETE CASCADE;


--
-- Name: list_wish fk_product_id; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_wish
    ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: product fk_uid; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT fk_uid FOREIGN KEY (owner_id) REFERENCES public.akouser(id);


--
-- Name: list_chat list_chat_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_chat
    ADD CONSTRAINT list_chat_ibfk_1 FOREIGN KEY (user1) REFERENCES public.akouser(id);


--
-- Name: list_chat list_chat_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_chat
    ADD CONSTRAINT list_chat_ibfk_2 FOREIGN KEY (user2) REFERENCES public.akouser(id);


--
-- Name: list_tag list_tag_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_tag
    ADD CONSTRAINT list_tag_ibfk_1 FOREIGN KEY (tag_id) REFERENCES public.hashtag(id) ON DELETE CASCADE;


--
-- Name: list_tag list_tag_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_tag
    ADD CONSTRAINT list_tag_ibfk_2 FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: list_trade list_trade_product_pid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_trade
    ADD CONSTRAINT list_trade_product_pid_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: list_trade list_trade_user_uid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_trade
    ADD CONSTRAINT list_trade_user_uid_fk FOREIGN KEY (owner_id) REFERENCES public.akouser(id);


--
-- Name: list_trade list_trade_user_uid_fk2; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_trade
    ADD CONSTRAINT list_trade_user_uid_fk2 FOREIGN KEY (buyer_id) REFERENCES public.akouser(id);


--
-- Name: list_wish list_wish_product_pid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_wish
    ADD CONSTRAINT list_wish_product_pid_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: list_wish list_wish_user_uid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_wish
    ADD CONSTRAINT list_wish_user_uid_fk FOREIGN KEY (owner_id) REFERENCES public.akouser(id);


--
-- Name: list_wish list_wish_user_uid_fk2; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.list_wish
    ADD CONSTRAINT list_wish_user_uid_fk2 FOREIGN KEY (buyer_id) REFERENCES public.akouser(id);


--
-- Name: payment payment_akouser_uid_fk; Type: FK CONSTRAINT; Schema: public; Owner: akomarket
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_akouser_uid_fk FOREIGN KEY (user_id) REFERENCES public.akouser(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

