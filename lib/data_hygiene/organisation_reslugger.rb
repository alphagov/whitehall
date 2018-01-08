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
      remove_from_search_index
      update_slug
      update_users if organisation.is_a? Organisation
      update_editions if organisation.is_a? Organisation
    end

  private

    attr_reader :organisation, :new_slug, :old_slug

    def remove_from_search_index
      Whitehall::SearchIndex.delete(organisation)
    end

    def update_slug
      # Note: This will trigger calls to both rummager and the Publishing API,
      # meaning that entries in both places will exist with the correct slug
      organisation.update_attributes!(slug: new_slug)
    end

    def update_users
      User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
    end

    def update_editions
      organisation.editions.published.each do |edition|
        edition.update_in_search_index
      end
    end

    def new_base_path
      case organisation
      when Organisation
        Whitehall.url_maker.organisation_path(new_slug)
      when WorldwideOrganisation
        Whitehall.url_maker.worldwide_organisation_path(new_slug)
      end
    end
  end
end
