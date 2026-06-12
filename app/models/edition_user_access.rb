class EditionUserAccess < ApplicationRecord
  belongs_to :edition, inverse_of: :edition_user_accesses

  validates :email,
            presence: true,
            uniqueness: { scope: :edition_id, case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  before_destroy :prevent_destroy_if_locked

private

  def prevent_destroy_if_locked
    throw(:abort) if locked?
  end
end
