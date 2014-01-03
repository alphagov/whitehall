# encoding: utf-8
require 'test_helper'

module Whitehall::GovUkDelivery
  class EmailFormatterTest < ActiveSupport::TestCase

    def assert_equal_ignoring_whitespace(expected, actual)
      assert_equal expected.gsub(/\s+/, ' ').strip, actual.gsub(/\s+/, ' ').strip
    end

    def email_formatter_for(edition, notification_date = Time.zone.now, title = edition.title, summary = edition.summary)
      Whitehall::GovUkDelivery::EmailFormatter.new(edition, notification_date.iso8601, title: title, summary: summary)
    end

    test '#display_title combines the title with the document type' do
      policy = Policy.new(title: 'Compulsory pickles for all')
      assert_equal 'Policy: Compulsory pickles for all', email_formatter_for(policy).display_title
    end

    test '#display_title uses an appropriate document type for world location new articles' do
      news = WorldLocationNewsArticle.new(title: 'Global pickle sales skyrocket')
      assert_equal 'News story: Global pickle sales skyrocket', email_formatter_for(news).display_title
    end

    test '#description returns the summary for a first edition' do
      first_edition = create(:published_publication)
      notifier = email_formatter_for(first_edition)
      assert_match first_edition.summary, notifier.email_body
    end

    test '#description includes the change note for updated editions' do
      first_edition = create(:published_publication)
      second_edition = first_edition.create_draft(create(:departmental_editor))
      second_edition.change_note = "Updated some stuff"
      second_edition.save!
      force_publish(second_edition)
      notifier = email_formatter_for(second_edition)

      assert_match "[Updated: #{second_edition.change_note}]<br /><br />#{second_edition.summary}", notifier.email_body
    end

    test '#email_body generates a utf-8 encoded body' do
      publication = create(:news_article, title: "Café".encode("UTF-8"))

      body = email_formatter_for(publication).email_body
      assert_includes body, publication.title
      assert_equal 'UTF-8', body.encoding.name
    end

    test "#email_body should link to full URL in email" do
      publication = create(:publication)
      publication.first_published_at = Time.zone.now
      publication.major_change_published_at = Time.zone.now

      assert_match /#{Whitehall.public_host}/, email_formatter_for(publication).email_body
    end

    test "#email_body includes the description and display_title" do
      first_draft = create(:published_publication)
      notifier = email_formatter_for(first_draft)

      assert_match first_draft.summary, notifier.email_body
      assert_match notifier.display_title, notifier.email_body
    end

    test "#email_body includes a formatted date" do
      publication = create(:publication)
      email_body = email_formatter_for(publication, Time.zone.parse("2011-01-01 12:13:14")).email_body
      body = Nokogiri::HTML.fragment(email_body)
      assert_equal_ignoring_whitespace "1 January, 2011 at 12:13pm", body.css('.rss_pub_date').inner_text
    end

    test '#email_body html-escapes html characters in the title, change note and summary' do
      first_draft = create(:published_publication, title: 'Beards & Facial Hair', summary: 'Keep your beard "tip-top"!')
      second_draft = first_draft.create_draft(create(:departmental_editor))
      second_draft.change_note = '"tip-top" added.'
      second_draft.save!
      force_publish(second_draft)

      body = email_formatter_for(second_draft).email_body
      assert_match %r(Beards &amp; Facial Hair), body
      assert_match %r(&quot;tip-top&quot; added), body
      assert_match %r(Keep your beard &quot;tip-top&quot;!), body
    end

  end
end
