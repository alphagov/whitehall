module CorporateInformationPagesHelper
  def render_corporate_info_header_for(organisation, corporate_information_page = nil)
    render(
      partial: "header",
      locals: {
        organisation: organisation,
        link_to_organisation: true,
        object_for_translation: corporate_information_page,
      },
    )
  end
end
