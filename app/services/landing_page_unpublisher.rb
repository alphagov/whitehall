class LandingPageUnpublisher
  attr_reader :landing_page

  def initialize(landing_page)
    @landing_page = landing_page
  end

  def self.call(landing_page)
    new(landing_page).call
  end

  def call
    Services.publishing_api.publish(existing_content_id, type: "gone")
  end

private

  def existing_content_id
    Services.publishing_api.lookup_content_id(base_path: landing_page.base_path)
  end
end
