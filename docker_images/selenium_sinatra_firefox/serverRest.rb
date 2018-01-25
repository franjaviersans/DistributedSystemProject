require 'sinatra'
require 'selenium-webdriver'
require 'json'


set :bind, '0.0.0.0'
enable :sessions
url = nil
ready = false
output_links = Array.new
tr = nil

get '/response' do
	#if the response is ready, send json
	if ready
		content_type :json
		output_links.to_json
	else
		content_type :html
		#if it is not ready, send a message
		'Not ready'
	end
end



post '/pages' do
	
	page = params['page']
	ready = false
	output_links = Array.new

	if(tr != nil)
		tr.exit
	end

	tr = Thread.new{
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

		driver.quit

		ready = true	
	}
end


