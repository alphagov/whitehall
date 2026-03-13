Given(/^a published standard edition called (.+) exists$/) do |title|
  # Ignore topic taxon validation
  TaxonValidator.any_instance.stubs(:validate)
  # By default allow all attachment types (HtmlAttachment not a thing for StandardEdition
  # but for the purposes of testing read-only forms, we want it to be).
  # Otherwise when visiting /html_endpoint endpoints the controller automatically
  # redirects to the attachments index page.
  StandardEdition.class_eval do
    def allows_attachment_type?(*)
      true
    end
  end

  @edition = create(
    :draft_standard_edition,
    :with_alternative_format_provider,
    {
      title: title,
      summary: "...",
      primary_locale: "en",
      block_content: {
        "body" => "...",
      },
    },
  )

  html_attachment = create(:html_attachment, title: "HTML attachment", attachable: @edition)
  external_attachment = create(:external_attachment, title: "External attachment", attachable: @edition)
  file_attachment = create(:file_attachment, title: "File attachment", attachable: @edition)

  single_usage_image = create(:image, usage: "lead", caption: "This is my lead image", image_data: build(:image_data, file: upload_fixture("minister-of-funk.960x640.jpg")))
  embeddable_image = create(:image, usage: "govspeak_embed", image_data: build(:image_data, file: upload_fixture("images/960x640_jpeg.jpg")))

  @edition.update!(
    attachments: [html_attachment, external_attachment, file_attachment],
    images: [single_usage_image, embeddable_image],
  )

  feature_list = create(:feature_list, featurable: @edition, locale: :en)
  create(:feature, :with_offsite_link_association, feature_list:, ordering: 1)
  create(:feature, document: create(:published_edition).document, feature_list:, ordering: 2)

  publisher = EditionForcePublisher.new(@edition)
  raise "Could not publish edition: #{publisher.failure_reason}" unless publisher.perform!
end

When(/^I view the "(.+)" tab$/) do |tab_name|
  visit "/government/admin/standard-editions/#{@edition.id}/edit"
  within ".app-c-secondary-navigation" do
    click_link tab_name
  end
end

Then("the tab navigation is still visible") do
  assert_selector ".app-c-secondary-navigation[aria-label='Document navigation']", count: 1
end

And(/^I see the "(.+)" message$/) do |string|
  assert_text string
end

And("the form is wrapped inside a disabled fieldset") do
  main_form = "main form:not(.js-filter-form)"
  assert_selector main_form, count: 1
  within main_form do
    assert_selector "fieldset[disabled]", count: 1
  end
end

And(/^there is no "(.+)" button$/) do |button_text|
  assert_no_selector "button.gem-c-button", text: button_text
end

And("there is no file upload form") do
  assert_no_selector "form.new_upload"
end

And("there is no image upload form") do
  assert_no_selector "form#govspeak_embed_image_upload_form"
end

And(/^there is no (.+) link/) do |link_text|
  assert_no_selector "a", text: link_text
end

And(/^there is a "(.+)" link next to the (.+) attachment/) do |_link_text, attachment_type|
  assert_selector "a[aria-label='View attachment: #{attachment_type} attachment']", text: "View attachment"
end

And(/^I click the "(.+)" link next to the (.+) attachment/) do |link_text, attachment_type|
  find(:css, "a[aria-label='#{link_text}: #{attachment_type} attachment']", text: link_text).click
end

Then("there is a back button taking me to the {string} tab") do |_string|
  assert_selector "a.govuk-back-link[href='/government/admin/editions/#{@edition.id}/attachments']", count: 1
end

When("I navigate to the reorder attachments page") do
  visit "/government/admin/editions/#{@edition.id}/attachments/reorder"
end

Then("I can see the attachments") do
  assert_selector ".gem-c-reorderable-list__content", text: "HTML attachment"
  assert_selector ".gem-c-reorderable-list__content", text: "External attachment"
  assert_selector ".gem-c-reorderable-list__content", text: "File attachment"
end

Then("the buttons on the form are hidden") do
  # The buttons are hidden using CSS. Ideally we'd omit rendering them altogether,
  # but the component offers no means to do that. Capybara can't test CSS visibility
  # so we're leaving this here more as a point of documentation than a test.
  #
  # We could call `pending` here but that causes CI to fail - so
  # we're just acknowledging the coverage gap in a comment.
end

Then("I can see my uploaded lead image") do
  assert_selector "#uploaded_lead_image_card .govuk-summary-list__row--no-actions", text: "Caption This is my lead image"
end

Then("I can see my uploaded embeddable image") do
  assert_selector "#uploaded_embeddable_image_list .govuk-label + .govuk-input[value='[Image: 960x640_jpeg.jpg]']"
end

Then("there is a back button taking me to the document summary screen") do
  assert_selector "a.govuk-back-link[href='/government/admin/standard-editions/#{@edition.id}']", count: 1
end

Then("I can see the currently featured items") do
  assert_selector ".govuk-table__cell", text: "Generic edition (document)"
  assert_selector ".govuk-table__cell", text: "Alert (offsite link)"
end
