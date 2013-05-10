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
  @the_main_office = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'HQ1.0')
  office_1 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Main office')
  office_2 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Summer office by the lake')
  office_3 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: 'Emergency bunker office')
  @the_organisation.add_office_to_home_page!(office_1)
  @the_organisation.add_office_to_home_page!(office_2)
  @the_organisation.add_office_to_home_page!(office_3)
  @the_ordered_offices = [office_1, office_2, office_3]
end

When /^I add a new contact to be featured on the home page of the organisation$/ do
  visit admin_organisation_path(@the_organisation)
  click_on 'Contacts'
  click_on 'All'
  click_on "Add"
  fill_in_contact_details(feature_on_home_page: 'yes')
  click_on "Save"
  @the_new_contact = Contact.last
end

When /^I reorder the contacts to highlight my new contact$/ do
  visit admin_organisation_path(@the_organisation)
  click_on 'Contacts'
  click_on 'Order on home page'

  within '#on-home-page' do
    @the_ordered_contacts = [@the_ordered_contacts[-1], *(@the_ordered_contacts[1..-2].shuffle), @the_ordered_contacts[0]]
    @the_ordered_contacts.each_with_index do |contact, index|
      fill_in contact.title, with: index + 2
    end
    fill_in @the_new_contact.title, with: 1
  end
  click_on 'Update contact list order'

  @the_ordered_contacts = [@the_new_contact, *@the_ordered_contacts]
end

Then /^I see the contacts in my specified order including the new one on the home page of the organisation$/ do
  visit organisation_path(@the_organisation)

  within '.addresses' do
    @the_ordered_contacts.each.with_index do |contact, idx|
      assert page.has_css?("div.contact:nth-child(#{idx+1}) h2", text: contact.title)
    end
  end
end

When /^I decide that one of the contacts no longer belongs on the home page$/ do
  visit admin_organisation_path(@the_organisation)

  click_on 'Contacts'

  @the_removed_contact = @the_ordered_contacts.sample
  @the_ordered_contacts.delete(@the_removed_contact)
  within record_css_selector(@the_removed_contact) do
    click_on 'Remove from home page'
  end
end

Then /^that contact is no longer visible on the home page of the organisation$/ do
  visit organisation_path(@the_organisation)

  within '.addresses' do
    refute page.has_css?("div.contact h2", text: @the_removed_contact.title)
  end
end

When /^I add a new office to be featured on the home page of the worldwide organisation$/ do
  visit admin_worldwide_organisation_path(@the_organisation)
  click_on 'Offices'
  click_on 'All'
  click_on "Add"

  fill_in_contact_details(feature_on_home_page: 'yes')
  select WorldwideOfficeType.all.sample.name, from: 'Office type'

  click_on "Save"
  @the_new_office = WorldwideOffice.last
end

When /^I reorder the offices to highlight my new office$/ do
  visit admin_worldwide_organisation_path(@the_organisation)
  click_on 'Offices'
  click_on 'Order on home page'

  within '#on-home-page' do
    @the_ordered_offices = [@the_ordered_offices[-1], *(@the_ordered_offices[1..-2].shuffle), @the_ordered_offices[0]]
    @the_ordered_offices.each_with_index do |office, index|
      fill_in office.title, with: index + 2
    end
    fill_in @the_new_office.title, with: 1
  end
  click_on 'Update office list order'

  @the_ordered_offices = [@the_new_office, *@the_ordered_offices]
end

Then /^I see the offices in my specified order including the new one under the main office on the home page of the worldwide organisation$/ do
  visit worldwide_organisation_path(@the_organisation)

  within '.contact-us' do
    assert page.has_css?("div.contact:nth-child(1) h2", text: @the_main_office.title)
    @the_ordered_offices.each.with_index do |contact, idx|
      assert page.has_css?("div.contact:nth-child(#{idx+2}) h2", text: contact.title)
    end
  end
end

When /^I decide that one of the offices no longer belongs on the home page$/ do
  visit admin_worldwide_organisation_path(@the_organisation)

  click_on 'Offices'

  @the_removed_office = @the_ordered_offices.sample
  @the_ordered_offices.delete(@the_removed_office)
  within record_css_selector(@the_removed_office) do
    click_on 'Remove from home page'
  end
end

Then /^that office is no longer visible on the home page of the worldwide organisation$/ do
  visit worldwide_organisation_path(@the_organisation)

  within '.contact-us' do
    refute page.has_css?("div.contact h2", text: @the_removed_office.title)
  end
end

When /^I add a new FOI contact to the organisation without adding it to the list of contacts for the home page$/ do
  visit admin_organisation_path(@the_organisation)
  click_on 'Contacts'
  click_on 'All'
  click_on "Add"
  fill_in_contact_details(
    title: 'Our FOI contact',
    feature_on_home_page: nil,
    contact_type: ContactType::FOI.name
  )
  click_on "Save"
  @the_new_foi_contact = Contact.last
end

Then /^I cannot add or reorder the new FOI contact in the home page list$/ do
  visit admin_organisation_path(@the_organisation)

  click_on 'Contacts'
  click_on 'All'

  within record_css_selector(@the_new_foi_contact) do
    refute page.has_button?('Add to home page')
    refute page.has_button?('Remove from home page')
  end

  click_on 'Order on home page'

  refute page.has_field?("ordering[#{@the_new_foi_contact.id}]")
end

Then /^I see the new FOI contact listed on the home page(?: only once,)? in the FOI section$/ do
  visit organisation_path(@the_organisation)

  within '#org-contacts + .org-contacts' do
    refute page.has_css?("div.contact h2", text: @the_new_foi_contact.title)
  end

  within '#foi-contacts .org-contacts' do
    assert page.has_css?("div.contact h2", text: @the_new_foi_contact.title)
  end
end
