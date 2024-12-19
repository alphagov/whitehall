And(/^the document has been updated by a change to the content block "([^"]*)"$/) do |content_block_title|
  host_content_update_event = build(:host_content_update_event, content_title: content_block_title)
  HostContentUpdateEvent.expects(:all_for_date_window).at_least_once.returns([host_content_update_event])
end

Then(/^I should see an entry for the content block "([^"]*)" on the (current|previous) edition$/) do |content_block, current_or_previous|
  selector = current_or_previous == "current" ? ".app-view-editions__current-edition-entries" : ".app-view-editions__previous-edition-entries"

  within selector do
    assert_text "Content Block Update"
    assert_text "#{content_block} updated"
  end
end
