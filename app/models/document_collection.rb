class DocumentCollection < Edition
  include Edition::Organisations
  include Edition::TaggableOrganisations

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  include Edition::Topics
  include Edition::TopicalEvents
  include Edition::BrexitNoDealContentNoticeLinks

  has_many :groups,
           -> { order("document_collection_groups.ordering") },
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

  def search_index
    super.merge("slug" => slug)
  end

  def search_link
    Whitehall.url_maker.public_document_path(self)
  end

  def indexable_content
    [
      Govspeak::Document.new(body).to_text,
      groups.live.map do |group|
        [group.heading, Govspeak::Document.new(group.body).to_text]
      end,
    ].flatten.join("\n")
  end

  def display_type
    "Collection"
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def content_ids
    groups.flat_map(&:content_ids)
  end

private

  def create_default_group
    if groups.empty?
      groups << DocumentCollectionGroup.new(DocumentCollectionGroup.default_attributes)
    end
  end

  def body_required?
    false
  end
end
