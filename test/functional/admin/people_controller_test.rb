# encoding: utf-8
require 'test_helper'

class Admin::PeopleControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "new shows form for creating a person" do
    get :new

    assert_select "form[action='#{admin_people_path}']" do
      assert_select "input[name='person[privy_counsellor]'][type=checkbox]"
      assert_select "input[name='person[title]'][type=text]"
      assert_select "input[name='person[forename]'][type=text]"
      assert_select "input[name='person[surname]'][type=text]"
      assert_select "input[name='person[letters]'][type=text]"
      assert_select "input[name='person[image]'][type=file]"
      assert_select "textarea[name='person[biography]']"
    end
  end

  view_test "creating with invalid data shows errors" do
    post :create, params: { person: { title: "", forename: "", surname: "", letters: "" } }

    assert_select ".form-errors"
  end

  test "creating with valid data creates a new person" do
    attributes = attributes_for(:person, title: "person-title", forename: "person-forename", surname: "person-surname", letters: "person-letters", biography: "person-biography")

    post :create, params: { person: attributes }

    refute_nil person = Person.last
    assert_equal attributes[:title], person.title
    assert_equal attributes[:forename], person.forename
    assert_equal attributes[:surname], person.surname
    assert_equal attributes[:letters], person.letters
    assert_equal attributes[:biography], person.biography
  end

  test "creating with valid data redirects to the index" do
    post :create, params: { person: attributes_for(:person) }

    assert_redirected_to admin_person_url(Person.last)
  end

  test "creating allows attachment of an image" do
    attributes = attributes_for(:person)
    attributes[:image] = fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg')
    post :create, params: { person: attributes }

    refute_nil Person.last.image
  end

  test "GET on :show assigns the person and renders the show page" do
    person = create(:person)
    get :show, params: { id: person }

    assert_equal person, assigns(:person)
    assert_response :success
    assert_template :show
  end

  view_test "editing shows form for editing a person" do
    person = create(:person, image: fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg'))
    get :edit, params: { id: person }

    assert_select "form[action='#{admin_person_path}']" do
      assert_select "input[name='person[title]'][type=text]"
      assert_select "input[name='person[forename]'][type=text]"
      assert_select "input[name='person[surname]'][type=text]"
      assert_select "input[name='person[letters]'][type=text]"
      assert_select "input[name='person[image]'][type=file]"
      assert_select "textarea[name='person[biography]']"
    end
  end

  view_test "editing shows existing image" do
    person = create(:person, image: fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg'))
    get :edit, params: { id: person }

    assert_select "img[src='#{person.image_url}']"
  end

  view_test "updating with invalid data shows errors" do
    person = create(:person)

    put :update, params: { id: person.id, person: { title: "", forename: "", surname: "", letters: "" } }

    assert_select ".form-errors"
  end

  test "updating with valid data redirects to the index" do
    person = create(:person)

    put :update, params: { id: person.id, person: attributes_for(:person) }

    assert_redirected_to admin_person_url(person)
  end

  test "should be able to destroy a destroyable person" do
    person = create(:person, forename: "Dave")
    delete :destroy, params: { id: person.id }

    assert_response :redirect
    assert_equal %{"Dave" destroyed.}, flash[:notice]
  end

  test "destroying a person which has an appointment" do
    person = create(:person)
    create(:role_appointment, person: person)

    delete :destroy, params: { id: person.id }
    assert_equal "Cannot destroy a person with appointments", flash[:alert]
  end

  test "lists people in alphabetical name order" do
    person_b = create(:person, forename: "B")
    person_a = create(:person, forename: "A")
    person_c = create(:person, forename: "C")

    get :index

    assert_equal %w(A B C), assigns(:people).map(&:name)
  end

  view_test "lists people displaying the first bit of their biography" do
    person = create(:person, title: "Colonel", surname: "Hathi", biography: %{Hathi is head of the elephant troop. He is one of the oldest animals of the jungle and represents order, dignity and obedience to the Law of the Jungle. In "How Fear Came", he tells the jungle animals' creation myth and describes Tha, the Creator.})

    get :index

    assert_select ".people .person .biography", text: %r{^Hathi is head of the elephant troop}
  end
end
