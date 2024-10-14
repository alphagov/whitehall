class PublishLandingPage
  attr_reader :landing_page

  def initialize(landing_page)
    @landing_page = landing_page
  end

  def self.call(landing_page)
    new(landing_page).call
  end

  def call
    send_to_publishing_api
  end

private

  def send_to_publishing_api
    Services.publishing_api.put_content(
      content_id,
      content_hash,
    )
    Services.publishing_api.publish(content_id)
  end

  def content_id
    @content_id ||= existing_content_id || SecureRandom.uuid
  end

  def existing_content_id
    Services.publishing_api.lookup_content_id(base_path: landing_page.base_path)
  end

  def content_hash
    {
      "base_path": landing_page.base_path,
      "title": landing_page.title,
      "description": landing_page.description,
      "locale": "en",
      "document_type": "landing_page",
      "schema_name": "landing_page",
      "publishing_app": "whitehall",
      "rendering_app": "frontend",
      "update_type": "major",
      "details": YAML.load(landing_page.yaml),
      "routes": [
        {
          "type": "exact",
          "path": landing_page.base_path,
        },
      ],
    }
  end
end
