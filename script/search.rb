#!/usr/bin/env ruby
# encoding = utf-8
require 'net/http'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'twitter'
require 'sequel'
require 'pit'

SEARCH_LIMIT = 15

def expand_url(url)
  uri = url.kind_of?(URI) ? url : URI.parse(url)
  Net::HTTP.start(uri.host, uri.port) { |io|
    r = io.head(uri.path)
    r['Location'] || uri.to_s
  }
end

def gif_url(url)
  response = open url
  doc = Nokogiri::HTML.parse response.read
  doc.css('.gif-box figure img').first.attribute('src').value
end

def gifboom_url(tweet)
  expand_url(tweet.text.scan(/http:\/\/\S+/).first)
end

def twitter_search
  pit = Pit.get('twitter')
  Twitter.configure do |c|
    c.consumer_key       = pit[:consumer_key]
    c.consumer_secret    = pit[:consumer_secret]
    c.oauth_token        = pit[:token]
    c.oauth_token_secret = pit[:secret]
  end

  search_hash = {:lang => 'ja', :count => SEARCH_LIMIT}
  Twitter.search('#gifboom -RT', search_hash).results.map do |tweet|
    link = gifboom_url(tweet)
    {:link => link, :gif => gif_url(link)}
  end
end

def get_gifs
  gifs = twitter_search.reverse
  db = Sequel.connect('sqlite://'+File.dirname(__FILE__)+'/../db/gifwall.db')
  gifs.each do |gif|
    if db[:url].filter(:link => gif[:link]).first == nil && gif[:gif] != nil
      db[:url].insert(:link => gif[:link], :gif => gif[:gif])
    end
  end
end

get_gifs
