require 'sinatra'
require "selenium-webdriver"

get '/' do
	'Put this in your pipe & smoke it!'

end

get '/sele' do
	
	driver = Selenium::WebDriver.for :chrome
	driver.navigate.to "http://google.com"

	element = driver.find_element(name: 'q')
	element.send_keys "Hello WebDriver!"
	element.submit

	puts driver.title

	driver.quit
end
