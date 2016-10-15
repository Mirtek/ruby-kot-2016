require 'sinatra'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :items do
	primary_key :id
	String :text
	Integer :count
	Integer :timecreated
  # String :fancyid
end

items = DB[:items]

items.insert(:text => 'Hello world', :count => 0, :timecreated => 0)
items.insert(:text => 'Top kek', :count => 0, :timecreated => 0)


get '/' do
	erb :input_form	
end

post '/' do
	items.insert(:text => params[:secret_message], :count =>0, :timecreated => 0)
end

get '/message/:id' do
	@message = items.select(:text)[:id => params[:id]][:text]
	erb :message, :locals => {'message' => @message}
end