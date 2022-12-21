Given(/^a directory of organisations exists$/) do
  stub_organisation_homepage_in_content_store
end

Given(/^the organisation "([^"]*)" exists$/) do |name|
  create_org_and_stub_content_store(:ministerial_department, name:)
end

Given(/^the organisation "(.*?)" exists with a featured article$/) do |name|
  org = create_org_and_stub_content_store(:ministerial_department, name:)
  create(:feature_list, featurable: org, features: [create(:feature, document: create(:published_news_article).document)])
end

Given(/^the organisation "(.*?)" exists with featured services and guidance$/) do |name|
  org = create(:organisation, name:, homepage_type: "service")
  create(:featured_link, linkable: org)
end

Given(/^the organisation "(.*?)" exists with no featured services and guidance$/) do |name|
  create(:organisation, name:)
end

Given(/^the executive office "([^"]*)" exists$/) do |name|
  create(:executive_office, name:)
end

Given(/^two organisations "([^"]*)" and "([^"]*)" exist$/) do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given(/^the "([^"]*)" organisation is associated with several ministers and civil servants$/) do |organisation_name|
  organisation = Organisation.find_by(name: organisation_name) || create_org_and_stub_content_store(:ministerial_department, name: organisation_name)
  3.times do |x|
    person = create(:person)
    ministerial_role = create(:ministerial_role, cabinet_member: (x == 1))
    organisation.ministerial_roles << ministerial_role
    create(:role_appointment, role: ministerial_role, person:)
  end
  3.times do |x|
    person = create(:person)
    role = create(:board_member_role, permanent_secretary: (x == 1))
    organisation.roles << role
    create(:role_appointment, role:, person:)
  end
end

Given(/^the "([^"]*)" organisation is associated with traffic commissioners$/) do |organisation_name|
  organisation = Organisation.find_by(name: organisation_name) || create_org_and_stub_content_store(:ministerial_department, name: organisation_name)
  traffic_commissioner_role = create(:traffic_commissioner_role, name: "traffic-commissioner-role", organisations: [organisation])
  create(:role_appointment, role: traffic_commissioner_role)
end

Given(/^the "([^"]*)" organisation is associated with scientific advisors$/) do |organisation_name|
  organisation = Organisation.find_by(name: organisation_name) || create_org_and_stub_content_store(:ministerial_department, name: organisation_name)
  chief_scientific_advisor_role = create(:chief_scientific_advisor_role, name: "csi-role", organisations: [organisation])
  create(:role_appointment, role: chief_scientific_advisor_role)
end

Given(/^the "([^"]*)" organisation is associated with chief professional officers$/) do |organisation_name|
  organisation = Organisation.find_by(name: organisation_name) || create_org_and_stub_content_store(:ministerial_department, name: organisation_name)
  chief_professional_officer_role = create(:chief_professional_officer_role, name: "cmo-role", organisations: [organisation])
  create(:role_appointment, role: chief_professional_officer_role)
end

Given(/^a submitted corporate publication "([^"]*)" about the "([^"]*)"$/) do |publication_title, organisation_name|
  organisation = Organisation.find_by(name: organisation_name)
  create(:submitted_corporate_publication, title: publication_title, organisations: [organisation])
end

Given(/^the organisation "([^"]*)" is associated with consultations "([^"]*)" and "([^"]*)"$/) do |name, consultation1, consultation2|
  organisation = create_org_and_stub_content_store(:organisation, name:)
  create(:published_consultation, title: consultation1, organisations: [organisation])
  create(:published_consultation, title: consultation2, organisations: [organisation])
end

Given(/^a published publication "([^"]*)" with a PDF attachment and alternative format provider "([^"]*)"$/) do |title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  publication = create(:published_publication, :with_file_attachment, title:, body: "!@1", organisations: [organisation], alternative_format_provider: organisation)
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given(/^I set the alternative format contact email of "([^"]*)" to "([^"]*)"$/) do |organisation_name, email|
  organisation = Organisation.find_by!(name: organisation_name)
  visit edit_admin_organisation_path(organisation)
  fill_in "organisation_alternative_format_contact_email", with: email
  click_button "Save"
end

Given(/^I have an offsite link "(.*?)" for the organisation "(.*?)"$/) do |title, organisation_name|
  organisation = Organisation.find_by(name: organisation_name)
  @offsite_link = create :offsite_link, title:, parent: organisation
end

When(/^I add a new organisation called "([^"]*)"$/) do |organisation_name|
  create(:topical_event, name: "Jazz Bizniz")

  visit new_admin_organisation_path

  fill_in "Name", with: organisation_name
  fill_in "Acronym", with: organisation_name.split(" ").collect { |word| word.chars.first }.join
  fill_in "Logo formatted name", with: organisation_name
  select "Ministerial department", from: "Organisation type"
  select "Jazz Bizniz", from: "organisation_topical_event_ids_0"
  within ".featured-links" do
    expect(page).to_not have_content("English:")
    fill_in "Title", with: "Top task 1"
    fill_in "URL", with: "http://mainstream.co.uk"
  end
  click_button "Save"
end

When(/^I add a translation for an organisation called "([^"]*)"$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)

  click_link "Translations"

  select "Cymraeg (Welsh)", from: "Locale"
  click_button "Create translation"

  fill_in "Name", with: "Organisation Name in another language"
  fill_in "Acronym", with: "ABC"
  fill_in "Logo formatted name", with: "Organisation Name in another language"

  within ".featured-links" do
    expect(page).to have_content("English: Top task 1")
    expect(page).to have_content("English: http://mainstream.co.uk")
    fill_in "Title", with: "Top task 1 in another language"
    fill_in "URL", with: "http://mainstream.wales"
  end

  click_button "Save"
end

Then(/^I should be able to see "([^"]*)" in the list of organisations$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  within record_css_selector(organisation) do
    expect(page).to have_content(organisation_name)
  end
end

Then(/^I should be able to see the translation for "([^"]*)" in the list of translations$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Translations"
  expect(page).to have_content("Cymraeg")
end

When(/^I feature the news article "([^"]*)" for "([^"]*)"$/) do |news_article_title, organisation_name|
  step %(I feature the news article "#{news_article_title}" for "#{organisation_name}" with image "minister-of-funk.960x640.jpg")
end

When(/^I feature the news article "([^"]*)" for "([^"]*)" with image "([^"]*)"$/) do |news_article_title, organisation_name, image_filename|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Features"
  locale = Locale.find_by_language_name("English")
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by(title: news_article_title)
  fill_in "title", with: news_article_title.split.first
  within record_css_selector(news_article) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I stop featuring the news article "([^"]*)" for "([^"]*)"$/) do |news_article_title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit features_admin_organisation_path(organisation)
  locale = Locale.find_by_language_name("English")
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by(title: news_article_title)
  within record_css_selector(news_article) do
    click_on "Unfeature"
  end
end

When(/^I order the featured items in the "([^"]*)" organisation as:$/) do |name, table|
  organisation = Organisation.find_by!(name:)
  visit features_admin_organisation_path(organisation)
  order_features_from(table)
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the organisation "(.*?)"$/) do |title, type, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit features_admin_organisation_path(organisation)
  click_link "Create a non-GOV.UK government link"
  fill_in :offsite_link_title, with: title
  select type, from: "offsite_link_link_type"
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

When(/^I feature the offsite link "(.*?)" for organisation "(.*?)" with image "(.*?)"$/) do |offsite_link_title, organisation_name, image_filename|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Features"
  offsite_link = OffsiteLink.find_by(title: offsite_link_title)
  within record_css_selector(offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I stop featuring the offsite link "([^"]*)" for "([^"]*)"$/) do |offsite_link_name, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit features_admin_organisation_path(organisation)
  offsite_link = OffsiteLink.find_by(title: offsite_link_name)
  within record_css_selector(offsite_link) do
    click_on "Unfeature"
  end
end

When(/^I delete the organisation "([^"]*)"$/) do |name|
  organisation = Organisation.find_by!(name:)
  visit edit_admin_organisation_path(organisation)
  click_button "delete"
end

Then(/^there should not be an organisation called "([^"]*)"$/) do |name|
  expect(Organisation.find_by(name:)).to_not be_present
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" organisation page$/) do |title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  offsite_link = OffsiteLink.find_by!(title:)
  visit admin_organisation_path(organisation)
  click_link "Features"
  expect(page).to have_link(title, href: edit_admin_organisation_offsite_link_path(organisation.slug, offsite_link.id))
end

def navigate_to_organisation(page_name)
  within("nav.sub_navigation") do
    click_link page_name
  end
end

Then(/^the alternative format contact email is "([^"]*)"$/) do |email|
  publication = Publication.last
  actual = publication.alternative_format_contact_email

  expect(email).to eq(actual)
end

Then(/^I cannot see links to Transparency data on the "([^"]*)" about page$/) do |name|
  visit_organisation_about_page name
  expect(page).to_not have_selector("a", text: "Transparency data")
end

Then(/^I can see a link to "([^"]*)" on the "([^"]*)" about page$/) do |link_text, name|
  visit_organisation_about_page name
  expect(page).to have_selector("a", text: link_text)
end

When(/^I associate a Transparency data publication to the "([^"]*)"$/) do |name|
  organisation = Organisation.find_by!(name:)
  create(:published_publication, :transparency_data, organisations: [organisation])
end

Given(/^an organisation "([^"]*)" has been assigned to handle fatalities$/) do |organisation_name|
  create(:organisation, name: organisation_name, handles_fatalities: true)
end

When(/^I visit the organisation admin page for "([^"]*)"$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
end

When(/^I add a new contact "([^"]*)" with address "([^"]*)"$/) do |contact_description, address|
  click_link "Contacts"
  click_link "Add"
  fill_in_contact_details(title: contact_description, street_address: address)
  click_button "Save"
end

When(/^I edit the contact to have address "([^"]*)"$/) do |address|
  click_link "Contacts"
  within ".contact" do
    click_link "Edit"
  end
  fill_in "Street address", with: address
  click_button "Save"
end

Then(/^I should see the "([^"]*)" contact in the admin interface with address "([^"]*)"$/) do |contact_description, address|
  within ".contact" do
    expect(page).to have_selector("h3", text: contact_description)
    expect(page).to have_selector(".vcard", text: address)
  end
end

Given(/^an organisation and some documents exist$/) do
  @organisation = create(:ministerial_department)
  @organisation2 = create(:ministerial_department)
  @author1 = create(:departmental_editor)
  @author2 = create(:departmental_editor)
  @documents = [
    create(:published_news_article, title: "DOC1", organisations: [@organisation], creator: @author1),
    create(:published_news_article, title: "DOC2", organisations: [@organisation2], creator: @author1),
    create(:published_consultation, title: "DOC3", organisations: [@organisation2], creator: @author2),
  ]
end

When(/^I go to the organisation feature page$/) do
  visit admin_organisation_path(@organisation)
  click_link "Features"
end

Then(/^I can filter instantaneously the list of documents by title, author, organisation, and document type$/) do
  fill_in "title", with: @documents.first.title
  click_on "enter"
  within "#search_results" do
    expect(page).to have_selector(record_css_selector(@documents[0]))
    expect(page).to_not have_selector(record_css_selector(@documents[1]))
    expect(page).to_not have_selector(record_css_selector(@documents[2]))
  end
  click_link "Reset all fields"
  within "#search_results" do
    expect(page).to have_selector(record_css_selector(@documents[0]))
    expect(page).to_not have_selector(record_css_selector(@documents[1]))
    expect(page).to_not have_selector(record_css_selector(@documents[2]))
  end
  select @organisation2.name, from: "organisation"
  within "#search_results" do
    expect(page).to_not have_selector(record_css_selector(@documents[0]))
    expect(page).to have_selector(record_css_selector(@documents[1]))
    expect(page).to have_selector(record_css_selector(@documents[2]))
  end
  select @author2.name, from: "author"
  within "#search_results" do
    expect(page).to_not have_selector(record_css_selector(@documents[0]))
    expect(page).to_not have_selector(record_css_selector(@documents[1]))
    expect(page).to have_selector(record_css_selector(@documents[2]))
  end
  select "News articles", from: "type"
  within "#search_results" do
    expect(page).to_not have_selector(record_css_selector(@documents[0]))
    expect(page).to_not have_selector(record_css_selector(@documents[1]))
    expect(page).to_not have_selector(record_css_selector(@documents[2]))
  end
end

When(/^I close the organisation "(.*?)", superseding it with the organisation "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by!(name: org_name)
  visit edit_admin_organisation_path(organisation.slug)
  select "Closed", from: "Status on GOV.UK"
  select "Replaced", from: "Reason for closure"
  select superseding_org_name, from: "Superseded by"
  click_on "Save"
end

Then(/^I can see that the organisation "(.*?)" has been superseded with the organisaion "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by!(name: org_name)
  visit admin_organisation_path(organisation)

  expect(page).to have_xpath("//th[.='Superseded by']/following-sibling::td[.='#{superseding_org_name}']")
end

Given(/^a closed organisation with documents which has been superseded by another$/) do
  @superseding_organisation  = create(:organisation)
  @organisation              = create_org_and_stub_content_store(:organisation, govuk_status: "closed", govuk_closed_status: "replaced", superseding_organisations: [@superseding_organisation])
  @organisation_speech       = create(:published_speech, organisations: [@organisation])
  @organisation_consultation = create(:published_consultation, organisations: [@organisation])
  @organisation_publication  = create(:published_publication, organisations: [@organisation])
  @organisation_statistics   = create(:published_statistics, organisations: [@organisation])
end

When(/^I view the organisation$/) do
  visit @organisation.public_path
end

Then(/^I can see that the organisation is closed$/) do
  expect(page).to have_content("#{@organisation.name} has closed")
end

Then(/^I can see that the organisation is closed and has been superseded by the other$/) do
  expect(page).to have_content("#{@organisation.name} was replaced by")
  expect(page).to have_content(@superseding_organisation.name)
end

Then(/^I can see the documents associated with that organisation$/) do
  expect(page).to have_content(@organisation_speech.title)
  expect(page).to have_content(@organisation_consultation.title)
  expect(page).to have_content(@organisation_publication.title)
  expect(page).to have_content(@organisation_statistics.title)
end
