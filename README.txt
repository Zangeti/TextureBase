This mod allows you to make texture packs!
To get started making your own texture pack, follow the upcoming steps.
As a quick heads up, unless you know what you are doing, don't change code in the data-final-fixes.lua file. You should only have to work in config.lua and info.json

1. Give the mod folder a cooool name!
   - Make sure it is lower case
   - It must be in the format of '<mod_name>_<version (x.y.z)>'

2. Info .json time!
   - set "name" to the lower case mod name of your folder
   - set "version" to the mod version, also in the folder name
   - set "title" to the mod name which can include upper case letters if you wish
   - set "author" to the username of your Factorio Account
   - edit the other fields as you see fit (check the documentation if in doubt)

3. What do you want to change?
   - Decide which textures you want to change
   - Inside of the data folder in this mod, create a directory for every mod you are creating textures for (core & base included)
   - Inside these, mirror the directory structure of the respective mod for all folders that contain images you wish to retexture!

4. Getting started!
   - Create your retextures, name & and format them the same way as is done by the mod you are retexturing, and put it into its respective position in the mirrored directory tree
   - You can also create your alternative for the sound .ogg files

5. Configuration
   - config.lua
   - resource_pack_name = "<name of resource pack in lower case>"
     - resource_pack_name should be the same as "name" in info.json

   - data table
   - Here you let the program know which sounds & textures you will be replacing

   - e.g.
   - data = {
         base = {},
		 core = {},
         bobslogistics = {},
     }
   - The above data tree would require you to have a respective .ogg/.jpg file in the mod data directory tree, for every .ogg, .png and .jpg file in base, core and bobslogistics


   - If you wanted to only change e.g. the texture files for the spidertron, and the spidertron activation & deactivation sound effect you would do so as follows:
   - data = {
         base = {
             graphics = {
	         entity = {
                     spidertron = {
                     
                     },
                 },
             },
             sound = {
                 spidertron = {		 
                      "spidertron-activate.ogg",
                      "spidertron-deactivate.ogg",
                 },
             },
         },     
     }
   - whenever a folder a specified with 'foldername = {}', if no folders or files are denoted inside it, the whole folder's contents need to be retextured (and present in the __mod__/data directory)
     - If one or more file(s)/folder(s) are specified, only these files / the content of these folders need to be retextured


   - See examples of data tables in my example texture packs, @ https://mods.factorio.com/mod/pixelperfect, https://mods.factorio.com/mod/shadowworld and https://mods.factorio.com/mod/hologramworld!
   - the README.md also features different examples of config.lua data tables.


6. It's nothing... You're DONE!
   - Upload your creation
   - You may want to expand on your texture packs with special behaviours & hence a control.lua! Go ahead!
   - Would love seeing what you have made! Send me a link to your texture pack in 




Troubleshooting:

 - Errors with missing files;
   you have either not correctly mirrored the file tree of the mod you are retexturing,
   or your data table in config.lua is telling the game to look for files you don't actually mean to be retexturing.

 - Note, mod does not crash if more files are in this texture_packs data directory than are included in the config.lua data table.
   However, files not included in the config.lua data table are not loaded into the game!
    - If you encounter no errors, but certain textures you have created are not loaded ingame, make sure the data table in config.lua is including these textures!
	