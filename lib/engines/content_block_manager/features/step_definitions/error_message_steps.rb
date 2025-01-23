Then("I should see a message that the field is an invalid {string}") do |format|
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: format)
end

Then("I should see a message that I need to confirm the details are correct") do
  assert_text I18n.t("content_block_edition.review_page.errors.confirm"), minimum: 2
end

Then("I should see a permissions error") do
  assert_text "Permissions error"
end

Then(/^I should see an error prompting me to choose an object type$/) do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank")
end

Then("I should see errors for the required fields") do
  assert_text "Title cannot be blank", minimum: 2

  required_fields = @schema.body["required"]
  required_fields.each do |required_field|
    assert_text "#{ContentBlockManager::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank", minimum: 2
  end
  assert_text "Lead organisation cannot be blank", minimum: 2
end

Then("I should see a message that the filter dates are invalid") do
  expect(page).to have_selector("a[href='#last_updated_from_3i']"), text: "Last updated from is not a valid date"
  expect(page).to have_selector("a[href='#last_updated_to_3i']"), text: "Last updated to is not a valid date"
end
