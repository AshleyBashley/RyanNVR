require_relative 'processorCommon'

def generateObjectFromOrder_RYAN(pdfName)
    ryanOrderLambda = -> (line, orderObj) {
        if line["KFK"] #If the current line contains "KFK"
            orderObj[:KitchenSink] = "11444"
        end

        if line["KFL"] #If the current line contains "KFL"
            orderObj[:KitchenSink] = "11600"
        end
        if line["999QK00"]
             #We’re definately in a color line
            orderObj[:ColorCode] = line.split[8..-1]*" "
        end

        if line["APPLIANCE PKG FREESTANDING"] #If the current line contains "freestanding"
            orderObj[:CooktopCode] = "freestanding"
        end
        if line["4CB"] #If the current line contains "4CB"
            orderObj[:CooktopCode] = "jgp329setss"
        end
        if (line["4CC"]|| line["4CF"]) #If the current line contains "4CC,4CF"
            orderObj[:CooktopCode] = "jgp940sekss"
        end
        if line["4CT"] #If the current line contains "4CT"
            orderObj[:CooktopCode] = "pgp953setss"
        end


        if line["FAUCET FIXTURES KITCHEN"]
            if line["UPGRADE"]
                #Faucet Fixtures Kitchen AND Upgrade
                orderObj[:FaucetSpread] = 'faucet centered, handle 4" to R, soap 4" to R of handle' #faucet upgrade
            else
                #Faucet Fixtures Kitchen AND NOT Upgrade
                orderObj[:FaucetSpread] = 'centered' #faucet standard
            end
        end
    }

    ryanChangeOrderLambda = -> (line, orderObj, changedObject) {
        if line["ADD"] then
            changedObject[:Change] = "ADD"
        elsif line["DELETE"] then
            changedObject[:Change] = "DELETE"
        elsif line["UPDATE"]
            changedObject[:Change] = "UPDATE"
        end
        if line["999QK00"]    
            changedObject[:ColorCode] = line.split[5...-2]*" "
        end
        if line["APPLIANCE PKG FREESTANDING"] 
            changedObject[:CooktopCode] = "freestanding"
        end
        if (line["4CC"]|| line["4CF"])
            changedObject[:CooktopCode] = "jgp940sekss"
        end
        if line["4CB"]
            changedObject[:CooktopCode] = "jgp329setss"
        end
        if line["4CT"]
            changedObject[:CooktopCode] = "pgp953setss"
        end
        if line["KFK"]
            changedObject[:KitchenSink] = "11444"
        end
        if line["KFL"]
            changedObject[:KitchenSink] = "11600"
        end
        if line["9FD"]
            changedObject[:FaucetSpread] = "standard"
        end
        if line["9FE"]
            changedObject[:FaucetSpread] = "upgrade"
        end
    }

    generateCommonObjectFromOrder(pdfName, 'Ryan Homes', ryanOrderLambda, ryanChangeOrderLambda)
end