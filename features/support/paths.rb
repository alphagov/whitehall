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
    organisation = Organisation.find_by!(name: name)
    visit organisation_path(organisation)
  end

  def visit_organisation_about_page(name)
    organisation = Organisation.find_by!(name: name)
    visit organisation_corporate_information_pages_path(organisation)
  end

  def visit_organisation_email_signup_information_page(name)
    organisation = Organisation.find_by!(name: name)
    visit organisation_email_signup_information_path(organisation)
  end

  def visit_organisation_featured_policies_admin(name)
    organisation = Organisation.find_by!(name: name)
    visit admin_organisation_path(organisation)
    click_link "Featured policies"
  end

  def visit_worldwide_organisation_page(name)
    worldwide_organisation = WorldwideOrganisation.find_by!(name: name)
    visit worldwide_organisation_path(worldwide_organisation)
  end

  def visit_topic(name)
    visit topic_path(Topic.find_by!(name: name))
  end

  def public_path_for(edition)
    case edition
    when Publication
      publications_path
    when Speech
      announcements_path
    when Consultation
      consultations_path
    when DetailedGuide
      detailed_guide_path(edition.document)
    else
      raise "Don't know where to go for #{edition.class.name}s"
    end
  end

  def visit_public_index_for(edition)
    visit public_path_for(edition)
  end
end

World(NavigationHelpers)
