Given(/^reshuffle mode is (on|off)$/) do |on_or_off|
  create(:sitewide_setting, key: :minister_reshuffle_mode, on: on_or_off == "on")
end

When(/^I visit the Cabinet ministers order page$/) do
  visit admin_cabinet_ministers_path
end

Then(/^I should see a preview link to the ministers index page$/) do
  expect(page).to have_selector(".govuk-link[data-track-action=ministers-index-page-button]")
end

Then(/^I should not see a preview link to the ministers index page$/) do
  expect(page).to_not have_selector(".govuk-link[data-track-action=ministers-index-page-button]")
end

Given(/^there are multiple Cabinet minister roles with active appointments$/) do
  organisation = create(:organisation)
  person = create(:person, forename: "Tony")
  minister_role1 = create(:ministerial_role, name: "Role 1", cabinet_member: true, organisations: [organisation], seniority: 0)
  minister_role2 = create(:ministerial_role, name: "Role 2", cabinet_member: true, organisations: [organisation], seniority: 1)
  create(:role_appointment, role: minister_role1, person:)
  create(:role_appointment, role: minister_role2, person:)
end

When(/^I click the reorder link in the "([^"]*)" tab$/) do |tab|
  within tab do
    click_link "Reorder list"
  end
end

And(/^I set the order of the (roles|organisations) to:$/) do |type, ordering|
  ordering.hashes.each do |hash|
    if type == "roles"
      role = Role.find_by!(name: hash[:name])
      fill_in "ministerial_roles[ordering][#{role.id}]", with: hash[:order]
    else
      organisation = Organisation.find_by!(name: hash[:name])
      fill_in "ministerial_organisations[ordering][#{organisation.id}]", with: hash[:order]
    end
  end

  click_button "Update order"
end

Then(/^the (roles|organisations) in the "([^"]*)" tab should be in the following order:$/) do |type, tab, role_names|
  name = all("#{tab} .govuk-table__row .govuk-table__cell:first").map(&:text)

  role_names.hashes.each_with_index do |hash, index|
    model = if type == "roles"
              Role.find_by!(name: hash[:name])
            else
              Organisation.find_by!(name: hash[:name])
            end

    expect(model.name).to eq name[index]
  end
end

Given(/^there are multiple Also attends cabinet roles$/) do
  organisation = create(:organisation)
  create(:ministerial_role, name: "Role 1", attends_cabinet_type_id: 2, organisations: [organisation], seniority: 1)
  create(:ministerial_role, name: "Role 2", attends_cabinet_type_id: 1, organisations: [organisation], seniority: 0)
end

Given(/^there are multiple Whip roles$/) do
  organisation = create(:organisation)
  create(:ministerial_role, name: "Role 1", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 1)
  create(:ministerial_role, name: "Role 2", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 0)
end

Given(/^there are multiple organisations with ministerial ordering$/) do
  create(:ministerial_department, ministerial_ordering: 1, name: "Org 1")
  create(:ministerial_department, ministerial_ordering: 0, name: "Org 2")
end
