# Admin edition title search performance

Branch for review: `perf/speed-up-admin-edition-title-search`
Base: `bcf513bead` (`main`)

## Where this landed

Searching by title on `/government/admin/editions` took 8–30 seconds against a
production-sized database. The same page with no title typed took about 250 ms.

Total page time, base `main` versus this branch:

| search term | before | after | change |
|---|---|---|---|
| *(no title)* | 55.8 ms | 53.4 ms | 37 → 23 queries |
| `UK` | 24,419 ms | 17,027–18,631 ms | **−24% to −30%** |
| `consultation outcome` | 16,474 ms | 16,211 ms | −1.6% |
| `/guidance` | 16,257 ms | 16,098 ms | −1% |
| `evisa` | 16,331 ms | 16,283 ms | −0.3% |
| `UK-gov` | 15,912 ms, 1 match | 16,209 ms, 1 match | no change |
| pasted full URL | 0.4 ms | 15,623 ms | **slower** |

**A typical title search is not yet faster.** Three things did improve: Rails no
longer collapses the page into one enormous join, the worst-case term is 24–30%
faster, and the page with no title typed makes 14 fewer queries. But the
~16 second floor is untouched, and one case got worse.

Two caveats on that table. The `pasted full URL` row is a deliberate trade-off,
not an accident — see [decision 2](#decisions-for-the-team). And no row
exercises the case the slug fix was written for: both `UK-gov` and the pasted
URL match no edition's slug, so every run falls through to the scan. A
mixed-case URL for an edition that *does* exist should now take ~15 ms rather
than ~16 s, and that has not been measured.

Full per-stage timings are in [Measurements](#measurements).

## Why it is still slow

There were two separate causes, not one:

1. **Typing a title changed how Rails loaded the page's data**, from several
   small queries into one very large join. This branch fixes that, and that fix
   is where the `UK` improvement comes from — the join cost grew with the number
   of matching rows, and `UK` matches 45,047 of them.
2. **Searching for text inside a title has to read the whole
   `edition_translations` table** — 7.4 GB — because nothing indexes the title
   column. This is the bigger cause and it is not fixed yet. It costs a flat
   ~8.1 seconds, charged twice per page view, which is the ~16 second floor.

The branch includes an index that addresses cause 2. Tested locally it makes the
scan 7.8× faster (6,283 ms → 806 ms), but **MySQL's query planner does not
choose to use it**, so as committed it changes nothing end to end. Options for
persuading the planner to use it are listed below and have not been tried. If
one works, a title search should land at roughly 1.7 seconds.

Measurements come from a local replica: 1,465,225 editions, and
`edition_translations` holding about 1.69 million rows (1,617,681 of them
English), 7,436 MB of row data, 67 MB of indexes.

## How to review

Ten commits plus this document, each one self-contained. The two that matter
most are `aecbe4c` (the query change) and `c0d2225` (the follow-up that makes it
hold). `8ff704d` and `fc8cbdb` are the two with trade-offs worth challenging.

The test suite has not been run yet — see [Outstanding](#outstanding).

## Background

Two pieces of behaviour explain most of what follows. Skip if they're familiar.

### Rails has two ways to load associated records

**Preloading** runs one extra small query per association:
`SELECT * FROM documents WHERE id IN (1, 2, 3…)`. Simple and predictable, but
you cannot filter or sort on the loaded table.

**Eager loading** fetches everything in one query using `LEFT OUTER JOIN`. This
lets you filter across tables, but rows multiply: if you join a table that has
many rows per edition, each edition comes back once per matching row.

`includes` asks Rails to pick one. It picks eager loading as soon as it notices
you are also joining that same association — the assumption being that you must
want to query across it. `preload` is an explicit instruction and cannot be
reinterpreted.

### An index only helps if it can answer the question

A database index is sorted, like a dictionary. That makes it good at finding
values by their beginning and useless for finding text in the middle. So
`title LIKE '%evisa%'` — "titles containing evisa anywhere" — cannot use a
normal index on `title`, and MySQL reads every row instead.

An index can still help, though, if it contains **every column the query
needs**. MySQL can then read the index and never touch the table. This is
called a **covering index**, and `EXPLAIN` reports it as `Using index`. It still
reads every entry, but an index holding two columns is far smaller than table
rows holding `title`, `summary`, `body` and `block_content`.

One detail matters later: every MySQL index also stores the table's primary key
(`id`), so it can find the row. It does **not** store any other column unless
you name it explicitly.

## What was slow, and why

### 1. Typing a title turned small queries into one large join

Two places disagreed about how to load translations.

`Edition::Scopes::SearchableByTitle#with_title_containing` called
`in_default_locale`, which **joins** translations:

```ruby
scope :in_default_locale, -> { joins(:translations).where("edition_translations.locale" => I18n.default_locale) }
```

`Admin::EditionFilter#editions_with_translations` separately asked to
**include** them:

```ruby
editions_without_translations.includes(:translations)
```

Rails sees the same association both joined and included, and switches the
whole query to eager loading:

```ruby
# activerecord-8.1.4.1/lib/active_record/relation.rb:1266
def eager_loading?
  @should_eager_load ||= eager_load_values.any? ||
    includes_values.any? && (joined_includes_values.any? || references_eager_loaded_tables?)
end

def joined_includes_values
  includes_values & joins_values   # the overlap between the two lists
end
```

Once that happens, *every* `includes` on the query becomes a join.
`Admin::EditionsController#index` adds three more
(`include_unpublishing`, `include_link_check_report`, `include_last_author`), so
a single statement joined `documents`, a second copy of `edition_translations`,
`unpublishings`, `link_checker_api_reports`, `versions` and `users`.

The worst of those is `last_author`:

```ruby
# app/models/concerns/audit_trail.rb:15-22
has_one :most_recent_version, -> { order("versions.created_at DESC, versions.id DESC") },
        class_name: "Version", as: :item
has_one :last_author, through: :most_recent_version, source: :user
```

It is a `has_one`, but the only thing restricting it to one row is the `order`.
Ordering limits nothing in a join, so every edition came back once per version
it has — an edition with 40 revisions became 40 rows — and the sort from that
association was applied to the whole query.

Two further costs followed. Because `translations` is a `has_many`, Rails could
not simply add `LIMIT 15` to a query whose rows had been multiplied, so it ran
`SELECT DISTINCT editions.id … LIMIT 15` first and then a second query to fetch
those editions. And the result count became `COUNT(DISTINCT editions.id)` over
the same join.

With no title typed, none of this happened: no join was added, the includes
stayed as preloads, and the page took about 250 ms of database time.

### 2. Finding text inside a title reads the whole table

`edition_translations` had no index on `title`, so `title LIKE '%evisa%'` reads
every row — and those rows also carry `summary` (MEDIUMTEXT), `body` (LONGTEXT)
and `block_content` (JSON), which is why the table is 7,436 MB.

One scan takes about 8.1 seconds, and the page pays for **two**: one for the 15
results shown, and one for the "N documents" count above them.

Filtering by state does not narrow this down. `state=active` means
`state != 'superseded'`, on top of a default scope of `state != 'deleted'`. Both
are "not equal" conditions, which indexes cannot help with.

### 3. The results table queried the database once per row

`Admin::EditionsHelper#search_results_table_actions` calls
`edition.document.content_id` and `can?(:see, edition)` for every row.

`can?` reaches `Edition#historic?`, which calls `Edition#government`. That is
not an association — it is a lookup (`Government.find` or
`Government.on_date`) — so Rails cannot preload it, and `historic?` called it
twice per invocation.

`:document` was only preloaded as a side effect of the title search scope. So
browsing *without* a title typed queried `documents` once per row.

## Measurements

From `script/benchmark_edition_search.rb`: median of 3 runs after 1 warmup,
15 per page, state `active`, signed in as a user who is neither a GDS admin nor
a GDS editor. All times in milliseconds. `eager` is whether Rails chose eager
loading; `page` is fetching the 15 results, `count` is the "N documents" total,
`rows` is the per-row work the results table does.

### Before (base `main`)

| case | term | eager | matches | queries | page | count | rows | total |
|---|---|---|---|---|---|---|---|---|
| no title | – | no | 461,766 | 37 | 3.3 | 44.5 | 8.2 | 55.8 |
| path fragment | `/guidance` | yes | 0 | 2 | 8,175.8 | 8,130.8 | 0.0 | 16,256.6 |
| two word phrase | `consultation outcome` | yes | 105 | 18 | 8,145.1 | 8,359.6 | 5.3 | 16,473.5 |
| short term | `UK` | yes | 45,047 | 30 | 12,922.0 | 12,049.3 | 7.8 | 24,418.5 |
| mixed case slug | `UK-gov` | yes | 1 | 6 | 8,147.0 | 8,035.2 | 1.4 | 15,912.3 |
| rare substring | `evisa` | yes | 29 | 20 | 8,201.2 | 8,186.7 | 5.7 | 16,330.5 |
| full url | `https://www.gov.uk/personal-tax-account` | no | 0 | 2 | 0.2 | 0.2 | 0.0 | 0.4 |

### After this branch (index present but unused)

| case | term | eager | matches | queries | page | count | rows | total |
|---|---|---|---|---|---|---|---|---|
| no title | – | no | 461,766 | 23 | 4.0 | 44.5 | 4.8 | 53.4 |
| path fragment | `/guidance` | no | 0 | 2 | 7,946.2 | 8,055.9 | 0.0 | 16,098.2 |
| two word phrase | `consultation outcome` | no | 105 | 23 | 8,146.6 | 8,056.3 | 5.2 | 16,211.0 |
| short term | `UK` | no | 45,047 | 29 | 9,450.0 | 9,174.4 | 6.5 | 18,631.1 |
| mixed case slug | `UK-gov` | no | 1 | 10 | 8,007.1 | 8,151.1 | 1.4 | 16,209.1 |
| rare substring | `evisa` | no | 29 | 24 | 8,117.4 | 8,069.7 | 5.5 | 16,282.5 |
| full url | `https://www.gov.uk/personal-tax-account` | no | 0 | 2 | 7,903.0 | 7,811.5 | 0.0 | 15,623.4 |

### Reading these numbers

- Eager loading is gone from every case, which was the goal of the main change.
- Removing the join removed the part of the cost that grew with the number of
  matching rows. That only shows up on `UK`, the term matching the most rows:
  in an intermediate run, `page` went 12,922 → 8,395 ms and `count` went
  12,049 → 8,136 ms.
- What is left is a flat ~8.1 seconds per scan that **does not depend on how
  many rows match**. `/guidance` matches nothing and still costs 8,178 ms. Two
  scans per page view is the ~16 second floor.
- Queries for the no-title case dropped from 37 to 23, because `documents` is
  now preloaded instead of fetched per row.
- Query counts went up slightly for some title searches (`consultation outcome`
  18 → 23). That is expected: five small preload queries replaced one big join.
- `UK` is slower in the final run than the intermediate one (18,631 vs
  17,027 ms). The index exists in the final run but is not used, so the query
  plan is the same; this is run-to-run variation.
- The `full url` case went from 0.4 ms to 15,623 ms. That is a deliberate
  trade-off in `8ff704d` — see
  [Decisions for the team](#decisions-for-the-team).

## What changed

Ten commits, oldest first.

| Commit | Change |
|---|---|
| `99ad116` | `script/benchmark_edition_search.rb` now measures what a page view actually costs: fetching the results, the "N documents" count, the per-row work, the number of queries, and whether Rails eager loaded. It previously only timed a count. |
| `2304194` | Adds tests that the search escapes `%` and `_`, the two wildcard characters in SQL `LIKE`. The existing test used `[`, which is a regular expression character, not a `LIKE` one, so `sanitize_sql_like` had no test covering it. |
| `8ff704d` | Two fixes to the fast path that recognises a slug. It now lowercases the input, so a pasted URL or path containing capitals uses the indexed `editions.slug` lookup instead of a full scan; this also fixes a crash where searching for `/` alone produced `nil`. And it is only taken when an edition with that slug actually exists, so a hyphenated phrase that appears only in titles is still found. |
| `aecbe4c` | **Main change.** The title search now matches with a subquery instead of joining `edition_translations`, so Rails no longer switches the page's association loading to one big join. What the search *matches* is unchanged: English titles only, `LIKE` wildcards still escaped, same slug fast path. `includes(:document)` moves out of the search scope into the two places whose views actually need it, as a `preload`. Also removes `in_default_locale`, whose only caller this was. |
| `c0d2225` | Changes `includes` to `preload` throughout `Admin::EditionFilter`. Needed because `Admin::StatisticsAnnouncementPublicationsController` and the `features` pages pass in a query that already joins translations (via the globalize gem, which stores them), so those pages kept eager loading even after `aecbe4c`. `preload` is explicit, so no join added anywhere else can change it back. |
| `6389726` | Memoises `published_count` and `force_published_count`. The results header shows three figures on published-state pages, and the percentage recalculates the other two, so it ran four counts over the whole filtered set where two are needed. |
| `cf9d969` | `_search_results.html.erb` builds the pagination markup once. Each branch of the `if` rendered it to check whether it was empty, then rendered it again to display it. |
| `e807b2f` | `Edition#historic?` keeps the government in a local variable rather than looking it up twice. |
| `1955fe1` | Adds `script/explain_edition_title_search.rb`, which reports table sizes, scan timings and query plans using the connection the app already has. There is no documented way to reach MySQL directly from the docker environment. |
| `fc8cbdb` | Adds the index on `edition_translations (locale, title, edition_id)`. See [the index section](#the-index-committed-but-not-yet-used) — it is correct but the planner does not currently choose it. |

Files changed: `app/models/concerns/edition/scopes/searchable_by_title.rb`,
`app/models/admin/edition_filter.rb`,
`app/models/concerns/edition/translatable.rb`, `app/models/edition.rb`,
`app/controllers/admin/document_collection_group_document_search_controller.rb`,
`app/views/admin/editions/_search_results.html.erb`,
`script/benchmark_edition_search.rb`,
`script/explain_edition_title_search.rb`, `db/schema.rb` plus one migration,
and tests in `test/unit/app/models/edition_test.rb`,
`test/unit/app/models/admin/edition_filter_test.rb`,
`test/functional/admin/document_collection_group_document_search_controller_test.rb`.

### The rewritten search

```ruby
scope :with_title_containing, lambda { |keywords|
  slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last.to_s.downcase

  if slug_keyword_candidate.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/) && exists?(slug: slug_keyword_candidate)
    where(slug: slug_keyword_candidate)
  else
    where(
      "editions.id IN (SELECT et_titlecheck.edition_id FROM edition_translations et_titlecheck
                       WHERE et_titlecheck.locale = :locale
                       AND et_titlecheck.title LIKE :title)",
      locale: I18n.default_locale,
      title: "%#{sanitize_sql_like(keywords)}%",
    )
  end
}
```

Two ways to write this were considered.

`id IN (subquery)`, used here, does not refer to the outer query. MySQL can run
it once, build the list of matching edition ids, and then look those editions up
by primary key.

A correlated `EXISTS (… WHERE et.edition_id = editions.id …)` — the style used
by the neighbouring `in_organisation` and `authored_by` scopes — refers back to
each edition, so MySQL may re-check it for every edition row it considers.
Those neighbouring scopes compare ids against small join tables, where that is
cheap. Searching text in a 1.69 million row table is not comparable, which is
why this scope differs from them.

## The index: committed, but not yet used

```ruby
add_index :edition_translations,
          %i[locale title edition_id],
          name: "index_edition_translations_on_locale_and_title_and_edition_id"
```

All three columns are listed on purpose. The subquery reads `locale`, `title`
and `edition_id`, and an index only avoids touching the table if it holds every
column the query needs. `edition_id` has to be named explicitly, because an
index automatically carries `id` but no other column. Without it, MySQL would
have to visit the table for each matching row just to read `edition_id`.

Declared key length is about 2,044 bytes (`title` varchar(255) in utf8mb4 =
1,020 bytes, `locale` varchar(255) = 1,020, `edition_id` int = 4), within
MySQL 8's 3,072-byte limit.

### Results

From `script/explain_edition_title_search.rb`:

| query | time |
|---|---|
| counting rows by `locale` alone, answered from the existing small `locale` index | 100 ms |
| the title search as it runs today | 6,283 ms |
| the same search with the new index forced (`EXPLAIN` shows `Using index`) | **806 ms** |

The first row is a reference point: it shows what reading every row's worth of a
*small* index costs, as opposed to reading the table.

So the index does what it was meant to — `Using index` confirms MySQL answered
without touching the table, 7.8× faster than today.

**But MySQL does not choose it.** Left alone, the plan is:

```
type  possible_keys                                   key                                   rows    filtered  Extra
ref   index_edition_translations_on_locale,           index_edition_translations_on_locale   683245  11.11     Using where
      index_edition_translations_on_locale_and_title_and_edition_id
```

`possible_keys` shows it knows about the new index. It picks the older, smaller
`locale` index instead, then fetches about 683,000 rows from the table to check
their titles — which is the 7.4 GB of reading the index was supposed to avoid.

The likely reason: both indexes start with `locale`, so MySQL can use either one
to find English rows, and it estimates the same 683,245 rows for both. It then
prefers the smaller index, without accounting for the row fetches that choice
costs. When the new index is forced, its row estimate drops to 1,433.

The index statistics also contradict each other: the same `locale` column is
reported with cardinality 73 in `index_edition_translations_on_locale` and 953
as the first column of the new index.

### Options, none of them tried yet

1. Run `ANALYZE TABLE edition_translations` to recalculate the statistics the
   planner uses when estimating rows.
2. Reorder the index to `(title, locale, edition_id)`. With `title` first,
   there is no `locale` prefix for MySQL to use, so the choice becomes "read
   the whole table" or "read the whole index" — a comparison it is more likely
   to get right. Same columns, so the same size, and because English is 96% of
   rows, narrowing by `locale` first was worth very little anyway.
3. Drop `index_edition_translations_on_locale`. Once a larger index starts with
   `locale`, the single-column one is redundant, and removing it removes the
   competing choice. This is an alternative to option 2, not an addition.
4. Force the index from application code (`optimizer_hints` or `FORCE INDEX`).
   This works but ties the Ruby code to an index name.

If the planner can be made to use the index, two scans at ~806 ms each would
put a title search at roughly **1.7 seconds, down from 16.3**.

## Outstanding

### Not done

**The test suite has not been run on this branch**, and neither has `rubocop`
or `erb_lint`. Relevant test files:

```
test/unit/app/models/edition_test.rb
test/unit/app/models/admin/edition_filter_test.rb
test/functional/admin/editions_controller_test.rb
test/functional/admin/document_collection_group_document_search_controller_test.rb
test/functional/admin/statistics_announcement_publications_controller_test.rb
test/functional/admin/corporate_information_pages_controller_test.rb
test/functional/admin/organisations_controller_test.rb
test/functional/admin/world_location_news_controller_test.rb
test/functional/admin/standard_editions_controller_test.rb
test/functional/admin/topical_event_featurings_controller_test.rb
test/unit/app/sidekiq/document_list_export_job_test.rb
```

The last six are included because they render the partial that changed, or use
the filter with a different starting query.

No Cucumber changes are proposed. `features/admin-filtering-documents.feature`
has no title scenario, and these changes keep matching behaviour the same.

### Decisions for the team

**1. Whether to ship the index (`fc8cbdb`).**
Cost: a few hundred MB on an already large table; an index entry to maintain
every time a title is created or changed; and building it in production. MySQL 8
can add an index without locking the table, so publishing keeps working, but it
is still a long operation with significant disk and replication load that
someone needs to own. Benefit, **if** the planner can be made to use it:
16.3 s → ~1.7 s. As committed, it has no effect.

**2. The trade-off in `8ff704d`.**
A slug-shaped search that matches no edition now falls through to the title
search instead of returning nothing. That is what makes `UK-gov` find its one
result again. The cost is that a pasted URL for a page that is *not* a Whitehall
edition went from 0.4 ms to 15,623 ms, and returns nothing either way —
`https://www.gov.uk/personal-tax-account` is a mainstream GOV.UK page, so no
edition has that slug.

The choice is between returning nothing instantly and finding title matches
slowly. Supporting pasted URLs is what `b78b77c543` was written for. If the
index does not land, splitting this commit and keeping only the lowercasing is
an option.

**3. The "N documents" count doubles the cost of every title search.**
Kaminari counts the full result set to render it. Using `without_count` would
halve the time and remove the count from the results header.

### Deliberately out of scope

Both of these are much faster and both change *which* editions match, so they
are product decisions rather than part of this branch.

- **Full-text search** (`FULLTEXT` with `MATCH … AGAINST`) matches whole words
  and word beginnings, not text in the middle. Two consequences on real search
  terms from the logs: `UK` would match nothing, because full-text indexes
  ignore words shorter than three characters by default; and `evisa` would no
  longer be found by searching `visa`.
- **Matching the start of a title only** (`LIKE 'term%'`) can use an ordinary
  index and would be fast, but drops matches in the middle:
  `consultation outcome` would no longer find
  `Fracking consultation outcome`.

A comment at
`app/models/concerns/edition/scopes/filterable_by_topical_event.rb:6` records an
intention to back admin filtering with an admin-only search_api index. None of
that exists today.

### Pre-existing issues found, left alone

- `Admin::EditionFilter#editions` (lines 18–31) filters out editions the user
  may not see *after* paginating, while the total count is taken *before* that
  filtering. Non-admin users therefore see short pages and an inflated total.
- The same method paginates its result twice:
  `Kaminari.paginate_array(page_of_15, total_count: n).page(page).per(per_page)`.
  `Kaminari::PaginatableArray#page` slices the array it is given, which here is
  already limited to one page, so page 2 onwards may slice past the end. There
  is no test for page 2 — `test/unit/app/models/admin/edition_filter_test.rb:429`
  covers page 1 only. **Unverified**; to check:
  ```ruby
  Admin::EditionFilter.new(Edition, User.first, per_page: 2, page: 2).editions.map(&:id)
  Edition.order(updated_at: :desc).offset(2).limit(2).pluck(:id)
  ```
- `Admin::DocumentCollectionGroupDocumentSearchController#add_by_title`
  paginates without an `ORDER BY`, so which results land on which page is not
  guaranteed to be stable.
- `Edition::Scopes::Orderable#in_reverse_chronological_order` loads every
  matching id with `pluck(:id)` and then queries `where(id: ids)`.
- Four pages do not pass the include flags
  (`Admin::OrganisationsController#features`,
  `Admin::WorldLocationNewsController#features`,
  `Admin::StandardEditionsController#features`,
  `Admin::TopicalEventFeaturingsController#index`), so their views query
  `unpublishing` and `link_check_report` once per row via
  `Admin::Editions::TagsComponent`. After `c0d2225`, switching the flags on is a
  one-line change.

## Reproducing the measurements

Needs a production-sized database locally. From inside the container:

```bash
# end-to-end timings per search term
bin/rails runner script/benchmark_edition_search.rb

# optional extras: slowest query per case, and query plans
BENCH_SQL=1 bin/rails runner script/benchmark_edition_search.rb
BENCH_EXPLAIN=1 bin/rails runner script/benchmark_edition_search.rb

# table sizes, scan costs and query plans
bin/rails runner script/explain_edition_title_search.rb
SEARCH_TERM=UK bin/rails runner script/explain_edition_title_search.rb
```

`BENCH_STATE` (default `active`), `BENCH_USER_EMAIL` and `BENCH_RUNS`
(default 3) configure the benchmark. The signed-in user changes the result: a
GDS admin skips the per-row permission checks that other users run, so compare
like with like. `BENCH_STATE=published` is the only setting that exercises the
three counts in the results header.

For a before-and-after comparison, `99ad116` has the benchmark script without
any of the fixes.

To take the index back out locally while keeping the rest of the branch:

```bash
bin/rails db:rollback
```
