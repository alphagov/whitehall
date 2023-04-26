When(/^another editor retrospectively approves the "([^"]*)" publication$/) do |publication_title|
  user = create(:departmental_editor, name: "Other editor")
  login_as user
  visit admin_editions_path(state: :published)
  click_link publication_title
  click_link "Approve"
  click_button "Approve"
end

Then(/^the "([^"]*)" publication should not be flagged as force-published any more$/) do |publication_title|
  visit admin_editions_path(state: :published)
  publication = Publication.find_by(title: publication_title)

  if using_design_system?
    expect(find(".govuk-table")).to have_content publication_title
    assert_selector ".govuk-table__cell", text: "Force published", count: 0
  else
    expect(page).to have_selector(record_css_selector(publication))
    expect(page).to_not have_selector("#{record_css_selector(publication)}.force_published")
  end
end

Then(/^the publication "([^"]*)" should have a force publish reason$/) do |publication_title|
  publication = Publication.find_by(title: publication_title)
  ensure_path(admin_edition_path(publication))
  expect(page).to have_content("Force published: because")
end
