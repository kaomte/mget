@echo off
cd "C:\Program Files\mget\Downloads"
"C:\Program Files\mget\mget.rb" -dC "%1"
explorer "C:\Program Files\mget\Downloads"