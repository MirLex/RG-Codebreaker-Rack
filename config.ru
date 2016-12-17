require './lib/classes/game.rb'
require './lib/classes/myrackmiddleware'

use Rack::Static, urls: ['/stylesheets'], root: 'public'
use Rack::Reloader
use MyRackMiddleware
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'secretKey'
run Game
