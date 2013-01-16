class NewsArticle < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  validates :news_article_type_id, presence: true

end
