require 'sinatra'
require 'selenium-webdriver'
require 'json'
require 'mongo'


set :bind, '0.0.0.0'
enable :sessions
url = nil
ready = false
output_links = Array.new
tr = nil
error_message = ''

#connection to database
db_route = ARGV[2]

client = Mongo::Client.new('mongodb://'+db_route+':27017/local')
db = client.database
collection = client[:web_pages]




get '/response' do

	if error_message != nil
		status 550
		error_message
	else
		#if the response is ready, send json
		if ready
			status 200
			content_type :json
			output_links.to_json
		else
			status 200
			content_type :html
			#if it is not ready, send a message
			'Not ready'
		end
	end
end



post '/pages' do
	
	

	if(tr != nil)
		begin
			tr.exit
			driver.quit
		rescue Exception => e
		end
	end

	page = params['page']
	ready = false
	output_links = Array.new
	driver = nil
	error_message = nil
	
	tr = Thread.new{
		begin
			#open driver for a remote firefox selenium
			caps = Selenium::WebDriver::Remote::Capabilities.send("firefox")
			driver = Selenium::WebDriver.for(:remote, url: "http://localhost:4444/wd/hub", desired_capabilities: caps)
			driver.manage.window.size = Selenium::WebDriver::Dimension.new(1920, 1080)

			#open the page
			driver.get page

			#get all tags
			all_links = driver.find_elements(:tag_name => 'a')

			#traverse all tags
			all_links.each do |link|
			    #retrieve the href of all tags	
			    ref = link.attribute('href')
			    if !ref.nil?
					output_links << ref
			    end 
			end


			doc = {pageLink: page, innerHTLM: driver.page_source}
			result = collection.insert_one(doc)

			driver.quit

			ready = true	
		rescue Exception => e
			error_message = 'Exception' + e.message
			driver.quit
		end
	}
end


