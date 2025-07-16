from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import date
from enum import Enum

# ---------- mood enum ----------

class MoodEnum(str, Enum):
    happy     = "happy"
    sad       = "sad"
    angry     = "angry"
    excited   = "excited"
    calm      = "calm"
    tired     = "tired"
    stressed  = "stressed"

# ---------- auth ----------

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    class Config: from_attributes = True


# ---------- todos ----------

class TodoBase(BaseModel):
    title: str
    completed: bool = False
    timestamp: str

class TodoCreate(TodoBase):
    pass

class TodoUpdate(BaseModel):
    title: Optional[str] = None
    completed: Optional[bool] = None
    timestamp: Optional[str] = None

class TodoOut(TodoBase):
    id: int
    class Config: from_attributes = True


# ---------- moods ----------

class MoodCreate(BaseModel):
    mood: MoodEnum

class MoodOut(BaseModel):
    id: int
    mood: MoodEnum
    date: date
    class Config: from_attributes = True

class Token(BaseModel):
   access_token: str
   token_type: str
