COPY file FROM '/csv/file.csv' DELIMITER ',' CSV HEADER;
COPY user_main FROM '/csv/user_main.csv' DELIMITER ',' CSV HEADER;
COPY user_post FROM '/csv/user_post.csv' DELIMITER ',' CSV HEADER;
COPY user_post_attachment FROM '/csv/user_post_attachment.csv' DELIMITER ',' CSV HEADER;
COPY user_post_comment FROM '/csv/user_post_comment.csv' DELIMITER ',' CSV HEADER;
COPY user_subscription FROM '/csv/user_subscription.csv' DELIMITER ',' CSV HEADER;
