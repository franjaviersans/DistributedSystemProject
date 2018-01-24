import requests
import queue
import threading
import sys

#global variables for the application
if len(sys.argv) != 4:
	sys.exit("Program should be run with the parameters: INITIAL_URL FILTER_URL MAX_LINKS")

initial_url_f = sys.argv[1]
filter_url = sys.argv[2] #domain to filter pages
max_links = int(sys.argv[3])
all_empty = False
empty = [False, False]


#get a lock for the threads
lock = threading.Lock()

#async queue to store urls to fetch
workQueue = queue.Queue(max_links)

#list of added url, to know if there is any duplicate
dupliSet = set()

#list for visited url
visited = []


class visitedLink():
	def __init__(self, link, status):
		self.link = link
		self.status = status


#fill the queue with the file
print("Initial links to visit:")
with open(initial_url_f) as f:
	for line in f:
		print(line)
		workQueue.put(line)


class myThread (threading.Thread):
	def __init__(self, threadID, name, server_url):
		threading.Thread.__init__(self)
		self.threadID = threadID
		self.name = name
		#selenium server url
		self.server_url = server_url


	def run(self):
		print(str(self.name)+": Starting")
		self.process_data()
		print(str(self.name)+": Exiting")

	def process_data(self):
		global filter_url
		global max_links
		global all_empty
		global empty
		global lock
		global workQueue
		global dupliSet
		global visited


		while max_links != 0 :
			element_fetched = False
			while not element_fetched :
					try:
						#get new url
						url = workQueue.get(True, 2);

						#can get element with this thread
						with lock:
							empty[self.threadID] = False

						element_fetched = True

					except :	
						#can't get element with this thread
						with lock:			
							empty[self.threadID] = True
						#print(str(self.name)+": asdfasdf " +str(empty[self.threadID])+"  "+str(self.threadID))

						#check if every thread is unable to get an element 
						with lock:
							x = True
							for b in empty :
								#print(str(self.name)+": "+str(x)+"  "+str(b))
								x = x and b

						#if everyone is empty, must finish the threads
						if x:
							all_empty = True
						if all_empty :
							print(str(self.name)+": There are no more threads working and no more links to fetch")
							return 

						print(str(self.name)+": Queue empty for the moment")

			print(str(self.name)+": Processing the url: "+str(url))
			
			with lock:
				max_links -= 1

			#send get request server with page as query
			payload = {'page':url}
			r = requests.get(self.server_url, params=payload)


			#mark this link as visited
			visited.append(visitedLink(url, r.status_code))

			#check if the server respond a correct message
			if r.status_code != 200 or r.headers['content-type'] != 'application/json' :
				#if it is not the case, print the error message
				print(str(self.name)+": Problem accessing page with status "+str(r.status_code)+" and response type " +(r.headers['content-type']))
			else:
				#if the server respond correctly, get json a filter responses
				resJson = r.json()
				my_list = [x for x in resJson if (filter_url in x)]

				#add each element to the global queue
				print(str(self.name)+": Placing " +str(len(my_list))+" new links ")
				for e in my_list:
					with lock:
						if e not in dupliSet:
							try:
								dupliSet.add(e)
								workQueue.put_nowait(e)
							except :
								#queue full, but that doesnt matter
								pass
				
			#indicate to the queue that the task with this elment is completed
			workQueue.task_done()
				
		


#class to contain information for every thread
class Register(object):
	def __init__(self, name, server):
		self.name = name
		self.server = server

#information about the threads
reg = [Register('Thread 1', 'http://seleniumserver1/pages'), Register('Thread 2', 'http://seleniumserver2/pages')]
threads = []
threadID = 0

#create new threads
for r in reg:
   thread = myThread(threadID, r.name, r.server)
   threads.append(thread)
   threadID += 1
   thread.start()



#wait for all threads to completed
for t in threads:
   t.join()

print("Finishing program")

print("Visited links stored in log.txt")
with open("log.txt", "w") as f:
	for x in visited :
		f.write("Status: "+str(x.status)+"\n")
		f.write("Link: "+str(x.link))

