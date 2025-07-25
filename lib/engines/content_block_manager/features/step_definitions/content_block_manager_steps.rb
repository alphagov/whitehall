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

When("I choose to delete the in-progress draft") do
  click_button "Delete draft"
end

When("I click to save and come back later") do
  click_link "Save for later"
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

  assert_text I18n.t("content_block_edition.confirmation_page.updated.banner", block_type: content_block_edition.document.block_type.humanize)
  assert_text I18n.t("content_block_edition.confirmation_page.updated.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block_edition.document,
    ),
  )
end

And("I should be taken to the confirmation page for a new contact block") do
  content_block = ContentBlockManager::ContentBlock::Edition.last

  assert_text I18n.t("content_block_edition.confirmation_page.created.banner", block_type: "Contact")
  assert_text I18n.t("content_block_edition.confirmation_page.created.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block.document,
    ),
  )
end

And("I should be taken to the confirmation page for a new {string}") do |block_type|
  content_block = ContentBlockManager::ContentBlock::Edition.last

  assert_text I18n.t("content_block_edition.confirmation_page.created.banner", block_type: block_type.titlecase)
  assert_text I18n.t("content_block_edition.confirmation_page.created.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block.document,
    ),
  )
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
    block_type: "Pension",
    date: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal),
  ).squish
  assert_text I18n.t("content_block_edition.confirmation_page.scheduled.detail")

  expect(page).to have_link(
    "View content block",
    href: content_block_manager.content_block_manager_content_block_document_path(
      content_block_edition.document,
    ),
  )
end

Then("I should be taken back to the document page") do
  expect(page.current_url).to match(content_block_manager.content_block_manager_content_block_document_path(
                                      ContentBlockManager::ContentBlock::Edition.last.document,
                                    ))
end

Given("a pension content block has been created") do
  @content_blocks ||= []
  organisation = create(:organisation)
  @content_block = create(
    :content_block_edition,
    :pension,
    details: { description: "Some text" },
    creator: @user,
    organisation:,
    title: "My pension",
  )
  ContentBlockManager::ContentBlock::Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

Given("a contact content block has been created") do
  @content_blocks ||= []
  organisation = create(:organisation)
  @content_block = create(
    :content_block_edition,
    :contact,
    details: { description: "Some text" },
    creator: @user,
    organisation:,
    title: "My contact",
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
    should_show_summary_title_for_generic_content_block(
      document.title,
    )
  end
end

Then("I should see the details for all documents from my organisation") do
  ContentBlockManager::ContentBlock::Document.with_lead_organisation(@user.organisation.id).each do |document|
    should_show_summary_title_for_generic_content_block(
      document.title,
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

When("I click to view the document with title {string}") do |title|
  content_block = ContentBlockManager::ContentBlock::Edition.where(title:).first

  click_link href: content_block_manager.content_block_manager_content_block_document_path(content_block.document)
end

When("I click to view the edition") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_block_manager.content_block_manager_content_block_edition_path(@content_block)
end

Then("I should see the details for the contact content block") do
  expect(page).to have_selector("h1", text: @content_block.document.title)
  should_show_generic_content_block_details(@content_block.document.title, @organisation)
end

When("I click the first edit link") do
  click_link "Edit", match: :first
end

When("I click to edit the {string}") do |block_type|
  click_link "Edit #{block_type}", match: :first
end

When("I fill out the form") do
  change_details(object_type: @content_block.document.block_type)
end

When("I set all fields to blank") do
  fill_in "Title", with: ""
  fill_in "Description", with: ""
  select "", from: "content_block/edition[organisation_id]"
  click_save_and_continue
end

Then("the edition should have been updated successfully") do
  block_type = @content_block.document.block_type

  case block_type
  when "pension"
    should_show_summary_card_for_pension_content_block(
      "Changed title",
      "New description",
      "Ministry of Example",
      "new context information",
    )
  else
    should_show_summary_card_for_contact_content_block(
      "Changed title",
      "changed@example.com",
      "Ministry of Example",
      "new context information",
    )
  end

  # TODO: this can be removed once the summary list is referring to the Edition's title, not the Document title
  edition = ContentBlockManager::ContentBlock::Edition.all.last
  assert_equal "Changed title", edition.title
end

Then("I am asked to review my answers") do
  assert_text "Review contact"
end

Then("I am asked to review my answers for a {string}") do |block_type|
  assert_text "Review #{block_type}"
end

Then("I confirm my answers are correct") do
  check "is_confirmed"
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
  publish_now
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
  add_internal_note
  add_change_note
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
  expect(page).to have_selector(".govuk-summary-list__value", text: @future_date.to_fs(:long_ordinal_with_at).squish)
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
  expect(page).to have_selector("a.govuk-header__link[href='#{content_block_manager.content_block_manager_root_path}']", text: "Blocks")
end

And("I should see the object store's phase banner") do
  expect(page).to have_selector(".govuk-tag", text: "Beta")
  expect(page).to have_link("feedback-content-modelling@digital.cabinet-office.gov.uk", href: "mailto:feedback-content-modelling@digital.cabinet-office.gov.uk")
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

Then(/^I should see a notification that a draft is in progress$/) do
  expect(page).to have_content("There’s a saved draft of this content block")
end

Then(/^I should not see a notification that a draft is in progress$/) do
  expect(page).to_not have_content("There’s a saved draft of this content block")
end

Then("there should be no draft editions remaining") do
  expect(@content_block.document.reload.editions.select { |e| e.state == "draft" }.count).to eq(0)
end

When(/^I click on the link to continue editing$/) do
  click_on "Continue editing"
end

And(/^I update the content block and publish$/) do
  change_details
  click_save_and_continue
  add_internal_note
  add_change_note
  publish_now
  review_and_confirm
end

Then("I should see an error for an invalid {string}") do |attribute|
  expect(page).to have_content(
    I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: attribute.humanize),
  )
end

And(/^I click the back link$/) do
  click_on "Back"
end

Given(/^my pension content block has no rates$/) do
  @content_block.details["rates"] = {}
  @content_block.save!
end

And("I choose {string}") do |label|
  choose label
end

When("I choose {string} from the type dropdown") do |type|
  select type, from: "content_block_manager_content_block_edition_details_telephones_telephone_numbers_0_type"
end

Then("the label should be set to {string}") do |label|
  expect(find("#content_block_manager_content_block_edition_details_telephones_telephone_numbers_0_label").value).to eq(label)
end
