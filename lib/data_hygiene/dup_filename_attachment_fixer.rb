module DataHygiene
  class DupFilenameAttachmentFixer < Struct.new(:attachable)

    def run!
      file_attachments.each do |attachment|
        DuplicateFilenameReplacer.new(attachment, file_attachments).replace_duplicates
      end
    end

    def file_attachments
      @file_attachments ||= attachable.attachments.files
    end

    class DuplicateFilenameReplacer < Struct.new(:attachment, :attachments)

      def initialize(attachment, attachments)
        @sequence_number = 0
        super
      end

      def conflicts
        other_attachments.select { |candidate| attachment.filename.downcase == candidate.filename.downcase }
      end

      def other_attachments
        attachments.select { |candidate| attachment != candidate }
      end

      def replace_duplicates
        conflicts.each { |conflict| rename_and_replace_attachment_data(conflict) }
      end

      def rename_and_replace_attachment_data(conflict)
        file                     = conflict.file
        renamed_file             = ActionDispatch::Http::UploadedFile.new(filename: next_available_filename, tempfile: file)
        conflict.attachment_data = AttachmentData.create!(file: renamed_file, to_replace_id: conflict.attachment_data_id)
        conflict.save!
      end

      def next_available_filename
        begin
          filename = next_filename
        end while already_exists?(filename)
        filename
      end

      def next_filename
        "#{basename}-#{next_in_sequence}.#{extension}"
      end

      def already_exists?(filename)
        other_attachments.any? { |attachment| attachment.filename.downcase == filename.downcase }
      end

    private

      def next_in_sequence
        @sequence_number += 1
      end

      def basename
        File.basename(attachment.file.path, ".#{extension}")
      end

      def extension
        attachment.file_extension
      end
    end
  end
end
