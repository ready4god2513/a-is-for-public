require "sinatra"
require "erb"
require "rubygems"
require "twitter"
require_relative 'environment'

before do
  search = Twitter::Search.new

  # Find the 3 most recent marriage proposals to @justinbieber
  @tweets = search.containing("a is for array").result_type("recent").per_page(3)
end

not_found do
  erb :'static/home'
end

get '/' do
  erb :'static/home'
end

get '/help/?' do
  erb :'static/help'
end