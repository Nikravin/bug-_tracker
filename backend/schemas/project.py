from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from .users import UserOut

class ProjectIn(BaseModel):
    title: str
    description: str

class ProjectOut(BaseModel):
    id: str
    title: str
    description: str
    created_by: str
    created_at: datetime
    members: List[UserOut]

    class Config:
        from_attributes = True

class UpdateProjectIn(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None

