class NationInapplicability < ActiveRecord::Base
  delegate :name, to: :nation

  belongs_to :nation
  belongs_to :edition

  scope :for_nation, -> nation {
    where(nation_id: nation.id)
  }

  validates :alternative_url, format: URI::regexp(%w(http https)), allow_blank: true
end