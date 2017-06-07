require 'date'
@TRIGGER_WORDS = ['999ZZ07']

def generateCommonObjectFromOrder(pdfName, communityType, orderLambda, changeOrderLambda)
    o={}
    o[:communityType] = communityType
    o[:fileName] = pdfName
    o[:changeOrders] = []
    o[:misc] = []
    currentChangeOrderDate = nil
    currentChangeOrderNumber = nil
    tmpChangeOrderObj = nil    

    reader = PDF::Reader.new(pdfName)

    reader.pages.each{|x| #Iterate over each of the pages in the reader
        x.text.split(/\n/).each{|y| #iterate over each line in the page

            if y["MISC #"] || (y["999ZZ"] && tmpChangeOrderObj.nil?)
                if @TRIGGER_WORDS.any?{|trigger|y[trigger]}
                    o[:misc] << "@"*75
                    o[:misc] << y
                    o[:misc] << "@"*75
                else
                    o[:misc] << y
                end
            end

            if y["CHANGE ORDER"] && y["Date:"] #Does "CHANGE ORDER" occur in the string y
                if tmpChangeOrderObj.nil? == false && tmpChangeOrderObj[:Changes].count > 0
                    o[:changeOrders] << tmpChangeOrderObj
                end

                currentChangeOrderDate = y.split("|")[1] #we'll change this later for dates
                begin
                    currentChangeOrderDate = Date.strptime(currentChangeOrderDate[currentChangeOrderDate.index("Date:")+5...-1].strip,'%m/%d/%Y')
                rescue
                    currentChangeOrderDate = "FAILED TO PARSE DATE"
                end

                currentChangeOrderNumber = y.split("|")[0]
                tmpChangeOrderObj = {}    
                tmpChangeOrderObj[:ChangeOrderNumber] = currentChangeOrderNumber
                tmpChangeOrderObj[:ChangeOrderDate] = currentChangeOrderDate
                tmpChangeOrderObj[:Changes] = []
            end

            if currentChangeOrderDate.nil? then
            	#VAZ - WET BAR BASEMENT
            	#VAG - WET BAR FIRST FLOOR
            	#VCG - 
            	if ["VCG","VAZ","VAG","999QW01", "999QW02", "NME", "NNE", "NMX", "NLX"].any?{|wetbar|y.start_with? wetbar}
            		#We've found a wetbar!
            		if o[:wetbars].nil?
            			o[:wetbars] = []
            		end
            		o[:wetbars] << y
            	end
            	orderLambda.call(y, o)
            else
                #we're in change orders
                changedObj = {}

                changeOrderLambda.call(y, o, changedObj)
                if changedObj.keys.count > 1
                    tmpChangeOrderObj[:Changes] << changedObj
                end
            end
        }#x.text.split.each
    }#reader.pages.each
    return o
end 