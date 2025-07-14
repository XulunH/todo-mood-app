from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import date

# ---------- auth ----------

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    class Config: orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    user_id: Optional[int] = None


# ---------- todos ----------

class TodoBase(BaseModel):
    title: str
    completed: bool = False
    timestamp: str

class TodoCreate(TodoBase):
    pass

class TodoOut(TodoBase):
    id: int
    class Config: orm_mode = True


# ---------- moods ----------

class MoodCreate(BaseModel):
    mood: str           # emoji or text

class MoodOut(BaseModel):
    id: int
    mood: str
    date: date
    class Config: orm_mode = True
