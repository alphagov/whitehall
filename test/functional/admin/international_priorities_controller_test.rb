require 'test_helper'

class Admin::InternationalPrioritiesControllerTest < ActionController::TestCase

  setup do
    @user = login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :international_priority
  should_allow_creating_of :international_priority
  should_allow_editing_of :international_priority
  should_allow_revision_of :international_priority

  should_allow_association_between_countries_and :international_priority
  should_allow_attached_images_for :international_priority
  should_allow_organisations_for :international_priority

  should_be_rejectable :international_priority
  should_be_publishable :international_priority
  should_be_force_publishable :international_priority
  should_be_able_to_delete_a_document :international_priority
  should_link_to_public_version_when_published :international_priority
  should_not_link_to_public_version_when_not_published :international_priority
  should_prevent_modification_of_unmodifiable :international_priority
end
