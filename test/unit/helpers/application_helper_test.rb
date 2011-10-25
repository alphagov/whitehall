require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

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

  test '#link_to_attachment returns nil when attachment is nil' do
    assert_nil link_to_attachment(nil)
  end

  test '#link_to_attachment returns link to an attachment given attachment' do
    attachment = create(:attachment)
    assert_equal %{<a href="#{attachment.url}">#{File.basename(attachment.filename)}</a>}, link_to_attachment(attachment)
  end
end
