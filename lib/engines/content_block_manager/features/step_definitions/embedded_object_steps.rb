When("I visit the page to create a new {string} for the block") do |object_type|
  visit content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
    document_id: @content_block.document.id,
    object_type: object_type.pluralize,
  )
end

Then("I should see a form to create a {string} for the content block") do |object_type|
  expect(page).to have_text("Create #{object_type}")
end

Then("I should see confirmation that my {string} has been created") do |object_type|
  expect(page).to have_text("#{object_type.titleize} created")
end

When("I complete the {string} form with the following fields:") do |object_type, table|
  fields = table.hashes.first
  @details = fields
  fields.keys.each do |k|
    field = find_field "content_block_manager_content_block_edition_details_#{object_type.pluralize}_#{k}"
    if field.tag_name == "select"
      select @details[k].humanize, from: field[:id]
    else
      fill_in field[:id], with: @details[k]
    end
  end

  click_save_and_continue
end

Then("I should be asked to review my {string}") do |object_type|
  assert_text "Review #{object_type}"
end

Then("the {string} should have been created successfully") do |object_type|
  edition = ContentBlockManager::ContentBlock::Edition.all.last

  assert_not_nil edition
  assert_not_nil edition.document
  key = @details["name"].parameterize

  @details.keys.each do |k|
    assert_equal edition.details[object_type.parameterize.pluralize][key][k], @details[k]
  end
end

Then("I should see errors for the required {string} fields") do |object_type|
  schema = @schemas.values.first.subschema(object_type.pluralize)
  required_fields = schema.body["required"]
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

And("I click to create a new {string}") do |object_type|
  click_on "Create #{object_type}"
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
