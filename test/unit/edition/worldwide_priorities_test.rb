require 'test_helper'

class Edition::WorldwidePrioritiesTest < ActiveSupport::TestCase
  class EditionWithWorldwidePriorities < Edition
    include ::Edition::WorldwidePriorities
  end

  def valid_edition_attributes
    {
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: build(:user),
      lead_organisation_ids: [create(:organisation).id]
    }
  end

  def priorities
    @priorities ||= [
      create(:published_worldwide_priority),
      create(:draft_worldwide_priority)
    ]
  end

  setup do
    @edition = EditionWithWorldwidePriorities.new(valid_edition_attributes.merge(worldwide_priorities: priorities))
  end

  test "edition can be created with worldwide priorities" do
    assert_equal priorities, @edition.worldwide_priorities
  end

  test "editions also keep a list of their published priorities" do
    @edition.save!
    assert_equal [priorities.first], @edition.published_worldwide_priorities
  end

  test "editions with worldwide priorities can have none set" do
    assert EditionWithWorldwidePriorities.new(valid_edition_attributes).valid?
  end

  test "copies the worldwide priorities over to a new draft" do
    published = build :published_world_location_news_article, worldwide_priorities: priorities
    assert_equal priorities, published.create_draft(build(:user)).worldwide_priorities
  end

  test "editions with worldwide priorities report that they can be associated with them" do
    refute Edition.new.can_be_associated_with_worldwide_priorities?
    assert EditionWithWorldwidePriorities.new.can_be_associated_with_worldwide_priorities?
  end
end
