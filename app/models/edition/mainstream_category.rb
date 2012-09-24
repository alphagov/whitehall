module Edition::MainstreamCategory
  extend ActiveSupport::Concern

  included do
    belongs_to :primary_mainstream_category, class_name: "MainstreamCategory"

    has_many :edition_mainstream_categories, dependent: :destroy,
             foreign_key: :edition_id
    has_many :other_mainstream_categories, through: :edition_mainstream_categories,
             source: :mainstream_category
  end

  def mainstream_categories
    [primary_mainstream_category] + other_mainstream_categories
  end
end
