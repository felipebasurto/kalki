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

# iPad icons
magick "kalki.png" -resize 20x20 "kalki-ipad-20@1x.png"      # 20pt @1x
magick "kalki.png" -resize 40x40 "kalki-ipad-20@2x.png"      # 20pt @2x
magick "kalki.png" -resize 29x29 "kalki-ipad-29@1x.png"      # 29pt @1x
magick "kalki.png" -resize 58x58 "kalki-ipad-29@2x.png"      # 29pt @2x
magick "kalki.png" -resize 40x40 "kalki-ipad-40@1x.png"      # 40pt @1x
magick "kalki.png" -resize 80x80 "kalki-ipad-40@2x.png"      # 40pt @2x
magick "kalki.png" -resize 76x76 "kalki-ipad-76@1x.png"      # 76pt @1x
magick "kalki.png" -resize 152x152 "kalki-ipad-76@2x.png"    # 76pt @2x
magick "kalki.png" -resize 167x167 "kalki-ipad-83.5@2x.png"  # 83.5pt @2x 