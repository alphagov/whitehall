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
      if organisation.is_a? Organisation
        update_child_and_parent_organisations_in_search
        update_users
        update_editions
      end
    end

  private

    attr_reader :organisation, :new_slug, :old_slug

    def remove_from_search_index
      Whitehall::SearchIndex.delete(organisation)
    end

    def update_slug
      # NOTE: This will trigger calls to both search_api and the Publishing API,
      # meaning that entries in both places will exist with the correct slug
      organisation.update!(slug: new_slug)
    end

    def update_child_and_parent_organisations_in_search
      organisation.child_organisations.each do |child_org|
        Whitehall::SearchIndex.add(child_org)
      end
      organisation.parent_organisations.each do |parent_org|
        Whitehall::SearchIndex.add(parent_org)
      end
    end

    def update_users
      User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
    end

    def update_editions
      organisation.editions.published.each(&:update_in_search_index)
    end

    def new_base_path
      case organisation
      when Organisation
        new_slug.public_path
      end
    end
  end
end
