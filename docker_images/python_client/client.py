import requests


#initial url to fetch
url = 'https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings'
#domain to filter pages
url_filter = 'github.com'


#send get request server with page as query
payload = {'page':url}
r = requests.get('http://fran/pages', params=payload)


#check if the server respond a correct message
if r.status_code != 200 or r.headers['content-type'] != 'application/json' :
	#if it is not the case, print the error message
	print("Problem accessing page with status "+str(r.status_code)+" and response type " +(r.headers['content-type']))
else:
	#if the server respond correctly, get json a filter responses
	resJson = r.json()
	my_list = [x for x in resJson if not (url_filter in x)]

	#add each element to the global queue
#	for x in my_list :
