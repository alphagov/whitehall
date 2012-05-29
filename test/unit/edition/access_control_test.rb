require "test_helper"

class Edition::AccessControlTest < ActiveSupport::TestCase

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable if #{state}" do
      edition = create("#{state}_edition")
      assert edition.editable?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be editable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.editable?
    end
  end

  test "should be rejectable by editors if submitted" do
    edition = create(:submitted_edition)
    assert edition.rejectable_by?(build(:departmental_editor))
  end

  test "should not be rejectable by writers" do
    edition = create(:submitted_edition)
    refute edition.rejectable_by?(build(:policy_writer))
  end

  [:draft, :rejected, :published, :archived, :deleted].each do |state|
    test "should not be rejectable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.rejectable_by?(build(:departmental_editor))
    end
  end

  [:draft, :rejected].each do |state|
    test "should be submittable if #{state}" do
      edition = create("#{state}_edition")
      assert edition.submittable?
    end
  end

  [:submitted, :published, :archived, :deleted].each do |state|
    test "should not be submittable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.submittable?
    end
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be deletable if #{state}" do
      edition = create("#{state}_edition")
      assert edition.deletable?
    end
  end

  test "should not be deletable if deleted" do
    edition = create(:deleted_edition)
    refute edition.deletable?
  end

  [:published, :archived].each do |state|
    test "should be deletable if #{state} and there is only one edition" do
      edition = create("#{state}_edition")
      assert edition.deletable?
    end
  end

  test "should not be deletable if published and there are previous editions" do
    first_edition = create(:published_edition)
    user = create(:user)
    second_edition = first_edition.create_draft(user)
    second_edition.publish!
    refute second_edition.reload.deletable?
  end

end