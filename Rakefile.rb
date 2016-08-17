require "rubygems"
require "bundler/setup"
require "stringex"
require "date"

## -- Config -- ##

public_dir      = "public"    # compiled site directory
posts_dir       = "_posts"    # directory for blog files
new_post_ext    = "md"  # default new post file extension when using the new_post task
new_page_ext    = "md"  # default new page file extension when using the new_page task


#############################
# Create a new Post or Page #
#############################

# usage rake new_post
desc "Create a new post in #{posts_dir}"
task :new_post, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your post: ")
  end
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end

# Set last month to a past event
cmd = %x[for i in _posts/*.md; do sed -i "" -e 's/category: event/category: past_event/' $i; done]
puts cmd

  date = get_stdin("Event date (fmt:2015-01-26): ")
  year, month, day = date.split("-")
  monthName = Date::MONTHNAMES[month.to_i]
  puts "Creating new post: #{filename}"

  open(filename, 'w') do |post|
    post.puts "---
layout: post
category: event
tags: [MilSec, Event]
sort_time: #{year}#{month}#{day}1800
title: \"#{title.gsub(/&/,'&amp;')}\"
modified: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}
details:
  when: \"#{monthName} #{day}, #{year} at 6:00 PM\"
  where: \"<a href='http://www.saloononcalhoun.com/home.php'>Saloon on Calhoun</a>\"
  what: \"Meetup at a local area pub to just hang out\"
rsvp:
  text: \"RSVP is completely optional, but it can help keep the group at the same table\"
  url: site.owner.email
milsec: true
---
MilSec will be meeting at [Saloon on Calhoun](http://www.saloononcalhoun.com/home.php) at 6:00 PM on #{monthName}, #{day}th (last Thursday of the month) for food and drinks. As always, anyone is welcome.

Although we don't require an RSVP, it helps to provide a headcount to the restaurant the morning of the event. Just [send us an email](mailto:{{ site.owner.email }}) if you plan on being there.
"

  end
end

# usage rake new_page
desc "Create a new page"
task :new_page, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your page: ")
  end
  filename = "#{title.to_url}.#{new_page_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  tags = get_stdin("Enter tags to classify your page (comma separated): ")
  puts "Creating new page: #{filename}"
  open(filename, 'w') do |page|
    page.puts "---"
    page.puts "layout: page"
    page.puts "permalink: /#{title.to_url}/"
    page.puts "title: \"#{title}\""
    page.puts "modified: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    page.puts "tags: [#{tags}]"
    page.puts "image:"
    page.puts "  feature: "
    page.puts "  credit: "
    page.puts "  creditlink: "
    page.puts "share: "
    page.puts "---"
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end
