Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = find_or_create_ministerial_role(row["Ministerial Role"])
    create(:role_appointment, role: ministerial_role, person: person)
  end
end

Given /^"([^"]*)" used to be the "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 3.years.ago => 2.years.ago)
end

Given /^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago)
end

Given /^"([^"]*)" is the "([^"]*)" for the "([^"]*)" and also attends cabinet$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago, role_options: {attends_cabinet_type_id: 1})
end

Given /^the role "([^"]*)" has the responsibilities "([^"]*)"$/ do |role_name, responsibilities|
  ministerial_role = find_or_create_ministerial_role(role_name)
  ministerial_role.responsibilities = responsibilities
  ministerial_role.save!
end

When /^I visit the minister page for "([^"]*)"$/ do |name|
  visit ministers_page
  click_link name
end

When /^I visit the ministers page$/ do
  visit ministers_page
end

Then /^I should see that "([^"]*)" is a minister in the "([^"]*)"$/ do |minister_name, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  within record_css_selector(organisation) do
    assert page.has_css?('.current-appointee', text: minister_name)
  end
end

Then /^I should see that "([^"]*)" is a minister in the "([^"]*)" with role "([^"]*)"$/ do |minister_name, organisation_name, role|
  organisation = Organisation.find_by_name!(organisation_name)
  within record_css_selector(organisation) do
    assert page.has_css?('.current-appointee', text: minister_name)
    assert page.has_css?('.role', text: role)
  end
end

Then /^I should see that the minister is associated with the "([^"]*)"$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  assert page.has_css?(record_css_selector(organisation)), "organisation was missing"
end

Then /^I should see that the minister has responsibilities "([^"]*)"$/ do |responsibilities|
  assert page.has_css?(".responsibilities", text: responsibilities)
end

When /^there is a reshuffle and "([^"]*)" is now "([^"]*)"$/ do |person_name, ministerial_role|
  person = find_or_create_person(person_name)
  role = MinisterialRole.find_by_name(ministerial_role)
  create(:role_appointment, role: role, person: person, make_current: true)
end

Given /^"([^"]*)" is a commons whip "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago,
    role_options: {whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseOfCommons.id})
end

Then /^I should see that "([^"]*)" is a commons whip "([^"]*)"$/ do |minister_name, role_title|
  within record_css_selector(Whitehall::WhipOrganisation::WhipsHouseOfCommons) do
    assert page.has_css?('.current-appointee', text: minister_name)
    assert page.has_css?('.role', text: role_title)
  end
end

Then /^I should see that "([^"]*)" also attends cabinet$/ do |minister_name|
  within "#also-attends-cabinet" do
    assert page.has_css?('.current-appointee', text: minister_name)
  end
end

Given /^two cabinet ministers "([^"]*)" and "([^"]*)"$/ do |person1, person2|
  create(:role_appointment, person: create(:person, forename: person1), role: create(:ministerial_role, cabinet_member: true))
  create(:role_appointment, person: create(:person, forename: person2), role: create(:ministerial_role, cabinet_member: true))
end

Given /^two whips "([^"]*)" and "([^"]*)"$/ do |person1, person2|
  whip_organisation_id = Whitehall::WhipOrganisation::WhipsHouseOfCommons.id
  create(:role_appointment,
         person: create(:person, forename: person1),
         role: create(:ministerial_role, whip_organisation_id: whip_organisation_id, cabinet_member: false))
  create(:role_appointment,
         person: create(:person, forename: person2),
         role: create(:ministerial_role, whip_organisation_id: whip_organisation_id, cabinet_member: false))
end

When /^I order the (?:cabinet ministers|whips) "([^"]*)", "([^"]*)"$/ do |role1, role2|
  visit admin_cabinet_ministers_path
  [role1, role2].each_with_index do |role, index|
    fill_in(role, with: index)
  end
  click_button "Save"
end

Then /^I should see "([^"]*)", "([^"]*)" in that order on the ministers page$/ do |person1, person2|
  visit ministers_page
  actual = all(".person .current-appointee").map {|elem| elem.text}
  assert_equal [person1, person2], actual
end

Then /^I should see "([^"]*)", "([^"]*)" in that order on the whips section of the ministers page$/ do |person1, person2|
  visit ministers_page
  actual = all(".whips .current-appointee").map {|elem| elem.text}
  assert_equal [person1, person2], actual
end

Given /^there are some ministers for the "([^"]*)"$/ do |organisation_name|
  aaron = create_role_appointment('Aaron A. Aadrvark', "Minister of The Start Of The Alphabet", organisation_name, 2.years.ago)
  marion = create_role_appointment('Marion M. Myddleton', "Minister of The Middle Of The Alphabet", organisation_name, 2.years.ago)
  zeke = create_role_appointment('Zeke Z. Zaltzman', "Minister of The End Of The Alphabet", organisation_name, 2.years.ago)
  onezero = create_role_appointment('10101010', "Minister of Numbers", organisation_name, 2.years.ago)
  @the_ministers = [aaron, marion, zeke, onezero]
  @the_ministerial_organisation = Organisation.find_by_name(organisation_name)
end

When /^I specify an order for those ministers$/ do
  visit people_admin_organisation_path(@the_ministerial_organisation)
  # .shuffle on it's own isn't enough to guarantee a new ordering, so we
  # swap the first and last, and shuffle the middle
  @the_ordered_ministers = [@the_ministers[-1], *(@the_ministers[1..-2].shuffle), @the_ministers[0]]
  @the_ordered_ministers.each_with_index do |role_appointment, index|
    fill_in "#{role_appointment.role.name}#{role_appointment.person.name}", with: index
  end
  click_on 'Save'
end

Then /^I should see that ordering displayed on the organisation page$/ do
  visit organisation_path(@the_ministerial_organisation)
  within '#ministers' do
    @the_ordered_ministers.each.with_index do |role_appointment, idx|
      assert page.has_css?("li:nth-child(#{idx + 1}) h3", text: role_appointment.person.name)
    end
  end
end

Then /^I should see that ordering displayed on the section for the organisation on the ministers page$/ do
  visit ministers_page
  within "#organisation_#{@the_ministerial_organisation.id} .minister-list" do
    @the_ordered_ministers.each.with_index do |role_appointment, idx|
      assert page.has_css?("li:nth-child(#{idx + 1}) h4", text: role_appointment.person.name)
    end
  end
end
