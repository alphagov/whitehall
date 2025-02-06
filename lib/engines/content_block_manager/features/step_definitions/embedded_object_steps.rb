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
