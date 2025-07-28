class MailNotifications < ApplicationMailer
  include ActionView::RecordIdentifier
  include ActionView::Helpers::TextHelper
  include Admin::EditionRoutesHelper

  default from: "<winston@alphagov.co.uk>"
  CONTENT_SECOND_LINE_EMAIL_ADDRESS = "second-line-content@digital.cabinet-office.gov.uk".freeze

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
              to: CONTENT_SECOND_LINE_EMAIL_ADDRESS,
              subject:
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

  def call_for_evidence_reminder(call_for_evidence, recipient_address:)
    @title = call_for_evidence.title

    view_mail template_id,
              to: recipient_address,
              subject: "Reminder: Call for evidence \"#{@title}\" closed 8 weeks ago"
  end

  def review_reminder(edition, recipient_address:)
    @title = edition.title
    @format_name = edition.format_name
    @link_to_summary_page = admin_edition_url(edition)

    view_mail template_id,
              to: recipient_address,
              subject: "#{edition.format_name.capitalize} '#{edition.title}' has reached its set review date"
  end
end
