class RelatedMainstream < ActiveRecord::Base
  belongs_to :edition, foreign_key: :edition_id
end
