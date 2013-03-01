class AttachmentUploadValidator < ActiveModel::Validator
  def validate(record)
    if record.file.present? && failed_examiner = zip_file_error(record)
      record.errors.add(:file, failed_examiner.failure_message)
    end
  end

  def zip_file_error(record)
    extension = record.file.file.extension.to_s
    return unless extension == 'zip'

    examiners_for(record).detect { |examiner| !examiner.valid? }
  end

  def examiners_for(record)
    zip_file = ZipFile.new(record.file.path)

    if record.skip_file_content_examination?
      [ ZipFile::UTF8FilenamesExaminer.new(zip_file) ]
    else
      [ ZipFile::UTF8FilenamesExaminer.new(zip_file),
        ZipFile::AnyValidExaminer.new(zip_file, [
          ZipFile::WhitelistedExtensionsExaminer.new(zip_file, AttachmentUploader::EXTENSION_WHITE_LIST - ['zip']),
          ZipFile::ArcGISShapefileExaminer.new(zip_file)
        ])
      ]
    end
  end

  class ZipFile
    class NonUTF8ContentsError < RuntimeError; end

    def initialize(zip_path)
      @zip_path = zip_path
    end

    def filenames
      unless @filenames
        zipinfo_output = `#{Whitehall.system_binaries[:zipinfo]} -1 "#{@zip_path}"`
        @filenames = zipinfo_output.split(/[\r\n]+/)
      end
      @filenames
    rescue ArgumentError => e
      raise NonUTF8ContentsError, "Some filenames in zip aren't UTF-8: #{zipinfo_output}"
    end

    def extensions
      filenames.map do |f|
        if match = f.match(/\.([^\.]+)\Z/)
          match[1]
        else
          nil
        end
      end.compact
    end

    class Examiner < Struct.new(:zip_file); end

    class UTF8FilenamesExaminer < Examiner
      def valid?
        zip_file.filenames
        true
      rescue NonUTF8ContentsError
        false
      end

      def failure_message
        "contains filenames that aren't encoded in UTF-8"
      end
    end

    class WhitelistedExtensionsExaminer < Examiner
      def initialize(zip_file, whitelist)
        super(zip_file)
        @whitelist = whitelist
      end

      def extensions_in_file
        @extensions_in_file ||= zip_file.extensions.uniq
      end

      def illegal_extensions
        @illegal_extensions ||= extensions_in_file - @whitelist
      end

      def valid?
        illegal_extensions.empty?
      end

      def failure_message
        "contains illegal file types"
      end
    end

    class ArcGISShapefileExaminer < Examiner
      REQUIRED_EXTS = ['shp', 'shx', 'dbf']
      OPTIONAL_EXTS = ['prj', 'sbn', 'sbx', 'fbn', 'fbx', 'ain', 'aih',
                       'ixs', 'mxs', 'atx', 'shp.xml', 'cpg']
      ALLOWED_EXTS = REQUIRED_EXTS + OPTIONAL_EXTS
      EXT_MATCHER = /\.(#{ALLOWED_EXTS.map {|e| Regexp.escape(e)}.join('|')})\Z/

      def files_with_extensions
        @files_with_extensions ||=
          zip_file.filenames.map { |f|
            if (match = f.match(EXT_MATCHER))
              [f, match[1]]
            else
              [f, nil]
            end
          }
      end

      def files_by_shape_and_allowed_extension
        @files_by_shape_and_allowed_extension ||=
          Hash[
            files_with_extensions.
              reject { |file, ext| ext.nil? }.
              group_by { |file, ext| file.gsub(/\.#{Regexp.escape(ext)}\Z/,'')}.
              map { |shape, files|
                [ shape, files.group_by { |file, ext| ext } ]
              }
          ]
      end

      def has_no_extra_files?
        files_with_extensions.select { |(f, e)| e.nil? }.empty?
      end

      def each_shape_has_only_one_of_each_allowed_file?
        files_by_shape_and_allowed_extension.all? do |shape, files|
          files.
            select { |ext, files| files.size > 1 }.
            empty?
        end
      end

      def each_shape_has_required_files?
        files_by_shape_and_allowed_extension.all? do |shape, files|
          files.
            select { |ext, files| REQUIRED_EXTS.include? ext }.
            reject { |ext, files| files.size > 1 }.
            keys.sort == REQUIRED_EXTS.sort
        end
      end

      def valid?
        has_no_extra_files? &&
          each_shape_has_only_one_of_each_allowed_file? &&
          each_shape_has_required_files?
      end

      def failure_message
        "is not a valid ArcGIS file"
      end
    end

    class AnyValidExaminer < Examiner
      def initialize(zip_file, others)
        super(zip_file)
        @others = others
      end

      def valid?
        @others.any? { |other| other.valid? }
      end

      def failure_message
        "#{@others.map {|o| o.failure_message}.join(' or ')}"
      end
    end
  end
end
