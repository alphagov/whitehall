# Alt Text to Caption Migration
#
# This rake task migrates alt text content to caption fields for images in Whitehall.
# It applies conditional logic to determine the best caption based on existing alt text
# and caption content, handling credit terms, duplicates, and length preferences.
#
# The migration is idempotent - it can be safely re-run multiple times. Images are
# processed in batches and alt text is cleared after processing to mark completion.
# Documents with updated images are automatically enqueued for republishing to make
# changes visible to users.
#
# Usage with GOV.UK Docker:
#   govuk-docker-run bundle exec rake data_migration:alt_text_to_caption
# Usage with kubernetes:
#   k exec -it deploy/whitehall-admin -- rake 'data_migration:alt_text_to_caption'
#
# Business Logic:
# 1. Empty alt text → keep existing caption
# 2. Identical content → avoid duplication
# 3. Credit terms + descriptive alt text (>10 chars) → combine: "alt text [caption]"
# 4. Default → use longer text (or alt text if caption empty)
# 5. Changed images → enqueue document for republishing
#
require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

ALT_TEXT_MIGRATION_BATCH_SIZE = 1000
ALT_TEXT_MIGRATION_DESCRIPTIVE_MIN_LENGTH = 10
ALT_TEXT_MIGRATION_CREDIT_TERMS = ["credit", "copyright", "source", "©", "crown copyright"].freeze

namespace :data_migration do
  desc "Migrate alt text to caption fields with confirmation"
  task alt_text_to_caption: :environment do
    images_scope = Image.where.not(alt_text: [nil, ""])
    total_images = images_scope.count

    puts "=== Alt Text to Caption Migration ==="
    puts "Found #{total_images} images with alt text to process"

    if total_images.zero?
      puts "No images with alt text found. Migration is complete!"
      next
    end

    if Rails.env.test?
      puts "\n--- RUNNING MIGRATION ---"
      perform_migration(images_scope, dry_run: false)
      next
    end

    shell.say "About to process #{total_images} images. Would you like to apply the updates for real, show a preview of what the changes will be, or cancel?", :cyan
    shell.say "  1) Dry run (preview only)"
    shell.say "  2) Apply changes (no preview)"
    shell.say "  3) Cancel"

    choice = nil
    attempts = 0
    max_attempts = 10

    while choice.nil? && attempts < max_attempts
      attempts += 1
      response = shell.ask("Enter 1, 2, or 3:")

      if response.nil? || response.to_s.strip.empty?
        shell.say "No input received. Please enter 1, 2, or 3.", :red
        next
      end

      response = response.to_s.strip
      if %w[1 2 3].include?(response)
        choice = response
      else
        shell.say "Your response must be one of: 1, 2, or 3. Please try again.", :red
      end
    end

    if choice.nil?
      shell.say "Too many invalid attempts or input system not working. Exiting.", :red
      next
    end

    mode =
      case choice
      when "1" then :dry_run
      when "2" then :apply
      else
        shell.say "Cancelled.", :yellow
        next
      end

    if mode == :dry_run
      puts "\n--- DRY RUN PREVIEW ---"
      perform_migration(images_scope, dry_run: true)
    else
      puts "\n--- RUNNING MIGRATION ---"
      perform_migration(images_scope, dry_run: false)
    end
  end
end

def perform_migration(images_scope, dry_run:)
  total_images = images_scope.count

  puts "#{dry_run ? 'DRY RUN - ' : ''}Processing #{total_images} images with alt text..."

  if dry_run && total_images.positive?
    puts "\n Full migration preview (save this output for reference):"
    puts "Migration Date: #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}"
    puts "Total Images: #{total_images}"
  end

  updated_count = 0
  republish_count = 0
  start_time = Time.current

  images_scope.find_in_batches(batch_size: ALT_TEXT_MIGRATION_BATCH_SIZE) do |batch|
    batch.each do |image|
      new_caption = determine_new_caption(image.alt_text, image.caption)
      current_caption = image.caption.to_s.strip

      if new_caption != current_caption
        if dry_run
          puts "\nImage ##{image.id} - CAPTION WILL CHANGE:"
          puts "  Alt text: \"#{image.alt_text}\""
          puts "  Current caption: \"#{current_caption.presence || '(empty)'}\""
          puts "  New caption: \"#{new_caption}\""
          display_document_info(image)
          puts "  → Will enqueue for republishing"
        else
          image.update_columns(caption: new_caption, alt_text: nil)
          enqueue_republishing(image)
        end
        updated_count += 1
        republish_count += 1
      elsif dry_run
        puts "\nImage ##{image.id} - NO CAPTION CHANGE (alt text will be cleared):"
        puts "  Alt text: \"#{image.alt_text}\" → (cleared)"
        puts "  Caption: \"#{current_caption.presence || '(empty)'}\" → (unchanged)"
        display_document_info(image)
      else
        image.update_column(:alt_text, nil)
      end
    end
  end

  if dry_run
    puts "\n#{'=' * 80}"
    puts "DRY RUN SUMMARY:"
    puts "#{updated_count}/#{total_images} images would have caption changes"
    puts "#{republish_count} documents would be enqueued for republishing"
    puts "#{total_images - updated_count} images would only have alt_text cleared"
    puts "=" * 80
  else
    puts "\n\nMigration complete! Updated #{updated_count}/#{total_images} captions."
    puts "Enqueued #{republish_count} documents for republishing."
    puts "Total time: #{(Time.current - start_time).round(1)} seconds"
  end
end

def display_document_info(image)
  puts "  Document: #{image.edition&.document_id ? "#{image.edition.title} (ID: #{image.edition.document_id})" : 'No document'}"
end

def determine_new_caption(alt_text, caption)
  alt_text = alt_text.to_s.strip
  caption = caption.to_s.strip

  return caption if alt_text.blank?
  return caption if alt_text == caption

  if caption_starts_with_credit_terms?(caption) && alt_text.length > ALT_TEXT_MIGRATION_DESCRIPTIVE_MIN_LENGTH
    return "#{alt_text} [#{caption}]"
  end

  if caption.blank? || alt_text.length > caption.length
    alt_text
  else
    caption
  end
end

def caption_starts_with_credit_terms?(caption)
  return false if caption.blank?

  ALT_TEXT_MIGRATION_CREDIT_TERMS.any? { |term| caption.downcase.start_with?(term) }
end

def enqueue_republishing(image)
  return unless image.edition&.document_id

  PublishingApiDocumentRepublishingWorker.perform_async(image.edition.document_id)
rescue StandardError => e
  puts "Warning: Failed to enqueue republishing for image #{image.id}, edition #{image.edition&.id}: #{e.message}"
end
