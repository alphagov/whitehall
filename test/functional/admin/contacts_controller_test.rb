require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "POST on :create creates contact" do
    organisation = create(:organisation)
    post :create,
      contact: {
        title: "Main office",
        contact_type_id: ContactType::General.id
      },
      organisation_id: organisation.id

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
        },
        contact_type_id: ContactType::General.id
      },
      organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal ["Main phone: 1234"], contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "POST on :create creates contact on the home page of the organisation if told to" do
    organisation = create(:organisation)
    post :create, 
      contact: {
        title: "Main office",
        show_on_home_page: '1',
        contact_type_id: ContactType::General.id
      },
      organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "POST on :create creates contact without adding to the home page of the organisation if told not to" do
    organisation = create(:organisation)
    post :create, 
      contact: {
        title: "Main office",
        show_on_home_page: '0',
        contact_type_id: ContactType::General.id
      },
      organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    refute organisation.contact_shown_on_home_page?(contact)
  end

  test "POST on :create creates contact without adding to the home page of the organisation if no suggestion made" do
    organisation = create(:organisation)
    post :create, 
      contact: {
        title: "Main office",
        contact_type_id: ContactType::General.id
      },
      organisation_id: organisation.id

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %{"#{contact.title}" created successfully}, flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    refute organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update updates a contact" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)

    put :update, contact: {title: "Head office"}, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.reload.title}" updated successfully}, flash[:notice]
    assert_equal ["Head office"], organisation.contacts.map(&:title)
  end

  test "PUT on :update updates associated phone numbers" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)
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

  test "PUT on :update adds contact to the home page of the organisation if told to" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)

    put :update,
      contact: {
        title: "Head office",
        show_on_home_page: '1',
      },
      organisation_id: organisation, id: contact

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" updated successfully}, flash[:notice]
    assert_equal "Head office", contact.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update removes contact from the home page of the organisation if told to" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    put :update,
      contact: {
        title: "Head office",
        show_on_home_page: '0',
      },
      organisation_id: organisation, id: contact

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" updated successfully}, flash[:notice]
    assert_equal "Head office", contact.title
    refute organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update doesn\'t change home page status of the organisation if no suggestion made" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    put :update,
      contact: {
        title: "Head office",
      },
      organisation_id: organisation, id: contact

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" updated successfully}, flash[:notice]
    assert_equal "Head office", contact.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "DELETE on :destroy destroys the contact" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)

    delete :destroy, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" deleted successfully}, flash[:notice]
    refute Contact.exists?(contact)
  end

  test "POST on :remove_from_home_page removes contact from the home page of the organisation" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    post :remove_from_home_page, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" removed from home page successfully}, flash[:notice]
    refute organisation.contact_shown_on_home_page?(contact)
  end

  test "POST on :add_to_home_page adds contact to the home page of the organisation" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office", contact_type: ContactType::General)

    post :add_to_home_page, organisation_id: organisation, id: contact

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{"#{contact.title}" added to home page successfully}, flash[:notice]
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test 'POST on :reorder_for_home_page takes id => ordering mappings and reorders the list based on this' do
    organisation = create(:organisation)
    contact_1 = organisation.contacts.create(title: "Head office", contact_type: ContactType::General)
    contact_2 = organisation.contacts.create(title: "Body office", contact_type: ContactType::General)
    contact_3 = organisation.contacts.create(title: 'Spirit office', contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact_1)
    organisation.add_contact_to_home_page!(contact_2)
    organisation.add_contact_to_home_page!(contact_3)

    post :reorder_for_home_page, organisation_id: organisation,
      ordering: {
        contact_1.id.to_s => '3',
        contact_2.id.to_s => '1',
        contact_3.id.to_s => '2'
      }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{Contacts on home page reordered successfully}, flash[:notice]
    assert_equal [contact_2, contact_3, contact_1], organisation.reload.home_page_contacts
  end

  test 'POST on :reorder_for_home_page doesn\'t break with unknown contact ids' do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Head office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    post :reorder_for_home_page, organisation_id: organisation,
      ordering: {
        contact.id.to_s => '2',
        '1000000' => '1'
      }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %{Contacts on home page reordered successfully}, flash[:notice]
    assert_equal [contact], organisation.reload.home_page_contacts
  end
end