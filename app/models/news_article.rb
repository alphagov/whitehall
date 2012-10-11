class NewsArticle < Announcement
  include Edition::Ministers
  include Edition::Appointment
  include Edition::FactCheckable
end
