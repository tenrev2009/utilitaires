# Fichier: Plugins/JackUtils/tools/system.rb
require 'win32/registry' if Sketchup.platform == :platform_win
require 'json'

module JackUtils
  module System
    
    # --- 1. PURGE FICHIERS RÉCENTS ---
    def self.purge_recent
      if Sketchup.platform == :platform_win
        begin
          path = 'Software\SketchUp\SketchUp 2024\Recent File List'
          # Tente d'adapter l'année si besoin, ou reste générique
          Win32::Registry::HKEY_CURRENT_USER.open(path, Win32::Registry::KEY_WRITE) do |reg|
            reg.each_value { |name, _, _| reg.delete_value(name) }
          end
          UI.messagebox("Fichiers récents purgés avec succès.")
        rescue => e
          UI.messagebox("Erreur (Windows) : #{e.message}")
        end
      else
        UI.messagebox("Cette fonction est pour Windows uniquement.")
      end
    end

    # --- 2. HOT RELOAD (Ton interface avancée) ---
    module HotReload
      def self.scan_plugins
        root = Sketchup.find_support_file("Plugins")
        entries = []
        
        # Scan des dossiers
        Dir.glob(File.join(root, "**", "*")).select { |p| File.directory?(p) }.each do |d|
          # Chemin relatif
          entries << d.sub(/^#{Regexp.escape(root + File::SEPARATOR)}/, "") + '/'
        end
        
        # Scan des fichiers .rb
        Dir.glob(File.join(root, "**", "*.rb")).each do |f|
          entries << f.sub(/^#{Regexp.escape(root + File::SEPARATOR)}/, "")
        end
        entries.sort
      end

      def self.show_dialog
        files = scan_plugins
        # HTML intégré directement
        html = <<~HTML
          <!DOCTYPE html>
          <html>
          <body style="font-family:sans-serif; margin:10px; background-color:#f0f0f0;">
            <h3 style="color:#333;">Hot Reload Plugin</h3>
            <p style="font-size:0.8em; color:#666;">Sélectionnez un fichier ou dossier à recharger :</p>
            <select id="plist" style="width:100%; height:200px; padding:4px; border:1px solid #ccc;" size="15">
              #{ files.map{ |e| "<option>#{e}</option>" }.join }
            </select>
            <div style="margin-top:10px; text-align:right">
              <button onclick="reload()" style="padding:5px 10px; cursor:pointer;">🔄 Reload</button>
              <button onclick="closeDialog()" style="padding:5px 10px; cursor:pointer;">✖ Fermer</button>
            </div>
            <script>
              function reload() {
                const sel = document.getElementById('plist');
                if (sel.selectedIndex >= 0) {
                  const val = sel.options[sel.selectedIndex].value;
                  window.sketchup.reloadPlugin(val);
                }
              }
              function closeDialog() { window.sketchup.closeWindow(); }
            </script>
          </body>
          </html>
        HTML

        @dlg ||= UI::HtmlDialog.new(
          dialog_title: "Jack Hot Reload",
          preferences_key: "JackHotReloadUI",
          width: 400, height: 350,
          style: UI::HtmlDialog::STYLE_DIALOG
        )

        @dlg.set_html(html)
        @dlg.add_action_callback("reloadPlugin") { |_, path| self.do_reload(path) }
        @dlg.add_action_callback("closeWindow") { |_| @dlg.close }
        @dlg.center
        @dlg.show
      end

      def self.do_reload(rel_path)
        root = Sketchup.find_support_file("Plugins")
        target = File.join(root, rel_path)
        
        # Détermine si on recharge un dossier ou un fichier
        scan_dir = if rel_path.end_with?('/')
                     target
                   elsif File.file?(target)
                     File.dirname(target)
                   else
                     nil
                   end

        unless scan_dir && Dir.exist?(scan_dir)
          UI.messagebox("Chemin invalide : #{rel_path}")
          return
        end

        # Si c'est un fichier spécifique, on ne recharge que lui, sinon tout le dossier
        files = File.file?(target) ? [target] : Dir.glob(File.join(scan_dir, "**", "*.rb")).sort
        
        errors = []
        files.each do |f|
          begin
            load f # C'est ICI que la magie opère (force la relecture)
            puts "Rechargé : #{File.basename(f)}"
          rescue Exception => e
            errors << "#{File.basename(f)} : #{e.message}"
          end
        end

        if errors.empty?
          Sketchup.status_text = "Succès : #{files.size} fichiers rechargés."
          UI.beep
        else
          UI.messagebox("Erreurs :\n" + errors.join("\n"))
        end
      end
    end

    # Point d'entrée appelé par le bouton de la toolbar
    def self.launch_reload_ui
      HotReload.show_dialog
    end

  end
end