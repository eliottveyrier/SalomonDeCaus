## Hortus Palatinus

### An interactive concert

From archive scans of engravings of the original designs of the [Hortus Palatinus](https://en.wikipedia.org/wiki/Hortus_Palatinus) garden in heidelberg, this project was an interactive installation
and music concert where people could "visit" the original designs, interact with some mini-games, look at engravings of many details of the garden, all influencing the music thanks to Open Sound Control data
being sent via UDP from this game to a Reaktor patch.

The concert was played in the [KlangForum](https://klangforum-heidelberg.de/en) in Heidelberg to celebrate the 450th anniversary of Salomon De Caus, and in Montpellier for the Radio France Occitanie Festival. The real garden in Heidelberg was sadly destroyed in the 30-year war before its completion and is now a less ambitious but quite enjoyable garden, where only a few of the originally planned sculptures and features remain.

The music was played live by two flautists, an organist, and a keyboardist playing with an extensive Reaktor patch that spatialized and twisted the sound based on the OSC messages sent by the game. There also was a physical installation detailing the history of Samolon De Caus and of the garden.

## Technology

The installation is a Godot game, with a small Rust GDExtension that handles UDP and Open Sound Control messages.
This was done over a few days of caffeine-reinforced work and is therefore not the tidyest repository, but some systems are reusable.

Having a debug console autoload where anything can register commands (and would unregister them if there was any scene changing in the game) 
was a great help in allowing us to fix issues quickly. I might polish this into a plugin later.







