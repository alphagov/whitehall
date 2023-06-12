module DiagramGenerator
  class DocumentObjectDiagram
    def initialize(document_id = nil)
      @document = document_id ? Document.unscoped.find(document_id) : Document.unscoped.last
      # avoid duplicates
      @emitted_objects = []
      @emitted_links = []
    end

    def draw
      # suppress sql
      old_log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = Logger::INFO

      puts "-" * 60

      puts "@startuml"
      puts "node Whitehall {"
      emit_object(@document, %i[slug document_type content_id latest_edition_id live_edition_id])

      Edition.unscoped.where(document_id: @document.id).each do |edition|
        dump_edition(@document, edition)
      end

      # data objects are outside editions (and link back to editions)
      Edition.unscoped.where(document_id: @document.id).each do |edition|
        dump_data_objects(edition)
      end

      puts "}"
      puts "@enduml"

      puts "-" * 60

      ActiveRecord::Base.logger.level = old_log_level
    end

    private

    def emit_object(obj, fields)
      key = object_key(obj)
      unless @emitted_objects.include? key
        @emitted_objects << key
        puts "object \"#{object_name(obj)}\" as #{object_key(obj)} {"
        fields.each do |f|
          if obj[f].is_a? Time
            puts "  #{f}: #{obj[f].to_fs(:short)}"
          else
            puts "  #{f}: #{obj[f]}"
          end
        end
        puts "}"
      end
    end

    def emit_link(from, to, link)
      from_key = object_key(from)
      to_key = object_key(to)
      unless @emitted_links.include?([from_key, to_key])
        puts "#{object_key(from)} #{link} #{object_key(to)}"
        @emitted_links << [from_key, to_key]
      end
    end

    def object_key(obj)
      "#{obj.class.name}_#{obj.id}"
    end

    def object_name(obj)
      "#{obj.class.name}:#{obj.id}"
    end

    def dump_edition(document, edition)
      puts "together {"
      emit_object(edition, %i[type state lock_version major_change_published_at first_published_at force_published external_url])

      emit_link(document, edition, "*--")

      if edition.class.included_modules.include? Attachable
        Attachment.unscoped.where(attachable_id: edition.id).each do |attachment|
          dump_attachment(edition, attachment)
        end
      end
      Image.unscoped.where(edition_id: edition.id).each do |image|
        dump_image(edition, image)
      end

      if (unpub = Unpublishing.unscoped.where(edition_id: edition.id).first)
        emit_object(unpub, %i[unpublishing_reason_id document_type slug redirect content_id unpublished_at])
        emit_link(edition, unpub, "*-")
      end
      puts "}"
    end

    def dump_data_objects(edition)
      if edition.class.included_modules.include? Attachable
        Attachment.unscoped.where(attachable_id: edition.id).each do |attachment|
          dump_attachment_data_objects(attachment)
        end
      end
      Image.unscoped.where(edition_id: edition.id).each do |image|
        dump_image_data_objects(image)
      end
    end

    def dump_attachment(edition, attachment)
      emit_object(attachment, %i[type title attachment_data_id content_id deleted])
      emit_link(edition, attachment, "*--")
    end

    def dump_attachment_data_objects(attachment)
      attachment_data = AttachmentData.unscoped.find(attachment.attachment_data_id)
      emit_object(attachment_data, %i[carrierwave_file content_type uploaded_to_asset_manager_at present_at_unpublish])
      emit_link(attachment_data, attachment, "*-u-")

      all_attachments = Attachment.unscoped.where(attachment_data_id: attachment_data.id)
      if all_attachments.count > 1
        all_attachments.filter { |a| a.id != attachment.id }.each do |other_attachment|
          other_attachable = Edition.unscoped.find(other_attachment.attachable_id)
          unless @emitted_objects.include? object_key(other_attachment)
            raise "unexpected new attachment: #{object_key(other_attachment)}"
          end

          emit_link(attachment_data, other_attachment, "*-u-")

          unless @emitted_objects.include? object_key(other_attachable)
            raise "unexpected new attachable: #{object_key(other_attachable)}"
          end
        end
      end
    end

    def dump_image(edition, image)
      emit_object(image, %i[alt_text caption])
      emit_link(edition, image, "*--")
    end

    def dump_image_data_objects(image)
      image_data = ImageData.unscoped.find(image.image_data_id)
      emit_object(image_data, %i[carrierwave_image])
      emit_link(image_data, image, "*-u-")
      all_images = Image.unscoped.where(image_data_id: image_data.id)
      if all_images.count > 1
        all_images.filter { |i| i.id != image.id }.each do |other_image|
          unless @emitted_objects.include? object_key(other_image)
            raise "unexpected new image #{object_key(other_image)}"
          end

          other_edition = Edition.unscoped.find(other_image.edition_id)
          unless @emitted_objects.include? object_key(other_edition)
            raise "unexpected new edition #{object_key(other_edition)}"
          end
        end
      end
    end
  end
end
