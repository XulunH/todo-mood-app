# Todo + Mood API

FastAPI backend for daily todo and mood tracking.

## Built By
**Xulun Huang**

## Tech Stack
- FastAPI, SQLAlchemy, JWT, SQLite, Render

## Project Structure
```
backend/
├── main.py          # FastAPI app & routes
├── models.py        # Database models
├── schemas.py       # Request/response schemas
├── crud.py          # Database operations
├── auth.py          # JWT authentication
├── database.py      # DB connection
├── requirements.txt # Dependencies
├── render.yaml      # Deployment config
└── database.db      # SQLite database
```

## API Endpoints
### Auth
- `POST /register` - Register user
- `POST /login` - Login (returns JWT token)
- `GET /me` - Get current user

### Todos
- `GET /todos` - List todos
- `POST /todos` - Create todo
- `PATCH /todos/{todo_id}` - Update todo
- `DELETE /todos/{todo_id}` - Delete todo

### Moods
- `GET /moods/options` - Available moods
- `GET /moods/today` - Today's mood
- `POST /moods/today` - Set today's mood
- `GET /moods/{date}` - Mood by date

## Authentication
- **JWT tokens** with 30 days expiration
- **OAuth2PasswordBearer** in Authorization header
- **Password hashing** with bcrypt
- **User data isolation**

## Mood Design
- **5 mood options:** terrible, bad, ok, good, excellent
- **One mood per day** per user
- **Historical data** retrieval
- **Automatic date tracking**

## Live Demo
https://todo-mood-backend.onrender.com



