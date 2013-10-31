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

  def visit_public_index_for(edition)
    case edition
    when Publication
      visit publications_path
    when NewsArticle, Speech
      visit announcements_path
    when Consultation
      visit consultations_path
    when Policy
      visit policies_path
    when DetailedGuide
      visit detailed_guide_path(edition.document)
    when WorldwidePriority
      visit worldwide_priorities_path
    else
      raise "Don't know where to go for #{edition.class.name}s"
    end
  end
end

World(NavigationHelpers)
