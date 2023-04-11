require "test_helper"

class PublishingApi::MinistersIndexPresenterTest < ActionView::TestCase
  def presented_item
    PublishingApi::MinistersIndexPresenter.new
  end

  test "presenter is valid against ministers index schema" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      assert_valid_against_publisher_schema(presented_item.content, "ministers_index")
      assert_valid_against_links_schema({ links: presented_item.links }, "ministers_index")
    end
  end

  test "presents ministers index page ready for the publishing-api in english" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: false)

      ministerial_department_1 = create(:ministerial_department, ministerial_ordering: 2)
      ministerial_department_2 = create(:ministerial_department, ministerial_ordering: 3)
      ministerial_department_3 = create(:ministerial_department, ministerial_ordering: 1)

      prime_minister = create(:role_appointment, person: create(:person), role: create(:prime_minister_role, cabinet_member: true, seniority: 0, organisations: [ministerial_department_3]))
      cabinet_member_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, cabinet_member: true, seniority: 2, organisations: [ministerial_department_3]))
      cabinet_member_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, cabinet_member: true, seniority: 1, organisations: [ministerial_department_1]))
      also_attends_cabinet_minister_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, attends_cabinet_type_id: RoleAttendsCabinetType::AttendsCabinet.id, seniority: 4, organisations: [ministerial_department_1]))
      also_attends_cabinet_minister_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, attends_cabinet_type_id: RoleAttendsCabinetType::AttendsCabinet.id, seniority: 3, organisations: [ministerial_department_3]))
      create(:role_appointment, person: create(:person), role: create(:ministerial_role, organisations: [ministerial_department_3]))
      create(:role_appointment, person: create(:person), role: create(:ministerial_role, organisations: [ministerial_department_2]))

      expected_content = {
        title: "Ministers",
        locale: "en",
        publishing_app: "whitehall",
        redirects: [],
        update_type: "major",
        base_path: "/government/ministers",
        details: {
          body: "Read biographies and responsibilities of [Cabinet ministers](#cabinet-ministers) and all [ministers by department](#ministers-by-department), as well as the [whips](#whips) who help co-ordinate parliamentary business.",
        },
        document_type: "ministers_index",
        rendering_app: "whitehall-frontend",
        schema_name: "ministers_index",
        routes: [
          {
            path: "/government/ministers",
            type: "exact",
          },
        ],
      }

      expected_links = {
        ordered_cabinet_ministers: [
          prime_minister.person.content_id,
          cabinet_member_2.person.content_id,
          cabinet_member_1.person.content_id,
        ],
        ordered_also_attends_cabinet: [
          also_attends_cabinet_minister_2.person.content_id,
          also_attends_cabinet_minister_1.person.content_id,
        ],
        ordered_ministerial_departments: [
          ministerial_department_3.content_id,
          ministerial_department_1.content_id,
          ministerial_department_2.content_id,
        ],
      }

      assert_equal expected_content, presented_item.content
      assert_equal expected_links, presented_item.links
    end
  end

  test "presents ministers index page ready for the publishing-api with correct reshuffle message" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      expected_details = {
        reshuffle: {
          message: "example text",
        },
      }

      expected_links = {}

      assert_equal expected_details, presented_item.content[:details]
      assert_equal expected_links, presented_item.links
    end
  end
end
