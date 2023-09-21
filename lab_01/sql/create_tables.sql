/*
TODO:
[x] parent table 3/3
[x] child table 4/1
[x] many-to-many 1/1
[x] constraints in another file
*/

/* Parent 1 */
DROP TABLE file;
CREATE TABLE IF NOT EXISTS file (
    id            UUID,
    url           VARCHAR(256),
    filetype      VARCHAR(8),
    filesize      BIGINT,
    uploaded_by   UUID,
    creation_date TIMESTAMP
    );

/* Parent 2 */
DROP TABLE user_main;
CREATE TABLE IF NOT EXISTS user_main (
    id            UUID,
    username      VARCHAR(32),
    fullname      VARCHAR(256),
    email         VARCHAR(64),
    password_hash VARCHAR(256),
    phone         VARCHAR(256),
    country       VARCHAR(256),
    gender        CHAR,
    birthday      DATE,
    creation_date TIMESTAMP,
    pfp_file_id   UUID,
    bio           VARCHAR(256)
    );

/* Parent 3, Child 1 */
DROP TABLE user_post;
CREATE TABLE IF NOT EXISTS user_post (
    id             UUID,
    user_id        UUID,
    shared_post_id UUID,
    text           VARCHAR(1024),
    creation_date  TIMESTAMP
    );

/* Child 2 */
DROP TABLE user_post_attachment;
CREATE TABLE IF NOT EXISTS user_post_attachment (
    id      UUID,
    post_id UUID,
    file_id UUID
    );

/* Child 3 */
DROP TABLE user_post_comment;
CREATE TABLE IF NOT EXISTS user_post_comment (
    id            UUID,
    commenter_id  UUID,
    post_id       UUID,
    text          VARCHAR(1024),
    creation_date TIMESTAMP
    );

/* Child 4, Many to many */
DROP TABLE user_subscription;
CREATE TABLE IF NOT EXISTS user_subscription (
    id           UUID,
    following_id UUID,
    follower_id  UUID
);
