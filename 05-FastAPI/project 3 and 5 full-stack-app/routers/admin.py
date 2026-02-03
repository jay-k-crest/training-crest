from fastapi import APIRouter,HTTPException,status
from fastapi.params import Depends, Path
from pydantic import BaseModel,Field
from sqlalchemy.orm import Session
from typing import Annotated
from models import Todos
from database import  SessionLocal
from .auth import get_current_user

router = APIRouter(
    prefix='/admin',
    tags=['admin'],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]




@router.get('/todos',status_code=status.HTTP_200_OK)
async def get_todos(user: user_dependency,db: db_dependency):
    if user is None or user.get('user_role')!='admin':
        raise HTTPException(status_code=401,detail='user not found')
    else:
        return db.query(Todos).all()

@router.delete('/todos/{todo_id}',status_code=status.HTTP_202_ACCEPTED)
async def delete_todo(todo_id: int,user: user_dependency,db: db_dependency):
    if user is None or user.get('user_role')!='admin':
        raise HTTPException(status_code=401,detail='user not found')
    else:
        (db.query(Todos)
         .filter(Todos.id == todo_id)
         .delete())

        db.commit()


