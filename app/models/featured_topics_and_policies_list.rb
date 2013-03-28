class FeaturedTopicsAndPoliciesList < ActiveRecord::Base
  belongs_to :organisation

  validates :summary, presence: true, length: { maximum: 65_535 }
  validates :organisation, presence: true
end
