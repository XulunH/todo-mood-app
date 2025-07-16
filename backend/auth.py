from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import models, database


SECRET_KEY  = "Xulun_Huang"
ALGORITHM   = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 24 * 60 * 30

pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2  = OAuth2PasswordBearer(tokenUrl="/login")     # <— back to OAuth2

# ---------- hashing ----------
def hash_password(pwd: str) -> str:        return pwd_ctx.hash(pwd)
def verify_password(pwd: str, h: str) -> bool: return pwd_ctx.verify(pwd, h)

# ---------- JWT ----------
def create_access_token(data: dict, exp: timedelta | None = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (exp or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(
    token: str = Depends(oauth2),           # <— Swagger injects raw token here
    db:    Session = Depends(database.get_db)
) -> models.User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub", 0))
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.get(models.User, user_id)
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user


