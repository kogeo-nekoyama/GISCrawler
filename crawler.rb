require "rubygems"
require "watir-webdriver"
require "nokogiri"
require "readline"

browser = Watir::Browser::new :ff
while 1  do
  inputs = []
  puts "Input keywords.\n"
  while 1 do
    input = Readline.readline
    if input == "q" then
      break
    end
    inputs << input
  end
  `mkdir -p ./dl/#{inputs.join("_")}/`
  browser.goto("https://www.google.co.jp/search?q=#{inputs.join('+')}&tbm=isch")
  html = Nokogiri::HTML(browser.html)
  html.xpath("//div[@class='rg_di rg_el']/a/@href").each do |img|
    /\?imgurl=(.+)&imgrefurl=/ =~ img.to_s
    url = $1
    puts url
    /([^\/]+?)([\?#].*)?$/ =~ url
    filename = $1
    `wget -O ./dl/#{inputs.join("_")}/#{filename} #{url} -q`
  end
end