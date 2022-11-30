#
#    Fennec build scripts
#    Copyright (C) 2020-2022  Matías Zúñiga, Andrew Nayenko
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

outdir := ../fenix-overlay/res
images := $(foreach x,hdpi mdpi xhdpi xxhdpi xxxhdpi, \
                    $(outdir)/mipmap-$(x)/ic_launcher.png \
                    $(outdir)/mipmap-$(x)/ic_launcher_foreground.png \
                    $(outdir)/drawable-$(x)/ic_logo_wordmark_normal.png \
                    $(outdir)/drawable-$(x)/ic_logo_wordmark_private.png) \
          $(outdir)/drawable/ic_wordmark_text_normal.png \
          $(outdir)/drawable/ic_wordmark_text_private.png \
          $(outdir)/drawable/ic_wordmark_logo.png

all: $(images)

clean:
	rm -f $(images)

define rasterize
mkdir -p $(dir $@)
$(eval temp := $(shell mktemp).png)
inkscape $< -o $(temp) --export-area=$(1) -h $(2)
optipng -o7 -quiet -out $@ $(temp)
rm $(temp)
endef

# Legacy non-adaptive icon

$(outdir)/mipmap-mdpi/ic_launcher.png : ic_launcher_foreground.svg
	$(call rasterize,24:24:84:84,48)

$(outdir)/mipmap-hdpi/ic_launcher.png : ic_launcher_foreground.svg
	$(call rasterize,24:24:84:84,72)

$(outdir)/mipmap-xhdpi/ic_launcher.png : ic_launcher_foreground.svg
	$(call rasterize,24:24:84:84,96)

$(outdir)/mipmap-xxhdpi/ic_launcher.png : ic_launcher_foreground.svg
	$(call rasterize,24:24:84:84,144)

$(outdir)/mipmap-xxxhdpi/ic_launcher.png : ic_launcher_foreground.svg
	$(call rasterize,24:24:84:84,192)

# Adaptive icon foreground

$(outdir)/mipmap-mdpi/ic_launcher_foreground.png : ic_launcher_foreground.svg
	$(call rasterize,0:0:108:108,108)

$(outdir)/mipmap-hdpi/ic_launcher_foreground.png : ic_launcher_foreground.svg
	$(call rasterize,0:0:108:108,162)

$(outdir)/mipmap-xhdpi/ic_launcher_foreground.png : ic_launcher_foreground.svg
	$(call rasterize,0:0:108:108,216)

$(outdir)/mipmap-xxhdpi/ic_launcher_foreground.png : ic_launcher_foreground.svg
	$(call rasterize,0:0:108:108,324)

$(outdir)/mipmap-xxxhdpi/ic_launcher_foreground.png : ic_launcher_foreground.svg
	$(call rasterize,0:0:108:108,432)

# Wordmark normal

$(outdir)/drawable-mdpi/ic_logo_wordmark_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,0:0:300:46,80)

$(outdir)/drawable-hdpi/ic_logo_wordmark_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,0:0:300:46,120)

$(outdir)/drawable-xhdpi/ic_logo_wordmark_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,0:0:300:46,160)

$(outdir)/drawable-xxhdpi/ic_logo_wordmark_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,0:0:300:46,240)

$(outdir)/drawable-xxxhdpi/ic_logo_wordmark_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,0:0:300:46,320)

# Wordmark private

$(outdir)/drawable-mdpi/ic_logo_wordmark_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,0:0:300:46,80)

$(outdir)/drawable-hdpi/ic_logo_wordmark_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,0:0:300:46,120)

$(outdir)/drawable-xhdpi/ic_logo_wordmark_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,0:0:300:46,160)

$(outdir)/drawable-xxhdpi/ic_logo_wordmark_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,0:0:300:46,240)

$(outdir)/drawable-xxxhdpi/ic_logo_wordmark_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,0:0:300:46,320)

# Wordmark normal, text-only

$(outdir)/drawable/ic_wordmark_text_normal.png : ic_logo_wordmark_normal.svg
	$(call rasterize,64:10:300:35,70)

# Wordmark private, text-only

$(outdir)/drawable/ic_wordmark_text_private.png : ic_logo_wordmark_private.svg
	$(call rasterize,64:10:300:35,70)

# Wordmark logo

$(outdir)/drawable/ic_wordmark_logo.png : ic_launcher_foreground.svg
	$(call rasterize,28:28:80:80,160)

.PNONY: all clean
