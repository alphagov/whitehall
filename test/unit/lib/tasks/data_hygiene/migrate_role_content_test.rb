require "test_helper"
require "rake"
class MigrateRoleContentTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require "tasks/data_hygiene"
    Rake::Task.define_task(:environment)
    Rake::Task["data_hygiene:migrate_role_content"].reenable
  end

  test "it moves content from one role appointment to another" do
    speech = create(:speech)

    person = create(:person, forename: "Sluggy", surname: "McSlugson")
    old_role = create(:ministerial_role, slug: "head-slug-and-chief-snail-executive", name: "Head Slug and Chief Snail Executive")
    old_role_appointment = create(:role_appointment, role: old_role, person:, speeches: [speech])
    new_role = create(:ministerial_role, slug: "head-slug", name: "Head Slug")
    new_role_appointment = create(:role_appointment, role: new_role, person:)

    assert_equal old_role, speech.role

    Rake.application.invoke_task "data_hygiene:migrate_role_content[#{old_role_appointment.id},#{new_role_appointment.id}]"

    assert_equal new_role, speech.reload.role
  end
end
