# frozen_string_literal: true

require 'ralphql/version'
require 'ralphql/node'

module Ralphql
  class AttributeNotSupportedError < StandardError; end
  class EmptyBodyError < StandardError; end
end
