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
    o[:changeOrders] = []
	currentChangeOrderDate = nil
	currentChangeOrderNumber = nil
	tmpChangeOrderObj = nil	

    blueDiamondCodes = ["11600", "1160W", "11700", "11800", "1180W", "11900", 
                        "1190W", "12000", "1200W", "13000", "14000", "1400W"]

    reader = PDF::Reader.new(pdfName)

    reader.pages.each{|x| #Iterate over each of the pages in the reader
        x.text.split(/\n/).each{|y| #iterate over each line in the page

        	if y["CHANGE ORDER"]
				if tmpChangeOrderObj.nil? == false && tmpChangeOrderObj.keys.count > 2
					o[:changeOrders] << tmpChangeOrderObj
				end

        		currentChangeOrderDate = y.split("|")[1] #we'll change this later for dates
				currentChangeOrderDate = Date.strptime(currentChangeOrderDate[currentChangeOrderDate.index("Date:")+5...-1].strip,'%m/%d/%Y')

        		currentChangeOrderNumber = y.split("|")[0]
				tmpChangeOrderObj = {}	
		    	tmpChangeOrderObj[:ChangeOrderNumber] = currentChangeOrderNumber
		    	tmpChangeOrderObj[:ChangeOrderDate] = currentChangeOrderDate
		    end

            #Parse the start date to determine sink
            if y["Contract Date"] 
               o[:contractDate] = Date.strptime(y[y.index("Contract Date")+13..-1].split*"", '%m/%d/%Y')
            end

            if y["Set/"] && o[:houseTypeCode].nil?
                o[:houseTypeCode] = y[y.rindex("(")+1..y.rindex("-")-1]
            end
            if y["999QK00"]
                 #We’re definately in a color line
                o[:"ColorCode"] = y.split[5...-2]*" "

                if y["UPDATE"]
                    o[:"UpdatedColor"] = y.split[5...-2]*" "
                    #We’re on a color line *AND* it’s an update
                else
                     #We’re on a color line *AND* it’s *NOT* an update
                     o[:"ColorCode"] = y.split[5...-2]*" "
                end
            end

             	if y["APPLIANCE PKG FREESTANDING"] #If the current line contains "freestanding"
					o[:CooktopCode] = "freestanding"
				end
				if y["4CB"] #If the current line contains "4CB"
					o[:CooktopCode] = "jgp323setss"
				end
				if (y["4CF"]||y["4CH"]||y["4CQ"]) #If the current line contains "4CH,4CF,4CQ"
					o[:CooktopCode] = "pgp976setss"
				end
				if y["4CD"] #If the current line contains "4CD"
					o[:CooktopCode] = "pgp943setss"
				end
				if y["4CP"] #If the current line contains "4CP"
					o[:CooktopCode] = "zgu385nsmss"
				end
				if y["4CG"] #If the current line contains "4CG"
					o[:CooktopCode] = "jgp633setss"
				end


            #Parse the Faucet and Sink fixtures from the doc
            if y["KFK"] then 
                #KFK Fixture Parsing Here
                if o[:contractDate] < Date.strptime('02/02/2017', '%m/%d/%Y') then
                    
                    o[:FaucetSpread] = '8"'
                    o[:KitchenSink] = '11409'
                    
                else
                    #Contract Date on or after 02/02/2017
                    
                    #Default faucet Spread
                    o[:KitchenSink] = '11409'
                    
                end
            end
            if y["KFL"] then
                #KFL Fixture Parsing Here
                if o[:contractDate] < Date.strptime('02/02/2017', '%m/%d/%Y') then
                    
                    o[:FaucetSpread] = 'faucet centered, handle to R, soap to R of handle'
                    o[:KitchenSink] = 'K3821-4'
                    
                elsif o[:contractDate] < Date.strptime('02/14/2017', '%m/%d/%Y') then
                    #Contract Date between 02/02/2017 and 02/14/2017
                    
                    #Default faucet Spread
                    o[:KitchenSink] = 'K3821-4'
                    
                else
                    if blueDiamondCodes.include? o[:houseTypeCode] then
                        
                        #Default faucet Spread
                        o[:KitchenSink] = 'AS342'
                        
                    else
                        
                        #Default faucet Spread
                        o[:KitchenSink] = 'AS333'
                        
                    end
                    
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
	o[:changeOrders] = []
	currentChangeOrderDate = nil
	currentChangeOrderNumber = nil
	tmpChangeOrderObj = nil	

	reader = PDF::Reader.new(pdfName)

	reader.pages.each{|x| #Iterate over each of the pages in the reader
		x.text.split(/\n/).each{|y| #iterate over each line in the page

			if y["CHANGE ORDER"]
				if tmpChangeOrderObj.nil? == false && tmpChangeOrderObj.keys.count > 2
					o[:changeOrders] << tmpChangeOrderObj
				end

        		currentChangeOrderDate = y.split("|")[1] #we'll change this later for dates
				currentChangeOrderDate = Date.strptime(currentChangeOrderDate[currentChangeOrderDate.index("Date:")+5...-1].strip,'%m/%d/%Y')

        		currentChangeOrderNumber = y.split("|")[0]
				tmpChangeOrderObj = {}	
		    	tmpChangeOrderObj[:ChangeOrderNumber] = currentChangeOrderNumber
		    	tmpChangeOrderObj[:ChangeOrderDate] = currentChangeOrderDate
		    end

		    if currentChangeOrderDate.nil? then
		    	if y["KFK"] #If the current line contains "KFK"
					o[:KitchenSink] = "11444"
				end

				if y["KFL"] #If the current line contains "KFL"
					o[:KitchenSink] = "11600"
				end
				if y["999QK00"]
				 	#We’re definately in a color line
					o[:"ColorCode"] = y.split[8..-1]*" "
				end

				if y["APPLIANCE PKG FREESTANDING"] #If the current line contains "freestanding"
					o[:CooktopCode] = "freestanding"
				end
				if y["4CB"] #If the current line contains "4CB"
					o[:CooktopCode] = "jgp329setss"
				end
				if (y["4CC"]|| y["4CF"]) #If the current line contains "4CC,4CF"
					o[:CooktopCode] = "jgp940sekss"
				end
				if y["4CT"] #If the current line contains "4CT"
					o[:CooktopCode] = "pgp953setss"
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
		    else
		    	#we're in change orders
		    	if y["999QK00"]	
					tmpChangeOrderObj[:"ColorCode"] = y.split[5...-2]*" "
				end

				if y["APPLIANCE PKG FREESTANDING"] 
					tmpChangeOrderObj[:CooktopCode] = "freestanding"
				end
		    end
			

		}#x.text.split.each
	}#reader.pages.each
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