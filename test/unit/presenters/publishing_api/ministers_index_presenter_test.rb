require "test_helper"

class PublishingApi::MinistersIndexPresenterTest < ActionView::TestCase
  def presented_item
    PublishingApi::MinistersIndexPresenter.new
  end

  test "presents a valid content item containing the correct information when reshuffle mode is off" do
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

      hoc_whip_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseOfCommons.id, whip_ordering: 2, organisations: [ministerial_department_1]))
      hoc_whip_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseOfCommons.id, whip_ordering: 1, organisations: [ministerial_department_1]))
      junior_treasury_whip_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::JuniorLordsoftheTreasury.id, whip_ordering: 2, organisations: [ministerial_department_1]))
      junior_treasury_whip_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::JuniorLordsoftheTreasury.id, whip_ordering: 1, organisations: [ministerial_department_1]))
      assistant_whip_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::AssistantWhips.id, whip_ordering: 2, organisations: [ministerial_department_1]))
      assistant_whip_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::AssistantWhips.id, whip_ordering: 1, organisations: [ministerial_department_1]))
      hol_whip_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseofLords.id, whip_ordering: 2, organisations: [ministerial_department_1]))
      hol_whip_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseofLords.id, whip_ordering: 1, organisations: [ministerial_department_1]))
      baroness_whip_1 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::BaronessAndLordsInWaiting.id, whip_ordering: 2, organisations: [ministerial_department_1]))
      baroness_whip_2 = create(:role_appointment, person: create(:person), role: create(:ministerial_role, whip_organisation_id: Whitehall::WhipOrganisation::BaronessAndLordsInWaiting.id, whip_ordering: 1, organisations: [ministerial_department_1]))

      expected_content = {
        title: "Ministers",
        locale: "en",
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        redirects: [],
        update_type: "major",
        base_path: "/government/ministers",
        details: {
          body: "Read biographies and responsibilities of <a href=\"#cabinet-ministers\" class=\"govuk-link\">Cabinet ministers</a> and all <a href=\"#ministers-by-department\" class=\"govuk-link\">ministers by department</a>, as well as the <a href=\"#whips\" class=\"govuk-link\">whips</a> who help co-ordinate parliamentary business.",
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
        ordered_house_of_commons_whips: [
          hoc_whip_2.person.content_id,
          hoc_whip_1.person.content_id,
        ],
        ordered_junior_lords_of_the_treasury_whips: [
          junior_treasury_whip_2.person.content_id,
          junior_treasury_whip_1.person.content_id,
        ],
        ordered_assistant_whips: [
          assistant_whip_2.person.content_id,
          assistant_whip_1.person.content_id,
        ],
        ordered_house_lords_whips: [
          hol_whip_2.person.content_id,
          hol_whip_1.person.content_id,
        ],
        ordered_baronesses_and_lords_in_waiting_whips: [
          baroness_whip_2.person.content_id,
          baroness_whip_1.person.content_id,
        ],
      }

      assert_equal expected_content, presented_item.content
      assert_valid_against_publisher_schema(presented_item.content, "ministers_index")

      assert_equal expected_links, presented_item.links
      assert_valid_against_links_schema({ links: presented_item.links }, "ministers_index")
    end
  end

  test "presents a valid content item without information when reshuffle mode is on" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      expected_details = {
        reshuffle: {
          message: "example text",
        },
      }

      expected_links = {}

      assert_equal expected_details, presented_item.content[:details]
      assert_valid_against_publisher_schema(presented_item.content, "ministers_index")

      assert_equal expected_links, presented_item.links
      assert_valid_against_links_schema({ links: presented_item.links }, "ministers_index")
    end
  end
end
