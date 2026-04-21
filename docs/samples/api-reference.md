# API Endpoint Reference

## Authentication

| Method | Path               | Description          | Auth Required |
|--------|--------------------|----------------------|---------------|
| POST   | /api/auth/login    | Authenticate user    | No            |
| POST   | /api/auth/logout   | End session          | Yes           |
| POST   | /api/auth/refresh  | Refresh access token | Yes (refresh) |

## Tasks

| Method | Path              | Description        | Auth Required |
|--------|-------------------|--------------------|---------------|
| GET    | /api/tasks        | List tasks         | Yes           |
| POST   | /api/tasks        | Create task        | Yes           |
| GET    | /api/tasks/:id    | Get task details   | Yes           |
| PUT    | /api/tasks/:id    | Update task        | Yes           |
| DELETE | /api/tasks/:id    | Delete task        | Yes (admin)   |
| GET    | /api/tasks/search | Search tasks       | Yes           |

## Projects

| Method | Path               | Description        | Auth Required |
|--------|--------------------|--------------------|---------------|
| GET    | /api/projects      | List projects      | Yes           |
| POST   | /api/projects      | Create project     | Yes           |
| GET    | /api/projects/:id  | Get project detail | Yes           |
| PUT    | /api/projects/:id  | Update project     | Yes (owner)   |
| DELETE | /api/projects/:id  | Delete project     | Yes (admin)   |

## Common Response Codes

| Code | Meaning               |
|------|-----------------------|
| 200  | Success               |
| 201  | Created               |
| 400  | Bad request           |
| 401  | Not authenticated     |
| 403  | Not authorized        |
| 404  | Resource not found    |
| 429  | Rate limit exceeded   |
| 500  | Internal server error |

## Error Response Format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "The requested resource was not found.",
    "details": null
  }
}
```

## Rate Limiting

- Authenticated requests: 1000 per hour
- Search endpoint: 30 per minute
- Rate limit headers included in every response:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`
