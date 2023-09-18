## When we removed default_access_and_opening_times from worlwide orgs, some
## offices which didn't have a custom access_and_opening_time weren't backfilled
## with the default.
## Fortunately, no office where access and opening times are nil have subsequently been
## updated so we can restore it, by retrieving the Office from Publishing API
## The PR was merged at 8am on 23/8/2023 so that's the date i've chosen to use here.
## It will also mean if for some reason this is run in the future all, offices that
## have been updated since then won't be affected.

offices = WorldwideOffice.where(updated_at: ..Time.zone.local(2023, 8, 23, 8, 0, 0), access_and_opening_times: nil)

offices.find_each(batch_size: 10) do |office|
  content_item = Services.publishing_api.get_content(office.content_id).to_h
  access_and_opening_times = content_item.dig("details", "access_and_opening_times")
  office.update_column("access_and_opening_times", access_and_opening_times) if access_and_opening_times != office.access_and_opening_times
end
