=begin
Specialist sector cleanup

A `SpecialistSector` is a join model which associates an edition with a
specialist sector tag. The specialist sectors are not stored in whitehall,
they are produced by collections publisher and stored in the content-store
(they used to be in panopticon).

If a SpecialistSector is removed, these associations need to be deleted,
otherwise whitehall will display links to no-existent pages from the edition
show pages.

After removing these associations we also need to inform dependent systems
about the change, in particular:

* rummager (which records the association in search document)
* content-store (which records the association from the content item to the
  SpecialistSector in the details hash, so it's not able to benefit from the
  dynamic resolution of associations provided by content store)
* content-api/panopticon (stores )

This is done by using the `EditionReregisterer`

Does the following:

* removes the Deletes any SpecialistSector records.

=end

class SpecialistSectorCleanup
  attr_reader :logger

  def initialize(specialist_sector_slug, logger: Logger.new(nil))
    @specialist_sector_slug = specialist_sector_slug
    @logger = logger
  end

  def any_taggings?
    taggings.any?
  end

  def remove_taggings
    taggings.each do |tagging|
      edition = tagging.edition

      if edition
        logger.info "Removing tagging to edition ##{edition.id}"
      else
        logger.info "Removing tagging where edition was nil"
      end

      tagging.destroy

      if edition.nil?
        logger.info "no edition (probably deleted)"
      else
        add_remark(edition)

        if edition.state == 'published'
          register_edition(edition)
        end
      end
    end
  end

private

  def add_remark(edition)
    if Edition::FROZEN_STATES.include?(edition.state)
      logger.info "edition is frozen; not adding editorial remark"
    else
      logger.info "adding an editorial remark"

      edition.editorial_remarks.create!(
        author: gds_user,
        body: "Automatically untagged from old sector '#{@specialist_sector_slug}'"
      )
    end
  end

  def register_edition(edition)
    logger.info "registering '#{edition.slug}' (id #{edition.id})"
    edition.reload
    Whitehall.edition_services.publisher(edition).perform!
  end

  def gds_user
    @gds_user ||= User.find_by(email: "govuk-whitehall@digital.cabinet-office.gov.uk")
  end

  def taggings
    SpecialistSector.where(tag: @specialist_sector_slug)
  end
end
