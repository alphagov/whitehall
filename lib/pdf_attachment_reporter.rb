#  Notes/limitations of this report
#
#  - We do not take into account changes in ownership of a document with
#  a PDF attachment over time. Instead we take the most recently-published
#  version of the document as the correct source of ownership.
#
#  - A document that has had a PDF published in the past under one name that
#  is subsequently replaced by a PDF with another name is counted in the
#  report twice. Even though the site shows only one PDF.
#
#  - All policy group attachments are lumped into one category
#
#  - Finding the organisation which owns a PDF can be complex. In
#  cases where there are multiple owners, we first try to find a parent
#  organisation, if we know that all associated organisations are related.
#  Otherwise we assume that the first organisation in the list is a best
#  guess.

require 'csv'
require 'ruby-progressbar'

class PDFAttachmentReporter
  POLICY_GROUPS = 'Policy Groups'.freeze

  def initialize(opts = {})
    @data_path = opts.fetch(:data_path, Rails.root)
    @first_period_start_date = opts.fetch(:first_period_start_date, Date.parse('2016-01-01'))
    @last_time_period_days = opts.fetch(:last_time_period_days, 30)
  end

  def pdfs_by_organisation
    second_time_period_date = @last_time_period_days.days.ago.to_date

    live_organisation_names = Organisation.where(govuk_status: 'live').includes(:translations).map(&:name) << POLICY_GROUPS

    live_organisation_published_pdfs_total_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]
    live_organisation_published_pdfs_since_first_period_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]
    live_organisation_published_pdfs_since_second_period_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]

    attachment_ids = unique_published_pdf_attachments.pluck(:id)

    progress_bar.total = attachment_ids.size
    progress_bar.start

    Attachment.where(id: attachment_ids).find_each do |attachment|
      progress_bar.log("Processing Attachment ##{attachment.id}...")

      pdf_attachment_data = find_pdf_attachment_data(attachment)

      if pdf_attachment_data
        live_organisation_published_pdfs_total_counts_hash[pdf_attachment_data.owning_organisation_name] += 1

        if pdf_attachment_data.created_at >= second_time_period_date
          live_organisation_published_pdfs_since_second_period_counts_hash[pdf_attachment_data.owning_organisation_name] += 1
        end

        if pdf_attachment_data.created_at >= @first_period_start_date
          live_organisation_published_pdfs_since_first_period_counts_hash[pdf_attachment_data.owning_organisation_name] += 1
        end
      end

      progress_bar.increment
    end
    progress_bar.finish

    CSV.open(csv_file_path, 'wb') do |csv|
      csv << [
        "Organisation",
        "Total published PDF attachments",
        "#{@first_period_start_date} - present PDF attachments",
        "Last #{@last_time_period_days} days PDF attachments"
      ]

      live_organisation_names.each do |organisation_name|
        csv << [
          organisation_name,
          live_organisation_published_pdfs_total_counts_hash[organisation_name],
          live_organisation_published_pdfs_since_first_period_counts_hash[organisation_name],
          live_organisation_published_pdfs_since_second_period_counts_hash[organisation_name]
        ]
      end
    end
  end

private

  PDFAttachmentData = Struct.new(:owning_organisation_name, :created_at)

  def find_pdf_attachment_data(attachment)
    if attachment.attachable
      if attachment.attachable_type == 'PolicyGroup'
        PDFAttachmentData.new(POLICY_GROUPS, attachment.created_at)
      else
        # Responses are only sometimes linked to organisations (via a consultation)
        if attachment.attachable.is_a? Response
          if attachment.attachable.consultation
            pdf_attachment_data_from_edition(attachment.attachable.consultation, attachment.attachment_data)
          end
        else
          pdf_attachment_data_from_edition(attachment.attachable, attachment.attachment_data)
        end
      end
    end
  end

  def pdf_attachment_data_from_edition(edition, attachment_data)
    last_published_edition_with_attachment = find_last_published_edition_with_attachment(edition, attachment_data)

    if last_published_edition_with_attachment
      pdf_owning_organisation = guess_organisation_owner_of_edition(last_published_edition_with_attachment)
      first_published_edition_with_attachment = find_first_published_version_with_attachment(edition)
    end

    if pdf_organisation_live_and_edition_has_timestamp(pdf_owning_organisation, first_published_edition_with_attachment)
      PDFAttachmentData.new(pdf_owning_organisation.name, first_published_edition_with_attachment.public_timestamp)
    end
  end

  def pdf_organisation_live_and_edition_has_timestamp(pdf_owning_organisation, edition)
    pdf_owning_organisation && pdf_owning_organisation.live? && edition && edition.public_timestamp
  end

  def find_last_published_edition_with_attachment(edition, attachment_data)
    edition.document.ever_published_editions.order('created_at DESC').detect do |ed|
      ed.attachments.any? { |a| a.attachment_data_id == attachment_data.id }
    end
  end

  def find_first_published_version_with_attachment(edition)
    edition.document.ever_published_editions
      .order('created_at DESC')
      .joins("INNER JOIN attachments ON attachable_id = editions.id AND attachable_type = 'Edition'")
      .first
  end

  def guess_organisation_owner_of_edition(edition)
    # Corporate information pages are unusual in that their organisations array
    # can contain a worldwide organisation. If this is the case, then we want to
    # use that organisation's sponsor.
    if edition.organisations.first.class == WorldwideOrganisation
      edition.organisations.first.sponsoring_organisation
    else
      organisation_ids = edition.organisations.map(&:id)

      if any_organisations_unrelated?(edition, organisation_ids)
        # If there is at least one unrelated organisation, assume the first organisation in the list is the owner
        if edition.respond_to?(:lead_organisations)
          edition.lead_organisations.detect { |org| org.class == Organisation }
        else
          edition.organisations.detect { |org| org.class == Organisation }
        end
      else
        # If all organisations are related, use the parent organisation as the owner
        edition.organisations.detect do |org|
          (org.parent_organisation_ids & organisation_ids).none?
        end
      end
    end
  end

  def any_organisations_unrelated?(edition, all_organisation_ids)
    edition.organisations.any? do |org|
      (org.class != Organisation) || ((org.child_organisation_ids + org.parent_organisation_ids) & all_organisation_ids).none?
    end
  end

  def unique_published_pdf_attachments
    Attachment.joins(:attachment_data)
      .where(attachment_data: { content_type: AttachmentUploader::PDF_CONTENT_TYPE })
      .group('attachment_data.id')
      .includes(:attachment_data)
  end

  def unique_pdf_count
    AttachmentData.joins(:attachments)
      .where(content_type: AttachmentUploader::PDF_CONTENT_TYPE)
      .uniq.count
  end

  def csv_file_path
    File.join(@data_path, "pdf-attachments-report-#{Time.zone.now.strftime('%y%m%d-%H%M%S')}.csv")
  end

  def progress_bar
    @progress ||= ProgressBar.create(
      autostart: false,
      format: "%e [%b>%i] [%c/%C]"
    )
  end
end
