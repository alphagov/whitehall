class OperationalField < ActiveRecord::Base
  include Searchable

  validates :name, presence: true, uniqueness: true

  has_many :fatality_notices

  searchable title: :name,
             link: :search_link,
             content: :description_without_markup

  extend FriendlyId
  friendly_id

  def search_link
    Whitehall.url_maker.operational_field_path(slug)
  end

  def description_without_markup
    Govspeak::Document.new(description).to_text
  end

  def published_fatality_notices
    fatality_notices.published
  end
end
