from fastapi import FastAPI, Body

app = FastAPI()

BOOKS = [
    {
        "title": "title one",
        "author": "author one",
        "category": "science"
    },
    {
        "title": "title two",
        "author": "author two",
        "category": "science"
    },
    {
        "title": "title three",
        "author": "author three",
        "category": "history"
    },
    {
        "title": "title four",
        "author": "author four",
        "category": "math"
    },
    {
        "title": "title five",
        "author": "author five",
        "category": "math"
    },
    {
        "title": "title SIX",
        "author": "author Six",
        "category": "interstellar"
    }
]
@app.get("/books")
async def read_all_books(category: str = None):  # Set category as an optional parameter
    if category:
        books_to_return = []
        for book in BOOKS:
            if book.get("category").casefold() == category.casefold():
                books_to_return.append(book)
        return books_to_return

    return BOOKS

@app.get("/books/mybook")
async def real_all_book():
    return  { "title":"harry potter"}
@app.get("/books/{book_title}")
async  def read_all_books(book_title: str):
    for book in BOOKS:
        if book.get("title").casefold() == book_title.casefold():
            return book
        else:
            return {"error": "Book not found"}


@app.get("/books/{book_author}/")
async def read_author_category_by_query(book_author:str,category:str):
    books_to_return = []
    for book in BOOKS:
        if (book.get("category").casefold() == category.casefold() and
                book.get("author").casefold() == book_author.casefold()):
            books_to_return.append(book)
    return books_to_return

@app.post("/books/create_book")
async def create_book(new_book=Body()):
    BOOKS.append(new_book)

@app.put("/books/update_book")
async def update_book(new_book = Body()):
    for i in range(len(BOOKS)):
        if BOOKS[i].get('title').casefold() == new_book.get("title").casefold():
            BOOKS[i].update(new_book)

@app.delete("/books/delete_book/{book_title}")
async def delete_book(book_title : str):
    for i in range(len(BOOKS)):
        if BOOKS[i].get('title').casefold() == book_title.casefold():
            BOOKS.pop(i)
        break
@app.get("/books/get/{book_author}")
async def get_book(book_author: str):
    books_to_return = []
    for i in range(len(BOOKS)):
        if BOOKS[i].get('author').casefold() == book_author.casefold():
            books_to_return.append(BOOKS[i])
    if not books_to_return:
        return {"error": "Book not found"}
    else:
        return books_to_return






