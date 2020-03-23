module DataHygiene
  class AttachmentAttributeUpdater
    def initialize(attachment, dry_run:)
      @attachment = attachment
      @dry_run = dry_run
    end

    def call
      old_number = attachment.command_paper_number
      valid_number = fix_command_paper_number(old_number)

      unless AttachmentValidator.new.command_paper_number_valid?(valid_number)
        raise DataHygiene::AttachmentAttributeNotFixable.new
      end

      return valid_number if dry_run || old_number == valid_number

      attachment.update(command_paper_number: valid_number)
      valid_number
    end

    def self.call(*args)
      new(*args).call
    end

    private_class_method :new

  private

    attr_reader :attachment, :dry_run

    def fix_command_paper_number(original_number)
      # for example, "CM.123-iv "
      original_number.tr(". ", "") # remove periods and spaces: "CM123-iv"
        .sub(/(\d+)/) { |number| ". #{number}" } # inject period & space before number: "CM. 123-iv"
        .capitalize # "Cm. 123-iv"
        .sub(/^Cp\./, "CP") # fix the special case "CP", which should be all caps and no period
        .sub(/\d+-(.+)$/, &:upcase) # make suffix uppercase: "Cm. 123-IV"
    end
  end

  class AttachmentAttributeNotFixable < StandardError; end
end
