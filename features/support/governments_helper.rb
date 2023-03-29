module GovernmentsHelper
  def create_government(name:, start_date: nil, end_date: nil)
    visit admin_governments_path

    click_on using_design_system? ? "Create new government" : "Create a government"

    fill_in "Name", with: name

    if using_design_system?
      within "#government_start_date" do
        fill_in_date_fields(start_date) if start_date
      end

      within "#government_end_date" do
        fill_in_date_fields(end_date) if end_date
      end
    else
      fill_in "Start date", with: start_date if start_date
      fill_in "End date", with: end_date if end_date
    end

    click_on "Save"
  end

  def edit_government(name:, attributes:)
    visit admin_governments_path

    click_on name

    if using_design_system?
      within "#government_start_date" do
        fill_in_date_fields(attributes[:start_date]) if attributes[:start_date]
      end

      within "#government_end_date" do
        fill_in_date_fields(attributes[:end_date]) if attributes[:end_date]
      end
    else
      attributes.each do |attribute, value|
        fill_in attribute.to_s.humanize, with: value
      end
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

    click_on using_design_system? ? "Close this government" : "Yes, close this government"
  end

  def count_active_ministerial_role_appointments
    RoleAppointment.current.for_ministerial_roles.count
  end
end

World(GovernmentsHelper)
