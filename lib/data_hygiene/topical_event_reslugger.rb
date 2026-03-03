module DataHygiene
  class TopicalEventReslugger
    def initialize(topical_event, new_slug)
      @topical_event = topical_event
      @new_slug = new_slug
      @old_slug = @topical_event.slug
      @editions = @topical_event.editions
    end

    def run!
      update_slug
      republish
      update_atom_feed_url
    end

  private

    attr_reader :topical_event, :new_slug, :old_slug, :editions

    def update_slug
      topical_event.update!(slug: new_slug)
    end

    def republish
      Whitehall::PublishingApi.republish_async(topical_event)
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
