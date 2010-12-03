module Rocinante
  def self.new(*params)
    Rocinante::Base.new(*params)
  end
  
  class Base
    attr_reader :public_key, :private_key
    
    # Parámetro key: Hash md5 resultado de concatenar pub con la clave privada
    
    REST_API_ENDPOINT = 'http://api.turismocastillalamancha.com'
    
    # Create a new Rocinante object
    # You must have a YAML file to configure the gem, named 'rocinante.yml'
    # 
    # Example
    # ---
    # public_key: YOUR_PUBLIC_KEY
    # private_key: YOUR_PRIVATE_KEY
    
    # Example config file with two environments:
    # ---
    #   development:
    #     public_key: YOUR_DEVELOPMENT_PUBLIC_KEY
    #     private_key: YOUR_DEVELOPMENT_PRIVATE_KEY
    #   production:
    #     public_key: YOUR_PRODUCTION_PUBLIC_KEY
    #     private_key: YOUR_PRODUCTION_PRIVATE_KEY
    
    def initialize(config_yaml='config/rocinante.yml',config_params = {})
      config = config_params ? config_params : YAML.load_file(config_yaml)
      @api_key = config[:public_key] || config["public_key"]
      @api_secret = config[:private_key] || config["private_key"]
      raise 'config file must contain an publick key and private key' unless @api_key and @api_secret
    end
    
    
    # Send a request to Castilla la Mancha Api
    # 
    # Params
    # * method (Required)
    #     name of the Castilla la Mancha Api method (at this moment only two: search or media)
    # * options (Optional)
    #     hash of query parameters, you do not need to include public key and private key, they are added automatically
    def send_request(method, options = {})
      http_method = :get
      endpoint = REST_API_ENDPOINT
      options.merge!(:api_key => @api_key, :method => method)
      sign_request(options)
      
      rsp = http_request(options, http_method, endpoint)
      
      rsp = '<rsp stat="ok"></rsp>' if rsp == ""
      xm = XmlMagic.new(rsp)
      
      if xm[:stat] == 'ok'
        xm
      else
        raise Rocinante::Errors.error_for(xm.err[:code].to_i, xm.err[:msg])
      end
    end
    
    # alters your api parameters to include your public key and MD5 hash signature from public and private key
    # Params
    # * options (Required)
    #     the hash of parameters to be passed to the send_request
    # 
    def sign_request(options)
      options.merge!(:pub => @api_key)
      options.merge!(:key => Digest::MD5.hexdigest(@api_secret + @api_key))
    end
    
    protected
    
    def http_request(options, http_method, endpoint)
      if http_method == :get
        api_call = endpoint + "?" + options.collect{|k,v| "#{k}=#{CGI.escape(v.to_s)}"}.join('&')
        Net::HTTP.get(URI.parse(api_call))
      end
    end
    
    
    
  end
end