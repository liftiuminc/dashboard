module Liftium
  class AdNetworks

    def AdNetworks.new_from_name (name)
      ### now try to find a class that matches this, walking
      ### up the tree as needed
      try = 'Liftium::AdNetworks::' + self.str_to_class_name( name )
      
      ### do we have this class?
      begin
        ### Kernel.const_get? etc don't do nested classes.
        ### There's not a clear ruby way of doing this that I
        ### found doing extensive google searches. If there's
        ### a better way, then please XXX FIXME -jos
        does_exist = eval( try + '.methods' )
         
        ### eval may fail, catch it here
        rescue NameError
      end

      ### valid class, let's instantiate from it
      if does_exist
            
        return eval try + '.new'

      ### ok, chop off the top level and keep going
      else 
        return Liftium::AdNetworks.new
      end
    end 
    
    def AdNetworks.str_to_class_name (str)
      ### translate "Google Adsense" to "GoogleAdsense" and
      ### "Test (US only)" to "TestUsOnly" so it matches ruby 
      ### class name rules
      return str.split( /\W/ ).map { |w| w.capitalize }.join    
    end
    
  end
end  

module Liftium
  class AdNetworks::AdCom
  end
end  
