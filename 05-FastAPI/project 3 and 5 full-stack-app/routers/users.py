from fastapi import APIRouter,HTTPException,status
from fastapi.params import Depends, Path
from passlib.context import CryptContext
from pydantic import BaseModel,Field
from sqlalchemy.orm import Session
from typing import Annotated
from database import SessionLocal
from models import User
from .auth import get_current_user
router = APIRouter(
    prefix='/user',
    tags=['user'],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class user_verify(BaseModel):
    password: str
    new_password: str = Field(min_length=6)

class phone_verify(BaseModel):
    phone_number: str
    new_phone_number: str = Field(min_length=10)

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]
bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.get("/",status_code=status.HTTP_200_OK)
async def get_user(user:user_dependency,db:db_dependency):
    if user is None:
        raise HTTPException(status_code=401, detail='user not found')
    return db.query(User).filter(User.id==user.get('user_id')).first()

@router.put("/password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    user: user_dependency,
    db: db_dependency,
    password_data: user_verify
):
    if user is None:
        raise HTTPException(status_code=401, detail='user not found')

    user_model = db.query(User).filter(
        User.id == user['user_id']
    ).first()

    if not bcrypt_context.verify(
        password_data.password,
        user_model.hashed_password
    ):
        raise HTTPException(status_code=401, detail='invalid password')

    user_model.hashed_password = bcrypt_context.hash(
        password_data.new_password
    )

    db.add(user_model)
    db.commit()


# 1. Rename to avoid conflict
@router.put("/phone_number", status_code=status.HTTP_204_NO_CONTENT)
async def change_phone_number(  # Changed name
        user: user_dependency,
        db: db_dependency,
        phone_data: phone_verify  # Renamed for clarity
):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')

    user_model = db.query(User).filter(User.id == user.get('user_id')).first()

    if user_model is None:
        raise HTTPException(status_code=404, detail='User not found')

    # 2. Use the NEW phone number from the Pydantic model
    user_model.phone_number = phone_data.new_phone_number

    db.add(user_model)
    db.commit()

