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

  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /^the new policy page$/
      new_admin_document_path

    when /^the new publication page$/
      new_admin_document_path(type: 'publication')

    when /^the policies admin page$/
      admin_editions_path

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end

  def visit_organisation(name)
    organisation = Organisation.find_by_name!(name)
    visit organisation_path(organisation)
  end

  def visit_organisation_about_page(name)
    organisation = Organisation.find_by_name!(name)
    visit about_organisation_path(organisation)
  end
end

World(NavigationHelpers)
