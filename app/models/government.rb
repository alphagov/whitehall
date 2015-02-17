class Government < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :start_date, presence: true

  before_validation on: :create do |government|
    government.slug = government.name.to_s.parameterize
  end
end
