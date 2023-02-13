When(/^"([^"]*)" has lots of history and internal notes$/) do |title|
  @edition = Edition.find_by!(title:)
  Timecop.travel 1.minute.from_now
  15.times do |i|
    @edition.update!(body: "body #{i}")
    Timecop.travel 1.minute.from_now
    create(:editorial_remark, edition: @edition, body: "editorial-remark-body-#{i}")
    Timecop.travel 1.minute.from_now
  end
end

When(/^I click the "([^"]*)" tab$/) do |tab_name|
  click_link tab_name, class: "govuk-tabs__tab"
end

When(/^I click the "([^"]*)" history link$/) do |link|
  within("#history_tab") do |history_tab|
    # Randomly click one of the two matching links
    all("a", text: link, count: 2).sample.click

    # Wait for Ajax to complete
    wait_for_change_to history_tab if running_javascript?
  end
end

When(/^I set the filter to show "([^"]*)"$/) do |filter_option|
  within("#history_tab") do |history_tab|
    select filter_option

    if running_javascript?
      # JavaScript auto-updates page via Ajax
      wait_for_change_to history_tab
    else
      click_button "Filter"
    end
  end
end

Then(/^I can see the ten most recent timeline entries$/) do
  expect(rendered_history_items.count).to eq 10
  expect(rendered_history_items).to eq [
    "editorial-remark-body-14",
    "Document updated",
    "editorial-remark-body-13",
    "Document updated",
    "editorial-remark-body-12",
    "Document updated",
    "editorial-remark-body-11",
    "Document updated",
    "editorial-remark-body-10",
    "Document updated",
  ]
end

Then(/^I can see the second page of timeline entries$/) do
  expect(rendered_history_items.count).to eq 10
  expect(rendered_history_items).to eq [
    "editorial-remark-body-9",
    "Document updated",
    "editorial-remark-body-8",
    "Document updated",
    "editorial-remark-body-7",
    "Document updated",
    "editorial-remark-body-6",
    "Document updated",
    "editorial-remark-body-5",
    "Document updated",
  ]
end

Then(/I can only see the history$/) do
  expect(rendered_history_items).to eq ["Document updated"] * 10
end

Then(/^I can only see the internal notes$/) do
  expect(rendered_history_items.count).to eq 10
  expect(rendered_history_items).to eq %w[
    editorial-remark-body-14
    editorial-remark-body-13
    editorial-remark-body-12
    editorial-remark-body-11
    editorial-remark-body-10
    editorial-remark-body-9
    editorial-remark-body-8
    editorial-remark-body-7
    editorial-remark-body-6
    editorial-remark-body-5
  ]
end

Then(/I can see the second page of internal notes$/) do
  expect(rendered_history_items.count).to eq 5
  expect(rendered_history_items).to eq %w[
    editorial-remark-body-4
    editorial-remark-body-3
    editorial-remark-body-2
    editorial-remark-body-1
    editorial-remark-body-0
  ]
end

def rendered_history_items
  within "#history_tab" do
    items = all(".app-view-editions__current-edition-entries li")

    items.map do |entry|
      action = entry.find("h4").text.strip
      detail = entry.find("h4 + p").text.strip
      action == "Internal note" ? detail : action
    end
  end
end
