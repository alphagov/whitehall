require "securerandom"

class PublishingApiPresenters::Gone
  def initialize(base_path)
    @base_path = base_path
  end

  def as_json
    {
      base_path: @base_path,
      content_id: SecureRandom.uuid,
      format: 'gone',
      publishing_app: 'whitehall',
      update_type: 'major',
      routes: [{ path: @base_path, type: 'exact' }],
    }
  end
end
