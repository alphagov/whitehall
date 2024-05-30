require "test_helper"

class Admin::WorldwideOfficesControllerTest < ActionController::TestCase
  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "GET :edit correctly renders the form page for editing" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    get :edit, params: {
      worldwide_organisation_id: worldwide_organisation.id,
      id: office.id,
    }

    assert_response :success
  end

  test "post create creates worldwide office" do
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
    assert_equal 1, worldwide_organisation.reload.offices.count
    assert_equal "Main office", worldwide_organisation.offices.first.contact.title
    assert_equal "Main office has been added", flash[:notice]
  end

  test "post create creates worldwide office on the home page of the world org if told to" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
             show_on_home_page: "1",
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    new_office = worldwide_organisation.reload.offices.last
    assert_equal "Main office", new_office.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office without adding it to the home page of the world org if told not to" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
             show_on_home_page: "0",
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    new_office = worldwide_organisation.reload.offices.last
    assert_equal "Main office", new_office.contact.title
    assert_not worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office without adding it to the home page of the world org if no suggestion made" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    new_office = worldwide_organisation.reload.offices.last
    assert_equal "Main office", new_office.contact.title
    assert_not worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office with services" do
    service1 = create(:worldwide_service)
    service2 = create(:worldwide_service)
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
             service_ids: [service2.id, service1.id],
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    assert_equal 1, worldwide_organisation.reload.offices.count
    assert_equal [service1, service2], worldwide_organisation.offices.first.services.sort_by(&:id)
  end

  test "post create creates associated phone numbers" do
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Head office",
               contact_type_id: ContactType::General.id,
               contact_numbers_attributes: {
                 "0" => { label: "Main phone", number: "1234" },
               },
             },
           },
           worldwide_organisation_id: worldwide_organisation.id,
         }

    actual_numbers = worldwide_organisation
                       .reload
                       .offices
                       .first
                       .contact
                       .contact_numbers
                       .map { |cn| "#{cn.label}: #{cn.number}" }

    assert_equal 1, worldwide_organisation.offices.count
    assert_equal ["Main phone: 1234"], actual_numbers
  end

  test "put update updates an office" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
            },
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_equal "Head office", office.reload.contact.title
    assert_equal "Head office has been edited", flash[:notice]
  end

  test "put update updates an office adding it to the home page of the world org if told to" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
            },
            show_on_home_page: "1",
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_equal "Head office", office.reload.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "put update updates an office removing it from the home page of the world org if told to" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
            },
            show_on_home_page: "0",
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_equal "Head office", office.reload.contact.title
    assert_not worldwide_organisation.reload.office_shown_on_home_page?(office)
  end

  test "put update updates an office without changing the home page state if no suggestion made" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
            },
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_equal "Head office", office.reload.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "put update updates an offices services" do
    service2 = create(:worldwide_service)
    service3 = create(:worldwide_service)
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
        params: {
          worldwide_office: {
            service_ids: [service3.id, service2.id],
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_equal [service2, service3], office.reload.services.sort_by(&:id)
  end

  test "put update updates associated phone numbers" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    contact_number = office.contact.contact_numbers.create!(label: "Main phone", number: "1234")

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
              contact_numbers_attributes: {
                "0" => { id: contact_number.id, label: "Main phone", number: "5678" },
              },
            },
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    actual_numbers = office
                       .contact
                       .reload
                       .contact_numbers
                       .reload
                       .map { |cn| "#{cn.label}: #{cn.number}" }

    assert_equal ["Main phone: 5678"], actual_numbers
  end

  test "PUT :update deletes contact numbers that have only blank fields" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    contact_number = office.contact.contact_numbers.create!(label: "Phone", number: "1234")

    put :update,
        params: {
          worldwide_office: {
            contact_attributes: {
              id: office.contact.id,
              title: "Head office",
              contact_numbers_attributes: {
                "0" => {
                  id: contact_number.id,
                  label: contact_number.label,
                  number: contact_number.number,
                  _destroy: "true",
                },
              },
            },
          },
          id: office,
          worldwide_organisation_id: worldwide_organisation,
        }

    assert_not ContactNumber.exists?(contact_number.id)
  end

  test "POST on :reorder_for_home_page takes id => ordering mappings and reorders the list based on this" do
    worldwide_organisation, office1 = create_worldwide_organisation_and_office
    office2 = worldwide_organisation.offices.create!(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Body office",
        contact_type_id: ContactType::General.id,
      },
    )
    office3 = worldwide_organisation.offices.create!(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Spirit office",
        contact_type_id: ContactType::General.id,
      },
    )
    worldwide_organisation.add_office_to_home_page!(office1)
    worldwide_organisation.add_office_to_home_page!(office2)
    worldwide_organisation.add_office_to_home_page!(office3)

    post :reorder_for_home_page,
         params: {
           worldwide_organisation_id: worldwide_organisation,
           ordering: {
             office1.id.to_s => "3",
             office2.id.to_s => "1",
             office3.id.to_s => "2",
           },
         }

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %(Offices on home page reordered successfully), flash[:notice]
    assert_equal [office2, office3, office1], worldwide_organisation.reload.home_page_offices
  end

  test "POST on :reorder_for_home_page doesn't break with unknown contact ids" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    post :reorder_for_home_page,
         params: {
           worldwide_organisation_id: worldwide_organisation,
           ordering: {
             office.id.to_s => "2",
             "1000000" => "1",
           },
         }

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %(Offices on home page reordered successfully), flash[:notice]
    assert_equal [office], worldwide_organisation.reload.home_page_offices
  end

  test "GET :confirm_destroy calls correctly" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    get :confirm_destroy, params: {
      worldwide_organisation_id: worldwide_organisation.id,
      id: office.id,
    }

    assert_response :success
    assert_equal worldwide_organisation, assigns(:worldwide_organisation)
    assert_equal office, assigns(:worldwide_office)
  end

  test "GET :reorder calls correctly" do
    worldwide_organisation = create_worldwide_organisation_with_main_office
    office1 = create(:worldwide_office, worldwide_organisation:)
    office2 = create(:worldwide_office, worldwide_organisation:)

    worldwide_organisation.add_office_to_home_page!(office1)
    worldwide_organisation.add_office_to_home_page!(office2)

    get :reorder, params: {
      worldwide_organisation_id: worldwide_organisation.id,
    }

    assert_response :success
    assert_equal worldwide_organisation, assigns(:worldwide_organisation)
    assert_equal [office1, office2], assigns(:reorderable_offices)
  end

  test "POST :create for an office attached to an editionable worldwide organisation republishes the draft of the editionable worldwide organisation" do
    feature_flags.switch! :editionable_worldwide_organisations, true

    worldwide_organisation = create(:draft_editionable_worldwide_organisation)

    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(instance_of(WorldwideOffice), "major").at_least_once
    Whitehall::PublishingApi.expects(:save_draft).with(instance_of(Contact), "major").at_least_once

    post :create,
         params: {
           worldwide_office: {
             worldwide_office_type_id: WorldwideOfficeType::Other.id,
             contact_attributes: {
               title: "Main office",
               contact_type_id: ContactType::General.id,
             },
           },
           worldwide_organisation_id: worldwide_organisation,
         }
  end

  test "PUT :update for an office attached to an editionable worldwide organisation republishes the draft of the editionable worldwide organisation" do
    feature_flags.switch! :editionable_worldwide_organisations, true

    office = create(:worldwide_office, edition: create(:draft_editionable_worldwide_organisation), worldwide_organisation: nil)

    Whitehall::PublishingApi.expects(:save_draft).with(office.edition)
    Whitehall::PublishingApi.expects(:save_draft).with(office, "major")
    Whitehall::PublishingApi.expects(:save_draft).with(office.contact, "major")

    put :update,
        params: {
          worldwide_office: {
            access_and_opening_times: "New times",
          },
          id: office,
          worldwide_organisation_id: office.edition,
        }
  end

  test "DELETE :destroy for an office attached to an editionable worldwide organisation republishes the draft of the editionable worldwide organisation" do
    feature_flags.switch! :editionable_worldwide_organisations, true

    office = create(:worldwide_office, edition: create(:draft_editionable_worldwide_organisation), worldwide_organisation: nil)

    Whitehall::PublishingApi.expects(:save_draft).with(office.edition)

    delete :destroy,
           params: {
             id: office,
             worldwide_organisation_id: office.edition,
           }
  end

  test "DELETE :destroy for an office attached to an editionable worldwide organisation discards draft of the office and the contact" do
    feature_flags.switch! :editionable_worldwide_organisations, true

    office = create(:worldwide_office, edition: create(:draft_editionable_worldwide_organisation), worldwide_organisation: nil)

    PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(office.content_id, "en")
    PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(office.contact.content_id, "en")

    Sidekiq::Testing.inline! do
      delete :destroy,
             params: {
               id: office,
               worldwide_organisation_id: office.edition,
             }
    end
  end

private

  def create_worldwide_organisation_and_office
    worldwide_organisation = create_worldwide_organisation_with_main_office
    office = worldwide_organisation.offices.create!(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Main office",
        contact_type_id: ContactType::General.id,
      },
    )
    [worldwide_organisation, office]
  end

  def create_worldwide_organisation_with_main_office
    create(:worldwide_organisation).tap do |worldwide_organisation|
      create(:worldwide_office, worldwide_organisation:)
    end
  end
end
