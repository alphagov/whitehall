class Whitehall::Exporters::DocumentMappings < Struct.new(:platform)
  include Rails.application.routes.url_helpers, PublicDocumentRoutesHelper, Admin::EditionRoutesHelper

  def request
    OpenStruct.new(host: "whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk")
  end

  def row(public_url, admin_url)
    [
      '',
      public_url,
      '',
      '',
      admin_url,
      ''
    ]
  end

  def admin_host
    "whitehall-admin.#{platform}.alphagov.co.uk"
  end

  def host_name
    platform == 'production' ? 'www.gov.uk' : 'www.preview.alphagov.co.uk'
  end

  def edition_values(edition, document, document_source=nil)
    [ (document_source.try(:url) || ''),
      public_document_url(document.published_edition || document.latest_edition, protocol: 'https', locale: document_source.try(:locale)),
      http_status(edition),
      document.slug,
      admin_edition_url(edition, host: admin_host, protocol: 'https'),
      edition.state ]
  end

  def http_status(edition)
    case edition.state
    when 'published'
      '301'
    when 'draft'
      '418'
    else
      ''
    end
  end

  def export(target)
    target << ['Old Url','New Url','Status','Slug','Admin Url','State']
    Document.find_each do |document|
      document.editions.each do |edition|
        if document.document_sources.any?
          document.document_sources.each do |source|
            target << edition_values(edition, document, source)
          end
        else
          target << edition_values(edition, document)
        end
      end
    end

    ###### ATTACHMENT SOURCES

    AttachmentSource.all.each do |attachment_source|
      attachment_url = attachment_source.attachment ? host_name + attachment_source.attachment.url : ""
      status = (attachment_url.blank? ? '' : '301')
      state = (attachment_url.blank? ? 'Open' : 'Closed')
      target << [attachment_source.url, attachment_url, status, '', '', '', state]
    end

    SupportingPage.find_each do |page|
      next unless page.edition.present?
      target << row(
        policy_supporting_page_url(page.edition.document, page, host: host_name, protocol: 'https'),
        admin_supporting_page_url(page, host: admin_host, protocol: 'https')
      )
      target << row(
        policy_supporting_page_url(page.edition.document, page, host: host_name, protocol: 'https'),
        edit_admin_supporting_page_url(page, host: admin_host, protocol: 'https')
      )
    end

    Person.find_each do |person|
      target << row(
        person_url(person, host: host_name, protocol: 'https'),
        admin_person_url(person, host: admin_host, protocol: 'https')
      )
      target << row(
        person_url(person, host: host_name, protocol: 'https'),
        edit_admin_person_url(person, host: admin_host, protocol: 'https'),
      )
    end

    PolicyAdvisoryGroup.find_each do |group|
      target << row(
        policy_advisory_group_url(group, host: host_name, protocol: 'https'),
        admin_policy_advisory_group_url(group, host: admin_host, protocol: 'https')
      )
      target << row(
        policy_advisory_group_url(group, host: host_name, protocol: 'https'),
        edit_admin_policy_advisory_group_url(group, host: admin_host, protocol: 'https')
      )
    end

    PolicyTeam.find_each do |team|
      target << row(
        policy_team_url(team, host: host_name, protocol: 'https'),
        admin_policy_team_url(team, host: admin_host, protocol: 'https'),
      )
      target << row(
        policy_team_url(team, host: host_name, protocol: 'https'),
        edit_admin_policy_team_url(team, host: admin_host, protocol: 'https'),
      )
    end

    Role.find_each do |role|
      target << row(
        ministerial_role_url(role, host: host_name, protocol: 'https'),
        admin_role_url(role, host: admin_host, protocol: 'https'),
      )
      target << row(
        ministerial_role_url(role, host: host_name, protocol: 'https'),
        edit_admin_role_url(role, host: admin_host, protocol: 'https'),
      )
    end

    Organisation.find_each do |organisation|
      target << row(
        organisation_url(organisation, host: host_name, protocol: 'https'),
        admin_organisation_url(organisation, host: admin_host, protocol: 'https'),
      )
      target << row(
        organisation_url(organisation, host: host_name, protocol: 'https'),
        edit_admin_organisation_url(organisation, host: admin_host, protocol: 'https'),
      )
    end

    CorporateInformationPage.find_each do |page|
      organisation = page.organisation
      target << row(
        organisation_corporate_information_page_url(page, organisation_id: organisation, host: host_name, protocol: 'https'),
        edit_admin_organisation_corporate_information_page_url(page, organisation_id: organisation, host: admin_host, protocol: 'https')
      )
    end
  end
end
