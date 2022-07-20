When(/^I draft a new publication "([^"]*)" that does not apply to the nations:$/) do |title, nations|
  begin_drafting_publication(title, all_nation_applicability: false)
  nations.raw.flatten.each do |nation_name|
    within record_css_selector(Nation.find_by_name!(nation_name)) do
      check nation_name
      fill_in "URL of corresponding content", with: "http://www.#{nation_name}.com/"
    end
  end
  click_button "Save and continue"
  click_button "Save tagging changes"
  add_external_attachment
end

Then(/^the publication should be excluded from these nations:$/) do |nation_names|
  @new_edition = Publication.last

  expected = nation_names.raw.flatten.sort
  actual = @new_edition.nation_inapplicabilities.map(&:name).sort

  expect(expected).to eq(actual)
end
