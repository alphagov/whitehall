require 'active_record_like_interface'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/inflections.rb'

class NewsArticleType
  include ActiveRecordLikeInterface

  attr_accessor :id, :singular_name, :plural_name, :prevalence, :key

  def slug
    plural_name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.all_slugs
    all.map(&:slug).to_sentence
  end

  def self.by_prevalence
    all.group_by { |type| type.prevalence }
  end

  def self.ordered_by_prevalence
    primary + migration
  end

  def self.primary
    by_prevalence[:primary]
  end

  def self.migration
    by_prevalence[:migration]
  end

  def search_format_types
    ['news-article-' + self.key.gsub('_', ' ').parameterize]
  end

  NewsStory = create(id: 1, key: "news_story", singular_name: "News story", plural_name: "News stories", prevalence: :primary)
  PressRelease = create(id: 2, key: "press_release", singular_name: "Press release", plural_name: "Press releases", prevalence: :primary)
  GovernmentResponse = create(id: 3, key: "government_response", singular_name: "Government response", plural_name: "Government responses", prevalence: :primary)

  # Temporary to allow migration
  Unknown                = create(id: 999, key: "announcement", singular_name: "Announcement", plural_name: "Announcements", prevalence: :migration)
  # For imported news with a blank news_article_type field
  ImportedAwaitingType   = create(id: 1000, key: "imported", singular_name: "Imported - awaiting type", plural_name: "Imported - awaiting type", prevalence: :migration)

end
