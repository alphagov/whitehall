Given(/^there is a worldwide organisation with some offices on its home page$/) do
  @the_organisation = create(:worldwide_organisation)
  @the_main_office = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "HQ1.0")
  office1 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "Main office")
  office2 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "Summer office by the lake")
  office3 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "Emergency bunker office")
  @the_organisation.add_office_to_home_page!(office1)
  @the_organisation.add_office_to_home_page!(office2)
  @the_organisation.add_office_to_home_page!(office3)
  @the_ordered_offices = [office1, office2, office3]
end

When(/^I add a new office to be featured on the home page of the worldwide organisation$/) do
  visit admin_worldwide_organisation_path(@the_organisation)
  click_on "Offices"
  click_on "All"
  click_on "Add"

  fill_in_contact_details(feature_on_home_page: "yes")
  select WorldwideOfficeType.all.sample.name, from: "Office type"

  click_on "Save"
  @the_new_office = WorldwideOffice.last
end

When(/^I reorder the offices to highlight my new office$/) do
  visit admin_worldwide_organisation_path(@the_organisation)
  click_on "Offices"
  click_on "Order on home page"

  within "#on-home-page" do
    @the_ordered_offices = [@the_ordered_offices[-1], *@the_ordered_offices[1..-2].shuffle, @the_ordered_offices[0]]
    @the_ordered_offices.each_with_index do |office, index|
      fill_in office.title, with: index + 2
    end
    fill_in @the_new_office.title, with: 1
  end
  click_on "Update office list order"

  @the_ordered_offices = [@the_new_office, *@the_ordered_offices]
end

Then(/^I see the offices in my specified order including the new one under the main office on the home page of the worldwide organisation$/) do
  visit @the_organisation.public_path(locale: :en)

  contact_headings = all(".contact-section .gem-c-heading").map(&:text)

  expect(@the_main_office.title).to eq(contact_headings[0])
  @the_ordered_offices.each.with_index do |contact, idx|
    expect(contact.title).to eq(contact_headings[idx + 1])
  end
end

When(/^I decide that one of the offices no longer belongs on the home page$/) do
  visit admin_worldwide_organisation_path(@the_organisation)

  click_on "Offices"

  @the_removed_office = @the_ordered_offices.sample
  @the_ordered_offices.delete(@the_removed_office)
  within record_css_selector(@the_removed_office) do
    click_on "Remove from home page"
  end
end

Then(/^that office is no longer visible on the home page of the worldwide organisation$/) do
  visit @the_organisation.public_path(locale: :en)

  within ".contact-section:first-of-type" do
    expect(page).to_not have_selector("h2", text: @the_removed_office.title)
  end
end
