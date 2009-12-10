class Module
  
  # Define a method_missing handler that matches given object.
  #
  # Specify either a block to call, or a second argument containing
  # a symbol with the name of method to call.
  #
  # If the match object is a regular expression that contains sub-matches,
  # these matches will be passed to the callback before any passed arguments.
  #
  # Blocks passed to this method may not themselves take a block argument
  # or yield to a block.
  
  def def_when object, *args, &method
    missingno_init
    @missingno_chain << [object, !method.nil? ? method : args[0]]
  end
  
private
  
  # Get the specified method as an UnboundMethod object, or nil if none
  # exists
  
  def missingno_get_old_method method_name
    if method_defined? method_name
      instance_method method_name
    else
      nil
    end
  end
  
  # Initialize the missingno chain and override method_missing and respond_to?
  # methods for class.

  def missingno_init
    return if defined? @missingno_chain
    
    chain = @missingno_chain = []
    is_a_class = is_a? Class

    old_method_missing = missingno_get_old_method :method_missing
    define_method :method_missing do |sym, *args, &block|
      item = chain.find do |item|
        if item[0].respond_to? :include?
          item[0].include? sym.to_s
        else
          item[0] === sym.to_s
        end
      end
      if item
        a = if item[0].is_a? Regexp
          $~.to_a.slice(1..-1) + args
        else
          args
        end
        if item[1].is_a? Symbol
          if m = method(item[1])
            m.call *a, &block
          end
        else
          instance_exec *a, &item[1]
        end
      elsif old_method_missing
        old_method_missing.bind(self).call(sym, *args, &block)
      elsif is_a_class
        super
      end
    end
    
    old_respond_to = missingno_get_old_method :respond_to?
    define_method :respond_to? do |sym, *args|
      if chain.any? { |item| item[0] === sym.to_s }
        true
      elsif old_respond_to
        old_respond_to.bind(self).call(sym, *args)
      elsif is_a_class
        super
      end
    end
  end
end