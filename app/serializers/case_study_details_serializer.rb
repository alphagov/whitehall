class CaseStudyDetailsSerializer < ActiveModel::Serializer
  attributes(
    :body,
    :change_history,
    :emphasised_organisations,
    :first_public_at,
    :format_display_type,
  )
  has_one :tag, key: :tags
  attribute :image, if: -> { image_available? }

  def body
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(object)
  end

  def change_history
    object.change_history.as_json
  end

  def emphasised_organisations
    object.lead_organisations.map(&:content_id)
  end

  def first_public_at
    return object.first_public_at if object.document.published?
    object.document.created_at.iso8601
  end

  def format_display_type
    object.display_type_key
  end

  def image_available?
    object.images.any? || emphasised_organisation_default_image_available?
  end

  def emphasised_organisation_default_image_available?
    object.lead_organisations.first.default_news_image.present?
  end

  def image
    ImageDetailsSerializer.new(CaseStudyPresenter.new(object)).as_json
  end

  def tag
    TagDetailsSerializer.new(object).as_json
  end
end
