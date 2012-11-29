class Group < ActiveRecord::Base
  belongs_to :organisation

  validates :name, :organisation, presence: true

  def destroyable?
    true
  end
end
