# vim plugin for code notes

## Description

This repo contains a plugin for simplifying taking notes while coding. Code notes is a plugin that will open a new split (horizontal or vertical) that will store your notes while coding. After opening the split there are simple keyboard shortcuts that will copy a single line or multiple visual lines to your code note and then return back to your original split.

## Layout

The autoload directory contains all of the code functions for code notes.

The plugin direcotry contains all of the commands and shortcut key definitions.

The doc directory contains all of the vim documentation for how code notes works.

## Defaults

## Notes
### Installation
Without a plugin manager, for a simple install, you can create a pack folder in your .vim directory and clone this repo

*mkdir -p ~/.vim/pack/code_notes/start*

*cd ~/.vim/pack/code_notes/start/*

*git clone https://github.com/CombobulateTech/vim_CodeNotes*


Without a plugin manager, for a manual install, you can just copy the files from each of the git folders into their prospective .vim folders:

*autoload/code_notes.vim -> ~/.vim/autoload/code_notes/code_notes.vim*

*doc/code_notes.vim -> ~/.vim/doc/code_notes/code_notes.vim*

*plugin/code_notes.vim -> ~/.vim/plugin/code_notes/code_notes.vim*

### Usage
[Link to vim documentation](code_notes/doc/code_notes.txt)
