from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from models.models import User, Project, Issue
from config.db import SessionLocal
from schemas.users import UserCreate, UserOut, DashboardOut
from schemas.token import Token
# from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse
from sqlalchemy.orm import Session
from utility.token_genrater import create_access_token, decode_access_token
from utility.hashed_password import hash_password, verify_password
from typing import List

user_route = APIRouter()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@user_route.post("/user/register/", response_model=UserOut)
async def register_user(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(status_code=400, detail="This username already exits")
    if db.query(User).filter(User.email == user.email).first():
        raise HTTPException(status_code=400, detail="This email already exits")
    if len(user.hashed_password) < 6 :
        raise HTTPException(status_code=400, detail="This password is too short")


    hashed_pwd = hash_password(user.hashed_password)

    new_user = User(username=user.username, name=user.name, email=user.email, role=user.role, hashed_password=hashed_pwd)

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

@user_route.post("/user/login/", response_model=Token)
async def login_user(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user =  db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid username or password.", headers={"WWW-Authenticate": "Bearer"},)
    
    access_token = create_access_token({"sub":user.username, "id":user.id, "role":user.role})

    return {"access_token":access_token, "token_type":"bearer"}


@user_route.get("/dashboard", status_code=status.HTTP_200_OK, response_model=UserOut)
async def profile(user: dict = Depends(decode_access_token), db: Session = Depends(get_db)):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Error')

    user_info = db.query(User).filter(User.id == user.get("id")).first()
    if user_info:
        project_info = db.query(Project).filter(Project.created_by == user_info.id).first()
    print("This is the value of user_info: ", user_info)

    return user_info

@user_route.get("/user/list/", response_model=List[UserOut])
async def list_users(user: dict = Depends(decode_access_token), db: Session = Depends(get_db)):
    """Get list of all users for adding to projects"""
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Error')
    
    # Get all users except the current user
    current_user_id = user.get("id")
    users = db.query(User).filter(User.id != current_user_id).all()
    
    return users

@user_route.get("/user/search/", response_model=List[UserOut])
async def search_users(
    q: str = None, 
    username: str = None, 
    email: str = None, 
    id: str = None,
    user: dict = Depends(decode_access_token), 
    db: Session = Depends(get_db)
):
    """Search users by various fields"""
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Error')
    
    # Build query based on provided parameters
    query = db.query(User)
    
    # Exclude current user from results
    current_user_id = user.get("id")
    query = query.filter(User.id != current_user_id)
    
    if q:
        # General search across name, username, and email
        search_term = f"%{q}%"
        query = query.filter(
            (User.name.ilike(search_term)) |
            (User.username.ilike(search_term)) |
            (User.email.ilike(search_term))
        )
    elif username:
        query = query.filter(User.username.ilike(f"%{username}%"))
    elif email:
        query = query.filter(User.email.ilike(f"%{email}%"))
    elif id:
        try:
            user_id = int(id)
            query = query.filter(User.id == user_id)
        except ValueError:
            # If ID is not a valid integer, return empty results
            return []
    else:
        # If no search parameters provided, return all users (except current)
        pass
    
    users = query.all()
    return users
