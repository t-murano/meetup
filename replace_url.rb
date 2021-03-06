require 'uri'
require 'net/http'

def fetch(url)
  p url
  uri = url.kind_of?(URI) ? url : URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.class == URI::HTTPS
 
  http.head(uri.path) rescue nil
end

def expand(url)
  target_url = url
  loop do
    res = fetch(target_url)
    return target_url if res.to_s.empty?

    case res
    when Net::HTTPRedirection then
      target_url = res["location"]
    else
      return target_url
    end
  end
end

file_name = ARGV[0]

original_contents = File.read(file_name)
urls = URI.extract(original_contents, ["http", "https"]).uniq

expanded_contents = original_contents
urls.each do |original_url|
  expanded_url = expand(original_url)
  expanded_contents = expanded_contents.gsub(original_url, expanded_url)
end

File.write(file_name, expanded_contents)

