When(/^another editor retrospectively approves the "([^"]*)" publication$/) do |publication_title|
  user = create(:departmental_editor, name: "Other editor")
  login_as user
  visit admin_editions_path(state: :published)
  click_link publication_title
  click_button "Looks good"
end

Then(/^the "([^"]*)" publication should not be flagged as force\-published any more$/) do |publication_title|
  visit admin_editions_path(state: :published)
  publication = Publication.find_by(title: publication_title)
  assert_selector record_css_selector(publication)
  assert_no_selector record_css_selector(publication) + ".force_published"
end

Then(/^the publication "([^"]*)" should have a force publish reason$/) do |publication_title|
  publication = Publication.find_by(title: publication_title)
  ensure_path(admin_edition_path(publication))
  assert_text "Force published: because"
end
