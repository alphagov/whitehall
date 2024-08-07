Before do
  stub_dependent_content(results: [])
end

def stub_dependent_content(results:, total: 0, pages: 0, current_page: 1)
  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/content})
    .with(query: hash_including({ "page" => current_page.to_s }))
    .to_return(body: {
      "total" => total,
      "pages" => pages,
      "current_page" => current_page,
      "results" => results,
    }.to_json)
end
