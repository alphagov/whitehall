Given /^there is an organisation with some contacts on its home page$/ do
  @the_organisation = create(:organisation)
  contact_1 = create(:contact, contactable: @the_organisation, title: 'Main office')
  contact_2 = create(:contact, contactable: @the_organisation, title: 'Summer office by the lake')
  contact_3 = create(:contact, contactable: @the_organisation, title: 'Emergency bunker office')
  @the_organisation.add_contact_to_home_page!(contact_1)
  @the_organisation.add_contact_to_home_page!(contact_2)
  @the_organisation.add_contact_to_home_page!(contact_3)
  @the_ordered_contacts = [contact_1, contact_2, contact_3]
end

Given /^there is a worldwide organisation with some offices on its home page$/ do
  @the_organisation = create(:worldwide_organisation)
  office_1 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Main office')
  office_2 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Summer office by the lake')
  office_3 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Emergency bunker office')
  @the_ordered_contacts = [office_1, office_2, office_3]
end

When /^I add a new contact to be featured on the home page of the organisation$/ do
  visit admin_organisation_path(@the_organisation)
  click_on 'Contacts'
  click_on 'All'
  click_on "Add"
  fill_in "Title", with: 'Our shiny new office'

  fill_in "Street address", with: "address1\naddress2"
  fill_in "Postal code", with: "12345-123"
  fill_in "Email", with: "foo@bar.com"
  fill_in "Label", with: "Main phone number"
  fill_in "Number", with: "+22 (0) 111 111-111"
  select "United Kingdom", from: "Country"
  choose "yes"
  click_on "Save"
  @the_new_contact = Contact.last
end

When /^I reorder the contacts to highlight my new contact$/ do
  pending
end

Then /^I see the contacts in my specified order including the new one on the home page of the organisation$/ do
  visit organisation_path(@the_organisation)
  
  within '.contact-us' do
    @the_ordered_contacts.each.with_index do |contact, idx|
      assert page.has_css?("div.contact:nth-child(#{idx+1}) h2", text: contact.title)
    end
  end
end

When /^I decide that one of the contacts no longer belongs on the home page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that contact is no longer visible on the home page of the organisation$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I add a new office to be featured on the home page of the worldwide organisation$/ do
  visit admin_worldwide_organisation_path(@the_organisation)
  click_on 'Offices'
  click_on 'All'
  click_on "Add"
  fill_in "Title", with: 'Our shiny new office'
  select WorldwideOfficeType.all.sample.name, from: 'Office type'

  fill_in "Street address", with: "address1\naddress2"
  fill_in "Postal code", with: "12345-123"
  fill_in "Email", with: "foo@bar.com"
  fill_in "Label", with: "Main phone number"
  fill_in "Number", with: "+22 (0) 111 111-111"
  select "United Kingdom", from: "Country"
  pending
  click_on "Save"
  @the_new_office = WorldwideOffice.last
end

When /^I reorder the offices to highlight my new office$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see the offices in my specified order including the new one on the home page of the worldwide organisation$/ do
  visit worldwide_organisation_path(@the_organisation)
  
  within '.org-contacts' do
    @the_ordered_contacts.each.with_index do |contact, idx|
      assert page.has_css?("div.contact:nth-child(#{idx+1}) h2", text: contact.title)
    end
  end
end

When /^I decide that one of the offices no longer belongs on the home page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that office is no longer visible on the home page of the worldwide organisation$/ do
  pending # express the regexp above with the code you wish you had
end
