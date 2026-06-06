# LW Platform Roadmap

This roadmap is shared by `LW_Portal_2.0` and `LW_App`. The two roadmap files must remain identical so planning and delivery stay aligned across the admin portal and the member-facing app.

## Sync Rule
- Always keep `LW_Portal_2.0/roadmap.md` and `LW_App/Roadmap.md` in sync when adding new features, reprioritizing work, or marking features complete.

## Shared Product Direction
LW Portal is the operational and content control layer.
LW App is the congregation-facing experience layer.
Both products run on the same Supabase backend and should be planned as one platform rather than two separate systems.

## Current Shared Foundation
These backend domains already exist in the system and should be extended before introducing unrelated new modules:
- Users and profiles
- Announcements
- Sermons
- Events and event RSVP
- Groups / Connect and Serve
- Prayer requests
- Notes
- Social media links
- Tithes and offerings settings
- Meta data / church information

## Now
These are the next highest-value features because they build directly on existing shared entities and create complete loops between portal operations and app engagement.

### 1. Groups 2.0
Turn groups into a full discipleship and community workflow.
- Status: shared Supabase contract, portal admin management, and app member/leader flows are delivered
- Backend: `group_memberships`, shared views, RPCs, and RLS for join, approve, decline, leave, remove, and leader assignment
- Portal: group CRUD plus leader assignment, active-member management, pending-request approval, and membership counts
- App: dedicated group detail screens, join/leave actions, `My Groups`, and leader moderation tools
- App: group feed with leader-authored rich-text posts and member reactions

### 2. Group Feed Moderation and Notifications
Extend the new group feed into an operational communications loop.
- Status: pinned posts (backend, mobile, portal) and portal feed moderation are delivered; push notifications remain pending
- Backend: `is_pinned` column, `set_group_post_pinned` RPC, and updated `group_posts_view` with pinned-first ordering
- Portal: feed tab in group manage view — admins can view, pin/unpin, and delete posts via Quill rich-text viewer
- App: leaders can pin/unpin posts from the group feed; pinned posts are visually badged and float to top
- App: deep links into specific group posts when notifications are added
- Add push notification delivery for new group posts
- Add feed analytics or read-state only if needed later

### 3. Prayer Workflow Completion
Complete the prayer request lifecycle from submission to care follow-up.
- Status: portal private requests and pastoral notes trail delivered; app-side and assignment remain
- Portal: multi-step pastoral notes per request — admins can add/delete internal notes with author + timestamp trail
- Portal: private request flag — hides the request from the public app view; portal admins see all
- App: replace generic reaction with `Ek Het Gebid`
- App: allow request owners to post updates / praise reports
- App: support private prayer requests visible only to church leadership
- Portal: assign prayer requests to a leader or team member (deferred)

### 4. Announcements and Notifications Platform
Use announcements as the base communications system across the platform.
- Portal: scheduled announcements
- Portal: push action for mobile delivery
- App: notification center for missed announcements and pushes
- App: event reminder notifications for RSVP'd users
- Add delivery and read-state tracking where practical

### 5. Sermon Series and Contextual Notes
Improve sermon discoverability and long-term engagement.
- Portal: sermon series management with artwork and descriptions
- App: series collections and guided discovery
- App: sermon-linked notes
- App: continue watching / listening progress

### 6. Pastoral Blog
A pastoral communications channel where church leaders author and publish blog-style posts from the portal, which appear as a scrollable feed on the mobile app. Members can react to posts.
- Status: delivered — Supabase schema (pastoral_posts, pastoral_post_reactions, pastoral_posts_view, RPCs), portal list + editor views, LwpQuillEditor component, app feed screen with reactions, BLoC with optimistic updates, and dashboard tile.
- Backend: `pastoral_posts`, `pastoral_post_reactions`, `pastoral_posts_view`, RPCs for create/update/publish/delete/react
- Portal: post list (draft/published status), full-page Quill editor with cover image upload and publish toggle
- App: scrollable post feed with cover images, rich-text body, and amen/prayer/heart reactions
- Commenting on posts deferred to a future iteration

### 7. Attendance and Check-In
Add the next operational layer on top of events and RSVPs.
- Portal: attendance registers per event or service
- Portal: first-timer visibility and follow-up flags
- App: QR or manual event check-in for selected event types
- Portal: attendance reporting and trends

## Next
These are strong follow-on features once the "Now" items are in place.

### 8. Member Journey CRM
Track the path from visitor to engaged member.
- Journey stages such as visitor, regular, membership class, member, serving
- Owner assignment for follow-up
- Notes, tasks, and dashboard summaries

### 9. Volunteer Scheduling and Rosters
Coordinate service teams more effectively.
- Portal: roster builder, conflict detection, role assignment
- App: volunteer schedule visibility and reminders
- Future option: member availability submission in-app

### 10. Featured Content and Home Screen Curation
Let the portal intentionally shape what users see first.
- Pin sermons, events, testimonies, or announcements
- Add expiry dates and ordering
- Preview home screen content from the portal

### 11. Resource Library
Create a managed library for documents and study resources.
- Portal: upload and organize PDFs and other files
- App: browse and download resources by category
- Optional role-based access for restricted resources

### 12. Giving Records and Reporting
Extend giving from static banking details into structured stewardship data.
- Portal: record individual giving entries
- Portal: member and aggregate giving reports
- App: eventual in-app giving support if payment integration is introduced

### 13. Dashboard Analytics and Reporting
Make trends visible to leaders and administrators.
- Attendance trends
- Member growth and conversion funnels
- Sermon and announcement engagement
- Exportable reports

## Later
These are good platform expansions, but they should follow the shared workflow and engagement work above.

### 14. Global Search
- Portal: command palette / entity search
- App: cross-content search for sermons, events, groups, and prayer requests

### 15. Testimonies Module
- App submission flow
- Portal moderation queue
- Featured testimonies and home screen placement

### 16. Live Service Mode
- Portal `Go Live` control
- App live-state surfacing and alerts

### 17. Audit Trail and Granular Roles
- Immutable activity logs
- More specific admin role permissions

### 18. Media Library
- Reusable Cloudinary-backed asset management
- Search, tagging, and reuse across modules

### 19. Settings and Integrations Hub
- Church profile
- Firebase / WhatsApp / SMS credentials
- Admin preferences and operational settings

## New Additions To Include
These were not cleanly represented in the original roadmaps and should now be considered part of platform planning.

### Households and Family Links
- Link spouses, parents, and children where relevant
- Useful for pastoral care, attendance, and ministry follow-up

### Follow-Up Task Engine
- Generate and assign tasks from first-timer visits, unresolved prayer requests, and join requests
- Provide due dates, ownership, and completion tracking

### Volunteer Availability
- Allow members to submit availability in the app
- Use that data in portal roster planning

### Profile Completeness and Data Quality
- Prompt members to complete profile details
- Surface missing key fields to admins for cleanup

### Content Expiry and Archiving Rules
- Auto-expire stale announcements, pins, and event promotions
- Reduce manual cleanup in the portal

### Language Preference Targeting
- Support Afrikaans and English delivery preferences for announcements, devotionals, and notifications if needed later

## Delivery Rule
When a feature affects shared backend data or a user workflow that spans portal and app, planning must cover:
- Required Supabase schema changes
- Portal admin workflows
- App member workflows
- Permissions and visibility rules
- Notifications or follow-up actions
- Analytics or reporting needs
