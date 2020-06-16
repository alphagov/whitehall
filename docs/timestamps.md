# Timestamps

## `public_timestamp`

* point in time the edition became visible to the public on the website. Updated for major changes
* used to sort documents in the atom feed
* for building `change_history` on a document
* used when comparing edition published dates in scopes on Edition (e.g. `published_before(date)`)
* set to `first_public_at` or `major_change_published_at` on every save

## `first_published_at`

* signifies when the document was 'first published', which may be before the public timestamp. E.g. transitioned content, etc.
* Either user supplied on the form, or set during publishing to the `major_change_published_at` timestamp

## `first_public_at`

* `first_published_at` on Edition
* `opening_at` on Consultation

## `major_change_published_at`

* date of the last major change. Major changes require change notes. This is decided by the user.

