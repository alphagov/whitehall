#Unpublishing was allowing alternative_url with trailing whitespace. This will
#clean the data by causing it to be stripped
Unpublishing.all.map(&:save)
