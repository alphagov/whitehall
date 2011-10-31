class Nation < ActiveRecord::Base
  class << self
    def ensure_existence!
      ["England", "Scotland", "Wales", "Northern Ireland"].each do |nation_name|
        find_or_create_by_name(nation_name)
      end
    end

    def england; find_by_name("England"); end
    def scotland; find_by_name("Scotland"); end
    def wales; find_by_name("Wales"); end
    def northern_ireland; find_by_name("Northern Ireland"); end
  end

  scope :potentially_inapplicable, where(%{name <> "England"})
end