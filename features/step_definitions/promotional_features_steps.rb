Given(/^the executive office organisation "([^"]*)" exists$/) do |organisation_name|
  @executive_office = create_org_and_stub_content_store(:executive_office, name: organisation_name)
end

Given(/^the executive office has a promotional feature with an item$/) do
  @promotional_item = create_feature_item_for(@executive_office)
  @promotional_feature = @promotional_item.promotional_feature
end

Given(/^the executive office has a promotional feature with the maximum number of items$/) do
  @promotional_feature = create_feature_item_for(@executive_office).promotional_feature
  create(:promotional_feature_item, promotional_feature: @promotional_feature)
  create(:promotional_feature_item, promotional_feature: @promotional_feature)
end

When(/^I view the promotional feature$/) do
  visit admin_organisation_promotional_feature_url(@executive_office, @promotional_feature)
end

When(/^I add a new promotional feature with a single item which has an image$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  click_link "New promotional feature"
  if using_design_system?
    fill_in "Feature title (required)", with: "Big Cheese"
    fill_in "Summary (required)", with: "The Big Cheese is coming."
    fill_in "Item title", with: "The Big Cheese"
    fill_in "Item title url", with: "http://big-cheese.co"
    attach_file :image, Rails.root.join("test/fixtures/big-cheese.960x640.jpg")
    fill_in "Image description", with: "The Big Cheese"
    fill_in "URL", with: "http://test.com"
    fill_in "Text", with: "someText"
  else
    fill_in "Feature title", with: "Big Cheese"

    within "form.promotional_feature_item" do
      fill_in "Summary", with: "The Big Cheese is coming."
      fill_in "Item title (optional)", with: "The Big Cheese"
      fill_in "Item title url (optional)", with: "http://big-cheese.co"
      attach_file :image, Rails.root.join("test/fixtures/big-cheese.960x640.jpg")
      fill_in "Image description (alt text)", with: "The Big Cheese"
      fill_in "Url", with: "http://test.com"
      fill_in "Text", with: "someText"
    end
  end

  click_button "Save"
end

When(/^I add a new promotional feature with a single item which has a YouTube URL$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  click_link "New promotional feature"

  if using_design_system?
    fill_in "Feature title (required)", with: "Big Cheese"
    fill_in "Summary (required)", with: "The Big Cheese is coming."
    fill_in "Item title", with: "The Big Cheese"
    fill_in "Item title url", with: "http://big-cheese.co"
    choose "YouTube video"
    fill_in "YouTube video URL (required)", with: "https://www.youtube.com/watch?v=fFmDQn9Lbl4"
    fill_in "YouTube description (required)", with: "Description of video."
    fill_in "Image description", with: "The Big Cheese"
    fill_in "URL", with: "http://test.com"
    fill_in "Text", with: "someText"
  else
    fill_in "Feature title", with: "Big Cheese"

    within "form.promotional_feature_item" do
      fill_in "Summary", with: "The Big Cheese is coming."
      fill_in "Item title (optional)", with: "The Big Cheese"
      fill_in "Item title url (optional)", with: "http://big-cheese.co"
      choose "YouTube video"
      fill_in "YouTube video URL", with: "https://www.youtube.com/watch?v=fFmDQn9Lbl4"
      fill_in "YouTube video description (alt text)", with: "Description of video."
      fill_in "Url", with: "http://test.com"
      fill_in "Text", with: "someText"
    end
  end

  click_button "Save"
end

When(/^I delete the promotional feature$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"

  if using_design_system?
    click_link "Delete #{@promotional_feature.title}"
  else
    within record_css_selector(@promotional_feature) do
      click_link "Delete"
    end
  end
  click_button "Delete"
end

When(/^I edit the promotional item, set the summary to "([^"]*)"$/) do |new_summary|
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  if using_design_system?
    click_link "View #{@promotional_feature.title}"
    click_link "Edit"
  else
    click_link @promotional_feature.title
    within record_css_selector(@promotional_item) do
      click_link "Edit"
    end
  end
  fill_in "Summary", with: new_summary
  attach_file :image, Rails.root.join("test/fixtures/big-cheese.960x640.jpg")
  click_button "Save"
end

When(/^I delete the promotional item$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  if using_design_system?
    click_link "View #{@promotional_feature.title}"
    click_link "Delete"
  else
    click_link @promotional_feature.title
    within record_css_selector(@promotional_feature) do
      click_link "Delete"
    end
  end

  click_button "Delete"
end

Then(/^I should see the promotional feature on the organisation's page$/) do
  promotional_feature = @executive_office.reload.promotional_features.first
  item = promotional_feature.items.first
  expect(current_url).to eq(admin_organisation_promotional_feature_url(@executive_office, promotional_feature))

  if using_design_system?
    expect(page).to have_selector("h1", text: promotional_feature.title)
    within ".govuk-summary-card__content" do
      expect(all(".govuk-summary-list__row")[0]).to have_selector("dd", text: item.title)
      expect(all(".govuk-summary-list__row")[1].find(".govuk-summary-list__actions")).to have_link("View", href: item.title_url)
      expect(all(".govuk-summary-list__row")[2]).to have_selector("dd", text: item.summary)
      if item.image.present?
        expect(all(".govuk-summary-list__row")[3].find(".govuk-summary-list__value")).to have_selector("img[src='#{item.image.s300.url}']")
        expect(all(".govuk-summary-list__row")[4]).to have_selector("dd", text: item.image_alt_text)
      end
      if item.youtube_video_url.present?
        expect(all(".govuk-summary-list__row")[3].find(".govuk-summary-list__actions")).to have_link("View", href: item.youtube_video_url)
        expect(all(".govuk-summary-list__row")[4]).to have_selector("dd", text: item.youtube_video_alt_text)
      end
      expect(all(".govuk-summary-list__row")[5].find(".govuk-summary-list__actions")).to have_link("View", href: item.links.first.url)
      expect(all(".govuk-summary-list__row")[5]).to have_selector("dd", text: item.links.first.text)
    end
  else
    within record_css_selector(promotional_feature) do
      expect(page).to have_selector("h1", text: promotional_feature.title)
      within record_css_selector(item) do
        expect(page).to have_content(item.summary)
        expect(page).to have_link(item.title, href: item.title_url)
        expect(page).to have_selector("img[src='#{item.image.s300.url}'][alt='#{item.image_alt_text}']") if item.image.present?
        expect(page).to have_selector("a[href='#{item.youtube_video_url}']") if item.youtube_video_url.present?
      end
    end
  end
end

Then(/^I should no longer see the promotional feature$/) do
  expect(current_url).to eq(admin_organisation_promotional_features_url(@executive_office))
  expect(page).to_not have_selector(record_css_selector(@promotional_feature))
end

Then(/^I should see the promotional feature item's summary has been updated to "([^"]*)"$/) do |summary_text|
  expect(current_url).to eq(admin_organisation_promotional_feature_url(@executive_office, @promotional_feature))
  if using_design_system?
    expect(page).to have_selector("dd", text: summary_text)
  else
    within record_css_selector(@promotional_item) do
      expect(page).to have_selector("p", text: summary_text)
    end
  end
end

Then(/^I should no longer see the promotional item$/) do
  expect(page).to_not have_selector("h2", text: @promotional_feature.title)
end

Then(/^I should not be able to add any further feature items$/) do
  expect(page).to_not have_link("Add feature item")
end

And(/^the executive office has the promotional feature "([^"]*)"$/) do |title|
  @executive_office.promotional_features.create!(title:)
end

When(/^I set the order of the promotional features to:$/) do |promotional_feature_order|
  visit admin_organisation_promotional_features_path(@executive_office)
  click_link "Reorder promotional features"

  promotional_feature_order.hashes.each do |promotional_feature_info|
    promotional_feature = PromotionalFeature.find_by(title: promotional_feature_info[:title])
    fill_in "ordering[#{promotional_feature.id}]", with: promotional_feature_info[:order]
  end
  click_button "Save"
end

Then(/^the promotional features should be in the following order:$/) do |promotional_feature_list|
  promotion_feature_ids = all("table td:first").map(&:text)

  promotional_feature_list.hashes.each_with_index do |feature_info, index|
    promotional_feature = PromotionalFeature.find_by(title: feature_info[:title])
    expect(promotional_feature.title.to_s).to eq(promotion_feature_ids[index])
  end
end
