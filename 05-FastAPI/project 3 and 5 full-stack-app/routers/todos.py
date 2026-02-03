from fastapi import APIRouter,HTTPException,status,Request
from fastapi.params import Depends, Path
from pydantic import BaseModel,Field
from sqlalchemy.orm import Session
from typing import Annotated
from models import Todos
from database import  SessionLocal
from .auth import get_current_user
from starlette.responses import  RedirectResponse
from fastapi.templating import Jinja2Templates

templates = Jinja2Templates(directory='templates')
router = APIRouter(
    prefix='/todos',
    tags=['todos']
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]

class TodoRequest(BaseModel):
    title :str = Field(min_length=3)
    description :str = Field(min_length=3,max_length=100)
    priority: int = Field(gt=0,lt=6,default=1)
    completed: bool = Field(default=False)

###pages

def redirect_to_login():
    return RedirectResponse(url="/auth/login-page")


@router.get("/todo-page")
async def render_todo_page(request: Request, db: db_dependency):
    try:
        user = await get_current_user(request.cookies.get('access_token'))
        if user is None:
            return redirect_to_login()

        todos = db.query(Todos).filter(Todos.owner_id == user.get("user_id")).all()
        return templates.TemplateResponse("todo.html", {"request": request, "todos": todos, "user": user})
    except Exception as e:
        print("Error rendering todo page:", e)
        return redirect_to_login()


@router.get('/add-todo-page')
async def render_add_todo_page(request: Request):
    try:
        user = await get_current_user(request.cookies.get('access_token'))
        if user is None:
            return redirect_to_login()

        return templates.TemplateResponse("add-todo.html", {"request": request, "user": user})
    except Exception as e:
        print("Error rendering add-todo page:", e)
        return redirect_to_login()


@router.get("/edit-todo-page/{todo_id}")
async def render_edit_todo_page(request: Request, todo_id: int, db: db_dependency):
    try:
        user = await get_current_user(request.cookies.get('access_token'))
        if user is None:
            return redirect_to_login()

        todo = db.query(Todos).filter(Todos.id == todo_id, Todos.owner_id == user.get("user_id")).first()
        if not todo:
            return redirect_to_login()  # optional: could show 404 page instead
        return templates.TemplateResponse("edit-todo.html", {"request": request, "todo": todo, "user": user})
    except Exception as e:
        print("Error rendering edit-todo page:", e)
        return redirect_to_login()

###routes


@router.get("/")
async def read_all(user: user_dependency,db: db_dependency):
    if user is None:
        raise HTTPException(status_code=401,detail='user not found')
    return db.query(Todos).filter(Todos.owner_id == user['user_id']).all()

@router.get("/todo/{todo_id}",status_code=status.HTTP_200_OK)
async def read_one(user : user_dependency,db: db_dependency,todo_id: int = Path(gt=0)):
    if user is None:
        raise HTTPException(status_code=401,detail='user not found')

    todo_model = (db.query(Todos)
                  .filter(Todos.id == todo_id)
                  .filter(Todos.owner_id == user['user_id']).
                  first())
    if todo_model is not None:
        return todo_model
    raise HTTPException(status_code=404,detail='todo not found')

# post request

@router.post("/todo",status_code=status.HTTP_201_CREATED)
async def create_todo(user: user_dependency,
                      db:db_dependency,
                      todo_request: TodoRequest):
    if user is None:
        raise HTTPException(status_code=401,detail='user not found')
    todo_model = Todos(**todo_request.model_dump(), owner_id=user['user_id'])

    db.add(todo_model)
    db.commit()

#put
@router.put("/todo/{todo_id}",status_code=status.HTTP_204_NO_CONTENT)
async def update_todo(user: user_dependency,
                      db: db_dependency,
                      todo_id: int = Path(gt=0),
                      todo_request: TodoRequest = Depends(TodoRequest)):
    if user is None:
        raise HTTPException(status_code=401,detail='user not found')

    todo_model = (db.query(Todos)
                  .filter(Todos.id == todo_id)
                  .filter(Todos.owner_id == user['user_id']).
                  first())

    if todo_model is None:
        raise HTTPException(status_code=404,detail='todo not found')
    else:
        todo_model.title = todo_request.title
        todo_model.description = todo_request.description
        todo_model.priority = todo_request.priority
        todo_model.completed = todo_request.completed

        db.add(todo_model)
        db.commit()

# delete_todo
@router.delete("/todo/{todo_id}",status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(user: user_dependency,db: db_dependency,todo_id: int = Path(gt=0)):
    if user is None:
        raise HTTPException(status_code=401,detail='user not found')

    todo_model = (db.query(Todos)
                  .filter(Todos.id == todo_id).
                  filter(Todos.owner_id == user['user_id']).
                  first())

    if todo_model is None:
        raise HTTPException(status_code=404,detail='todo not found')
    else:
        (db.query(Todos)
         .filter(Todos.id == todo_id)
         .filter(Todos.owner_id == user['user_id'])
         .delete())

        db.commit()



