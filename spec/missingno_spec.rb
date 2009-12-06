require 'missingno'
require 'spec'

class SingleClass
  def_when /^(foo|bar)$/, :test
end

describe 'missingno' do
  describe SingleClass, 'with a single class' do
    subject { SingleClass.new }
    
    it 'should respond to symbols matching given regexp' do
      should respond_to(:foo)
      should respond_to(:bar)
      should_not respond_to(:zap)
    end
    
    it 'should call nominated method when I call a matching (missing) method' do
      subject.should_receive(:test)
      subject.foo
    end
    
    it 'should receive the submatch as an argument to #test' do
      subject.should_receive(:test).with('foo')
      subject.foo
    end
    
  end
end