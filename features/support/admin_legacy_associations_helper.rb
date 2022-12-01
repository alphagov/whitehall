module AdminLegacyAssociationsHelper
  def set_all_legacy_associations
    tag_specialist_sectors
    click_button "Update specialist topics"
  end

  def check_associations_have_been_saved
    check_specialist_sectors
  end

  def check_legacy_associations_are_displayed_on_admin_page
    assert_selected_specialist_sectors_are_displayed
  end

private

  def tag_specialist_sectors
    select "Oil and Gas: Wells", from: "edition[primary_specialist_sector_tag]"
    select "Oil and Gas: Fields", from: "edition[secondary_specialist_sector_tags][]"
    select "Oil and Gas: Offshore", from: "edition[secondary_specialist_sector_tags][]"
  end

  def check_specialist_sectors
    expect("WELLS").to eq(Publication.last.primary_specialist_sector_tag)
    expect(%w[FIELDS OFFSHORE]).to eq(Publication.last.secondary_specialist_sector_tags)
  end

  def assert_selected_specialist_sectors_are_displayed
    expect(page).to have_selector(".primary-specialist-sector li", text: "Oil and Gas: Wells")
    expect(page).to have_selector(".secondary-specialist-sectors li", text: "Oil and Gas: Fields")
    expect(page).to have_selector(".secondary-specialist-sectors li", text: "Oil and Gas: Offshore")

    expect(page).to_not have_selector(".primary-specialist-sector li", text: "Oil and Gas: Fields")
    expect(page).to_not have_selector(".secondary-specialist-sectors li", text: "Oil and Gas: Wells")
  end
end

World(AdminLegacyAssociationsHelper)
