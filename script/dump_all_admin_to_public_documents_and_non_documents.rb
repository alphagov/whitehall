require 'csv'
require 'ostruct'
include Rails.application.routes.url_helpers, PublicDocumentRoutesHelper, Admin::EditionRoutesHelper

#mysql_slave_config = ActiveRecord::Base.configurations['production'].merge('host' => 'slave.mysql')
#ActiveRecord::Base.establish_connection(mysql_slave_config)
#
ENV['FACTER_govuk_platform'] ||= "production"

admin_host = "whitehall-admin.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk"
host_name = (ENV['FACTER_govuk_platform'] == 'production' ? 'www.gov.uk' : 'www.preview.alphagov.co.uk')


module PublicDocumentRoutesHelper
  def request
    OpenStruct.new(host: "whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk")
  end
end

CSV.open(Rails.root.join('public/government/all_document_attachment_and_non_document_mappings.csv'), 'wb') do |csv_out|

  csv_out << ['Old Url','New Url','Status','Whole Tag','Slug','Admin Url','State']
  Document.all.each do |document|
    edition = document.published_edition || document.latest_edition
    if edition
      status = (edition.state == 'published' ? '301' : '')
      whole_tag = (edition.state == 'published' ? 'Closed' : 'Open')
      csv_out << [document.document_sources.any? ? document.document_sources.first.url : '', public_document_url(edition, protocol: 'https'), status, whole_tag, document.slug, admin_edition_url(edition, host: admin_host, protocol: 'https'), edition.state]
    else
      csv_out << [document.document_sources.any? ? document.document_sources.first.url : '' , '', '', 'Open']
    end
  end

  ###### ATTACHMENT SOURCES

  AttachmentSource.all.each do |attachment_source|
    attachment_url = attachment_source.attachment ? host_name + attachment_source.attachment.url : ""
    status = (attachment_url.blank? ? '' : '301')
    whole_tag = (attachment_url.blank? ? 'Open' : 'Closed')
    csv_out << [attachment_source.url, attachment_url, status, whole_tag]
  end

  SupportingPage.find_each do |page|
    next unless page.edition.present?
    csv_out << [
      '',
      admin_edition_supporting_page_url(page, edition_id: page.edition_id, host: admin_host, protocol: 'https'),
      policy_supporting_page_url(page.edition.document, page, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
  end

  Person.find_each do |person|
    csv_out << [
      '',
      admin_person_url(person, host: admin_host, protocol: 'https'),
      person_url(person, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
    csv_out << [
      '',
      edit_admin_person_url(person, host: admin_host, protocol: 'https'),
      person_url(person, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
  end

  PolicyAdvisoryGroup.find_each do |group|
    csv_out << [
      '',
      admin_policy_advisory_group_url(group, host: admin_host, protocol: 'https'),
      policy_advisory_group_url(group, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
    csv_out << [
      '',
      edit_admin_policy_advisory_group_url(group, host: admin_host, protocol: 'https'),
      policy_advisory_group_url(group, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
  end

  PolicyTeam.find_each do |team|
    csv_out << [
      '',
      admin_policy_team_url(team, host: admin_host, protocol: 'https'),
      policy_team_url(team, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
    csv_out << [
      '',
      edit_admin_policy_team_url(team, host: admin_host, protocol: 'https'),
      policy_team_url(team, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
  end

  Role.find_each do |role|
    csv_out << [
      '',
      admin_role_url(role, host: admin_host, protocol: 'https'),
      ministerial_role_url(role, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
    csv_out << [
      '',
      edit_admin_role_url(role, host: admin_host, protocol: 'https'),
      ministerial_role_url(role, host: host_name, protocol: 'https'),
      '',
      'Open'
    ]
  end
end
