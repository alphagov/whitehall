module GovernmentsHelper
  def create_government(name:, start_date: nil, end_date: nil)
    visit admin_governments_path

    button_text = using_design_system? ? "Create new government" : "Create a government"

    click_on button_text

    fill_in "Name", with: name
    fill_in "Start date", with: start_date if start_date
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

  def check_for_government(name:, start_date: nil, end_date: nil, current: false)
    visit admin_governments_path

    rows = all("table tr")

    matching_row = rows.find do |row|
      row.has_content?(name) &&
        (start_date.nil? || row.has_content?(start_date)) &&
        (end_date.nil? || row.has_content?(end_date)) &&
        (current.nil? || current == row.has_content?("Yes"))
    end

    expect(matching_row).to be_present
  end

  def check_for_current_government(name:)
    expect(Government.find_by_name(name).current?).to be(true)
  end

  def close_government(name:)
    visit admin_governments_path

    click_on name

    click_on "Prepare to close this government"
    click_on "Yes, close this government"
  end

  def count_active_ministerial_role_appointments
    RoleAppointment.current.for_ministerial_roles.count
  end
end

World(GovernmentsHelper)
