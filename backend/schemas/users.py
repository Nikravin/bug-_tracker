from pydantic import BaseModel, EmailStr
from typing import Literal

class UserCreate(BaseModel):
    username: str
    name: str
    email: EmailStr
    role: Literal["admin", "developer", "tester",]
    hashed_password: str

class UserOut(BaseModel):
    id: str
    username: str
    name: str
    email: EmailStr
    role: str

    class Config:
        from_attributes = True

class DashboardOut(BaseModel):
    id: str
    username: str
    project_id: str
    bug_id: str

    class Config:
        from_attributes = True
