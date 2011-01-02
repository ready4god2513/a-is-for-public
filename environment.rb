configure :development do |config|
  require "sinatra/reloader"
  config.also_reload "*.rb"
end

configure :production do |config|
  require 'sinatra/cache'
  # NB! you need to set the root of the app first
  set :root, '/sites/brandon/aisforarray.com/current'
  set :public, '/sites/brandon/aisforarray.com/current/public'

  set :cache_enabled, true  # turn it on
end