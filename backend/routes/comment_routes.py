from fastapi import APIRouter, status, Depends, HTTPException
from sqlalchemy.orm import Session
from schemas.comments import CommentIn, CommentOut
from config.db import SessionLocal
from utility.token_genrater import decode_access_token
from models.models import User, Project, Issue, Comment
from typing import List

comment_route = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@comment_route.post("/{issue_id}/write_comment/", status_code=status.HTTP_201_CREATED, response_model=CommentOut)
def write_comment(issue_id: str, comment: CommentIn, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if not issue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="issue not found.")
    
    project = db.query(Project).filter(Project.id == issue.project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Facing an Error to finding the project")
    
    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)

    if not create_by or is_member:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to see the issue or bug report for this project")
    
    comment_write = Comment(text=comment.text, created_by=user.get("id"), issue_id=issue.id)

    db.add(comment_write)
    db.commit()
    db.refresh(comment_write)

    return comment_write


@comment_route.get("/{issue_id}/show_comment/", status_code=status.HTTP_200_OK, response_model=List[CommentOut])
def write_comment(issue_id: str, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if not issue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="issue not found.")
    
    project = db.query(Project).filter(Project.id == issue.project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Facing an Error to finding the project")
    
    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)

    if not create_by or is_member:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to see the issue or bug report for this project")
    
    comment = db.query(Comment).filter(Comment.issue_id == issue.id).all()

    if not comment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="comment not found.")
    

    return comment 

@comment_route.delete("/delete/{comment_id}/", status_code=status.HTTP_200_OK)
def delete_comment(comment_id: str, db: Session = Depends(get_db), user: dict=Depends(decode_access_token)):

    comment = db.query(Comment).filter(Comment.id == comment_id).first()

    if not comment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="comment not found.")
    
    if comment.created_by != user.get("id"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to delete this comment.")
    
    db.delete(comment)
    db.commit()

    return {"Message": "comment delete successfully."}
