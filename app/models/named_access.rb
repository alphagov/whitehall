class NamedAccess < ApplicationRecord
  belongs_to :edition, inverse_of: :named_accesses

  validates :email,
            presence: true,
            uniqueness: { scope: :edition_id, case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
end
