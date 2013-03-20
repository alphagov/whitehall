require 'test_helper'

class Admin::WorldwidePrioritiesControllerTest < ActionController::TestCase

  setup do
    @user = login_as :gds_editor
  end

  should_be_an_admin_controller

  should_allow_creating_of :worldwide_priority
  should_allow_editing_of :worldwide_priority

  should_allow_association_between_world_locations_and :worldwide_priority
  should_allow_association_with_worldwide_organisations :worldwide_priority
  should_allow_attached_images_for :worldwide_priority
  should_allow_organisations_for :worldwide_priority

  should_prevent_modification_of_unmodifiable :worldwide_priority
  should_allow_access_limiting_of :worldwide_priority
end
