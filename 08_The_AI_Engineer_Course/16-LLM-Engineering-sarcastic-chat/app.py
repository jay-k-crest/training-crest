import os
import json
import sqlite3
from datetime import datetime
from typing import List, Dict, Any

import streamlit as st
import groq

# -----------------------------
# App Config
# -----------------------------
st.set_page_config(
    page_title="SarcastiChat",
    page_icon="💬",
    layout="wide"
)

# Free Groq models
GROQ_MODELS = {
    "Llama 3.3 70B": "llama-3.3-70b-versatile",
    "Llama 3.1 8B": "llama-3.1-8b-instant",
    "Llama 4 Maverick 17B": "meta-llama/llama-4-maverick-17b-128e-instruct",
    "Llama 4 Scout 17B": "meta-llama/llama-4-scout-17b-16e-instruct",
    "Qwen 3 32B": "qwen/qwen3-32b",
    "Kimi K2": "moonshotai/kimi-k2-instruct",
    "GPT-OSS 120B": "openai/gpt-oss-120b",
    "Allam 2 7B": "allam-2-7b",
}

SYSTEM_INSTRUCTION = (
    "You are SarcastiChat: a witty, sarcastic assistant who still gives correct, helpful answers. "
    "Keep the sarcasm playful, never mean-spirited."
)

DB_PATH = "chat_memory.db"


# -----------------------------
# Database functions
# -----------------------------
def get_conn():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            ts TEXT NOT NULL,
            FOREIGN KEY(conversation_id) REFERENCES conversations(id)
        )
    """)
    return conn


def create_conversation(conn, title: str) -> int:
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO conversations (title, created_at) VALUES (?, ?)",
        (title, datetime.utcnow().isoformat())
    )
    conn.commit()
    return cur.lastrowid


def list_conversations(conn):
    cur = conn.cursor()
    cur.execute("SELECT id, title, created_at FROM conversations ORDER BY id DESC")
    return [{"id": r[0], "title": r[1], "created_at": r[2]} for r in cur.fetchall()]


def rename_conversation(conn, conv_id: int, new_title: str):
    conn.execute("UPDATE conversations SET title=? WHERE id=?", (new_title, conv_id))
    conn.commit()


def delete_conversation(conn, conv_id: int):
    conn.execute("DELETE FROM messages WHERE conversation_id=?", (conv_id,))
    conn.execute("DELETE FROM conversations WHERE id=?", (conv_id,))
    conn.commit()


def add_message(conn, conv_id: int, role: str, content: str):
    conn.execute(
        "INSERT INTO messages (conversation_id, role, content, ts) VALUES (?, ?, ?, ?)",
        (conv_id, role, content, datetime.utcnow().isoformat()),
    )
    conn.commit()


def get_messages(conn, conv_id: int):
    cur = conn.cursor()
    cur.execute(
        "SELECT role, content FROM messages WHERE conversation_id=? ORDER BY id ASC",
        (conv_id,)
    )
    return [{"role": r[0], "content": r[1]} for r in cur.fetchall()]


def clear_messages(conn, conv_id: int):
    conn.execute("DELETE FROM messages WHERE conversation_id=?", (conv_id,))
    conn.commit()


def export_conversation(conn, conv_id: int):
    cur = conn.cursor()
    cur.execute("SELECT title, created_at FROM conversations WHERE id=?", (conv_id,))
    row = cur.fetchone()
    if not row:
        return {}
    messages = get_messages(conn, conv_id)
    return {"id": conv_id, "title": row[0], "created_at": row[1], "messages": messages}


# -----------------------------
# Groq helper
# -----------------------------
def get_groq_response(client, messages, model, temperature=0.7, max_tokens=2048):
    try:
        completion = client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
        )
        return completion.choices[0].message.content
    except Exception as e:
        return f"Error: {str(e)}"


# -----------------------------
# Initialize database
# -----------------------------
conn = get_conn()

# -----------------------------
# Sidebar
# -----------------------------
with st.sidebar:
    st.title("💬 SarcastiChat")

    # API Key
    api_key = st.text_input("Groq API Key", type="password", placeholder="gsk_...")
    if not api_key:
        api_key = os.getenv("GROQ_API_KEY", "")

    if api_key:
        st.divider()

        # Model selection
        model_name = st.selectbox("Model", options=list(GROQ_MODELS.keys()))
        model = GROQ_MODELS[model_name]

        # Settings
        with st.expander("Settings"):
            temperature = st.slider("Temperature", 0.0, 2.0, 0.7, 0.1)
            max_tokens = st.slider("Max Tokens", 256, 4096, 2048, 256)

    st.divider()

    # Conversations
    st.subheader("Conversations")

    # List conversations
    convs = list_conversations(conn)

    # Initialize session state
    if "conv_id" not in st.session_state:
        if convs:
            st.session_state.conv_id = convs[0]["id"]
        else:
            st.session_state.conv_id = create_conversation(conn, "New Chat")

    # Conversation selector
    if convs:
        conv_titles = {c["title"]: c["id"] for c in convs}
        selected = st.selectbox(
            "Switch chat",
            options=list(conv_titles.keys()),
            index=0
        )
        st.session_state.conv_id = conv_titles[selected]

    # Action buttons in a simple layout
    col1, col2 = st.columns(2)
    with col1:
        if st.button("➕ New", use_container_width=True):
            new_id = create_conversation(conn, "New Chat")
            st.session_state.conv_id = new_id
            st.rerun()

    with col2:
        if st.button("🗑️ Delete", use_container_width=True):
            delete_conversation(conn, st.session_state.conv_id)
            remaining = list_conversations(conn)
            if remaining:
                st.session_state.conv_id = remaining[0]["id"]
            else:
                st.session_state.conv_id = create_conversation(conn, "New Chat")
            st.rerun()

    col3, col4 = st.columns(2)
    with col3:
        if st.button("✏️ Rename", use_container_width=True):
            st.session_state.show_rename = True

    with col4:
        if st.button("🧹 Clear", use_container_width=True):
            clear_messages(conn, st.session_state.conv_id)
            st.rerun()

    # Rename popup
    if st.session_state.get("show_rename", False):
        new_title = st.text_input("New title")
        if st.button("Update"):
            if new_title.strip():
                rename_conversation(conn, st.session_state.conv_id, new_title.strip())
                st.session_state.show_rename = False
                st.rerun()

    # Export
    if st.button("📥 Export", use_container_width=True):
        data = export_conversation(conn, st.session_state.conv_id)
        st.download_button(
            "Download JSON",
            data=json.dumps(data, indent=2),
            file_name=f"chat_{st.session_state.conv_id}.json",
            mime="application/json"
        )

    # Stats
    messages = get_messages(conn, st.session_state.conv_id)
    st.caption(f"Messages: {len(messages)}")

# -----------------------------
# Main chat area
# -----------------------------
if not api_key:
    st.info("👆 Enter your Groq API key in the sidebar to start chatting")
    st.stop()

# Get current conversation
current_conv = next((c for c in convs if c["id"] == st.session_state.conv_id), None)
if current_conv:
    st.header(f"📝 {current_conv['title']}")

# Display messages
for msg in get_messages(conn, st.session_state.conv_id):
    with st.chat_message(msg["role"]):
        st.write(msg["content"])

# Chat input
if prompt := st.chat_input("Type your message..."):
    # Add user message
    with st.chat_message("user"):
        st.write(prompt)
    add_message(conn, st.session_state.conv_id, "user", prompt)

    # Build messages for Groq
    history = get_messages(conn, st.session_state.conv_id)[-10:]  # Last 10 for context
    groq_messages = [{"role": "system", "content": SYSTEM_INSTRUCTION}]
    for msg in history:
        groq_messages.append({"role": msg["role"], "content": msg["content"]})

    # Get response
    client = groq.Groq(api_key=api_key)

    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            response = get_groq_response(
                client,
                groq_messages,
                model,
                temperature,
                max_tokens
            )
        st.write(response)

    # Save response
    add_message(conn, st.session_state.conv_id, "assistant", response)

    # Auto-rename if needed
    if len(get_messages(conn, st.session_state.conv_id)) == 2:  # First exchange
        title = prompt[:30] + ("..." if len(prompt) > 30 else "")
        rename_conversation(conn, st.session_state.conv_id, title)
        st.rerun()