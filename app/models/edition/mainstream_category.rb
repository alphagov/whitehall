module Edition::MainstreamCategory
  extend ActiveSupport::Concern

  included do
    belongs_to :primary_mainstream_category, class_name: "MainstreamCategory"
  end
end
