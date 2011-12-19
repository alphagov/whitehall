require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase

  should_show_published_documents_associated_with :ministerial_role, :policies
  should_show_published_documents_associated_with :ministerial_role, :publications
  should_show_published_documents_associated_with :ministerial_role, :news_articles
  should_show_published_documents_associated_with :ministerial_role, :consultations

  test "shows only published speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)

    get :show, id: ministerial_role

    assert_select_object(published_speech)
    refute_select_object(draft_speech)
  end

  test "shows only speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    another_role_appointment = create(:role_appointment)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    another_published_speech = create(:published_speech, role_appointment: another_role_appointment)

    get :show, id: ministerial_role

    assert_select "#speeches" do
      assert_select_object(published_speech)
      refute_select_object(another_published_speech)
    end
  end

  test "shows most recent speeches at the top" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    earlier_document = create(:published_speech, role_appointment: role_appointment, published_at: 2.hours.ago)
    later_document = create(:published_speech, role_appointment: role_appointment, published_at: 1.hour.ago)

    get :show, id: ministerial_role

    assert_equal [later_document, earlier_document], assigns[:speeches]
  end

  test "should not display an empty published speeches section" do
    ministerial_role = create(:ministerial_role)

    get :show, id: ministerial_role

    refute_select "#speeches"
  end

  test "shows minister's picture if available" do
    minister = create(:person, image: File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.jpg')))
    role_appointment = create(:ministerial_role_appointment, person: minister)
    get :show, id: role_appointment.role.id

    assert_select "img[src='#{minister.image.url}']"
  end

  test "shows placeholder picture if minister has none" do
    role_appointment = create(:ministerial_role_appointment)
    get :show, id: role_appointment.role.id

    assert_select "img[src$='blank-person.jpg']"
  end
end