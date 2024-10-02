class PublishHistoryPage
  attr_reader :history_page_content_item, :content_id

  def initialize(history_page_details)
    @history_page_content_item = make_content_item(history_page_details)
    @content_id = history_page_details[:content_it]
  end

  def self.call(history_page_details)
    new(history_page_details).call
  end

  def call
    send_to_publishing_api
  end

private

  def make_content_item(details)
    govspeak = Govspeak::Document.new(details[:govspeak])

    {
      base_path: details[:base_path],
      title: details[:title],
      description: details[:description],
      locale: "en",
      document_type: "history",
      schema_name: "history",
      publishing_app: "whitehall",
      rendering_app: "frontend",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "minor",
      details: {
        image: {
          src: details[:image],
          alt: details[:image_alt],
        },
        headers: extract_headers(govspeak),
        body: govspeak.to_html,
      },
      routes: [
        {
          type: "exact",
          path: details[:base_path],
        },
      ],
    }
  end

  def extract_headers(govspeak)
    govspeak.headers.select{ |h| h.level == 2 }.map { |h| { title: h.text, id: h.id } }
  end

  def send_to_publishing_api
    Services.publishing_api.put_content(
      content_id,
      history_page_content_item,
    )
    Services.publishing_api.publish(content_id)
  end
end
