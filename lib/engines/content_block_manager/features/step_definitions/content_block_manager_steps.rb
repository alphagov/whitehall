require_relative "../support/stubs"
require_relative "../support/dependent_content"

# Suppress noisy Sidekiq logging in the test output
Sidekiq.configure_client do |cfg|
  cfg.logger.level = ::Logger::WARN
end

Given("I am in the staging or integration environment") do
  Whitehall.stubs(:integration_or_staging?).returns(true)
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
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

When("I access the create object page") do
  visit content_block_manager.new_content_block_manager_content_block_edition_path
end

When("I click to create an object") do
  click_link "Create content block"
end

When("I click cancel") do
  click_button "Cancel"
end

When("I click the cancel link") do
  click_link "Cancel"
end

Then(/^I click on page ([^"]*)$/) do |page_number|
  click_link page_number
end

When("I click to view results") do
  click_button "View results"
end

Then("I should see all the schemas listed") do
  @schemas.values.each do |schema|
    expect(page).to have_content(schema.name)
  end
end

When("I click on the {string} schema") do |schema_id|
  @schema = @schemas[schema_id]
  ContentBlockManager::ContentBlock::Schema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  choose @schema.name
  click_save_and_continue
end

Then("I should see a form for the schema") do
  expect(page).to have_content(@schema.name)
end

Then("I should see a back link to the document list page") do
  expect(page).to have_link("Back", href: content_block_manager.content_block_manager_content_block_documents_path)
end

Then("I should see a Cancel button to the document list page") do
  expect(page).to have_link("Cancel", href: content_block_manager.content_block_manager_content_block_documents_path)
end

Then("I should see a back link to the select schema page") do
  expect(page).to have_link("Back", href: content_block_manager.new_content_block_manager_content_block_document_path)
end

Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: content_block_manager.content_block_manager_content_block_document_path(@content_block.document),
  )
end

Then("I should see a back link to the show page") do
  match_data = URI.parse(page.current_url).path.match(%r{content-block-editions/(\d+)/edit$})
  id = match_data[1] unless match_data.nil?
  expect(id).not_to be_nil, "Could not find an existing content block edition ID in the URL"
  expect(page).to have_link("Back", href: content_block_manager.content_block_manager_content_block_edition_path(id))
end

Then("I should see a back link to the edit page") do
  expect(page).to have_link(
    "Back",
    href: content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document),
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
  @instructions_to_publishers = fields.delete("instructions_to_publishers")
  @details = fields

  fill_in "Title", with: @title if @title.present?

  select @organisation, from: "content_block_manager_content_block_edition_lead_organisation" if @organisation.present?

  fill_in "Instructions to publishers", with: @instructions_to_publishers if @instructions_to_publishers.present?

  fields.keys.each do |k|
    fill_in "content_block_manager_content_block_edition_details_#{k}", with: @details[k]
  end

  click_save_and_continue
end

When("I complete the form") do
  @title = "My title"
  @details = @schema.fields.index_with { |f| "#{f} content" }

  fill_in "Title", with: @title
  @details.keys.each do |k|
    fill_in "content_block_manager/content_block_edition_details_#{k}", with: @details[k]
  end
  click_save_and_continue
end

Then("the edition should have been created successfully") do
  edition = ContentBlockManager::ContentBlock::Edition.all.last

  assert_not_nil edition
  assert_not_nil edition.document

  assert_equal @title, edition.title if @title.present?
  assert_equal @instructions_to_publishers, edition.instructions_to_publishers if @instructions_to_publishers.present?

  @details.keys.each do |k|
    assert_equal edition.details[k], @details[k]
  end
end

And("I should be taken to the confirmation page for a published block") do
  content_block_edition = ContentBlockManager::ContentBlock::Edition.last

  assert_text I18n.t("content_block_edition.confirmation_page.updated.banner", block_type: "Email address")
  assert_text I18n.t("content_block_edition.confirmation_page.updated.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block_edition.document,
    ),
  )

  has_support_button
end

def has_support_button
  expect(page).to have_link(
    "Raise a support request",
    href: Whitehall.support_url,
  )
end

And("I should be taken to the confirmation page for a new block") do
  content_block = ContentBlockManager::ContentBlock::Edition.last

  assert_text I18n.t("content_block_edition.confirmation_page.created.banner", block_type: "Email address")
  assert_text I18n.t("content_block_edition.confirmation_page.created.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block.document,
    ),
  )

  has_support_button
end

When("I click to view the content block") do
  click_link href: content_block_manager.content_block_manager_content_block_document_path(
    ContentBlockManager::ContentBlock::Edition.last.document,
  )
end

When("I should be taken to the scheduled confirmation page") do
  content_block_edition = ContentBlockManager::ContentBlock::Edition.last

  assert_text I18n.t(
    "content_block_edition.confirmation_page.scheduled.banner",
    block_type: "Email address",
    date: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal),
  ).squish
  assert_text I18n.t("content_block_edition.confirmation_page.scheduled.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block_edition.document,
    ),
  )

  has_support_button
end

Then("I should be taken back to the document page") do
  expect(page.current_url).to match(content_block_manager.content_block_manager_content_block_document_path(
                                      ContentBlockManager::ContentBlock::Edition.last.document,
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
    title: "previously created title",
  )
  ContentBlockManager::ContentBlock::Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

Given(/^([^"]*) content blocks of type ([^"]*) have been created with the fields:$/) do |count, block_type, table|
  fields = table.rows_hash
  organisation_name = fields.delete("organisation")
  organisation = Organisation.where(name: organisation_name).first
  title = fields.delete("title") || "title"
  instructions_to_publishers = fields.delete("instructions_to_publishers")

  (1..count.to_i).each do |_i|
    document = create(:content_block_document, block_type.to_sym, sluggable_string: title.parameterize(separator: "_"))

    editions = create_list(
      :content_block_edition,
      3,
      block_type.to_sym,
      document:,
      organisation:,
      details: fields,
      creator: @user,
      instructions_to_publishers:,
      title:,
    )

    document.latest_edition = editions.last
    document.save!
  end
end

Given("an email address content block has been created with the following email address and title:") do |table|
  fields = table.rows_hash
  @content_blocks ||= []
  @email_address = "foo@example.com"
  organisation = create(:organisation)
  title = fields.delete("title") || "title"
  document = create(:content_block_document, :email_address, sluggable_string: title.parameterize(separator: "_"))
  @content_block = create(
    :content_block_edition,
    :email_address,
    document:,
    details: { email_address: fields[:email_address] },
    creator: @user,
    organisation:,
    title:,
  )
  ContentBlockManager::ContentBlock::Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

When("I visit the page for the content block") do
  visit content_block_manager.content_block_manager_content_block_edition_path(@content_block)
end

When("I visit the Content Block Manager home page") do
  visit content_block_manager.content_block_manager_root_path
end

When("I visit a block's content ID endpoint") do
  block = ContentBlockManager::ContentBlock::Document.last
  visit content_block_manager.content_block_manager_content_block_content_id_path(block.content_id)
end

Then("I am taken back to Content Block Manager home page") do
  assert_equal current_path, content_block_manager.content_block_manager_root_path
end

Then("I am taken back to the view page of the content block") do
  assert_equal current_path, content_block_manager.content_block_manager_content_block_document_path(@content_block.document)
end

And("no draft Content Block Edition has been created") do
  assert_equal 0, ContentBlockManager::ContentBlock::Edition.where(state: "draft").count
end

And("no draft Content Block Document has been created") do
  assert_equal 0, ContentBlockManager::ContentBlock::Document.count
end

Then("I should see the details for all documents") do
  assert_text "Content Block Manager"

  ContentBlockManager::ContentBlock::Document.find_each do |document|
    should_show_summary_card_for_email_address_content_block(
      document.title,
      document.latest_edition.details[:email_address],
    )
  end
end

Then("'all organisations' is already selected as a filter") do
  expect(page).to have_field("Lead organisation", with: "")
end

Then("I should see the details for all documents from my organisation") do
  ContentBlockManager::ContentBlock::Document.with_lead_organisation(@user.organisation.id).each do |document|
    should_show_summary_card_for_email_address_content_block(
      document.title,
      document.latest_edition.details[:email_address],
    )
  end
end

Then("I should see the content block with title {string} returned") do |title|
  expect(page).to have_selector(".govuk-summary-card__title", text: title)
end

Then("{string} content blocks are returned in total") do |count|
  assert_text "#{count} #{'result'.pluralize(count.to_i)}"
end

When("I click to view the document") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_block_manager.content_block_manager_content_block_document_path(@content_block.document)
end

When("I click to view the edition") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_block_manager.content_block_manager_content_block_edition_path(@content_block)
end

Then("I should see the details for the email address content block") do
  assert_text "View email address"

  should_show_summary_list_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
    @organisation,
  )
end

When("I click the first edit link") do
  click_link "Edit"
end

Then("I should see the edit form") do
  should_show_edit_form_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
  )
end

When("I fill out the form") do
  change_details
end

When("I set all fields to blank") do
  fill_in "Title", with: ""
  fill_in "Email address", with: ""
  select "", from: "content_block/edition[organisation_id]"
  click_save_and_continue
end

Then("the edition should have been updated successfully") do
  should_show_summary_list_for_email_address_content_block(
    "Changed title",
    "changed@example.com",
    "Ministry of Example",
    "new context information",
  )

  # TODO: this can be removed once the summary list is referring to the Edition's title, not the Document title
  edition = ContentBlockManager::ContentBlock::Edition.all.last
  assert_equal "Changed title", edition.title
end

def should_show_summary_card_for_email_address_content_block(document_title, email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
end

def should_show_summary_list_for_email_address_content_block(document_title, email_address, organisation, instructions_to_publishers = nil)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Edit")
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Lead organisation")
  expect(page).to have_selector(".govuk-summary-list__value", text: organisation)
  if instructions_to_publishers
    expect(page).to have_selector(".govuk-summary-list__key", text: "Instructions to publishers")
    expect(page).to have_selector(".govuk-summary-list__value", text: instructions_to_publishers)
  end
  expect(page).to have_selector(".govuk-summary-list__key", text: "Status")
  expect(page).to have_selector(".govuk-summary-list__value", text: @user.name)
end

def should_show_edit_form_for_email_address_content_block(document_title, email_address)
  expect(page).to have_content(I18n.t("content_block_edition.update.title", block_type: "email address"))
  expect(page).to have_field("Title", with: document_title)
  expect(page).to have_field("Email address", with: email_address)
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end

Then("I should see errors for the required fields") do
  assert_text "Title cannot be blank", minimum: 2

  required_fields = @schema.body["required"]
  required_fields.each do |required_field|
    assert_text "#{ContentBlockManager::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank", minimum: 2
  end
  assert_text "Lead organisation cannot be blank", minimum: 2
end

Then("I see the errors prompting me to provide a date and time") do
  assert_text "Scheduled publication date and time cannot be blank", minimum: 2
end

Then("I see the errors informing me the date is invalid") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.time.blank"), minimum: 2
end

Then("I should see an error message telling me that schedule publishing cannot be blank") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.schedule_publishing.blank"), minimum: 2
end

Then("I see the errors informing me the date must be in the future") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.future_date"), minimum: 2
end

Then("I should see a message that the field is an invalid {string}") do |format|
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: format)
end

Then("I should see a message that I need to confirm the details are correct") do
  assert_text I18n.t("content_block_edition.review_page.errors.confirm"), minimum: 2
end

Then("I should see a message that the filter dates are invalid") do
  expect(page).to have_selector("a[href='#last_updated_from_3i']"), text: "Last updated from is not a valid date"
  expect(page).to have_selector("a[href='#last_updated_to_3i']"), text: "Last updated to is not a valid date"
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

Then("I am asked to review my answers") do
  assert_text "Review email address"
end

Then("I confirm my answers are correct") do
  check "By creating this content block you are confirming that, to the best of your knowledge, the details you are providing are correct."
end

Then("I accept and publish") do
  click_on "Accept and publish"
end

When("I review and confirm my answers are correct") do
  assert_text "Review email address"
  check "By creating this content block you are confirming that, to the best of your knowledge, the details you are providing are correct."
  click_on @is_scheduled ? "Schedule" : "Publish"
end

When("I click publish without confirming my details") do
  click_on "Publish"
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

Then(/^I should see the dependent content listed$/) do
  assert_text "List of locations"

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end

  expect(page).to have_link(@host_content_editor.name, href: content_block_manager.content_block_manager_user_path(@host_content_editor.uid))
end

Then(/^I (should )?see the rollup data for the dependent content$/) do |_should|
  @rollup.keys.each do |k|
    within ".rollup-details__rollup-metric.#{k}" do
      assert_text k.to_s.titleize
      within ".gem-c-glance-metric__figure" do
        assert_text @rollup[k]
      end
    end
  end
end

Then(/^I should see an error prompting me to choose an object type$/) do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank")
end

Then(/^I am shown where the changes will take place$/) do
  expect(page).to have_selector("h1", text: "Preview email address")

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end
end

And("the host documents link to the draft content store") do
  @dependent_content.each do |item|
    expect(page).to have_selector("a.govuk-link[href='#{Plek.external_url_for('draft-origin') + item['base_path']}']", text: item["title"])
  end
end

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

When(/^I save and continue$/) do
  click_save_and_continue
end

Then(/^I am asked when I want to publish the change$/) do
  assert_text "Select publish date"
end

Then(/^I choose to publish the change now$/) do
  @is_scheduled = false
  choose "Publish the edit now"
end

Then("I check the block type {string}") do |checkbox_name|
  check checkbox_name
end

Then("I select the lead organisation {string}") do |organisation|
  select organisation, from: "lead_organisation"
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
  visit content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
  #  fill in the new data
  change_details
  # accept changes
  click_save_and_continue
end

When("I choose to schedule the change") do
  choose "Schedule the edit for the future"
end

And(/^I schedule the change for (\d+) days in the future$/) do |number_of_days|
  choose "Schedule the edit for the future"
  @future_date = number_of_days.days.since(Time.zone.now)
  @is_scheduled = true
  fill_in_date_and_time_field(@future_date)

  click_on "Save and continue"
end

When("one of the content blocks was updated 2 days ago") do
  content_block_document = ContentBlockManager::ContentBlock::Document.all.last
  content_block_document.latest_edition.updated_at = 2.days.before(Time.zone.now)
  content_block_document.latest_edition.save!
end

When("I add a filter for blocks updated two days ago") do
  date = 2.days.before(Time.zone.now)

  fill_in "last_updated_from_1i", with: date.year
  fill_in "last_updated_from_2i", with: date.month
  fill_in "last_updated_from_3i", with: date.day

  fill_in "last_updated_to_1i", with: date.year
  fill_in "last_updated_to_2i", with: date.month
  fill_in "last_updated_to_3i", with: date.day
end

When("I input invalid dates to filter by") do
  fill_in "last_updated_from_1i", with: "1"
  fill_in "last_updated_from_2i", with: "34"
  fill_in "last_updated_from_3i", with: "56"

  fill_in "last_updated_to_1i", with: "1"
  fill_in "last_updated_to_2i", with: "67"
  fill_in "last_updated_to_3i", with: "56"
end

When("I enter an invalid date") do
  fill_in "Year", with: "01"
end

When("I enter a date in the past") do
  past_date = 7.days.before(Time.zone.now).to_date
  fill_in_date_and_time_field(past_date)
end

When("I enter the keyword {string}") do |keyword|
  fill_in "Keyword", with: keyword
end

Then("the edition should have been scheduled successfully") do
  @schema = @schemas[@content_block.document.block_type]
  assert_text "#{@schema.name} scheduled successfully"
end

And("the block is scheduled and published") do
  @is_scheduled = true
  create(:scheduled_publishing_robot)
  near_future_date = 1.minute.from_now
  fill_in_date_and_time_field(near_future_date)

  Sidekiq::Testing.inline! do
    click_on "Save and continue"
  end
end

Then("the published state of the object should be shown") do
  visit content_block_manager.content_block_manager_content_block_document_path(@content_block.document)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Status")
  expect(page).to have_selector(".govuk-summary-list__value", text: "Published")
end

Then("I should see the scheduled date on the object") do
  expect(page).to have_selector(".govuk-summary-list__key", text: "Status")
  expect(page).to have_selector(".govuk-summary-list__value", text: I18n.l(@future_date, format: :long_ordinal).squish)
end

Then("I should see a warning telling me there is a scheduled change") do
  assert_text "There is currently a change scheduled"
end

def visit_edit_page
  visit content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
end

def change_details
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  select "Ministry of Example", from: "content_block_manager_content_block_edition_lead_organisation"
  fill_in "Instructions to publishers", with: "new context information"
  click_save_and_continue
end

def click_save_and_continue
  click_on "Save and continue"
end

Then(/^I should see the object store's title in the header$/) do
  expect(page).to have_selector(".govuk-header__product-name", text: "Content Block Manager")
end

Then(/^I should see the object store's home page title$/) do
  expect(page).to have_title "Home - GOV.UK Content Block Manager"
end

And(/^I should see the object store's navigation$/) do
  expect(page).to have_selector("a.govuk-header__link[href='#{content_block_manager.content_block_manager_root_path}']", text: "Dashboard")
end

And("I should see the object store's phase banner") do
  expect(page).to have_selector(".govuk-tag", text: "Alpha")
  expect(page).to have_link("feedback", href: "mailto:govuk-publishing-content-modelling-team@digital.cabinet-office.gov.uk")
end

Then(/^I should still see the live edition on the homepage$/) do
  within(".govuk-summary-card", text: @content_block.document.title) do
    @content_block.details.keys.each do |key|
      expect(page).to have_content(@content_block.details[key])
    end
  end
end

Then(/^I should not see the draft document$/) do
  expect(page).not_to have_content(@title)
end

Then("I should see the content block manager home page") do
  expect(page).to have_content("Content Block Manager")
end

When("I click to copy the embed code") do
  find("a", text: "Copy code").click
  has_text?("Code copied")
  @embed_code = @content_block.document.embed_code
end

When("I click to copy the embed code for the content block {string}") do |content_block_name|
  within(".govuk-summary-card", text: content_block_name) do
    find("a", text: "Copy code").click
    has_text?("Code copied")
    edition = ContentBlockManager::ContentBlock::Edition.find_by(title: content_block_name)
    @embed_code = edition.document.embed_code
  end
end

Then("the embed code should be copied to my clipboard") do
  page.driver.browser.execute_cdp("Browser.grantPermissions", origin: page.server_url, permissions: %w[clipboardReadWrite])
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(@embed_code)
end

When("I click to edit the schedule") do
  find("a", text: "Edit schedule").click
end

Then(/^there should only be one job scheduled$/) do
  jobs = Sidekiq::ScheduledSet.new.select { |job| job.item["class"] == ContentBlockManager::SchedulePublishingWorker.to_s }
  expect(jobs.count).to eq(1)
end

Then(/^there should be no jobs scheduled$/) do
  jobs = Sidekiq::ScheduledSet.new.select { |job| job.item["class"] == ContentBlockManager::SchedulePublishingWorker.to_s }
  expect(jobs.count).to eq(0)
end

Given("A user exists with uuid {string}") do |uuid|
  @user_from_signon = build(
    :signon_user,
    uid: uuid,
    name: "John Doe",
    email: "john@doe.com",
    organisation: build(:signon_user_organisation, content_id: "456", name: "User's Org", slug: "users-org"),
  )

  stub_request(:get, "#{Plek.find('signon', external: true)}/api/users")
    .with(query: { uuids: [uuid] })
    .to_return(body: [@user_from_signon].to_json)
end

When("I visit the user page for uuid {string}") do |uuid|
  visit content_block_manager.content_block_manager_user_path(uuid)
end

Then("I should see the details for that user") do
  expect(page).to have_selector("h1", text: @user_from_signon.name)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.name)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.email)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.organisation.name)
end
