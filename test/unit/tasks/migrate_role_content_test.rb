require "test_helper"
require "rake"
class MigrateRoleContentTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require "tasks/migrate_role_content"
    Rake::Task.define_task(:environment)
    Rake::Task["migrate:role_content"].reenable
  end

  test "what" do
    speech = create(:speech)
    # edition = create(:published_publication, speech: speech)

    person = create(:person, forename: "Sluggy", surname: "McSlugson")
    old_role = create(:ministerial_role, slug: "head-slug-and-chief-snail-executive", name: "Head Slug and Chief Snail Executive")
    old_role_appointment = create(:role_appointment, role: old_role, person: person, speeches: [speech])
    new_role = create(:ministerial_role, slug: "head-slug", name: "Head Slug")
    new_role_appointment = create(:role_appointment, role: new_role, person: person)

    assert_equal old_role, speech.role

    Rake.application.invoke_task "migrate:role_content[head-slug-and-chief-snail-executive,head-slug]"

    assert_equal new_role, speech.reload.role
  end
end
