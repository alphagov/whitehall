require 'gds_api/content_store'

class GdsApi::ContentStore::Fake
  def content_item!(tag)
    Struct.new("ContentItem", :content_id)
    Struct::ContentItem.new("#{tag}-content-id")
  end
end

Whitehall.content_store = if Rails.env.test?
                            GdsApi::ContentStore::Fake.new
                          else
                            GdsApi::ContentStore.new(Plek.find('content-store'))
                          end
