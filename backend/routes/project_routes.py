from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from models.models import Project, User, Issue
from schemas.project import ProjectIn, ProjectOut, UpdateProjectIn
from schemas.issues import IssuesIn, IssuesOut, UpdateIssues
from config.db import SessionLocal
from utility.token_genrater import decode_access_token
from typing import List


project_route = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ------------- Project --------------

@project_route.post("/add_project/", response_model=ProjectOut, status_code=status.HTTP_201_CREATED)    
def create_project(project: ProjectIn, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):

    if user.get("role") not in ["admin", "project_manager"] :
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Your are not able to add a project.")
    
    create_project = Project(title=project.title, description=project.description, created_by=user.get("id"))

    db.add(create_project)
    db.commit()
    db.refresh(create_project)

    return create_project


@project_route.get("/show_all_project/", response_model=List[ProjectOut], status_code=status.HTTP_200_OK)
def show_all_projects(db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    # Get projects created by the user
    created_projects = db.query(Project).filter(Project.created_by == user.get("id")).all()
    
    # Get projects where the user is a member
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    member_projects = user_obj.projects if user_obj else []
    
    # Combine both lists and remove duplicates
    all_projects = list({p.id: p for p in created_projects + member_projects}.values())

    if not all_projects:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You are not associated with any projects.")
    
    return all_projects



@project_route.get("/show_project/{project_id}/", response_model=ProjectOut, status_code=status.HTTP_200_OK)
def show_project(project_id: str, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found.")
    
    return project




@project_route.put("/update_project/{project_id}/", status_code=status.HTTP_200_OK, response_model=ProjectOut)
def update_project(project_id: str, up_project: UpdateProjectIn, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):
    
    
    pro = db.query(Project).filter(Project.id == project_id).first()

    if user.get("role") not in ["admin", "project_manager"] and user.get("id") != pro.created_by:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You are not able to update project.")

    if not pro:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not Found")
    

    updates_fields = up_project.model_dump(exclude_unset=True)

    for key, value in updates_fields.items():
        setattr(pro, key, value)


    db.commit()
    db.refresh(pro)

    return pro


@project_route.delete("/delete_project/{project_id}/", status_code=status.HTTP_200_OK)
def delete_project(project_id: str, db: Session = Depends(get_db), user: dict = Depends(decode_access_token)):

    pro = db.query(Project).filter(Project.id == project_id).first()
    
    if user.get("role") not in ["admin", "project_manager"] and user.get("id") != pro.created_by:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You are not able to delete project.")
    

    if not pro:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not Found")

    pro.members.clear()
    db.commit()
    db.delete(pro)
    db.commit()

    return {"Message": "Project Delete Successfully."}




# --------- Project Members -----------

@project_route.post("/{project_id}/add_member/{user_id}", response_model=ProjectOut, status_code=status.HTTP_200_OK)
def add_member(project_id: str, user_id: str, db: Session=Depends(get_db), user: dict=Depends(decode_access_token)):

    if user.get("role") not in ["admin", "project_manager"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You are not able to add members.")
    
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not Found.")
    
    pro_user = db.query(User).filter(User.id == user_id).first()

    if not pro_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User Not Found.")
    
    if pro_user in project.members:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User are already in this project.")


    project.members.append(pro_user)
    db.commit()
    db.refresh(project)

    return project

@project_route.delete("/{project_id}/delete_member/{user_id}", response_model=ProjectOut, status_code=status.HTTP_200_OK)
def delete_member(project_id: str, user_id: str, db: Session=Depends(get_db), user: dict=Depends(decode_access_token)):

    if user.get("role") not in ["admin", "project_manager"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You are not able to delete members.")
    
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project Not Found.")
    
    pro_user = db.query(User).filter(User.id == user_id).first()

    if not pro_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User Not Found.")
    
    if pro_user not in project.members:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User are not add in this project.")


    project.members.remove(pro_user)
    db.commit()
    db.refresh(project)

    return project

