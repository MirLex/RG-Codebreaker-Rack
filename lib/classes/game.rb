require 'Codebreaker_ML'
require 'json'
require 'erb'

class Game
  def self.call(env)
    new(env).response
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = @request.session[:game]
  end

  def response
    case @request.path
    when '/' then
      Rack::Response.new(render('index.html.erb'))
    when '/start'
      @game = @request.session[:game] = Codebreaker::Game.new
      Rack::Response.new do |response|
        response.redirect('/')
      end
    when '/restart'
      @game = @request.session[:game] = Codebreaker::Game.new
      Rack::Response.new do |response|
        response.redirect('/')
      end
    when '/hint'
      render_response(@game.hint)
    when '/guess'
        answer = {}
        answer['result'] = @game.guess(@request.params['guess'])
        if @game.status.nil?
          render_response(answer)
        else
          answer['game_over'] = @game.status
          render_response(answer)
        end
    else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def render_response(data)
    Rack::Response.new(data.to_json, 200, 'Content-Type' => 'application/json')
  end

  def game
    @game.instance_variable_get('@secret_code')
  end

  def text(message)
    Codebreaker::Game::TEXT[message]
  end
end
