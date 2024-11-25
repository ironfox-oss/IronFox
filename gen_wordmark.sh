#!/bin/bash
#License: AGPL-3.0

drawable="./fenix-overlay/res/drawable";
font="Fira-Sans-Bold";
wordmark="Mull";

convert -background transparent -fill black -font $font -gravity center -size x80 label:$wordmark $drawable-mdpi/ic_logo_wordmark_normal.png
convert -background transparent -fill white -font $font -gravity center -size x80 label:$wordmark $drawable-mdpi/ic_logo_wordmark_private.png
convert -background transparent -fill black -font $font -gravity center -size x80 label:$wordmark $drawable-mdpi/ic_wordmark_text_normal.png
convert -background transparent -fill white -font $font -gravity center -size x80 label:$wordmark $drawable-mdpi/ic_wordmark_text_private.png

convert -background transparent -fill black -font $font -gravity center -size x120 label:$wordmark $drawable-hdpi/ic_logo_wordmark_normal.png
convert -background transparent -fill white -font $font -gravity center -size x120 label:$wordmark $drawable-hdpi/ic_logo_wordmark_private.png
convert -background transparent -fill black -font $font -gravity center -size x120 label:$wordmark $drawable-hdpi/ic_wordmark_text_normal.png
convert -background transparent -fill white -font $font -gravity center -size x120 label:$wordmark $drawable-hdpi/ic_wordmark_text_private.png

convert -background transparent -fill black -font $font -gravity center -size x160 label:$wordmark $drawable-xhdpi/ic_logo_wordmark_normal.png
convert -background transparent -fill white -font $font -gravity center -size x160 label:$wordmark $drawable-xhdpi/ic_logo_wordmark_private.png
convert -background transparent -fill black -font $font -gravity center -size x160 label:$wordmark $drawable-xhdpi/ic_wordmark_text_normal.png
convert -background transparent -fill white -font $font -gravity center -size x160 label:$wordmark $drawable-xhdpi/ic_wordmark_text_private.png

convert -background transparent -fill black -font $font -gravity center -size x240 label:$wordmark $drawable-xxhdpi/ic_logo_wordmark_normal.png
convert -background transparent -fill white -font $font -gravity center -size x240 label:$wordmark $drawable-xxhdpi/ic_logo_wordmark_private.png
convert -background transparent -fill black -font $font -gravity center -size x240 label:$wordmark $drawable-xxhdpi/ic_wordmark_text_normal.png
convert -background transparent -fill white -font $font -gravity center -size x240 label:$wordmark $drawable-xxhdpi/ic_wordmark_text_private.png

convert -background transparent -fill black -font $font -gravity center -size x320 label:$wordmark $drawable-xxxhdpi/ic_logo_wordmark_normal.png
convert -background transparent -fill white -font $font -gravity center -size x320 label:$wordmark $drawable-xxxhdpi/ic_logo_wordmark_private.png
convert -background transparent -fill black -font $font -gravity center -size x320 label:$wordmark $drawable-xxxhdpi/ic_wordmark_text_normal.png
convert -background transparent -fill white -font $font -gravity center -size x320 label:$wordmark $drawable-xxxhdpi/ic_wordmark_text_private.png
