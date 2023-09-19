import psycopg2
from faker import Faker
import uuid
from datetime import datetime

fake = Faker()

# Подключение к базе данных
conn = psycopg2.connect(
    dbname="evilcorp",
    user="postgres",
    password="hotdog123",
    host="localhost",
    port="8001"
)
cur = conn.cursor()

file_ids = []
user_ids = []
post_ids = []

# Заполняем таблицу file_scheme.main с различными типами файлов
for _ in range(1000):
    file_id = str(uuid.uuid4())
    file_ids.append(file_id)
    file_type = fake.random_element(elements=("image", "video", "audio"))
    cur.execute("INSERT INTO file (id, filetype, fileurl) VALUES (%s, %s, %s)",
                (file_id, file_type, fake.url()))

# Заполняем таблицу user_scheme.main
for _ in range(1000):
    user_id = str(uuid.uuid4())
    user_ids.append(user_id)
    cur.execute("INSERT INTO user_scheme.main (id, username, fullname, email, password_hash, phone, country, gender, birthday, creation_date, pfp_id, bio) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (user_id, fake.user_name(), fake.name(), fake.email(), fake.sha256(), fake.phone_number(), fake.country(), fake.random_element(elements=("M", "F", None)), fake.date_of_birth(), datetime.now(), fake.random_element(file_ids), fake.text(max_nb_chars=256)))

# Заполняем таблицу user_scheme.post
for user_id in user_ids:
    post_id = str(uuid.uuid4())
    post_ids.append(post_id)
    cur.execute("INSERT INTO user_scheme.post (id, user_id, text, creation_date) VALUES (%s, %s, %s, %s)",
                (post_id, user_id, fake.text(max_nb_chars=1024), datetime.now()))

# Заполняем таблицу user_scheme.post_attachment
for post_id in post_ids:
    cur.execute("INSERT INTO user_scheme.post_attachment (post_id, file_id) VALUES (%s, %s)",
                (post_id, fake.random_element(file_ids)))

# Заполняем таблицу user_scheme.post_comment
for user_id in user_ids:
    cur.execute("INSERT INTO user_scheme.post_comment (id, commenter_id, post_id, text, creation_date) VALUES (%s, %s, %s, %s, %s)",
                (str(uuid.uuid4()), user_id, fake.random_element(post_ids), fake.text(max_nb_chars=1024), datetime.now()))

# Заполняем таблицу user_scheme.subscription
for following_id in user_ids[:5]:  # Просто для примера, первые 500 пользователей подписаны на последние 500
    for follower_id in user_ids[5:]:
        cur.execute("INSERT INTO user_scheme.subscription (following_id, follower_id) VALUES (%s, %s)",
                    (following_id, follower_id))

conn.commit()
cur.close()
conn.close()
