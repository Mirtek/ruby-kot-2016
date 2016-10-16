require 'sinatra'
require 'sequel'
require 'aescrypt'
require 'base64'
require 'time'

DB = Sequel.connect(ENV['DATABASE_URL'])
# dev DB = Sequel.sqlite # dev

run if DB.select(:items).nil?
	DB.create_table :items do
		primary_key :id
		String :text
		Integer :count
		Integer :timecreated
		Integer :timetodelete
		Integer :countlimit
		String :fancyid
	end
end

items = DB[:items]

get '/' do
	erb :input_form	
end

post '/' do
	fancyid = SecureRandom.urlsafe_base64
	encoded = AESCrypt.encrypt(params[:secret_message],params[:encode_key])
	items.insert(:text => encoded, :count =>0, :timecreated => Time.now.to_i, :countlimit => params[:count_limit], :timetodelete => params[:timetodelete], :fancyid => fancyid)
	fancyidlink = request.host_with_port+"/messagelink/"+fancyid
	erb :message_link, :locals => {'message_link' => fancyidlink}
end

get '/message/:fancyid' do
	message = items.select(:text)[:fancyid => params[:fancyid]][:text]
	erb :message, :locals => {'message' => message}
end

post '/message/' do
	decoded = AESCrypt.decrypt(params[:message], params[:encode_key])
	linktonewmessage = request.host_with_port
	erb :message_decrypted, :locals => {'message' => decoded, 'url' => linktonewmessage }
end

get '/messagelink/:fancyid' do
	fancyid = params[:fancyid]
	created = items.select(:timecreated)[:fancyid => fancyid][:timecreated]
	
	items.where(:fancyid => fancyid).update(:count=>Sequel[:count]+1)
	
	count = items.select(:count)[:fancyid => fancyid][:count]
	currenttime = Time.now.to_i
	timetodelete = items.select(:timetodelete)[:fancyid => fancyid][:timetodelete]
	if currenttime >= created+timetodelete
		items.where(:fancyid => fancyid).update(:text => "Message deleted - time expired", :timecreated=>0, :count=>-1)
	end	

	if count > items.select(:countlimit)[:fancyid => fancyid][:countlimit]
		items.where(:fancyid => fancyid).update(:text => "Message deleted - linkvisit expired", :timecreated=>0, :count=>-1)
	end
	@message = items.select(:text)[:fancyid => params[:fancyid]][:text]
	# @debugdata = items.select()[:fancyid => params[:fancyid]]
	erb :message, :locals => {'message' => @message}
end