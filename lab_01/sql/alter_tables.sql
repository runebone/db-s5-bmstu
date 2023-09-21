ALTER TABLE file
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_file_main_id
    PRIMARY KEY (id),

    ALTER COLUMN url SET NOT NULL,
    ALTER COLUMN filetype SET NOT NULL,

    ALTER COLUMN filesize SET NOT NULL,
    ADD CONSTRAINT unsigned_file_filesize
    CHECK (filesize > 0),

    ALTER COLUMN creation_date SET NOT NULL;

ALTER TABLE user_main
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_user_main_id
    PRIMARY KEY (id),

    ALTER COLUMN username SET NOT NULL,
    ADD CONSTRAINT unique_user_main_username
    UNIQUE (username),
    ADD CONSTRAINT check_user_main_username
    CHECK (
        LENGTH(username) BETWEEN 5 AND 32 AND 
        username ~ '^[a-z0-9_]+$' AND
        username NOT LIKE '\_%' AND
        username NOT LIKE '%\_' AND
        username NOT LIKE '[0-9]+%'
    ),

    ALTER COLUMN fullname SET NOT NULL,

    ALTER COLUMN email SET NOT NULL,
    ADD CONSTRAINT check_user_main_email
    CHECK (email LIKE '%@%.%'),

    ALTER COLUMN password_hash SET NOT NULL,
    ALTER COLUMN phone SET DEFAULT NULL,
    ALTER COLUMN country SET DEFAULT NULL,
    ALTER COLUMN gender SET DEFAULT NULL,
    ALTER COLUMN birthday SET NOT NULL,
    ALTER COLUMN creation_date SET NOT NULL,

    ALTER COLUMN pfp_file_id SET DEFAULT NULL,
    ADD CONSTRAINT fk_user_main_pfp_file_id
    FOREIGN KEY (pfp_file_id)
    REFERENCES file(id)
    ON DELETE SET NULL,

    ALTER COLUMN bio SET DEFAULT NULL;

-- Table file again. To be able to add FK to user constraint.
ALTER TABLE file
    ALTER COLUMN uploaded_by SET DEFAULT NULL,
    ADD CONSTRAINT fk_file_uploaded_by
    FOREIGN KEY (uploaded_by)
    REFERENCES user_main(id)
    ON DELETE CASCADE;

ALTER TABLE user_post
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_user_post_id
    PRIMARY KEY (id),

    ALTER COLUMN user_id SET NOT NULL,
    ADD CONSTRAINT fk_user_post_user_id
    FOREIGN KEY (user_id)
    REFERENCES user_main(id)
    ON DELETE CASCADE,

    ALTER COLUMN shared_post_id SET DEFAULT NULL,
    ADD CONSTRAINT fk_user_post_shared_post_id
    FOREIGN KEY (shared_post_id)
    REFERENCES user_post(id)
    ON DELETE SET NULL,

    ALTER COLUMN creation_date SET NOT NULL;

ALTER TABLE user_post_attachment
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_user_post_attachment_id
    PRIMARY KEY (id),

    ALTER COLUMN post_id SET NOT NULL,
    ADD CONSTRAINT fk_user_post_attachment_post_id
    FOREIGN KEY (post_id)
    REFERENCES user_post(id)
    ON DELETE CASCADE,

    ALTER COLUMN file_id SET NOT NULL,
    ADD CONSTRAINT fk_user_post_attachment_file_id
    FOREIGN KEY (file_id)
    REFERENCES file(id)
    ON DELETE CASCADE;

ALTER TABLE user_post_comment
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_user_post_comment_id
    PRIMARY KEY (id),

    ALTER COLUMN commenter_id SET NOT NULL,
    ADD CONSTRAINT fk_user_post_comment_commenter_id
    FOREIGN KEY (commenter_id)
    REFERENCES user_main(id)
    ON DELETE CASCADE,

    ALTER COLUMN post_id SET NOT NULL,
    ADD CONSTRAINT fk_user_post_comment_post_id
    FOREIGN KEY (post_id)
    REFERENCES user_post(id)
    ON DELETE CASCADE,

    ALTER COLUMN text SET NOT NULL,
    ALTER COLUMN creation_date SET NOT NULL;

ALTER TABLE user_subscription
    ALTER COLUMN id SET NOT NULL,
    ADD CONSTRAINT pk_user_subscription_id
    PRIMARY KEY (id),

    ALTER COLUMN following_id SET NOT NULL,
    ADD CONSTRAINT fk_user_subscription_following_id
    FOREIGN KEY (following_id)
    REFERENCES user_main(id)
    ON DELETE CASCADE,

    ALTER COLUMN follower_id SET NOT NULL,
    ADD CONSTRAINT fk_user_subscription_follower_id
    FOREIGN KEY (follower_id)
    REFERENCES user_main(id)
    ON DELETE CASCADE,

    ADD CONSTRAINT unique_user_subscription
    UNIQUE (following_id, follower_id);
