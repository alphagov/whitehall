module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #

  def homepage
    # temporary substitute for the real home page until it has proper navigation links
    organisations_path
  end

  def ministers_page
    ministerial_roles_path
  end

  def new_detailed_guides_page
    new_admin_detailed_guide_path
  end

  def visit_organisation(name)
    organisation = Organisation.find_by_name!(name)
    visit organisation_path(organisation)
  end

  def visit_organisation_about_page(name)
    organisation = Organisation.find_by_name!(name)
    visit about_organisation_path(organisation)
  end

  def visit_worldwide_organisation_page(name)
    worldwide_organisation = WorldwideOrganisation.find_by_name!(name)
    visit worldwide_organisation_path(worldwide_organisation)
  end

  def visit_topic(name)
    visit topic_path(Topic.find_by_name!(name))
  end
end

World(NavigationHelpers)
