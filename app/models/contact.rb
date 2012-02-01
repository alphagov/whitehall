class Contact < ActiveRecord::Base
  belongs_to :organisation
  has_many :contact_numbers
  validates :description, presence: true
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true, reject_if: :all_blank

  def mappable?
    (latitude.present? and longitude.present?) or postcode.present?
  end
end