class Contact < ActiveRecord::Base
  belongs_to :organisation

  def mappable?
    (latitude.present? and longitude.present?) or postcode.present?
  end
end