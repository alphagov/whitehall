class Country < ActiveRecord::Base
  has_many :document_countries
  has_many :documents, through: :document_countries

  validates :name, presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end
end