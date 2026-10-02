require "test_helper"

class Document::PaginatedTimeline::ChangeNoteDecoratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:major_change_published_at) { Time.zone.parse("2024-01-01 12:00") }
  let(:edition) { build(:published_edition, id: 5, change_note: "Updated guidance", major_change_published_at:) }
  let(:decorator) { Document::PaginatedTimeline::ChangeNoteDecorator.new(edition) }

  describe "#created_at" do
    it "is the time the major change was published" do
      assert_equal major_change_published_at, decorator.created_at
    end
  end

  describe "#note" do
    it "is the edition's change note" do
      assert_equal "Updated guidance", decorator.note
    end

    it "is 'First published.' when the change note is blank on the first published edition" do
      edition.change_note = nil
      decorator = Document::PaginatedTimeline::ChangeNoteDecorator.new(edition, is_first_published_edition: true)

      assert_equal "First published.", decorator.note
    end

    it "is nil when the change note is blank on a later edition" do
      edition.change_note = nil

      assert_nil decorator.note
    end
  end

  describe "#actor" do
    it "is the user who published the edition" do
      user = build(:user)
      edition.stubs(:published_by).returns(user)

      assert_equal user, decorator.actor
    end
  end

  describe "#is_for_newer_edition?" do
    it "is true when the edition is newer than the one passed in" do
      assert decorator.is_for_newer_edition?(build(:edition, id: 4))
      assert_not decorator.is_for_newer_edition?(build(:edition, id: 5))
    end
  end

  describe "#is_for_current_edition?" do
    it "is true when the edition is the one passed in" do
      assert decorator.is_for_current_edition?(build(:edition, id: 5))
      assert_not decorator.is_for_current_edition?(build(:edition, id: 6))
    end
  end

  describe "#is_for_older_edition?" do
    it "is true when the edition is older than the one passed in" do
      assert decorator.is_for_older_edition?(build(:edition, id: 6))
      assert_not decorator.is_for_older_edition?(build(:edition, id: 5))
    end
  end
end
