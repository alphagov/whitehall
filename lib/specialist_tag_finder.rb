class SpecialistTagFinder

  class Null
    def topics
      []
    end

    def top_level_topic
      nil
    end
  end

  def initialize(edition)
    @edition = edition
  end

  def topics
    @topics ||=
      begin
        presented_edition = PublishingApiPresenters::Edition.new(@edition)
        edition_path = presented_edition.base_path
        content_item = Whitehall.content_store.content_item(edition_path)

        return [] unless content_item
        Array(content_item.links["topics"])
      end
  end

  def grandparent_topic
    @grandparent_topic ||=
      begin
        presented_edition = PublishingApiPresenters::Edition.new(@edition)
        edition_path = presented_edition.base_path
        edition_content_item = Whitehall.content_store.content_item(edition_path)

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
end
