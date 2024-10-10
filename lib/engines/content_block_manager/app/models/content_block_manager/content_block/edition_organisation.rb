module ContentBlockManager
  module ContentBlock
    class EditionOrganisation < ApplicationRecord
      belongs_to :edition
      belongs_to :organisation
    end
  end
end
