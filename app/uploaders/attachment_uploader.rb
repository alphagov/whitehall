# encoding: utf-8

class AttachmentUploader < WhitehallUploader
  PDF_CONTENT_TYPE = 'application/pdf'
  INDEXABLE_TYPES = %w(csv doc docx ods odp odt pdf ppt pptx rdf rtf txt xls xlsx xml)

  THUMBNAIL_GENERATION_TIMEOUT = 10.seconds
  FALLBACK_PDF_THUMBNAIL = File.expand_path("../../assets/images/pub-cover.png", __FILE__)
  EXTENSION_WHITELIST = %w(chm csv diff doc docx dot dxf eps gif gml ics jpg kml odp ods odt pdf png ppt pptx ps rdf ris rtf sch txt wsdl xls xlsm xlsx xlt xml xsd xslt zip).freeze

  before :cache, :validate_zipfile_contents!

  process :set_content_type
  def set_content_type
    filename = full_filename(file.file)
    types = MIME::Types.type_for(filename)
    content_type = types.first.content_type if types.any?
    content_type = "text/xml" if filename.end_with?(".xsd")
    content_type = "text/csv" if content_type == "text/comma-separated-values"
    content_type = "application/pdf" if content_type == "application/octet-stream"
    file.content_type = content_type
  end

  version :thumbnail, if: :pdf? do
    def full_filename(for_file)
      super + ".png"
    end

    def full_original_filename
      super + ".png"
    end

    process :generate_thumbnail
    before :store, :set_correct_content_type

    def set_correct_content_type(_ignore_argument)
      @file.content_type = "image/png"
    end
  end

  def generate_thumbnail
    get_first_page_as_png(105, 140)
  end

  def pdf?(file)
    file.content_type == PDF_CONTENT_TYPE
  end

  def get_first_page_as_png(width, height)
    output, exit_status = Timeout.timeout(THUMBNAIL_GENERATION_TIMEOUT) do
      [
        `#{pdf_thumbnail_command(width, height)}`,
        $?.exitstatus,
      ]
    end

    unless exit_status == 0
      Rails.logger.warn "Error thumbnailing PDF. Exit status: #{exit_status}; Output: #{output}"
      use_fallback_pdf_thumbnail
    end
  rescue Timeout::Error => e
    message = "PDF thumbnail generation took longer than #{THUMBNAIL_GENERATION_TIMEOUT} seconds. Using fallback pdf thumbnail: #{FALLBACK_PDF_THUMBNAIL}."
    Rails.logger.warn message

    GovukError.notify(
      e,
      extra: {
        error_message: message,
        path: relative_path,
      },
    )

    use_fallback_pdf_thumbnail
  end

  def pdf_thumbnail_command(width, height)
    %{gs -o #{path} -sDEVICE=pngalpha -dLastPage=1 -r72 -dDEVICEWIDTHPOINTS=#{width} -dDEVICEHEIGHTPOINTS=#{height} -dPDFFitPage #{path} 2>&1}
  end

  def extension_whitelist
    EXTENSION_WHITELIST
  end

  class ZipFile
    class NonUTF8ContentsError < RuntimeError; end

    def initialize(zip_path)
      @zip_path = zip_path
    end

    def filenames
      unless @filenames
        zipinfo_output = `#{Whitehall.system_binaries[:zipinfo]} -1 "#{@zip_path}" | grep -v /$ | while read -r line ; do basename "$line"; done`
        @filenames = zipinfo_output.split(/[\r\n]+/)
      end
      @filenames
    rescue ArgumentError => e
      raise NonUTF8ContentsError, "Some filenames in zip aren't UTF-8: #{zipinfo_output}"
    end

    def extensions
      filenames.map do |f|
        if match = f.match(/\.([^\.]+)\Z/)
          match[1].downcase
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
        "Your zipfile must not contain filenames that aren't encoded in UTF-8"
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
        "You are not allowed to upload a zip file containing #{illegal_extensions.join(", ")} files, allowed types: #{@whitelist.inspect}"
      end
    end

    class ArcGISShapefileExaminer < Examiner
      REQUIRED_EXTS = %w(shp shx dbf)
      OPTIONAL_EXTS = %w(aih ain atx avl cpg fbn fbx ixs mxs prj sbn sbx shp.xml shp_rxl).freeze
      ALLOWED_EXTS = REQUIRED_EXTS + OPTIONAL_EXTS
      EXT_MATCHER = /\.(#{ALLOWED_EXTS.map { |e| Regexp.escape(e) }.join('|') })\Z/

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
              reject { |_file, ext| ext.nil? }.
              group_by { |file, ext| file.gsub(/\.#{Regexp.escape(ext)}\Z/, '') }.
              map { |shape, files|
                [shape, files.group_by { |_file, ext| ext }]
              }
          ]
      end

      def has_no_extra_files?
        files_with_extensions.select { |(_f, e)| e.nil? }.empty?
      end

      def each_shape_has_only_one_of_each_allowed_file?
        files_by_shape_and_allowed_extension.all? do |_shape, files|
          files.
            select { |_ext, files| files.size > 1 }.
            empty?
        end
      end

      def each_shape_has_required_files?
        files_by_shape_and_allowed_extension.all? do |_shape, files|
          files.
            select { |ext, _files| REQUIRED_EXTS.include? ext }.
            reject { |_ext, files| files.size > 1 }.
            keys.sort == REQUIRED_EXTS.sort
        end
      end

      def valid?
        has_no_extra_files? &&
          each_shape_has_only_one_of_each_allowed_file? &&
          each_shape_has_required_files?
      end

      def failure_message
        "Your zip file doesn\'t look like an ArcGIS shapefile.  To be an ArcGIS shapefile: It must contain one file of each of these types: #{REQUIRED_EXTS.inspect}. It can contain one file of each of these types: #{OPTIONAL_EXTS.inspect}. It may not contain any other file types, or more than one of any allowed file type."
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
        "The contents of your zip file did not meet any of our constraints: #{@others.map { |o| o.failure_message }.join(' or: ')}"
      end
    end
  end

  def validate_zipfile_contents!(new_file)
    extension = new_file.extension.to_s
    return unless extension == 'zip'

    zip_file = ZipFile.new(new_file.path)
    examiners = [
      ZipFile::UTF8FilenamesExaminer.new(zip_file),
      ZipFile::AnyValidExaminer.new(zip_file, [
        ZipFile::WhitelistedExtensionsExaminer.new(zip_file, extension_whitelist - ['zip']),
        ZipFile::ArcGISShapefileExaminer.new(zip_file)
      ])
    ]
    problem = examiners.detect { |examiner| !examiner.valid? }
    raise CarrierWave::IntegrityError, problem.failure_message if problem
  end

private

  def use_fallback_pdf_thumbnail
    FileUtils.cp(FALLBACK_PDF_THUMBNAIL, path)
  end
end
