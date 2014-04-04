require 'test_helper'

class Admin::WorldwideOfficesControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "post create creates worldwide office" do
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Main office",
          contact_type_id: ContactType::General.id
        }
      },
      worldwide_organisation_id: worldwide_organisation.id

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
    assert_equal 1, worldwide_organisation.offices.count
    assert_equal 'Main office', worldwide_organisation.offices.first.contact.title
  end

  test "post create creates worldwide office on the home page of the world org if told to" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Main office",
          contact_type_id: ContactType::General.id
        },
        show_on_home_page: '1'
      },
      worldwide_organisation_id: worldwide_organisation.id

    new_office = worldwide_organisation.offices.last
    assert_equal 'Main office', new_office.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office without adding it to the home page of the world org if told not to" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Main office",
          contact_type_id: ContactType::General.id
        },
        show_on_home_page: '0'
      },
      worldwide_organisation_id: worldwide_organisation.id

    new_office = worldwide_organisation.offices.last
    assert_equal 'Main office',new_office.contact.title
    refute worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office without adding it to the home page of the world org if no suggestion made" do
    worldwide_organisation = create_worldwide_organisation_with_main_office

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Main office",
          contact_type_id: ContactType::General.id
        }
      },
      worldwide_organisation_id: worldwide_organisation.id

    new_office = worldwide_organisation.offices.last
    assert_equal 'Main office',new_office.contact.title
    refute worldwide_organisation.office_shown_on_home_page?(new_office)
  end

  test "post create creates worldwide office with services" do
    service1 = create(:worldwide_service)
    service2 = create(:worldwide_service)
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Main office",
          contact_type_id: ContactType::General.id
        },
        service_ids: [service2.id, service1.id]
      },
      worldwide_organisation_id: worldwide_organisation.id

    assert_equal 1, worldwide_organisation.offices.count
    assert_equal [service1, service2], worldwide_organisation.offices.first.services.sort_by {|s| s.id}
  end

  test "post create creates associated phone numbers" do
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {
          title: "Head office",
          contact_type_id: ContactType::General.id,
          contact_numbers_attributes: {
            "0" => {label: "Main phone", number: "1234"}
          }
        }
      },
      worldwide_organisation_id: worldwide_organisation.id

    assert_equal 1, worldwide_organisation.offices.count
    assert office = worldwide_organisation.offices.first
    assert_equal ["Main phone: 1234"], office.contact.contact_numbers.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "put update updates an office" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office"
        }
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal "Head office", office.reload.contact.title
  end


  test "put update updates an office adding it to the home page of the world org if told to" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office"
        },
        show_on_home_page: '1'
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal "Head office", office.reload.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "put update updates an office removing it from the home page of the world org if told to" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office"
        },
        show_on_home_page: '0'
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal "Head office", office.reload.contact.title
    refute worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "put update updates an office without changing the home page state if no suggestion made" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office"
        }
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal "Head office", office.reload.contact.title
    assert worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "put update updates an offices services" do
    service1 = create(:worldwide_service)
    service2 = create(:worldwide_service)
    service3 = create(:worldwide_service)
    worldwide_organisation, office = create_worldwide_organisation_and_office

    put :update,
      worldwide_office: {
        service_ids: [service3.id, service2.id]
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal [service2, service3], office.reload.services.sort_by {|s| s.id}
  end

  test "put update updates associated phone numbers" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    contact_number = office.contact.contact_numbers.create(label: "Main phone", number: "1234")

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office",
          contact_numbers_attributes: {
            "0" => {id: contact_number.id, label: "Main phone", number: "5678"}
          }
        },
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal ["Main phone: 5678"], office.contact.reload.contact_numbers.reload.map { |cn| "#{cn.label}: #{cn.number}" }
  end

  test "PUT :update deletes contact numbers that have only blank fields" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    contact_number = office.contact.contact_numbers.create(label: "Phone", number: "1234")

    put :update,
      worldwide_office: {
        contact_attributes: {
          id: office.contact.id,
          title: "Head office",
          contact_numbers_attributes: {
            "0" => {
              id: contact_number.id,
              label: contact_number.label,
              number: contact_number.number,
              _destroy: 'true'
            }
          }
        },
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    refute ContactNumber.exists?(contact_number)
  end

  test "POST on :remove_from_home_page removes office from the home page of the worldwide organisation" do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    post :remove_from_home_page, worldwide_organisation_id: worldwide_organisation, id: office

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %{"#{office.title}" removed from home page successfully}, flash[:notice]
    refute worldwide_organisation.office_shown_on_home_page?(office)
  end

  test "POST on :add_to_home_page adds office to the home page of the worldwide organisation" do
    worldwide_organisation, office = create_worldwide_organisation_and_office

    post :add_to_home_page, worldwide_organisation_id: worldwide_organisation, id: office

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %{"#{office.title}" added to home page successfully}, flash[:notice]
    assert worldwide_organisation.office_shown_on_home_page?(office)
  end

  test 'POST on :reorder_for_home_page takes id => ordering mappings and reorders the list based on this' do
    worldwide_organisation, office_1 = create_worldwide_organisation_and_office
    office_2 = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Body office",
        contact_type_id: ContactType::General.id
      }
    )
    office_3 = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Spirit office",
        contact_type_id: ContactType::General.id
      }
    )
    worldwide_organisation.add_office_to_home_page!(office_1)
    worldwide_organisation.add_office_to_home_page!(office_2)
    worldwide_organisation.add_office_to_home_page!(office_3)

    post :reorder_for_home_page, worldwide_organisation_id: worldwide_organisation,
      ordering: {
        office_1.id.to_s => '3',
        office_2.id.to_s => '1',
        office_3.id.to_s => '2'
      }

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %{Offices on home page reordered successfully}, flash[:notice]
    assert_equal [office_2, office_3, office_1], worldwide_organisation.reload.home_page_offices
  end

  test 'POST on :reorder_for_home_page doesn\'t break with unknown contact ids' do
    worldwide_organisation, office = create_worldwide_organisation_and_office
    worldwide_organisation.add_office_to_home_page!(office)

    post :reorder_for_home_page, worldwide_organisation_id: worldwide_organisation,
      ordering: {
        office.id.to_s => '2',
        '1000000' => '1'
      }

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_url(worldwide_organisation)
    assert_equal %{Offices on home page reordered successfully}, flash[:notice]
    assert_equal [office], worldwide_organisation.reload.home_page_offices
  end

private

  def create_worldwide_organisation_and_office
    worldwide_organisation = create_worldwide_organisation_with_main_office
    office = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {
        title: "Main office",
        contact_type_id: ContactType::General.id
      }
    )
    [worldwide_organisation, office]
  end

  def create_worldwide_organisation_with_main_office
    create(:worldwide_organisation).tap do |worldwide_organisation|
      create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    end
  end
end
