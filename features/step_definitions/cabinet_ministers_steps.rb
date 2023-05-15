Given(/^there are multiple Cabinet minister roles$/) do
  organisation = create(:organisation)
  create(:ministerial_role, name: "Role 1", cabinet_member: true, organisations: [organisation], seniority: 0)
  create(:ministerial_role, name: "Role 2", cabinet_member: true, organisations: [organisation], seniority: 1)
end

When(/^I visit the Cabinet ministers order page$/) do
  visit admin_cabinet_ministers_path
end

When(/^I click the reorder link in the "([^"]*)" tab$/) do |tab|
  within tab do
    click_link "Reorder list"
  end
end

And(/^I set the order of the roles for the "([^"]*)" ordering field to:$/) do |name, ordering|
  ordering.hashes.each do |hash|
    role = Role.find_by!(name: hash[:name])
    fill_in "#{name}[ordering][#{role.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the roles in the "([^"]*)" tab should be in the following order:$/) do |tab, role_names|
  name = all("#{tab} .govuk-table__row .govuk-table__cell:first").map(&:text)

  role_names.hashes.each_with_index do |hash, index|
    role = Role.find_by!(name: hash[:name])
    expect(role.name).to eq name[index]
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
