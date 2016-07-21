class SpecialistTagFinder
  class Null
    def topics
      []
    end

    def top_level_topic
      nil
    end
  end

  def initialize(edition_path)
    @edition_path = edition_path
  end

  def topics
    @topics ||= begin
      return [] unless edition_content_item
      Array(edition_content_item.links["topics"])
    end
  end

  def top_level_topic
    # Topics in GOVUK (called 'Specialist Sectors' in  Whitehall admin and
    # throughout this codebase) exist in a 2-level hierarchy.  Editions may be
    # tagged with a parent - this is always one of the 2nd level topics.  The
    # top level topic (i.e. - the parent of the edition's parent) is required
    # in the frontend when rendering an Edition's breadcrumb.

    @top_level_topic ||= begin
      return unless edition_content_item
      parents = Array(edition_content_item.links["parent"])
      return unless parents.any?

      # FIXME: We now need to fetch the parent topic from the content store to
      # retrieve its parent. We should replace this implementation with the
      # publishing API's links expansion / dependency resolution, which is
      # currently WIP.
      parent_path = parents.first["base_path"]
      parent_content_item = Whitehall.content_store.content_item(parent_path)
      Array(parent_content_item.links["parent"]).first
    end
  end

private

  def edition_content_item
    @edition_content_item ||= begin
      Whitehall.content_store.content_item(@edition_path)
    end
  end
end
