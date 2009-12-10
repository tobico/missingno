require 'missingno'
require 'spec'

#Single class using missingno
class SingleClass
  def_when /^(foo|bar)$/, :test
  def_when ['one', 'two', 'three'] do
    @ok = true
  end
  attr_accessor :ok
end

#Subclass of class using missingno
class SubClass < SingleClass
  def_when /^zap$/, :sub_test
end

#Class with method_missing defined
class MMClass
  def method_missing *args
    "mmclass method_missing"
  end
  
  def_when 'foo', :missingno
end

#Subclass of class with method_missing defined
class MMSubClass < MMClass
  def_when /^zap$/, :sub_test
end

#Mixin module using missingno
module MixinMM
  def_when 'zap', :mm_zap
end

#Class using missingno with mixin
class MixedChain
  include MixinMM
  def_when 'foo', :mm_foo
end

describe 'missingno' do
  describe 'with a single class' do
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
    
    it 'should run specified block when matching array element given' do
      subject.ok = false
      subject.one
      subject.ok.should == true
      subject.ok = false
      subject.three
      subject.ok.should == true
    end
  end
  
  describe 'with a subclass of a class also using missingno' do
    subject { SubClass.new }
    
    it 'should respond to matches from superclass' do
      should respond_to(:foo)
      should respond_to(:bar)
    end
    
    it 'should respond to matches from subclass' do
      should respond_to(:zap)
    end
    
    it 'should call the correct methods when a match found' do
      subject.should_receive :test
      subject.foo
      subject.should_receive :sub_test
      subject.zap
    end
  end
  
  describe 'with a class that already has method_missing' do
    subject { MMClass.new }
    
    it 'should call missingno method when I call a matching method' do
      subject.should_receive :missingno
      subject.foo
    end
    
    it 'should call original method_missing when I call a non-matching method' do
      subject.zap.should == "mmclass method_missing"
    end
  end
  
  describe 'through a mixin' do
    subject { MixedChain.new }
    
    it 'should call method matched in class' do
      subject.should_receive :mm_foo
      subject.foo
    end
    
    it 'should call method matched in mixin' do
      subject.should_receive :mm_zap
      subject.zap
    end
  end
end