require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "should supply options with IDs and descriptions for the current ministerial appointments" do
    home_office = create(:organisation, name: "Home Office")
    ministry_of_defence = create(:organisation, name: "Ministry of Defence")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    defence_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [ministry_of_defence])
    theresa_may = create(:person, name: "Theresa May")
    philip_hammond = create(:person, name: "Philip Hammond")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    philip_hammond_appointment = create(:role_appointment, role: defence_secretary, person: philip_hammond)

    options = ministerial_appointment_options

    assert_equal 2, options.length
    assert_equal options.first, [philip_hammond_appointment.id, "Philip Hammond (Secretary of State, Ministry of Defence)"]
    assert_equal options.last, [theresa_may_appointment.id, "Theresa May (Secretary of State, Home Office)"]
  end

  test "should not include non-current appointments" do
    create(:ministerial_role_appointment, started_at: 2.weeks.ago, ended_at: 1.week.ago)
    assert_equal [], ministerial_appointment_options
  end

  test "should not include non-ministerial appointments" do
    create(:board_member_role_appointment)
    assert_equal [], ministerial_appointment_options
  end

  test '#link_to_attachment returns nil when attachment is nil' do
    assert_nil link_to_attachment(nil)
  end

  test '#link_to_attachment returns link to an attachment given attachment' do
    attachment = create(:attachment)
    assert_equal %{<a href="#{attachment.url}">#{File.basename(attachment.filename)}</a>}, link_to_attachment(attachment)
  end

  test "should format into paragraphs" do
    assert_equal "", format_in_paragraphs(nil)
    assert_equal "", format_in_paragraphs("")
    assert_equal "<p>line one</p>", format_in_paragraphs("line one")
  end

  test "should raise unless you supply the content of the list item" do
    e = assert_raise(ArgumentError) { render_list_of_ministerial_roles([]) }
    assert_match /please supply the content of the list item/i, e.message
  end

  test "should render a list of ministerial roles" do
    roles = [build(:ministerial_role, name: "Jack"), build(:ministerial_role,  name: "Jill")]
    html = render_list_of_ministerial_roles(roles) { |ministerial_role| "<p>#{ministerial_role.name}</p>" }
    assert_select_in_html(html, 'ul li p', text: "Jack")
    assert_select_in_html(html, 'ul li p', text: "Jill")
  end
end
