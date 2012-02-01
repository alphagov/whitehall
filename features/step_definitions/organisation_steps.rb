Given /^the organisation "([^"]*)" contains some policies$/ do |name|
  documents = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:organisation, name: name, documents: documents)
end

Given /^other organisations also have policies$/ do
  create(:organisation, documents: [build(:published_policy)])
  create(:organisation, documents: [build(:published_policy)])
end

Given /^the organisation "([^"]*)" exists$/ do |name|
  create(:organisation, name: name)
end

Given /^two organisations "([^"]*)" and "([^"]*)" exist$/ do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given /^the "([^"]*)" organisation contains:$/ do |organisation_name, table|
  organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    organisation.ministerial_roles << ministerial_role
    create(:role_appointment, role: ministerial_role, person: person)
  end
end

Given /^that "([^"]*)" is responsible for "([^"]*)" and "([^"]*)"$/ do |parent_org_name, child_org_1_name, child_org_2_name|
  child_org_1 = create(:organisation, name: child_org_1_name)
  child_org_2 = create(:organisation, name: child_org_2_name)
  create(:organisation, name: parent_org_name, child_organisations: [child_org_1, child_org_2])
end

Given /^that "([^"]*)" is the responsibility of "([^"]*)" and "([^"]*)"$/ do |child_org_name, parent_org_1_name, parent_org_2_name|
  parent_org_1 = create(:organisation, name: parent_org_1_name)
  parent_org_2 = create(:organisation, name: parent_org_2_name)
  create(:organisation, name: child_org_name, parent_organisations: [parent_org_1, parent_org_2])
end

Given /^a submitted corporate publication "([^"]*)" about the "([^"]*)"$/ do |publication_title, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  create(:submitted_corporate_publication, title: publication_title, organisations: [organisation])
end

Given /^the organisation "([^"]*)" is associated with consultations "([^"]*)" and "([^"]*)"$/ do |name, consultation_1, consultation_2|
  organisation = create(:organisation, name: name)
  create(:published_consultation, title: consultation_1, organisations: [organisation])
  create(:published_consultation, title: consultation_2, organisations: [organisation])
end

When /^I visit the "([^"]*)" organisation$/ do |name|
  visit_organisation name
end

When /^I set the featured news articles in the "([^"]*)" organisation to:$/ do |name, table|
  organisation = Organisation.find_by_name!(name)
  visit edit_admin_organisation_path(organisation)
  table.rows.each do |title|
    news_article = NewsArticle.find_by_title(title)
    within record_css_selector(news_article) do
      click_button "Feature"
    end
  end
end

When /^I navigate to the "([^"]*)" organisation's (about|news|home) page$/ do |organisation_name, page_name|
  within('.organisation nav') do
    click_link \
      case page_name
      when 'about'  then 'About'
      when 'news'   then 'News'
      when 'home'   then 'Home'
      end
  end
end

Then /^I should see the featured news articles in the "([^"]*)" organisation are:$/ do |name, expected_table|
  visit_organisation name
  rows = find("#featured-news-articles").all('.news_article')
  table = rows.map { |r| r.all('a.title').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  documents = records_from_elements(Document, page.all(".document"))
  assert documents.all? { |document| organisation.documents.published.include?(document) }
end

Then /^I should see "([^"]*)" has the "([^"]*)" ministerial role$/ do |person_name, role_name|
  person = find_person(person_name)
  ministerial_role = person.current_ministerial_roles.find_by_name!(role_name)
  assert page.has_css?(".ministerial_role", text: ministerial_role.name)
  assert page.has_css?(".ministerial_role .current_appointee", text: person.name)
end

Then /^I should see that "([^"]*)" is responsible for "([^"]*)"$/ do |parent_org_name, child_org_name|
  child_org = Organisation.find_by_name!(child_org_name)
  assert page.has_css?("#child_organisations #{record_css_selector(child_org)}")
end

Then /^I should see that "([^"]*)" is the responsibility of "([^"]*)"$/ do |child_org_name, parent_org_name|
  parent_org = Organisation.find_by_name!(parent_org_name)
  assert page.has_css?(".meta a[href='#{organisation_path(parent_org)}']")
end

Then /^I should see the following speeches are associated with the "([^"]*)" organisation:$/ do |name, table|
  table.hashes.each do |row|
    assert page.has_css?("#speeches .speech .title", row["Title"])
  end
end

Then /^I should see the organisation navigation$/ do
  assert page.has_css?('.organisation nav')
end

Then /^I should see the "([^"]*)" organisation's (about|news|home) page$/ do |organisation_name, page_name|
  title =
    case page_name
    when 'about'  then "About #{organisation_name}"
    when 'news'   then "#{organisation_name} News"
    when 'home'   then organisation_name
    end

  assert page.has_css?('title', text: title)
end
