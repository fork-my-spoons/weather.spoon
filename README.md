# Weather

TBD

![screenshot](./screenshots/screenshot.png)

![screenshot](./screenshots/screenshot2.png)

```lua
-- weather
hs.loadSpoon('weather')
spoon.weather:setup{
  app_id = 'owm app id',
  -- units = 'f',
  lat = 45.501670,
  lon = -73.567221,
--   city = 'Montreal,QC,CA'
}
spoon.weather:start()
```