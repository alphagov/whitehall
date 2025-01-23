require_relative "../support/dependent_content"
require_relative "../support/helpers"

Then(/^I should see the dependent content listed$/) do
  assert_text "List of locations"

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end

  expect(page).to have_link(@host_content_editor.name, href: content_block_manager.content_block_manager_user_path(@host_content_editor.uid))
end

Then(/^I (should )?see the rollup data for the dependent content$/) do |_should|
  should_show_rollup_data
end

When(/^dependent content exists for a content block$/) do
  host_editor_id = SecureRandom.uuid
  @dependent_content = 10.times.map do |i|
    {
      "title" => "Content #{i}",
      "document_type" => "document",
      "base_path" => "/host-content-path-#{i}",
      "content_id" => SecureRandom.uuid,
      "last_edited_by_editor_id" => host_editor_id,
      "last_edited_at" => 2.days.ago.to_s,
      "host_content_id" => "abc12345",
      "instances" => 1,
      "primary_publishing_organisation" => {
        "content_id" => SecureRandom.uuid,
        "title" => "Organisation #{i}",
        "base_path" => "/organisation/#{i}",
      },
    }
  end

  @rollup = build(:rollup).to_h

  stub_publishing_api_has_embedded_content_for_any_content_id(
    results: @dependent_content,
    total: @dependent_content.length,
    order: ContentBlockManager::HostContentItem::DEFAULT_ORDER,
    rollup: @rollup,
  )

  stub_publishing_api_has_embedded_content_details(@dependent_content.first)

  @host_content_editor = build(:signon_user, uid: host_editor_id)

  stub_request(:get, "#{Plek.find('signon', external: true)}/api/users")
    .with(query: { uuids: [host_editor_id] })
    .to_return(body: [@host_content_editor].to_json)
end

And("the host documents link to the draft content store") do
  @dependent_content.each do |item|
    expect(page).to have_selector("a.govuk-link[href='#{Plek.external_url_for('draft-origin') + item['base_path']}']", text: item["title"])
  end
end
