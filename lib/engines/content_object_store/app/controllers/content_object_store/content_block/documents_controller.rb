require "net/http"
require "json"
require "uri"
class ContentObjectStore::ContentBlock::DocumentsController < ContentObjectStore::BaseController
  def index
    @content_block_documents = ContentObjectStore::ContentBlock::Document.all
  end

  def show
    @content_block_document = ContentObjectStore::ContentBlock::Document.find(params[:id])
    @content_block_versions = @content_block_document.versions

    # TODO: This should be extracted out into GDS Adapters when we're ready
    url = URI.parse("http://publishing-api.dev.gov.uk/v2/content/#{@content_block_document.content_id}/linked-items")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      @linked_content_items = JSON.parse(response.body)["linked_content_items"]
    else
      puts "HTTP Request failed (#{response.code} #{response.message})"
    end
  end
end
