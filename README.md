# TextureBase
TextureBase is a mod that make it easy to create Texture Packs in factorio.
TextureBase can override textures, but also sound .ogg files to create a custom experience!
Follow the guide below to see how you can easily make your own texture pack!

---

# Steps

### Download TextureBase!

 - place TextureBase into the factorio/data mods folder
 - the mod does nothing on its own; now I will show how you can make a texturepack with its

### Give your Texture Pack a cool name!

- rename the TextureBase mod folder to what you want to call your texture pack in the format of '<texture_pack_name>_<version (x.y.z)>'. Your name must be lower case!
- edit info.json
    - set "name" to the lower case mod name of your folder
	- set "version" to the version of your texturepack (usually 0.0.1 if you are creating a new texture pack)
	- set "title" to the mod name! Here you may use uppercase letters & spaces
	- set "author" to the username of your [Factorio Account](https://factorio.com/login)
	- edit the other fields as you see fit... if you are retexturing another mod, I recommend listing that mod as an optional dependency, to guarantee your texture pack is loaded after the mod you are retexturing is.
- edit config.lua
    - set resource_pack_name to what you wrote for "name" in info.json

### Create duplicate file tree in *\_\_texturepackfolder\_\_/data* to add your own textures & sounds!

- For the texturepack to apply your textures correctly, you need to save them in a specific format & location. follow the next steps
- locate the data folder inside of your texturepack (TextureBase). It should be empty.
- Think of this *\_\_texturepackfolder\_\_/data* directory as a duplicate of the *factorio/data* directory (mods folder). Any textures created in this *\_\_texturepackfolder\_\_/data* **must have the same relative paths as their originals to factorio/data**
	- for example, to retexture a nuclear explosion, you would:
        - find the directory in which the nuclear explosion sprites are stored, which is *factorio/data/base/graphics/entity/nuke-explosion/*
	    - mirror the file tree in *\_\_texturepackfolder\_\_/data*, such that the directory *\_\_texturepackfolder\_\_/data/base/graphics/entity/nuke-explosion/* exists
	    - place the .png files in *factorio/data/base/graphics/entity/nuke-explosion/* you have retextured in *\_\_texturepackfolder\_\_/data/base/graphics/entity/nuke-explosion/*. Make sure the file name & format of your texture is the same the original.
- Mods may have file trees with different structures to base or core.
    - You must nonetheless mirror the file tree of the respective mod.
    - e.g. to change the logistic chest texture in [boblogistics](https://mods.factorio.com/mod/boblogistics) found at *factorio/data/boblogistics/graphics/entity/logistic-chest/*, you would have to add your retextured files to *\_\_texturepackfolder\_\_/data/boblogistics/graphics/entity/logistic-chest/*
- sounds work the same! To change the spidertron activation sound (*factorio/data/base/sound/spidertron/spidertron-activate.ogg*), place your new sound file to *\_\_texturepackfolder\_\_/data/base/sound/spidertron/spidertron-activate.ogg*
	
- if you are planning on retexturing large parts of base or another mod, I would recommend copying the mod directory found in *factorio/data* to *\_\_texturepackfolder\_\_/data*, and deleting any files / directories that do not contain images or .ogg sound files (or textures/sounds you don't want to change)!


### Let your texture pack know which files you have retextured!

- Sadly, due to factorio lua not being able to read files, the texture pack currently has no way of knowing which files you put into *\_\_texturepackfolder\_\_/data*
- Let's change that
- edit config.lua
    - Here you let the resource pack know which textures & sounds you have created in *\_\_texturepackfolder\_\_/data* and hence would like changed in game. You do this by changing the 'data' table in config.lua
	- To let the program know you want *factorio/data/base/sound/spidertron/spidertron-activate.ogg* replaced by *\_\_texturepackfolder\_\_/data/base/sound/spidertron/spidertron-activate.ogg*, you write the following:
	  ```lua
	  data = {
	      base = {
		      sound = {
				spidertron = {
				      "spidertron-activate.ogg",
				  },
			  },
		  },
	  }
	  ```
	  You can see how the path to the file to be changed is specified in config.lua, every directory bying a table, and files being strings (in quotation marks)
		


