require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "post create creates contact" do
    organisation = create(:organisation)

    post :create, contact: {title: "Main office"},
      contactable_type: "Organisation",
      contactable_id: organisation.id

    assert_equal 1, organisation.contacts.count
    assert_equal "Main office", organisation.contacts.first.title
  end

  test "post create creates associated phone numbers" do
    organisation = create(:organisation)

    post :create,
      contact: {
        title: "Head office",
        contact_numbers_attributes: {
          "0" => {label: "Main phone", number: "1234"}
        }
      },
      contactable_type: "Organisation",
      contactable_id: organisation.id

    assert_equal 1, organisation.contacts.count
    assert contact = organisation.contacts.first
    assert_equal ["Main phone: 1234"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "put update updates a contact" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office")

    put :update, contact: {title: "Head office"}, id: contact

    assert_equal ["Head office"], organisation.contacts.map(&:title)
  end

  test "put update updates associated phone numbers" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office")
    contact_number = contact.contact_numbers.create(label: "Main phone", number: "1234")

    put :update,
      contact: {
        title: "Head office",
        contact_numbers_attributes: {
          "0" => {id: contact_number.id, label: "Main phone", number: "5678"}
        }
      },
      id: contact

    assert_equal 1, organisation.contacts.count
    assert contact = organisation.contacts.first
    assert_equal ["Main phone: 5678"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end
end