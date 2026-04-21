# Search API Design

## Endpoint

`GET /api/tasks/search`

## Query Parameters

| Parameter | Type   | Required | Description                |
|-----------|--------|----------|----------------------------|
| q         | string | yes      | Search query text          |
| project   | int    | no       | Filter by project ID       |
| status    | string | no       | Filter by task status      |
| page      | int    | no       | Page number (default: 1)   |
| limit     | int    | no       | Results per page (max: 50) |

## Example Request

```
GET /api/tasks/search?q=dashboard&status=open&page=1&limit=20
```

## Response Format

```json
{
  "results": [
    {
      "id": 42,
      "title": "Fix dashboard loading issue",
      "description": "The dashboard takes too long to load...",
      "status": "open",
      "score": 0.95
    }
  ],
  "total": 1,
  "page": 1,
  "pages": 1
}
```

## Implementation Notes

- Use PostgreSQL full-text search with `tsvector` columns
- Add GIN index on task title and description
- Implement search result ranking by relevance score
- Cache frequent queries with 5-minute TTL via Redis
- Debounce client-side requests (300ms)
