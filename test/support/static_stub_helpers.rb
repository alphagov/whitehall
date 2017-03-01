module StaticStubHelpers
  def stub_static_locales
    # Stub requests to static as per
    # https://github.com/alphagov/slimmer/blob/c2a6b26d5884d7ee7c641dc072e9b28387f3603e/lib/slimmer/test_helpers/govuk_components.rb
    # which can't be used here as we oddly still use alphagov.co.uk
    stub_request(:get, %r{.*static.*/templates/locales\/.+}).
      to_return(status: 400, headers: {})
  end
end
