class ServicesAndInformationController < PublicFacingController
  before_filter :load_organisation, only: [:show]
  before_filter :set_organisation_slimmer_headers, only: [:show]

  def show
    if organisation_has_services_and_information_content?
      collection_groups
    else
      render status: 404
    end
  end

private

  def organisation_has_services_and_information_content?
    !collection_groups.blank?
  end

  def collection_groups
    @collection_groups ||= build_services_and_information_collection_group
  end

  def load_organisation
    @organisation = Organisation.with_translations(I18n.locale).find(params[:organisation_id])
  end

  def set_organisation_slimmer_headers
    set_slimmer_organisations_header([@organisation])
    set_slimmer_page_owner_header(@organisation)
  end

  def build_services_and_information_collection_group
    ServicesAndInformationCollection.build_collection_group_from(parsed_search_results)
  end

  def parsed_search_results
    ServicesAndInformationParser.new(search_results).parse
  end

  def search_results
    ServicesAndInformationFinder.new(@organisation, search_client).find
  end

  def search_client
    Whitehall.unified_search_client
  end
end
