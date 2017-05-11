class NewsArticle < Newsesque
  include Edition::RoleAppointments
  include Edition::HasDocumentCollections
  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies

  validates :news_article_type_id, presence: true

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
end
