# Admin edition title search performance

Branch: `perf/speed-up-admin-edition-title-search` · Base: `bcf513bead` (`main`)

Searching by title on `/government/admin/editions` took 8–30 seconds. It now
takes about a second. Measured on a local copy of production: 1,465,225
editions, 1.7 million rows in `edition_translations`.

## Result

**A title search now takes 92–95% less time than it did.** The slowest case we
measured — `UK`, matching 45,047 editions — still saves 66%.

| search term | matches | before | after | |
|---|---|---|---|---|
| *(no title)* | 461,766 | 56 ms | 53 ms | |
| `UK-gov` | 1 | 15,912 ms | **866 ms** | 18× |
| `evisa` | 29 | 16,331 ms | **1,194 ms** | 14× |
| `/guidance` | 0 | 16,257 ms | **1,230 ms** | 13× |
| `consultation outcome` | 105 | 16,474 ms | **1,343 ms** | 12× |
| `nhs` | 4,343 | not measured | **1,776 ms** | |
| `UK` | 45,047 | 24,419 ms | **8,316 ms** | 2.9× |
| `forthcoming-publications` | 1 | not measured | **3 ms** | |
| a URL for a real edition | 1 | not measured | **3 ms** | |
| a URL for no edition | 0 | 0.4 ms | 833 ms | slower |

Cost used to be flat — `/guidance` matched nothing and still took 16 seconds.
It now tracks how many rows match, which is what a working search looks like.

The last row is slower on purpose: a slug-shaped search that matches nothing now
looks for title matches instead of giving up. See
[decision 1](#decisions-left-open).

## What was wrong

**Reading every row to find text in a title.** `edition_translations` had no
index on `title`, so MySQL read all 1.7 million rows — and those rows also hold
the summary, body and block content, so a single search read 7.4 GB. That cost a
flat ~8 seconds, and a page view pays it twice: once for the results, once for
the "N documents" count. That was the 16-second floor.

**Typing a title changed how the page loaded its data.** The title search joined
translations while the filter asked Rails to *include* them. Rails reads that
combination as "give me one big query", and converts every other include on the
page to a join too — documents, unpublishings, link checker reports, versions
and users, all in one statement. `last_author` made it worse: its only
restriction is an ordering, which restricts nothing in a join, so each edition
came back once per version it had.

The second cause sounds worse than it measured. Fixing it alone barely moved the
totals; the index is where the improvement came from.

## The fix

| Commit | Change |
|---|---|
| `4211359b` | Two scripts: one times a page view per search term, one reports table sizes, scan timings and query plans. |
| `a0a98e31` | Tests that `%` and `_` in a search term are treated as ordinary characters. They are wildcards in SQL, and the escaping had no test. |
| `f9b39d25` | The slug shortcut now works whatever case the slug is typed in, and falls back to searching titles when no edition has that slug. |
| `80b5f552` | The title search matches with a subquery instead of a join, so the page's associations load as separate small queries again. The filter asks for them with `preload`, which cannot be reinterpreted. What the search matches is unchanged. |
| `648021ee` | Three bits of duplication while rendering: four result counts where two would do, the pagination rendered twice, and `Edition#historic?` looking the government up twice. |
| `60fcb3fc` | Indexes `edition_translations` on `(locale, title, edition_id)` and drops the index on `locale` alone. |

### The index, and why the old one had to go

The new index holds every column the search reads, so MySQL answers from the
index without touching the table: 6,283 ms → 712 ms. `edition_id` is listed
explicitly because an index always carries the primary key but no other column.

Adding it was not enough. Both indexes start with `locale`, MySQL expected the
same number of rows from either, so it kept choosing the smaller one and reading
the rows anyway. An index on `locale` alone is redundant once a larger index
starts with `locale`, so dropping it leaves one candidate — the one that answers
from the index. The two changes have to ship together, so the migration makes
them in one `ALTER TABLE` — a single pass over the table rather than two.

The only thing given up: a query reading `locale` and nothing else now reads a
wider key (100 ms → 357 ms). Nothing in the app does that.

### The rewritten search

```ruby
scope :with_title_containing, lambda { |keywords|
  slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last.to_s.downcase

  if slug_keyword_candidate.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/) && exists?(slug: slug_keyword_candidate)
    where(slug: slug_keyword_candidate)
  else
    matching_titles = Edition::Translation
                        .where(locale: I18n.default_locale)
                        .where("title LIKE ?", "%#{sanitize_sql_like(keywords)}%")
                        .select(:edition_id)

    where(id: matching_titles)
  end
}
```

A subquery rather than the `EXISTS` used by the neighbouring `in_organisation`
and `authored_by` scopes. Those compare ids against small join tables; this
searches text in a 1.7 million row table, where MySQL can run the subquery once
and look the editions up by id.

## `UK` is still slow, and not because of the scan

8,316 ms against ~1,200 for terms matching a handful of rows. The title scan
costs the same ~700 ms it does for `evisa`. The rest is this:

```
table                 type    key                                  rows    Extra
edition_translations  ref     …locale_and_title_and_edition_id    683245  Using index; Using temporary;
                                                                          Using filesort
editions              eq_ref  PRIMARY                                  1  Using where
```

Having found 45,047 matching translations in the index, MySQL fetches all 45,047
editions one row at a time, because the state filter (`state != 'deleted' AND
state != 'superseded'`) can only be checked on the row. It then sorts all 45,047
to find the 15 most recently updated. Once for the results, once for the count:

| term | matches | results query | count query |
|---|---|---|---|
| `evisa` | 29 | 617 ms | 572 ms |
| `nhs` | 4,343 | 894 ms | 862 ms |
| `UK` | 45,047 | 4,304 ms | 3,984 ms |

## Decisions left open

**1. The slug fallback.** A pasted URL for a page that is not a Whitehall
edition went from 0.4 ms to 833 ms and returns nothing either way. It buys the
case where the text *is* in a title — `UK-gov` finds its one result again.
Supporting pasted URLs is what `b78b77c543` was written for. Keeping only the
case fix, and dropping the fallback, is the alternative.

**2. The result count is half of every title search** — 3,984 ms of `UK`'s
8,316. It cannot stop early. Two options, both visible to publishers:

- `without_count` removes it. Every search halves; `UK` → ~4.3 s. The header
  loses its "N documents" figure and pagination loses its page count.
- Cap it, counting at most 1,000 and showing "1,000+ documents". `UK`'s count
  becomes negligible. Paging past the cap stops working, which on a 3,000-page
  result set is arguably no loss.

This is the largest remaining win and the cheapest to build, but it changes what
publishers see.

### Out of scope

Both of these are faster still and both change *which* editions match, so they
are product decisions:

- **Full-text search** matches whole words and word beginnings, not text in the
  middle. `UK` would match nothing (full-text indexes ignore words under three
  characters by default) and `evisa` would no longer be found by searching
  `visa`.
- **Matching only the start of a title** would be fast with an ordinary index,
  but `consultation outcome` would stop finding `Fracking consultation outcome`.

`filterable_by_topical_event.rb:6` notes an intention to move admin filtering to
a search_api index. None of that exists yet.

## Tests

```bash
govuk-docker-run bundle exec rake test TEST=path/to/test/file
```

```
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

The last six render the partial that changed, or use the filter with a different
starting query. No Cucumber changes: there is no title scenario in
`admin-filtering-documents.feature` and matching behaviour is unchanged.

## Pre-existing issues found, left alone

- `Admin::EditionFilter#editions` removes editions the user may not see *after*
  paginating, while the total is counted *before*. Non-admins see short pages
  and an inflated total.
- The same method paginates twice:
  `Kaminari.paginate_array(page_of_15, total_count: n).page(page)` slices an
  array that is already one page long, so page 2 onwards may come back empty.
  No test covers page 2. **Unverified** — to check:
  ```ruby
  Admin::EditionFilter.new(Edition, User.first, per_page: 2, page: 2).editions.map(&:id)
  Edition.order(updated_at: :desc).offset(2).limit(2).pluck(:id)
  ```
- `DocumentCollectionGroupDocumentSearchController#add_by_title` paginates with
  no `ORDER BY`, so which results land on which page is not stable.
- `Orderable#in_reverse_chronological_order` loads every matching id with
  `pluck(:id)` then queries `where(id: ids)`.
- Four `features` pages do not pass the include flags, so their views query
  `unpublishing` and `link_check_report` once per row. `80b5f552` makes turning
  them on a one-line change.

## Reproducing

Needs a production-sized database locally.

```bash
bin/rails db:migrate
bin/rails runner script/benchmark_edition_search.rb
bin/rails runner script/explain_edition_title_search.rb
```

`BENCH_STATE` (default `active`), `BENCH_USER_EMAIL` and `BENCH_RUNS` configure
the benchmark; `BENCH_SQL=1` prints the slowest query per term and
`BENCH_EXPLAIN=1` the plan for each. The signed-in
user matters: a GDS admin skips the per-row permission checks everyone else
runs. `SEARCH_TERM` and `COVERING_INDEX` configure the explain script.

For before-and-after, `4211359b` has both scripts and none of the fixes.
