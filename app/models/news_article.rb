class NewsArticle < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

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

  def search_index
    super.merge({"news_article_type" => news_article_type_id})
  end

  private

  def only_news_article_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:news_article_type, 'must be changed') if NewsArticleType::ImportedAwaitingType == self.news_article_type
    end
  end
end
