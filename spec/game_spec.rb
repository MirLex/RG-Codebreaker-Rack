require 'spec_helper'
require 'rack/test'

feature Game do
  scenario 'Open Main Page' do
    visit '/'
    expect(page).to have_content('RULES')
  end

  scenario 'Return code 200 when path in known' do
    visit '/start'
    expect(status_code).to be(200)
  end

  scenario 'Return code 404 when path in unknown' do
    visit '/unknown'
    expect(status_code).to be(404)
  end

  scenario 'Return error when invalid Guess input' do
    visit '/guess?guess=FAIL'
    expect(page).to have_content(/invalid_input/)
  end

  scenario 'Return result when Guess input is correct' do
    visit '/start'
    visit '/guess?guess=1234'
    expect(page).to have_content(/result/)
  end

  scenario 'Game over when attempts have ended' do
    visit '/start'
    15.times { visit '/guess?guess=1111' }
    expect(page).to have_content(/\"status\":\"game_over\"/)
  end

  scenario 'Show game progress when game ended' do
    visit '/start'
    15.times { visit '/guess?guess=1111' }
    expect(page).to have_content(/Secret code was: /)
  end

  scenario 'Save game process' do
    visit '/start'
    15.times { visit '/guess?guess=1111' }
    visit '/save_history?name=TEST'
    expect(page).to have_content(/\"saved\"/)
  end

  scenario 'Show games history' do
    visit '/start'
    15.times { visit '/guess?guess=1111' }
    visit '/save_history?name=TEST_NAME'
    visit '/show_history'
    expect(page).to have_content(/\"TEST_NAME\"/)
  end
end

describe Game do
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def session
    last_request.env['rack.session']
  end

  context 'Return code 404 when path in unknown', skip: false do
    let(:response) { post '/unknown' }

    it 'Return code 404' do
      expect(response.status).to eql(404)
    end
    it 'body text: Not Found' do
      expect(response.body).to eql('Not Found')
    end
  end

  context 'Open Main Page', skip: false do
    let(:response) { post '/' }

    it 'Return code 200' do
      expect(response.status).to eql(200)
    end
    it 'body text: Start Game' do
      expect(response.body).to match(/Start Game/)
    end
  end

  context 'Start Game', skip: false do
    let(:response) { post '/start' }

    it 'Return code 200' do
      expect(response.status).to eql(200)
    end
    it 'body text: Guess' do
      expect(response.body).to match(/status\":\"game_started/)
    end
  end

  context 'Show Hint', skip: false do
    let(:response) { post '/hint' }
    let(:start) { post '/start' }
    it 'body text: Guess' do
      start
      expect(response.body).to match(/[1-6]/)
    end
  end

  context 'Return result when input is correct', skip: false do
    let(:response) { post '/guess?guess=1111' }
    let(:start) { post '/start' }
    it 'body text: Guess' do
      start
      expect(response.body).to match(/"result\":/)
    end
  end

  context 'Return error when invalid input', skip: false do
    let(:response) { post '/guess?guess=invalid_input' }
    let(:start) { post '/start' }
    it 'body text: Guess' do
      start
      expect(response.body).to match(/invalid_input/)
    end
  end
end
