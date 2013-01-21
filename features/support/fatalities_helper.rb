module FatalitiesHelper
  def draft_fatality_notice(title, field)
    create(:operational_field, name: field)
    begin_drafting_document type: "fatality_notice", title: title, summary: "fatality notice summary"
    fill_in "Introduction", with: "fatality notice roll call introduction"
    select field, from: "Field of operation"
    click_button "Save"
  end
end

World(FatalitiesHelper)
