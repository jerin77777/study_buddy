import psycopg2
from playhouse.postgres_ext import *
import uuid





pg_db = PostgresqlDatabase("postgres",
                           user='postgres',
                           password='0007!asd',
                           host='localhost'
)


class BaseModel(Model):
    """A base model that will use our Postgresql database"""
    class Meta:
        database = pg_db


class Files(BaseModel):
    fileId = IdentityField(primary_key=True, null=False)
    sessionId = IntegerField(null=False)
    subject = TextField(null=False)
    chapter = TextField(null=False)
    fileName = TextField(null=False)
    fileSize = TextField(null=False)
    topics = JSONField(null=False)
    url = TextField(null=False)
    difficulty = DoubleField(null=False)

class Questions(BaseModel):
    questionId = UUIDField(primary_key=True, default=uuid.uuid4)
    fileId = ForeignKeyField(Files, to_field='fileId')
    question = TextField(null=False)
    ans = JSONField(null=False)


class Objects(BaseModel):
    objectId = IdentityField(primary_key=True, null=False)
    objectName = TextField(null=False)
    object = TextField(null=False)


class Schedules(BaseModel):
    scheduleId = IdentityField(primary_key=True, null=False)
    sessionId = TextField(null=False)
    schedule = JSONField(null=False)





def create_db():
    conn = psycopg2.connect(database='postgres',
                            user='postgres',
                            password='0007!asd',
                            host='localhost')

    cursor = conn.cursor()  # creating a cursor

    cursor.execute("DROP SCHEMA public CASCADE;")
    conn.commit()
    cursor.execute("CREATE SCHEMA public;")
    conn.commit()
    # users
    pg_db.create_tables([Files,Questions,Objects])


