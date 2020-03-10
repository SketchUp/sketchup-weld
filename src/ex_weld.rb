require 'sketchup.rb'
require 'extensions.rb'

module Examples
  module Weld

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('SketchUp Weld', 'ex_weld/main')
      ex.description = 'SketchUp Ruby API example using Weld.'
      ex.version     = '1.0.0'
      ex.copyright   = 'Trimble Inc. © 2020'
      ex.creator     = 'SketchUp'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module Weld
end # module Examples
