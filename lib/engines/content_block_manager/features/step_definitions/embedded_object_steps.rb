require_relative "../support/form_step_helpers"
require_relative "./video_relay_service_steps"

When("I visit the page to create a new {string} for the block") do |object_type|
  visit content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
    document_id: @content_block.document.id,
    object_type: object_type.pluralize,
  )
end

Then("I should see a form to create a {string} for the content block") do |object_type|
  expect(page).to have_text("Add #{add_indefinite_article object_type}")
end

Then("I should see confirmation that my {string} has been created") do |object_type|
  expect(page).to have_text("#{object_type.capitalize} created")
end

When("I complete the {string} form with the following fields:") do |object_type, table|
  fill_in_embedded_object_form(object_type, table)

  click_save_and_continue
end

And("I fill in the {string} form with the following fields:") do |object_type, table|
  @object_type = object_type
  fill_in_embedded_object_form(object_type, table)
end

And("I add the following {string} to the form:") do |item_type, table|
  fields = table.hashes

  if item_type == "opening_hours"
    fields.map! do |item|
      time_from = item.delete("time_from")
      time_to = item.delete("time_to")

      item["time_from(h)"] = time_from.split(":")[0]
      item["time_from(m)"] = time_from.split(":")[1][0..1]
      item["time_from(meridian)"] = time_from[-2..]

      item["time_to(h)"] = time_to.split(":")[0]
      item["time_to(m)"] = time_to.split(":")[1][0..1]
      item["time_to(meridian)"] = time_to[-2..]

      item
    end

    check "Show opening hours"
  end

  fields.each do |row|
    field_prefix = "content_block/edition[details][#{@object_type.pluralize}][#{item_type}][]"

    row.each do |key, value|
      within all(".js-add-another__fieldset").last do
        field = page.all(:css, "[name='#{field_prefix}[#{key}]']").last
        if field.tag_name == "select"
          select value, from: field[:id]
        else
          fill_in field[:id], with: value
        end
      end
    end

    page.driver.with_playwright_page do |page|
      page.get_by_text("Add another #{item_type.humanize.singularize}").click unless row == fields.last
    end
  end
end

Given("I indicate that the call charges info URL should be shown") do
  check "Show hyperlink to 'Find out about call charges'"
end

Given("I change the call charges info URL from its default value") do
  fill_in("URL to find out about call charges", with: "https://custom.example.com")
end

Given("I change the call charges info label from its default value") do
  within(".app-c-content-block-manager-call-charges-component") do
    fill_in("Label", with: "Learn about the cost of calls (custom label)")
  end
end

When("I view all the telephone attributes") do
  # navigate to "telephones" tab
  find("#tab_telephones").click
  # expand the list of telphone details
  find("span[data-ga4-expandable='']", text: "All telephone attributes").click
end

Then("I should see that the call charges fields have been changed") do
  within(".gem-c-summary-card[title='Call Charges']") do
    expect(page).to have_css("dt", text: "Show call charges info url")
    expect(page).to have_css("dt", text: "on")

    expect(page).not_to have_content("https://gov.uk/call-charges")
    expect(page).to have_content("https://custom.example.com")

    expect(page).not_to have_content("Find out about call charges")
    expect(page).to have_content("Learn about the cost of calls (custom label)")
  end
end

When("I indicate that BSL guidance should be shown") do
  check I18n.t("content_block_edition.details.labels.telephones.bsl_guidance.show")
end

When("I change the BSL guidance label from its default value") do
  fill_in(I18n.t("content_block_edition.details.labels.telephones.bsl_guidance.value"), with: "More about BSL")
end

Then("I should see that the BSL guidance fields have been changed") do
  within(".gem-c-summary-card[title='Bsl Guidance']") do
    expect(page).to have_css("dt", text: "Show")
    expect(page).to have_css("dt", text: "true")

    expect(page).to have_css("dt", text: "Value")
    expect(page).to have_css("dt", text: "More about BSL")
  end
end

Then("I should be asked to review my {string}") do |object_type|
  assert_text "Review #{object_type}"
end

Then("the {string} should have been created successfully") do |object_type|
  edition = ContentBlockManager::ContentBlock::Edition.all.last

  assert_not_nil edition
  assert_not_nil edition.document
  key = @object_title

  @details.keys.each do |k|
    assert_equal edition.details[object_type.parameterize.pluralize][key][k], @details[k]
  end

  version = edition.versions.order("created_at asc").first
  assert_equal version.updated_embedded_object_type, object_type.pluralize
  assert_equal version.updated_embedded_object_title, @object_title
end

Then("I should see errors for the required {string} fields") do |object_type|
  schema = @schemas.values.first.subschema(object_type.pluralize)
  required_fields = schema.body["required"]
  required_fields.each do |required_field|
    assert_text "#{ContentBlockManager::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank", minimum: 2
  end
end

Then("I should see errors for the required nested {string} fields") do |nested_object_name|
  subschema = @subschemas[@object_type.pluralize]
  required_fields = subschema.dig("properties", nested_object_name.pluralize, "items", "required")
  required_fields.each do |required_field|
    assert_text "#{ContentBlockManager::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank", minimum: 2
  end
end

And("I should see details of my {string}") do |object_type|
  within "div[data-testid='#{object_type.pluralize}_listing']" do
    @details.keys.each do |k|
      assert_text @details[k]
    end
  end
end

And("I click to add a new {string}") do |object_type|
  @object_type = object_type
  click_on "Add #{add_indefinite_article object_type.humanize.downcase}"
end

And("I click to add another {string}") do |object_type|
  @object_type = object_type
  click_on "Add another #{object_type.humanize.downcase}"
end

And("I review and confirm my {string} is correct") do |_object_type|
  check "is_confirmed"
  click_on "Create"
end

And(/^I click create$/) do
  click_on "Create"
end

When(/^I click edit$/) do
  click_on "Edit"
end

And(/^that pension has a rate with the following fields:$/) do |table|
  rate = table.hashes.first
  @content_block.details["rates"] = {
    rate[:title].parameterize.to_s => {
      "title" => rate[:title],
      "amount" => rate[:amount],
      "frequency" => rate[:frequency],
    },
  }
  @content_block.save!
end

And(/^I should see the rates for that block$/) do
  @content_block.details["rates"].keys.each do |k|
    within "div[data-test-id=embedded_#{k}]" do
      @content_block.details["rates"][k].each do |_k, value|
        assert_text value
      end
    end
  end
end

When(/^I click to edit the first rate$/) do
  key = @content_block.details["rates"].keys.first
  within "div[data-test-id=embedded_#{key}]" do
    click_on "Edit"
  end
end

And(/^I should see the updated rates for that block$/) do
  @details.keys.each do |k|
    assert_text @details[k]
  end
end

And("I should not see a button to add a new {string}") do |object_type|
  assert_no_text "Add #{add_indefinite_article object_type}"
end

Then("I should see the created embedded object of type {string}") do |object_type|
  assert_text "#{object_type.humanize.pluralize} (1)"
end
