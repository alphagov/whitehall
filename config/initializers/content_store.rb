require 'gds_api/content_store'

class GdsApi::ContentStore::Fake
  def content_item!(_base_path)
    Struct.new("ContentItem", :content_id)
    Struct::ContentItem.new("129fb467-afd8-42e5-98c9-4f3294c40bb9")
  end
end

Whitehall.content_store = if Rails.env.test?
                            GdsApi::ContentStore::Fake.new
                          else
                            GdsApi::ContentStore.new(Plek.find('content-store'))
                          end
