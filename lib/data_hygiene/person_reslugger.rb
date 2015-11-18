module DataHygiene
  # Reslugs a person to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Person record's slug
  #   - reindexes the person for search
  #   - republishes the person to Publishing API
  #   - publishes a redirect content item to Publishing API
  #   - reindexes all dependent documents in search
  #
  class PersonReslugger
    def initialize(person, new_slug)
      @person = person
      @new_slug = new_slug
      @old_slug = person.slug
    end

    def run!
      remove_from_search_index
      update_slug
      register_redirect
      republish_dependencies
    end

  private
    attr_reader :person, :new_slug, :old_slug

    def remove_from_search_index
      Whitehall::SearchIndex.delete(person)
    end

    def update_slug
      # Note: This will trigger calls to both rummager and the Publishing API,
      # meaning that entries in both places will exist with the correct slug
      person.update_attributes!(slug: new_slug)
    end

    def old_base_path
      Whitehall.url_maker.person_path(old_slug)
    end

    def new_base_path
      Whitehall.url_maker.person_path(new_slug)
    end

    def redirects
      @redirects ||= [
        { path: old_base_path, destination: new_base_path, type: "exact" },
        { path: (old_base_path + ".atom"), destination: (new_base_path + ".atom"), type: "exact" },
      ]
    end

    def register_redirect
      Whitehall::PublishingApi.publish_redirect_async(old_base_path, redirects)
    end

    def republish_dependencies
      person.published_speeches.each(&:update_in_search_index)
      person.published_news_articles.each(&:update_in_search_index)
    end
  end
end
