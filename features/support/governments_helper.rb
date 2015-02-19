module GovernmentsHelper
  def create_government(name:, start_date:, end_date: nil)
    visit admin_governments_path

    click_on "Create a government"

    fill_in "Name", with: name
    fill_in "Start date", with: start_date
    fill_in "End date", with: end_date if end_date

    click_on "Save"
  end

  def edit_government(name:, attributes:)
    visit admin_governments_path

    click_on name

    attributes.each do |attribute, value|
      fill_in attribute.to_s.humanize, with: value
    end

    click_on "Save"
  end

  def check_for_government(name:, start_date:, end_date: nil)
    visit admin_governments_path

    government = Government.find_by_name(name)

    within("#government_#{government.id}") do
      assert page.has_content?(name)
      assert page.has_content?(start_date)
      assert page.has_content?(end_date) if end_date
    end
  end
end

World(GovernmentsHelper)
