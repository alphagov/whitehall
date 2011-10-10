class Document < ActiveRecord::Base
  has_many :editions
  has_one :published_edition, class_name: 'Edition', conditions: { state: 'published' }

  def self.published
    joins(:published_edition)
  end
end