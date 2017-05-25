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

            if y["CHANGE ORDER"] && y["Date:"] #Does "CHANGE ORDER" occur in the string y
                if tmpChangeOrderObj.nil? == false && tmpChangeOrderObj.keys.count > 2
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
                    o[:ColorCode] = y.split[8..-1]*" "
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
                    tmpChangeOrderObj[:ColorCode] = y.split[5...-2]*" "
                end

                if y["APPLIANCE PKG FREESTANDING"] 
                    tmpChangeOrderObj[:CooktopCode] = "freestanding"
                end
                if (y["4CC"]|| y["4CF"])
                    tmpChangeOrderObj[:CooktopCode] = "jgp940sekss"
                end
                if y["4CB"]
                    tmpChangeOrderObj[:CooktopCode] = "jgp329setss"
                end
                if y["4CT"]
                    tmpChangeOrderObj[:CooktopCode] = "pgp953setss"
                end
                if y["KFK"]
                    tmpChangeOrderObj[:KitchenSink] = "11444"
                end
                if y["KFL"]
                    tmpChangeOrderObj[:KitchenSink] = "11600"
                end
                if y["9FD"]
                    tmpChangeOrderObj[:FaucetSpread] = "standard"
                end
                if y["9FE"]
                    tmpChangeOrderObj[:FaucetSpread] = "upgrade"
                end
            end
            

        }#x.text.split.each
    }#reader.pages.each
    return o
end 