# YouVersion API Integration Guide

## Overview

The YouVersion Platform API provides access to Bible metadata, books, chapters, verses, passages, and authentication services.

Base URL:

```txt
https://api.youversion.com/v1
```

Authentication is performed using an App Key provided through the YouVersion developer portal.

---

# Table of Contents

1. Getting Started
2. Authentication
3. Base Headers
4. Bible Endpoints
5. Book Endpoints
6. Chapter Endpoints
7. Verse Endpoints
8. Passage Endpoints
9. Apps Endpoint
10. OAuth / Sign-In APIs
11. Pagination
12. Error Handling
13. Rate Limiting
14. JavaScript Integration
15. Python Integration
16. TypeScript Interfaces
17. Best Practices

---

# 1. Getting Started

## Create a Developer Account

Visit:

https://platform.youversion.com

Create an application and obtain:

- App Key
- OAuth credentials (if using Sign-In APIs)

---

# 2. Authentication

All requests require the following header:

```http
X-YVP-App-Key: YOUR_APP_KEY
```

Example:

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles
```

---

# 3. Base Headers

Recommended headers:

```http
Content-Type: application/json
Accept: application/json
X-YVP-App-Key: YOUR_APP_KEY
```

---

# 4. Bible Endpoints

## Get Available Bibles

### Endpoint

```http
GET /bibles
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles
```

### Optional Query Parameters

| Parameter | Description |
|---|---|
| language_ranges | Comma-separated language codes |
| page_size | Number of items |
| page_token | Pagination token |

### Example Response

```json
{
  "data": [
    {
      "id": 3034,
      "abbreviation": "BSB",
      "title": "Berean Standard Bible",
      "language_tag": "en"
    }
  ]
}
```

---

## Get Bible Details

### Endpoint

```http
GET /bibles/{version_id}
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034
```

---

# 5. Book Endpoints

## Get Books for a Bible

### Endpoint

```http
GET /bibles/{version_id}/books
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/books
```

### Example Response

```json
{
  "data": [
    {
      "id": "GEN",
      "title": "Genesis",
      "canon": "old_testament"
    }
  ]
}
```

---

## Get Single Book

### Endpoint

```http
GET /bibles/{version_id}/books/{book_usfm}
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/books/JHN
```

---

# 6. Chapter Endpoints

## Get Chapters in a Book

### Endpoint

```http
GET /bibles/{version_id}/books/{book_usfm}/chapters
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/books/JHN/chapters
```

---

## Get Chapter Verses

### Endpoint

```http
GET /bibles/{version_id}/books/{book_usfm}/chapters/{chapter_number}/verses
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/books/JHN/chapters/3/verses
```

---

# 7. Verse Endpoints

## Get Specific Verse

### Endpoint

```http
GET /bibles/{version_id}/books/{book_usfm}/chapters/{chapter_number}/verses/{verse_number}
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/books/JHN/chapters/3/verses/16
```

---

# 8. Passage Endpoints

## Get Passage by Reference

### Endpoint

```http
GET /bibles/{version_id}/passages/{reference}
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/bibles/3034/passages/JHN.3.16
```

### Additional Examples

| Reference | Meaning |
|---|---|
| GEN.1 | Genesis 1 |
| PSA.23 | Psalm 23 |
| JHN.3.16 | John 3:16 |
| ROM.8.1-ROM.8.5 | Romans 8:1-5 |

---

# 9. Apps Endpoint

## Get App Details

### Endpoint

```http
GET /apps/{app_id}
```

### Example

```bash
curl -H "X-YVP-App-Key: YOUR_APP_KEY" \
https://api.youversion.com/v1/apps/YOUR_APP_ID
```

---

# 10. OAuth / Sign-In APIs

YouVersion supports OAuth Authorization Code Flow with PKCE.

## Authorization Endpoint

```http
GET https://api.youversion.com/auth/authorize
```

## Required Query Parameters

| Parameter | Description |
|---|---|
| response_type | code |
| client_id | App Key |
| redirect_uri | Registered callback URL |
| scope | openid profile email |
| nonce | Security nonce |
| state | CSRF protection |
| code_challenge | PKCE challenge |
| code_challenge_method | S256 |

## Example Authorization URL

```txt
https://api.youversion.com/auth/authorize
?response_type=code
&client_id=YOUR_APP_KEY
&redirect_uri=https://yourapp.com/callback
&scope=openid profile email
&state=random123
&nonce=random456
&code_challenge=XYZ
&code_challenge_method=S256
```

---

# 11. Pagination

Some endpoints support pagination.

## Request Parameters

| Parameter | Description |
|---|---|
| page_size | Max results |
| page_token | Next page token |

## Example

```http
GET /bibles?page_size=100&page_token=abc123
```

## Response

```json
{
  "data": [],
  "next_page_token": "xyz456"
}
```

---

# 12. Error Handling

## Common Status Codes

| Status | Meaning |
|---|---|
| 200 | Success |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Server Error |
| 503 | Service Unavailable |

## Example Error

```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing App Key"
}
```

---

# 13. Rate Limiting

The documentation does not currently specify public rate limits.

Recommendations:

- Cache Bible metadata
- Retry failed requests with exponential backoff
- Avoid repeated verse fetches

---

# 14. JavaScript Integration

## Fetch Example

```javascript
const API_KEY = process.env.YVP_APP_KEY;

async function getVerse() {
  const response = await fetch(
    "https://api.youversion.com/v1/bibles/3034/passages/JHN.3.16",
    {
      headers: {
        "X-YVP-App-Key": API_KEY
      }
    }
  );

  const data = await response.json();
  return data;
}

getVerse().then(console.log);
```

---

# 15. Python Integration

## Requests Example

```python
import os
import requests

API_KEY = os.getenv("YVP_APP_KEY")

headers = {
    "X-YVP-App-Key": API_KEY
}

url = "https://api.youversion.com/v1/bibles/3034/passages/JHN.3.16"

response = requests.get(url, headers=headers)

print(response.json())
```

---

# 16. TypeScript Interfaces

```typescript
export interface Bible {
  id: number;
  abbreviation: string;
  title: string;
  language_tag: string;
}

export interface Book {
  id: string;
  title: string;
  canon: string;
}

export interface Verse {
  id: string;
  text: string;
}
```

---

# 17. Best Practices

## Use Environment Variables

```bash
export YVP_APP_KEY="your_key"
```

## Cache Static Data

Recommended for:

- Bible versions
- Books
- Chapter metadata

## Use USFM Book Codes

Examples:

| Book | Code |
|---|---|
| Genesis | GEN |
| Matthew | MAT |
| John | JHN |
| Romans | ROM |

## Handle Pagination

Always check for:

```json
next_page_token
```

## Secure OAuth Tokens

- Store securely
- Refresh when expired
- Validate issuer and audience

---

# Useful References

Developer Portal:
https://developers.youversion.com/api

Quick Reference:
https://developers.youversion.com/quick-reference

API Usage:
https://developers.youversion.com/api-usage

OAuth Docs:
https://developers.youversion.com/sign-in-apis

USFM Reference:
https://developers.youversion.com/usfm-reference