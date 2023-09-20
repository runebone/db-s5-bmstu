from faker import Faker
import uuid
from datetime import datetime
import csv

fake = Faker()

file_ids = []
user_ids = []
post_ids = []

unique_usernames = set()

while len(unique_usernames) < 1000:
    u = fake.user_name() + str(fake.random.randint(1, 9999))
    unique_usernames.add(u)

unique_usernames = list(unique_usernames)

FILE_CSV                 = "csv/file.csv"
USER_MAIN_CSV            = "csv/user_main.csv"
USER_POST_CSV            = "csv/user_post.csv"
USER_POST_ATTACHMENT_CSV = "csv/user_post_attachment.csv"
USER_POST_COMMENT_CSV    = "csv/user_post_comment.csv"
USER_SUBSCRIPTION_CSV    = "csv/user_subscription.csv"

def create_csv_title(filename, data):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(data)

create_csv_title(FILE_CSV, ["id", "url", "filetype", "filesize", "uploaded_by",
                            "creation_date"])

create_csv_title(USER_MAIN_CSV, ["id", "username", "fullname", "email",
                                 "password_hash", "phone", "country", "gender",
                                 "birthday", "creation_date", "pfp_file_id",
                                 "bio"])

create_csv_title(USER_POST_CSV, ["id", "user_id", "shared_post_id", "text",
                                 "creation_date"])

create_csv_title(USER_POST_ATTACHMENT_CSV, ["post_id", "file_id"])

create_csv_title(USER_POST_COMMENT_CSV, ["id", "commenter_id", "post_id",
                                         "text", "creation_date"])

create_csv_title(USER_SUBSCRIPTION_CSV, ["following_id", "follower_id"])

def write_to_csv(filename, data):
    with open(filename, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(data)

def create_users(n, user_ids, file_ids):
    for _ in range(n):
        user_id = str(uuid.uuid4())
        user_ids.append(user_id)

        # username = fake.user_name()
        username = unique_usernames.pop()
        fullname = fake.name()
        email = fake.email()
        password_hash = fake.sha256()
        phone = fake.phone_number()
        country = fake.country()
        gender = fake.random_element(elements=("M", "F", None))
        birthday = fake.date_of_birth()
        creation_date = datetime.now()
        pfp_file_id = fake.random_element([*file_ids, None])
        bio = fake.text(max_nb_chars=256)

        write_to_csv(USER_MAIN_CSV, [user_id, username, fullname, email,
                                     password_hash, phone, country, gender,
                                     birthday, creation_date, pfp_file_id,
                                     bio])

def create_files(n, user_ids, file_ids):
    for _ in range(n):
        file_id = str(uuid.uuid4())
        file_ids.append(file_id)

        url = fake.url()
        filetype = fake.random_element(elements=("image", "video", "audio"))
        filesize = fake.random.randint(10**6, 10**7)
        uploaded_by = fake.random_element(user_ids)
        creation_date = datetime.now()

        write_to_csv(FILE_CSV, [file_id, url, filetype, filesize, uploaded_by,
                                creation_date])

# Создаём 100 пользователей без аватарок
create_users(100, user_ids, file_ids)

# Создаём 100 файлов, созданных первыми 100 пользователями
create_files(100, user_ids, file_ids)

# Создаём оставшихся 900 пользователей и файлов
create_users(900, user_ids, file_ids)
create_files(900, user_ids, file_ids)

def create_posts(n, user_ids, post_ids):
    for _ in range(n):
        post_id = str(uuid.uuid4())
        user_id = fake.random_element(user_ids)
        shared_post_id = fake.random_element([*post_ids, None])
        text = fake.text(max_nb_chars=1024)
        creation_date = datetime.now()

        write_to_csv(USER_POST_CSV, [post_id, user_id, shared_post_id, text,
                                     creation_date])

        post_ids.append(post_id)

# Создаём 1000 постов
create_posts(1000, user_ids, post_ids)

def create_post_attachments(n, post_ids, file_ids):
    unique_post_attachments = set()

    while len(unique_post_attachments) < n:
        post_id = fake.random_element(post_ids)
        file_id = fake.random_element(file_ids)
        unique_post_attachments.add((post_id, file_id))

    unique_post_attachments = list(unique_post_attachments)

    for i in range(n):
        write_to_csv(USER_POST_ATTACHMENT_CSV, [*unique_post_attachments[i]])

# Создаём 1000 вложений
create_post_attachments(1000, post_ids, file_ids)

def create_post_comments(n, user_ids, post_ids):
    for _ in range(n):
        comment_id = str(uuid.uuid4())
        commenter_id = fake.random_element(user_ids)
        post_id = fake.random_element(post_ids)
        text = fake.text(max_nb_chars=1024)
        creation_date = datetime.now()

        write_to_csv(USER_POST_COMMENT_CSV, [comment_id, commenter_id, post_id,
                                             text, creation_date])

# Создаём 1000 комментариев
create_post_comments(1000, user_ids, post_ids)

def create_subscriptions(n, user_ids):
    unique_subscriptions = set()

    while len(unique_subscriptions) < n:
        # FIXME: meh
        following_id = fake.random_element(user_ids)
        follower_id = fake.random_element(user_ids)
        unique_subscriptions.add((following_id, follower_id))

    unique_subscriptions = list(unique_subscriptions)

    for i in range(n):
        write_to_csv(USER_SUBSCRIPTION_CSV, [*unique_subscriptions[i]])

# Создаём 1000 подписок
create_subscriptions(1000, user_ids)
