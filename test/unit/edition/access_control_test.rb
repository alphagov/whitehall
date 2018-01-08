require "test_helper"

class Edition::AccessControlTest < ActiveSupport::TestCase
  %i[imported draft submitted rejected].each do |state|
    test "should be editable if #{state}" do
      edition = build("#{state}_edition")
      assert edition.editable?
    end
  end

  %i[published superseded deleted].each do |state|
    test "should not be editable if #{state}" do
      edition = build("#{state}_edition")
      refute edition.editable?
    end
  end

  %i[imported deleted superseded].each do |state|
    test "can have some invalid data if #{state}" do
      edition = build("#{state}_edition")
      assert edition.can_have_some_invalid_data?
    end
  end

  %i[draft submitted rejected published].each do |state|
    test "cannot have some invalid data if #{state}" do
      edition = build("#{state}_edition")
      refute edition.can_have_some_invalid_data?
    end
  end

  %i[draft rejected published superseded deleted].each do |state|
    test "should not be rejectable if #{state}" do
      edition = build("#{state}_edition")
      refute edition.can_reject?
    end
  end

  %i[draft rejected].each do |state|
    test "should be submittable if #{state}" do
      edition = build("#{state}_edition")
      assert edition.can_submit?
    end
  end

  %i[submitted published superseded deleted].each do |state|
    test "should not be submittable if #{state}" do
      edition = build("#{state}_edition")
      refute edition.can_submit?
    end
  end

  %i[imported draft submitted rejected].each do |state|
    test "should be deletable if #{state}" do
      edition = build("#{state}_edition")
      assert edition.can_delete?
    end
  end

  %i[scheduled published superseded].each do |state|
    test "should not be deletable if #{state}" do
      edition = build("#{state}_edition")
      refute edition.can_delete?
    end
  end
end
