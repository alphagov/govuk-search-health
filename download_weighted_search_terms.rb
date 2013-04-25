require 'time'
require 'open-uri'

resource_id = "0AmD7K4ab1dYrdDR5c2tITTNHRUZqajFTTU8wODAzZ1E"
# Link generated by going to:
#   File
#     Publish to the web
#       Get a link to the published data
#          then choose CSV
io = open("https://docs.google.com/spreadsheet/pub?key=#{resource_id}&single=true&gid=0&output=csv")

file = File.new("downloaded-weighted-search-terms-#{Time.now.utc.iso8601}.csv", "wb")
file.write(io.read)
file.close

# Create a symlink called "weighted-search-terms.csv" pointing at the file just downloaded
FileUtils.ln_s(File.basename(file), "weighted-search-terms.csv")
