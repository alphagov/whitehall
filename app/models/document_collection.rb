class DocumentCollection < Edition
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::TopicalEvents

  has_many :groups,
           lambda {
             (extending UserOrderableExtension)
             .order("document_collection_groups.ordering")
           },
           class_name: "DocumentCollectionGroup",
           dependent: :destroy,
           inverse_of: :document_collection

  before_create :create_default_group

  class ClonesGroupsTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      new_edition.groups = @edition.groups.map(&:dup)
    end
  end

  add_trait ClonesGroupsTrait

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def content_ids
    groups.flat_map(&:content_ids)
  end

  def locale_can_be_changed?
    true
  end

  def base_path
    "/government/collections/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::DocumentCollectionPresenter
  end

  def has_topic_level_notifications?
    taxonomy_topic_email_override.present?
  end

private

  def string_for_slug
    title
  end

  def create_default_group
    if groups.empty?
      groups << DocumentCollectionGroup.new(DocumentCollectionGroup.default_attributes)
    end
  end

  def body_required?
    false
  end
end
