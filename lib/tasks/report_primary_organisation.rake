namespace :report_primary_organisation do
  desc "A one-off CSV report of how many documents were initially published by authors who don't belong to the document's primary organisation"
  task :generate_csv, %i[user_email start_date] => :environment do |_task, args|
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    if args[:user_email].present? && args[:start_date].present? && args[:user_email].match(VALID_EMAIL_REGEX)
      require 'csv'
      require 'ruby-progressbar'

      class CSVReport
        def author_belongs_to_diff_org?(author, organisation)
          author.organisation.present? && organisation.present? && organisation.id != author.organisation.id
        end

        def header_row
          ['Admin URL',
           'First published',
           'Title',
           'Format',
           'Lead organisation',
           'First Author Name',
           'First Author Email Address',
           'First Author Organisation',
           'Last Author Name',
           'Last Author Email Address',
           'Last Author Organisation']
        end

        def get_last_author(edition)
          edition.published_by
        end

        def filtered_editions(start_date)
          @filtered ||= Edition.published.where("first_published_at >= ?", start_date)
        end

        def progress_bar
          @progress ||= ProgressBar.create(
            autostart: false,
            format: "%e [%b>%i] [%c/%C]"
          )
        end

        def generate_csv(start_date = nil)
          editions = filtered_editions(start_date)

          CSV.generate do |csv|
            progress_bar.total = editions.size
            progress_bar.start

            csv << header_row
            editions.find_each do |e|
              progress_bar.log("Processing edition ##{e.id}...")

              first_author = e.creator
              primary_organisation = e.type == 'CorporateInformationPage' ? e.owning_organisation : e.lead_organisations.first

              if author_belongs_to_diff_org?(first_author, primary_organisation)
                last_author = get_last_author(e)
                row = []
                row << Whitehall.url_maker.admin_edition_url(e)
                row << e.first_published_at.to_date
                row << e.title
                row << e.type.titleize
                row << primary_organisation
                row << first_author.try(:name) || 'Name missing'
                row << first_author.try(:email_address) || 'Email missing'
                row << first_author.try(:organisation) || 'Missing organisation'
                row << last_author.try(:name) || 'Name missing'
                row << last_author.try(:email_address) || 'Email missing'
                row << last_author.try(:organisation) || 'Missing organisation'

                csv << row
              end

              progress_bar.increment
            end

            progress_bar.finish
            csv
          end
        end
      end

      start_date = args[:start_date].to_date

      csv = CSVReport.new.generate_csv(start_date)
      email_title = "Primary organisation report for documents published on or after #{start_date} "
      Notifications.document_list(csv, args[:user_email], email_title).deliver_now
      puts "The report has been generated and emailed to #{args[:user_email]}"
    else
      puts "Please provide an email address and a start date"
    end
  end
end
