class NationInapplicability < ActiveRecord::Base
  belongs_to :nation
  belongs_to :document

  scope :for_nation, -> nation {
    where(nation_id: nation.id)
  }
end