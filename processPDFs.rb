require 'pdf-reader' # gem install pdf-reader
require 'date'
#nonfunctional
require 'ap' #gem install awesome_print

########################################################################
########################################################################
#######################  Don't touch above!  ###########################
########################################################################
########################################################################

##This method generates an order object from a RYAN home PDF.
def generateObjectFromOrder_RYAN(pdfName)
	o={}
	o[:communityType] = "Ryan Homes"
	o[:fileName] = pdfName

	reader = PDF::Reader.new(pdfName)

	reader.pages.each{|x| #Iterate over each of the pages in the reader
		x.text.split(/\n/).each{|y| #iterate over each line in the page
			#Parse the start date to determine sink
			if y["Start Date"]
				o[:orderDate] = Date.strptime(y[y.index("Start Date")+10..-1], '%m/%d/%Y')
			end

			#Parse the faucet fixtures from the doc
			if y["FAUCET FIXTURES KITCHEN"]
				if y["UPGRADE"]
					o[:FaucetSpread] = 2316584651 #Fauced upgraded
				else
					o[:FaucetSpread] = 9876235 #No faucet upgrade
				end
			end


			#Parse the Kitchen Sink fixtures from the doc
			if y["KITCHEN SINK"] #If the current line contains "KITCHEN SINK"
				if !y["UPGRADE"] #If the current line contains "UPGRADE"
					if o[:orderDate] > Date.strptime('02/02/2017', '%m/%d/%Y') #If the orderDate is after 02/02/2017
						o[:KitchenSink] = "AS342"
					else
						o[:KitchenSink] = "K3821-4"
					end
				else
					o[:KitchenSink] = false
				end
			end
		}
	}
	return o
end

########################################################################
########################################################################
#######################  Don't touch below!  ###########################
########################################################################
########################################################################

##This method generates an order object from an NV home PDF.
def generateObjectFromOrder_NV(pdfName)
	#Not yet implemented.
	return {}
end

def main
	#A place to collect all of the orders
	parsedOrders = []

	#Parse all RYAN pdfs
	Dir.mkdir('PDFs_RYAN') if !File.directory?('PDFs_RYAN')
	Dir['PDFs_RYAN/*.pdf'].each{|x|
		#Generate the parsed order from the PDF and push it onto parsedOrders array.
		parsedOrders << generateObjectFromOrder_RYAN(x)
	}

	# Parse all NV pdfs
	# Dir.mkdir('PDFs_NV') if !File.directory?('PDFs_NV')
	# Dir['PDFs_NV/*.pdf'].each{|x|
	# 	#Generate the parsed order from the PDF and push it onto parsedOrders array.
	# 	parsedOrders << generateObjectFromOrder_NV(x)
	# }

	#awesome_print out all of the orders we just processed!
	ap parsedOrders
end

main
