# Enable mocha, not using a separate support file because I want to make
# sure these Before / After happen before the ones I define below.  If
# they go in their own it'll be support/**/*.rb load order defined and
# who knows what that'll be.
require 'mocha/setup'
World(Mocha::API)

Before do
  mocha_setup
end

After do
  begin
    mocha_verify
  ensure
    mocha_teardown
  end
end

# For everything we don't explicitly want a "real" search for, use FakeSearch
Before("~@not-quite-as-fake-search") do
  Whitehall.search_backend = Whitehall::DocumentFilter::FakeSearch
end

require 'whitehall/not_quite_as_fake_search'
# Otherwise, because we asked for it, use NotQuiteAsFakeSearch
Before("@not-quite-as-fake-search") do
  Whitehall::NotQuiteAsFakeSearch.stop_faking_it_quite_so_much!
end

After("@not-quite-as-fake-search") do
  Whitehall::NotQuiteAsFakeSearch.start_faking_it_again!
end
