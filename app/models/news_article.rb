class NewsArticle < Newsesque
  include Edition::RoleAppointments
  include Edition::HasDocumentCollections
  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies

  validate :ministers_are_not_associated, if: :world_news_story?
  validates :news_article_type_id, presence: true
  validate :non_english_primary_locale_only_for_world_news_story
  validate :policies_are_not_associated, unless: :can_be_related_to_policies?

  def self.subtypes
    NewsArticleType.all
  end

  def self.by_subtype(subtype)
    where(news_article_type_id: subtype.id)
  end

  def self.by_subtypes(subtype_ids)
    where(news_article_type_id: subtype_ids)
  end

  def news_article_type
    NewsArticleType.find_by_id(news_article_type_id)
  end

  def news_article_type=(news_article_type)
    self.news_article_type_id = news_article_type && news_article_type.id
  end

  def display_type
    news_article_type.singular_name
  end

  def display_type_key
    news_article_type.key
  end

  def search_index
    super.merge({"news_article_type" => news_article_type.slug})
  end

  def search_format_types
    super + [NewsArticle.search_format_type] + self.news_article_type.search_format_types
  end

  def alternative_format_provider_required?
    false
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def locale_can_be_changed?
    new_record?
  end

  def non_english_primary_locale_only_for_world_news_story
    if non_english_edition? && news_article_type != NewsArticleType::WorldNewsStory
      errors.add(:foreign_language, 'is not allowed')
    end
  end

  def world_news_story?
    news_article_type == NewsArticleType::WorldNewsStory
  end

  def can_be_related_to_policies?
    !world_news_story?
  end

private

  def policies_are_not_associated
    unless edition_policies.empty?
      errors.add(:base, "You can't tag a world news story to policies, please remove policy")
    end
  end

  def ministers_are_not_associated
    if is_associated_with_a_minister?
      errors.add(:base, "You can't tag a world news story to ministers, please remove minister")
    end
  end
end
