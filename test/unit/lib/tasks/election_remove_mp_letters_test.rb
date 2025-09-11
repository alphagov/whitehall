require "test_helper"
require "rake"

class RemoveMpLettersRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#remove_mp_letters" do
    let(:task) { Rake::Task["election:remove_mp_letters"] }

    it "removes the letters MP from people names" do
      member_a = create(:person, forename: "A", surname: "Member", letters: "MP")
      member_b = create(:person, forename: "B", surname: "Member", letters: "CBE MP")
      member_c = create(:person, forename: "C", surname: "Member", letters: "MP MEng")
      member_d = create(:person, forename: "D", surname: "Member", letters: "CBE MP MPhil")
      non_member_a = create(:person, forename: "A", surname: "Non-Member", letters: "CBE MPhil VC")

      Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)
      out, _err = capture_io { task.invoke }

      assert_match(/----------DRY RUN----------/, out)
      assert_match(/Found A Member MP that matches 'MP'/, out)
      assert_match(/Found B Member CBE MP that matches 'MP'/, out)
      assert_match(/Found C Member MP MEng that matches 'MP'/, out)
      assert_match(/Found D Member CBE MP MPhil that matches 'MP'/, out)
      assert_match(/Skipped A Non-Member CBE MPhil VC - includes 'MP' \(case insensitive\), but doesn't match exactly/, out)

      assert_match(/----------CHANGES SUMMARY----------/, out)
      assert_match(/Updated A Member MP to A Member/, out)
      assert_match(/Updated B Member CBE MP to B Member CBE/, out)
      assert_match(/Updated C Member MP MEng to C Member MEng/, out)
      assert_match(/Updated D Member CBE MP MPhil to D Member CBE MPhil/, out)

      assert_equal "A Member", member_a.reload.name
      assert_equal "B Member CBE", member_b.reload.name
      assert_equal "C Member MEng", member_c.reload.name
      assert_equal "D Member CBE MPhil", member_d.reload.name
      assert_equal "A Non-Member CBE MPhil VC", non_member_a.reload.name
    end
  end
end
