module Whitehall::Models::Contacts
  extend ActiveSupport::Concern

  included do
    has_many :contacts, as: :contactable, dependent: :destroy
    accepts_nested_attributes_for :contacts, reject_if: :contact_and_contact_numbers_are_blank
  end

  def contact_and_contact_numbers_are_blank(attributes)
    attributes.all? { |key, value|
      key == '_destroy' ||
      value.blank? || (
        (key == "contact_numbers_attributes") &&
        value.all? { |contact_number_attributes|
          contact_number_attributes.all? { |contact_number_key, contact_number_value|
            contact_number_key == '_destroy' ||
            contact_number_value.blank?
          }
        }
      )
    }
  end
end
