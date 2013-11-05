Given /^a draft (document|publication|policy|news article|consultation|speech) "([^"]*)" exists$/ do |document_type, title|
  document_type = 'policy' if document_type == 'document'
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^a published (publication|policy|news article|consultation|speech|detailed guide) "([^"]*)" exists$/ do |document_type, title|
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^a published document "([^"]*)" exists$/ do |title|
  create(:published_policy, title: title)
end

Given /^a draft (publication|policy|news article|consultation) "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name!(topic_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, topics: [topic])
end

Given /^a submitted (publication|policy|news article|consultation|detailed guide) "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name!(topic_name)
  create("submitted_#{document_class(document_type).name.underscore}".to_sym, title: title, topics: [topic])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name!(topic_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, topics: [topic])
end

Given /^a draft (publication|policy|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/ do |document_type, title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, organisations: [organisation])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/ do |document_type, title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, organisations: [organisation])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" exists relating to the (?:world location|international delegation) "([^"]*)"$/ do |document_type, title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, world_locations: [world_location])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" exists relating to the (?:world location|international delegation) "([^"]*)" produced (\d+) days ago$/ do |document_type, title, world_location_name, days_ago|

  world_location = WorldLocation.find_by_name!(world_location_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, first_published_at: days_ago.to_i.days.ago, world_locations: [world_location])
end

Given /^a submitted (publication|policy|news article|consultation|speech|worldwide priority|detailed guide) "([^"]*)" exists$/ do |document_type, title|
  create("submitted_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^another user edits the (publication|policy|news article|consultation|speech) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  edition = document_class(document_type).find_by_title!(original_title)
  edition.update_attributes!(title: new_title)
end

Given /^a published (publication|policy|news article|consultation|speech) "([^"]*)" that's the responsibility of:$/ do |document_type, title, table|
  edition = create(:"published_#{document_type}", title: title)
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = find_or_create_ministerial_role(row["Ministerial Role"])
    unless RoleAppointment.for_role(ministerial_role).for_person(person).exists?
      create(:role_appointment, role: ministerial_role, person: person)
    end
    edition.ministerial_roles << ministerial_role
  end
end

Given(/^a draft publication "(.*?)" with a file attachment exists$/) do |title|
  @edition = create(:draft_publication, :with_file_attachment, title: title)
  @attachment = @edition.attachments.first
end

Given /^a force published (document|publication|policy|news article|consultation|speech) "([^"]*)" was produced by the "([^"]*)" organisation$/ do |document_type, title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  document_type = 'policy' if document_type == 'document'
  edition = create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, organisations: [organisation])
  visit admin_editions_path(state: :draft)
  click_link title
  publish(force: true)
end

When /^I view the (publication|policy|news article|consultation|speech|document) "([^"]*)"$/ do |document_type, title|
  click_link title
end

When /^I visit the list of draft documents$/ do
  visit admin_editions_path(state: :draft)
end

When /^I visit the list of documents awaiting review$/ do
  visit admin_editions_path(state: :submitted)
end

When /^I select the "([^"]*)" edition filter$/ do |edition_type|
  filter_editions_by :type, edition_type
end

When /^I filter by author "([^"]*)"$/ do |author_name|
  filter_editions_by :author, author_name
end

When /^I filter by organisation "([^"]*)"$/ do |organisation_name|
  filter_editions_by :organisation, organisation_name
end

When /^I visit the (publication|policy|news article|consultation) "([^"]*)"$/ do |document_type, title|
  edition = document_class(document_type).find_by_title!(title)
  visit public_document_path(edition)
end

When /^I preview "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title)
  visit preview_document_path(edition)
end

When /^I preview the document$/ do
  click_link "Preview on website"
end

When /^I submit (#{THE_DOCUMENT})$/ do |edition|
  visit_edition_admin edition.title
  click_button "Submit for 2nd eyes"
end

When /^I publish (#{THE_DOCUMENT})$/ do |edition|
  visit_edition_admin edition.title
  publish
end

When /^someone publishes (#{THE_DOCUMENT})$/ do |edition|
  as_user(create(:departmental_editor)) do
    visit_edition_admin edition.title
    publish(force: true)
  end
end

When /^I force publish (#{THE_DOCUMENT})$/ do |edition|
  visit_edition_admin edition.title, :draft
  click_link "Edit draft"
  fill_in_change_note_if_required
  click_button "Save"
  publish(force: true)
end

When /^I save my changes to the (publication|policy|news article|consultation|speech)$/ do |document_type|
  click_button "Save"
end

When /^I edit the (publication|policy|news article|consultation) changing the title to "([^"]*)"$/ do |document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

Then /^I should see (#{THE_DOCUMENT})$/ do |edition|
  assert has_css?(record_css_selector(edition))
end

Then /^I should not see (#{THE_DOCUMENT})$/ do |edition|
  assert has_no_css?(record_css_selector(edition))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of draft documents$/ do |edition|
  visit admin_editions_path
  assert has_css?(record_css_selector(edition))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of submitted documents$/ do |edition|
  visit admin_editions_path(state: :submitted)
  assert has_css?(record_css_selector(edition))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of published documents$/ do |edition|
  visit admin_editions_path(state: :published)
  assert has_css?(record_css_selector(edition))
end

Then /^I should not see the policy "([^"]*)" in the list of draft documents$/ do |title|
  visit admin_editions_path
  assert has_no_css?(".policy a", text: title)
end

Then(/^(#{THE_DOCUMENT}) should no longer be listed on the public site$/) do |edition|
  visit_public_index_for(edition)
  css_selector = edition.is_a?(DetailedGuide) ? 'h1.page_title' : record_css_selector(edition)
  refute page.has_content?(edition.title)
end

Then /^(#{THE_DOCUMENT}) should be visible to the public$/ do |edition|
  visit_public_index_for(edition)
  css_selector = edition.is_a?(DetailedGuide) ? 'h1.page_title' : record_css_selector(edition)
  assert page.has_css?(css_selector, text: edition.title)
end

Then /^I should see in the preview that "([^"]*)" should be in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  visit_document_preview title
  assert has_css?(".document-topics a", text: first_topic)
  assert has_css?(".document-topics a", text: second_topic)
end

Then /^I should see in the preview that "([^"]*)" was produced by the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  visit_document_preview title
  assert has_css?(".organisation", text: first_org)
  assert has_css?(".organisation", text: second_org)
end

Then /^I should see in the preview that "([^"]*)" is associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  visit_document_preview title
  assert has_css?(".document-ministerial-roles a", text: minister_1)
  assert has_css?(".document-ministerial-roles a", text: minister_2)
end

Then /^I should see in the preview that "([^"]*)" does not apply to the nations:$/ do |title, nation_names|
  visit_document_preview title
  nation_names.raw.flatten.each do |nation_name|
    assert has_css?(".document-inapplicable-nations", text: /#{nation_name}/)
  end
end

Then /^I should see in the preview that "([^"]*)" should related to "([^"]*)" and "([^"]*)" policies$/ do |title, related_policy_1, related_policy_2|
  visit_document_preview title
  assert has_css?(".document-policies a", text: related_policy_1)
  assert has_css?(".document-policies a", text: related_policy_2)
end

Then /^I should see in the preview that "([^"]*)" should related to "([^"]*)" and "([^"]*)" worldwide priorities$/ do |title, related_priority_1, related_priority_2|
  visit_document_preview title
  assert has_content?(related_priority_1)
  assert has_content?(related_priority_2)
end

Then /^I should see the conflict between the (publication|policy|news article|consultation|speech) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert_equal new_title, find(".conflicting.new #edition_title").value
  assert page.has_css?(".conflicting.latest .document .title", text: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  edition = Edition.latest_edition.find_by_title!(title)
  assert !edition.published?
end

Then /^my attempt to publish "([^"]*)" should succeed$/ do |title|
  edition = Edition.latest_edition.find_by_title!(title)
  assert edition.published?
end

Then /^my attempt to save it should fail with error "([^"]*)"/ do |error_message|
  click_button "Save"
  assert page.has_css?(".errors li", text: error_message)
end
