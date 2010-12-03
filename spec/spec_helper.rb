require 'rubygems'
gem 'rspec'
require 'spec'
 
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rocinante'

class SpecHelper
  def self.rocinante
    Rocinante.new(:public_key => "", :private_key => "")
  end
end

class Hash
  def strip_api_params!
    delete :public_key
    delete :private_key
  end
end