#!/usr/bin/env ruby
require 'sequel'

db = Sequel.connect('sqlite://'+File.dirname(__FILE__)+'/../db/gifwall.db')

db.create_table :url do
  primary_key :id
  text :link
  text :gif
end
