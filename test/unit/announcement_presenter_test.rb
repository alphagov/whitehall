require "test_helper"

class AnnouncementPresenterTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "#today returns news and speeches from the last 24 hours" do
    older_announcements = [create(:published_news_article, published_at: 25.hours.ago), create(:published_speech, published_at: 26.hours.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    assert_equal announced_today, AnnouncementPresenter.new.today
  end

  test "#today returns news and speeches from the last 24 hours in order of first publication" do
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    editor = create(:departmental_editor)
    announced_today.push(updated_announcement = announced_today.pop.create_draft(editor))
    updated_announcement.change_note = "change-note"
    updated_announcement.publish_as(editor, force: true)

    assert_equal announced_today, AnnouncementPresenter.new.today
  end

  test "#today does not return recently-updated old news and speeches as happening in the last 24 hours" do
    older_announcements = [create(:published_news_article, published_at: 25.hours.ago), create(:published_speech, published_at: 26.hours.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    editor = create(:departmental_editor)
    updated_older_announcements = older_announcements.map do |older_announcement|
      older_announcement.create_draft(editor).tap do |updated_older_announcement|
        updated_older_announcement.publish_as(editor, force: true)
      end
    end

    assert_equal announced_today, AnnouncementPresenter.new.today
  end

  test "#in_last_7_days doesn't include anything from within the last 24 hours" do
    older_announcements = [create(:published_news_article, published_at: 8.days.ago), create(:published_speech, published_at: 8.days.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article, published_at: 24.hours.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    assert_equal announced_in_last_7_days.to_set, AnnouncementPresenter.new.in_last_7_days.to_set
  end

  test "#in_last_7_days returns editions in order of first publication" do
    announced_in_last_7_days = [
      create(:published_news_article, published_at: 24.hours.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    editor = create(:departmental_editor)
    announced_in_last_7_days.push(updated_announcement = announced_in_last_7_days.pop.create_draft(editor))
    updated_announcement.change_note = "change-note"
    updated_announcement.publish_as(editor, force: true)

    assert_equal announced_in_last_7_days, AnnouncementPresenter.new.in_last_7_days
  end

  test "#in_last_7_days does not return old news and speeches updated in the last 7 days as happening in the last 7 days" do
    older_announcements = [create(:published_news_article, published_at: 8.days.ago), create(:published_speech, published_at: 8.days.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article, published_at: 24.hours.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    Timecop.travel(3.days.ago) do
      editor = create(:departmental_editor)
      older_announcements.each do |older_announcement|
        older_announcement.create_draft(editor).publish_as(editor, force: true)
      end
    end

    assert_equal announced_in_last_7_days, AnnouncementPresenter.new.in_last_7_days
  end

end
