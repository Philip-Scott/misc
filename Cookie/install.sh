#! /bin/bash

mkdir ~/.local/CC
cp Clicker ~/.local/CC/Cookie\ Clicker
cp icon.png ~/.local/CC/
cp Cookie\ Clicker.desktop ~/.local/share/applications/

sudo cp org.felipe.CookieClicker*.gschema.xml /usr/share/glib-2.0/schemas
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
