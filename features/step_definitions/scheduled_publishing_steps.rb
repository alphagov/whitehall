Given(/^a (draft|submitted) scheduled news article exists$/) do |state|
  @news_article = create(:news_article, state.to_sym, scheduled_publication: 1.day.from_now)
end

When(/^I schedule the news article for publication$/) do
  visit admin_news_article_path(@news_article)
  click_on "Schedule"
end

When(/^I force schedule the news article for publication$/) do
  visit admin_news_article_path(@news_article)
  click_on "Force schedule"
end

Then(/^the news article is published when the scheduled publication time arrives$/) do
  assert scheduled_publishing_job_for(@news_article)

  Timecop.travel(1.day.from_now + 1.second) do
    execute_scheduled_publication_job_for(@news_article)

    visit news_article_path(@news_article.slug)
    assert page.has_content?(@news_article.title)
  end
end
