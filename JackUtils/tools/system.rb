# encoding: UTF-8
require 'sketchup.rb'

module JackUtils
  module System
    
    # --- 1. PURGE RECENT ---
    def self.purge_recent
      if Sketchup.platform == :platform_win
        begin
          require 'win32/registry'
          # Chemin registre (Adaptez 2024 si besoin vers votre version)
          path = 'Software\SketchUp\SketchUp 2024\Recent File List'
          Win32::Registry::HKEY_CURRENT_USER.open(path, Win32::Registry::KEY_WRITE) do |reg|
            reg.each_value { |name, _, _| reg.delete_value(name) }
          end
          # Utilisation de \u00E9 pour "é" afin d'éviter l'erreur multibyte
          UI.messagebox("Succ\u00E8s : Fichiers r\u00E9cents purg\u00E9s.")
        rescue => e
          UI.messagebox("Erreur purge (Windows) : #{e.message}")
        end
      else
        UI.messagebox("Fonction Windows uniquement.")
      end
    end

    # --- 2. RELOAD UI ---
    def self.get_plugin_files
      root = Sketchup.find_support_file("Plugins")
      files = []
      
      # Récupération récursive des fichiers .rb
      Dir.glob(File.join(root, "**", "*.rb")).each do |f|
        # Création du chemin relatif
        rel_path = f.sub(root, "")
        # Nettoyage critique pour Windows : on remplace antislash par slash
        rel_path = rel_path.gsub("\\", "/")
        # On enlève le slash de début s'il reste
        rel_path = rel_path[1..-1] if rel_path.start_with?("/")
        files << rel_path
      end
      files.sort
    end

    def self.show_reload_dialog
      # On prépare la liste HTML ici, en Ruby
      files = get_plugin_files
      options_list = ""
      
      files.each do |f|
        options_list += "<option value='#{f}'>#{f}</option>"
      end

      # On injecte la liste directement dans le HTML
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <body style="font-family:sans-serif; background:#f0f0f0; padding:10px;">
          <h3>Reload Plugins</h3>
          <select id="file_select" style="width:100%; height:300px; margin-bottom:10px;">
            #{options_list}
          </select>
          <button onclick="doReload()" style="width:100%; padding:10px; font-weight:bold; cursor:pointer;">RECHARGER</button>
          
          <script>
            function doReload() {
              var sel = document.getElementById('file_select');
              if (sel.selectedIndex >= 0) {
                window.sketchup.reload_file(sel.value);
              } else {
                alert("Veuillez choisir un fichier !");
              }
            }
          </script>
        </body>
        </html>
      HTML

      @dlg = UI::HtmlDialog.new(
        dialog_title: "Jack Reload",
        preferences_key: "JackReloadSafe",
        width: 400, height: 450,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      
      @dlg.set_html(html)
      @dlg.center
      
      @dlg.add_action_callback("reload_file") do |_, filename|
        self.perform_reload(filename)
      end
      
      @dlg.show
    end

    def self.perform_reload(rel_path)
      root = Sketchup.find_support_file("Plugins")
      full_path = File.join(root, rel_path)
      
      begin
        load full_path
        # Utilisation de \u00E9 pour éviter l'erreur d'encodage sur le message
        UI.messagebox("Fichier recharg\u00E9 :\n#{rel_path}")
      rescue => e
        UI.messagebox("Erreur :\n#{e.message}")
      end
    end

  end
end