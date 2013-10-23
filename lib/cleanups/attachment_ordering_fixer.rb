class AttachmentOrderingFixer

  attr_reader :logger

  class OldAttachment < Attachment; end
  OldAttachment.table_name = :old_attachments

  def initialize(options = {})
    @logger = options[:logger] || Logger.new(nil)
  end

  def self.run!(options = {})
    AttachmentOrderingFixer.new(options).run!
  end

  def run!
    Document.find_each do |doc|
      unless doc.latest_edition.try(:allows_attachments?)
        logger.info "Skipping #{doc.id} because it does not allow attachments"
        next
      end
      if manually_ordered_edition = manually_ordered?(doc)
        logger.info "Skipping #{doc.id} because #{manually_ordered_edition.id} was manually ordered"
        next
      end

      fix(doc)
    end
  end

  def fix(doc)
    last_known_good_edition = nil
    doc.editions.order(:id).each do |edition|
      if created_before_polymorphic_attachments_code_deployed?(edition)
        logger.info "#{edition.class}##{edition.id} - created before #{polymorphic_attachments_code_deployed_at}, using attachment IDs"
        fix_ordering_using_attachment_ids(edition)
        last_known_good_edition = edition
      elsif was_first_edition_after_polymorphic_attachments_code_deployed?(doc, edition) && created_before_timestamp_ordering_fix?(edition)
        logger.info "#{edition.class}##{edition.id} - first edition after #{polymorphic_attachments_code_deployed_at}, using attachment IDs"
        fix_ordering_using_attachment_ids(edition)
        last_known_good_edition = edition
      elsif last_known_good_edition.nil?
        logger.info "Skipping #{edition.class}##{edition.id} because no last known good edition - CHECK INTEGRITY - Major: #{edition.published_major_version} Minor: #{edition.published_minor_version}"
      else
        logger.info "#{edition.class}##{edition.id} - 2+ editions after #{polymorphic_attachments_code_deployed_at}, fixing with last known good edition"
        fix_ordering_using_last_known_good_edition(last_known_good_edition, edition)
      end
    end
  end

  def manually_ordered?(doc)
    seen_manual_ordering_in_logs?(doc) || manually_ordered_before_polymorphic_attachments_code_deployed?(doc)
  end

  def manually_ordered_before_polymorphic_attachments_code_deployed?(doc)
    doc.editions.where('created_at < ?', polymorphic_attachments_code_deployed_at).find do |edition|
      old_attachments = OldAttachment.where(id: edition.attachment_ids)

      old_attachments.order(:ordering).map(&:ordering) == (0...old_attachments.length).to_a
    end
  end

  def seen_manual_ordering_in_logs?(doc)
    doc.editions.find {|e| MANUALLY_ORDERED_EDITION_IDS.include?(e.id)}
  end

  MANUALLY_ORDERED_EDITION_IDS = [
    225885, 231108, 233037, 234186, 234192, 235088, 235091, 235480, 237547,
    238367, 238378, 238479, 238548, 238737, 238800, 238803, 238806, 238807,
    238809, 238814, 238875, 242589, 242594, 243019, 243026, 243064, 243072,
    243078, 243112, 243139, 243191, 243193, 243199, 243242, 243278, 243317,
    243326, 243359, 243370, 243376, 243383, 243384, 243391, 243396, 243400,
    243404, 243424, 243436, 243509, 243514, 243588, 243595, 243601, 243620,
    243662, 243684, 243693, 243708, 243782, 243830, 243853, 243870, 243889,
    243891, 243897, 243906, 243909, 243912, 243957, 244052, 244089, 244112,
    244148, 244158, 244172, 244177, 244240, 244242, 244265, 244267, 244338,
    244361, 244393, 244442, 244445, 244449, 244451, 244476, 244477, 244488,
    244501, 244515, 244529, 244578, 244598, 244607, 244633, 244642, 244654,
    244665, 244681, 244682, 244701, 244722, 244728, 244733, 244747, 244762,
    244779, 244855, 244859, 244898, 244907, 244921, 244944, 244952, 244966,
    244993, 245008, 245019, 245029, 245040, 245046, 245072, 245086, 245091,
    245098, 245105, 245110, 245122, 245133, 245198, 245228, 245250, 245253,
    245292, 245308, 245313, 245331, 245333, 245344, 245370, 245379, 245388,
    245390, 245393, 245400, 245431, 245436, 245444, 245457, 245504, 245594,
    245609, 245633, 245636, 245641, 245672, 245717, 245726, 245732, 245737,
    245740, 245757, 245772, 245773, 245789, 245799, 245802, 245804, 245817,
    245895, 245926, 245934, 245937, 245955, 246011, 246080, 246082, 246304,
    247952, 247960, 247968, 247994, 248013, 248078, 248156, 248160, 248177,
    248186, 248246, 248260, 248264, 248279, 248372, 248374, 248431, 248439,
    248446, 248456, 248460, 248464, 248475, 248529, 248536, 248557, 248575,
    248582, 248590, 248606, 248612, 248634, 248643, 248645, 248647, 248654,
    248660, 248671, 248679, 248694, 248707, 248734, 248736, 248748, 248752,
    248766, 248801, 248883, 248911, 248931, 248946, 248975, 248994, 249029,
    249030, 249153, 249187, 249191, 249199, 249303, 249347, 249359, 249380,
    249381, 249450, 249462, 249483, 249497, 249517, 249526, 249544, 249559,
    249654, 249701, 249794, 249798, 249799, 249800, 249808, 249815, 249820,
    249838, 249839, 249847, 249851, 249881, 249882, 249886, 249892, 249894,
    249902, 249948, 250010, 250013, 250014, 250018, 250026, 250053, 250088,
    250104, 250106, 250348, 250748, 250885, 251028, 251032, 251039, 251093,
    251094, 251098, 251137, 251150, 251161, 251171, 251174, 251199, 251211,
    251223, 251227, 251244, 251265, 251271, 251337, 251355, 251361, 251363,
    251364, 251419, 251422, 252600, 252662, 252939, 252945, 253037, 253038,
    253043, 253050, 253059, 253067, 253073, 253114, 253120, 253142, 253146,
    253148, 253164, 253176, 253185, 253237, 253247, 253258, 253259, 253273,
    253288, 253294, 253309, 253322, 253361, 253436, 253459, 253462, 253506,
    253537, 253577, 253590, 253594, 253603, 253637, 253641, 253683, 253696,
    253713, 253714, 253725, 253726, 253746, 253757, 253760, 253766, 253798,
    253805, 253806, 253807, 253838, 253844, 253850, 253852, 253853
  ]

  def created_before_polymorphic_attachments_code_deployed?(edition)
    edition.created_at < polymorphic_attachments_code_deployed_at
  end

  def polymorphic_attachments_code_deployed_at
    Time.zone.parse("2013-10-07 10:14:05 UTC")
  end

  def created_before_timestamp_ordering_fix?(edition)
    edition.created_at < timestamp_fix_ran_at
  end

  def timestamp_fix_ran_at
    Time.zone.parse("2013-10-11 12:59:31 UTC")
  end

  def was_first_edition_after_polymorphic_attachments_code_deployed?(doc, edition)
    first_edition_after_polymorphic_attachments_code_deployed(doc) == edition
  end

  def first_edition_after_polymorphic_attachments_code_deployed(doc)
    doc.editions.order(:id).find {|e| e.created_at > polymorphic_attachments_code_deployed_at }
  end

  def fix_ordering_using_attachment_ids(edition)
    resorted_attachments = edition.attachments.sort_by(&:id)
    nil_attachments, old_attachments = OldAttachment.where(id: edition.attachment_ids).partition(&:nil?)

    resorted_attachments.each_with_index do |attachment, index|
      old_attachment = old_attachments.detect { |o| o.id == attachment.id }
      logger.info "-- #{attachment.id} #{old_attachment.try(:ordering)}->#{attachment.ordering}->#{index}"
      attachment.update_column(:ordering, index)
    end
  end

  def fix_ordering_using_last_known_good_edition(last_known_good_edition, edition)
    old_attachments_by_attachment_data_id = last_known_good_edition.attachments.includes(:attachment_data).each_with_object({}) do |a, hash|
      hash[a.attachment_data_id] = a
      hash[a.attachment_data.replaced_by_id] = a if a.attachment_data.replaced_by_id
    end

    new_attachments_to_put_at_the_end = []
    highest_seen_ordering = nil
    edition.attachments.each do |attachment|
      matching_attachment_from_previous_edition = old_attachments_by_attachment_data_id[attachment.attachment_data_id]

      if matching_attachment_from_previous_edition
        logger.info "-- #{attachment.id} #{matching_attachment_from_previous_edition.ordering}->#{attachment.ordering}->#{matching_attachment_from_previous_edition.ordering}"
        attachment.update_column(:ordering, matching_attachment_from_previous_edition.ordering)
        highest_seen_ordering ||= matching_attachment_from_previous_edition.ordering
        highest_seen_ordering = [highest_seen_ordering, matching_attachment_from_previous_edition.ordering].max
      else
        new_attachments_to_put_at_the_end << attachment
      end
    end

    highest_seen_ordering ||= 0
    new_attachments_to_put_at_the_end.each.with_index do |attachment, i|
      new_ordering = highest_seen_ordering + i + 1
      logger.info "-- #{attachment.id} NEW->#{attachment.ordering}->#{new_ordering}"
      attachment.update_column(:ordering, new_ordering)
    end
  end
end
