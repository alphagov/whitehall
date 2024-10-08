require_relative "../support/stubs"

# Suppress noisy Sidekiq logging in the test output
Sidekiq.configure_client do |cfg|
  cfg.logger.level = ::Logger::WARN
end

Given(/^the content object store feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:content_object_store, enabled == "enabled")
end

Given("a schema {string} exists with the following fields:") do |block_type, table|
  fields = table.hashes
  @schemas ||= {}
  body = {
    "type" => "object",
    "required" => fields.select { |f| f["required"] == "true" }.map { |f| f["field"] },
    "additionalProperties" => false,
    "properties" => fields.map { |f|
      [f["field"], { "type" => f["type"], "format" => f["format"] }]
    }.to_h,
  }
  @schemas[block_type] = build(:content_block_schema, block_type:, body:)
  ContentObjectStore::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

When("I access the create object page") do
  visit content_object_store.new_content_object_store_content_block_edition_path
end

When("I click to create an object") do
  click_link "Create new object"
end

Then("I should see all the schemas listed") do
  @schemas.values.each do |schema|
    expect(page).to have_content(schema.name)
  end
end

When("I click on the {string} schema") do |schema_id|
  @schema = @schemas[schema_id]
  ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  choose @schema.name
  click_save_and_continue
end

Then("I should see a form for the schema") do
  expect(page).to have_content(@schema.name)
end

Then("I should see a back link to the document list page") do
  expect(page).to have_link("Back", href: content_object_store.content_object_store_content_block_documents_path)
end

Then("I should see a back link to the select schema page") do
  expect(page).to have_link("Back", href: content_object_store.new_content_object_store_content_block_document_path)
end

Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: content_object_store.content_object_store_content_block_document_path(@content_block.document),
  )
end

Then("I should see a back link to the show page") do
  match_data = URI.parse(page.current_url).path.match(%r{content-block-editions/(\d+)/edit$})
  id = match_data[1] unless match_data.nil?
  expect(id).not_to be_nil, "Could not find an existing content block edition ID in the URL"
  expect(page).to have_link("Back", href: content_object_store.content_object_store_content_block_edition_path(id))
end

Then("I should see a back link to the edit page") do
  expect(page).to have_link(
    "Back",
    href: content_object_store.new_content_object_store_content_block_edition_path(@content_block.document),
  )
end

Then(/^I should see a back link to the review page$/) do
  expect(page).to have_link(
    "Back",
    href: /^.*review_links.*$/,
  )
end

When("I complete the form with the following fields:") do |table|
  fields = table.hashes.first
  @title = fields.delete("title")
  @organisation = fields.delete("organisation")
  @details = fields

  fill_in "Title", with: @title

  select @organisation, from: "content_block/edition_lead_organisation"

  fields.keys.each do |k|
    fill_in "content_object_store/content_block/edition_details_#{k}", with: @details[k]
  end

  click_save_and_continue
end

When("I complete the form") do
  @title = "My title"
  @details = @schema.fields.index_with { |f| "#{f} content" }

  fill_in "Title", with: @title
  @details.keys.each do |k|
    fill_in "content_object_store/content_block_edition_details_#{k}", with: @details[k]
  end
  click_save_and_continue
end

Then("the edition should have been created successfully") do
  assert_text "#{@schema.name} created successfully"

  edition = ContentObjectStore::ContentBlock::Edition.all.last

  assert_not_nil edition
  assert_not_nil edition.document

  assert_equal edition.title, @title
  @details.keys.each do |k|
    assert_equal edition.details[k], @details[k]
  end
end

Then("I should be taken back to the document page") do
  expect(page.current_url).to match(content_object_store.content_object_store_content_block_document_path(
                                      ContentObjectStore::ContentBlock::Edition.last.document,
                                    ))
end

Given("an email address content block has been created") do
  @content_blocks ||= []
  @email_address = "foo@example.com"
  organisation = create(:organisation)
  @content_block = create(
    :content_block_edition,
    :email_address,
    details: { email_address: @email_address },
    creator: @user,
    organisation:,
  )
  ContentObjectStore::ContentBlock::Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

When("I visit the page for the content block") do
  visit content_object_store.content_object_store_content_block_edition_path(@content_block)
end

When("I visit the document object store") do
  visit content_object_store.content_object_store_content_block_documents_path
end

Then("I should see the details for all documents") do
  assert_text "All content blocks"

  ContentObjectStore::ContentBlock::Document.find_each do |document|
    should_show_summary_card_for_email_address_content_block(
      document.title,
      document.latest_edition.details[:email_address],
    )
  end
end

When("I click to view the document") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_object_store.content_object_store_content_block_document_path(@content_block.document)
end

When("I click to view the edition") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_object_store.content_object_store_content_block_edition_path(@content_block)
end

Then("I should see the details for the email address content block") do
  assert_text "Manage an Email address"

  should_show_summary_list_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
    @organisation,
  )
end

When("I click the first change link") do
  first_link = find("a[href='#{content_object_store.new_content_object_store_content_block_document_edition_path(@content_block.document)}']", match: :first)
  first_link.click
end

Then("I should see the edit form") do
  should_show_edit_form_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
  )
end

When("I fill out the form") do
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  select "Ministry of Example", from: "content_block/edition_lead_organisation"
  click_save_and_continue
end

When("I set all fields to blank") do
  fill_in "Title", with: ""
  fill_in "Email address", with: ""
  select "", from: "content_block/edition[organisation_id]"
  click_save_and_continue
end

Then("the edition should have been updated successfully") do
  should_show_summary_list_for_email_address_content_block("Changed title", "changed@example.com", "Ministry of Example")
end

def should_show_summary_card_for_email_address_content_block(document_title, email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
end

def should_show_summary_list_for_email_address_content_block(document_title, email_address, organisation)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Change")
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Lead organisation")
  expect(page).to have_selector(".govuk-summary-list__value", text: organisation)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Creator")
  expect(page).to have_selector(".govuk-summary-list__value", text: @user.name)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Change")
end

def should_show_edit_form_for_email_address_content_block(document_title, email_address)
  expect(page).to have_content("Change Email address")
  expect(page).to have_field("Title", with: document_title)
  expect(page).to have_field("Email address", with: email_address)
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end

Then("I should see errors for the required fields") do
  assert_text "Title can't be blank"

  required_fields = @schema.body["required"]
  required_fields.each do |required_field|
    assert_text "#{ContentObjectStore::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank"
  end
  assert_text "Lead organisation cannot be blank"
end

Then("I see the errors prompting me to provide a date and time") do
  assert_text "Scheduled publication date and time cannot be blank", minimum: 2
end

Then("I see the errors informing me the date is invalid") do
  assert_text "Scheduled publication is not in the correct format", minimum: 2
end

Then("I see the errors informing me the date must be in the future") do
  assert_text "Scheduled publication date and time must be in the future", minimum: 2
end

Then("I should see a message that the {string} field is an invalid {string}") do |field_name, format|
  assert_text "#{ContentObjectStore::ContentBlock::Edition.human_attribute_name("details_#{field_name}")} is an invalid #{format.titleize}"
end

Then("I should see a permissions error") do
  assert_text "Permissions error"
end

Then("I should see the created event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address created")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then(/^I should see ([^"]*) publish events on the timeline$/) do |count|
  expect(page).to have_selector(".timeline__title", text: "Email address published", count:)
end

Then("I should see the publish event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address published")
  expect(page).to have_selector(".timeline__byline", text: "by Scheduled Publishing Robot")
end

Then("I should see the scheduled event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address scheduled")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then("I am asked to check my answers") do
  assert_text "Check your answers"
end

Then("I accept and publish") do
  click_on "Accept and publish"
end

When(/^dependent content exists for a content block$/) do
  @dependent_content = 10.times.map do |i|
    {
      "title" => "Content #{i}",
      "document_type" => "document",
      "base_path" => "/",
      "content_id" => SecureRandom.uuid,
      "primary_publishing_organisation" => {
        "content_id" => SecureRandom.uuid,
        "title" => "Organisation #{i}",
        "base_path" => "/organisation/#{i}",
      },
    }
  end

  stub_publishing_api_has_embedded_content(content_id: anything, results: @dependent_content, total: @dependent_content.length)
end

Then(/^I should see the dependent content listed$/) do
  assert_text "Content appears in"

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end
end

Then(/^I should see an error prompting me to choose an object type$/) do
  assert_text "You must select a block type"
end

Then(/^I am shown where the changes will take place$/) do
  expect(page).to have_selector("h1", text: "Where the change will appear")

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end
end

When(/^I save and continue$/) do
  click_save_and_continue
end

Then(/^I am asked when I want to publish the change$/) do
  assert_text "When do you want to publish the change?"
end

Then(/^I choose to publish the change now$/) do
  choose "Publish the change now"
end

When("I revisit the edit page") do
  @content_block = @content_block.document.latest_edition
  visit_edit_page
end

When("I make the changes") do
  change_details
  click_save_and_continue
end

When("I am updating a content block") do
  # go to the edit page for the block
  visit content_object_store.new_content_object_store_content_block_document_edition_path(@content_block.document)
  #  fill in the new data
  change_details
  # accept changes
  click_save_and_continue
end

When("I choose to schedule the change") do
  choose "Schedule the change for the future"
end

When("I schedule the change for 7 days in the future") do
  choose "Schedule the change for the future"
  @future_date = 7.days.since(Time.zone.now)
  fill_in_date_and_time_field(@future_date)

  Sidekiq::Testing.fake! do
    click_on "Accept and publish"
  end
end

When("I enter an invalid date") do
  fill_in "Year", with: "01"
end

When("I enter a date in the past") do
  past_date = 7.days.before(Time.zone.now).to_date
  fill_in_date_and_time_field(past_date)
end

Then("the edition should have been scheduled successfully") do
  @schema = @schemas[@content_block.document.block_type]
  assert_text "#{@schema.name} scheduled successfully"
end

And("the block is scheduled and published") do
  create(:scheduled_publishing_robot)
  near_future_date = 1.minute.from_now
  fill_in_date_and_time_field(near_future_date)

  Sidekiq::Testing.inline! do
    click_on "Accept and publish"
  end
end

Then("published state of the object is shown") do
  visit content_object_store.content_object_store_content_block_document_path(@content_block.document)
  expect(page).to have_selector(".govuk-summary-list__key", text: "State")
  expect(page).to have_selector(".govuk-summary-list__value", text: "Published")
end

Then("I should see the scheduled date on the object") do
  expect(page).to have_selector(".govuk-summary-list__key", text: "Scheduled for publication at")
  expect(page).to have_selector(".govuk-summary-list__value", text: I18n.l(@future_date, format: :long_ordinal).squish)
end

Then("I should see a warning telling me there is a scheduled change") do
  assert_text "There is currently a change scheduled"
end

def visit_edit_page
  visit content_object_store.new_content_object_store_content_block_document_edition_path(@content_block.document)
end

def change_details
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  select "Ministry of Example", from: "content_block/edition_lead_organisation"
  click_save_and_continue
end

def click_save_and_continue
  click_on "Save and continue"
end

Then(/^I should see the object store's title in the header$/) do
  expect(page).to have_selector(".govuk-header__product-name", text: "Content Object Store")
end

And(/^I should see the object store's navigation$/) do
  expect(page).to have_selector("a.govuk-header__link[href='#{content_object_store.content_object_store_root_path}']", text: "Dashboard")
end

Then(/^I should still see the live edition on the homepage$/) do
  within(".govuk-summary-card", text: @content_block.document.title) do
    expect(page).to have_content("Published")
  end
end

Then(/^I should not see the draft document$/) do
  expect(page).not_to have_content(@title)
end
