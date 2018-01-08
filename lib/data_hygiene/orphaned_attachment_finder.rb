require 'csv'

module DataHygiene
  class OrphanedAttachmentFinder
    def editions_with_orphaned_attachments
      @editions_with_orphaned_attachments ||= find
    end

    def summarize_by_type
      "Documents with all/some attachments not referenced by inline tags:\n\n" +
        ("%-30s %-11s %-11s" % ["", "Published", "Other"]) + "\n" +
        ("%-30s %5s %5s %5s %5s" % ["", "All--", "Some-", "All--", "Some-"]) + "\n" +
        editions_with_orphaned_attachments.group_by { |e| e[:edition].class.name }.map do |class_name, batch|
          published, other = batch.partition { |r| r[:state] == "published" }
          all_missing_published, some_missing_published = published.partition { |r| r[:actual].size == 0 }
          all_missing_other, some_missing_other = other.partition { |r| r[:actual].size == 0 }
          ("%-30s %5s %5s %5s %5s" % [class_name, all_missing_published.size, some_missing_published.size, all_missing_other.size, some_missing_other.size])
        end.join("\n")
    end

    def by_document
      editions_with_orphaned_attachments.group_by do |record|
        if record[:edition].respond_to?(:document_id)
          record[:edition].document_id
        else
          record[:edition].class.name + record[:edition].id.to_s
        end
      end
    end

    def dump
      CSV.generate do |csv|
        csv << ["type", "title", "admin url", "state", "missing placeholders"]
        by_document.each do |_document_id, records|
          records.each do |record|
            edition = record[:edition]
            csv << [
              edition.type,
              edition.title,
              edition.respond_to?(:state) && edition.state,
              admin_url(edition),
              record[:expected] - record[:actual]
            ]
          end
        end
      end
    end

  private

    def find
      editions_with_orphaned_attachments = []
      [StatisticalDataSet, CorporateInformationPage, DetailedGuide].each do |klass|
        klass.includes(:attachments).each do |edition|
          if edition.respond_to?(:published?) && edition.respond_to?(:is_latest_edition?)
            next unless edition.published? || edition.is_latest_edition?
            state = edition.state
          else
            state = "published"
          end
          next if state == 'superseded'
          num_attachments = edition.attachments.count
          actual_placeholders = edition.body.scan(/!@[1-9][0-9]*/).sort
          expected_placeholders = 1.upto(num_attachments).map { |n| "!@#{n}" }
          missing = expected_placeholders - actual_placeholders
          if missing.any?
            editions_with_orphaned_attachments << {
              edition: edition,
              expected: expected_placeholders,
              actual: actual_placeholders,
              state: state
            }
          end
        end
      end
      editions_with_orphaned_attachments
    end

    def admin_url(thing)
      case thing
      when CorporateInformationPage
        Whitehall.url_maker.admin_organisation_corporate_information_page_url(thing.organisation, thing)
      when StatisticalDataSet, DetailedGuide
        Whitehall.url_maker.admin_edition_url(thing)
      end
    end
  end
end
