# Whitehall Content Auditing

Some content types in Whitehall are versioned so that we are able to explain how a content item reached its current state.

Versioning behaviour is implemented in the [audit trail module](../app/models/audit_trail.rb). At time of writing, this module is included in the `Edition` and `WorldwideOrganisation` models.

Every time an auditable model is created or updated, the audit trail module adds a new record to the versions table. The version data includes the type and ID of the auditable model, the user ID of the user who triggered the event, if available (for updates performed via Rake tasks or queue workers this may not be possible), the new state of the model, and a timestamp. Note that user IDs are tracked in the `whodunnit` column, which is an idea borrowed from the [Paper Trail rails gem](https://github.com/paper-trail-gem/paper_trail).

The `whodunnit` value is populated by fetching the user from the [Current model](../app/models/current.rb). The `Current` model extends the Active Support `CurrentAttributes` [class](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html), which provides convenient access to global request data in a thread-safe manner.