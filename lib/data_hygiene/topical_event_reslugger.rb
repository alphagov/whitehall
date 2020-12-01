module DataHygiene
  class TopicalEventReslugger
    def initialize(topical_event, new_slug)
      @topical_event = topical_event
      @new_slug = new_slug
      @old_slug = @topical_event.slug
      @editions = @topical_event.editions
    end

    def run!
      delete_from_search_index
      update_slug
      republish
      add_to_search_index
      update_atom_feed_url
    end

  private

    attr_reader :topical_event, :new_slug, :old_slug, :editions

    def delete_from_search_index
      topical_event.remove_from_search_index
      editions.each(&:remove_from_search_index)
    end

    def update_slug
      topical_event.update!(slug: new_slug)
    end

    def republish
      Whitehall::PublishingApi.republish_async(topical_event)
    end

    def add_to_search_index
      topical_event.update_in_search_index
      editions.each(&:update_in_search_index)
    end

    def update_atom_feed_url
      old_atom_feed_path = "/government/topical-events/#{old_slug}.atom"
      new_atom_feed_path = "/government/topical-events/#{new_slug}.atom"
      redirects = [{ path: old_atom_feed_path, type: "exact", destination: new_atom_feed_path }]
      content_id = SecureRandom.uuid
      redirect = Whitehall::PublishingApi::Redirect.new(old_atom_feed_path, redirects)
      Services.publishing_api.put_content(content_id, redirect.as_json)
      Services.publishing_api.publish(content_id, nil, locale: "en")
    end
  end
end
