#!/usr/bin/ruby

require 'erb'

ERB_TEMPLATE = <<EOF
<html>
  <head>
    <title>Installed Fonts (<%= ([modename] + optionname).join(",") %>)</title>
    <style>
      p { margin-left: 40px; }
      section {
        margin-top: 15px;
        border-top: #339 solid 2px;
      }
    </style>
  </head>
  <body>
    <h1>Installed Fonts (<%= ([modename] + optionname).join(",") %>)</h1>
    <% fonts.keys.sort.each do |k| %>
      <section style="font-family: &quot;<%= k %>&quot;;">
        <h2><%= k %> (<%= fonts[k][:fullname] %>)</h2>
        <p>The quick brown fox jumps over the lazy dog</p>
        <% if fonts[k][:monospace] %>
        <p>[monospace] 1lI|/\ 0O 6b 9g -=^~_ .,:; *+ ()[]{}&lt;&gt;</p>
        <% end %>
        <% if fonts[k][:kana] %>
        <p>[kana] いろはにほへと　ちりぬるを </p>
        <% end %>
        <% if fonts[k][:hani] %>
        <p>[hani] 吾輩は猫である。名前は未だ無い。</p>
        <% end %>
      </section>
    <% end %>
  </body>
</html>
EOF

OPTIONS = []
fonts = Hash.new
modename = "All Installed"
optionname = []
outfile = nil

argv = []
ARGV.each do |i|
  if i =~ /^-/
    $'.scan(/(.)/) {|c| argv.push("-" + $1) }
  else
    argv.push i
  end
end

p argv

while arg = argv.shift
  break if arg == "--"
  case arg.strip
  when "-d"
    OPTIONS.push :list_dual
  when "-m"
    OPTIONS.push :list_mono
  when "-j"
    OPTIONS.push :req_kana
    optionname |= ["かな必須"]
  when "-H"
    OPTIONS.push :req_hani
    optionname |= ["漢字必須"]
  when "-o"
    outfile = argv.shift
  when "-h"
    STDERR.puts "Usage:"
    STDERR.puts "  installed-font-list-html.rb [-m|-d] [-H] [-j] [-o outfile]"
  end
end

if outfile
  STDOUT.reopen(File.open(outfile, "w"))
end

STDERR.puts "building list.........."

fontlist = nil

if((OPTIONS & [:list_dual, :list_mono]).length > 1)
  STDERR.puts "-d, -m options are able to turn on only one of them."
  exit 1
end

if OPTIONS.include?(:list_mono)
  modename = "Monospace"
  IO.popen(["fc-list", ":mono", ":", "family", "fullname", "spacing", "capability"], "r") do |io|
    fontlist = io.each.map {|i| i.split(":", 2)}
  end
elsif OPTIONS.include?(:list_dual)
  modename = "Monospace + Dualspace"
  IO.popen(["fc-list", ":dual", ":", "family", "fullname", "spacing", "capability"], "r") do |io|
    fontlist = io.each.to_a
  end
  IO.popen(["fc-list", ":mono", ":", "family", "fullname", "spacing", "capability"], "r") do |io|
    fontlist |= io.each.to_a
  end
  fontlist = fontlist.map {|i| i.split(":", 2)}
else
  IO.popen(["fc-list", ":", "family", "fullname", "spacing", "capability"], "r") do |io|
    fontlist = io.each.map {|i| i.split(":", 2)}
  end
end

fontlist.each do |fl|
  infoline = {fullname: nil, kana: false, hani: false, monospace: false}
  family = fl[0].split(",")
  capability = ""
  fullname = ""


  if fl[1] =~ /\bfullname=(.*?)(?::|$)/
    infoline[:fullname] = $1.gsub('\\', '')
  end

  if fl[1] =~ /\bspacing=(.*?)\b/
    spacing = $1
    unless(spacing == "0" || spacing.casecmp?("proportional"))
      infoline[:monospace] = true
    end
    infoline[:spacing] = spacing
  end

  if fl[1] =~ /\bcapability=(.*)$/
    capability = $1.gsub('\\', '')
  end

  infoline[:kana] = true if capability.include?("otlayout:kana")
  infoline[:hani] = true if capability.include?("otlayout:hani")

  next if OPTIONS.include?(:req_kana) && ! infoline[:kana]
  next if OPTIONS.include?(:req_hani) && ! infoline[:hani]

  family.each do |i|
    fonts[i.gsub('\\', '')] = infoline
  end

  STDERR.puts(infoline[:fullname] || family.first)
end

STDERR.puts "Generating HTML..............."

ERB.new(ERB_TEMPLATE).run(binding)
