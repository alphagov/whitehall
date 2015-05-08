module DataHygiene
  # Reslugs a role to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Role record's slug
  #   - reindexes the role for search
  #   - republishes the role to Publishing API
  #   - publishes a redirect content item to Publishing API
  #   - reindexes all dependent documents in search
  #
  class RoleReslugger
    def initialize(role, new_slug)
      @role = role
      @new_slug = new_slug
      @old_slug = @role.slug
    end

    def run!
      remove_from_search_index
      update_slug
      register_redirect
    end

  private
    attr_reader :role, :new_slug, :old_slug

    def remove_from_search_index
      Whitehall::SearchIndex.delete(role)
    end

    def update_slug
      # Note: This will trigger calls to both rummager and the Publishing API,
      # meaning that entries in both places will exist with the correct slug
      role.update_attributes!(slug: new_slug)
    end

    def old_base_path
      Whitehall.url_maker.ministerial_role_path(old_slug)
    end

    def new_base_path
      Whitehall.url_maker.ministerial_role_path(new_slug)
    end

    def redirects
      @redirects ||= [
        { path: old_base_path, destination: new_base_path, type: "exact" },
        { path: (old_base_path + ".atom"), destination: (new_base_path + ".atom"), type: "exact" },
      ]
    end

    def register_redirect
      redirect_item = Whitehall::PublishingApi::Redirect.new(old_base_path, redirects)
      Whitehall::PublishingApi.publish_redirect(redirect_item)
    end
  end
end
