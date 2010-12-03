module Rocinante
    class Error < RuntimeError
      attr_accessor :code
    end
    
    
    class Errors
      
      # Method used for raising the appropriate error class for a given error code.
      def self.error_for(code, message)
        raise RuntimeError.new("Unknown error") if (code.nil? || message.nil? || message.empty?)
        e = Rocinante::Error.new("#{code}: #{message}")
        e.code = code
        raise e
      end
    end

end