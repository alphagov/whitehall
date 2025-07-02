require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:name_prefix) { "name_prefix" }
  let(:id_prefix) { "id_prefix" }
  let(:index) { 0 }
  let(:field) { stub(:field) }
  let(:errors) { {} }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent.new(
      name_prefix:,
      id_prefix:,
      value: {},
      index:,
      field:,
      errors:,
      can_be_deleted:,
    )
  end

  describe "when the object can be deleted" do
    let(:can_be_deleted) { true }

    it "renders with the correct class" do
      render_inline(component)

      assert_selector ".app-c-content-block-manager-opening-hours-item-component"
      refute_selector ".app-c-content-block-manager-opening-hours-item-component--immutable"
    end
  end

  describe "when the object can't be deleted" do
    let(:can_be_deleted) { false }

    it "renders with the correct class" do
      render_inline(component)

      assert_selector ".app-c-content-block-manager-opening-hours-item-component"
      assert_selector ".app-c-content-block-manager-opening-hours-item-component--immutable"
    end
  end
end
