Given /^the executive office organisation "([^"]*)" exists$/ do |organisation_name|
  @executive_office = create(:executive_office, name: organisation_name)
end

Given /^the executive office has a promotional feature with an item$/ do
  @promotional_item = create_feature_item_for(@executive_office)
  @promotional_feature = @promotional_item.promotional_feature
end

Given /^the executive office has a promotional feature with the maximum number of items$/ do
  @promotional_feature = create_feature_item_for(@executive_office).promotional_feature
  create(:promotional_feature_item, promotional_feature: @promotional_feature)
  create(:promotional_feature_item, promotional_feature: @promotional_feature)
end

When /^I view the promotional feature$/ do
  visit admin_organisation_promotional_feature_url(@executive_office, @promotional_feature)
end

When /^I add a new promotional feature with a single item$/ do
  visit admin_organisation_path(@executive_office)
  click_link 'Promotional features'
  click_link 'New promotional feature'

  fill_in 'Feature title', with: 'Big Cheese'

  within 'form.promotional_feature_item' do
    fill_in 'Summary',                      with: 'The Big Cheese is coming.'
    fill_in 'Item title (optional)',        with: 'The Big Cheese'
    fill_in 'Item title url (optional)',    with: 'http://big-cheese.co'
    attach_file :image,    Rails.root.join('test/fixtures/big-cheese.960x640.jpg')
    fill_in 'Image description (alt text)', with: 'The Big Cheese'
  end

  click_button 'Save'
end

When /^I delete the promotional feature$/ do
  visit admin_organisation_path(@executive_office)
  click_link 'Promotional features'

  within record_css_selector(@promotional_feature) do
    click_button 'Delete'
  end
end

When /^I edit the promotional item, set the summary to "([^"]*)"$/ do |new_summary|
  visit admin_organisation_path(@executive_office)
  click_link 'Promotional features'
  click_link @promotional_feature.title
  within record_css_selector(@promotional_item) do
    click_link 'Edit'
  end
  fill_in 'Summary', with: new_summary
  click_button 'Save'
end

When /^I delete the promotional item$/ do
  visit admin_organisation_path(@executive_office)
  click_link 'Promotional features'
  click_link @promotional_feature.title

  within record_css_selector(@promotional_item) do
    click_button 'Delete'
  end
end

Then /^I should see the promotional feature on the organisation's page$/ do
  assert promotional_feature = @executive_office.promotional_features.first
  assert_current_url admin_organisation_promotional_feature_url(@executive_office, promotional_feature)

  within record_css_selector(promotional_feature) do
    assert page.has_css?('h1', text: promotional_feature.title)

    item = promotional_feature.items.first
    within record_css_selector(item) do
      assert page.has_content?(item.summary)
      assert page.has_link?(item.title, href: item.title_url)
      assert page.has_css?("img[src='#{item.image.s300.url}'][alt='#{item.image_alt_text}']")
    end
  end
end

Then /^I should no longer see the promotional feature$/ do
  assert_current_url admin_organisation_promotional_features_url(@executive_office)
  refute page.has_css?(record_css_selector(@promotional_feature))
end

Then /^I should see the promotional feature item's summary has been updated to "([^"]*)"$/ do |summary_text|
  assert_current_url admin_organisation_promotional_feature_url(@executive_office, @promotional_feature)

  within record_css_selector(@promotional_item) do
    assert page.has_css?('p', text: summary_text)
  end
end

Then /^I should no longer see the promotional item$/ do
  within record_css_selector(@promotional_feature) do
    assert !page.has_css?(record_css_selector(@promotional_item))
  end
end

Then /^I should not be able to add any further feature items$/ do
  refute page.has_link?("Add feature item")
end

Then /^I should see the promotional feature on the executive office page$/ do
  visit organisation_path(@executive_office)

  within record_css_selector(@executive_office) do
    within 'section.features' do
      assert page.has_css?('.promotional_feature h2', @promotional_feature.title)

      within record_css_selector(@promotional_feature) do
        @promotional_feature.items.each do |item|
          assert page.has_content?(item.summary)
          assert page.has_css?("img[src='#{item.image.s300.url}'][alt='#{item.image_alt_text}']")
          item.links.each { |link| assert page.has_link(link.text, href: link.url)  }
        end
      end
    end
  end
end
