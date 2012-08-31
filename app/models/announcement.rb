class Announcement < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::Countries
  self.abstract_class = true

  def has_summary?
    true
  end

  def self.sort_by_first_published_at(announcements)
    announcements.sort_by(&:first_published_at).reverse
  end

  def <=>(other_object)
    if other_object.is_a?(Announcement)
      self.to_key <=> other_object.to_key
    else
      nil
    end
  end

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end
end

require_relative 'news_article'
require_relative 'speech'