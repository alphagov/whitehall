def stub_publishing_api_has_embedded_content_details(dependent_content)
  url = %r{\A#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content/[0-9a-fA-F-]{36}/host-content/#{dependent_content['host_content_id']}}
  stub_request(:get, url)
    .to_return(body: dependent_content.to_json)
end
