import streamlit as st
from groq import Groq
from streamlit_js_eval import streamlit_js_eval

# Setting up the Streamlit page configuration
st.set_page_config(page_title="StreamlitChatMessageHistory", page_icon="💬")
st.title("Chatbot")

# Initialize session state variables
if "setup_complete" not in st.session_state:
    st.session_state.setup_complete = False
if "user_message_count" not in st.session_state:
    st.session_state.user_message_count = 0
if "feedback_shown" not in st.session_state:
    st.session_state.feedback_shown = False
if "chat_complete" not in st.session_state:
    st.session_state.chat_complete = False
if "messages" not in st.session_state:
    st.session_state.messages = []

# Initialize Groq client ONCE
client = Groq(api_key=st.secrets["GROQ_API_KEY"])

MODEL_NAME = "llama-3.3-70b-versatile"


# Helper functions
def complete_setup():
    st.session_state.setup_complete = True

def show_feedback():
    st.session_state.feedback_shown = True


# ------------------ SETUP STAGE ------------------
if not st.session_state.setup_complete:

    st.subheader('Personal Information')

    if "name" not in st.session_state:
        st.session_state["name"] = ""
    if "experience" not in st.session_state:
        st.session_state["experience"] = ""
    if "skills" not in st.session_state:
        st.session_state["skills"] = ""

    st.session_state["name"] = st.text_input(
        "Name",
        value=st.session_state["name"],
        max_chars=40
    )

    st.session_state["experience"] = st.text_area(
        "Experience",
        value=st.session_state["experience"],
        max_chars=200
    )

    st.session_state["skills"] = st.text_area(
        "Skills",
        value=st.session_state["skills"],
        max_chars=200
    )

    st.subheader('Company and Position')

    if "level" not in st.session_state:
        st.session_state["level"] = "Junior"
    if "position" not in st.session_state:
        st.session_state["position"] = "Data Scientist"
    if "company" not in st.session_state:
        st.session_state["company"] = "Amazon"

    col1, col2 = st.columns(2)

    with col1:
        st.session_state["level"] = st.radio(
            "Choose level",
            ["Junior", "Mid-level", "Senior"],
            index=["Junior", "Mid-level", "Senior"].index(st.session_state["level"])
        )

    with col2:
        st.session_state["position"] = st.selectbox(
            "Choose a position",
            ("Data Scientist", "Data Engineer", "ML Engineer", "BI Analyst", "Financial Analyst"),
            index=("Data Scientist", "Data Engineer", "ML Engineer", "BI Analyst", "Financial Analyst").index(st.session_state["position"])
        )

    st.session_state["company"] = st.selectbox(
        "Select a Company",
        ("Amazon", "Meta", "Udemy", "365 Company", "Nestle", "LinkedIn", "Spotify"),
        index=("Amazon", "Meta", "Udemy", "365 Company", "Nestle", "LinkedIn", "Spotify").index(st.session_state["company"])
    )

    if st.button("Start Interview", on_click=complete_setup):
        st.write("Setup complete. Starting interview...")


# ------------------ INTERVIEW STAGE ------------------
if st.session_state.setup_complete and not st.session_state.feedback_shown and not st.session_state.chat_complete:

    st.info("Start by introducing yourself 👋")

    # Initialize system message once
    if not st.session_state.messages:
        st.session_state.messages = [{
            "role": "system",
            "content": (
                f"You are an HR executive interviewing {st.session_state['name']} "
                f"with experience {st.session_state['experience']} and skills {st.session_state['skills']}. "
                f"Interview him for the position {st.session_state['level']} {st.session_state['position']} "
                f"at {st.session_state['company']}."
            )
        }]

    # Display chat (hide system)
    for message in st.session_state.messages:
        if message["role"] != "system":
            with st.chat_message(message["role"]):
                st.markdown(message["content"])

    if st.session_state.user_message_count < 5:
        if prompt := st.chat_input("Your response", max_chars=1000):

            st.session_state.messages.append({"role": "user", "content": prompt})

            with st.chat_message("user"):
                st.markdown(prompt)

            if st.session_state.user_message_count < 4:
                with st.chat_message("assistant"):

                    def stream_generator():
                        stream = client.chat.completions.create(
                            model=MODEL_NAME,
                            messages=st.session_state.messages,
                            stream=True,
                        )
                        for chunk in stream:
                            content = chunk.choices[0].delta.content
                            if content:
                                yield content

                    response = st.write_stream(stream_generator())

                st.session_state.messages.append(
                    {"role": "assistant", "content": response}
                )

            st.session_state.user_message_count += 1

    if st.session_state.user_message_count >= 5:
        st.session_state.chat_complete = True


# ------------------ FEEDBACK BUTTON ------------------
if st.session_state.chat_complete and not st.session_state.feedback_shown:
    if st.button("Get Feedback", on_click=show_feedback):
        st.write("Fetching feedback...")


# ------------------ FEEDBACK STAGE ------------------
if st.session_state.feedback_shown:

    st.subheader("Feedback")

    conversation_history = "\n".join(
        [f"{msg['role']}: {msg['content']}" for msg in st.session_state.messages]
    )

    feedback_completion = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {
                "role": "system",
                "content": """You are a helpful tool that provides feedback on an interviewee performance.
Before the Feedback give a score of 1 to 10.
Follow this format:
Overall Score: //Your score
Feedback: //Your feedback
Give only the feedback."""
            },
            {
                "role": "user",
                "content": f"Evaluate this interview:\n{conversation_history}"
            }
        ],
    )

    st.write(feedback_completion.choices[0].message.content)

    if st.button("Restart Interview", type="primary"):
        streamlit_js_eval(js_expressions="parent.window.location.reload()")
