module FatalitiesHelper
  def draft_fatality_notice(title, field, policy)
    policies = publishing_api_has_policies([policy])

    create(:operational_field, name: field)
    begin_drafting_document type: "fatality_notice", title: title, summary: "fatality notice summary", previously_published: false
    fill_in "Introduction", with: "fatality notice roll call introduction"
    select field, from: "Field of operation"
    click_button "Next"
    select policy, from: "Policies"
    click_button "Save legacy associations"
  end
end

World(FatalitiesHelper)
