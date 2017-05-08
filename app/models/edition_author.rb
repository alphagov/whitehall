class EditionAuthor < ApplicationRecord
  belongs_to :edition
  belongs_to :user
end
