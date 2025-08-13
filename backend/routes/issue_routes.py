from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from utility.token_genrater import decode_access_token
from config.db import SessionLocal
from models.models import Issue, Project 
from schemas.issues import IssuesIn, IssuesOut, UpdateIssues
from typing import List

issues_route = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ------------- ISSUES ( Report BUGS ) ----------------

@issues_route.post("/add_issue/{project_id}/", response_model=IssuesOut, status_code=status.HTTP_201_CREATED)
def create_issue(project_id: str, issue_create: IssuesIn, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):

    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not found")
    
    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)

    if not (create_by or is_member):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to create the issue or bug report for this project")
    
    issue = Issue(title=issue_create.title, description=issue_create.description, priority=issue_create.priority, status=issue_create.status, reporter_id=user.get("id"), project_id=project_id)
    

    db.add(issue)
    db.commit()
    db.refresh(issue)

    return issue

# ----------------- find all issues in the project ---------------------------------

@issues_route.get("/show_all_issues_in_project/{project_id}/", status_code=status.HTTP_200_OK, response_model=List[IssuesOut])
def show_issues(project_id: str, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not found")
    
    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)

    if not (create_by or is_member):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to see the issue or bug report for this project")
    
    issues = db.query(Issue).filter(Issue.project_id == project_id).all()

    # Return empty list if no issues found instead of raising 404
    return issues

# ----------------- find particular issue with the issue id ---------------------------------

@issues_route.get("/show_issue/{issue_id}/", status_code=status.HTTP_200_OK, response_model=IssuesOut)
def show_issues(issue_id: str, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):

    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if not issue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Issue Not found")
    
    project = db.query(Project).filter(Project.id == issue.project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="There is no project found with this issue.")

    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)

    if not (create_by or is_member):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to see the issue or bug report for this project")

    return issue


@issues_route.delete("/delete/{issue_id}/", status_code=status.HTTP_200_OK)
def delete_issue(issue_id: str, db: Session=Depends(get_db), user: dict = Depends(decode_access_token)):
    print(f"🗑️ Delete issue request for issue_id: {issue_id}")
    print(f"👤 User ID: {user.get('id')}")
    
    issue = db.query(Issue).filter(Issue.id == issue_id).first()
    if not issue:
        print(f"❌ Issue not found: {issue_id}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Issue Not found")
    
    print(f"📋 Found issue: {issue.title} in project: {issue.project_id}")
    
    project = db.query(Project).filter(Project.id == issue.project_id).first()
    if not project:
        print(f"❌ Project not found: {issue.project_id}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="There is no project found with this issue.")

    print(f"🏗️ Found project: {project.title}")
    print(f"👑 Project creator: {project.created_by}")
    print(f"👥 Project members: {[member.id for member in project.members]}")
    
    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)
    
    print(f"✅ Is creator: {create_by}")
    print(f"✅ Is member: {is_member}")
    
    if not (create_by or is_member):
        print(f"❌ Permission denied for user {user.get('id')}")
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't have permission to delete this issue. Only project creators and members can delete issues.")
    
    print(f"🗑️ Deleting issue: {issue.title}")
    db.delete(issue)
    db.commit()
    print(f"✅ Issue deleted successfully")

    return {"message": "Issue deleted successfully."}



@issues_route.put("/update/{issue_id}/", status_code=status.HTTP_200_OK, response_model=IssuesOut)
def update_issue(issue_id: str, up_issue: UpdateIssues, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if not issue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Issue Not found")
    
    project = db.query(Project).filter(Project.id == issue.project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="There is no project found with this issue.")

    create_by = project.created_by == user.get("id")
    is_member = any(member.id == user.get("id") for member in project.members)
    if not (create_by or is_member):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not able to see the issue or bug report for this project")
    

    updates_fields = up_issue.model_dump(exclude_unset=True)

    for key, value in updates_fields.items():
        setattr(issue, key, value)


    db.commit()
    db.refresh(issue)

    return issue