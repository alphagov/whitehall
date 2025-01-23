require_relative "../support/form_step_helpers"

Then(/^I should be on the "([^"]*)" step$/) do |step|
  case step
  when "edit"
    should_show_edit_form
  when "review_links"
    should_show_dependent_content
    should_show_rollup_data
  when "schedule_publishing"
    should_show_publish_form
  when "review"
    should_be_on_review_step
  when "change_note"
    should_be_on_change_note_step
  end
end
