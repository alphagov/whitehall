class EditionUserNeed < ActiveRecord::Base
  belongs_to :edition, inverse_of: :edition_user_need
  belongs_to :user_need
end
