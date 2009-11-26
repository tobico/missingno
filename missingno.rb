class Module
  def def_when regexp, &method
    missingno_init
    @missingno_chain << [regexp, method]
  end
  
  private
  
  def missingno_init
    return if defined? @missingno_chain
    chain = @missingno_chain = []

    old_method_missing = method :method_missing if method_defined? :method_missing
    define_method :method_missing do |sym, *args, &block|
      if item = chain.find { |item| item[0] === sym.to_s }
        item[1].call *($~.to_a.slice(1..-1) + args), &block
      elsif defined? old_method_missing and old_method_missing.respond_to? :call
        old_method_missing.call sym, *args, &block
      else
        super
      end
    end
    
    old_respond_to = method :respond_to? if method_defined? :respond_to?
    define_method :respond_to? do |sym|
      if chain.any? { |item| item[0] === sym.to_s }
        true
      elsif defined? old_respond_to and old_respond_to.respond_to? :call
        old_respond_to.call sym, *args, &block
      else
        super
      end
    end
  end
end