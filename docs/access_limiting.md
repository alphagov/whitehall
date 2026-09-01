# Access limiting

Whitehall lets a publisher restrict a document to a chosen set of people while it's still in draft. This is used to keep sensitive content private until it's ready to publish.

Restrictions only apply to drafts: once an edition is published it becomes visible to everyone, regardless of how it was access limited.

By default, an edition isn't access limited: any signed-in Whitehall user, from any government department, can see and edit any other department's draft. Access limiting is how you opt out of that.

## Access limiting rules at a glance

| Mode               | Who can see the content | Who is blocked |
|--------------------|-------------------------|----------------|
| No limit           | Everyone                | Nobody         |
| Organisation limit | Users whose organisation is on the edition's access-limiting organisations list | Users in any other organisation |
| Individual limit   | Users whose email address is on the edition's access-limiting individuals list  | Everyone else, regardless of their organisation |

Access limiting takes priority over every other permission in Whitehall, including GDS Editor and GDS Admin privileges - see [How enforcement works](#how-enforcement-works) for the mechanism, and [GDS Admin overrides](#gds-admin-overrides-edit-access) for the one route around it.

None of the rules above apply to someone using a shared preview link - see [Sharing a preview link (auth bypass)](#sharing-a-preview-link-auth-bypass), which is a separate mechanism that bypasses all of them.

## Glossary

| Term                   | Meaning |
|------------------------|---------|
| Access limit           | A restriction placed on a piece of content so fewer people can view or edit it while it's in draft |
| Organisation limit     | Access restricted to one or more organisations (teams/departments) |
| Individual limit       | Access restricted to named person(s), identified by their email address |
| GDS Editor / GDS Admin | GDS staff with elevated publishing permissions - but access limits override even their privileges |
| Auth bypass            | A shared link that lets someone view a draft (access limited or not) on the public GOV.UK frontend without signing in |

## Does my role matter?

For access limiting specifically, role only matters in one place: managing access limiting on someone else's edition (the "Edit access" page, below) is **GDS Admin only** - GDS Editors, Managing Editors and Departmental Editors can't use it. Otherwise access limiting doesn't care about role at all: as the [rules table above](#access-limiting-rules-at-a-glance) shows, it blocks everyone equally, including GDS Admins and Editors.

## Setting access limiting on an edition

Access limiting is set on the edition edit page, near the bottom, and offers three options:

- **No** - available to every publisher (the default)
- **Yes, limit to specific organisations** - pick one or more organisations from a select
- **Yes, limit to named publishers** - list specific email addresses

Whoever sets the restriction must include their own organisation (or their own email, for the individuals option) in the list, so they can't lock themselves out.

When limiting to named publishers, it's recommended that you list at least two people rather than one - if the sole person on the list leaves or changes role, a GDS Admin will need to step in to restore access.

## How enforcement works

The access-limiting check is handled by [`EditionRules#access_limit_enforced?`](/lib/whitehall/authority/rules/edition_rules.rb). An edition is in exactly one access-limiting mode at a time - none, organisations, or individuals - so the check simply looks at whichever mode is set, then checks whether the current user's email or organisation is on that mode's allow-list.

Access is controlled entirely through these two lists. Note that until mid 2026, access-limiting was a boolean choice: on or off. If 'on', the document's chosen lead and supporting organisations would double up as the list of organisations the document was access-limited to. When introducing the new mode of 'individual' access-limiting, we also refactored the 'organisation' access-limiting to introduce a separate 'access_limiting_organisations' field, no longer coupling access-limiting to the publisher's choice of lead and supporting organisations.

If a user isn't on the allow-list, they're blocked from every action on the edition - viewing, editing, publishing, deleting - and this applies just as much to GDS Editors and GDS Admins who aren't on the list. The check runs across the editions interface and its related areas (tags, translations, change notes, workflow, fact-check requests). Anyone blocked sees a 403 (forbidden) page.

Beyond Whitehall's UI, the access-limiting also applies:

- On the draft stack (e.g. on the draft preview link)
- On Asset Manager (for attachments and images associated with the access-limited document), kept in sync via [`AssetManager::AttachmentUpdater`](/app/services/asset_manager/attachment_updater.rb) whenever the edition is saved

On the draft stack, the access-limiting information is propagated through to the draft content store, e.g. `access_limited: {"users" => [], "organisations" => ["af07d5a5-df63-4ddc-9383-6a666845ebe9"]}`. The value is an array of Signon user IDs or of Organisation content IDs respectively

On Asset Manager, the access-limiting information is propagated through as either `access_limited_organisation_ids` or `access_limited_user_ids` on the asset.

Publishing the edition clears all access-limiting. For assets, the [`PublishAttachmentAssetJob`](/app/sidekiq/publish_attachment_asset_job.rb) resets each attachment's `draft`, `access_limited_organisation_ids`, `access_limited_user_ids` and `auth_bypass_ids` to empty/false, in a background job triggered by the publish.

## Sharing a preview link (auth bypass)

An editor can generate a shareable preview link for a draft edition - "auth bypass" - that lets anyone with the link view it on the public GOV.UK frontend without signing in or being on any access-limiting allow-list. It's meant for previewing a draft with people outside of Whitehall publisher, including an access-limited one.

Generating a link (via "Share preview link" on the edition page, [`EditionAuthBypassUpdater`](/app/services/edition_auth_bypass_updater.rb)) sets a random `auth_bypass_id` on the edition. This is included in its Publishing API payload as `auth_bypass_ids`, and propagated the same way to the edition's attachments, images, and consultation/call-for-evidence response forms on Asset Manager, via [`EditionAuthBypassAssetPropagator`](/app/services/edition_auth_bypass_asset_propagator.rb).

An editor can revoke a link at any time ("Remove link", [`EditionAuthBypassRevoker`](/app/services/edition_auth_bypass_revoker.rb)), which clears `auth_bypass_id` and pushes the empty `auth_bypass_ids` back out to every associated asset. Publishing the edition does the same automatically, at the same time access limiting itself is reset to "no limit" - both are cleared together as part of the publish action.

## GDS Admin overrides ("Edit access")

Because the normal permission check blocks everyone equally, changing an edition's access limiting needs a separate route that doesn't depend on already having access to that specific edition. This is reachable at `/admin/editions/:id/edit_access_limited`.

From this page a GDS Admin can change or remove the access-limiting mode, organisations, or individual emails. Any change here requires a mandatory "editorial remark" explaining why. The intention for this page is to enable GDS Admins to be able to fix access in cases where publishers may have accidentally locked themselves out (a belt and braces approach, given there is also validation in place to attempt to prevent that from occurring in the first place).
