Before do
  stub_dependent_content(content_id: anything, total: 0, results: [])
end

def stub_dependent_content(results:, content_id: anything, total: 0)
  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/content/[0-9a-fA-F-]{36}/embedded})
    .to_return(body: {
      "content_id" => content_id,
      "total" => total,
      "results" => results,
    }.to_json)
end
