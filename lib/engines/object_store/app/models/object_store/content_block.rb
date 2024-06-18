class ObjectStore::ContentBlock
  include ActiveModel::API
  include ActiveRecord::Store

  attr_accessor :title

  store_accessor :properties
end
