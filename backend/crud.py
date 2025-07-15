from sqlalchemy.orm import Session
from datetime import date
import models, schemas, auth


# ---------- todos ----------

def get_todos(db: Session, user: models.User):
    return user.todos

def add_todo(db: Session, user: models.User, todo_in: schemas.TodoCreate):
    todo = models.Todo(**todo_in.dict(), owner_id=user.id)
    db.add(todo)
    db.commit(); db.refresh(todo)
    return todo

def update_todo(db: Session, user: models.User, todo_id: int, updates: schemas.TodoUpdate):
    todo = db.get(models.Todo, todo_id)
    if not todo or todo.owner_id != user.id:
        return None
    for field, value in updates.dict(exclude_unset=True).items():
        setattr(todo, field, value)
    db.commit(); db.refresh(todo)
    return todo

def delete_todo(db: Session, user: models.User, todo_id: int):
    todo = db.get(models.Todo, todo_id)
    if not todo or todo.owner_id != user.id:
        return False
    db.delete(todo)
    db.commit()
    return True


# ---------- moods ----------

def get_today_mood(db: Session, user: models.User):
    today = date.today()
    return (
        db.query(models.Mood)
        .filter(models.Mood.owner_id == user.id, models.Mood.date == today)
        .first()
    )

def set_today_mood(db: Session, user: models.User, mood_in: schemas.MoodCreate):
    today_mood = get_today_mood(db, user)
    if today_mood:
        today_mood.mood = mood_in.mood
    else:
        today_mood = models.Mood(mood=mood_in.mood, date=date.today(), owner_id=user.id)
        db.add(today_mood)
    db.commit(); db.refresh(today_mood)
    return today_mood

def get_mood_by_date(db: Session, user: models.User, day: date):
    return (
        db.query(models.Mood)
          .filter(models.Mood.owner_id == user.id,
                  models.Mood.date == day)
          .first()
    )

# ---------- user ----------

def create_user(db: Session, user_in: schemas.UserCreate) -> models.User:
    db_user = models.User(
        email=user_in.email,
        hashed_password=auth.hash_password(user_in.password)
    )
    db.add(db_user)
    db.commit(); db.refresh(db_user)
    return db_user

def authenticate(db: Session, email: str, password: str) -> models.User | None:
    user = db.query(models.User).filter(models.User.email == email).first()
    if user and auth.verify_password(password, user.hashed_password):
        return user
    return None


