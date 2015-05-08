require "rubygems"
require "watir-webdriver"
require "nokogiri"
require "uri"
require "open-uri"
require "csv"

browser = Watir::Browser::new :firefox

CSV.read("keywords.txt").each do |keywords|
  puts "Search '#{keywords.join(' ')}'"
  `mkdir -p ./dl/#{keywords.join("_")}/`
  browser.goto("https://www.google.co.jp/search?q=#{keywords.join('+')}&tbm=isch")
  html = Nokogiri::HTML(browser.html)
  html.xpath("//div[@class='rg_di rg_el']/a/@href").each do |img|
    /\?imgurl=(.+)&imgrefurl=/ =~ img.to_s
    url = $1
    while 1 do
      begin
        if url == URI.unescape(url) then
          break
        else
          url = URI.unescape(url)
        end
      rescue
        url = $1
        break
      end
    end
    /([^\?]+)(?:\?.+)?/ =~ url
    url = $1
    puts "  #{url}"
    #begin
    #  open(url)
    #rescue OpenURI::HTTPError
    #  next
    #rescue URI::InvalidURIError
    #end
    /([^\/]+?)([\?#].*)?$/ =~ url
    filename = $1
    `wget -4 -O ./dl/#{keywords.join("_")}/#{filename} #{url} -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.52 Safari/537.36" -nc --timeout=5 --tries=3 -q`
    if File.size?("./dl/#{keywords.join("_")}/#{filename}") == 0 then
      `rm "./dl/#{keywords.join("_")}/#{filename}"`
      puts "    Download File is empty."
    end
    puts "    Finished."
  end
end