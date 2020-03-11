require 'sketchup.rb'

module Examples
  module Weld

    EDGE_COLOR_BY_MATERIAL = 0
    EDGE_COLOR_ALL_THE_SAME = 1
    EDGE_COLOR_BY_AXIS = 2

    STIPPLE_DOTTED = "." # (Dotted Line),
    STIPPLE_SHORT_DASH = "-" # (Short Dashes Line),
    STIPPLE_LONG_DASH = "_" # (Long Dashes Line),
    STIPPLE_DASH_DOT_DASH = "-.-" # (Dash Dot Dash Line).

    def self.weld_selection
      model = Sketchup.active_model
      entities = model.active_entities
      edges = model.selection.grep(Sketchup::Edge)
      if edges.size < 2
        message = 'Select at least two edges to weld.'
        UI.messagebox(message)
        return
      end

      model.start_operation('Weld', true)
      entities.weld(edges)
      model.commit_operation
    end

    def self.count_curves
      model = Sketchup.active_model
      entities = model.active_entities
      edges = entities.grep(Sketchup::Edge)
      curves = edges.map(&:curve).flatten.uniq.compact
      message = "There are #{curves.size} curves in the current context."
      UI.messagebox(message)
    end

    def self.dump_pids
      model = Sketchup.active_model
      entities = model.active_entities
      edges = entities.grep(Sketchup::Edge)
      curves = edges.map(&:curve).flatten.uniq.compact
      return if curves.empty?
      SKETCHUP_CONSOLE.show
      curves.each { |curve|
        puts
        puts "#{curve.persistent_id} (#{curve.vertices.first.position.inspect})"
        curve.edges.each { |edge|
          puts "  #{edge.persistent_id}"
        }
      }
    end

    def self.colorize_curves
      model = Sketchup.active_model
      entities = model.active_entities
      edges = entities.grep(Sketchup::Edge)
      curves = edges.map(&:curve).flatten.uniq.compact
      return if curves.empty?

      model.start_operation('Colorize Curves', true)
      model.rendering_options['EdgeColorMode'] = EDGE_COLOR_BY_MATERIAL
      colors = Sketchup::Color.names.sample(curves.size)
      curves.each_with_index { |curve, i|
        color = colors[i]
        curve.edges.each { |edge| edge.material = color }
      }
      model.commit_operation
    end

    def self.mark_curve_ends
      model = Sketchup.active_model
      entities = model.active_entities
      edges = entities.grep(Sketchup::Edge)
      curves = edges.map(&:curve).flatten.uniq.compact
      return if curves.empty?

      model.start_operation('Mark Curve Ends', true)
      model.rendering_options['ConstructionColor'] = 'red'
      curves.each { |curve|
        vertices = curve.vertices
        pt1 = vertices.first.position
        pt2 = vertices.last.position

        entities.add_cpoint(pt1) # Start of curve
        cline = entities.add_cline(pt1, pt1.offset(Z_AXIS, 500.mm))
        cline.stipple = STIPPLE_LONG_DASH

        if pt1 == pt2 # Closed curve
          cline.stipple = STIPPLE_DASH_DOT_DASH
          next
        end

        entities.add_cpoint(pt2) # End of curve
        cline = entities.add_cline(pt2, pt2.offset(Z_AXIS, 500.mm))
        cline.stipple = STIPPLE_DOTTED
      }
      model.commit_operation
    end

    def self.mark_edge_pids
      model = Sketchup.active_model
      entities = model.active_entities
      edges = entities.grep(Sketchup::Edge)
      return if edges.empty?

      model.start_operation('Mark Edge PIDs', true)
      edges.each { |edge|
        pt1, pt2 = edge.vertices.map(&:position)
        mid = Geom.linear_combination(0.5, pt1, 0.5, pt2)
        text = entities.add_text(edge.persistent_id.to_s, mid, [0, 0, 500.mm])
        text.material = 'orange'
      }
      model.commit_operation
    end

    def self.validate_model
      if Sketchup.platform == :platform_osx
        message = 'Ruby API cannot trigger Check Validity on mac builds. '\
                  'Use "Fix Problems" from the Model Info dialog.'
        UI.messagebox(message)
        UI.show_model_info('Statistics')
      else
        Sketchup.send_action(21124) # Triggers Check Validity
      end
    end

    unless file_loaded?(__FILE__)
      plugins_menu = UI.menu('Plugins')
      menu = plugins_menu.add_submenu('Weld Debug')
      menu.add_item('Count Curves') { count_curves }
      menu.add_item('Dump PIDs') { dump_pids }
      menu.add_item('Colors Curves') { colorize_curves }
      menu.add_item('Mark Curve Endpoints') { mark_curve_ends }
      menu.add_item('Mark Edge PIDS') { mark_edge_pids }
      menu.add_item('Validate Model') { validate_model }

      UI.add_context_menu_handler do |context_menu|
        model = Sketchup.active_model
        entities = model.active_entities
        edges = model.selection.grep(Sketchup::Edge)

        context_menu.add_item('Weld') { weld_selection } unless edges.empty?
      end

      file_loaded(__FILE__)
    end

  end # module Weld
end # module Examples
