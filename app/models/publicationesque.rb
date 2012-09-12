class Publicationesque < Edition
  include Edition::RelatedPolicies
  include ::Attachable

  attachable :edition

  has_one :response, foreign_key: :edition_id, dependent: :destroy

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end
end

require_relative 'publication'
require_relative 'consultation'
