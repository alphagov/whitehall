class PublishingApiPresenters::Unpublishing < PublishingApiPresenters::Edition
  attr_reader :edition, :update_type

  def initialize(edition, options = {})
    @edition = edition
    @update_type = options[:update_type] || default_update_type
  end

  def as_json
    super.merge(format: "unpublishing")
  end

  private

  def details
    {
      explanation: unpublishing_explanation,
      unpublished_at: edition.unpublishing.created_at,
      alternative_url: edition.unpublishing.alternative_url || ""
    }
  end

  def unpublishing_explanation
    Whitehall::EditionGovspeakRenderer.new(edition).unpublishing_explanation
  end


end
