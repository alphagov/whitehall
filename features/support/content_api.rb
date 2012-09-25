require Rails.root.join('test/support/content_api_stubs.rb')
require 'webmock/cucumber'

WebMock.allow_net_connect!

World(ContentApiStubs)

Before do
  stub_content_api_request
end
