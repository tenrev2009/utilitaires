module JackUtils
  module MatchCompo
    def self.start_tool
      Sketchup.active_model.select_tool(Tool.new)
    end

    class Tool
      def activate
        Sketchup.active_model.selection.clear
        puts "Cliquez sur la source, puis sur la cible."
      end

      def onLButtonDown(flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        sel = ph.best_picked
        return unless sel.is_a?(Sketchup::ComponentInstance)

        if @source.nil?
          @source = sel
          UI.messagebox("Source: #{@source.definition.name}. Cliquez sur la cible.")
        else
          sel.definition = @source.definition
          @source = nil
          Sketchup.active_model.select_tool(nil)
        end
      end
    end
  end
end