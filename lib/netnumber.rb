require 'dnsruby'
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Netnumber

  # hash of Tapioca Mobile supported wireless carriers, mapping the NNIDs to the carrier IDs
  NNID_TO_CARRIER_ID = { 
    "100313" => 1, # Verizon Wireless
    "100321" => 2, # AT&T Wireless
    "100335" => 5, # T-Mobile USA
    "100343" => 3  # Sprint Spectrum
  }
  
  WIRELESS_NNIDS = NNID_TO_CARRIER_ID.keys
  
  attr_reader :nnid, :response, :error_message
  
  def initialize(mobile_phone)
    @mobile_phone = mobile_phone
    @response = query_netnumber_service(@mobile_phone)
  end
  
  def carrier_id
    @nnid and NNID_TO_CARRIER_ID[@nnid]
  end
  
  # query the NetNumber service
  def query_netnumber_service(mobile_phone)
    services = ["65.214.42.88", "65.216.77.208"]
    #services = ["0.0.0.0", "0.0.0.0"]
    
    # transform the phone number into reverse dot notation format
    mobile_phone = "1" << mobile_phone unless mobile_phone[0,1] == '1'
    mobile_phone.reverse!
    if mobile_phone.length == 11
  	  index = 1
  	  for k in 1..11
  	    mobile_phone.insert(index, '.')
  	    index += 2
  	  end
	  end
  	
  	# randomly pick a spot on the services edge array, then go through the rest of the array if the current service fails
  	current_index = rand(services.size)
	  for i in 1..services.length	      
  	  begin
  	    resolver = Dnsruby::Resolver.new(:nameserver => services[current_index], :query_timeout => 15)
  	    @response = resolver.query(mobile_phone,'ANY')
  	    @nnid = decode_nnid_from_answer(@response)
  	    break
  	  # if the phone number format was incorrect, a NXDomain exception is thrown by dnsruby
  	  rescue Dnsruby::NXDomain
  	    @response = 0
  	    break
  	  # dnsruby is unable to query NetNumber due to a timeout and/or service failure
  	  rescue Dnsruby::ResolvError, Dnsruby::ResolvTimeout
  	    @error_message = "We are unable to determine your carrier at this time. Please select your carrier from the list below."
  	  end
	    
	    if current_index == services.size - 1
	      current_index = 0
	    else
	      current_index += 1
	    end  
    end # end looping thru services array
    
    resolver.close
    return @response   	  
  end
  
  # checks if this company is one of the wireless carriers
  def valid?
    WIRELESS_NNIDS.include? nnid
  end
  
  private
    # once a valid response is received from NetNumber, we need to pull just the six digit NNID from the response
    def decode_nnid_from_answer(response)
      nnid = ""
      response.each_answer {|answer| nnid = answer.rdata_to_string}
      readable_nnid = ""
      for j in 8..nnid.length
        readable_nnid << nnid[j,1] if j % 2 == 0
      end
      return readable_nnid
    end
end