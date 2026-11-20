# Admin edition title search performance

Branch: `perf/speed-up-admin-edition-title-search` · Base: `70c5784423` (`main`)

Searching by title on `/government/admin/editions` took 8–30 seconds. It now
takes about a second. Measured on a local copy of production: 1,465,225 editions
and 1.7 million rows in `edition_translations`.

## Result

**A title search now takes 92–95% less time than it did.** The worst case we
measured — searching `UK`, which matches 45,047 editions — still saves 66%.

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

Before, a search cost about the same no matter what you typed: `/guidance`
matched nothing at all and still took 16 seconds. Now the time depends on how
much the search finds, which is how a search is meant to behave.

One case got slower deliberately. Pasting a URL for a page that is not a
Whitehall edition used to come back empty almost instantly; it now goes on to
search titles before coming back empty. See [decision 1](#decisions-left-open).

Slug matching is more accurate as well. A document whose slug carries a
duplicate-slug counter, such as `ripa-forms--2`, could not be found by its own
slug or its own URL at all; both now return it.

## What was wrong

Two separate problems.

**Every search read the whole table.** Finding text in the middle of a title
means checking every title, because an index can only jump to values by their
beginning. `edition_translations` had no index covering titles, so MySQL read all
1.7 million rows. Those rows also hold each edition's summary, body and block
content, so a single search moved 7.4 GB of data to look at one column. That cost
about 8 seconds whatever you searched for, and a page view paid it twice: once
for the results, and once for the "N documents" count above them. Hence the
16 seconds.

**Typing a title changed how the rest of the page loaded.** The page asks Rails
to load each row's associated records up front using `includes`. `includes` does
not promise how it will do that. Normally it runs one extra query per
association, but it switches to a single large `LEFT OUTER JOIN` across all of
them as soon as it notices the query mentioning one of those tables by name. The
title search mentioned one, because it matched titles by joining
`edition_translations`. So the whole page became one statement, which also pulled
in documents, unpublishings, link checker reports, versions and users.

`last_author` made that worse. It picks out the most recent version by sorting,
and sorting narrows nothing down once it has been folded into a join, so every
edition came back once per version it had. All of those duplicates then had to be
sorted and discarded to show fifteen rows.

The second problem mattered much less than it sounds. Fixing it alone barely
moved the totals; the index is where the time was going.

## The fix

| Commit | Change |
|---|---|
| `765ebc39` | Two scripts: one times a page view for each search term, the other reports table sizes, scan times and the query plans MySQL chooses. |
| `e5b94353` | Tests that a `%` or `_` typed into a search is treated as an ordinary character. Both are wildcards in SQL, and nothing tested that they were escaped. |
| `0ae07da2` | The URL shortcut now works whatever case the slug is typed in, and falls back to searching titles when no edition has that slug. |
| `7adb1d3c` | The title search finds its matches with a subquery instead of a join, so the query no longer mentions `edition_translations` and Rails stops combining the page into one statement. The page also asks for its associated records with `preload`, which only ever runs separate queries. What the search matches is unchanged. |
| `298d0751` | Three pieces of work the page was doing twice over: counting the results, rendering the pagination, and looking up each edition's government. |
| `e2779f5f` | Adds an index on `edition_translations` covering `(locale, title, edition_id)`, and drops the old index on `locale` alone. |
| `3fd62beb` | Matches slugs that carry a duplicate-slug counter, such as `ripa-forms--2`. The pattern allowed only one hyphen at a time, so these were sent to the title search and found nothing. |

### The index, and why the old one had to go

The new index lists every column the search needs: the locale it filters on, the
title it searches, and the edition id it returns. Because nothing else is
required, MySQL can answer the search by reading the index alone and never
opening the table. That takes the query from 6,283 ms to 712 ms.

`edition_id` has to be named explicitly. MySQL adds a table's own primary key to
every index automatically, but that key here is `id`, and `id` is not what the
search needs back.

Adding the index was not enough on its own. The old index on `locale` also
started with `locale`, MySQL estimated the same number of rows from either, and
it preferred the smaller one — which meant going back to the table after all. An
index on `locale` by itself is redundant once a wider index starts with `locale`,
so dropping it leaves a single choice, and that one answers the search without
help. The migration makes both changes in one `ALTER TABLE`, so they cannot be
applied separately and the table is rewritten once rather than twice.

The cost is that a query reading `locale` and nothing else now reads a wider
index entry (100 ms → 357 ms). Nothing in the application does that.

### The rewritten search

```ruby
SLUG_PATTERN = /\A[a-z0-9]+(-[a-z0-9]+)+(--\d+)?\z/

scope :with_title_containing, lambda { |keywords, locale: I18n.default_locale|
  slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last.to_s.downcase

  if slug_keyword_candidate.match?(SLUG_PATTERN) && exists?(slug: slug_keyword_candidate)
    where(slug: slug_keyword_candidate)
  else
    matching_titles = Edition::Translation
                        .where(locale:)
                        .where("title LIKE ?", "%#{sanitize_sql_like(keywords)}%")
                        .select(:edition_id)

    where(id: matching_titles)
  end
}
```

The neighbouring `in_organisation` and `authored_by` scopes use `EXISTS` for
this sort of thing, but they are comparing ids against small join tables. This
one searches text across 1.7 million rows, where it works out better for MySQL
to run the inner query once, collect the ids it finds, and look those editions up
directly.

### Searching in a language other than English

The scope takes the locale to search in, defaulting to English. That used to
happen by accident. The old code always filtered on English, and globalize's
`with_translations` quietly replaced that condition, because it applies its own
locale using `Relation#merge`, and `merge` overwrites a conflicting condition on
the same column rather than adding to it. The world location news features page
depended on that override to find Spanish titles, and
`features/world-location-news.feature` covers it.

A subquery cannot be reached by `merge`, so the locale is now passed in. The
filter hands the scope whichever locale it is displaying, and everything else
gets English. That is also easier to follow than a condition being overridden
from two files away.

## Why `UK` is still slow

Searching `UK` takes 8,316 ms, against roughly 1,200 ms for a term that matches a
handful of editions. Reading the index is not the problem — that costs the same
~700 ms it costs for `evisa`. The time goes on what happens afterwards.

`UK` appears in 45,047 titles. MySQL finds all of them in the index, then has to
fetch all 45,047 editions one row at a time, because whether an edition has been
deleted or superseded can only be checked on the row itself. It then sorts all
45,047 of them to find the 15 most recently updated. The page does that twice,
once for the results and once for the count:

| term | matches | results query | count query |
|---|---|---|---|
| `evisa` | 29 | 617 ms | 572 ms |
| `nhs` | 4,343 | 894 ms | 862 ms |
| `UK` | 45,047 | 4,304 ms | 3,984 ms |

`script/explain_edition_title_search.rb` prints the full query plan behind this.

## Decisions left open

**1. Whether to keep the URL fallback.**

When someone pastes a URL into the title filter, the search takes the last part
of the path and looks for an edition with that slug. If no edition has it, the
search now carries on and looks for the text in titles rather than stopping
there.

That helps when the text really is in a title. Searching `UK-gov` finds its one
result again, which it could not before. It costs something when the text is not
in any title: pasting a URL for a page that is not a Whitehall edition used to
come back empty in 0.4 ms, and now takes 833 ms to come back equally empty.

Handling pasted URLs is what `b78b77c543` set out to do, which is the argument
for keeping the fallback. The alternative is to keep only the fix for capital
letters and drop the fallback, so that an unrecognised URL fails quickly again.

**2. What to do about the result count.**

The page shows an "N documents" figure above the results, and working that number
out costs almost as much as fetching the results themselves: 3,984 ms of the
8,316 ms that searching `UK` takes. It cannot be made cheaper, because counting
has to look at every match, where fetching a page can stop after 15 rows.

There are two ways out, and both change what publishers see:

- **Drop the count.** Every title search roughly halves, taking `UK` to about
  4.3 seconds. The header loses its "N documents" figure, and the pagination
  loses its total page count.
- **Cap it.** Count up to 1,000 and show "1,000+ documents" instead. The count
  then costs almost nothing. Publishers could no longer page past the cap, which
  on a result set 3,000 pages long is arguably no loss.

This is the largest remaining saving and the easiest to build, but it is a
decision about what publishers see rather than a technical one.

### Out of scope

Two approaches that would be faster still, both ruled out because they change
*which* editions a search finds, which makes them product decisions:

- **Full-text search** matches whole words and the beginnings of words, not text
  in the middle. `UK` would find nothing, because full-text indexes ignore words
  shorter than three characters by default, and searching `visa` would no longer
  find `evisa`.
- **Matching only the start of a title** would be fast with an ordinary index,
  but searching `consultation outcome` would stop finding
  `Fracking consultation outcome`.

`filterable_by_topical_event.rb:6` records an intention to move admin filtering
to a search_api index instead. None of that exists yet.

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

The last six either render the results table that changed, or use the filter
starting from a different query.

Run the Cucumber suite too, and `features/world-location-news.feature` in
particular. `admin-filtering-documents.feature` has no title scenario, but
world location news has one that searches for a Spanish title, and it is the
only test covering the search in a language other than English.

## Pre-existing issues found, left alone

- `Admin::EditionFilter#editions` removes the editions a user is not allowed to
  see *after* paginating, but counts the total *before*. Anyone who is not an
  admin therefore sees short pages and a total that is too high.
- The same method paginates twice, slicing an array that is already only one page
  long, so page 2 onwards may come back empty. No test covers page 2.
  **Unverified** — to check:
  ```ruby
  Admin::EditionFilter.new(Edition, User.first, per_page: 2, page: 2).editions.map(&:id)
  Edition.order(updated_at: :desc).offset(2).limit(2).pluck(:id)
  ```
- `DocumentCollectionGroupDocumentSearchController#add_by_title` paginates
  without sorting first, so which results land on which page is not stable.
- `Orderable#in_reverse_chronological_order` loads the id of every matching
  edition with `pluck(:id)`, then queries for them all again with
  `where(id: ids)`.
- Four `features` pages do not pass the flags that load associated records up
  front, so their views query `unpublishing` and `link_check_report` once per
  row. `7adb1d3c` makes turning them on a one-line change.

## Reproducing

Needs a production-sized database locally.

```bash
bin/rails db:migrate
bin/rails runner script/benchmark_edition_search.rb
bin/rails runner script/explain_edition_title_search.rb
```

The benchmark takes `BENCH_STATE` (default `active`), `BENCH_USER_EMAIL` and
`BENCH_RUNS`; `BENCH_SQL=1` also prints the slowest query for each term, and
`BENCH_EXPLAIN=1` its query plan. Which user is signed in matters, because a GDS
admin skips the per-row permission checks everyone else runs. The explain script
takes `SEARCH_TERM` and `COVERING_INDEX`.

For a before-and-after comparison, `765ebc39` has both scripts and none of the
fixes.
