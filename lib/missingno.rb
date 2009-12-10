class Module
  def def_when regexp, *args, &method
    missingno_init
    @missingno_chain << [regexp, !method.nil? ? method : args[0]]
  end
  
  protected
  
  def missingno_merge_chain chain
    missingno_init
    @missingno_chain += chain
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