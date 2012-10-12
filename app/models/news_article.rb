class NewsArticle < Announcement
  include Edition::Ministers
  include Edition::RoleAppointments
  include Edition::FactCheckable
end
