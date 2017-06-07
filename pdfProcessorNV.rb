require 'date'
require_relative 'processorCommon'
##This method generates an order object from a NV home PDF.
def generateObjectFromOrder_NV(pdfName)
    nvOrderLambda = -> (line, orderObj) {
        begin
            line["Contract Date"] 
            orderObj[:contractDate] = Date.strptime(line[line.index("Contract Date")+13..-1].split*"", '%m/%d/%Y')
        rescue
            contractDate = "FAILED TO PARSE DATE"
        end

        if line["Set/"] && orderObj[:houseTypeCode].nil?
            orderObj[:houseTypeCode] = line[line.rindex("(")+1..line.rindex("-")-1]
        end
        if line["999QK00"]
             #We’re definately in a color line
            orderObj[:"ColorCode"] = line.split[8..-1]*" "
            if line["UPDATE"]
                orderObj[:"UpdatedColor"] = line.split[8..-1]*" "
                #We’re on a color line *AND* it’s an update
            else
                 #We’re on a color line *AND* it’s *NOT* an update
                 orderObj[:"ColorCode"] = line.split[8..-1]*" "
            end
        end

        if line["APPLIANCE PKG FREESTANDING"] #If the current line contains "freestanding"
            orderObj[:CooktopCode] = "freestanding"
        end
        if line["4CB"] #If the current line contains "4CB"
            orderObj[:CooktopCode] = "jgp323setss"
        end
        if (line["4CF"]||line["4CH"]||line["4CQ"]) #If the current line contains "4CF,4CH,4CQ"
            orderObj[:CooktopCode] = "pgp976setss"
        end
        if line["4CD"] #If the current line contains "4CD"
            orderObj[:CooktopCode] = "pgp943setss"
        end
        if line["4CP"] #If the current line contains "4CP"
            orderObj[:CooktopCode] = "zgu385nsmss"
        end
        if line["4CG"] #If the current line contains "4CG"
            orderObj[:CooktopCode] = "jgp633setss"
        end

        #Parse the Faucet and Sink fixtures from the doc
        if line["KFK"] then 
            faucetAndSink = determineFaucetSpreadAndKitchenSink_NV(orderObj[:contractDate], "KFK", orderObj[:houseTypeCode])
            orderObj[:FaucetSpread] = faucetAndSink[:FaucetSpread]
            orderObj[:KitchenSink] = faucetAndSink[:KitchenSink]
        end
        if (line["KFL"]|| line["KFM"]) then
            faucetAndSink = determineFaucetSpreadAndKitchenSink_NV(orderObj[:contractDate], "KFL", orderObj[:houseTypeCode])
            orderObj[:FaucetSpread] = faucetAndSink[:FaucetSpread]
            orderObj[:KitchenSink] = faucetAndSink[:KitchenSink]             
        end
    }


    nvChangeOrderLambda = -> (line, orderObj, changedObject) {
        if line["ADD"] then
            changedObject[:Change] = "ADD"
        elsif line["DELETE"] then
            changedObject[:Change] = "DELETE"
        elsif line["UPDATE"]
            changedObject[:Change] = "UPDATE"
        end
        #we're in change orders
        if line["999QK00"]    
            changedObject[:ColorCode] = line.split[5..-3]*" "
        end
        if line["APPLIANCE PKG FREESTANDING"] 
            changedObject[:CooktopCode] = "freestanding"
        end
        if (line["4CF"]||line["4CH"]||line["4CQ"])
            changedObject[:CooktopCode] = "pgp976setss"
        end
        if line["4CB"]
            changedObject[:CooktopCode] = "jgp333setss"
        end
        if line["4CD"] #If the current line contains "4CD"
            changedObject[:CooktopCode] = "pgp943setss"
        end
        if line["4CP"] #If the current line contains "4CP"
            changedObject[:CooktopCode] = "zgu385nsmss"
        end
        if line["4CG"] #If the current line contains "4CG"
            changedObject[:CooktopCode] = "jgp633setss"
        end
        if line["KFK"]
            changedObject[:KitchenSink] = "11409"
        end
        if (line["KFL"]|| line["KFM"])
            changedObject[:KitchenSink] = "k3821-4"
        end
        
        if line["KFK"] then 
            faucetAndSink = determineFaucetSpreadAndKitchenSink_NV(orderObj[:contractDate], "KFK", orderObj[:houseTypeCode])
            changedObject[:KitchenSink] = faucetAndSink[:KitchenSink]
        end
        if (line["KFL"]|| line["KFM"]) then
            faucetAndSink = determineFaucetSpreadAndKitchenSink_NV(orderObj[:contractDate], "KFL", orderObj[:houseTypeCode])
            changedObject[:KitchenSink] = faucetAndSink[:KitchenSink]             
        end
    }

    generateCommonObjectFromOrder(pdfName, 'NV Homes', nvOrderLambda, nvChangeOrderLambda)
end

def determineFaucetSpreadAndKitchenSink_NV(contractDate, sinkModel, houseTypeCode)

 	blueDiamondCodes = ["11600", "1160W", "11700", "11800", "1180W", "11900", 
                        "1190W", "12000", "1200W", "13000", "14000", "1400W"]

    defaultFaucetSpread = 'faucet centered, soap 8" to R' 
    
    if sinkModel == "KFK" then 
        #KFK Fixture Parsing Here
        if contractDate < Date.strptime('02/02/2017', '%m/%d/%Y') then
            return {
                    :FaucetSpread => '8"',
                    :KitchenSink => '11409'
                }
        else
            #Contract Date on or after 02/02/2017
            #Default faucet Spread
            return {
                    :FaucetSpread => defaultFaucetSpread,
                    :KitchenSink => '11409'
                }
        end
    end
    if sinkModel == "KFL" || sinkModel == "KFM" then
        #KFL Fixture Parsing Here
        if contractDate < Date.strptime('02/02/2017', '%m/%d/%Y') then
            return {
                    :FaucetSpread => 'faucet centered, handle to R, soap to R of handle',
                    :KitchenSink => 'K3821-4'
                }
        elsif contractDate < Date.strptime('02/14/2017', '%m/%d/%Y') then
            #Contract Date between 02/02/2017 and 02/14/2017

            #Default faucet Spread
            return {
                    :FaucetSpread => defaultFaucetSpread,
                    :KitchenSink => 'K3821-4'
                }
        else
            if blueDiamondCodes.include? houseTypeCode then
                #Default faucet Spread
                return {
                    :FaucetSpread => defaultFaucetSpread,
                    :KitchenSink => 'AS342'
                }
            else
                #Default faucet Spread
                return {
                    :FaucetSpread => defaultFaucetSpread,
                    :KitchenSink => 'AS333'
                }
            end
        end

    end
end