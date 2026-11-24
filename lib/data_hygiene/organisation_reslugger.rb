module DataHygiene
  # Reslugs an organisation to new_slug.
  #
  # When run, the following happens:
  #
  #   - updates the Organisation's slug
  #   - republishes the org to Publishing API (which creates a redirect)
  #   - republishes the org's corporate information pages (live and draft),
  #     whose paths are derived from the org's slug
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
        republish_corporate_information_pages
      end
    end

  private

    attr_reader :organisation, :new_slug, :old_slug

    def update_slug
      # NOTE: This will trigger calls to the Publishing API.
      organisation.update!(slug: new_slug)
    end

    def republish_corporate_information_pages
      organisation.corporate_information_pages.map(&:document).uniq.each do |document|
        Whitehall::PublishingApi.republish_document_async(document)
      end
    end

    def update_users
      User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
    end
  end
end
