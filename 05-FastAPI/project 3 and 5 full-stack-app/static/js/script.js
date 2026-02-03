// Add Todo JS
const todoForm = document.getElementById('todoForm');
if (todoForm) {
    todoForm.addEventListener('submit', async function (event) {
        event.preventDefault();

        const form = event.target;
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        // Fixed: send 'completed' to match backend
        const payload = {
            title: data.title,
            description: data.description,
            priority: parseInt(data.priority),
            completed: data.completed === "on" // changed from 'complete'
        };

        try {
            const response = await fetch('/todos/todo', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${getCookie('access_token')}`
                },
                body: JSON.stringify(payload)
            });

            if (response.ok) {
                form.reset();
            } else {
                const errorData = await response.json();
                alert(`Error: ${errorData.detail}`);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        }
    });
}

// Edit Todo JS
const editTodoForm = document.getElementById('editTodoForm');

if (editTodoForm) {
    editTodoForm.addEventListener('submit', async function (event) {
        event.preventDefault();

        const formData = new FormData(editTodoForm);

        const params = new URLSearchParams({
            title: formData.get('title'),
            description: formData.get('description'),
            priority: formData.get('priority'),
            completed: formData.has('completed') ? 'true' : 'false'
        });

        const todoId = window.location.pathname.split('/').pop();
        const token = getCookie('access_token');

        const response = await fetch(
            `/todos/todo/${todoId}?${params.toString()}`,
            {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            }
        );

        if (response.ok) {
            window.location.href = '/todos/todo-page';
        } else {
            const err = await response.json();
            alert(err.detail);
        }
    });

    const deleteBtn = document.getElementById('deleteButton');
    if (deleteBtn) {
        deleteBtn.addEventListener('click', async () => {
            const todoId = window.location.pathname.split('/').pop();
            const token = getCookie('access_token');

            await fetch(`/todos/todo/${todoId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            window.location.href = '/todos/todo-page';
        });
    }
}



// Login JS
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', async function (event) {
        event.preventDefault();

        const form = event.target;
        const formData = new FormData(form);

        const payload = new URLSearchParams();
        for (const [key, value] of formData.entries()) {
            payload.append(key, value);
        }

        try {
            const response = await fetch('/auth/token', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: payload.toString()
            });

            if (response.ok) {
                const data = await response.json();
                logout(); // optional, keeps behavior
                document.cookie = `access_token=${data.access_token}; path=/`;
                window.location.href = '/todos/todo-page';
            } else {
                const errorData = await response.json();
                alert(`Error: ${errorData.detail}`);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        }
    });
}

// Register JS
const registerForm = document.getElementById('registerForm');
if (registerForm) {
    registerForm.addEventListener('submit', async function (event) {
        event.preventDefault();

        const form = event.target;
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (data.password !== data.password2) {
            alert("Passwords do not match");
            return;
        }

        // Fixed field names to match backend
        const payload = {
            email: data.email,
            username: data.username,
            first_name: data.first_name, // changed from firstname
            last_name: data.last_name,   // changed from lastname
            role: data.role,
            phone_number: data.phone_number,
            password: data.password
        };

        try {
            const response = await fetch('/auth', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            if (response.ok) {
                window.location.href = '/auth/login-page';
            } else {
                const errorData = await response.json();
                alert(`Error: ${errorData.detail}`); // changed from message
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        }
    });
}

// Helper functions
function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.startsWith(name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

function logout() {
    const cookies = document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
        const cookie = cookies[i];
        const eqPos = cookie.indexOf("=");
        const name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
        document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
    }
    window.location.href = '/auth/login-page';
}
