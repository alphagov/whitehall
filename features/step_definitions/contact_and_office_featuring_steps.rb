Given(/^there is a worldwide organisation with some offices on its home page$/) do
  @the_organisation = create(:worldwide_organisation)
  @the_main_office = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "HQ1.0")
  office1 = create(:worldwide_office, worldwide_organisation: @the_organisation, title: "The main office")
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

When(/^I decide that one of the offices no longer belongs on the home page$/) do
  visit admin_worldwide_organisation_path(@the_organisation)

  click_on "Offices"

  @the_removed_office = @the_ordered_offices.sample

  if using_design_system?
    click_link "Edit #{@the_removed_office.title}"
    choose "No"
    click_on "Save"
  else
    @the_ordered_offices.delete(@the_removed_office)
    within record_css_selector(@the_removed_office) do
      click_on "Remove from home page"
    end
  end
end

Then(/^that office is marked as no longer visible on the home page of the worldwide organisation$/) do
  visit admin_worldwide_organisation_path(@the_organisation)

  click_on "Offices"

  if using_design_system?
    summary_card = find(".govuk-summary-card__title", text: @the_removed_office.title).ancestor(".app-vc-worldwide-offices-index-office-summary-card-component")

    within summary_card do
      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "On homepage"
      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "No"
    end
  else
    removed_office_card = find("h3", text: @the_removed_office.title).ancestor("div.worldwide_office")
    within removed_office_card do
      row_index = find("dt", text: "On home page?").path.scan(/\d+/).last.to_i - 1
      description = all("dd")[row_index]

      expect(description.text).to eq "No"
    end
  end
end
