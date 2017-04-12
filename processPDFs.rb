require 'pdf-reader' # gem install pdf-reader
require 'date'
#nonfunctional
require 'ap' #gem install awesome_print

########################################################################
########################################################################
#######################  Don't touch above!  ###########################
########################################################################
########################################################################

##This method generates an order object from a NV home PDF.
def generateObjectFromOrder_NV(pdfName)
	o={}
	o[:communityType] = "NVHomes"
	o[:fileName] = pdfName

	reader = PDF::Reader.new(pdfName)

	reader.pages.each{|x| #Iterate over each of the pages in the reader
		x.text.split(/\n/).each{|y| #iterate over each line in the page
			
			#Parse the start date to determine sink
			if y["Start Date"]
				
				o[:orderDate] = Date.strptime(y[y.index("Start Date")+10..-1], '%m/%d/%Y')
			end
			if y["Start Dat"] && o[:orderDate].nil?
				o[:orderDate] = Date.strptime(y[y.index("Start Dat")+9..-1], '%m/%d/%Y')
			end

			#Parse the faucet fixtures from the doc
			if y["FAUCET FIXTURES KITCHEN"]
				if y["UPGRADE"]
					o[:FaucetSpread] = 'faucet centered, soap 8" to R' #Faucet spread 
				else
					o[:FaucetSpread] = 'faucet centered, handle to R, soap to R of handle' #Faucet upgrade
				end
			end


			#Parse the Kitchen Sink fixtures from the doc
			if y["KFK"] #If the current line contains "KFK"
				if !y["KFL"] #If the current line contains "KFL"
					if o[:orderDate] > Date.strptime('02/14/2017', '%m/%d/%Y') #If the orderDate is after 02/14/2017
						
						o[:KitchenSink] = "AS342"
					else
						o[:KitchenSink] = "AS333"

					if o[:KitchenSink] = "11409"
					else
						o[:KitchenSink] = "K3821-4"
					end
					o[:KitchenSink] = false
				end
			end
	end
	return o
}

########################################################################
########################################################################
#######################  Don't touch below!  ###########################
########################################################################
########################################################################

##This method generates an order object from an RYAN home PDF.
def generateObjectFromOrder_NV(pdfName)
	#Not yet implemented.
	return {}
end

def main
	#A place to collect all of the orders
	parsedOrders = []

	#Parse all RYAN pdfs
	Dir.mkdir('PDFs_NV') if !File.directory?('PDFs_NV')
	Dir['PDFs_NV/*.pdf'].each{|x|
		#Generate the parsed order from the PDF and push it onto parsedOrders array.
		parsedOrders << generateObjectFromOrder_NV(x)
	}

	# Parse all NV pdfs
	Dir.mkdir('PDFs_NV') if !File.directory?('PDFs_NV')
	Dir['PDFs_NV/*.pdf'].each{|x|
	# 	#Generate the parsed order from the PDF and push it onto parsedOrders array.
	 	parsedOrders << generateObjectFromOrder_NV(x)
	 }

	#awesome_print out all of the orders we just processed!
	ap parsedOrders
end
	}
main
end