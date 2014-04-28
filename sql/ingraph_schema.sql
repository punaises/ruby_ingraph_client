--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: crit_type_enum; Type: TYPE; Schema: public; Owner: icinga
--

CREATE TYPE crit_type_enum AS ENUM (
    'inside',
    'outside'
);


ALTER TYPE public.crit_type_enum OWNER TO icinga;

--
-- Name: status_enum; Type: TYPE; Schema: public; Owner: icinga
--

CREATE TYPE status_enum AS ENUM (
    'warning',
    'critical'
);


ALTER TYPE public.status_enum OWNER TO icinga;

--
-- Name: warn_type_enum; Type: TYPE; Schema: public; Owner: icinga
--

CREATE TYPE warn_type_enum AS ENUM (
    'inside',
    'outside'
);


ALTER TYPE public.warn_type_enum OWNER TO icinga;

--
-- Name: update_existing(); Type: FUNCTION; Schema: public; Owner: icinga
--

CREATE FUNCTION update_existing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
         DECLARE
             existing RECORD;
         BEGIN
             SELECT INTO existing * FROM datapoint
                 WHERE (plot_id, timeframe_id, timestamp) = (NEW.plot_id, NEW.timeframe_id, NEW.timestamp);
             IF NOT FOUND THEN -- INSERT
                 RETURN NEW;
             ELSE
                 UPDATE datapoint SET
                     avg = (existing.avg * existing.count + NEW.avg) / (existing.count + 1),
                     min = LEAST(existing.min, NEW.min),
                     max = GREATEST(existing.max, NEW.max),
                     count = existing.count + 1
                 WHERE
                     plot_id = existing.plot_id
                     AND timeframe_id = existing.timeframe_id
                     AND timestamp = existing.timestamp;
                 RETURN NULL; -- DON'T INSERT
             END IF;
         END;
         $$;


ALTER FUNCTION public.update_existing() OWNER TO icinga;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE comment (
    id integer NOT NULL,
    hostservice_id integer NOT NULL,
    "timestamp" integer NOT NULL,
    comment_timestamp integer NOT NULL,
    author character varying(128) NOT NULL,
    text character varying(512) NOT NULL
);


ALTER TABLE public.comment OWNER TO icinga;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_id_seq OWNER TO icinga;

--
-- Name: datapoint; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE datapoint (
    plot_id integer NOT NULL,
    timeframe_id integer NOT NULL,
    "timestamp" integer NOT NULL,
    min numeric(20,5) NOT NULL,
    max numeric(20,5) NOT NULL,
    avg numeric(20,5) NOT NULL,
    lower_limit numeric(20,5),
    upper_limit numeric(20,5),
    warn_lower numeric(20,5),
    warn_upper numeric(20,5),
    warn_type warn_type_enum,
    crit_lower numeric(20,5),
    crit_upper numeric(20,5),
    crit_type crit_type_enum,
    count integer NOT NULL
);


ALTER TABLE public.datapoint OWNER TO icinga;

--
-- Name: host; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE host (
    id integer NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.host OWNER TO icinga;

--
-- Name: host_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.host_id_seq OWNER TO icinga;

--
-- Name: hostservice; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE hostservice (
    id integer NOT NULL,
    host_id integer NOT NULL,
    service_id integer NOT NULL,
    parent_hostservice_id integer,
    check_command character varying(128)
);


ALTER TABLE public.hostservice OWNER TO icinga;

--
-- Name: hostservice_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE hostservice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hostservice_id_seq OWNER TO icinga;

--
-- Name: plot; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE plot (
    id integer NOT NULL,
    hostservice_id integer NOT NULL,
    name character varying(128) NOT NULL,
    unit character varying(16)
);


ALTER TABLE public.plot OWNER TO icinga;

--
-- Name: plot_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE plot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plot_id_seq OWNER TO icinga;

--
-- Name: pluginstatus; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE pluginstatus (
    id integer NOT NULL,
    hostservice_id integer NOT NULL,
    "timestamp" integer NOT NULL,
    status status_enum NOT NULL
);


ALTER TABLE public.pluginstatus OWNER TO icinga;

--
-- Name: pluginstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE pluginstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pluginstatus_id_seq OWNER TO icinga;

--
-- Name: service; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE service (
    id integer NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.service OWNER TO icinga;

--
-- Name: service_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.service_id_seq OWNER TO icinga;

--
-- Name: timeframe; Type: TABLE; Schema: public; Owner: icinga; Tablespace: 
--

CREATE TABLE timeframe (
    id integer NOT NULL,
    "interval" integer NOT NULL,
    retention_period integer,
    active boolean NOT NULL
);


ALTER TABLE public.timeframe OWNER TO icinga;

--
-- Name: timeframe_id_seq; Type: SEQUENCE; Schema: public; Owner: icinga
--

CREATE SEQUENCE timeframe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timeframe_id_seq OWNER TO icinga;

--
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id, hostservice_id, "timestamp");


--
-- Name: datapoint_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY datapoint
    ADD CONSTRAINT datapoint_pkey PRIMARY KEY (plot_id, timeframe_id, "timestamp");


--
-- Name: host_name_key; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_name_key UNIQUE (name);


--
-- Name: host_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_pkey PRIMARY KEY (id);


--
-- Name: hostservice_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY hostservice
    ADD CONSTRAINT hostservice_pkey PRIMARY KEY (id);


--
-- Name: plot_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (id);


--
-- Name: pluginstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY pluginstatus
    ADD CONSTRAINT pluginstatus_pkey PRIMARY KEY (id, hostservice_id, "timestamp");


--
-- Name: service_name_key; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_name_key UNIQUE (name);


--
-- Name: service_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_pkey PRIMARY KEY (id);


--
-- Name: timeframe_pkey; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY timeframe
    ADD CONSTRAINT timeframe_pkey PRIMARY KEY (id);


--
-- Name: uc_hs_1; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY hostservice
    ADD CONSTRAINT uc_hs_1 UNIQUE (host_id, service_id, parent_hostservice_id);


--
-- Name: uc_plot_1; Type: CONSTRAINT; Schema: public; Owner: icinga; Tablespace: 
--

ALTER TABLE ONLY plot
    ADD CONSTRAINT uc_plot_1 UNIQUE (hostservice_id, name);


--
-- Name: idx_dp_1; Type: INDEX; Schema: public; Owner: icinga; Tablespace: 
--

CREATE INDEX idx_dp_1 ON datapoint USING btree (timeframe_id, "timestamp");


--
-- Name: idx_dp_2; Type: INDEX; Schema: public; Owner: icinga; Tablespace: 
--

CREATE INDEX idx_dp_2 ON datapoint USING btree ("timestamp");


--
-- Name: idx_ps_1; Type: INDEX; Schema: public; Owner: icinga; Tablespace: 
--

CREATE INDEX idx_ps_1 ON pluginstatus USING btree ("timestamp");


--
-- Name: update_existing; Type: TRIGGER; Schema: public; Owner: icinga
--

CREATE TRIGGER update_existing BEFORE INSERT ON datapoint FOR EACH ROW EXECUTE PROCEDURE update_existing();


--
-- Name: comment_hostservice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_hostservice_id_fkey FOREIGN KEY (hostservice_id) REFERENCES hostservice(id);


--
-- Name: datapoint_plot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY datapoint
    ADD CONSTRAINT datapoint_plot_id_fkey FOREIGN KEY (plot_id) REFERENCES plot(id);


--
-- Name: datapoint_timeframe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY datapoint
    ADD CONSTRAINT datapoint_timeframe_id_fkey FOREIGN KEY (timeframe_id) REFERENCES timeframe(id);


--
-- Name: hostservice_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY hostservice
    ADD CONSTRAINT hostservice_host_id_fkey FOREIGN KEY (host_id) REFERENCES host(id);


--
-- Name: hostservice_parent_hostservice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY hostservice
    ADD CONSTRAINT hostservice_parent_hostservice_id_fkey FOREIGN KEY (parent_hostservice_id) REFERENCES hostservice(id);


--
-- Name: hostservice_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY hostservice
    ADD CONSTRAINT hostservice_service_id_fkey FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: plot_hostservice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY plot
    ADD CONSTRAINT plot_hostservice_id_fkey FOREIGN KEY (hostservice_id) REFERENCES hostservice(id);


--
-- Name: pluginstatus_hostservice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: icinga
--

ALTER TABLE ONLY pluginstatus
    ADD CONSTRAINT pluginstatus_hostservice_id_fkey FOREIGN KEY (hostservice_id) REFERENCES hostservice(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

