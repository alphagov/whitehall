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
        contact_attributes: {title: "Main office"} 
      },
      worldwide_organisation_id: worldwide_organisation.id

    assert_equal 1, worldwide_organisation.offices.count
    assert_equal 'Main office', worldwide_organisation.offices.first.contact.title
  end

  test "post create creates worldwide office with services" do
    service1 = create(:worldwide_service)
    service2 = create(:worldwide_service)
    worldwide_organisation = create(:worldwide_organisation)

    post :create,
      worldwide_office: {
        worldwide_office_type_id: WorldwideOfficeType::Other.id,
        contact_attributes: {title: "Main office"},
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
    worldwide_organisation = create(:worldwide_organisation)
    office = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {title: "Main office"}
    )

    put :update,
      worldwide_office: {
        contact_attributes: {
          title: "Head office"
        }
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal "Head office", worldwide_organisation.offices.first.contact.title
  end

  test "put update updates an offices services" do
    service1 = create(:worldwide_service)
    service2 = create(:worldwide_service)
    service3 = create(:worldwide_service)
    worldwide_organisation = create(:worldwide_organisation)
    office = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {title: "Main office"}, services: [service1, service2]
    )

    put :update,
      worldwide_office: {
        service_ids: [service3.id, service2.id]
      },
      id: office,
      worldwide_organisation_id: worldwide_organisation

    assert_equal [service2, service3], worldwide_organisation.offices.first.services.sort_by {|s| s.id}
  end

  test "put update updates associated phone numbers" do
    worldwide_organisation = create(:worldwide_organisation)
    office = worldwide_organisation.offices.create(
      worldwide_office_type_id: WorldwideOfficeType::Other.id,
      contact_attributes: {title: "Main office"}
    )
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

    assert_equal 1, worldwide_organisation.offices.count
    assert office = worldwide_organisation.offices.first
    assert_equal ["Main phone: 5678"], office.contact.reload.contact_numbers.reload.map { |cn| "#{cn.label}: #{cn.number}" }
  end
end