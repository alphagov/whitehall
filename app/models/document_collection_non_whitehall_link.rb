class DocumentCollectionNonWhitehallLink < ApplicationRecord
  has_many :document_collection_group_memberships,
           inverse_of: :non_whitehall_link,
           foreign_key: :non_whitehall_link_id,
           dependent: :destroy

  # may want to validate base_path and content_id
end
