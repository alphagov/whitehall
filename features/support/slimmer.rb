require Rails.root.join('test/support/skip_slimmer.rb')
require Rails.root.join('test/support/static_stub_helpers.rb')

Before do
  stub_request(:get, %r{.*static.*/templates/locales\/.+}).
    to_return(status: 400, headers: {})
end

