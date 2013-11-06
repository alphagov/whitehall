Given /^a submitted policy titled "([^"]*)"$/ do |policy_title|
  create(:submitted_policy, title: policy_title)
end

Given /^a published policy "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" topics$/ do |policy_title, topic_1, topic_2|
  policy = create(:published_policy, title: policy_title)
  create(:topic, name: topic_1, editions: [policy])
  create(:topic, name: topic_2, editions: [policy])
end

Given /^a published policy "([^"]*)" that does not apply to the nations:$/ do |policy_title, nation_names|
  policy = create(:published_policy, title: policy_title)
  nation_names.raw.flatten.each do |nation_name|
    policy.nation_inapplicabilities.create!(nation: Nation.find_by_name!(nation_name))
  end
end

Given /^a published policy "([^"]*)"$/ do |title|
  @policy = create(:published_policy, title: title)
end

Given /^I visit the list of draft policies$/ do
  visit admin_editions_path(state: :draft)
end

Given /^I click on the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
end

Given /^I start editing the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^two published policies "([^"]*)" and "([^"]*)" exist$/ do |policy_title_1, policy_title_2|
  create(:published_policy, title: policy_title_1)
  create(:published_policy, title: policy_title_2)
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy "([^"]*)" with supporting page "([^"]*)"$/ do |email, title, supporting_page_title|
  policy = create(:draft_policy, title: title)
  supporting_page = create(:supporting_page, edition: policy, title: supporting_page_title)
  fact_check_request = create(:fact_check_request, edition: policy, email_address: email)
  Notifications.fact_check_request(fact_check_request, host: "example.com").deliver
end

Given /^an editor named "([^"]*)" has rejected the policy titled "([^"]*)"$/ do |editor_name, policy_title|
  editor = create(:departmental_editor, name: editor_name)
  policy = create(:submitted_policy, title: policy_title)
  login_as editor
  policy.reject!
end

Given /^a published (publication|consultation|news article|speech) "([^"]*)" related to the policy "([^"]*)"$/ do |document_type, document_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  create("published_#{document_class(document_type).name.underscore}".to_sym,
          title: document_title, related_editions: [policy])
end

When /^I reject the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  visit admin_policy_path(policy)
  click_button "Reject"
  fill_in "Remark", with: "reason-for-rejection"
  click_button "Submit remark"
end

When /^I create a new edition of the published policy "([^"]*)"$/ do |policy_title|
  visit admin_editions_path(state: :published)
  click_link policy_title
  click_button 'Create new edition'
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Body', with: "New policy"
  click_button 'Save'
end

When /^I request that "([^"]*)" fact checks the policy "([^"]*)" with instructions "([^"]*)"$/ do |email, title, instructions|
  policy = Policy.find_by_title!(title)
  visit admin_editions_path(state: :draft)
  within(record_css_selector(policy)) do
    click_link title
  end
  within("#new_fact_check_request") do
    fill_in "Email address", with: email
    fill_in "Extra instructions", with: instructions
    click_button "Send request"
  end
end

When /^I draft a new policy "([^"]*)"$/ do |title|
  begin_drafting_policy title: title
  fill_in_change_note_if_required
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_policy title: title
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" produced by the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  begin_drafting_policy title: title
  select first_org, from: "edition_lead_organisation_ids_1"
  select second_org, from: "edition_lead_organisation_ids_2"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  begin_drafting_policy title: title
  select minister_1, from: "Ministers"
  select minister_2, from: "Ministers"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_policy title: title
  nations.raw.flatten.each do |nation_name|
    within record_css_selector(Nation.find_by_name!(nation_name)) do
      check nation_name
      fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
    end
  end
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" relating it to the worldwide_priorities "([^"]*)" and "([^"]*)"$/ do |title, first_priority, second_priority|
  begin_drafting_policy title: title
  select first_priority, from: "Worldwide priorities"
  select second_priority, from: "Worldwide priorities"
  click_button "Save"
end

When /^I edit the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
  fill_in_change_note_if_required
  click_button "Save"
end

When /^I edit the policy "([^"]*)" adding it to the "([^"]*)" topic$/ do |title, topic_name|
  begin_editing_document title
  select topic_name, from: "Topics"
  fill_in_change_note_if_required
  click_button "Save"
end

When /^I publish the policy "([^"]*)" but another user edits it while I am viewing it$/ do |title|
  policy = Policy.find_by_title!(title)
  visit_edition_admin title
  policy.update_attributes!(body: 'A new body')
  publish(ignore_errors: true)
end

When /^I publish the policy "([^"]*)" without a change note$/ do |title|
  policy = Policy.find_by_title!(title)
  visit_edition_admin title
  publish(without_change_note: true)
end

When /^I visit the activity of the published policy "([^"]*)"$/ do |title|
  policy = Policy.published.find_by_title!(title)
  visit activity_policy_path(policy.document)
end

When /^I delete the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  visit admin_edition_path(policy)
  click_button "Delete"
end

When /^I view the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
end

When /^I resubmit the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Submit"
end

When /^I publish a new edition of the policy "([^"]*)" with the new title "([^"]*)"$/ do |policy_title, new_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  fill_in "Title", with: new_title
  fill_in_change_note_if_required
  click_button "Save"
  publish(force: true)
end

When /^I publish a new edition of the policy "([^"]*)" as a minor change$/ do |policy_title|
  policy = Policy.latest_edition.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  check "edition_minor_change"
  click_button "Save"
  publish(force: true, ignore_errors: true)
end

When /^I publish a new edition of the policy "([^"]*)" with a change note "([^"]*)"$/ do |policy_title, change_note|
  policy = Policy.latest_edition.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  fill_in "edition_change_note", with: change_note
  click_button "Save"
  publish(force: true)
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", text: comments)
end

Then /^I should see the pending fact check request to "([^"]*)" for policy "([^"]*)"$/ do |email_address, title|
  visit admin_policy_path(Policy.find_by_title!(title))
  assert page.has_css?(".fact_check_request.pending .from", text: email_address)
end

Then /^I should see that those responsible for the policy are:$/ do |table|
  table.hashes.each do |row|
    person = find_person(row["Person"])
    assert page.has_css?(".meta a", text: person.name)
  end
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".body", text: policy_body)
end

Then /^I should see that the policy only applies to:$/ do |nation_names|
  message = "#{nation_names.raw.flatten.sort.to_sentence}"
  assert page.has_css?("#{inapplicable_nations_selector}", text: message)
end

Then /^they should see the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  assert page.has_css?('.document .title', text: policy.title)
  assert page.has_css?('.document .body', text: policy.body)
end

Then /^they should see the supporting page "([^"]*)"$/ do |title|
  supporting_page = SupportingPage.find_by_title!(title)
  assert page.has_css?("#{supporting_pages_selector} .document .title", text: supporting_page.title)
  assert page.has_css?("#{supporting_pages_selector} .document .body", text: supporting_page.body)
end

Then /^I can see links to the related published policies "([^"]*)" and "([^"]*)"$/ do |policy_title_1, policy_title_2|
  assert has_css?(".meta a", text: policy_title_1)
  assert has_css?(".meta a", text: policy_title_2)
end

Then /^I should see a link to the public version of the policy "([^"]*)"$/ do |policy_title|
  policy = Policy.published.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  assert_match public_document_path(policy), find("a.public_version")[:href]
end

Then /^I should see a link to the preview version of the policy "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  preview_path_regexp = Regexp.new(Regexp.escape(preview_document_path(policy)).gsub(/cachebust=[0-9]+/, 'cachebust=[0-9]+'))
  assert_match preview_path_regexp, find("a.preview_version")[:href]
end

Then /^I should see the policy titled "([^"]*)" in the list of documents that need work$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  filter_editions_by :state, "Rejected"
  assert page.has_css?("#{record_css_selector(policy)}", text: policy.title)
end

Then /^the writers who worked on the policy titled "([^"]*)" should be emailed about the rejection$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  policy.authors.each do |writer|
    assert_equal 1, unread_emails_for(writer.email).size
    assert_match /The policy '#{policy_title}' was rejected by/, unread_emails_for(writer.email).first.subject
  end
end

Then /^the writers who worked on the policy titled "([^"]*)" should be emailed about the publication$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  policy.authors.each do |writer|
    assert_equal 1, unread_emails_for(writer.email).size
    assert_match /The policy '#{policy_title}' has been published/, unread_emails_for(writer.email).first.subject
  end
end

Then /^I should see that it was rejected by "([^"]*)"$/ do |rejected_by|
  assert page.has_css?('.rejected_by', text: rejected_by)
end

Then /^I should see the policy titled "([^"]*)" in the list of submitted documents$/ do |policy_title|
  filter_editions_by :author, "All authors"
  filter_editions_by :state, 'Submitted'
  policy = Policy.find_by_title!(policy_title)
  assert page.has_css?("#{record_css_selector(policy)}", text: policy.title)
end

Then /^I can see links to the recently changed document "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title)
  assert page.has_css?("#recently-changed #{record_css_selector(edition)} a", text: edition.title), "#{edition.title} not found"
end

Then /^the change notes should appear in the history for the policy "([^"]*)" in reverse chronological order$/ do |title|
  visit policies_path
  click_link title
  policy = Policy.find_by_title!(title)
  document_history = policy.document.change_history
  change_notes = find('.change-notes').all('.note')
  assert_equal document_history.length, change_notes.length
  document_history.zip(change_notes).each do |history, note|
    assert_equal history.note, note.text.strip
  end
end

Given /^a published publication "([^"]*)" associated with the policy$/ do |title|
  create(:published_speech, title: title, related_editions: [@policy])
end

Given /^a draft publication "([^"]*)" associated with the policy$/ do |title|
  create(:draft_speech, title: title, related_editions: [@policy])
end

Then /^I should see a link to "([^"]*)" in the list of related documents$/ do |title|
  edition = Edition.find_by_title(title)
  assert_match admin_edition_path(edition), page.find("#inbound-links a", text: title)[:href]
end

Then /^I should not see a link to "([^"]*)" in the list of related documents$/ do |title|
  edition = Edition.find_by_title(title)
  assert page.has_no_css?("#inbound-links a", text: title), "unexpected link to '#{title}' found"
end

Given /^a (.*?) policy "([^"]*)" for the organisation "([^"]*)"$/ do |state, title, organisation|
  org = create(:organisation, name: organisation)
  create("#{state}_policy", title: title, organisations: [org])
end

Given /^a (.*?) policy "([^"]*)" for the organisations "([^"]*)" and "([^"]*)"$/ do |state, title, organisation1, organisation2|
  org1 = create(:organisation, name: organisation1)
  org2 = create(:organisation, name: organisation2)
  create("#{state}_policy", title: title, organisations: [org1, org2])
end
