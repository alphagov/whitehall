# This edition was archived then re-editioned around the time of the 2015 election.
# It's not a workflow we support any more, it may have been manually resurrected so
# delete the draft edition to allow the sync check to compare live to live versions.
edition = Edition.find(483007)
edition.delete_all_attachments
edition.destroy
