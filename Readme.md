Missingno - automated method_missing generator
==============================================

Automated `method_missing` and `respond_to?` generator.

Features
--------

  * Add convenience methods for your classes defined by a regular expression, or by any other construct that responds to === or include?
  * Create both `method_missing` and `respond_to?` methods without repeating yourself
  * Add convenience methods even when extending classes that already have `method_missing` defined.
  * Add convenience methods to Mixins

Example
-------

    require 'missingno'
    
    class Model
      def find(field, value)
        #do stuff
      end
      def_when /^find_by_(.+)$/, :find
      #i.e. find_by_state 'VIC'
      
      def_when ['update', 'refresh', 'load'] do
        #do stuff
      end
    end