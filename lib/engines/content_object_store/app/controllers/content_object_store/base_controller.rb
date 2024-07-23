class ContentObjectStore::BaseController < Admin::BaseController
  before_action :check_object_store_feature_flag

  def check_object_store_feature_flag
    forbidden! unless Flipflop.content_object_store?
  end
end
