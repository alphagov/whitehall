class Publicationesque < Edition
  include Edition::RelatedPolicies
  include ::Attachable

  attachable :edition
  force_review_of_bulk_attachments

  has_one :response, foreign_key: :edition_id, dependent: :destroy

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def part_of_series?
    false
  end
end

require_relative 'publication'
require_relative 'consultation'
