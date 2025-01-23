When("I click on the first host document") do
  @current_host_document = @dependent_content.first
  stub_request(
    :get,
    "#{Plek.find('publishing-api')}/v2/content/#{@current_host_document['host_content_id']}",
  ).to_return(
    status: 200,
    body: {
      details: {
        body: "<p>title</p>",
      },
      title: @current_host_document["title"],
      document_type: "news_story",
      base_path: @current_host_document["base_path"],
      publishing_app: "test",
    }.to_json,
  )

  stub_request(
    :get,
    Plek.website_root + @current_host_document["base_path"],
  ).to_return(
    status: 200,
    body: "<body><h1>#{@current_host_document['title']}</h1><p>iframe preview <a href=\"/other-page\">Link to other page</a></p>#{@content_block.render}</body>",
  )

  stub_request(
    :get,
    "#{Plek.website_root}/other-page",
  ).to_return(
    status: 200,
    body: "<body><h1>#{@current_host_document['title']}</h1><p>other page</p>#{@content_block.render}</body>",
  )

  click_on @current_host_document["title"]
end

Then("the preview page opens in a new tab") do
  page.switch_to_window(page.windows.last)
  assert_text "Preview email address"
  assert_text "Instances: 1"
  assert_text "Email address: #{@email_address}"
  within_frame "preview" do
    assert_text @current_host_document["title"]
  end
end

When("I click on a link within the frame") do
  within_frame "preview" do
    click_on "Link to other page"
  end
end

Then("I should see the content of the linked page") do
  within_frame "preview" do
    assert_text "other page"
    assert_text @email_address
  end
end
