from idlelib.rpc import request_queue
from typing import Optional

from fastapi import FastAPI,Path,Query,HTTPException
from pydantic import BaseModel, Field
from starlette import status
app = FastAPI()

class BookRequest(BaseModel):
    id : Optional[int] = Field(description='Id is not needed on create',default=None)
    title: str = Field(min_length=3)
    author: str = Field(min_length=1)
    description: str = Field(min_length=1,max_length=100)
    rating: float = Field(ge=0,le=5)
    published_date : int = Field(ge=1999,le=2031,description='date published')

    model_config = {
        "json_schema_extra":{
            "example":{
                'title':'a new book',
                'author':'codingwithjay',
                'description':'descirption of book',
                'rating':2.2,
                'published_date':2012
            }
        }
    }

class Book:
    id : int
    title: str
    author: str
    description: str
    rating: float
    published_date: int

    def __init__(self ,id , title , author, description, rating,published_date):
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.rating = rating
        self.published_date = published_date




BOOKS = [
    Book(1,'computer science pro','coding with jay','a very nice book', 5,2012),

    Book(2,'fast api','coding with jay','a very nice book', 5,2013),

    Book(3,'slow api','coding with jay','a very nice book', 2,2012),

    Book(4,'ai','author 1','book desc', 4,2026),

    Book(5,'ml','author 2','book desc', 4,2019),

    Book(6,'hp3','author 3','book desc', 1,2012)
]

@app.get("/books", status_code=status.HTTP_200_OK)
async def get_books():
    return BOOKS

@app.get("/books/{book_id}", status_code=status.HTTP_200_OK)
async def read_book(book_id : int = Path(gt=0)):
    for book in BOOKS:
        if book.id == book_id:
            return book
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail='resource not found')


@app.post("/create-book", status_code=status.HTTP_201_CREATED)
async def create_book(book_request: BookRequest):
    new_book = Book(**book_request.model_dump())
    new_book.id = 1 if len(BOOKS) == 0 else BOOKS[-1].id + 1
    BOOKS.append(new_book)
    return new_book

#filter by rating
@app.get("/books/", status_code=status.HTTP_200_OK)
async def read_books(book_rating: Optional[float] = Query(ge=0,le=5, default=None), published_date: Optional[int] = Query(ge=1999,le=2031, default=None)):
    books_to_return = []
    for book in BOOKS:
        if (book_rating is not None and book.rating == book_rating) or \
                (published_date is not None and book.published_date == published_date):
            books_to_return.append(book)
    return books_to_return

#put request
@app.put("/books/update_book", status_code=status.HTTP_204_NO_CONTENT)
async def update_book(book: BookRequest):
    change = False
    for i in range(len(BOOKS)):
        if BOOKS[i].id == book.id:
            BOOKS[i] = Book(**book.model_dump())
            change = True
            break
    if not change:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='resource not found')
    return BOOKS[i]


@app.delete("/books/{book_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_book(book_id: int= Path(gt=0)):
        change = False
        for i in range(len(BOOKS)):
            if BOOKS[i].id == book_id:
                BOOKS.pop(i)
                change = True
                break
        if not change:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='resource not found')
# 2xx request success
# 4xx response client error
# 5xx server error server error
