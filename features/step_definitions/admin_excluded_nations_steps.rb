When(/^I draft a new publication "([^"]*)" that does not apply to the nations:$/) do |title, nations|
  begin_drafting_publication(title)
  nations.raw.flatten.each do |nation_name|
    within record_css_selector(Nation.find_by_name!(nation_name)) do
      check nation_name
      fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
    end
  end
  click_button "Save"
  add_external_attachment
end

Then(/^the publication should be excluded from these nations:$/) do |nation_names|
  @new_edition = Publication.last

  expected = nation_names.raw.flatten.sort
  actual = @new_edition.nation_inapplicabilities.map(&:name).sort

  assert_equal expected, actual
end
