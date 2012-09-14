module Edition::MainstreamCategory
  extend ActiveSupport::Concern

  included do
    belongs_to :mainstream_category
  end
end
