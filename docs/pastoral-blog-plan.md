# Pastoral Blog — Implementation Plan

## Context

Church leadership needs to author and publish long-form blog-style posts from the portal, which then appear as a scrollable feed on the mobile app. Members can react to posts (amen / prayer / heart). This replaces "Daily Devotionals" in the roadmap — the intent is a pastoral communications channel, not a structured devotional schedule. No commenting in v1.

The closest existing analogue is the **group feed**: leader-authored Quill rich-text posts + emoji reactions. The pastoral blog is church-wide (no group scope), adds a draft/publish workflow, and is authored exclusively from the portal.

---

## System 1 — Supabase Migration

**New file:** `migrations/20260607120000_add_pastoral_blog.sql`

### Tables

**`pastoral_posts`**
```
id                      uuid pk default gen_random_uuid()
author_user_id          uuid not null references auth.users on delete cascade
title                   text not null, check char_length(trim(title)) > 0
content                 text not null, check char_length(trim(content)) > 0  -- Quill Delta JSON
cover_image_url         text
cover_image_public_id   text
is_published            boolean not null default false
created_at              timestamptz not null default now()
updated_at              timestamptz not null default now()
```
Indexes: `(is_published, created_at desc)`, `(author_user_id)`

**`pastoral_post_reactions`**
```
id                      uuid pk default gen_random_uuid()
pastoral_post_id        uuid not null references pastoral_posts on delete cascade
user_id                 uuid not null references auth.users on delete cascade
reaction_type           text not null, check reaction_type in ('amen', 'prayer', 'heart')
created_at              timestamptz not null default now()
updated_at              timestamptz not null default now()
unique (pastoral_post_id, user_id)
```
Indexes: `(pastoral_post_id)`, `(user_id)`

Both tables get `moddatetime` triggers on `updated_at`.

### View — `pastoral_posts_view`

Enriches the base table with:
- Author: `first_name`, `last_name`, `author_full_name`, `profile_public_id`, `profile_url`
- Reaction aggregates (lateral joins): `reaction_count`, `amen_count`, `prayer_count`, `heart_count`
- Current user state: `current_user_reaction`, `is_author`
- **No `is_published` filter in the view** — RLS handles visibility. Portal admins see all rows; app users see only published posts.

### RLS

| Table | Policy | Rule |
|-------|--------|------|
| `pastoral_posts` | SELECT | `is_published = true OR public.is_super_admin(auth.uid())` |
| `pastoral_posts` | INSERT / UPDATE / DELETE | `public.is_super_admin(auth.uid())` |
| `pastoral_post_reactions` | SELECT / INSERT / UPDATE / DELETE | Standard authenticated user patterns (mirror `group_post_reactions`) |

### RPCs

All follow existing conventions: `target_*` params, `actor_id uuid := auth.uid()`.

| RPC | Guard | Notes |
|-----|-------|-------|
| `create_pastoral_post(target_title, target_content, target_cover_image_url, target_cover_image_public_id)` | SUPER_ADMIN | Returns `pastoral_posts` row |
| `update_pastoral_post(target_post_id, target_title, target_content, target_cover_image_url, target_cover_image_public_id)` | SUPER_ADMIN | Returns updated row |
| `set_pastoral_post_published(target_post_id, should_publish)` | SUPER_ADMIN | Mirrors `set_group_post_pinned` pattern |
| `delete_pastoral_post(target_post_id)` | SUPER_ADMIN | Returns deleted row |
| `set_pastoral_post_reaction(target_post_id, target_reaction_type)` | authenticated | Upsert on conflict |
| `remove_pastoral_post_reaction(target_post_id)` | authenticated | Standard delete |

---

## System 2 — Portal (LW_Portal_2.0)

### New shared component: `LwpQuillEditor.vue`
**Path:** `src/components/lwp-quill-editor/LwpQuillEditor.vue`

This is the only net-new shared component. The viewer already exists at `src/components/lwp-quill-viewer/LwpQuillViewer.vue` — mirror its Quill setup but with `readOnly: false` and a minimal toolbar (bold, italic, underline, H1/H2, bullet list, numbered list). Emits `update:modelValue` (Delta JSON string) for v-model compatibility.

### Types
**Path:** `src/types/pastoral-blog/pastoral-post.ts`

```typescript
export type PastoralPost = {
  id: string
  author_user_id: string
  title: string
  content: string            // Quill Delta JSON
  cover_image_url?: string | null
  cover_image_public_id?: string | null
  is_published: boolean
  created_at: string
  updated_at: string
  author_first_name?: string | null
  author_last_name?: string | null
  author_full_name?: string | null
  author_profile_public_id?: string | null
  author_profile_url?: string | null
  reaction_count?: number
  amen_count?: number
  prayer_count?: number
  heart_count?: number
  current_user_reaction?: string | null
  is_author?: boolean
}
```

### Service
**Path:** `src/services/pastoral-blog/pastoral-blog-service.ts`

Mirror `connect-serve-service.ts` style:
- `sbQueryPastoralPosts()` → query `pastoral_posts_view`, order `created_at desc`
- `sbCreatePastoralPost(payload)` → RPC `create_pastoral_post`
- `sbUpdatePastoralPost(id, payload)` → RPC `update_pastoral_post`
- `sbSetPastoralPostPublished(id, published)` → RPC `set_pastoral_post_published`
- `sbDeletePastoralPost(id)` → RPC `delete_pastoral_post`

### Store
**Path:** `src/stores/pastoral-blog/pastoral-blog.store.ts`

- State: `posts: PastoralPost[]`, `postsStatus: Status`, `actionStatus: Status`
- Actions: `loadPosts()`, `createPost()`, `updatePost()`, `setPublished()`, `deletePost()`
- All actions use Toast for feedback, consistent with the announcements store pattern.

### Views

**`PastoralBlogView.vue`** — `src/views/pastoral-blog/PastoralBlogView.vue`
- DataTable listing all posts (admins see drafts + published)
- Columns: Cover thumbnail, Title, Author, Status badge (Draft / Published), Date, Actions
- Row actions: Edit (navigate to edit view), Publish/Unpublish toggle, Delete (with confirm dialog)
- "New Post" button in header → navigates to edit view with no ID
- `LwpSkeletonTable` for loading, `LwpEmptyState` for empty

**`PastoralBlogEditView.vue`** — `src/views/pastoral-blog/PastoralBlogEditView.vue`

Full-page editor (not a modal — rich text needs the space):
- Title field (InputText, required)
- Cover image upload (reuse `LwpImageUploader`)
- `LwpQuillEditor` for body content
- Publish toggle (ToggleSwitch)
- Save and Cancel actions
- Handles both create (no route param) and edit (`/pastoral-blog/:id/edit`)

### Router additions
`src/router/index.ts`:
```
/pastoral-blog              → PastoralBlogView (list)
/pastoral-blog/new          → PastoralBlogEditView (create)
/pastoral-blog/:id/edit     → PastoralBlogEditView (edit, props: true)
```

### Sidebar navigation
Add a "Blog" nav item in the sidebar alongside or grouped near Announcements.

---

## System 3 — LW_App (Flutter)

### Model
**Path:** `lib/Models/PastoralBlog/pastoral_post.dart`

Mirror `lib/Models/Group/group_post.dart`. Key fields: `id`, `authorUserId`, `title`, `content`, `coverImageUrl`, `coverImagePublicId`, `isPublished`, `createdAt`, `updatedAt`, author enrichment fields, all reaction count fields, `currentUserReaction`, `isAuthor`. Drop `groupId` and `isPinned` — not applicable here. Include `copyWith()`, `fromJson()`, and `displayAuthorName` helpers.

### Service
**Path:** `lib/Services/PastoralBlog/pastoral_blog_service.dart`

Mirror `lib/Services/Groups/groups_service.dart`:
- `getPastoralPosts()` → query `pastoral_posts_view`, order `created_at desc`
- `setPastoralPostReaction({postId, reactionType})` → RPC `set_pastoral_post_reaction`
- `removePastoralPostReaction(postId)` → RPC `remove_pastoral_post_reaction`

### BLoC
**Path:** `lib/Blocs/PastoralBlog/pastoral_blog_{bloc,event,state}.dart`

Mirror `lib/Blocs/GroupDetail/group_detail_{bloc,event,state}.dart`, stripped of group-specific concerns.

**Events:**
- `LoadPastoralBlog`
- `RefreshPastoralBlog`
- `TogglePastoralPostReaction({post, reactionType})`
- `ClearPastoralBlogMessage`

**State fields:** `status`, `posts: List<PastoralPost>`, `isRefreshing`, `isFeedActionInProgress`, `message`, `isErrorMessage`

**Key pattern:** `TogglePastoralPostReaction` uses the identical optimistic update + revert logic from `group_detail_bloc.dart` (`_applyReactionPreview` equivalent). If the user already has that reaction type, it removes it; otherwise it sets it.

### Screen
**Path:** `lib/Screens/PastoralBlog/pastoral_blog.dart`

Mirror `lib/Screens/GroupFeed/group_feed.dart`:
- `PastoralBlogPage` (stateless, provides BLoC via `BlocProvider`) → `_PastoralBlogView` (stateful)
- `CustomScrollView` with `SliverAppBar` + `SliverList` of post cards
- Pull-to-refresh via `RefreshIndicator` dispatching `RefreshPastoralBlog`
- `LwpLoader` / `LwpError` / `LwpEmpty` for load states
- `LwpSnackbar` for action feedback

**Post card widget** (`_PastoralBlogPostCard`):
- Cover image (Cloudinary via `CldImageWidget`, optional — placeholder if none)
- Title, author name, formatted date
- Rich text body via `QuillEditor(readOnly: true)` — same as group feed
- Reaction row: three `ActionChip` widgets (amen / prayer / heart) with counts, selected-state highlighting, disabled during `isFeedActionInProgress` — mirror `_GroupFeedPostCard` pattern exactly

### Navigation entry point
Add a "Blog" tile on the home screen (`lib/Screens/Home/`). Uses standard `MaterialPageRoute` to `PastoralBlogPage`.

---

## Delivery Order

1. Supabase migration (everything depends on this)
2. Portal types + service + store
3. `LwpQuillEditor` component
4. Portal views + router + sidebar nav
5. App model + service
6. App BLoC
7. App screen + home navigation

---

## Verification

- Portal: create a draft post → confirm it does **not** appear in the app
- Portal: publish → confirm it appears in the app feed
- Portal: unpublish → confirm it disappears from the app feed
- Portal: delete post → confirm cascade removes all reactions
- App: react to a post → optimistic update shows immediately, correct count, toggling same reaction removes it
- App: pull-to-refresh reloads the feed
- Portal: `npm run type-check` passes with no errors
- Portal: `npm run lint` clean
