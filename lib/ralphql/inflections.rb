# frozen_string_literal: true

class Hash
  def to_ralphql
    "{#{map { |key, value| "#{key}:#{value.to_ralphql}" }.join(', ')}}"
  end
end

class Integer
  def to_ralphql
    self
  end
end

class String
  def to_ralphql
    "'#{self}'"
  end
end

class Symbol
  def to_ralphql
    "'#{self}'"
  end
end

class Array
  def to_ralphql
    "[#{map(&:to_ralphql).join(', ')}]"
  end
end
