import json
import psycopg2

conn = psycopg2.connect("host=localhost port=8001 dbname=evilcorp user=postgres password=hotdog123")
cur = conn.cursor()

for table in ["user_main", "file", "user_post", "user_post_attachment", "user_post_comment", "user_subscription"]:
    cur.execute(f"SELECT json_agg({table}) FROM {table};")
    result = cur.fetchone()[0]
    with open(f'json/{table}.json', 'w') as outfile:
        json.dump(result, outfile, indent=4)

cur.close()
conn.close()
