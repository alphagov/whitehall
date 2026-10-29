require "test_helper"

class Admin::ContactsControllerTest < ActionController::TestCase
  setup do
    @organisation = create(:organisation)
    login_as(:departmental_editor, @organisation)
  end

  should_be_an_admin_controller

  test "POST on :create creates contact" do
    organisation = @organisation
    post :create,
         params: {
           contact: {
             title: "Main office",
             contact_type_id: ContactType::General.id,
           },
           organisation_id: organisation.id,
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %("#{contact.title}" created successfully), flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
  end

  test "POST on :create creates associated phone numbers" do
    organisation = @organisation

    post :create,
         params: {
           contact: {
             title: "Head office",
             contact_numbers_attributes: {
               "0" => { label: "Main phone", number: "1234" },
             },
             contact_type_id: ContactType::General.id,
           },
           organisation_id: organisation.id,
         }

    contact = organisation.contacts.last
    actual_numbers = contact
                       .contact_numbers
                       .map { |cn| "#{cn.label}: #{cn.number}" }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.title}" created successfully), flash[:notice]
    assert_equal ["Main phone: 1234"], actual_numbers
  end

  test "POST on :create creates contact on the home page of the organisation if told to" do
    organisation = @organisation
    post :create,
         params: {
           contact: {
             title: "Main office",
             show_on_home_page: "1",
             contact_type_id: ContactType::General.id,
           },
           organisation_id: organisation.id,
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %("#{contact.title}" created successfully), flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "POST on :create creates contact without adding to the home page of the organisation if told not to" do
    organisation = @organisation
    post :create,
         params: {
           contact: {
             title: "Main office",
             show_on_home_page: "0",
             contact_type_id: ContactType::General.id,
           },
           organisation_id: organisation.id,
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %("#{contact.title}" created successfully), flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    assert_not organisation.contact_shown_on_home_page?(contact)
  end

  test "POST on :create creates contact without adding to the home page of the organisation if no suggestion made" do
    organisation = @organisation
    post :create,
         params: {
           contact: {
             title: "Main office",
             contact_type_id: ContactType::General.id,
           },
           organisation_id: organisation.id,
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert contact = organisation.contacts.last
    assert_equal %("#{contact.title}" created successfully), flash[:notice]
    assert_equal "Main office", organisation.contacts.first.title
    assert_not organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update updates a contact" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)

    put :update, params: { contact: { title: "Head office" }, organisation_id: organisation, id: contact }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.reload.title}" updated successfully), flash[:notice]
    assert_equal ["Head office"], organisation.contacts.map(&:title)
  end

  test "PUT on :update updates associated phone numbers" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)
    contact_number = contact.contact_numbers.create!(label: "Main phone", number: "1234")

    put :update,
        params: {
          contact: {
            title: "Head office",
            contact_numbers_attributes: {
              "0" => { id: contact_number.id, label: "Main phone", number: "5678" },
            },
          },
          organisation_id: organisation,
          id: contact,
        }

    actual_numbers = contact
                       .reload
                       .contact_numbers
                       .map { |cn| "#{cn.label}: #{cn.number}" }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.reload.title}" updated successfully), flash[:notice]
    assert_equal ["Main phone: 5678"], actual_numbers
  end

  test "PUT on :update adds contact to the home page of the organisation if told to" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)

    put :update,
        params: {
          contact: {
            title: "Head office",
            show_on_home_page: "1",
          },
          organisation_id: organisation,
          id: contact,
        }

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.title}" updated successfully), flash[:notice]
    assert_equal "Head office", contact.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update removes contact from the home page of the organisation if told to" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    put :update,
        params: {
          contact: {
            title: "Head office",
            show_on_home_page: "0",
          },
          organisation_id: organisation,
          id: contact,
        }

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.title}" updated successfully), flash[:notice]
    assert_equal "Head office", contact.title
    assert_not organisation.contact_shown_on_home_page?(contact)
  end

  test "PUT on :update doesn\'t change home page status of the organisation if no suggestion made" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    put :update,
        params: {
          contact: {
            title: "Head office",
          },
          organisation_id: organisation,
          id: contact,
        }

    contact.reload
    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.title}" updated successfully), flash[:notice]
    assert_equal "Head office", contact.title
    assert organisation.contact_shown_on_home_page?(contact)
  end

  test "GET :should be able to visit confirm_destroy page for a contact" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)

    get :confirm_destroy, params: { organisation_id: organisation, id: contact }

    assert_response :success
    assert_equal contact, assigns(:contact)
  end

  test "DELETE on :destroy destroys the contact" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Main office", contact_type: ContactType::General)

    delete :destroy, params: { organisation_id: organisation, id: contact }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %("#{contact.title}" deleted successfully), flash[:notice]
    assert_not Contact.exists?(contact.id)
  end

  view_test "GET :should be able to visit reorder page" do
    organisation = @organisation

    get :reorder, params: { organisation_id: organisation }

    assert_template :reorder
    assert_response :success
    assert_select "h1", "Reorder contacts"
  end

  test "POST on :reorder_for_home_page takes id => ordering mappings and reorders the list based on this" do
    organisation = @organisation
    contact1 = organisation.contacts.create!(title: "Head office", contact_type: ContactType::General)
    contact2 = organisation.contacts.create!(title: "Body office", contact_type: ContactType::General)
    contact3 = organisation.contacts.create!(title: "Spirit office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact1)
    organisation.add_contact_to_home_page!(contact2)
    organisation.add_contact_to_home_page!(contact3)

    post :reorder_for_home_page,
         params: {
           organisation_id: organisation,
           ordering: {
             contact1.id.to_s => "3",
             contact2.id.to_s => "1",
             contact3.id.to_s => "2",
           },
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %(Contacts on home page reordered successfully), flash[:notice]
    assert_equal [contact2, contact3, contact1], organisation.reload.home_page_contacts
  end

  test "POST on :reorder_for_home_page doesn't break with unknown contact ids" do
    organisation = @organisation
    contact = organisation.contacts.create!(title: "Head office", contact_type: ContactType::General)
    organisation.add_contact_to_home_page!(contact)

    post :reorder_for_home_page,
         params: {
           organisation_id: organisation,
           ordering: {
             contact.id.to_s => "2",
             "1000000" => "1",
           },
         }

    assert_redirected_to admin_organisation_contacts_url(organisation)
    assert_equal %(Contacts on home page reordered successfully), flash[:notice]
    assert_equal [contact], organisation.reload.home_page_contacts
  end

  test "actions are forbidden for users outside the organisation" do
    other_organisation = create(:organisation)
    contact = create(:contact, contactable: other_organisation, title: "Head office")

    post :create, params: { organisation_id: other_organisation, contact: { title: "Main office", contact_type_id: ContactType::General.id } }
    assert_response :forbidden
    assert_equal [contact], other_organisation.contacts.reload

    put :update, params: { organisation_id: other_organisation, id: contact, contact: { title: "Updated", show_on_home_page: "1" } }
    assert_response :forbidden
    assert_equal "Head office", contact.reload.title
    assert_not other_organisation.reload.contact_shown_on_home_page?(contact)

    delete :destroy, params: { organisation_id: other_organisation, id: contact }
    assert_response :forbidden
    assert Contact.exists?(contact.id)

    post :reorder_for_home_page, params: { organisation_id: other_organisation, ordering: { contact.id.to_s => "1" } }
    assert_response :forbidden

    %i[new reorder].each do |action|
      get action, params: { organisation_id: other_organisation }
      assert_response :forbidden
    end

    %i[edit confirm_destroy].each do |action|
      get action, params: { organisation_id: other_organisation, id: contact }
      assert_response :forbidden
    end
  end

  view_test "GET :index shows actions to users who can edit the organisation" do
    contact = create(:contact, contactable: @organisation, translated_into: [:fr])

    get :index, params: { organisation_id: @organisation }

    assert_select "a[href=?]", new_admin_organisation_contact_path(@organisation)
    assert_select "a[href=?]", edit_admin_organisation_contact_path(@organisation, contact)
    assert_select "a[href=?]", confirm_destroy_admin_organisation_contact_path(@organisation, contact)
    assert_select "a[href=?]", confirm_destroy_admin_organisation_contact_translation_path(@organisation, contact, "fr")
  end

  view_test "GET :index hides actions from users who cannot edit the organisation" do
    other_organisation = create(:organisation)
    contact = create(:contact, contactable: other_organisation, translated_into: [:fr])

    get :index, params: { organisation_id: other_organisation }

    assert_response :success
    refute_select "a[href=?]", new_admin_organisation_contact_path(other_organisation)
    refute_select "a[href=?]", edit_admin_organisation_contact_path(other_organisation, contact)
    refute_select "a[href=?]", confirm_destroy_admin_organisation_contact_path(other_organisation, contact)
    refute_select "a[href=?]", admin_organisation_contact_translations_path(other_organisation, contact)
    refute_select "a[href=?]", edit_admin_organisation_contact_translation_path(other_organisation, contact, "fr")
    refute_select "a[href=?]", confirm_destroy_admin_organisation_contact_translation_path(other_organisation, contact, "fr")
  end
end
