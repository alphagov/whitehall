require 'data_hygiene/policy_redirect_identifier'
require 'data_hygiene/supporting_page_redirect_identifier'
require 'csv'

class RedirectGenerator
  HEADER = %w(source destination)

  attr_reader :csv
  def initialize
    @csv = CSV.open(Rails.root.join("data/policy_redirects.csv"), 'w')
  end

  def generate!
    csv << HEADER

    Policy.published.includes(:document).with_translations.find_each do |policy|
      csv << policy_redirect_row(policy)
      # If a policy is being retired, we want to replace the feed URLs with gone
      # routes. The empty value for the destination will be used to signify this.
      if policy_being_retired?(policy)
        csv << [url_maker.activity_policy_path(policy.document), nil]
        csv << [url_maker.activity_policy_path(policy.document, format: :atom), nil]
      else
        csv << policy_activity_redirect_row(policy)
        csv << policy_activity_atom_redirect_row(policy)
      end
      policy.published_supporting_pages.each do |supporting_page|
        csv << supporting_page_redirect_row(supporting_page, policy)
      end
    end

    csv.close
  end

private

  def policy_redirect_row(policy)
    [
      url_maker.policy_path(policy.document),
      policy_redirect_path(policy),
    ]
  end

  def policy_activity_redirect_row(policy)
    [
      url_maker.activity_policy_path(policy.document),
      policy_redirect_path(policy),
    ]
  end

  def policy_activity_atom_redirect_row(policy)
    [
      url_maker.activity_policy_path(policy.document, format: 'atom'),
      policy_atom_redirect_path(policy),
    ]
  end

  def supporting_page_redirect_row(supporting_page, policy)
    [
      url_maker.public_document_path(supporting_page, policy_id: policy.document),
      supporting_page_redirect_path(supporting_page, policy),
    ]
  end

  def policy_being_retired?(policy)
    policy_redirect_path(policy).starts_with?("/government/publications")
  end

  def policy_redirect_path(policy)
    DataHygiene::PolicyRedirectIdentifier.new(policy).redirect_path
  end

  def policy_atom_redirect_path(policy)
    policy_redirect_path(policy) + ".atom"
  end

  def supporting_page_redirect_path(supporting_page, policy)
    DataHygiene::SupportingPageRedirectIdentifier.new(supporting_page, policy).redirect_path
  end

  def url_maker
    @url_maker ||= Whitehall.url_maker
  end
end


RedirectGenerator.new.generate!
