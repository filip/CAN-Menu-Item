# CAN Member API Documentation
**Version:** 2.1 (2026)
**Main API Gateway:** `https://www.creativeapplications.net/wp-json`

Welcome to the CreativeApplications.Net Member API. This interface allows you to programmatically interact with the CAN ecosystem using your member credentials.

---

## ⚖️ Terms of Use

By accessing the CAN Member API, you agree to the following conditions:

### Permitted Uses
- Personal research and data analysis
- Creating custom notifications or alerts for your own use
- Building tools that extend or complement CAN's functionality in novel ways
- Academic research and educational projects
- Integrations with other platforms that add unique value

### Prohibited Uses
- **No replication of CAN services.** You may not use this API to create, distribute, or operate any application, website, or service that replicates, emulates, or substitutes the functionality provided by CreativeApplications.Net, including but not limited to:
  - The CAN website (creativeapplications.net)
  - Any future official CAN applications or services
- **No competing products.** You may not build alternative clients, readers, or interfaces that serve as replacements for official CAN platforms.
- **No bulk data harvesting.** Systematic downloading of content for the purpose of creating derivative databases or services is prohibited.
- **No redistribution.** Content accessed via this API may not be republished or redistributed without explicit permission.

### Enforcement
CAN reserves the right to revoke API access at any time for violations of these terms or for any activity deemed harmful to the CAN community or platform.

### Changes to Terms
These terms may be updated at any time. Continued use of the API constitutes acceptance of any modifications.

---

## 🔑 Authentication

The API uses **Basic Authentication**. To connect, you must generate an **App Password**:

1. Log in to [CreativeApplications.Net](https://www.creativeapplications.net).
2. Go to **Edit-Profile** > **App Password**.
3. Generate a password.
4. Use your standard username and this 24-character password for all API requests.

> **Note:** Testing these URLs directly in a browser tab will result in a `401 rest_forbidden` error. Authenticated requests must be made via scripts, terminal, or API clients.

### 🔒 App Password Security

- **Revocation:** If you suspect your password has been compromised, generate a new one from your profile settings. This will invalidate the old password.
- **Storage:** Never commit your app password to version control (git). Use environment variables or secure credential storage.
- **Permissions:** Your app password has the same permissions as your account. Only use it with scripts you trust.

---

## 📡 Endpoints

### 1. Activity Logs (Custom CAN Feed)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wp/v2/activity-logs` | Fetch activity feed (paginated) |
| GET | `/wp/v2/activity-logs/{id}` | Get single activity log |
| GET | `/can/v1/activity-thread/{id}` | Get full thread for an activity |
| POST | `/can/v1/activity-comment` | Post a comment on an activity |
| POST | `/can/v1/toggle-like` | Like/unlike an activity |
| POST | `/can/v1/post-activity-entry` | Post a new activity entry (text and/or image) |
| POST | `/can/v1/upload-activity-image` | Upload an image for use in an activity entry |

### 2. Mentions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/can/v1/mentions` | Fetch mentions for current user (paginated) |
| POST | `/can/v1/mark-mentions-read` | Mark all mentions as read |

### 3. Global Site Content (Standard Posts)
Use these to fetch articles or pages referenced by an `object_id`.
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wp/v2/posts/{id}` | Get a standard post/article |
| GET | `/wp/v2/pages/{id}` | Get a page |

### 4. Member Profiles & Updates
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/can/v1/member/{username}` | Get member profile |
| GET | `/can/v1/member-activities/{user_id}` | Get a member's activity feed (paginated) |
| POST | `/can/v1/update-profile` | Update own profile field |

**Profile fields:** `description`, `url`, `location`, `instagram`, `twitterx`, `discord`, `other`

### 5. Save/Bookmark
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/can/v1/toggle-save` | Save/unsave a post (article, event) |
| POST | `/can/v1/toggle-save-archive` | Save/unsave an archive (member, term) |

### 6. Session Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/can/v1/auth-session` | Create WordPress session (returns cookies) |
| GET | `/wp/v2/users/me` | Validate credentials / get current user |

---

## 🛠 Examples

### cURL (Terminal)

**Fetch latest activity logs:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?per_page=10"
```

**Fetch filtered activity logs (e.g., new posts only):**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?per_page=10&filter=Post%20Published"
```

**Fetch your own actions:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?per_page=10&filter=My%20Actions"
```

**Get a specific activity thread:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/can/v1/activity-thread/12345"
```

**Post a comment:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"activity_id": 12345, "comment": "Great work!"}' \
  "https://www.creativeapplications.net/wp-json/can/v1/activity-comment"
```

**Like an activity:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"post_id": 12345}' \
  "https://www.creativeapplications.net/wp-json/can/v1/toggle-like"
```

**Get member profile:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/can/v1/member/filip"
```

**Get a member's activity feed:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/can/v1/member-activities/42?per_page=12&page=1"
```

**Update your bio:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"field": "description", "value": "Creative technologist based in London"}' \
  "https://www.creativeapplications.net/wp-json/can/v1/update-profile"
```

**Save/unsave a post (article or event):**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"post_id": 12345}' \
  "https://www.creativeapplications.net/wp-json/can/v1/toggle-save"
```

**Save/unsave a member:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"type": "author", "slug": "filip"}' \
  "https://www.creativeapplications.net/wp-json/can/v1/toggle-save-archive"
```

**Save/unsave a term (People/Tools):**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"type": "taxonomy", "slug": "zach-lieberman", "taxonomy": "People"}' \
  "https://www.creativeapplications.net/wp-json/can/v1/toggle-save-archive"
```

**Fetch your mentions:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/can/v1/mentions?per_page=10&page=1"
```

**Mark all mentions as read:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "https://www.creativeapplications.net/wp-json/can/v1/mark-mentions-read"
```

**Post a new activity entry (text only):**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"status": "Hello from the API!", "comments_enabled": true}' \
  "https://www.creativeapplications.net/wp-json/can/v1/post-activity-entry"
```

**Upload an image for an activity entry:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -F "file=@/path/to/image.jpg" \
  "https://www.creativeapplications.net/wp-json/can/v1/upload-activity-image"
```

**Post a new activity entry with an uploaded image:**
```bash
curl -X POST -u "your_username:your_app_password" \
  -H "Content-Type: application/json" \
  -d '{"status": "Check out this image!", "attachment_id": 98765, "comments_enabled": true}' \
  "https://www.creativeapplications.net/wp-json/can/v1/post-activity-entry"
```

---

### Python (Requests)

Ideal for data analysis and quick automation.

```python
import requests
from requests.auth import HTTPBasicAuth

user = "your_username"
password = "your_app_password"
base_url = "https://www.creativeapplications.net/wp-json"
auth = HTTPBasicAuth(user, password)

# Fetch latest 5 activity logs
response = requests.get(f"{base_url}/wp/v2/activity-logs?per_page=5", auth=auth)

if response.status_code == 200:
    for log in response.json():
        print(f"ID: {log['id']} | Title: {log['title']['rendered']}")
```

**Fetch all activities with pagination:**
```python
import requests
from requests.auth import HTTPBasicAuth

user = "your_username"
password = "your_app_password"
base_url = "https://www.creativeapplications.net/wp-json"
auth = HTTPBasicAuth(user, password)

all_activities = []
page = 1

while True:
    response = requests.get(
        f"{base_url}/wp/v2/activity-logs?per_page=100&page={page}",
        auth=auth
    )

    if response.status_code != 200 or not response.json():
        break

    all_activities.extend(response.json())
    page += 1

print(f"Fetched {len(all_activities)} activities")
```

**Post a comment:**
```python
import requests
from requests.auth import HTTPBasicAuth

user = "your_username"
password = "your_app_password"
base_url = "https://www.creativeapplications.net/wp-json"
auth = HTTPBasicAuth(user, password)

response = requests.post(
    f"{base_url}/can/v1/activity-comment",
    auth=auth,
    json={"activity_id": 12345, "comment": "Inspiring project!"}
)

if response.status_code == 200:
    print("Comment posted successfully")
```

**Like/unlike an activity:**
```python
import requests
from requests.auth import HTTPBasicAuth

user = "your_username"
password = "your_app_password"
base_url = "https://www.creativeapplications.net/wp-json"
auth = HTTPBasicAuth(user, password)

response = requests.post(
    f"{base_url}/can/v1/toggle-like",
    auth=auth,
    json={"post_id": 12345}
)

if response.status_code == 200:
    data = response.json()
    status = "liked" if data["is_liked"] else "unliked"
    print(f"Activity {status}. Total likes: {data['like_count']}")
```

---

### JavaScript (Node.js / Fetch)

```javascript
const username = "your_username";
const password = "your_app_password";
const baseUrl = "https://www.creativeapplications.net/wp-json";
const auth = Buffer.from(`${username}:${password}`).toString("base64");

// Fetch latest activity logs
async function getActivityLogs() {
  const response = await fetch(`${baseUrl}/wp/v2/activity-logs?per_page=10`, {
    headers: { Authorization: `Basic ${auth}` }
  });

  const logs = await response.json();
  logs.forEach(log => {
    console.log(`ID: ${log.id} | Title: ${log.title.rendered}`);
  });
}

getActivityLogs();
```

**Post a comment (Node.js):**
```javascript
const username = "your_username";
const password = "your_app_password";
const baseUrl = "https://www.creativeapplications.net/wp-json";
const auth = Buffer.from(`${username}:${password}`).toString("base64");

async function postComment(activityId, comment) {
  const response = await fetch(`${baseUrl}/can/v1/activity-comment`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ activity_id: activityId, comment: comment })
  });

  if (response.ok) {
    console.log("Comment posted successfully");
  }
}

postComment(12345, "Amazing work!");
```

---

## 📦 Response Examples

### Activity Log Response
```json
{
  "id": 12345,
  "date": "2026-02-01T12:00:00",
  "title": { "rendered": "Post Published by filip" },
  "content": { "rendered": "<p>@filip updated <a href=\"...\">Article Title</a></p>" },
  "author": 42,
  "like_data": {
    "is_liked": false,
    "like_count": 5,
    "is_author": true,
    "liker_names": ["user1", "user2", "user3", "user4", "user5"]
  }
}
```

### Member Profile Response
```json
{
  "id": 42,
  "username": "filip",
  "description": "Founder of CAN",
  "url": "https://example.com",
  "location": "London, UK",
  "latitude": "51.5074",
  "longitude": "-0.1278",
  "discord": "filip#1234",
  "twitterx": "filip",
  "instagram": "filip",
  "other": "https://linkedin.com/in/filip",
  "isSaved": false,
  "lastActivityVisit": 1740000000
}
```

> **Note:** `lastActivityVisit` is a Unix timestamp and is only included when fetching your own profile. It reflects the last time the activity feed was viewed — via the website, the iOS app, or any API client that fetched page 1 without `silent=1`. Returns `null` if never visited.

### Toggle Like Response
```json
{
  "success": true,
  "is_liked": true,
  "like_count": 6
}
```

### Toggle Save Response (Post)
```json
{
  "success": true,
  "is_saved": true,
  "post_id": 12345
}
```

### Toggle Save Archive Response (Member/Term)
```json
{
  "success": true,
  "is_saved": true
}
```

### Update Profile Response
```json
{
  "success": true,
  "field": "description",
  "value": "Creative technologist based in London"
}
```

### Post Activity Entry Response
```json
{
  "success": true,
  "activity_id": 12345,
  "entry": { }
}
```

> **Note:** The `entry` object contains the full activity log in the same enriched format as the main feed.

### Upload Activity Image Response
```json
{
  "success": true,
  "attachment_id": 98765,
  "url": "https://www.creativeapplications.net/wp-content/uploads/2026/02/activity-filip-20260226.jpg",
  "filename": "activity-filip-20260226.jpg"
}
```

---

## 🔀 Conditional Response Data

Activity logs include additional data fields based on the activity type. These fields are only present when relevant.

### `author_meta` (Profile Updates)

Included when the activity title contains profile update keywords:

| Activity Type | Fields Included |
|---------------|-----------------|
| `User Location Updated` | `location`, `latitude`, `longitude` |
| `User Bio Updated` | `description` |
| `User Website URL Updated` | `url` |
| `User Discord Updated` | `discord` |
| `User TwitterX Updated` | `twitterx` |
| `User Instagram Updated` | `instagram` |
| `User Other Updated` | `other` |

```json
{
  "id": 12345,
  "title": { "rendered": "User Location Updated by filip" },
  "author_meta": {
    "location": "London, UK",
    "latitude": "51.5074",
    "longitude": "-0.1278"
  }
}
```

### `term_data` (Taxonomy Activities)

Included for: `People Saved`, `Tools Saved`, `Term Comment`, `Term Description Added`

```json
{
  "id": 12345,
  "title": { "rendered": "People Saved by filip" },
  "term_data": {
    "name": "Zach Lieberman",
    "description": "Artist and educator based in New York...",
    "link": "https://www.creativeapplications.net/people/zach-lieberman/",
    "image_urls": [
      "https://www.creativeapplications.net/wp-content/uploads/...",
      "https://www.creativeapplications.net/wp-content/uploads/...",
      "https://www.creativeapplications.net/wp-content/uploads/..."
    ]
  }
}
```

### `event_data` (Event Activities)

Included for: `Event Added`

```json
{
  "id": 12345,
  "title": { "rendered": "Event Added by filip" },
  "event_data": {
    "title": "Creative Coding Meetup",
    "excerpt": "Join us for an evening of creative coding...",
    "image_url": "https://www.creativeapplications.net/wp-content/uploads/...",
    "start_date": "2026-03-15",
    "end_date": "2026-03-15",
    "location": "London, UK",
    "event_type": "Meetup",
    "link": "https://www.creativeapplications.net/events/creative-coding-meetup/"
  }
}
```

### `memberData` (Member Saved Activities)

Included for: `Member Saved`

```json
{
  "id": 12345,
  "title": { "rendered": "Member Saved by filip" },
  "memberData": {
    "name": "John Doe",
    "username": "johndoe",
    "description": "Creative developer based in Berlin...",
    "link": "https://www.creativeapplications.net/author/johndoe/",
    "location": "Berlin, Germany"
  }
}
```

### `gallery_images` (Post Activities with Galleries)

Included when the activity references a post that contains a WordPress gallery block. Returns medium-sized image URLs.

```json
{
  "id": 12345,
  "title": { "rendered": "Post Published by filip" },
  "gallery_images": [
    "https://www.creativeapplications.net/wp-content/uploads/2026/02/image1-1200x750.jpg",
    "https://www.creativeapplications.net/wp-content/uploads/2026/02/image2-1200x750.jpg"
  ]
}
```

> **Note:** This field is only present when the referenced post contains a gallery. Posts without galleries will not have this field.

### `activity_entry` (Activity Entry Posts)

Included when the activity is of type `Activity Entry` (posts created via the composer). Contains the attached image and basic author metadata.

```json
{
  "id": 12345,
  "title": { "rendered": "Activity Entry by filip" },
  "activity_entry": {
    "thumbnail_url": "https://www.creativeapplications.net/wp-content/uploads/2026/02/activity-filip-20260226.jpg",
    "thumbnail_filename": "activity-filip-20260226.jpg"
  },
  "author_meta": {
    "username": "filip"
  }
}
```

> **Note:** `thumbnail_url` and `thumbnail_filename` are `null` when no image was attached. The `author_meta` object for activity entries only contains `username`; other profile fields are `null`.

### `save_data` (Always Included)

Present on all activity log responses. Indicates whether the current user has saved the referenced item (post, term, or member).

```json
{
  "save_data": {
    "is_saved": false
  }
}
```

### `like_data` (Always Included)

Present on all activity log responses. Note that `like_count` and `liker_names` are **only visible to the post author** for privacy reasons.

**Response for post author:**
```json
{
  "like_data": {
    "is_liked": false,
    "like_count": 5,
    "is_author": true,
    "liker_names": ["user1", "user2", "user3", "user4", "user5"]
  }
}
```

**Response for other users:**
```json
{
  "like_data": {
    "is_liked": true,
    "is_author": false
  }
}
```

---

## 📝 Query Parameters

### Activity Logs (`/wp/v2/activity-logs`)
| Parameter | Type | Description |
|-----------|------|-------------|
| `per_page` | int | Number of results per page (default: 10, max: 100) |
| `page` | int | Page number for pagination |
| `order` | string | Sort order: `asc` or `desc` (default: `desc`) |
| `orderby` | string | Sort field: `date`, `id`, `title` |
| `author` | int | Filter by author user ID |
| `filter` | string | Filter by activity type (see Filter Values below) |
| `silent` | int | Pass `1` to suppress the last-visit timestamp update (see [Silent Polling](#silent-polling)) |

### Post Activity Entry (`/can/v1/post-activity-entry`)
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Text content of the entry (required if no `attachment_id`) |
| `attachment_id` | int | WordPress attachment ID from a prior image upload (optional) |
| `comments_enabled` | bool | Whether comments are open on this entry (default: true) |

> **Note:** Rate-limited to one post per 2 minutes per user. Returns `429` with a `retry_after` field (seconds) if exceeded.

### Member Activities (`/can/v1/member-activities/{user_id}`)
| Parameter | Type | Description |
|-----------|------|-------------|
| `per_page` | int | Number of results per page (default: 12, max: 100) |
| `page` | int | Page number for pagination |

> **Note:** Returns the same enriched activity log format as `/wp/v2/activity-logs`, filtered to only include activities authored by the specified user.

### Mentions (`/can/v1/mentions`)
| Parameter | Type | Description |
|-----------|------|-------------|
| `per_page` | int | Number of results per page (default: 10, max: 100) |
| `page` | int | Page number for pagination |

### Filter Values

The `filter` parameter accepts the following values:

| Value | Description |
|-------|-------------|
| `all` | Everything (default, no filtering) |
| `My Actions` | Activities authored by the current user |
| `My Daps` | Activities liked by the current user |
| `My Saved` | Save actions by the current user for items still saved |
| `Mentions` | Activities where the current user is mentioned (uses dedicated `/can/v1/mentions` endpoint) |
| `Post Published` | New posts |
| `Event Added` | Events |
| `Comment,Term Comment,Event Comment` | Comments (comma-separated for multiple action types) |
| `User Registered,User Location Updated,Newsletter Subscribed,...` | Members (all member-related action types) |
| `User Location Updated` | Location updates only |
| `User Website URL Updated` | URL updates only |
| `Article Saved,Event Saved,Member Saved,Tool Saved,People Saved` | All save actions |
| `Post Updated` | Updated posts |
| `Term Description Added,Term Created,Term Comment` | People/Tools activities |

> **Note:** For filters with multiple action types, pass them as a comma-separated string. The API will match activities where the action type is any of the provided values.

---

## 🔕 Silent Polling

By default, fetching page 1 of the activity feed stamps a server-side "last visited" timestamp for your account. This timestamp is used by the CAN website to show a dot indicator when new content has been published since your last visit.

If you are building a background polling client (e.g. a menu bar app or notification tool), you should pass `silent=1` to avoid clearing this indicator unintentionally:

```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?page=1&per_page=20&silent=1"
```

### Recommended pattern for a polling client

**1. On startup — sync last-visit state from server:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/can/v1/member/your_username"
```
Use the `lastActivityVisit` Unix timestamp from the response as your baseline.

**2. On each background poll — fetch silently:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?page=1&per_page=20&silent=1"
```
Count entries with an `id` greater than your last known ID, or a `date` newer than `lastActivityVisit`.

**3. When the user acknowledges — stamp the visit:**
```bash
curl -u "your_username:your_app_password" \
  "https://www.creativeapplications.net/wp-json/wp/v2/activity-logs?page=1&per_page=1"
```
Fetch without `silent=1` to update the server-side timestamp, clearing the website dot indicator.

---

## ⚠️ Rate Limits & Best Practices

- Avoid excessive requests in short periods
- Cache responses when possible
- Use pagination (`per_page` and `page`) for large datasets
- Store your app password securely (never commit to version control)
- The API returns standard HTTP status codes (200, 401, 404, etc.)

---

## ❌ Error Codes

The API uses standard HTTP status codes. Here are the most common errors you may encounter:

| Code | Name | Description |
|------|------|-------------|
| `200` | OK | Request successful |
| `400` | Bad Request | Invalid parameters (e.g., missing `activity_id` for comments) |
| `401` | Unauthorized | Missing or invalid credentials. Check your username and app password. |
| `403` | Forbidden | You don't have permission for this action (e.g., updating another user's profile) |
| `404` | Not Found | Resource doesn't exist (e.g., invalid activity ID, unknown username) |
| `500` | Server Error | Something went wrong on the server. Try again later. |

### Error Response Format

```json
{
  "code": "rest_forbidden",
  "message": "You must be logged in to view activity logs.",
  "data": {
    "status": 401
  }
}
```

### Common Issues

**401 Unauthorized**
- Double-check your username (case-sensitive)
- Ensure you're using an App Password, not your regular login password
- Verify the App Password hasn't been revoked
- Make sure there are no extra spaces in credentials

**403 Forbidden**
- You may be trying to access a resource you don't have permission for
- Some security plugins may block requests - ensure your User-Agent header is set

**404 Not Found**
- The activity ID or username doesn't exist
- Check for typos in the endpoint URL

---

## 📞 Support & Contact

**Bug Reports & Issues**
If you encounter API bugs or unexpected behavior, please report them to:
- Email: api@creativeapplications.net

**Feature Requests**
Have ideas for new API endpoints or improvements? We'd love to hear from you at the same address.

**Community**
Join the CAN community to connect with other members and developers:
- Website: [creativeapplications.net](https://www.creativeapplications.net)

> **Note:** API support is provided on a best-effort basis. For urgent account issues, use the standard contact form on the website.

---

## 📋 Changelog

### Version 2.1 (February 2026)
- Added `POST /can/v1/post-activity-entry` endpoint for posting new activity entries (text and/or image)
- Added `POST /can/v1/upload-activity-image` endpoint for uploading images via multipart form data
- Activity entries support optional image attachment via `attachment_id`, comments toggle via `comments_enabled`
- Rate limit: one post per 2 minutes; returns `429` with `retry_after` seconds on violation
- URLs in entry text are automatically linkified server-side
- @mentions in entry text trigger notifications to mentioned users
- New `activity_entry` field in feed responses for entries of type `Activity Entry` (thumbnail URL and filename)
- Feed responses for activity entries also include `author_meta.username`
- Added `silent=1` query parameter to `/wp/v2/activity-logs` — suppresses last-visit timestamp update for background polling clients
- Added `lastActivityVisit` Unix timestamp to own member profile response (`/can/v1/member/{username}`)

### Version 2.0 (February 2026)
- Added `/can/v1/member-activities/{user_id}` endpoint for fetching a specific member's activity feed
- Supports pagination via `page` and `per_page` parameters
- Returns enriched activity log format (same as main feed) filtered by author
- Added `id` field to member profile response (`/can/v1/member/{username}`)

### Version 1.9 (February 2026)
- Gallery images now included inline in activity log responses via `gallery_images` field
- Uses medium-sized images from WordPress attachment metadata for faster loading
- Removed separate `/can/v1/post-gallery/{id}` endpoint — gallery data now comes with the feed
- No additional API calls needed for gallery/carousel display

### Version 1.8 (February 2026)
- Added `post-gallery/{id}` endpoint for fetching gallery image URLs from a post (now removed in v1.9)

### Version 1.7 (February 2026)
- Added `mentions` endpoint for fetching activities where the current user is mentioned
- Added `mark-mentions-read` endpoint for marking all mentions as read
- Added `Mentions` as a filter option with dedicated endpoint
- New mentions indicator: client can poll mentions to detect unread mentions by comparing latest mention ID

### Version 1.6 (February 2026)
- Added `filter` query parameter to activity logs endpoint for server-side filtering
- Supported filters: Everything, My Actions, My Daps, My Saved, New Posts, Events, Comments, Members, Locations, URLs, Saved, Updated Posts, People/Tools
- `My Actions` filter returns activities authored by the current user
- `My Daps` filter returns activities liked by the current user
- `My Saved` filter returns save actions by the current user, cross-referenced against currently saved items
- Comma-separated action type values supported (e.g., `Comment,Term Comment,Event Comment`)
- Filter persists across pagination (load more respects active filter)

### Version 1.5 (February 2026)
- Added `toggle-save` endpoint for saving/unsaving posts (articles, events)
- Added `toggle-save-archive` endpoint for saving/unsaving archives (members, terms)
- Added `save_data` to activity log responses (indicates if item is saved by current user)
- Added `memberData` to activity log responses for "Member Saved" activities
- Added `isSaved` to member profile responses
- Activity logging now fires when saving articles, events, members, and terms

### Version 1.4 (February 2026)
- Added `auth-session` endpoint for WebView authentication
- Added comprehensive documentation with examples
- Added Terms of Use
- Added conditional response data documentation

### Version 1.3 (January 2026)
- Added `toggle-like` endpoint
- Added `activity-comment` endpoint
- Added `activity-thread` endpoint
- Added `update-profile` endpoint
- Added `member/{username}` endpoint
- Added `like_data` to activity log responses
- Added `author_meta` conditional data for profile updates
- Added `term_data` for taxonomy activities
- Added `event_data` for event activities

### Version 1.0 (January 2026)
- Initial API release
- Basic authentication with App Passwords
- Activity logs endpoint (`/wp/v2/activity-logs`)
- Standard WordPress endpoints for posts and pages
