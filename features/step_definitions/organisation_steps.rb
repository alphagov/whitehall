Given /^the organisation "([^"]*)" contains some policies$/ do |name|
  editions = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:ministerial_department, name: name, editions: editions)
end

Given /^other organisations also have policies$/ do
  create(:organisation, editions: [build(:published_policy)])
  create(:organisation, editions: [build(:published_policy)])
end

Given /^the organisation "([^"]*)" exists$/ do |name|
  create(:ministerial_department, name: name)
end

Given(/^the organisation "(.*?)" exists with a featured article$/) do |name|
  org = create(:ministerial_department, name: name)
  create(:feature_list, featurable: org, features: [create(:feature, document: create(:published_news_article).document)])
end

Given /^the executive office "([^"]*)" exists$/ do |name|
  create(:executive_office, name: name)
end

Given /^two organisations "([^"]*)" and "([^"]*)" exist$/ do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given /^the "([^"]*)" organisation is associated with several ministers and civil servants$/ do |organisation_name|
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  3.times do |x|
    person = create(:person)
    ministerial_role = create(:ministerial_role, cabinet_member: (x == 1))
    organisation.ministerial_roles << ministerial_role
    create(:role_appointment, role: ministerial_role, person: person)
  end
  3.times do |x|
    person = create(:person)
    role = create(:board_member_role, permanent_secretary: (x == 1))
    organisation.roles << role
    create(:role_appointment, role: role, person: person)
  end
end

Given /^the "([^"]*)" organisation is associated with traffic commissioners$/ do |organisation_name|
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  traffic_commissioner_role = create(:traffic_commissioner_role, name: "traffic-commissioner-role", organisations: [organisation])
  create(:role_appointment, role: traffic_commissioner_role)
end

Given /^the "([^"]*)" organisation is associated with scientific advisors$/ do |organisation_name|
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  chief_scientific_advisor_role = create(:chief_scientific_advisor_role, name: "csi-role", organisations: [organisation])
  create(:role_appointment, role: chief_scientific_advisor_role)
end

Given /^the "([^"]*)" organisation is associated with chief professional officers$/ do |organisation_name|
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  chief_professional_officer_role = create(:chief_professional_officer_role, name: "cmo-role", organisations: [organisation])
  create(:role_appointment, role: chief_professional_officer_role)
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

Given /^a published publication "([^"]*)" with a PDF attachment and alternative format provider "([^"]*)"$/ do |title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  publication = create(:published_publication, :with_file_attachment, title: title, body: "!@1", organisations: [organisation], alternative_format_provider: organisation)
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given /^I set the alternative format contact email of "([^"]*)" to "([^"]*)"$/ do |organisation_name, email|
  organisation = Organisation.find_by_name!(organisation_name)
  visit edit_admin_organisation_path(organisation)
  fill_in "organisation_alternative_format_contact_email", with: email
  click_button "Save"
end

Given(/^some organisations of every type exist$/) do
  @executive_office =             create :organisation, organisation_type_key: :executive_office, govuk_status: 'live'
  @ministerial_department =       create :organisation, organisation_type_key: :ministerial_department, govuk_status: 'live'
  @non_ministerial_department_1 = create :organisation, organisation_type_key: :non_ministerial_department, govuk_status: 'live'
  @non_ministerial_department_2 = create :organisation, organisation_type_key: :non_ministerial_department, govuk_status: 'transitioning'
  @executive_agency =             create :organisation, organisation_type_key: :executive_agency
  @executive_ndpb =               create :organisation, organisation_type_key: :executive_ndpb
  @advisory_ndpb =                create :organisation, organisation_type_key: :advisory_ndpb
  @tribunal_ndpb =                create :organisation, organisation_type_key: :tribunal_ndpb
  @public_corporation =           create :organisation, organisation_type_key: :public_corporation
  @independent_monitoring_body =  create :organisation, organisation_type_key: :independent_monitoring_body
  @adhoc_advisory_group =         create :organisation, organisation_type_key: :adhoc_advisory_group
  @devolved_administration =      create :organisation, organisation_type_key: :devolved_administration, govuk_status: "exempt"
  @other_organisation =           create :organisation, organisation_type_key: :other

  @child_org_1 = create :organisation, parent_organisations: [@ministerial_department]
  @child_org_2 = create :organisation, parent_organisations: [@non_ministerial_department_2]
end

Given(/^1 live, 1 transitioning and 1 exempt executive agencies$/) do
  @live_agency =          create :organisation, organisation_type_key: :executive_agency, govuk_status: 'live'
  @transitioning_agency = create :organisation, organisation_type_key: :executive_agency, govuk_status: 'transitioning'
  @exempt_agency =        create :organisation, organisation_type_key: :executive_agency, govuk_status: 'exempt'
end

Given(/^1 live, 1 transitioning and 1 exempt non ministerial departments$/) do
  @live_agency =          create :organisation, organisation_type_key: :non_ministerial_department, govuk_status: 'live'
  @transitioning_agency = create :organisation, organisation_type_key: :non_ministerial_department, govuk_status: 'transitioning'
  @exempt_agency =        create :organisation, organisation_type_key: :non_ministerial_department, govuk_status: 'exempt'
end

Given(/^I have an offsite link "(.*?)" for the organisation "(.*?)"$/) do |title, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  @offsite_link = create :offsite_link, title: title, parent: organisation
end

When /^I add a new organisation called "([^"]*)"$/ do |organisation_name|
  create(:topic, name: 'Jazz Bizniz')
  create(:mainstream_category, title: 'Jazzy Bizzle')

  visit new_admin_organisation_path

  fill_in 'Name', with: organisation_name
  fill_in 'Acronym', with: organisation_name.split(' ').map {|word| word.chars.first }.join
  fill_in 'Logo formatted name', with: organisation_name
  select 'Ministerial department', from: 'Organisation type'
  select 'Jazz Bizniz', from: 'organisation_topic_ids_0'
  select 'Jazzy Bizzle', from: 'organisation_mainstream_category_ids_0'
  within '.top-tasks' do
    fill_in 'Title', with: 'Top task 1'
    fill_in 'Url', with: 'http://mainstream.co.uk'
  end
  click_button 'Save'
end

Then /^I should be able to see "([^"]*)" in the list of organisations$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  within record_css_selector(organisation) do
    assert page.has_content?(organisation_name)
  end
end

When /^I visit the "([^"]*)" organisation$/ do |name|
  visit_organisation name
end

When(/^I visit the organisations page$/) do
  visit organisations_path
end

When /^I feature the news article "([^"]*)" for "([^"]*)"$/ do |news_article_title, organisation_name|
  step %%I feature the news article "#{news_article_title}" for "#{organisation_name}" with image "minister-of-funk.960x640.jpg"%
end

When /^I feature the news article "([^"]*)" for "([^"]*)" with image "([^"]*)"$/ do |news_article_title, organisation_name, image_filename|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Features"
  locale = Locale.find_by_language_name("English")
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by_title(news_article_title)
  fill_in 'title', with: news_article_title.split.first
  within record_css_selector(news_article) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When /^I stop featuring the news article "([^"]*)" for "([^"]*)"$/ do |news_article_title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit features_admin_organisation_path(organisation)
  locale = Locale.find_by_language_name("English")
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by_title(news_article_title)
  within record_css_selector(news_article) do
    click_on "Unfeature"
  end
end

When /^I order the featured items in the "([^"]*)" organisation as:$/ do |name, table|
  organisation = Organisation.find_by_name!(name)
  visit features_admin_organisation_path(organisation)
  order_features_from(table)
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the organisation "(.*?)"$/) do |title, type, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit features_admin_organisation_path(organisation)
  click_link "Create an offsite link"
  fill_in :offsite_link_title, with: title
  select type, from: 'offsite_link_link_type'
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

When(/^I feature the offsite link "(.*?)" for organisation "(.*?)" with image "(.*?)"$/) do |offsite_link_title, organisation_name, image_filename|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Features"
  offsite_link = OffsiteLink.find_by_title(offsite_link_title)
  within record_css_selector(offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When /^I stop featuring the offsite link "([^"]*)" for "([^"]*)"$/ do |offsite_link_name, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit features_admin_organisation_path(organisation)
  locale = Locale.find_by_language_name("English")
  offsite_link = OffsiteLink.find_by_title(offsite_link_name)
  within record_css_selector(offsite_link) do
    click_on "Unfeature"
  end
end

When /^I delete the organisation "([^"]*)"$/ do |name|
  organisation = Organisation.find_by_name!(name)
  visit edit_admin_organisation_path(organisation)
  click_button "delete"
end

Then(/^I should see the executive offices listed$/) do
  within "#executive-offices" do
    assert page.has_link?(@executive_office.name, href: organisation_path(@executive_office))
  end
end

Then(/^I should see the ministerial departments including their sub\-organisations listed with count and number live$/) do
  within "#ministerial-departments" do
    assert page.has_link?(@ministerial_department.name, href: organisation_path(@ministerial_department))
    within "#organisation_#{@ministerial_department.id}" do
      assert page.has_link?(@child_org_1.name, href: organisation_path(@child_org_1))
    end
    within "header" do
      assert page.has_content? "1"
    end
  end
end

Then(/^I should see the non ministerial departments including their sub\-organisations listed with count$/) do
  within "#non-ministerial-departments" do
    assert page.has_link?(@non_ministerial_department_1.name, href: organisation_path(@non_ministerial_department_1))
    assert page.has_link?(@non_ministerial_department_2.name, href: organisation_path(@non_ministerial_department_2))
    within "#organisation_#{@non_ministerial_department_2.id}" do
      assert page.has_link?(@child_org_2.name, href: organisation_path(@child_org_2))
    end
    within "header" do
      assert page.has_content? "2"
    end
  end
end

Then(/^I should see the agencies and government bodies listed with count$/) do
  within "#agencies-and-government-bodies" do
    assert page.has_link?(@executive_agency.name, href: organisation_path(@executive_agency))
    assert page.has_link?(@executive_ndpb.name, href: organisation_path(@executive_ndpb))
    assert page.has_link?(@advisory_ndpb.name, href: organisation_path(@advisory_ndpb))
    assert page.has_link?(@tribunal_ndpb.name, href: organisation_path(@tribunal_ndpb))
    assert page.has_link?(@independent_monitoring_body.name, href: organisation_path(@independent_monitoring_body))
    assert page.has_link?(@adhoc_advisory_group.name, href: organisation_path(@adhoc_advisory_group))
    assert page.has_link?(@other_organisation.name, href: organisation_path(@other_organisation))
    assert page.has_link?(@child_org_1.name, href: organisation_path(@child_org_1))
    assert page.has_link?(@child_org_2.name, href: organisation_path(@child_org_2))
    within "header" do
      assert page.has_content? "9"
    end
  end
end

Then(/^I should see the public corporations listed with count$/) do
  within "#public-corporations" do
    assert page.has_link?(@public_corporation.name, href: organisation_path(@public_corporation))
    within "header" do
      assert page.has_content? "1"
    end
  end
end

Then(/^I should see the devolved administrations listed with count$/) do
  within "#devolved-administrations" do
    assert page.has_link?(@devolved_administration.name, href: organisation_path(@devolved_administration))
    within "header" do
      assert page.has_content? "1"
    end
  end
end

Then(/^I should see a transition visualisation showing 1 out of 2 agencies moved plus 1 agency$/) do
  within "#agencies-and-government-bodies .transition-state-visualisation" do
    assert page.find('.horizontal-percent-bar .bar-inner')['style'].include?("width: 50%")
    assert page.has_content? "1/2 on GOV.UK"
    assert page.has_content? "+1 not moving to GOV.UK"
  end
end

Then(/^I should see a transition visualisation showing 1 out of 2 non ministerial departments moved plus 1 not moving$/) do
  within "#non-ministerial-departments .transition-state-visualisation" do
    assert page.find('.horizontal-percent-bar .bar-inner')['style'].include?("width: 50%")
    assert page.has_content? "1/2 on GOV.UK"
    assert page.has_content? "+1 not moving to GOV.UK"
  end
end

Then(/^I should see metadata in the agency list indicating the status of each organisation which is not live$/) do
  within('#agencies-and-government-bodies') do
    assert page.has_content? "#{@transitioning_agency.name} moving to GOV.UK"
    assert page.has_content? "#{@exempt_agency.name} separate website"
  end
end

Then(/^I should see metadata in the non ministerial department list indicating the status of each organisation which is not live$/) do
  within('#non-ministerial-departments') do
    assert page.has_content? "#{@transitioning_agency.name} moving to GOV.UK"
    assert page.has_content? "#{@exempt_agency.name} separate website"
  end
end

Then /^there should not be an organisation called "([^"]*)"$/ do |name|
  refute Organisation.find_by_name(name)
end

Then /^I should be able to view all civil servants for the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  organisation.management_roles.each do |role|
    assert page.has_css?(record_css_selector(role.current_person))
  end
end

Then /^I should be able to view all ministers for the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  organisation.ministerial_roles.each do |role|
    assert page.has_css?(record_css_selector(role.current_person))
  end
end

Then /^I should be able to view all traffic commissioners for the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  organisation.traffic_commissioner_roles.each do |role|
    assert page.has_css?(record_css_selector(role.current_person))
  end
end

Then /^I should be able to view all chief professional officers for the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  organisation.chief_professional_officer_roles.each do |role|
    assert page.has_css?(record_css_selector(role.current_person))
  end
end

Then /^I should see the featured (news articles|topical events|offsite links) in the "([^"]*)" organisation are:$/ do |_, name, expected_table|
  visit_organisation name
  rows = find(featured_documents_selector).all('.feature')
  table = rows.map do |row|
    [
      row.find('h2').text.strip,
      File.basename(row.find('.featured-image')['src'])
    ]
  end
  expected_table.diff!(table)
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" organisation page$/) do |title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  offsite_link = OffsiteLink.find_by_title!(title)
  visit_organisation organisation_name
  page.has_link?(title, href: edit_admin_organisation_offsite_link_path(organisation.id, offsite_link.id))
end

Then /^there should be nothing featured on the home page of "([^"]*)"$/ do |name|
  visit_organisation name
  assert page.assert_no_selector(featured_documents_selector)
end

Then /^I should only see published policies belonging to the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  editions = records_from_elements(Edition, page.all(".document"))
  assert editions.all? { |edition| organisation.editions.published.include?(edition) }
end

def navigate_to_organisation(page_name)
  within('nav.sub_navigation') do
    click_link page_name
  end
end

Then /^I should see a mailto link for the alternative format contact email "([^"]*)"$/ do |email|
  assert page.has_css?("a[href^=\"mailto:#{email}\"]")
end

Then /^I cannot see links to Transparency data on the "([^"]*)" about page$/ do |name|
  visit_organisation_about_page name
  assert page.has_no_css?('a', text: 'Transparency data')
end

Then /^I can see a link to "([^"]*)" on the "([^"]*)" about page$/ do |link_text, name|
  visit_organisation_about_page name
  assert page.has_css?('a', text: link_text)
end

When /^I associate a Transparency data publication to the "([^"]*)"$/ do |name|
  organisation = Organisation.find_by_name!(name)
  publication = create(:published_publication, :transparency_data, organisations: [organisation])
end

When /^I add some top tasks to the organisation "([^"]*)" via the admin$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Edit"
  within ".top-tasks" do
    fill_in "Url", with: "https://www.gov.uk/mainstream/tool-alpha"
    fill_in "Title", with: "Tool Alpha"
  end
  click_button "Save"
end

Then /^the top tasks for the organisation "([^"]*)" should be visible on the public site$/ do |organisation_name|
  visit_organisation organisation_name
  within ".top-tasks" do
    assert page.has_css?("a[href='https://www.gov.uk/mainstream/tool-alpha']", "Tool Alpha")
  end
end

When /^I add some featured services and guidance to the organisation "([^"]*)" via the admin$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Edit"
  within ".featured-services-and-guidance" do
    fill_in "Url", with: "https://www.gov.uk/example/service"
    fill_in "Title", with: "Example Service"
  end
  click_button "Save"
end

Then /^the featured services and guidance for the organisation "([^"]*)" should be visible on the public site$/ do |organisation_name|
  visit_organisation organisation_name
  within ".featured-services-and-guidance" do
    assert page.has_css?("a[href='https://www.gov.uk/example/service']", "Example Service")
  end
end

Given /^an organisation "([^"]*)" has been assigned to handle fatalities$/ do |organisation_name|
  create(:organisation, name: organisation_name, handles_fatalities: true)
end

When /^I visit the organisation admin page for "([^"]*)"$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
end

When /^I add a new contact "([^"]*)" with address "([^"]*)"$/ do |contact_description, address|
  click_link "Contacts"
  click_link "Add"
  fill_in_contact_details(title: contact_description, street_address: address)
  click_button "Save"
end

When /^I edit the contact to have address "([^"]*)"$/ do |address|
  click_link "Contacts"
  within ".contact" do
    click_link "Edit"
  end
  fill_in "Street address", with: address
  click_button "Save"
end

Then /^I should see the "([^"]*)" contact in the admin interface with address "([^"]*)"$/ do |contact_description, address|
  within ".contact" do
    assert page.has_css?("h3", text: contact_description)
    assert page.has_css?(".adr .street-address", text: address)
  end
end

Given /^the organisation "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |name, native_locale_name|
  locale_code = Locale.find_by_language_name(native_locale_name).code
  create(:ministerial_department, name: name, translated_into: [locale_code])
end

When /^I add a new translation to the organisation with:$/ do |table|
  organisation = Organisation.last
  translation = table.rows_hash.stringify_keys

  visit admin_organisation_path(organisation)
  click_link "Translations"
  select translation["locale"], from: "Locale"
  click_on "Create translation"
  fill_in_organisation_translation_form(translation)
end

When /^I edit the translation for the organisation setting:$/ do |table|
  organisation = Organisation.last
  translation = table.rows_hash.stringify_keys
  visit admin_organisation_path(organisation)
  click_link "Translations"
  click_link translation["locale"]
  fill_in_organisation_translation_form(translation)
end

Then /^when I view the organisation with the locale "([^"]*)" I should see:$/ do |locale, table|
  organisation = Organisation.last
  translation = table.rows_hash

  visit organisation_path(organisation)
  click_link locale

  within record_css_selector(organisation) do
    assert page.has_css?('.organisation-logo', text: translation['logo formatted name']), 'Logo formatted name has not been translated'
  end
end

Given /^the topical event "([^"]*)" exists$/ do |name|
  TopicalEvent.create(name: name, description: "test", start_date: Date.today, end_date: Date.today + 2.months)
end

When /^I feature the topical event "([^"]*)" for "([^"]*)" with image "([^"]*)"$/ do |topic, organisation_name, image_filename|
  organisation = Organisation.find_by_name!(organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Features"
  locale = Locale.find_by_language_name("English")
  topical_event = TopicalEvent.find_by_name(topic)
  within record_css_selector(topical_event) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When /^I stop featuring the topical event "([^"]*)" for "([^"]*)"$/ do |topic, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  visit features_admin_organisation_path(organisation)
  locale = Locale.find_by_language_name("English")
  topical_event = TopicalEvent.find_by_name(topic)
  within record_css_selector(topical_event) do
    click_on "Unfeature"
  end
end

When /^I choose "([^"]*)" as a sponsoring organisation of "([^"]*)"$/ do |supporting_org_name, supported_org_name|
  supporting_organisation = Organisation.find_by_name!(supporting_org_name)
  supported_organisation = Organisation.find_by_name!(supported_org_name)

  visit admin_organisation_path(supported_organisation)
  click_on 'Edit'
  select supporting_org_name, from: 'Sponsoring organisations'
  click_on 'Save'
end

Then /^I should "([^"]*)" listed as a sponsoring organisation of "([^"]*)"$/ do |supporting_org_name, supported_org_name|
  supporting_organisation = Organisation.find_by_name!(supporting_org_name)
  supported_organisation = Organisation.find_by_name!(supported_org_name)

  ensure_path organisation_path(supported_organisation)
  within 'p.parent_organisations' do
    assert page.has_content?(supporting_org_name)
  end
end

Then /^I can see information about uk aid on the "(.*?)" page$/ do |org_name|
  org = Organisation.find_by_name!(org_name)

  visit organisation_path(org)
  assert page.has_css?('.uk-aid')
end

Then /^I can not see information about uk aid on the "(.*?)" page$/ do |org_name|
  org = Organisation.find_by_name!(org_name)

  visit organisation_path(org)
  assert page.has_no_css?('.uk-aid')
end

Given(/^an organisation and some documents exist$/) do
  @organisation = create(:ministerial_department)
  @organisation2 = create(:ministerial_department)
  @author1 = create(:departmental_editor)
  @author2 = create(:departmental_editor)
  @documents = [
    create(:published_news_article, title: "DOC1", organisations: [@organisation], creator: @author1),
    create(:published_news_article, title: "DOC2", organisations: [@organisation2], creator: @author1),
    create(:published_consultation, title: "DOC3", organisations: [@organisation2], creator: @author2)
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
    assert page.has_css?(record_css_selector(@documents[0]))
    assert page.has_no_css?(record_css_selector(@documents[1]))
    assert page.has_no_css?(record_css_selector(@documents[2]))
  end
  click_link "Reset all fields"
  within "#search_results" do
    assert page.has_css?(record_css_selector(@documents[0]))
    assert page.has_css?(record_css_selector(@documents[1]))
    assert page.has_css?(record_css_selector(@documents[2]))
  end
  select @organisation2.name, from: "organisation"
  within "#search_results" do
    assert page.has_no_css?(record_css_selector(@documents[0]))
    assert page.has_css?(record_css_selector(@documents[1]))
    assert page.has_css?(record_css_selector(@documents[2]))
  end
  select @author2.name, from: "author"
  within "#search_results" do
    assert page.has_no_css?(record_css_selector(@documents[0]))
    assert page.has_no_css?(record_css_selector(@documents[1]))
    assert page.has_css?(record_css_selector(@documents[2]))
  end
  select "News articles", from: "type"
  within "#search_results" do
    assert page.has_no_css?(record_css_selector(@documents[0]))
    assert page.has_no_css?(record_css_selector(@documents[1]))
    assert page.has_no_css?(record_css_selector(@documents[2]))
  end
end

When(/^I close the organisation "(.*?)", superseding it with the organisation "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by_name!(org_name)
  visit edit_admin_organisation_path(organisation.slug)
  select "Closed", from: "Status on GOV.UK"
  select "Replaced", from: "Reason for closure"
  select superseding_org_name, from: "Superseded by"
  click_on "Save"
end

Then(/^I can see that the organisation "(.*?)" has been superseded with the organisaion "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by_name!(org_name)
  visit admin_organisation_path(organisation)

  assert page.has_xpath?("//th[.='Superseded by']/following-sibling::td[.='#{superseding_org_name}']")
end

Given(/^a closed organisation with documents which has been superseded by another$/) do
  @superseding_organisation  = create(:organisation)
  @organisation              = create(:organisation, govuk_status: 'closed', govuk_closed_status: 'replaced', superseding_organisations: [@superseding_organisation])
  @organisation_speech       = create(:published_speech, organisations: [@organisation])
  @organisation_consultation = create(:published_consultation, organisations: [@organisation])
  @organisation_publication  = create(:published_publication, organisations: [@organisation])
  @organisation_statistics   = create(:published_statistics, organisations: [@organisation])
end

When(/^I view the organisation$/) do
  visit organisation_path(@organisation)
end

Then(/^I can see that the organisation is closed$/) do
  assert page.has_content?("#{@organisation.name} has closed")
end

Then(/^I can see that the organisation is closed and has been superseded by the other$/) do
  assert page.has_content?("#{@organisation.name} was replaced by")
  assert page.has_content?("#{@superseding_organisation.name}")
end

Then(/^I can see the documents associated with that organisation$/) do
  assert page.has_content?(@organisation_speech.title)
  assert page.has_content?(@organisation_consultation.title)
  assert page.has_content?(@organisation_publication.title)
  assert page.has_content?(@organisation_statistics.title)
end
