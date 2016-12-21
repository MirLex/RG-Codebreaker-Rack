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
      response_json(status: 'game_started')
    when '/restart'
      @game = @request.session[:game] = nil
    when '/hint'
      response_json(@game.hint)
    when '/guess'
      answer = { result: @game.guess(@request.params['guess']) }
      return response_json(answer) if @game.status.nil?
      answer[:status] = 'game_over'
      answer[:text] = text(@game.status)
      response_json(answer)
    when '/show_history'
      response_json(@game.show_history)
    when '/save_history'
      response_json(@game.save_history(@request.params['name']))
    else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def response_json(data)
    Rack::Response.new(data.to_json, 200, 'Content-Type' => 'application/json')
  end

  def redirect(url)
    Rack::Response.new do |response|
      response.redirect(url)
    end
  end

  def game_rules
    'Rules' # text(:rules)
  end

  # def index
  #   answer = {}
  #   if @game.nil?
  #     answer[:status] = 'new_game'
  #     answer[:text] =   'Rules' #text(:rules)
  #   else
  #     answer[:status] = 'game_started'
  #   end
  #   answer.to_json
  # end

  def text(message)
    Codebreaker::Game::TEXT[message]
  end
end
