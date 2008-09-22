$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Netnumber
  
  NNID_TO_CARRIER_ID = { "100313" => 1, "100321" => 2, "100335" => 5, "100343" => 3}
  WIRELESS_NNIDS = NNID_TO_CARRIER_ID.keys
  
  attr_reader :nnid, :response
  
  def initialize(mobile_phone)
    @mobile_phone = mobile_phone
    @response = query_netnumber_service(@mobile_phone)
  end
  
  def self.resolve(mobile_phone)
    new(mobile_phone)
  end
  
  def carrier_id
    @nnid and NNID_TO_CARRIER_ID[@nnid]
  end
  
  # used to query the NetNumber service edges, will put in here for now, but maybe there is a better place for it?
  # returns an answer if the query was successful
  # otherwise, returns a specific code to denote what type of error occurred 
  def query_netnumber_service(mobile_phone)
    # FIXME the services array probably shouldn't be here
    services = ["65.214.42.88", "65.216.77.208"]
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
  	    response = resolver.query(mobile_phone,'ANY')
  	    @nnid = decode_nnid_from_answer(response)
  	    break
  	  rescue Dnsruby::NXDomain
  	    @response = 0
  	    break
  	  rescue Dnsruby::ResolvError
  	    @response = -1
  	  rescue Dnsruby::ResolvTimeout
  	    @response = -1
  	  end
	    
	    if current_index == services.size - 1
	      current_index = 0
	    else
	      current_index += 1
	    end  
    end # end for-looping thru services array
    resolver.close
    return @response   	  
  end
  
  # checks if this company is one of the wireless carriers
  def is_wireless?
    WIRELESS_NNIDS.include? nnid
  end
  
  private
    # not sure if this is really needed, maybe put in query_netnumber_service
    def decode_nnid_from_answer(response)
      nnid = ""; response.each_answer {|answer| nnid << answer.rdata_to_string}
      readable_nnid = ""
      for j in 8..nnid.length
        readable_nnid << nnid[j,1] if j % 2 == 0
      end
      return readable_nnid
    end
end