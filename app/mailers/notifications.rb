require "zip"

class Notifications < ApplicationMailer
  include ActionView::RecordIdentifier
  include ActionView::Helpers::TextHelper
  include Admin::EditionRoutesHelper

  def fact_check_request(request, url_options)
    @fact_check_request = request
    @url_options = url_options

    from_address = no_reply_email_address
    to_address = request.email_address
    subject = "Fact checking request from #{request.requestor.name}: #{request.edition_title}"

    mail(from: from_address, to: to_address, subject: subject)
  end

  def fact_check_response(request, url_options)
    @fact_check_request = request
    @url_options = url_options
    @comment_url = admin_edition_url(request.edition, url_options.merge(anchor: dom_id(request)))

    from_address = no_reply_email_address
    to_address = request.requestor.email
    subject = "Fact check comment added by #{request.email_address}: #{request.edition_title}"

    mail(from: from_address, to: to_address, subject: subject)
  end

  def edition_published(author, edition, admin_url, public_url)
    @author = author
    @edition = edition
    @admin_url = admin_url
    @public_url = public_url
    subject = "The #{edition.format_name} '#{edition.title}' has been published"
    mail from: no_reply_email_address, to: @author.email, subject: subject
  end

  def edition_rejected(author, edition, admin_url)
    @author = author
    @edition = edition
    @admin_url = admin_url
    subject = "The #{edition.format_name} '#{edition.title}' was rejected by #{edition.rejected_by.name}"
    mail from: no_reply_email_address, to: @author.email, subject: subject
  end

  def edition_published_by_monitored_user(user)
    @user = user
    subject = "Account holder #{@user.name} (#{user.email}) has published to live"
    mail from: no_reply_email_address, to: content_second_line_email_address, subject: subject
  end

  def broken_link_reports(zip_path, recipient_address)
    filename = File.basename(zip_path)
    attachments[filename] = File.read(zip_path)

    mail from: no_reply_email_address, to: recipient_address, subject: "GOV.UK broken link reports"
  end

  def document_list(csv, recipient_address, filter_title)
    stream = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry("document_list.csv")
      zip.write(csv)
    end

    stream.rewind

    attachments["document_list.zip"] = stream.sysread

    mail from: no_reply_email_address, to: recipient_address, subject: "#{filter_title} from GOV.UK"
  end

  def consultation_deadline_upcoming(consultation, weeks_left:)
    @title = consultation.title
    @weeks_left = weeks_left

    mail from: no_reply_email_address,
      to: consultation.authors.uniq.map(&:email),
      subject: "Consultation response due in #{pluralize(weeks_left, 'week')}"
  end

  def consultation_deadline_passed(consultation)
    @title = consultation.title

    mail from: no_reply_email_address,
      to: consultation.authors.uniq.map(&:email),
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
