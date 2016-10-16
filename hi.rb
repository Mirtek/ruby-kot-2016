require 'sinatra'
require 'sequel'

# prod DB = Sequel.connect(ENV['DATABASE_URL'])
DB = Sequel.sqlite # dev

DB.create_table :items do
	primary_key :id
	String :text
	Integer :count
	Integer :timecreated
    String :fancyid
end

items = DB[:items]

items.insert(:text => 'Hello world', :count => 0, :timecreated => 0, :fancyid => SecureRandom.urlsafe_base64)
items.insert(:text => 'Top kek', :count => 0, :timecreated => 0, :fancyid => "rhewkdfh")


get '/' do
	erb :input_form	
end

post '/' do
	fancyid = SecureRandom.urlsafe_base64
	items.insert(:text => params[:secret_message], :count =>0, :timecreated => 0, :fancyid => fancyid)
	idlink = request.host_with_port+"/messagelink/"+fancyid
	erb :message_link, :locals => {'message_link' => idlink}
end

get '/message/:id' do
	@message = items.select(:text)[:id => params[:id]][:text]
	erb :message, :locals => {'message' => @message}
end


get '/messagelink/:fancyid' do
	@message = items.select(:text)[:fancyid => params[:fancyid]][:text]
	erb :message, :locals => {'message' => @message}
end