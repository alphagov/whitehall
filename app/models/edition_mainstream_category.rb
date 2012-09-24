class EditionMainstreamCategory < ActiveRecord::Base
  belongs_to :edition
  belongs_to :mainstream_category
end
