require 'sinatra'
require 'selenium-webdriver'
require 'json'

set :bind, '0.0.0.0'

get '/pages' do
	content_type :json

	page = params['page']

	#open driver for a remote firefox selenium
	caps = Selenium::WebDriver::Remote::Capabilities.send("firefox")
	driver = Selenium::WebDriver.for(:remote, url: "http://localhost:4444/wd/hub", desired_capabilities: caps)
	driver.manage.window.size = Selenium::WebDriver::Dimension.new(1920, 1080)

	#open the page
	driver.get page

	#driver.save_screenshot(File.join(Dir.pwd, "ciens.png"))


	output_links = Array.new

	#get all tags
	all_links = driver.find_elements(:tag_name => 'a')

	#traverse all tags
	all_links.each do |link|

	    #retrieve the href of all tags	
	    ref = link.attribute('href')
	    if !ref.nil?
	#       puts "Atttribute :" + ref;
		output_links << ref
	    end 
	end

	driver.quit

	#return JSON to client
	output_links.to_json
end

