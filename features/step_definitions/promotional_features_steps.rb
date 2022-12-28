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

  fill_in "Feature title", with: "Big Cheese"

  within "form.promotional_feature_item" do
    fill_in "Summary",                      with: "The Big Cheese is coming."
    fill_in "Item title (optional)",        with: "The Big Cheese"
    fill_in "Item title url (optional)",    with: "http://big-cheese.co"
    attach_file :image, Rails.root.join("test/fixtures/big-cheese.960x640.jpg")
    fill_in "Image description (alt text)", with: "The Big Cheese"
  end

  click_button "Save"
end

When(/^I add a new promotional feature with a single item which has a YouTube URL$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  click_link "New promotional feature"

  fill_in "Feature title", with: "Big Cheese"

  within "form.promotional_feature_item" do
    fill_in "Summary",                      with: "The Big Cheese is coming."
    fill_in "Item title (optional)",        with: "The Big Cheese"
    fill_in "Item title url (optional)",    with: "http://big-cheese.co"
    choose "YouTube video"
    fill_in "YouTube video URL", with: "https://www.youtube.com/watch?v=fFmDQn9Lbl4"
  end

  click_button "Save"
end

When(/^I delete the promotional feature$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"

  within record_css_selector(@promotional_feature) do
    click_button "Delete"
  end
end

When(/^I edit the promotional item, set the summary to "([^"]*)"$/) do |new_summary|
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  click_link @promotional_feature.title
  within record_css_selector(@promotional_item) do
    click_link "Edit"
  end
  fill_in "Summary", with: new_summary
  click_button "Save"
end

When(/^I delete the promotional item$/) do
  visit admin_organisation_path(@executive_office)
  click_link "Promotional features"
  click_link @promotional_feature.title

  within record_css_selector(@promotional_item) do
    click_button "Delete"
  end
end

Then(/^I should see the promotional feature on the organisation's page$/) do
  promotional_feature = @executive_office.reload.promotional_features.first
  expect(current_url).to eq(admin_organisation_promotional_feature_url(@executive_office, promotional_feature))

  within record_css_selector(promotional_feature) do
    expect(page).to have_selector("h1", text: promotional_feature.title)

    item = promotional_feature.items.first
    within record_css_selector(item) do
      expect(page).to have_content(item.summary)
      expect(page).to have_link(item.title, href: item.title_url)
      expect(page).to have_selector("img[src='#{item.image.s300.url}'][alt='#{item.image_alt_text}']") if item.image.present?
      expect(page).to have_selector("a[href='#{item.youtube_video_url}']") if item.youtube_video_url.present?
    end
  end
end

Then(/^I should no longer see the promotional feature$/) do
  expect(current_url).to eq(admin_organisation_promotional_features_url(@executive_office))
  expect(page).to_not have_selector(record_css_selector(@promotional_feature))
end

Then(/^I should see the promotional feature item's summary has been updated to "([^"]*)"$/) do |summary_text|
  expect(current_url).to eq(admin_organisation_promotional_feature_url(@executive_office, @promotional_feature))

  within record_css_selector(@promotional_item) do
    expect(page).to have_selector("p", text: summary_text)
  end
end

Then(/^I should no longer see the promotional item$/) do
  within record_css_selector(@promotional_feature) do
    expect(page).to_not have_selector(record_css_selector(@promotional_item))
  end
end

Then(/^I should not be able to add any further feature items$/) do
  expect(page).to_not have_link("Add feature item")
end

Then(/^I should see the promotional feature on the executive office page$/) do
  visit @executive_office.public_path

  within record_css_selector(@executive_office) do
    within "section.features" do
      expect(page).to have_selector(".promotional_feature h2", text: @promotional_feature.title)

      within record_css_selector(@promotional_feature) do
        @promotional_feature.items.each do |item|
          expect(page).to have_content(item.summary)
          expect(page).to have_selector("img[src='#{item.image.s300.url}'][alt='#{item.image_alt_text}']")
        end
      end
    end
  end
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
  promotion_feature_ids = all(".promotional_feature").map { |element| element[:id] }

  promotional_feature_list.hashes.each_with_index do |feature_info, index|
    promotional_feature = PromotionalFeature.find_by(title: feature_info[:title])
    expect("promotional_feature_#{promotional_feature.id}").to eq(promotion_feature_ids[index])
  end
end
