class LandingPages::BaseBlock
  include ActiveModel::API

  attr_reader :type, :images

  validates :type, presence: true

  def initialize(source, images)
    @source = source
    @images = images
    @type = @source["type"]
  end

  def present_for_publishing_api
    raise "cannot present invalid block to publishing api - errors: #{errors.to_a}" if invalid?

    @source
  end

  def render_in(view_context)
    view_context.render partial: "admin/landing_pages/blocks/#{model_name.element}"
  end
end
