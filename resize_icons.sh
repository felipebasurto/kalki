#!/bin/bash

cd "kalki/Assets.xcassets/AppIcon.appiconset"

# iPhone icons
magick "kalki 8.png" -resize 40x40 "kalki 8.png"     # 20pt @2x
magick "kalki 7.png" -resize 60x60 "kalki 7.png"     # 20pt @3x
magick "kalki 6.png" -resize 58x58 "kalki 6.png"     # 29pt @2x
magick "kalki 5.png" -resize 87x87 "kalki 5.png"     # 29pt @3x
magick "kalki 4.png" -resize 80x80 "kalki 4.png"     # 40pt @2x
magick "kalki 3.png" -resize 120x120 "kalki 3.png"   # 40pt @3x
magick "kalki 2.png" -resize 120x120 "kalki 2.png"   # 60pt @2x
magick "kalki 1.png" -resize 180x180 "kalki 1.png"   # 60pt @3x
magick "kalki.png" -resize 1024x1024 "kalki.png"     # App Store 