class CorporateInformationPagesController < DocumentsController
  prepend_before_action :find_organisation
  before_action :set_slimmer_headers_for_document, only: %i[show index]

  def show
    @corporate_information_page = @document

    render "show_worldwide_organisation"
  end

private

  def document_class
    CorporateInformationPage
  end

  def find_unpublishing
    # Find all unpublishings associated with a CIP edition whose organisation
    # is @organisation and which have slug from params (because slug can change
    # after edition is unpublished, but org cannot).
    # Use manual join because base Edition does not have a direct relationship
    # to Organisation, and the assocation with Unpublishing is not polymorphic.
    Unpublishing.joins(
      "JOIN edition_organisations ON edition_organisations.edition_id = unpublishings.edition_id",
    ).where(
      edition_organisations: { organisation_id: @organisation.id }, slug: params[:id], document_type: document_class.to_s,
    ).first
  end

  def find_document_or_edition_for_public
    published_edition = @organisation.corporate_information_pages.published.for_slug(params[:id])
    published_edition if published_edition.present? && published_edition.available_in_locale?(I18n.locale)
  end

  def set_slimmer_headers_for_document
    set_slimmer_organisations_header([@organisation])
    set_slimmer_page_owner_header(@organisation)
  end

  def find_organisation
    @organisation = WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
  end
end
