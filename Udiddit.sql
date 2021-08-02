CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(25) UNIQUE NOT NULL,
  recent_login_time TIMESTAMP
);

CREATE UNIQUE INDEX "find_user_by_name" ON "users" ("user_name");
CREATE INDEX "find_user_by_login_time" ON "users" ("recent_login_time");

  
CREATE TABLE topics (
  id SERIAL PRIMARY KEY,
  topic_name VARCHAR(30) UNIQUE NOT NULL ,
  description VARCHAR(500)
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  url VARCHAR(4000),
  text_content TEXT,
  user_id BIGINT REFERENCES "users",
  topic_id BIGINT REFERENCES "topics" ON DELETE CASCADE, 
  CONSTRAINT only_one_value CHECK (("url" is null OR "text_content" is null) AND NOT ("url" is null AND "text_content" is null))
);

CREATE INDEX "find_post_by_user" ON "posts" ("user_id");
CREATE INDEX "find_post_by_topic" ON "posts" ("topic_id");



CREATE TABLE votes (
  id SERIAL PRIMARY KEY,
  post_id BIGINT REFERENCES "posts" ON DELETE CASCADE,
  user_id BIGINT REFERENCES "users",
  vote_value SMALLINT
);


  
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id BIGINT REFERENCES "posts" ("id") ON DELETE CASCADE,
  user_id BIGINT REFERENCES "users",
  parent_comment_id BIGINT REFERENCES "comments" ("id") ON DELETE CASCADE,
  text_content TEXT not NULL
);

CREATE INDEX "find_parent_by_children" ON "comments" ("parent_comment_id");






INSERT INTO "topics" ("topic_name")
	SELECT DISTINCT "topic" FROM "bad_posts";


    
INSERT INTO "users" ("user_name")
	SELECT DISTINCT "username" FROM "bad_posts";
    
INSERT INTO "users" ("user_name")    
    SELECT DISTINCT "user_name" FROM "bad_comments" 
    WHERE 
    NOT EXISTS (SELECT "user_name" 
                FROM users);
    
    

    
INSERT INTO "users" ("user_name")  
    SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(downvotes,',') FROM "bad_posts"
    WHERE 
    NOT EXISTS (SELECT "user_name" 
                FROM users);
    
INSERT INTO "users" ("user_name")      
    SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(upvotes,',') FROM "bad_posts"
    WHERE 
    NOT EXISTS (SELECT "user_name" 
                FROM users);
                
INSERT INTO "posts" ("title")
	SELECT "title" FROM "bad_posts";

INSERT INTO "posts" ("url")
	SELECT "url" FROM "bad_posts";

INSERT INTO "posts" ("text_content")
	SELECT "text_content" FROM "bad_posts";
    
UPDATE "comments" SET "post_id" = (
  SELECT post_id 
  FROM bad_comments
  WHERE bad_comments.id = comments.id
);

UPDATE "comments" SET "user_id" = (
  SELECT id 
  FROM users
  WHERE bad_comments.username = users.username
);

INSERT INTO "votes" ("post_id","user_id") 
	SELECT bad_posts.id, users.id from bad_posts JOIN usrs ON users.user_name = bad_posts.REGEXP_SPLIT_TO_TABLE(upvotes,',');

UPDATE "votes" SET vote_value = 1;

INSERT INTO "votes" ("post_id","user_id") 
	SELECT bad_posts.id, users.id from bad_posts JOIN usrs ON users.user_name = bad_posts.REGEXP_SPLIT_TO_TABLE(downvotes,',');

UPDATE "votes" SET vote_value = -1 WHERE vote_value is NULL;

	
