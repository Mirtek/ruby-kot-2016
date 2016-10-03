require 'sinatra'

get '/hi' do
	"Hello World!"	
end


get '/' do
	erb :index
end