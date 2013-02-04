# Enable mocha, not using a separate support file because I want to make
# sure these Before / After happen before the ones I define below.  If
# they go in their own it'll be support/**/*.rb load order defined and
# who knows what that'll be.
require 'mocha'
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
  Whitehall.stubs(:search_backend).returns Whitehall::DocumentFilter::FakeSearch
end

require 'whitehall/not_quite_as_fake_search'
# Otherwise, because we asked for it, use NotQuiteAsFakeSearch
Before("@not-quite-as-fake-search") do
  Rummageable.stubs(:implementation).returns Whitehall::NotQuiteAsFakeSearch::Rummageable.new
  Whitehall.stubs(:search_backend).returns Whitehall::NotQuiteAsFakeSearch::DocumentFilter
  Whitehall::NotQuiteAsFakeSearch::Store.instance.initialize_indexes
end
