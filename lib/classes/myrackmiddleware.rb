class MyRackMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    case @request.path
    when '/guess'
      return @app.call(env) if Codebreaker::GameController.valid_code?(@request.params['guess'])
      data = { status: 'invalid_input', text: 'Invalid entry valid values, digits 1-6' }
      Rack::Response.new(data.to_json, 200, 'Content-Type' => 'application/json')
    else
      @app.call(env)
    end
  end
end
