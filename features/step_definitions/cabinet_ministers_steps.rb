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

And(/^I set the order of the (roles|organisations) for the "([^"]*)" ordering field to:$/) do |type, name, ordering|
  ordering.hashes.each do |hash|
    model = if type == "roles"
              Role.find_by!(name: hash[:name])
            else
              Organisation.find_by!(name: hash[:name])
            end

    fill_in "#{name}[ordering][#{model.id}]", with: hash[:order]
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
