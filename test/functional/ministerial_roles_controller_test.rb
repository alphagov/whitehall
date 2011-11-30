require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase
  test "shows only published policies associated with ministerial role" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    ministerial_role = create(:ministerial_role, documents: [published_document, draft_document])
    get :show, id: ministerial_role
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published publications associated with ministerial role" do
    published_document = create(:published_publication)
    draft_document = create(:draft_publication)
    ministerial_role = create(:ministerial_role, documents: [published_document, draft_document])
    get :show, id: ministerial_role
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published news articles associated with ministerial role" do
    published_document = create(:published_news_article)
    draft_document = create(:draft_news_article)
    ministerial_role = create(:ministerial_role, documents: [published_document, draft_document])
    get :show, id: ministerial_role
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_document = create(:published_speech, role_appointment: role_appointment)
    draft_document = create(:draft_speech, role_appointment: role_appointment)
    get :show, id: ministerial_role
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
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