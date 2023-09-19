/*
TODO:
[x] parent table 3/3
[x] child table 4/1
[x] many-to-many
[x] constraints in another file
*/

CREATE SCHEMA user;
CREATE SCHEMA file;

/* Parent 1 */
CREATE TABLE IF NOT EXISTS file.main (
    id       UUID,
    filetype VARCHAR(8),
    fileurl  VARCHAR(256),
    );

/* Parent 2 */
CREATE TABLE IF NOT EXISTS user.main (
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
    pfp_id        UUID,
    bio           VARCHAR(256),
    );

/* Parent 3, Child 1 */
CREATE TABLE IF NOT EXISTS user.post (
    id            UUID,
    user_id       UUID,
    text          VARCHAR(1024),
    creation_date TIMESTAMP,
    );

/* Child 2 */
CREATE TABLE IF NOT EXISTS user.post_attachment (
    post_id UUID,
    file_id UUID,
    );

/* Child 3 */
CREATE TABLE IF NOT EXISTS user.post_comment (
    id            UUID,
    commenter_id  UUID,
    post_id       UUID,
    text          VARCHAR(1024),
    creation_date TIMESTAMP,
    );

/* Child 4, Many to many */
CREATE TABLE IF NOT EXISTS user.subscription (
    following_id UUID,
    follower_id  UUID,
);
