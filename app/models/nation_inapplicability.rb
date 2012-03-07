class NationInapplicability < ActiveRecord::Base
  extend Forwardable

  def_delegators :nation, :name

  belongs_to :nation
  belongs_to :document

  scope :for_nation, -> nation {
    where(nation_id: nation.id)
  }

  validates :alternative_url, format: URI::regexp(%w(http https)), allow_blank: true
end