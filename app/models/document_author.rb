class DocumentAuthor < ActiveRecord::Base
  belongs_to :document, foreign_key: :edition_id
  belongs_to :user
end