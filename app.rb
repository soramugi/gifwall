#!/usr/bin/env ruby
# encoding = utf-8
require 'sinatra'
require 'sequel'

configure do
  DB = Sequel.connect('sqlite://db/gifwall.db')
end

get '/' do
  @puts = DB[:url].reverse_order(:id).limit(15)
  haml :index
end
