from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CommentIn(BaseModel):
    text: str

class CommentOut(BaseModel):
    id: str
    text: str
    created_at: datetime
    created_by: Optional[str]
    issue_id: Optional[str]

    class Config:
        from_attributed = True