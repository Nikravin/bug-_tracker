# Bug Tracker (Flutter + FastAPI)

A full-stack bug/issue tracking application with a Flutter front-end and a FastAPI + SQLAlchemy + PostgreSQL back-end. This monorepo contains both the backend API and the Flutter client.

---

## Features

- User authentication with JWT (login/register)
- Role-based access for admin/project_manager/member
- Project management (create, update, delete, list)
- Project membership management (add/remove members)
- Issue tracking with status and priority
  - Status: open, in_progress, resolved, closed
  - Priority: low, medium, high, critical
- Commenting system per issue
- Dashboard endpoints for user context
- CORS enabled for local and emulator development
- Basic AI chatbot route (personal AI) placeholder

---

## Tech Stack

- Backend: FastAPI, SQLAlchemy 2.x, PostgreSQL, Uvicorn
- Auth: OAuth2 password flow + JWT (python-jose), bcrypt/password hashing
- Frontend: Flutter (Dart), BLoC, Dio, go_router

Badges: 

- ![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
- ![FastAPI](https://img.shields.io/badge/FastAPI-0.115.x-009688)
- ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)
- ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-336791)

---

## Repository Layout

```
bug _tracker/
├─ backend/                  # FastAPI backend
│  ├─ main.py                # App entrypoint
│  ├─ requirements.txt       # Python dependencies
│  ├─ config/db.py           # SQLAlchemy engine/session
│  ├─ models/models.py       # SQLAlchemy models
│  ├─ routes/                # FastAPI routers
│  │  ├─ user_routes.py
│  │  ├─ project_routes.py
│  │  ├─ issue_routes.py
│  │  ├─ comment_routes.py
│  │  └─ ai_chat_bot.py
│  ├─ schemas/               # Pydantic schemas
│  └─ utility/               # JWT, hashing, id generators
└─ frontend/                 # Flutter app
   ├─ pubspec.yaml           # Dart/Flutter dependencies
   └─ lib/
      ├─ services/api_service.dart  # API base URL + HTTP client
      └─ ...
```

---

## Prerequisites

- PostgreSQL (local or remote)
- Python 3.10+ (3.11/3.12/3.13 supported)
- Flutter 3.x with Dart SDK >= 3.8
- Git

---

## Backend Setup (FastAPI)

1) Create and activate a virtual environment

- Windows (PowerShell):

```powershell
python -m venv .venv
. .venv\Scripts\Activate.ps1
```

2) Install dependencies

```powershell
pip install -r backend/requirements.txt
```

3) Configure database and secrets

- Default DB URL is hardcoded in `backend/config/db.py`:

```python
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:sharma123@localhost:5432/bugtracker"
```

- Ensure a PostgreSQL database named `bugtracker` exists and credentials match; or update this value to your own.
- JWT settings are in `backend/utility/token_genrater.py`:
  - `SECRET_KEY`, `ALGORITHM`, and `ACCESS_TOKEN_EXPIRE_MINUTES`.

Tip: In production, move these values to environment variables and load via `python-dotenv` or OS env.

4) Initialize the database

- Tables are auto-created at app start via `Base.metadata.create_all(bind=engine)` in `main.py`.
- You only need to create the database itself in PostgreSQL beforehand.

5) Run the server

- Option A (uvicorn):

```powershell
uvicorn backend.main:app --reload --port 8000
```

- Option B (fastapi-cli):

```powershell
fastapi dev backend/main.py --port 8000
```

6) API docs

- Swagger UI: http://127.0.0.1:8000/docs
- ReDoc: http://127.0.0.1:8000/redoc

---

## Frontend Setup (Flutter)

1) Install dependencies

```bash
cd frontend
flutter pub get
```

2) API base URL (already configured)

- The app uses a dynamic base URL in `lib/services/api_service.dart`:
  - Android emulator: `http://10.0.2.2:8000/api/`
  - iOS simulator, web, desktop: `http://127.0.0.1:8000/api/`

Adjust if your backend runs on a different host/port.

3) Run the app

```bash
# From the frontend directory
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run                # Mobile (select a device)
```

---

## Key API Endpoints (Examples)

Base path: `/api/`

- Auth
  - `POST /api/user/register/` — Create a user (JSON body)
  - `POST /api/user/login/` — OAuth2 password flow (form-data: `username`, `password`) -> returns JWT
  - Auth header: `Authorization: Bearer <token>`

- Users
  - `GET /api/dashboard` — Current user info
  - `GET /api/user/list/` — List other users
  - `GET /api/user/search/` — Search users (q, username, email, id)

- Projects
  - `POST /api/project/add_project/`
  - `GET /api/project/show_all_project/`
  - `GET /api/project/show_project/{project_id}/`
  - `PUT /api/project/update_project/{project_id}/`
  - `DELETE /api/project/delete_project/{project_id}/`
  - `POST /api/project/{project_id}/add_member/{user_id}`
  - `DELETE /api/project/{project_id}/delete_member/{user_id}`

- Issues and Comments
  - Issues routes are mounted under `/api/project/issue/...`
  - Comments routes are under `/api/project/issue/comment/...`

- AI Chatbot
  - Mounted under `/api/personal_ai` (implementation placeholder)

Open Swagger UI to explore and test the full API surface.

---

## Quick cURL Examples

- Register

```bash
curl -X POST http://127.0.0.1:8000/api/user/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "name": "Alice Doe",
    "email": "alice@example.com",
    "role": "project_manager",
    "hashed_password": "secret123"
  }'
```

- Login

```bash
curl -X POST http://127.0.0.1:8000/api/user/login/ \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=alice&password=secret123"
```

- Authenticated request

```bash
curl http://127.0.0.1:8000/api/dashboard \
  -H "Authorization: Bearer <TOKEN>"
```

---

## Troubleshooting

- CORS errors: The backend allows all origins in dev. If testing from browsers/emulators, confirm ports and hosts match the configured base URL.
- Android emulator cannot reach backend: Use `10.0.2.2` instead of `localhost` or `127.0.0.1`.
- Database connection errors: Verify `backend/config/db.py` connection string and PostgreSQL service. Create the `bugtracker` database if it does not exist.
- 401/403 errors: Ensure you include the `Authorization: Bearer <token>` header and your user role has the required privileges.

---

## Security Notes

- Replace the default `SECRET_KEY` in `backend/utility/token_genrater.py`.
- Do not commit real secrets. Prefer environment variables for all secrets and DB URLs.
- Consider adding rate limiting, refresh tokens, and HTTPS in production.

---

## Contributing

1) Fork the repo and create a feature branch
2) Keep changes focused and well-documented
3) Open a Pull Request with a clear description and screenshots when relevant

---

## License

Specify your license (e.g., MIT). If you need, create a `LICENSE` file at the repository root.

---

## Roadmap (suggested)

- Email verification and password reset
- File attachments for issues
- Advanced search and filters
- Notifications (in-app / email)
- Docker Compose for dev environment