module CorporateInformationPagesHelper

  def render_corporate_info_header_for(organisation)
    render(partial: "#{organisation.class.table_name}/header", locals: { organisation: organisation, link_to_organisation: true})
  end
end
