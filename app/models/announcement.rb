class Announcement
  def self.by_first_published_at(announcements)
    announcements.sort_by(&:first_published_at).reverse
  end
end
