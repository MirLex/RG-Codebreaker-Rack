require 'Codebreaker_ML'
require 'json'
require 'erb'
require './lib/classes/game.rb'
require './lib/classes/myrackmiddleware'

use Rack::Static, urls: ['/stylesheets' , '/js'], root: 'public'
use Rack::Reloader
use MyRackMiddleware
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'secretKey'
run Game
