# Fichier: Plugins/JackUtils.rb
require 'sketchup.rb'
require 'extensions.rb'

module JackUtils
  # Définition de l'extension
  ext = SketchupExtension.new('Jack Utilities', File.join('JackUtils', 'main'))
  ext.description = "Boîte à outils complète par Jack."
  ext.version     = '2.0.0'
  ext.copyright   = 'Jack © 2026'
  ext.creator     = 'Jack'
  
  Sketchup.register_extension(ext, true)
end