# [Current Map](https://openplanet.dev/plugin/currentmap)

  

Allows to share the current map you're playing with other players and display it on screen. It can be useful when speedrunning the seasonal campaign with friends for instance.
![Ingame screenshot](https://i.imgur.com/rU4WQlQ.png)

Every player with the same API Key in the settings will be part of the list. You can put whatever alphanumerical string you want as an API Key. Having a long string lowers the chance of conflicts with other groups of players using the plugin.

![Settings screenshot](https://i.imgur.com/kcnF2Oc.png)

All information are sent and stored temporarly to a server in order to share them with every player in your group. Here is the list of what is shared and stored :

 - Player unique identifier (only stored)
 - Player username
 - Player Club Tag
 - Player region (country)
 - Current map name
 - Current map author time
 - Current map personnal best

The first four information are already public and can be found by any person using the Nadeo Services API.

Thanks a lot to Miss, Greep and Phlarx for their work. The code is mostly inspired by plugins of theirs :
https://github.com/codecat/tm-better-chat

https://github.com/Phlarx/tm-ultimate-medals

https://github.com/tm-rmc/MXRandom
