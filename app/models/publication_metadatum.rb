class PublicationMetadatum < ActiveRecord::Base
  belongs_to :publication

  ATTRIBUTES = (attribute_names - %w(id publication_id created_at updated_at))
end