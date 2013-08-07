
When(/^I make unsaved changes to the news article$/) do
  @news_article = NewsArticle.last
  visit edit_admin_news_article_path(@news_article)
  fill_in 'Title', with: 'An unsaved change'
end

When(/^I attempt to visit the attachments page$/) do
  click_on 'Attachments'
end

Then(/^I should stay on the edit screen for the news article$/) do
  assert_equal edit_admin_news_article_path(@news_article), page.current_path
end

When(/^I save my changes$/) do
  click_on 'Save and continue editing'
end

Then(/^I can visit the attachments page$/) do
  click_on 'Attachments'
  assert_equal admin_edition_attachments_path(@news_article), page.current_path
end

When /^the (?:attachment|image)s? (?:has|have) been virus\-checked$/ do
  FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
  FileUtils.rm_rf(Whitehall.incoming_uploads_root)
  FileUtils.mkdir(Whitehall.incoming_uploads_root)
end

Then /^the image will be quarantined for virus checking$/ do
  assert_final_path(person_image_path, "thumbnail-placeholder.png")
end

Then /^the virus checked image will be available for viewing$/ do
  assert_final_path(person_image_path, person_image_path)
end
