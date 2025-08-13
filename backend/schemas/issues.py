from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime


class IssuesIn(BaseModel):
    title: str
    description: str
    priority : Optional[str] = None
    status: Optional[str] = None

class IssuesOut(BaseModel):
    id: str
    title: str
    description: str
    priority: str
    status: str
    created_at: datetime
    updated_at: datetime
    project_id: str
    reporter_id: str
    solver_id: Optional[str]

    class Config:
        from_attributes = True

class UpdateIssues(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None
    solver_id: Optional[str] = None