require "open-uri"
require "json"


raw_data = open("http://www.maxmind.com/app/iso3166_2").read
res = {}

# AD,02,"Canillo"
raw_data.split("\n").each do |line|
  row = line.gsub(/\"/, "").split(",")

  country_code = row[0]
  region_code  = row[1]
  region_name  = row[2]

  region_code2 = -1;

  # next if country_code != "AD"

  if region_code =~ /^\d{2}$/
    region_code2 = (region_code[0].ord - 48) * 10 + (region_code[1].ord - 48)
  elsif region_code =~ /^[A-Z0-9]{2}$/
    region_code2 = ((region_code[0].ord - 48) * (65 + 26 - 48)) + (region_code[1].ord - 48 + 100)
  else
    raise "Region code seems wrong #{region_code}";
  end

  res[country_code] = {} unless res.has_key?(country_code)
  res[country_code][region_code2] = region_name
end

region_name_js = File.open(File.join(File.dirname(__FILE__), "/../lib/region_name_data.js"), "w")
region_name_js.write %Q{
// Do not modify this file, it was generated by
// ./tools/gen_time_zone.rb
module.exports = #{JSON.pretty_generate(res)};
}
# module.exports = #{res.to_json};
region_name_js.close

puts "Done"