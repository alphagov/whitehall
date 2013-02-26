require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "POST on :create creates contact" do
    organisation = create(:organisation)
    post :create, contact: {title: "Main office"}, organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
  end

  test "POST on :create creates associated phone numbers" do
    organisation = create(:organisation)

    post :create,
      contact: {
        title: "Head office",
        contact_numbers_attributes: {
          "0" => {label: "Main phone", number: "1234"}
        }
      },
      organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal ["Main phone: 1234"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "PUT on :update updates a contact" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office")

    put :update, contact: {title: "Head office"}, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.reload.title}" updated successfully}, flash[:notice]
    assert_equal ["Head office"], organisation.contacts.map(&:title)
  end

  test "PUT on :update updates associated phone numbers" do
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
      organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.reload.title}" updated successfully}, flash[:notice]
    assert_equal ["Main phone: 5678"], contact.reload.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "DELETE on :destroy destroys the contact" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office")

    delete :destroy, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" deleted successfully}, flash[:notice]
    refute Contact.exists?(contact)
  end
end