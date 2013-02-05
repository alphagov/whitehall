require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "post create creates contact" do
    worldwide_office = create(:worldwide_office)

    post :create, contact: {title: "Main office"},
      contactable_type: "WorldwideOffice",
      contactable_id: worldwide_office.id

    assert_equal 1, worldwide_office.contacts.count
    assert_equal "Main office", worldwide_office.contacts.first.title
  end

  test "post create creates associated phone numbers" do
    worldwide_office = create(:worldwide_office)

    post :create,
      contact: {
        title: "Head office",
        contact_numbers_attributes: {
          "0" => {label: "Main phone", number: "1234"}
        }
      },
      contactable_type: "WorldwideOffice",
      contactable_id: worldwide_office.id

    assert_equal 1, worldwide_office.contacts.count
    assert contact = worldwide_office.contacts.first
    assert_equal ["Main phone: 1234"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "put update updates a contact" do
    worldwide_office = create(:worldwide_office)
    contact = worldwide_office.contacts.create(title: "Main office")

    put :update, contact: {title: "Head office"}, id: contact

    assert_equal ["Head office"], worldwide_office.contacts.map(&:title)
  end

  test "put update updates associated phone numbers" do
    worldwide_office = create(:worldwide_office)
    contact = worldwide_office.contacts.create(title: "Main office")
    contact_number = contact.contact_numbers.create(label: "Main phone", number: "1234")

    put :update,
      contact: {
        title: "Head office",
        contact_numbers_attributes: {
          "0" => {id: contact_number.id, label: "Main phone", number: "5678"}
        }
      },
      id: contact

    assert_equal 1, worldwide_office.contacts.count
    assert contact = worldwide_office.contacts.first
    assert_equal ["Main phone: 5678"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end
end