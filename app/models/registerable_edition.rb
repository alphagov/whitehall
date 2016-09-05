# RegisterableEdition is an object that `GdsApi::Panopticon::Registerer` uses
# to generate a payload to send to panopticon.
#
# The reason we're still sending things to panopticon is to make them available
# to link to as "related artefacts" and to make the need_ids available for
# metadata-api via content-api.
class RegisterableEdition
  attr_accessor :edition

  def initialize(edition)
    @edition = edition
  end

  def ==(other)
    edition == other.edition
  end

  def slug
    # strip the preceding slash character from the generated slug,
    # to be consistent with Panopticon's slug format.
    panopticon_slug = Whitehall.url_maker.public_document_path(edition).sub(/\A\//, "")
    if edition.deleted?
      panopticon_slug.sub!(%r{(\A|/)deleted-([^/]+)$}, '\1\2')
    end
    panopticon_slug
  end

  def rendering_app
    edition.rendering_app
  end

  def paths
    if kind == "detailed_guide"
      detailed_guide_paths
    else
      []
    end
  end

  def prefixes
    []
  end

  def title
    edition.title
  end

  def description
    edition.summary
  end

  def kind
    model_type = "#{edition.type.underscore}_type".to_sym
    edition.respond_to?(model_type) ? edition.send(model_type).key : edition.type.underscore
  end

  def state
    if no_longer_published?
      "archived"
    elsif published?
      "live"
    else
      "draft"
    end
  end

  def need_ids
    edition.need_ids
  end

  def content_id
    edition.content_id
  end

private

  def no_longer_published?
    %w(deleted withdrawn).include?(edition.state) || edition.unpublishing != nil
  end

  def published?
    edition.state == "published"
  end

  def detailed_guide_paths
    ["/#{slug}"] + edition.non_english_translations.map { |t| "/#{slug}.#{t.locale}" }
  end
end
