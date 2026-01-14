module DataHygiene
  # Reslugs an organisation to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Organisation's slug
  #   - republishes the org to Publishing API (which creates a redirect)
  #   - reindexes the org for search
  #   - reindexes all dependent documents in search
  #
  #
  class OrganisationReslugger
    def initialize(organisation, new_slug)
      @organisation = organisation
      @new_slug = new_slug
      @old_slug = @organisation.slug
    end

    def run!
      update_slug
      if organisation.is_a? Organisation
        update_users
      end
    end

  private

    attr_reader :organisation, :new_slug, :old_slug

    def update_slug
      # NOTE: This will trigger calls to both search_api and the Publishing API,
      # meaning that entries in both places will exist with the correct slug
      organisation.update!(slug: new_slug)
    end

    def update_users
      User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
    end
  end
end
