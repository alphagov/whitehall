require "securerandom"

class PublishingApiPresenters::Gone
  def initialize(base_path, edition_content_id)
    @base_path = base_path
    @edition_content_id = edition_content_id
  end

  def as_json
    {
      content_id: SecureRandom.uuid,
      format: 'gone',
      publishing_app: 'whitehall',
      update_type: 'major',
      routes: [{ path: @base_path, type: 'exact' }],
      links: {
        can_be_replaced_by: [@edition_content_id],
      },
    }
  end
end
