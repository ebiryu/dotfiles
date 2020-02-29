#!/bin/bash

for file in .??*; do
  ["$file" = ".DS_Store"] && continue
  ln -snfv ~/dotfiles/"$file" ~/
done
