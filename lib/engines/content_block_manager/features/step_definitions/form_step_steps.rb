require_relative "../support/form_step_helpers"

Then(/^I should be on the "([^"]*)" step$/) do |step|
  case step
  when "edit"
    should_show_edit_form(object_type: @content_block.document.block_type)
  when "review_links"
    should_show_dependent_content(object_type: @content_block.document.block_type)
    should_show_rollup_data
  when "schedule_publishing"
    should_show_publish_form
  when "review"
    should_be_on_review_step(object_type: @content_block.document.block_type)
  when "change_note"
    should_be_on_change_note_step
  when "add_embedded_objects"
    assert_text "Add to #{@schema.name}"
  when "edit_embedded_objects"
    assert_text "Change #{@schema.name}"
  end
end
