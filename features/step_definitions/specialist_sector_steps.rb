Given(/^there are some specialist sectors$/) do
  stub_specialist_sectors
end

When(/^I start editing a draft document$/) do
  begin_drafting_publication(title: "A Specialist Publication")
end

Then(/^I can tag it to some specialist sectors$/) do
  primary_select = "edition[primary_specialist_sector_tag]"
  secondary_select = "edition[secondary_specialist_sector_tags][]"

  select "Oil and Gas: Wells", from: primary_select
  select "Oil and Gas: Offshore", from: secondary_select
  select "Oil and Gas: Fields", from: secondary_select
  select "Oil and Gas: Distillation (draft)", from: secondary_select

  click_button "Update specialist topics"

  expect(page).to have_selector("[data-track-category='flash-message']")

  click_on "Edit draft"
  check "Applies to all UK nations"
  click_on "Save and continue"
  click_on "Update and review specialist topic tags"

  expect("WELLS").to eq(find_field(primary_select).value)
  expect(%w[OFFSHORE FIELDS DISTILL].to_set)
    .to eq(find_field(secondary_select).value.to_set)
end
