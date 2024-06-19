class ObjectStore::ContentBlock < ApplicationRecord
  attr_accessor :title, :block_type

  store_accessor :properties
end
