from datetime import timedelta, datetime, timezone
from typing import Annotated
from fastapi import FastAPI, APIRouter, Depends,HTTPException,Request
from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status
from jose import jwt , JWTError
from database import SessionLocal
from models import User
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm ,OAuth2PasswordBearer

from fastapi.templating import Jinja2Templates
router = APIRouter(
    prefix='/auth',
    tags=['auth']
)

SECRET_KEY = "supersecretkey123"
ALGORITHM = "HS256"

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")

class CreateUserRequest(BaseModel):
    email :str
    username :str
    first_name :str
    last_name :str
    password :str
    role :str
    phone_number :str

class Token(BaseModel):
    access_token :str
    token_type:str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]

templates = Jinja2Templates(directory='templates')
###pages

@router.get("/login-page")
def render_login(request: Request):
    return templates.TemplateResponse("login.html",{"request":request})

@router.get("/register-page")
def render_register_page(request: Request):
    return templates.TemplateResponse("register.html",{"request":request})



###

def authenticate_user(username :str,password : str ,db):
    user = db.query(User).filter(User.username == username).first()
    print(user.hashed_password)
    if not user:
        return False
    if not bcrypt_context.verify(password, user.hashed_password):
        return False
    return user

def create_token(username: str , user_id : int ,role :str, expires_delta : timedelta):
    encode = {'sub':username,'id':user_id,'role':role}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp':expires})
    return jwt.encode(encode,SECRET_KEY,algorithm=ALGORITHM)

async def get_current_user(token: Annotated[str,Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token,SECRET_KEY,algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        role : str = payload.get('role')
        if username is None or user_id is None:
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='not valid')
        return {'username':username,'user_id':user_id,'user_role':role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='not valid')


@router.post("/",status_code=status.HTTP_201_CREATED)
async def create_user(db:db_dependency, user: CreateUserRequest):
    user_model = User(
        email=user.email,
        username=user.username,
        first_name=user.first_name,
        last_name=user.last_name,
        hashed_password=bcrypt_context.hash(user.password),
        role=user.role,
        is_active=True,
        phone_number=user.phone_number
    )
    db.add(user_model)
    db.commit()

@router.post("/token",response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()],db:db_dependency):
    user = authenticate_user(form_data.username, form_data.password,db)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='not valid')
    else:
        token = create_token(user.username,user.id,user.role,timedelta(minutes=20))
        return {"access_token":token,"token_type":"bearer"}




