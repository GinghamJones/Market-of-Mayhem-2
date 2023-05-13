# Market-of-Mayhem-2
A 3D 3rd person all-out brawl set in a grocery store. This project is made with Godot Engine 4.0.

The main scenes involved are Character, Projectile, Game Mode, Settings, Scene Switcher, Character Select, World, Player Controller, AI Controller, AI(So far just Aggressive AI), and Globals(SpawnManager and NameGenerator).

Entry starts with Scene Switcher, which loads Character Select on startup. This will eventually be replaced with Main Menu, but for ease of development is how it is now. A World and Settings Menu are also loaded on startup for future use but are hidden. 
The Spawn Manager is given spawn points from the world on its creation to aid with placing characters in the world. Scene Switcher is in charge of managing the active scenes in the game, with ability to add a Game Mode or Menu and delete whichever is no longer needed.

There are 2 Game Modes right now: Dev Mode and Timed Mode. A Game Mode is given a World as a child by Scene Switcher. Dev Mode starts with only a Player Character who can open a Dev Menu to add new characters. A round can be started or ended with the proper key presses,
but otherwise this is just a sandbox. 
Timed Mode is the real meat of the game (along with Lives Mode which is planned for future development). This mode consists of 3 rounds, each beginning with a short countdown, then lasting for a time before ending and showing the current score. At the end of the third
round, Scene Switcher returns us to Character Select.

There are 7 Character types, each inheriting from Character and containing their own CharacterData Resource, which has stats such as speed, ammo count, health, etc... Each Character will eventually receive their own model and animations but for now share one model. 
The Character scene contains functions pertaining to the manipulation of it in the game world, like changing velocity, handling animations, taking damage, death, respawning, etc... Each Character must be given a Controller, a Player Controller for humans and AIController
for AI. The Controller handles input and uses it to enact Character functions. 

AIControllers are given a detection field, Navigation Agent, and a Decision Tree. The detection field handles spotting enemies and incoming projectiles. The Decision Tree is still much a work-in-progress but follows mostly the standard method (at least as I understand
it!).

Controls:
  WASD : Movement
  LMB : Normal Attack
  RMB : Projectile Attack
  E : Debug Cam(Eventually will be Special Melee)
  Q : Block(Meh, not worth using yet)
  Shift : Dodge
  C : Show scoreboard(will be changed to tab eventually)
  Tab : Hide/Unhide Cursor(soon to be deleted)
  ESC : Settings Menu while in World
  Space : Do a jump animation.... no real use yet
  ~ : Dev Menu(in Dev Mode)
  O : Start Round(in Dev Mode)
  P : End Round(in Dev Mode)
