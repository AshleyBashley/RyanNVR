require 'pdf-reader' # gem install pdf-reader
require 'date'
#nonfunctional
require 'ap' #gem install awesome_print
require_relative 'pdfProcessorRYAN'
require_relative 'pdfProcessorNV'

########################################################################
########################################################################
#######################  Don't touch above!  ###########################
########################################################################
########################################################################

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

    #     #Generate the parsed order from the PDF and push it onto parsedOrders array.
         parsedOrders << generateObjectFromOrder_NV(x)
     }

    #awesome_print out all of the orders we just processed!
    ap parsedOrders
end    
main        