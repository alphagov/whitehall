class ObjectStore::ContentBlock < ApplicationRecord
  attr_accessor :title, :block_type

  store_accessor :properties

  validates :properties, presence: true, json: { schema: -> { schema_for_block_type } }

  def schema_for_block_type
    ObjectStore::ContentBlockValidator.schema_for(block_type)
  end
end
