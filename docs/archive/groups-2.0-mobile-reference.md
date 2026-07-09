# Groups 2.0 Mobile Reference

This document defines the remaining `LW_App` work for Groups 2.0.
It is a build reference for the mobile implementation while the shared backend contract and portal admin tooling are already in progress.

## Current State

The current mobile implementation is still pre-Groups-2.0.

Current files and behavior:
- `lib/Services/Groups/groups_service.dart`
  - reads directly from `groups`
  - filters only by `type`
  - has no group detail, membership, join, leave, or moderation calls
- `lib/Models/Group/group.dart`
  - has only basic group fields
  - assumes `whatsappLink` is always available
  - has no membership status or count fields
- `lib/Blocs/ConnectGroups/connect_groups_bloc.dart`
  - loads only a simple list
- `lib/Blocs/ServiceGroups/service_groups_bloc.dart`
  - loads only a simple list
- `lib/Screens/ConnectGroups/connect_groups.dart`
  - renders a list of connect groups
- `lib/Screens/ServeGroups/serve_groups.dart`
  - renders a list of serve groups
- `lib/Widgets/Group/lwp_group_card.dart`
  - opens a bottom sheet on tap
- `lib/Widgets/Group/lwp_group_bottom_sheet.dart`
  - exposes an unconditional WhatsApp CTA
  - does not reflect membership state
- `lib/Screens/Profile/profile.dart`
  - has no `My Groups` entry point

## Backend Contract To Target

The mobile app must target the shared Supabase Groups 2.0 contract now in place.

Use these backend objects:
- `groups_public_view`
  - list and detail reads for member-facing group data
  - includes:
    - base group fields
    - `leader_count`
    - `member_count`
    - `pending_count`
    - `membership_status`
    - `isLeader`
    - conditional `whatsappLink`
- `group_memberships_view`
  - leader/member management reads where allowed by RLS
- RPCs:
  - `request_group_join`
  - `cancel_group_join_request`
  - `approve_group_membership`
  - `decline_group_membership`
  - `leave_group`
  - `remove_group_member`
  - `set_group_leader`
  - `update_group_from_leader`

Important backend behavior:
- `whatsappLink` is hidden for non-members, non-leaders, and non-super-admins
- users can re-request after `declined`, `left`, or `removed`
- leaders are group-scoped only
- app must not expose leader assignment or deletion controls

## Required Model Changes

### Update `lib/Models/Group/group.dart`

Extend `Group` to support Groups 2.0 fields:
- `membershipStatus` nullable string or enum
- `isLeader` bool
- `leaderCount` int
- `memberCount` int
- `pendingCount` int
- `whatsappLink` nullable or empty-safe because backend now hides it for non-members

Recommended additional model cleanup:
- convert `type` to existing `GroupType` usage where practical
- make `location` and `whatsappLink` nullable-safe instead of assuming both are always present

### Add membership models

Create new models under `lib/Models/Group/`:
- `group_membership.dart`
- optional enums or constants for:
  - `leader | member`
  - `pending | active | declined | left | removed`

`GroupMembership` should include:
- `id`
- `groupId`
- `userId`
- `role`
- `status`
- `requestedAt`
- `respondedAt`
- `respondedBy`
- `joinedAt`
- `firstName`
- `lastName`
- `fullName`
- `email`
- `profilePublicId`
- `profileUrl`
- responder display fields if needed in UI

## Required Service Changes

### Replace raw table reads in `lib/Services/Groups/groups_service.dart`

The service should stop using `groups` for app reads and instead use `groups_public_view`.

Required methods:
- `Future<List<Group>> getConnectGroups()`
  - source: `groups_public_view`
  - filter: `type = connect`
- `Future<List<Group>> getServeGroups()`
  - source: `groups_public_view`
  - filter: `type = serve`
- `Future<Group> getGroupDetail(String groupId)`
  - source: `groups_public_view`
  - filter by `id`
- `Future<void> requestGroupJoin(String groupId)`
  - RPC: `request_group_join`
- `Future<void> cancelGroupJoinRequest(String groupId)`
  - RPC: `cancel_group_join_request`
- `Future<void> leaveGroup(String groupId)`
  - RPC: `leave_group`
- `Future<List<Group>> getMyGroups()`
  - source: `groups_public_view`
  - filter rows where `membership_status` is not null
  - include both `active` and `pending`
- `Future<List<GroupMembership>> getGroupMemberships(String groupId)`
  - source: `group_memberships_view`
  - used only in leader-capable detail flows
- `Future<void> approveGroupMembership(String groupId, String userId)`
  - RPC: `approve_group_membership`
- `Future<void> declineGroupMembership(String groupId, String userId)`
  - RPC: `decline_group_membership`
- `Future<void> removeGroupMember(String groupId, String userId)`
  - RPC: `remove_group_member`
- `Future<void> updateGroupFromLeader(...)`
  - RPC: `update_group_from_leader`
  - must not expose group `type`, deletion, or leader assignment

Do not add mobile calls for:
- deleting groups
- setting leaders
- changing group type

## Required BLoC Changes

The current separate list BLoCs are too shallow for Groups 2.0.

### Keep and extend existing list BLoCs

Update:
- `lib/Blocs/ConnectGroups/connect_groups_bloc.dart`
- `lib/Blocs/ServiceGroups/service_groups_bloc.dart`

They should continue loading list pages, but the loaded data must now come from `groups_public_view` and expose membership/count data in cards.

### Add a dedicated group detail BLoC

Create a new feature, for example:
- `lib/Blocs/GroupDetail/`

Required responsibilities:
- load group detail
- request join
- cancel pending request
- leave group
- refresh after every action
- optionally load memberships when current user is a leader
- optionally handle leader edit submit if edits live on the same screen

Suggested events:
- `LoadGroupDetail(groupId)`
- `RefreshGroupDetail(groupId)`
- `RequestToJoinGroup(groupId)`
- `CancelGroupJoinRequest(groupId)`
- `LeaveGroup(groupId)`
- `LoadGroupMemberships(groupId)`
- `ApproveGroupMembership(groupId, userId)`
- `DeclineGroupMembership(groupId, userId)`
- `RemoveGroupMember(groupId, userId)`
- `UpdateGroupFromLeader(...)`

Suggested state shape:
- group detail payload
- optional membership list payload
- loading flag
- action-in-progress flag
- last success/error message

### Add a My Groups BLoC

Create a dedicated feature, for example:
- `lib/Blocs/MyGroups/`

Responsibilities:
- load current user's active and pending groups
- split or group the result for the UI
- refresh after returning from group detail

Suggested states should expose:
- active groups list
- pending groups list
- loading/error state

## Required Screen Changes

### Replace the bottom-sheet-only flow

Current tap behavior in `lib/Widgets/Group/lwp_group_card.dart` opens `lwp_group_bottom_sheet.dart`.
This should be replaced with navigation to a full group detail screen.

Create a new screen, for example:
- `lib/Screens/GroupDetail/group_detail.dart`

The detail screen must support these user states.

#### Non-member
Show:
- group banner
- title
- description
- location CTA if present
- counts
- `Request to Join` button

Do not show:
- WhatsApp CTA if backend returns no link

#### Pending requester
Show:
- `Request Pending`
- `Cancel Request`

Do not show:
- WhatsApp CTA

#### Active member
Show:
- WhatsApp CTA if `whatsappLink` is returned
- `Leave Group`

#### Leader
Show everything an active member sees, plus:
- pending requests section
- approve action
- decline action
- active members section
- remove member action
- limited edit action for group details

Do not show on mobile leader UI:
- delete group
- assign leaders
- remove leaders
- change `type`

### Add `My Groups` screen

Create a screen such as:
- `lib/Screens/MyGroups/my_groups.dart`

Entry point:
- add it to `lib/Screens/Profile/profile.dart`
- place it near the existing personal items like notes and prayer requests

The screen should show:
- active memberships section
- pending requests section
- empty state if neither exists

Tapping a row should navigate to group detail.

### Update list screens

Update:
- `lib/Screens/ConnectGroups/connect_groups.dart`
- `lib/Screens/ServeGroups/serve_groups.dart`

List items should start surfacing:
- leader/member counts
- pending badge if current user has a pending request
- state-aware subtitle or chip if useful

These screens should still be list-first and lightweight.
Do not move all lifecycle actions into the list itself.

## Required Widget Changes

### Update `lib/Widgets/Group/lwp_group_card.dart`

Change tap behavior:
- navigate to detail screen
- stop opening the old bottom sheet as the primary interaction

Visual additions:
- counts
- membership state chip where useful
- optional leader indicator

### Retire or reduce `lib/Widgets/Group/lwp_group_bottom_sheet.dart`

Options:
- remove it entirely if no longer needed
- keep it only for a condensed preview pattern elsewhere

It must not remain the main lifecycle UI because it cannot cleanly hold:
- join state
- leave flow
- moderation queue
- leader edit tools

### Add leader/member management widgets if needed

Possible new widgets:
- `group_membership_tile.dart`
- `group_pending_request_card.dart`
- `group_action_bar.dart`
- `group_membership_status_chip.dart`

## Leader Editing Scope On Mobile

Mobile leaders can edit only member-facing fields.

Allowed fields:
- `title`
- `description`
- `whatsappLink`
- `location`
- `banner`

Not allowed:
- `type`
- deleting the group
- assigning/removing leaders

If edit UI is added, it should call `update_group_from_leader` instead of direct `groups` table updates.

## Permissions And Visibility Rules The UI Must Respect

The mobile UI must assume backend enforcement is correct, but it should still render responsibly.

Rules:
- non-members must not see a WhatsApp join CTA if no `whatsappLink` is returned
- pending users must not see member-only actions
- leader tools must render only when `isLeader == true`
- `My Groups` should include pending and active states, but not historical declined/left/removed groups
- if a leader loses access between refreshes, the UI should fall back cleanly to regular member or public detail state

## Suggested Delivery Order In LW_App

1. Update models for group and membership payloads.
2. Replace raw `groups` reads in `groups_service.dart` with `groups_public_view` and add RPC methods.
3. Update connect/serve list BLoCs and cards to accept the richer payload.
4. Build the dedicated group detail BLoC and screen.
5. Add join, cancel, and leave flows.
6. Add `My Groups` screen and profile entry point.
7. Add leader moderation tools and limited edit UI.
8. Run `flutter analyze` and `flutter test` and verify against real backend transitions.

## Acceptance Criteria

The mobile work is complete when all of the following are true:
- connect and serve lists still load from the new backend contract
- tapping a group opens a full detail screen, not just a lifecycle-poor bottom sheet
- non-members can request to join
- pending users can cancel requests
- active members can leave groups
- WhatsApp CTA is only shown when the backend returns a link
- `My Groups` is reachable from Profile and shows active plus pending rows
- leaders can approve, decline, and remove from within the app
- leaders can edit only member-facing fields
- the mobile app does not expose leader assignment, type changes, or delete actions
- state changes made in portal are reflected correctly in the app after refresh

## Files Expected To Change

Primary files:
- `lib/Models/Group/group.dart`
- `lib/Services/Groups/groups_service.dart`
- `lib/Blocs/ConnectGroups/connect_groups_bloc.dart`
- `lib/Blocs/ServiceGroups/service_groups_bloc.dart`
- `lib/Screens/ConnectGroups/connect_groups.dart`
- `lib/Screens/ServeGroups/serve_groups.dart`
- `lib/Widgets/Group/lwp_group_card.dart`
- `lib/Widgets/Group/lwp_group_bottom_sheet.dart`
- `lib/Screens/Profile/profile.dart`

New files likely required:
- `lib/Models/Group/group_membership.dart`
- `lib/Blocs/GroupDetail/...`
- `lib/Blocs/MyGroups/...`
- `lib/Screens/GroupDetail/group_detail.dart`
- `lib/Screens/MyGroups/my_groups.dart`
- supporting group detail / membership widgets
