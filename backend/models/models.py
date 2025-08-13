from sqlalchemy import Column, Enum, String, Text, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship
from config.db import Base
from utility.id_genrater import idGenrate, projectIdGenrator, issuesIdGenrator, commentIdGenrator
from datetime import timezone, datetime


project_members = Table("project_members", Base.metadata, 
                        Column("project_id", ForeignKey("projects.id"), primary_key=True), 
                        Column("user_id", ForeignKey("users.id"), primary_key=True),
                        )


class User(Base):
    __tablename__ = "users"
    id = Column(String, default=idGenrate, primary_key=True, unique=True, index=True)
    username = Column(String(50), unique= True, nullable=False, index=True)
    name = Column(String(100), index = True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    role = Column(String(20), index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    projects = relationship("Project", secondary=project_members, back_populates="members")
    created_projects = relationship("Project", back_populates="creator", foreign_keys="Project.created_by")
    issues_reported = relationship("Issue", back_populates="reporter", foreign_keys="Issue.reporter_id")
    issues_solved = relationship("Issue", back_populates="solver", foreign_keys="Issue.solver_id")
    comments = relationship("Comment", back_populates="created", cascade="all, delete")


class Project(Base):
    __tablename__ = "projects"
    id = Column(String, default=projectIdGenrator, primary_key=True, unique=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.now(timezone.utc))
    created_by = Column(String, ForeignKey("users.id"))

    creator = relationship("User", back_populates="created_projects", foreign_keys=[created_by])
    members = relationship("User", secondary=project_members, back_populates="projects")
    issues = relationship("Issue", back_populates="project", cascade="all, delete")


status_enum = Enum(
    'open', 'in_progress', 'resolved', 'closed',
    name='issue_status'
)

priority_enum = Enum(
    'low', 'medium', 'high', 'critical',
    name='issue_priority'
)


class Issue(Base):
    __tablename__ = "issues"
    id = Column(String, default=issuesIdGenrator, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    priority = Column(priority_enum ,default="low", index=True)
    status = Column(status_enum, default="open", index=True)
    created_at = Column(DateTime, default=datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=datetime.now(timezone.utc), onupdate=datetime.now(timezone.utc))

    project_id = Column(String, ForeignKey("projects.id"))
    reporter_id = Column(String, ForeignKey("users.id"))
    solver_id = Column(String, ForeignKey("users.id"), nullable=True)

    project = relationship("Project", back_populates="issues")
    comments = relationship("Comment", back_populates="issue", cascade="all, delete")

    reporter = relationship("User", back_populates="issues_reported", foreign_keys=[reporter_id])
    solver = relationship("User", back_populates="issues_solved", foreign_keys=[solver_id])


class Comment(Base):
    __tablename__ = "comments"
    id = Column(String, default=commentIdGenrator, primary_key=True, index=True)
    text = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.now(timezone.utc))

    created_by = Column(String, ForeignKey("users.id"), nullable=False)
    issue_id = Column(String, ForeignKey("issues.id"), nullable=False)

    created = relationship("User", back_populates="comments")
    issue = relationship("Issue", back_populates="comments")

