# For now, this is used to register data for organisations in the content
# store as "placeholder" content items. This is so that finders can reference
# organisations using content_ids and have their basic information expanded
# out when read back out from the content store.
class PublishingApiPresenters::Organisation
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def base_path
    Whitehall.url_maker.organisation_path(organisation)
  end

  def as_json
    {
      content_id: organisation.content_id,
      title: organisation.name,
      base_path: base_path,
      format: "placeholder",
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: organisation.updated_at,
      routes: [
        {
          path: base_path,
          type: "exact"
        }
      ],
      update_type: "major",
    }
  end
end
