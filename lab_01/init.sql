/*
TODO:
[x] parent table 3/3
[x] child table 6/1
[x] many-to-many

[ ] constraints in another file
*/

create schema user;
create schema file;

/* Parent 1 */
create table if not exists file.main (
    id uuid not null primary key,
    filetype varchar(5) not null,
    filename varchar(255) not null,
    filepath varchar(255) not null,
    );

/* Parent 2 */
create table if not exists user.main (
    id uuid not null primary key,
    username varchar(255) not null, /* unique */
    fullname varchar(255) not null,
    email varchar(255) not null,
    password_hash varchar(255) not null,
    phone numeric(11, 0) null,
    country varchar(255) null,
    gender char null,
    birthday date not null,
    creation_date timestamp not null,
    pfp_id null references file.main(id),
    );

/* Child 1 */
create table if not exists file.video (
    id uuid not null references file.main(id) on delete cascade,
    title varchar(255) not null,
    description varchar(255) null,
    duration_ms numeric(10, 0) not null,
    );

/* Child 2 */
create table if not exists file.audio (
    id uuid not null references file.main(id) on delete cascade,
    title varchar(255) not null,
    description varchar(255) null,
    duration_ms numeric(10, 0) not null,
    );

/* Parent 3, Child 3 */
create table if not exists user.post (
    id uuid not null primary key,
    user_id uuid not null references user.main(id) on delete cascade,
    text varchar(1023) null,
    creation_date timestamp not null,
    );

/* Child 4 */
create table if not exists user.post_attachment (
    post_id uuid not null references user.post(id) on delete cascade,
    file_id uuid not null references file.main(id) on delete cascade,
    primary key (post_id, file_id)
    );

/* Child 5 */
create table if not exists user.post_comment (
    id uuid not null primary key,
    user_id uuid not null references user.main(id) on delete cascade,
    post_id uuid not null references user.post(id) on delete cascade,
    text varchar(1023) not null,
    creation_date timestamp not null,
    );

/* Child 6, Many to many */
create table if not exists user.subscription (
    user_id uuid not null references user.main(id) on delete cascade,
    subscriber_id uuid not null references user.main(id) on delete cascade,
    primary key (user_id, subscriber_id)
);
