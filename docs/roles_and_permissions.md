# Roles and Permissions in Whitehall

## Actions by permission

**Writer** means a signed-in user with no extra permissions. "Editor" can refer to Departmental Editor, Managing Editor or GDS Editor. There is also GDS Admin. Every edition-instance check is also blocked by access limiting.

### Any signed-in user (Writer)

- **Editions, every type:**
  - `index`, `show`, `new`, `create`, `edit`, `update`, `revise`, `diff`, `destroy`, `confirm_destroy`, `update_bypass_id`, `destroy_bypass_id`, `features`, `child_pages`, `choose_type`
  - `change_type`, `change_type_preview`, `apply_change_type`
  - Workflow: `submit`, `unschedule`
  - `translations`, `images`, `tags`, `world_tags`
  - `editorial_remarks#new`, `#create`
  - `fact_check_requests#new`, `#create`, `#index`
  - `review_reminders#*`
  - consultation and call-for-evidence `outcome` / `public_feedback`
  - `attachments`, `uploads`
  - `link_check_reports`
  - `document_history`
- **Collections and worldwide:** document collection groups, members and search; worldwide org pages, offices and translations; editionable social media accounts
- **Organisations:**
  - `index`, `show`, `features`, `about`, `organisations/people#index`, `promotional_features#index`, `#show`
  - `destroy`, `confirm_destroy`
  - `edit`/`update`, `organisation_people#reorder`/`#order` and `promotional_features` (create/edit/destroy/reorder), only for **own org or a child org**
  - contacts, contact translations, organisation translations, offsite links and promotional feature items for **any** org
- **People and roles:**
  - people: new, create, show, index; edit/update/destroy/reorder for anyone who isn't a PM
  - roles and role appointments: create/edit/update/destroy for non-ministerial roles
  - role and person translations
  - historical accounts
- **Other:**
  - topical events (full CRUD, featurings, organisations, about page)
  - world location news (edit, update, translations, offsite links)
  - statistics announcements: everything except unpublishing (create, edit, cancel, date changes, tags, link to publication)
  - policy groups: create and edit
  - features and feature lists
  - `users#index`, `#show`; `authors#show`; dashboard; `new_document`; `more`; `whats_new`; `bookmarklets`; `preview`; `by-content-id`; `/export/...` downloads; `/component-guide`

### Departmental Editor and above

- **Approval workflow:** `publish` and `schedule` (not your own submission), `reject`, `force_publish` and `force_schedule`, `approve_retrospectively`
- **Editions:** `export` and `confirm_export`
- **Social media accounts on organisations:** `new`, `create`, `edit`, `update`, `destroy`
- **Ministerial roles and appointments:** `create`, `edit`, `update`, `destroy`

### Managing Editor and above

- Unpublishing and withdrawing: `unpublish`, `unwithdraw`, `edition_unpublishing#edit`/`#update`
- `statistics_announcement_unpublishings#new`, `#create`
- Marking an edition as political
- Featured links for own/child org

### GDS Editor

- Editing any organisation, and managing featured links
- `cabinet_ministers#*` (reordering)
- `policy_groups#destroy`
- `sitewide_settings#*`
- `users#edit`, `#update`
- Fatality notices for any organisation
- Any action on historic content; choosing the government for history mode

### GDS Admin

Everything a GDS Editor can do on editions, organisations and people, plus:
- `organisations#new`, `#create`, `#destroy`
- `governments#*` (except `index`, which any user can see), including `close`
- `edition_access_limited#*`
- `edition_change_notes#*`
- `editorial_remarks#destroy`
- `people#destroy`
- `republishing#*`, `bulk_republishing#*`, `retagging#*`, `emergency_banner#*`
- Prime Minister records

### Special permissions

- **VIP Editor:** current and previous Prime Minister `people` records
- **Users in a fatality-handling organisation (or GDS Editor):** `fatality_notices#*` except `show`, and `operational_fields#*`
- **Unpublish historic content:** `unpublish` on historic editions
- **Sidekiq Admin:** `/sidekiq`
- **The `history_page` type's organisation** (`af07d5a5-df63-4ddc-9383-6a666845ebe9`): `history_page` standard editions.
