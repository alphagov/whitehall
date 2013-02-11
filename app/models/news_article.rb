class NewsArticle < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::DocumentSeries
  include Edition::WorldwidePriorities
  include ::Attachable
  include Edition::AlternativeFormatProvider

  attachable :edition
  force_review_of_bulk_attachments

  validates :news_article_type_id, presence: true
  validate :only_news_article_allowed_invalid_data_can_be_awaiting_type

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

  def search_format_types
    super + [NewsArticle.search_format_type] + self.news_article_type.search_format_types
  end

  def alternative_format_provider_required?
    false
  end

  def can_apply_to_local_government?
    true
  end

  def translatable?
    true
  end

  def apply_any_extra_validations_when_converting_from_imported_to_draft
    class << self
      validates :first_published_at, presence: true
    end
  end

  private

  def only_news_article_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:news_article_type, 'must be changed') if NewsArticleType::ImportedAwaitingType == self.news_article_type
    end
  end
end
