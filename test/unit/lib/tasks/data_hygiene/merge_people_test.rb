require "test_helper"
require "rake"

class MergePeopleTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable
  end

  let(:task) { Rake::Task["data_hygiene:merge_people"] }

  context "user aborts task when prompted" do
    before do
      Thor::Shell::Basic.any_instance.stubs(:yes?).returns(false)
    end

    it "does not merge the people" do
      person_to_merge = create(:person)
      person_to_keep = create(:person)

      Services.publishing_api.expects(:unpublish).never

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_match(/Merging aborted/, out)
      assert_not_nil person_to_merge.reload
    end

    it "returns if people cannot be found" do
      person_to_keep = create(:person)
      person_to_merge = create(:person)
      person_to_merge.destroy!
      person_to_keep.destroy!

      out, _err = capture_io { task.invoke(person_to_keep.id, person_to_merge.id) }
      assert_includes out, "Please provide valid person IDs to merge."
    end

    it "returns if people are not distinct" do
      person = create(:person)

      out, _err = capture_io { task.invoke(person.id, person.id) }
      assert_includes out, "The person IDs provided are the same. Please provide valid person IDs to merge."
    end

    it "outputs a summary of the people's relationships" do
      person_to_merge = create(:person,
                               translated_into: {
                                 fr: { biography: "french-biography" },
                               })
      create(:role_appointment, person: person_to_merge)
      create(:historical_account, person: person_to_merge)
      person_to_keep = create(:person)

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_includes out, "The Person ID #{person_to_merge.id} (#{person_to_merge.full_name}) has:\n\t1 role appointments " \
        "#{person_to_merge.role_appointments.map { |ra| ra.role&.name }.to_sentence}\n\t1 historical accounts\n\t1 translations fr\n"
      assert_includes out, "The Person ID #{person_to_keep.id} (#{person_to_keep.full_name}) has:\n\t0 role appointments \n\t0 historical accounts\n\t0 translations \n"
    end

    it "exits if person to merge has a historical account" do
      person_to_merge = create(:person)
      person_to_keep = create(:person)
      create(:historical_account, person: person_to_merge)

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_includes out, "Please remove the historical account from the person you want to merge, and retry."
      assert person_to_merge.reload
    end

    it "exits if person to merge has additional non-English translations" do
      person_to_merge = create(:person, translated_into: {
        "en" => { biography: "english-biography" },
        "fr" => { biography: "french-biography" },
      })
      person_to_keep = create(:person)

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_includes out, "Please manually migrate non-English translations from the person you want to merge to the person you want to keep, and retry."
      assert person_to_merge.reload
    end

    it "checks discrepancies between the people's English biographies" do
      person_to_merge = create(:person,
                               translated_into: {
                                 en: { biography: "english-biography 1" },
                               })
      person_to_keep = create(:person,
                              translated_into: {
                                en: { biography: "english-biography 2" },
                              })

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_includes out, "The English biographies of the people to merge are different. If the people get merged, you might lose data. Please manually migrate the data and retry."
    end
  end

  context "user confirms task execution when prompted" do
    before do
      Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)
      Kernel.stubs(:sleep)
    end

    it "rewires role appointments for people and deletes the person to merge" do
      person_to_merge = create(:person)
      role_to_merge = create(:role, name: "Role to Merge")
      ra_merge = create(:role_appointment, role: role_to_merge, person: person_to_merge)

      person_to_keep = create(:person)
      role_to_keep = create(:role, name: "Role to Keep")
      ra_keep = create(:role_appointment, role: role_to_keep, person: person_to_keep)

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_equal ra_merge.reload.person_id, person_to_keep.id
      assert_equal ra_keep.reload.person_id, person_to_keep.id
      assert_equal person_to_keep.reload.role_appointments.count, 2
      assert_includes out, "Linking role appointment #{ra_merge.id}: 'Role to Merge' from person #{person_to_merge.id} (#{person_to_merge.full_name}), to person #{person_to_keep.id} (#{person_to_keep.full_name})"
      assert_includes out, "Destroying Person ID: #{person_to_merge.id} (#{person_to_merge.full_name})"
      assert_raises(ActiveRecord::RecordNotFound) { person_to_merge.reload }
    end

    it "redirects the deleted person to the person to keep" do
      person_to_merge = create(:person)
      create(:role_appointment, person: person_to_merge)
      person_to_keep = create(:person)
      create(:role_appointment, person: person_to_keep)

      Services.publishing_api.expects(:unpublish).with(
        person_to_merge.content_id,
        type: "redirect",
        locale: "en",
        alternative_path: "/government/people/#{person_to_keep.slug}",
        allow_draft: false,
        discard_drafts: true,
      ).returns(OpenStruct.new(code: 200, raw_response_body: "success"))

      out, _err = capture_io { task.invoke(person_to_merge.id, person_to_keep.id) }

      assert_includes out, "Redirecting the deleted person of content ID: '#{person_to_merge.content_id}' to the person to keep, at path: '/government/people/#{person_to_keep.slug}'"
    end
  end
end
