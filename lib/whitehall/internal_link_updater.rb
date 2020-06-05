class Whitehall::InternalLinkUpdater
  include GovspeakHelper

  attr_reader :linked_to_edition

  def initialize(linked_to_edition)
    @linked_to_edition = linked_to_edition
  end

  def call
    update_all_linking_editions(linked_to_edition)
  end

private

  def update_all_linking_editions(linked_to_edition)
    linked_from_editions(linked_to_edition).each do |linked_from_edition|
      update_all_translations(linked_from_edition)
    end
  end

  def update_all_translations(linked_from_edition)
    linked_from_edition.translations.each do |translation|
      replace_translation_links(translation)
    end
  end

  def replace_translation_links(translation)
    whitehall_admin_links(translation.body).each do |whitehall_admin_link|
      if whitehall_admin_link_edition(whitehall_admin_link).document_id == linked_to_edition.document_id
        translation.body.sub!(whitehall_admin_link, edition_public_url(linked_to_edition))
      end
    end
    translation.save!(touch: false)
  end

  def linked_from_editions(edition)
    EditionDependency.where(dependable_id: edition.id, dependable_type: "Edition").map(&:edition)
  end

  def whitehall_admin_links(body)
    govspeak = build_govspeak_document(body)
    Govspeak::LinkExtractor.new(govspeak).call
  end

  def whitehall_admin_link_edition(link)
    Whitehall::AdminLinkLookup.find_edition(link)
  end

  def edition_public_url(edition)
    Whitehall.url_maker.public_document_url(edition)
  end
end
