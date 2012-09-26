module ContentApiStubs
  def stub_content_api_request
    stub_request(:get, "https://contentapi.test.alphagov.co.uk/tags/business%2Ftax.json").
      with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'User-Agent' => /GDS Api Client/}).
      to_return(status: 200, body: "{}", headers: {})
  end
end
