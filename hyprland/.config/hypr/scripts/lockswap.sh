#!/bin/bash

mv ~/.config/hypr/trash/hyprlock.conf.bak ~/.config/hypr/trash/hyprlock.conf
mv ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak
mv ~/.config/hypr/hyprlock.conf.bak ~/.config/hypr/trash/
mv ~/.config/hypr/trash/hyprlock.conf ~/.config/hypr/ 
