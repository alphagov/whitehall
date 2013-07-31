class NationInapplicability < ActiveRecord::Base
  delegate :name, to: :nation

  belongs_to :edition

  scope :for_nation, -> nation {
    where(nation_id: nation.id)
  }

  validates :alternative_url, uri: true, allow_blank: true

  def nation
    Nation.find_by_id(nation_id)
  end

  def nation=(new_nation)
    self.nation_id = new_nation.id
  end
end
