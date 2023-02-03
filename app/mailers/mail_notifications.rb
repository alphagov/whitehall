require "zip"

class MailNotifications < ApplicationMailer
  include ActionView::RecordIdentifier
  include ActionView::Helpers::TextHelper
  include Admin::EditionRoutesHelper

  default from: "<winston@alphagov.co.uk>"

  def fact_check_request(request, url_options)
    @fact_check_request = request
    @url_options = url_options

    to_address = request.email_address
    subject = "Fact checking request from #{request.requestor.name}: #{request.edition_title}"

    view_mail template_id,
              to: to_address,
              subject:
  end

  def fact_check_response(request, url_options)
    @fact_check_request = request
    @url_options = url_options
    @comment_url = admin_edition_url(request.edition, url_options.merge(anchor: "fact_checking_tab"))

    to_address = request.requestor.email
    subject = "Fact check comment added by #{request.email_address}: #{request.edition_title}"

    view_mail template_id,
              to: to_address,
              subject:
  end

  def edition_published(author, edition, admin_url, public_url)
    @author = author
    @edition = edition
    @admin_url = admin_url
    @public_url = public_url
    subject = "The #{edition.format_name} '#{edition.title}' has been published"
    view_mail template_id,
              to: @author.email,
              subject:
  end

  def edition_rejected(author, edition, admin_url)
    @author = author
    @edition = edition
    @admin_url = admin_url
    subject = "The #{edition.format_name} '#{edition.title}' was rejected by #{edition.rejected_by.name}"
    view_mail template_id,
              to: @author.email,
              subject:
  end

  def edition_published_by_monitored_user(user)
    @user = user
    subject = "Account holder #{@user.name} (#{user.email}) has published to live"
    view_mail template_id,
              to: content_second_line_email_address,
              subject:
  end

  def broken_link_reports(public_url, recipient_address)
    @public_url = public_url
    view_mail template_id,
              to: recipient_address,
              subject: "Monthly Whitehall broken links report"
  end

  def document_list(public_url, recipient_address, filter_title)
    @public_url = public_url

    view_mail template_id,
              to: recipient_address,
              subject: "#{filter_title} from GOV.UK"
  end

  def consultation_deadline_upcoming(consultation, weeks_left:, recipient_address:)
    @title = consultation.title
    @weeks_left = weeks_left

    view_mail template_id,
              to: recipient_address,
              subject: "Consultation response due in #{pluralize(weeks_left, 'week')}"
  end

  def consultation_deadline_passed(consultation, recipient_address:)
    @title = consultation.title

    view_mail template_id,
              to: recipient_address,
              subject: "Consultation deadline breached"
  end

  helper_method :production?

  def production?
    GovukAdminTemplate.environment_style == "production"
  end

private

  def no_reply_email_address
    name = "GOV.UK publishing"
    unless production?
      name.prepend("[GOV.UK #{GovukAdminTemplate.environment_label}] ")
    end

    email_address = "inside-government@digital.cabinet-office.gov.uk"
    unless production?
      email_address = "inside-government+#{GovukAdminTemplate.environment_style}@digital.cabinet-office.gov.uk"
    end

    address = Mail::Address.new(email_address)
    address.display_name = name
    address.format
  end

  def content_second_line_email_address
    "second-line-content@digital.cabinet-office.gov.uk"
  end
end
