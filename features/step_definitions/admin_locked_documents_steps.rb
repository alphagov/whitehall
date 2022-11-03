Given(/^a published locked document titled "([^"]*)"$/) do |title|
  @edition = create(:published_news_article, :with_locked_document, title:)
end

And(/^I can see that the document has been moved to Content Publisher$/) do
  within record_css_selector(@edition) do
    expect(page).to have_selector(".label-info", text: "Moved to Content Publisher")
    last_cell = find("td:last-child")
    expect(last_cell.text).to eq("Moved to Content Publisher")
  end
end
