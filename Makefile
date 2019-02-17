.PHONY: love clean run

TITLE=Untitled
TILED=/Applications/Tiled.app/Contents/MacOS/Tiled

clean:
	rm *.love

mapdata.lua: map.tmx
	${TILED} --export-map lua map.tmx mapdata.lua

run: mapdata.lua
	love .

# This is how to make love.
love: $(TITLE).love mapdata.lua

# Love is zipped.
${TITLE}.love: *.lua
	zip -9 -q -r $(TITLE).love .
