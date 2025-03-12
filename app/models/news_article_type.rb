require "active_record_like_interface"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

class NewsArticleType
  include ActiveRecordLikeInterface

  FORMAT_ADVICE = {
    1 => "<p>News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.</p>",
    2 => "<p>Unedited press releases as sent to the media, and official statements from the organisation or a minister.</p><p>Do not use for: statements to Parliament. Use the “Speech” format for those.</p>",
    3 => "<p>Government statements in response to media coverage, such as rebuttals and ‘myth busters’.</p><p>Do not use for: statements to Parliament. Use the “Speech” format for those.</p>",
    4 => "<p>Announcements specific to one or more world location. Don’t duplicate news published by another department.</p>",
  }.to_json.freeze

  attr_accessor :id, :singular_name, :plural_name, :key

  def slug
    plural_name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.all_slugs
    all.map(&:slug).to_sentence
  end

  def genus_key
    "news_article"
  end

  NewsStory = create!(
    id: 1,
    key: "news_story",
    singular_name: "News story",
    plural_name: "News stories",
  )
  PressRelease = create!(
    id: 2,
    key: "press_release",
    singular_name: "Press release",
    plural_name: "Press releases",
  )
  GovernmentResponse = create!(
    id: 3,
    key: "government_response",
    singular_name: "Government response",
    plural_name: "Government responses",
  )
  WorldNewsStory = create!(
    id: 4,
    key: "world_news_story",
    singular_name: "World news story",
    plural_name: "World news stories",
  )
end
