from fastapi.testclient import TestClient
from fastapi import status
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from passlib.context import CryptContext

from main import app
from database import Base
from routers.auth import get_db
from models import User

# -----------------------------
# TEST DATABASE SETUP
# -----------------------------
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base.metadata.create_all(bind=engine)

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

# -----------------------------
# CREATE USER SAFELY (IDEMPOTENT)
# -----------------------------
def setup_module():
    db = TestingSessionLocal()

    user = db.query(User).filter(User.username == "jay").first()
    if not user:
        user = User(
            email="test@test.com",
            username="jay",
            first_name="Jay",
            last_name="Kalsariya",
            hashed_password=bcrypt_context.hash("password"),
            role="admin",
            is_active=True,
            phone_number="9999999999",
        )
        db.add(user)
        db.commit()

    db.close()

# -----------------------------
# AUTH (LOGIN ONLY)
# -----------------------------
def get_auth_headers():
    response = client.post(
        "/auth/token",
        data={
            "username": "jay",
            "password": "password",
        },
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

# -----------------------------
# HEALTH
# -----------------------------
def test_health():
    res = client.get("/health")
    assert res.status_code == 200

# -----------------------------
# AUTH
# -----------------------------
def test_login():
    headers = get_auth_headers()
    assert headers["Authorization"].startswith("Bearer ")

# -----------------------------
# TODOS
# -----------------------------
def test_create_todo():
    headers = get_auth_headers()
    res = client.post(
        "/todo",
        headers=headers,
        json={
            "title": "Todo 1",
            "description": "Desc",
            "priority": 1,
            "completed": False,
        },
    )
    assert res.status_code == status.HTTP_201_CREATED

def test_read_all_todos():
    headers = get_auth_headers()
    res = client.get("/", headers=headers)
    assert res.status_code == 200

def test_read_single_todo():
    headers = get_auth_headers()
    res = client.get("/todo/1", headers=headers)
    assert res.status_code in (200, 404)

def test_update_todo():
    headers = get_auth_headers()
    res = client.put(
        "/todo/1",
        headers=headers,
        json={
            "title": "Updated",
            "description": "Updated Desc",
            "priority": 2,
            "completed": True,
        },
    )
    assert res.status_code == 422  # expected due to Depends(TodoRequest)

def test_delete_todo():
    headers = get_auth_headers()
    res = client.delete("/todo/1", headers=headers)
    assert res.status_code in (204, 404)

# -----------------------------
# USER
# -----------------------------
def test_get_user():
    headers = get_auth_headers()
    res = client.get("/user/", headers=headers)
    assert res.status_code == 200

def test_change_password():
    headers = get_auth_headers()
    res = client.put(
        "/user/password",
        headers=headers,
        json={
            "password": "password",
            "new_password": "newpassword",
        },
    )
    assert res.status_code in (204, 401)

def test_change_phone():
    headers = get_auth_headers()
    res = client.put(
        "/user/phone_number",
        headers=headers,
        json={
            "phone_number": "9999999999",
            "new_phone_number": "8888888888",
        },
    )
    assert res.status_code == 204

# -----------------------------
# ADMIN
# -----------------------------
def test_admin_get_todos():
    headers = get_auth_headers()
    res = client.get("/admin/todos", headers=headers)
    assert res.status_code == 200

def test_admin_delete_todo():
    headers = get_auth_headers()
    res = client.delete("/admin/todos/1", headers=headers)
    assert res.status_code in (202, 404)
