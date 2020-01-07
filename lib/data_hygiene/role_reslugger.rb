module DataHygiene
  # Reslugs a role to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Role record's slug
  #   - reindexes the role for search
  #   - republishes the role to Publishing API
  #   - publishes a redirect to Publishing API
  #   - reindexes all dependent documents in search
  #
  class RoleReslugger
    def initialize(role, new_slug)
      @role = role
      @new_slug = new_slug
      @old_slug = @role.slug
    end

    def run!
      update_slug
    end

  private

    attr_reader :role, :new_slug, :old_slug

    def update_slug
      # Note: This will trigger calls to the Publishing API.
      role.update!(slug: new_slug)
    end
  end
end
