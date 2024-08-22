require "net/http"
require "json"
require "uri"

module ContentObjectStore
  class GetHostContentItems
    attr_reader :content_id

    def initialize(content_id:)
      self.content_id = content_id
    end

    def self.by_embedded_document(content_block_document:)
      new(content_id: content_block_document.content_id).items
    end

    def items
      content_items["results"].map do |item|
        ContentObjectStore::HostContentItem.new(
          title: item["title"],
          base_path: item["base_path"],
          document_type: item["document_type"],
          publishing_organisation: item["primary_publishing_organisation"],
        )
      end
    end

  private

    attr_writer :content_id

    def content_items
      @content_items ||= begin
        # TODO: A temporary solution to get the content items from the new publishing-api endpoint.
        # To be replaced with a new method via GDS Adapters when it's implemented.
        url = URI.parse("#{Plek.find('publishing-api')}/v2/content/#{@content_id}/embedded")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == "https"

        request = Net::HTTP::Get.new(url.request_uri)
        response = http.request(request)

        @content_items = if response.is_a?(Net::HTTPSuccess)
                           JSON.parse(response.body)
                         else
                           {
                             "target_content_id" => @content_id,
                             "total" => 0,
                             "results" => [],
                           }
                         end
      end
    end
  end
end
