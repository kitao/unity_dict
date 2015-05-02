require 'set'
require 'open-uri'

BASE_URL = 'http://docs.unity3d.com/ScriptReference/'
FILENAME = 'unity.dict'

def make_dict
  dict = Set.new
  parse_index(dict)
  open(FILENAME, 'w') do |f|
    dict.sort.each { |name| f.puts(name) }
  end
end

def parse_index(dict)
  file = download_file(File.join(BASE_URL, 'docdata/toc.js'))
  classes = file.scan(/"link":"(.*?)","title":"(.*?)"/m)

  classes.each do |item|
    link, name = item[0], item[1]
    if link != 'null' && link != 'toc'
      dict.add(name)
      parse_class(dict, "#{BASE_URL}#{link}.html")
    end
  end
end

def parse_class(dict, url)
  file = download_file(url)
  methods = file.scan(/class="lbl"><a href=.*?>(.*?)<\/a>/m)

  methods.flatten.each do |name|
    dict.add(name) unless name.start_with?('operator')
  end
end

def download_file(url)
  puts "download: #{url}"
  open(url) { |data| data.read }
end

make_dict
