class Announcement < Edition
  include Edition::RelatedPolicies
  include Edition::Countries

  def has_summary?
    true
  end

  def self.sort_by_first_published_at(announcements)
    announcements.sort_by(&:first_published_at).reverse
  end
end
