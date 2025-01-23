require_relative "../support/stubs"
require_relative "../support/helpers"

# Suppress noisy Sidekiq logging in the test output
Sidekiq.configure_client do |cfg|
  cfg.logger.level = ::Logger::WARN
end

Given("I am in the staging or integration environment") do
  Whitehall.stubs(:integration_or_staging?).returns(true)
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

Then("I should see a Cancel button to the document list page") do
  expect(page).to have_link("Cancel", href: content_block_manager.content_block_manager_content_block_documents_path)
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
  review_and_confirm
end

When("I click publish without confirming my details") do
  click_on "Publish"
end

When(/^I save and continue$/) do
  click_save_and_continue
end

Then(/^I choose to publish the change now$/) do
  @is_scheduled = false
  choose "Publish the edit now"
  click_save_and_continue
end

Then("I check the block type {string}") do |checkbox_name|
  check checkbox_name
end

Then("I select the lead organisation {string}") do |organisation|
  select organisation, from: "lead_organisation"
end

When("I make the changes") do
  change_details
  click_save_and_continue
end

When("I am updating a content block") do
  update_content_block
end

When("one of the content blocks was updated 2 days ago") do
  content_block_document = ContentBlockManager::ContentBlock::Document.all.last
  content_block_document.latest_edition.updated_at = 2.days.before(Time.zone.now)
  content_block_document.latest_edition.save!
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

When("I continue after reviewing the links") do
  click_save_and_continue
end

When(/^I add a change note$/) do
  add_change_note
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

When(/^I add an internal note$/) do
  add_internal_note
end
