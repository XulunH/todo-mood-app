from sqlalchemy import Column, Integer, String, Boolean, Date, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"
    id             = Column(Integer, primary_key=True, index=True)
    email          = Column(String, unique=True, index=True)
    hashed_password = Column(String)

    todos = relationship("Todo", back_populates="owner", cascade="all, delete")
    moods = relationship("Mood", back_populates="owner", cascade="all, delete")

class Todo(Base):
    __tablename__ = "todos"
    id        = Column(Integer, primary_key=True, index=True)
    title     = Column(String)
    completed = Column(Boolean, default=False)
    timestamp = Column(String)                 # store ISO-string from iOS

    owner_id  = Column(Integer, ForeignKey("users.id"))
    owner     = relationship("User", back_populates="todos")

class Mood(Base):
    __tablename__ = "moods"
    id       = Column(Integer, primary_key=True, index=True)
    mood     = Column(String)
    date     = Column(Date)

    owner_id = Column(Integer, ForeignKey("users.id"))
    owner    = relationship("User", back_populates="moods")
