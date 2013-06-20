require 'csv'
require 'fog'
require 'open-uri'

path = "~/tmp/fco_attachments"

def run(cmd)
  `#{cmd}`
end

connection = Fog::Storage.new({
  provider: 'AWS',
  aws_access_key_id: 'XXX',
  aws_secret_access_key: 'XXX'
})

BUCKET_NAME = "fco-temp-attachment-store"

@directory = connection.directories.get(BUCKET_NAME) || connection.directories.create(key: BUCKET_NAME, public: 'true')

def upload_file(file, data)
  begin
    possible_existing_url = "https://fco-temp-attachment-store.s3.amazonaws.com/#{file}"
    open(possible_existing_url) do |f|
      if f.status[0] == '200'
        $stderr.puts "#{file} already on S3"
        return possible_existing_url
      end
    end
  rescue OpenURI::HTTPError
  end
  $stderr.puts "Uploading #{file} to S3"
  @directory.files.create(
    key: file,
    body: data,
    public: true
  ).public_url
end

run("mkdir -p #{path}")
csv = CSV.read("script/FCO_Publications_2.1_v2.csv", headers: true)
puts csv.headers.to_csv
csv.each do |row|
  1.upto(200).each do |index|
    url = row["attachment_#{index}_url"]
    next unless url
    filename = File.basename(url)
    filepath = File.expand_path("#{path}/#{filename}")
    unless File.exists?(filepath)
      unless (run("cd #{path} && curl -O #{url} 2>&1"))
        puts "CANNOT DOWNLOAD #{filename} from #{url}"
      end
    end
    ext = File.extname(url)
    next unless ext.empty?

    file_type = run("cd #{path} && file #{filename}")
    $stderr.puts file_type + " FOR FILE " + filename
    case file_type
    when /PDF/
      newfilepath = filepath + '.pdf'
    when /(ASCII|ISO-8859).*text/
      newfilepath = filepath + '.csv'
    when /Excel/
      newfilepath = filepath + '.xls'
    when /HTML/
      $stderr.puts "#{filename} is HTML - ignoring"
      next
    else
      raise "Can't convert file type: #{file_type}"
    end
    row["attachment_#{index}_url"] = upload_file(File.basename(newfilepath), File.open(filepath))
  end
  puts row.to_csv
end
