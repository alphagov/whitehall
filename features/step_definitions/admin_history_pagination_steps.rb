When(/^"([^"]*)" has two pages of history$/) do |title|
  @edition = Edition.find_by!(title:)
  @edition.versions.first.update!(created_at: 20.minutes.ago)

  [*1..11].each_with_index do |integer, index|
    create(:editorial_remark, edition: @edition, body: "editorial-remark-body-#{integer}", created_at: index.seconds.ago)
  end

  @ten_most_recent_remarks = @edition.editorial_remarks.order(created_at: :desc).slice(0, 9)
end

Then(/^I can see the first ten items in the History tab$/) do
  visit edit_admin_edition_path(@edition)
  click_link "History"

  @ten_most_recent_remarks.each do |editorial_remark|
    expect(page).to have_content(editorial_remark.body)
  end
  expect(all(".app-view-editions-editorial-remark__list-item").count).to eq 10
end

When(/^I click the "([^"]*)" history link$/) do |link|
  within "#history_tab" do
    # Randomly click one of the two matching links
    all("a", text: link, count: 2).sample.click
  end
end

Then(/^I can see the second page of history$/) do
  expect(page).to have_content("editorial-remark-body-11")
  expect(all(".app-view-editions-editorial-remark__list-item").count).to eq 1
end

And(/^the History tab is still showing$/) do
  expect(find(".govuk-tabs__list-item--selected").text).to eq "History"
end
