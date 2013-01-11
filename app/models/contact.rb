require 'validators/url_validator.rb'

class Contact < ActiveRecord::Base
  belongs_to :contactable, polymorphic: true
  has_many :contact_numbers, dependent: :destroy
  validates :description, presence: true
  validates :contact_form_url, url: true, allow_blank: true
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true, reject_if: :all_blank

  def mappable?
    (latitude.present? and longitude.present?) or postcode.present?
  end
end
