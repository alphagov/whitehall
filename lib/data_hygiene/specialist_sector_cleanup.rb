class SpecialistSectorCleanup
  def initialize(slug)
    @slug = slug
  end

  def any_taggings?
    taggings.any?
  end

  def remove_taggings
    taggings.each do |tagging|
      edition = tagging.edition

      if edition
        puts "Removing tagging to edition ##{edition.id}"
      else
        puts "Removing tagging where edition was nil"
      end

      tagging.destroy

      if edition.nil?
        puts "no edition (probably deleted)"
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
      puts "edition is frozen; not adding editorial remark"
    else
      puts "adding an editorial remark"

      edition.editorial_remarks.create!(
        author: gds_user,
        body: "Automatically untagged from old sector '#{@slug}'"
      )
    end
  end

  def register_edition(edition)
    puts "registering '#{edition.slug}' (id #{edition.id})"
    edition.reload
    register_with_panopticon(edition)
    register_with_publishing_api(edition)
    register_with_search(edition)
  end

  def register_with_panopticon(edition)
    registerable_edition = RegisterableEdition.new(edition)
    registerer           = Whitehall.panopticon_registerer_for(registerable_edition)
    registerer.register(registerable_edition)
  end

  def register_with_publishing_api(edition)
    Whitehall::PublishingApi.republish(edition)
  end

  def register_with_search(edition)
    edition.update_in_search_index
  end

  def gds_user
    @gds_user ||= User.find_by(email: "govuk-whitehall@digital.cabinet-office.gov.uk")
  end

  def taggings
    SpecialistSector.where(tag: @slug)
  end
end
