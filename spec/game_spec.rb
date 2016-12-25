require 'spec_helper'
require "rack/test"

feature Game do
  scenario 'Open Main Page' do
    visit '/'
    expect(page).to have_content('Rules')
  end

  # scenario 'Show Game Page' do
  #   visit '/'
  #   page.find("#start_game_btn").click
  #   expect(page).to have_content('Guess')
  # end

  # scenario 'Return code 200 when path in known' do
  #   visit '/start'
  #   expect(status_code).to be(200)
  # end  

  scenario 'Return code 404 when path in unknown' do
    visit '/unknown'
    expect(status_code).to be(404)
  end

  # scenario 'Return error when invalid input' do
  #   visit '/guess?guess=FAIL'
  #   expect(page).to match(/invalid_input/)
  # end  

  # scenario 'Return result when input is correct' do
  #   visit '/guess?guess=1234'
  #   expect(page).to match(/result/)
  # end  

  # scenario 'Return error when invalid input' do
  #   visit '/restart'
  #   expect(status_code).to be(200)
  #   expect(page).to have_content('Rules')
  # end  

  # scenario '#hint' do
  #   visit '/hint'
  #   expect(status_code).to be(200)
  #   expect(page).to match(/[1-6]/)
  # end  

  # scenario '#show_history' do
  #   visit '/show_history'
  #   expect(status_code).to be(200)
  #   expect(page).to match(/Secret code was: /)
  # end
end

describe Game do
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def session
    last_request.env['rack.session']
  end

  context 'Return code 404 when path in unknown' do
    let(:response) { post '/unknown' }

    it 'Return code 404' do
      expect(response.status).to eql(404)
    end
    it 'body text: Not Found' do
      expect(response.body).to eql('Not Found')
    end
  end

  context 'Open Main Page' do
    let(:response) { post '/' }

    it 'Return code 200' do
      expect(response.status).to eql(200)
    end
    it 'body text: Start Game' do
      expect(response.body).to match(/Start Game/)
    end
  end  

  # context 'Start Game' do
  #   let(:response) { post '/start' }

  #   it 'Return code 200' do
  #     expect(response.status).to eql(200)
  #   end
  #   it 'body text: Guess' do
  #     expect(response.body).to match(/Guess/)
  #   end
  # end
end