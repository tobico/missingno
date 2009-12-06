class Module
  def def_when regexp, *args, &method
    missingno_init
    @missingno_chain << [regexp, !method.nil? ? method : args[0]]
  end
  
  private
  
  def missingno_get_old_method method_name
    if method_defined? method_name
      instance_method method_name
    else
      nil
    end
  end
  
  def missingno_init
    return if defined? @missingno_chain
    chain = @missingno_chain = []

    old_method_missing = missingno_get_old_method :method_missing
    define_method :method_missing do |sym, *args, &block|
      if item = chain.find { |item| item[0] === sym.to_s }
        a = $~.to_a.slice(1..-1) + args
        if item[1].instance_of?(Symbol)
          if m = method(item[1])
            m.call *a, &block
          end
        else
          instance_exec *a, &item[1]
        end
      elsif old_method_missing
        old_method_missing.bind(self).call(sym, *args, &block)
      else
        super
      end
    end
    
    old_respond_to = missingno_get_old_method :respond_to?
    define_method :respond_to? do |sym, *args|
      if chain.any? { |item| item[0] === sym.to_s }
        true
      elsif old_respond_to
        old_respond_to.bind(self).call(sym, *args)
      else
        super
      end
    end
  end
end