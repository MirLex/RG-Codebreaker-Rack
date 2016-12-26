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
    when '/' then index
    when '/start' then start
    when '/restart' then restart
    when '/hint' then hint
    when '/guess' then guess
    when '/show_history' then show_history
    when '/save_history' then save_history
    else Rack::Response.new('Not Found', 404)
    end
  end

  def index
    Rack::Response.new(render('index.html.erb'))
  end

  def start
    @game = @request.session[:game] = Codebreaker::Game.new
    response_json(status: 'game_started')
  end

  def restart
    @game = @request.session[:game] = nil
  end

  def hint
    response_json(@game.hint)
  end

  def show_history
    results = Array[]
    results = YAML.load_stream(open('history.yaml'))
    response_json(results)
  end

  def save_history
    data = ['date' => Time.now.strftime('%d-%m-%Y-%H-%M'),
            'status' => @game.status,
            'user' => @request.params['name'],
            'attempts' => @game.number_of_turns]
    File.open('history.yaml', 'ab') { |f| f.write(data.to_yaml) }
    response_json('saved')
  end

  def mark_guess(guess)
    '+' * guess.first + '-' * guess.last
  end

  def guess
    answer = { result: mark_guess(@game.guess(@request.params['guess'])), turns: @game.number_of_turns }
    return response_json(answer) if @game.status.nil?
    answer[:status] = 'game_over'
    answer[:text] = text(@game.status)
    answer[:history] = @game.show_history
    response_json(answer)
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
    text(:rules)
  end

  def text(message)
    Codebreaker::Game::TEXT[message.to_s]
  end
end
