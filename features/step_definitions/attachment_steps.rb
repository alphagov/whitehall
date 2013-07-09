When(/^I start drafting a news article$/) do
  begin_drafting_news_article title: 'News Article'
end

When(/^I start drafting a statistical data set$/) do
  begin_drafting_statistical_data_set title: 'A Statistical data set', alternative_format_provider: create(:alternative_format_provider)
end

When(/^I start drafting a publication$/) do
  begin_drafting_publication 'A Publication'
end

When(/^I start drafting a consultation$/) do
  begin_drafting_consultation title: 'A Consultation', alternative_format_provider: create(:alternative_format_provider)
end

When(/^I save the (?:publication|statistical data set|news article|consultation)$/) do
  click_on "Save"
end

When(/^I add an attachment$/) do
  click_on "Save and add attachment"
  fill_in "Title", with: 'An attachment title'
  attach_file "File", Rails.root.join("features/fixtures", "attachment.pdf")
  click_on "Save"

  @attachment = Attachment.last
end

Then(/^I should see the attachment listed on the form with it's markdown code$/) do
  within record_css_selector(@attachment) do
    assert_equal @attachment.title, find_field('Title').value
    assert_equal '!@1', find_field('markdown').value
    assert_equal '[InlineAttachment:1]', find_field('markdown_inline').value
  end
end

Then(/^I should see the attachment listed on the attachments tab$/) do
  click_on "Attachments"
  assert page.has_content?(@attachment.title)
end

When(/^I add an attachment with additional references$/) do
  click_on "Save and add attachment"
  fill_in "Title", with: 'An attachment title'
  fill_in "Unique reference", with: 'A_UNIQUE_REFERENCE'
  attach_file "File", Rails.root.join("features/fixtures", "attachment.pdf")
  click_on "Save"

  @attachment = Attachment.last
end

Then(/^I should see the attachment listed on the form$/) do
  within record_css_selector(@attachment) do
    assert_equal @attachment.title, find_field('Title').value
    assert_equal @attachment.unique_reference, find_field('Unique reference').value
  end
end
