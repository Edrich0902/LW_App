# Groups Feed Handoff

## Summary
This document captures the current state of Groups 2.0 and the group feed so another agent can continue work without rediscovering product or technical decisions.

## Current Delivered State

### Shared Backend
- Groups 2.0 membership contract exists in:
  - `supabase/migrations/20260606123000_add_groups_2_0.sql`
  - `supabase/migrations/20260606143000_fix_groups_view_permissions.sql`
- Group feed backend exists in:
  - `supabase/migrations/20260606173000_add_group_posts.sql`
  - `supabase/migrations/20260607000000_add_group_post_pinning.sql`
- The backend currently provides:
  - `group_memberships`
  - `groups_public_view`
  - `groups_admin_view`
  - `group_memberships_view`
  - `group_posts` — includes `is_pinned boolean not null default false`
  - `group_post_reactions`
  - `group_posts_view` — exposes `is_pinned`; ordered by `is_pinned DESC, created_at DESC`
- Feed RPCs currently available:
  - `create_group_post`
  - `update_group_post`
  - `delete_group_post`
  - `set_group_post_reaction`
  - `remove_group_post_reaction`
  - `set_group_post_pinned(target_post_id uuid, should_pin boolean)` — leaders and super_admin only

### Permission Model
- Portal stays `super_admin` only.
- Group leaders are group-scoped, not global roles.
- Active members and active leaders can read group posts.
- Only active leaders can create posts.
- Only the post author can edit or delete the post.
- Any active leader in the group can pin or unpin any post.
- `super_admin` can view, pin/unpin, and delete any post (bypass access).
- Active members can add, change, or remove only their own reaction.

## Mobile Implementation

### Main Files
- `lib/Services/Groups/groups_service.dart`
- `lib/Models/Group/group.dart`
- `lib/Models/Group/group_membership.dart`
- `lib/Models/Group/group_post.dart`
- `lib/Blocs/GroupDetail/group_detail_bloc.dart`
- `lib/Blocs/GroupDetail/group_detail_event.dart`
- `lib/Blocs/GroupDetail/group_detail_state.dart`
- `lib/Screens/GroupDetail/group_detail.dart`
- `lib/Screens/GroupFeed/group_feed.dart`
- `lib/Screens/GroupPostEdit/group_post_edit.dart`
- `lib/Utils/quill_helper.dart`

### Current UX
- Group detail is the lifecycle screen for:
  - join request
  - cancel request
  - leave group
  - leader member-management tools
  - leader limited group editing
- Group feed is a dedicated full-screen screen, not inline in group detail.
- Group detail opens the feed through:
  - an app-bar feed button
  - a dedicated feed entry card in the page body
- Leaders create posts from the full-screen feed using a floating action button.
- Posts use the same Quill rich-text storage approach as Notes.
- Members can react from the feed.
- Feed reactions currently use a single selected reaction per user per post.
- **Pinned posts:** leaders see "Speld"/"Onthef" in the post popup menu. Pinned posts show a "Vasgespeld" badge at the top of the card and float to the top of the feed.

### Pinning Implementation Details
- `GroupPost.isPinned` — mapped from `is_pinned` in `fromJson`, included in `copyWith` and `props`
- `GroupService.setGroupPostPinned(postId, shouldPin)` — calls `set_group_post_pinned` RPC
- `GroupService.getGroupPosts` — orders by `is_pinned DESC, created_at DESC`
- `TogglePinPost` bloc event — dispatched from feed screen, uses `_runFeedAction` pattern
- `_onTogglePinPost` handler — toggles `!post.isPinned` and reloads feed on success

### Post Popup Menu
- Each feed post card shows a `PopupMenuButton` when the user has at least one available action (pin, edit, delete).
- Items use `Row(Icon + SizedBox + Text)` — never plain `Text` only.
- "Verwyder" (delete) uses `Icons.delete_outline` and `TextStyle(color: Colors.red)` — destructive action visual pattern.
- "Speld"/"Onthef" uses `Icons.push_pin` / `Icons.push_pin_outlined` to reflect current pin state.
- "Wysig" uses `Icons.edit_outlined`.
- The popup surface, radius, and border come entirely from `AppTheme.popupMenuTheme` — do not add per-instance styling to `PopupMenuButton`.

### AppTheme: popupMenuTheme
- `popupMenuTheme` is now defined in both `lightTheme` and `darkTheme` inside `lib/Themes/custom_theme.dart`.
- Light: `color: LightColors.surface`, `side: LightColors.outline`, `borderRadius: LwpRadii.lg`.
- Dark: `color: DarkColors.surface`, `side: Colors.white12`, `borderRadius: LwpRadii.lg`.
- `surfaceTintColor: Colors.transparent` on both — suppresses Material 3 tint bleed.
- Any future `PopupMenuButton` in the app automatically inherits this theming without local overrides.

## Portal Implementation

### Feed Moderation (ConnectServeManageView)
- The group manage screen (`/connect-serve/:id/manage`) now has two tabs: **Members** and **Feed**.
- Feed tab shows all posts for the group ordered pinned-first, then newest.
- Each post card shows: author name, timestamp, optional title, Quill-rendered content, reaction count.
- **Admin actions per post:** Pin/Unpin toggle button, Delete button with confirmation dialog.
- Loading: `LwpSkeletonTable` placeholder. Empty: `LwpEmptyState`.

### Portal Avatar Pattern
- All user-facing avatar slots (Leaders, Active Members, Pending Requests columns, and Feed post author) use PrimeVue `Avatar` + `LwpImage`, **not** raw `<img>` tags.
- Pattern: `<Avatar shape="circle" class="!h-8 !w-8 shrink-0 overflow-hidden"><LwpImage :public-id="..." :height="32" :width="32" class-name="w-full h-full object-cover" /></Avatar>` when `profile_public_id` / `author_profile_public_id` is non-null.
- Fallback: `<Avatar :label="initials(data)" shape="circle" class="!h-8 !w-8 shrink-0 text-xs font-semibold" />` for users with no Cloudinary public ID.
- `initials()` helper in the script derives `FI + LI` from `first_name`/`last_name`, or falls back to the first character of `email`.
- `GroupPost` exposes `author_profile_public_id` — use it for the post author avatar, not `author_profile_url`.

### Portal Feed Files
- `src/types/group/group-post.ts` — `GroupPost` type mapping `group_posts_view` columns
- `src/services/connect-serve/connect-serve-service.ts` — `sbQueryGroupPosts`, `sbSetGroupPostPinned`, `sbDeleteGroupPost`
- `src/stores/connect-serve/connect-serve.store.ts` — `posts`, `postsStatus`, `postActionStatus` state; `loadGroupPosts`, `pinGroupPost`, `removeGroupPost` actions
- `src/components/lwp-quill-viewer/LwpQuillViewer.vue` — read-only Quill Delta renderer (auto-imported)
- `src/views/connect-serve/ConnectServeManageView.vue` — Tabs with Members and Feed panels

### Quill in Portal
- `quill` npm package (v2.0.3) is installed.
- `LwpQuillViewer` is a read-only component: no toolbar, no border, inherits surface text color.
- It parses Delta JSON with a try/catch fallback to plain text if JSON is malformed.
- For any future feature that needs rich-text authoring in the portal, the Quill package is already available.

## Product Decisions Locked In
- The feed is intentionally not a two-way chat.
- It is a leader-authored post/update feed with member reactions.
- Rich text is required for posts and reuses the existing Notes-style Quill implementation.
- Feed authoring is mobile-first. Portal can moderate but does not author.
- Push notifications are deferred to a later phase.
- Comments, attachments, read receipts are not implemented.

## Important Known Constraints
- The feed uses `GroupDetailBloc` rather than a separate feed bloc.
  - This was chosen to reuse the existing group-detail fetch and refresh flow.
- The feed route creates its own `GroupDetailBloc` instance and loads the group by `groupId`.
- `group_posts_view` does not have an ORDER BY in its definition — ordering is applied at query time by both the mobile service and the portal service.
- There is no portal feed authoring — this is intentional per product decisions.

## Known Issues Already Solved
- The earlier `permission denied for table users` error on group management came from `security_invoker = on` on views that joined `auth.users`. Fixed in `20260606143000_fix_groups_view_permissions.sql`.

## Next Recommended Feature: Push Notifications
This is the last remaining item in roadmap item #2.
- Trigger: when a leader creates a new group post
- Audience: all active members of that group
- Required backend changes:
  - Add a push notification trigger or function that fires on `group_posts` insert
  - Requires Firebase Cloud Messaging credentials in Supabase secrets or edge function config
- Required portal changes:
  - None required for basic delivery; optionally surface notification delivery status per post in the feed tab
- Required mobile changes:
  - Handle the FCM push payload and deep-link into the relevant `GroupFeedPage(groupId: ...)`
  - Requires the notification routing pattern already used elsewhere in the app

## Verification Status
- `dart format` was run on the changed app files.
- `flutter analyze` on the changed feed files reports only the pre-existing repo-wide baseline `depend_on_referenced_packages` info — no new feed-specific failures.
- The Supabase migrations were written but were not applied to a live database in-session.
- Portal `npm run type-check` reports only pre-existing errors in unrelated files — no new errors from the feed changes.
- Portal `npm run lint` is clean for all changed files.
- `flutter analyze lib/Themes/custom_theme.dart lib/Screens/GroupFeed/group_feed.dart` — no issues after popup menu theming changes.
