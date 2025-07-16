from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import date

import models, schemas, crud, auth, database
from schemas import MoodEnum

# ──────────────────────────────────────────────────────────────
# App setup
# ──────────────────────────────────────────────────────────────
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="Todo + Mood API",
    version="0.1.0",
    description="Backend for the Daily Todo + Mood Tracker interview project. Built by Xulun Huang using FastAPI, SQLAlchemy, and JWT authentication.",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────────────────────
# root check 
# ──────────────────────────────────────────────────────────────
@app.get("/")
def health_check():
    return {"status": "healthy", "message": "This API is built by Xulun Huang"}

# ──────────────────────────────────────────────────────────────
# Auth routes
# ──────────────────────────────────────────────────────────────
@app.post("/register", response_model=schemas.UserOut, status_code=201)
def register(user_in: schemas.UserCreate, db: Session = Depends(database.get_db)):
    if db.query(models.User).filter(models.User.email == user_in.email).first():
        raise HTTPException(400, "Email already registered")
    return crud.create_user(db, user_in)


@app.post("/login", response_model=schemas.Token)
def login(
    form: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(database.get_db),
):
    user = crud.authenticate(db, form.username, form.password)
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Bad credentials")
    token = auth.create_access_token({"sub": str(user.id)})
    return {"access_token": token, "token_type": "bearer"}


@app.get("/me", response_model=schemas.UserOut)
def me(current: models.User = Depends(auth.get_current_user)):
    return current


# ──────────────────────────────────────────────────────────────
# Todos Routes
# ──────────────────────────────────────────────────────────────
@app.get("/todos", response_model=list[schemas.TodoOut])
def list_todos(
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    return crud.get_todos(db, current)


@app.post("/todos", response_model=schemas.TodoOut, status_code=201)
def create_todo(
    todo_in: schemas.TodoCreate,
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    return crud.add_todo(db, current, todo_in)


@app.patch("/todos/{todo_id}", response_model=schemas.TodoOut)
def update_todo(
    todo_id: int,
    updates: schemas.TodoUpdate,
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    todo = crud.update_todo(db, current, todo_id, updates)
    if not todo:
        raise HTTPException(404, "Todo not found")
    return todo


@app.delete("/todos/{todo_id}", status_code=204)
def delete_todo(
    todo_id: int,
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    if not crud.delete_todo(db, current, todo_id):
        raise HTTPException(404, "Todo not found")


# ──────────────────────────────────────────────────────────────
# Mood Routes
# ──────────────────────────────────────────────────────────────
@app.get("/moods/options", response_model=list[MoodEnum])
def list_mood_options():
    """Return the allowed moods for the front‑end buttons."""
    return [m.value for m in MoodEnum]


@app.get("/moods/today", response_model=schemas.MoodOut | None)
def get_today_mood(
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    return crud.get_today_mood(db, current)


@app.post("/moods/today", response_model=schemas.MoodOut)
def set_today_mood(
    mood_in: schemas.MoodCreate,
    current: models.User = Depends(auth.get_current_user),
    db: Session = Depends(database.get_db),
):
    return crud.set_today_mood(db, current, mood_in)

@app.get("/moods/{day}", response_model=schemas.MoodOut | None)
def get_mood_by_day(
    day: date,
    current: models.User = Depends(auth.get_current_user),
    db: Session          = Depends(database.get_db)
):
    """
    ISO‑date path param e.g. 2025-07-10
    Returns that day's mood or null.
    """
    return crud.get_mood_by_date(db, current, day)

# ──────────────────────────────────────────────────────────────
# Production startup configuration
# ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    import os
    
    # Get port from environment variable (Render sets this)
    port = int(os.environ.get("PORT", 8000))
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",  # Required for Render to route traffic
        port=port,
        reload=False     # Disable reload in production
    )
