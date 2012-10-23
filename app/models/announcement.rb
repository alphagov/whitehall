class Announcement < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::Countries
  self.abstract_class = true

  def can_have_summary?
    true
  end

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end
end

require_relative 'news_article'
require_relative 'speech'