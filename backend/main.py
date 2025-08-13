from fastapi import FastAPI
from config.db import Base, engine, SessionLocal
from routes.user_routes import user_route
from routes.project_routes import project_route
from routes.comment_routes import comment_route
from routes.issue_routes import issues_route
from routes.ai_chat_bot import chat_bot
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.include_router(user_route, prefix="/api", tags=["User"])
app.include_router(project_route, prefix="/api/project", tags=["Project"])
app.include_router(issues_route, prefix="/api/project/issue", tags=["Issue"])
app.include_router(comment_route, prefix="/api/project/issue/comment", tags=["Comment"])
app.include_router(chat_bot, prefix="/api/personal_ai", tags=["ChatBot"])


app.mount("/static", StaticFiles(directory="static"), name="static")
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def check():
    return {"Massage": "Bugtracker app run successfully."}



app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        # "http://localhost:5173",  # Web frontend
        # "http://localhost:3000",  # Alternative web port
        "http://127.0.0.1:8000",  # Backend self
        "http://10.0.2.2:8000",   # Android emulator
        "*"  # Allow all origins for development (Flutter apps)
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)