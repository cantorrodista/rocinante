require 'rubygems'
require 'xml_magic'
require 'net/http'

['base','errors'].each do |file|
require File.join(File.dirname(__FILE__), 'rocinante', file)
end
