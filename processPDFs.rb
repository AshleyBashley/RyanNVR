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
	o[:communityType] = 'NVHomes'
	o[:fileName] = pdfName
	o[:FaucetSpread] = 'faucet centered, soap 8" to R' #Default faucet spread

	blueDiamondCodes = ["11600", "1160W", "11700", "11800", "1180W", "11900", 
						"1190W", "12000", "1200W", "13000", "14000", "1400W"]

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

			if y["Set/"] && o[:houseTypeCode].nil?
				o[:houseTypeCode] = y[y.rindex("(")+1..y.rindex("-")-1]
			end

			#Parse the Kitchen Sink fixtures from the doc
			if y["KFK"] #If the current line contains "KFK"
				o[:KitchenSink] = "11409"
			end
			if y["KFL"] then
				if o[:orderDate] >= Date.strptime('02/14/2017', '%m/%d/%Y') #If the orderDate is after 02/14/2017
					if blueDiamondCodes.include? o[:houseTypeCode] 
						o[:KitchenSink] = "AS342"
					else
						o[:KitchenSink] = "AS333"
					end
				else
					#Explictly change FaucetSpread on k3821-4 models
					o[:KitchenSink] = "K3821-4"
					o[:FaucetSpread] = 'faucet centered, handle to R, soap to R of handle' #Faucet upgrade
				end
			end
		}
	}
	return o
end

##This method generates an order object from an RYAN home PDF.
def generateObjectFromOrder_RYAN(pdfName)
	o={}
	o[:communityType] = 'RyanHomes'
	o[:fileName] = pdfName

	reader = PDF::Reader.new(pdfName)

	reader.pages.each{|x| #Iterate over each of the pages in the reader
		x.text.split(/\n/).each{|y| #iterate over each line in the page

			if y["KFK"] #If the current line contains "KFK"
				o[:KitchenSink] = "11444"
			end

			if y["KFL"] #If the current line contains "KFL"
				o[:KitchenSink] = "11600"
			end

			if y["FAUCET FIXTURES KITCHEN"]
				if y["UPGRADE"]
					#Faucet Fixtures Kitchen AND Upgrade
					o[:FaucetSpread] = 'faucet centered, handle 4" to R, soap 4" to R of handle' #faucet upgrade
				else
					#Faucet Fixtures Kitchen AND NOT Upgrade
					o[:FaucetSpread] = 'centered' #faucet standard
				end
			end
		}
	}
	return o
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
	Dir.mkdir('PDFs_NV') if !File.directory?('PDFs_NV')
	Dir['PDFs_NV/*.pdf'].each{|x|
	# 	#Generate the parsed order from the PDF and push it onto parsedOrders array.
	 	parsedOrders << generateObjectFromOrder_NV(x)
	 }

	#awesome_print out all of the orders we just processed!
	ap parsedOrders
end	
main		