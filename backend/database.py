from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os


# local SQLite for development
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///database.db")

# SQLite configuration 
if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(DATABASE_URL, connect_args={'check_same_thread': False})
else:
    # PostgreSQL configuration 
    engine = create_engine(DATABASE_URL)

sessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = sessionLocal()
    try:
        yield db
    finally:
        db.close()