# TextureBase
**TextureBase is a mod that make it easy to create Texture Packs in factorio.<br/>**
**It's tool help you override textures, but also sound .ogg files so you can create your own a custom experience!<br/>**
<br/>
Follow the guide below to see how you can easily make your own texture pack!<br/>
Don't be intimidated by the README length; a vast majority is dedicated towards explaining [Attributes](#attributes) & [Wild Cards](#wild-cards-), an optional tool you don't have to use for your texturepack & giving lots of examples!

> Why not check out my discord @ [https://discord.gg/kC53xn2](https://discord.gg/kC53xn2) and the factorio mod portal @ [https://mods.factorio.com/mod/texturebase](https://mods.factorio.com/mod/texturebase) for more info

#### Contents
 - **[Steps](#steps)**
	- [Download TextureBase!](#download-texturebase)
	- [Give your Texture Pack a cool name!](#give-your-texture-pack-a-cool-name)
	- [Create duplicate file tree in *\_\_texturepackfolder\_\_/data* to add your own textures & sounds!](#create-duplicate-file-tree-in-\_\_texturepackfolder\_\_data-to-add-your-own-textures--sounds)
	- [Let your texture pack know which files you have retextured!](#let-your-texture-pack-know-which-files-you-have-retextured)
		- *[Basic Syntax](#basic-syntax)*
		- *[Attributes  __(optional)__](#attributes)*
		- *[Wild Cards (\*) __(optional)__](#wild-cards-)*
	- [You're done!!!](#youre-done)
 - **[Still having Issues, Bugfixes, Feature Requests](#still-having-issues-bugfixes-feature-requests)**
 - **[License](#license)**

---


# Steps

## Download TextureBase!

 - Place TextureBase into the factorio/data mods folder
 - The mod does nothing on its own; follow the next steps to make a texturepack with it!

---


## Give your Texture Pack a cool name!

- Rename the TextureBase mod folder to what you want to call your texture pack in the format of '<texture_pack_name>_<version (x.y.z)>'. Your name must be lower case!
- edit info.json
    - set "name" to the lower case mod name of your folder
	- set "version" to the version of your texturepack (usually 0.0.1 if you are creating a new texture pack); must be the same as the version written in the folder name
	- set "title" to the mod name! Here you may use uppercase letters & spaces
	- set "author" to the username of your [Factorio Account](https://factorio.com/login)
	- edit the other fields as you see fit... if you are retexturing another mod, I recommend listing that mod as an optional dependency, to guarantee your texture pack is loaded after the mod you are retexturing is.
- edit config.lua
    - set resource_pack_name to what you wrote for "name" in info.json

---


## Create duplicate file tree in *\_\_texturepackfolder\_\_/data* to add your own textures & sounds!

- For the texturepack to apply your textures correctly, you need to save them in a specific format & location. Follow the next steps:
- Locate the data folder inside of your texturepack (the folder you just renamed). That data folder should be empty (we will from now on call this data folder *\_\_texturepackfolder\_\_/data*).
- Think of this *\_\_texturepackfolder\_\_/data* directory as a duplicate of the *factorio/data* directory (mods folder). **Any textures created in this *\_\_texturepackfolder\_\_/data* must have the same relative paths as their originals to factorio/data**
	- for example, to retexture a nuclear explosion, you would:
        - find the directory in which the nuclear explosion sprites are stored, which is *factorio/data/base/graphics/entity/nuke-explosion/*
	    - mirror the file tree in *\_\_texturepackfolder\_\_/data*, such that the directory *\_\_texturepackfolder\_\_/data/base/graphics/entity/nuke-explosion/* exists
	    - place the .png files in *factorio/data/base/graphics/entity/nuke-explosion/* you have retextured in *\_\_texturepackfolder\_\_/data/base/graphics/entity/nuke-explosion/*. Make sure the file name & format of your texture is the same the original.
- Mods may have file trees with different structures to base or core.
    - You must nonetheless mirror the file tree of the respective mod.
    - e.g. to change the logistic chest texture in [boblogistics](https://mods.factorio.com/mod/boblogistics) found at *factorio/data/boblogistics/graphics/entity/logistic-chest/*, you would have to add your retextured files to *\_\_texturepackfolder\_\_/data/boblogistics/graphics/entity/logistic-chest/*
- Sounds work the same! To change the spidertron activation sound (*factorio/data/base/sound/spidertron/spidertron-activate.ogg*), place your new sound file to *\_\_texturepackfolder\_\_/data/base/sound/spidertron/spidertron-activate.ogg*
	
- If you are planning on retexturing large parts of base or another mod, I would recommend copying the mod directory found in *factorio/data* to *\_\_texturepackfolder\_\_/data*, and deleting any files / directories that do not contain images or .ogg sound files (or textures/sounds you don't want to change)!

---


## Let your texture pack know which files you have retextured!

### Basic Syntax

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
						["spidertron-activate.ogg"] = { },
					},
				},
			},
		}
		```
	  > You can see how the path to the file to be changed is specified in config.lua, every directory and file being represented by a table (though files are always in the format ["\<filename\>"] = {}, whilst this is only the case for folders with special character in their name \[see below in Key Rules]).
	- If you wanted to change both deactivation & activation sound of the spidertron, both of which are found in the *factorio/data/base/sound/spidertron/* directory, you would do so as follows
		```lua
		data = {
			base = {
				sound = {
					spidertron = {
						["spidertron-activate.ogg"] = { },
						["spidertron-deactivate.ogg"] = { },
					},
				},
			},
		}
		```
	  > Keep in mind your own *spidertron-activate.ogg* and *spidertron-deactivate.ogg* both have to exist in *\_\_texturepackfolder\_\_/data/base/sound/spidertron/* for the mod to replace the original sound files with your own! If you specify files in the config.lua data table that do not exist in *\_\_texturepackfolder\_\_/data/* your texture pack will throw a 'file not found' error upon loading the game.
	- If you wanted to change every spidertron sound stored in *factorio/data/base/sound/spidertron*, you luckily don't have write all of them out! The format below tells the texture pack to replace every sound in the *factorio/data/base/sound/spidertron* directory (and any subdirectories) with their *\_\_texturepackfolder\_\_/data* equivalents!
		```lua
		data = {
			base = {
				sound = {
					spidertron = {
						
					},
				},
			},
		}
		```
	  > Pay special attention to how folders with listed contents will exclusively have these contents loaded into the game as textures/sounds, whilst when folder contents are not specified, all .ogg, .png and .jpg files inside them are loaded into the game as textures. Once again, ensure that *\_\_texturepackfolder\_\_/data/base/sound/spidertron* contains a retextured file for every file in *factorio/data/base/sound/spidertron*, so your texture pack is not trying to assign textures to files that don't actually exist!

    - At this point you have learnt the basic syntax of using the config.lua data table to let your resource pack know which textures / sounds you are replacing!<br/>
	  <br/>
	  **The Key Rules are:**<br/>
	  **1.	Folders are always declared as tables (\<foldername\> = {}, or if special characters (such as .,%+-/\*) are in the foldername ["\<foldername\>"] = {},)**<br/>
	  **2.	Files are always declared as tables in the following format; ["\<filename\>"] = {}, like folders with special characters in their name**<br/>
	  **3.	Undefined table contents mean all of that folders/images .ogg, .png and .jpg contents have been retextured and exist the repective path in *\_\_texturepackfolder\_\_/data***<br/>
	  **4.	Folders with defined contents (whether that be files or other folders), contain retextured .ogg, .png and .jpg files in these defined folders / files**<br/>
	  > A few more examples will follow, but they all follow the above fundamental guidelines.
	
	- The below example is telling the resource pack you are retexturing/changing *accumulator.png* and *hr-accumulator.png* in *factorio/data/base/graphics/entity/accumulator/*, along with all .ogg, .png and .jpg files in, *factorio/data/base/sound/spidertron/*, *factorio/data/core/sound/* and *factorio/data/boblogistics/graphics/gui/*
		```lua
		data = {
			base = {
				graphics = {
					entity = {
						accumulator = {
							["accumulator.png"] = { },
							["hr-accumulator.png"]  = { },
						},
						["copper-ore"] = {
							
						},
					},
				},
				sound = {
					spidertron = {
						
					},
				},
			},
			core = {
				sound = {
					
				},
			},
			boblogistics = {
				graphics = {
					gui = {
						
					},
				},
			},
		}
		```
	  > Note that the use of '["copper-ore"]'. This is the format in which foldernames need to be written down that include special characters, in this case a dash ("-").
	  
	  > Also note that (as of version 1.0.0) boblogistics only has one .png file in *boblogistics/graphics/gui/* *(checkbox.png)*. data = {boblogistics = {graphics = {gui = {},},},} (as above) is therefore synonymous to writing data = {boblogistics = {graphics = {gui = {"checkbox.png",},},},}!
	  
	- The this system for the data table in config.lua may seem overcomplicated. However, especially when resource packs replace a vast number of the games assets, the data table gets really simple. After all, if you wanted to replace all .ogg, .png and .jpg files in factorio/base, you would let the resourcepack know as follows:
		```lua
		data = {
			base = {
				
			},
		}
		```
	  > Thats a pretty short data table considering the hundreds, if not thousands of images/.ogg sound files in *factorio/data/base/* that the resource pack will try to replace! One final reminder, that telling the mod you are replacing every .ogg, .png and .jpg file in *factorio/data/base/*, means you need a replacement for each of these files in the mirrored path in *\_\_texturepackfolder\_\_/data/base/*

**[Back To Top](#texturebase)**

---

### Attributes

**This is not necessary to get your texturepack working**. I recommend reading up on this however if you are intrested in what other things TextureBase can do for you (such as higher res pictures than the original or excluding certain filenames).<br/>
If you are making your first texturepack, I recommend you **[SKIP THIS SECTION](#youre-done)**.<br/>
<br/>
Attributes are effectively custom keywords you can use in the config.lua data table for custom behaviour in terms of which files are retextured & which aren't
```lua
data = {
	base = {
		graphics = {
			entity = {
				attribute_name = attribute_data_table1,
				attribute_name = attribute_data_table2,
				folder1 = folder_content_data_table1,
				folder2 = folder_content_data_table2,
				folder3 = folder_content_data_table3,
				folder4 = folder_content_data_table4,
			},
		},
	},
}
```
> You can see the format of declaring attributes is identical to that of declaring folders in the config.lua data table. YES, this does mean you can't retexture the contents of a folder with the same name as an attribute! Ask the creator of the mod you are retexturing to rename the folder!

Current attributes are:
 - \_\_settings\_\_

<br/>

#### The \_\_settings\_\_ Attribute; Customising What / How the Resource Pack Retextures by Specific Settings

- The use of the \_\_settings\_\_ attribute in the config.lua data table further customizes what/how the resource pack retextures.
- See the below example for one use of \_\_settings\_\_. Here we are retexturing every .png, .jpg and .ogg file in *data/base/graphics*, except for those with "shadow" or "reflection" in their name. This is very useful when you are using a script to modify images in a folder, but are omitting those with a certain string in their name.
	```lua
	data = {
		base = {
			graphics = {
				__settings__ = {
					exclude_names = {"shadow", "reflection"},
				},
			},
		},
	}
	```
  > Think \_\_settings\_\_ as an attribute of all contents within the same folder as itself (in this case the contents of *data/base/graphics*).

- **The Format of the \_\_settings\_\_ Attribute**
	```lua
	name_of_folder_whose_contents_are_affected_by_settings = {
		__settings__ = {
			setting_name_1 = setting_value_1,
				setting_name_2 = setting_value_2,
			setting_name_3 = setting_value_3,
		},
	}
	```
	
- The \_\_settings\_\_ attribute is applied to all files set for retexturing within the folder in which the \_\_settings\_\_ attribute is declared. This means that a folder with undeclared contents (\_\_settings\_\_ does not count), will have its \_\_settings\_\_ attribute applied to all .png, .jpg and .ogg files within it, whereas a folder with declared contents will only have the _\_settings\_\_ attribute applied to these specific subdirectories / images


- **Simple Rules of how \_\_settings\_\_ Attributes work.**
	 
	**1. \_\_settings\_\_ Attributes Apply to all Files inside the Folder / File in Which the Attribute is Declared.**
	  
	Therefore:
	```lua
	data = {
		__settings__ = {
			setting_name_1 = setting_value_1,
		},
		
		base = {
			["example_image.png"] = { },
		},
	}
	```
	has the same result as:
	```lua
	data = {
		base = {
			__settings__ = {
				setting_name_1 = setting_value_1,
			},
			["example_image.png"] = { },
		},
	}
	```
	which has the same result as:
	```lua
	data = {
		base = {
			["example_image.png"] = {
				__settings__ = {
					setting_name_1 = setting_value_1
				},
			},
		},
	}
	```
	In the top 2 examples above, *example_image.png* is in a folder whose \_\_settings\_\_ attribute prescibes for all of the retextured files inside of it have setting_name_1 applied at setting_name_1. In the last example, the \_\_settings\_\_ attribute is directly applied to the image itself (and not the contents of a folder, the image happens to be in).
	Note *example_image.png* does not actually exist in *data/base/*; it only demonstrates how \_\_settings\_\_ attributes are applied to retextured images. setting_name_1 and setting_name_1 are also only placeholders for actual settings (see below)<br/>
	<br/>

	**2. \_\_settings\_\_ Attributes can 'Stack' Up, Down a Path.**
	
	Therefore:
	```lua
	data = {
		__settings__ = {
			setting_name_1 = setting_value_1,
		},
		
		base = {
			__settings__ = {
				setting_name_2 = setting_value_2,
			},
			
			["example_image.png"] = {
				__settings__ = {
					setting_name_3 = setting_value_3,
				},
			},
		},
	}
	```
	has the same result as:
   ```lua
	data = {
		base = {	
			["example_image.png"] = {
				__settings__ = {
					setting_name_1 = setting_value_1,
					setting_name_2 = setting_value_2,
					setting_name_3 = setting_value_3,
				},
			},
		},
	}
	```
	Settings for an image accumulate along its path.<br/>
	<br/>

	**3. \_\_settings\_\_ Attributes can Overwrite each other Down a Path**
	
	Therefore:
	```lua
	data = {
		__settings__ = {
			setting_name_1 = setting_value_1,
		},
		
		base = {
			__settings__ = {
				setting_name_1 = setting_value_2,
			},
			
			["example_image.png"] = {
				__settings__ = {
					setting_name_1 = setting_value_3,
				},
			},
		},
	}
	```
	has the same result as:
	```lua
	data = {
		base = {
			["example_image.png"] = {
				__settings__ = {
					setting_name_1 = setting_value_3,
				},
			},
		},
	}
	```
	setting_name_1 is overwritten down the path towards *example_image.png*.

- Remember the contents of a folder. Folders that do not contain anything (but a \_\_settings\_\_ attribute) have that \_\_settings\_\_ attribute applied to all of the .png, .jpg and .ogg files in it, as a folder with undefined contents means all of its contents have been retextured. A folder with defined contents (other than a \_\_settings\_\_ attribute), will only have these settings applied to its defined contents!

<br/>
<br/>
<br/>

**Setting List**

A list of all accepted parameters in the \_\_settings\_\_ attribute<br/>
Settings are given in the form of *\<setting_name\> = \<setting_type\> (default = \<setting_default\>)*
> Note that to exclude certain images images / folders from a setting defined in a superceding folder, you will have to set the settings in the \_\_settings\_\_ attribute to their defaults
<br/>

- ***exclude_names = list (default = {})***
	```lua
	data = {
		base = {
			graphics = {
				__settings__ = {
					exclude_names = {"*shadow*", "*reflection*", "*mask*", "*particle*", "*fire*", "*.jpg", "hr-accumulator-discharge.png"},
				},
			},
		},
	}
	```
  exclude_names lets you exclude files that would otherwise be included in those to be retextured. This is very useful when you are retexturing via script.<br/>
  
  **e.g. If you Write a Script to Change the Look of every Image in *data/base/graphics/entity/* that Does not Have the Strings "shadow", "reflection" or "mask" in it, You Can Tell the Texture Pack to Retexture all Contents of *data/base/graphics/entity/* except Files Containing "shadow", "reflection" or "mask" in the Following Way:<br/>**
	```lua
	data = {
		base = {
			graphics = {
				entity = {
					__settings__ = {
						exclude_names = {"*shadow*", "*reflection*", "*mask*"},
					},
				},
			},
		},
	}
	```
  > Note the usage of \* surrounding the terms that are not allowed around filenames that would otherwise be retextured. See [Wild Cards](#wild-cards-) why this is necessary in order to exclude files whose names include these strings!

  > **CAVEAT:** exclude_names let you ommit images that contain whatever string you enter! typing in something like "a" WILL exclude all images that contain an a in their name. A "." would ommit all images, as every image has a file format of!<br/>
	It does not matter whether images that are excluded are specified or not!<br/>
	
   **In Spite of Being Manually Specified, *accumulator-shadow.png* and *hr-accumulator-shadow.png* Will not Actually Have their Paths Replaced in data.raw, as They are Excluded by having "shadow" in their Name, and being inside the Entity Directory to which the Setting Attribute containing 'exclude_names = {"shadow", "reflection", "mask"}' is Applied<br/>
	```lua
	data = {
		base = {
			graphics = {
				__settings__ = {
					exclude_names = {"*shadow*", "*reflection*", "*mask*"},
				},
				entity = {
					accumulator = {
						["accumulator-shadow.png"] = { },
						["hr-accumulator-shadow.png"] = { },
					},
				},
			},
		},
	}
	```
  > The above example does not result in any images being retextured. All images specified are excluded by the settings attribute
	
   **Only Images with exclude_names in their Filenames (Name and Format) are Excluded! The Image's Entire Path is not part of its Filename!**
	```lua
	data = {
		base = {
			graphics = {
				__settings__ = {
					exclude_names = {"*entity*"},
				},
				entity = {
					
				},
			},
		},
	}
	```
  > Therefore, this marks all files in *data/base/graphics/entity/* without "entity" in their filename for retexturing! NOT all of the contents of entity are excluded from retexturing, as it is only the filenames that are checked whether they contain "entity", and NOT an images entire path! 
<br/>
	
- ***upscale = int (default = 1)***
	```lua
	data = {
		base = {
			graphics = {
				entity = {
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
				},
			},
		},
	}
	```
   The *upscale* setting allows retextured images to have a higher resolution than their original. *upscale = 2* means that all the retextured files have 2x resolution of their originals, and for the texturepack to account for this in the in-game scaling of the texture.<br/>
   **Note that upscale is somewhat experimental!** You may get a variety of errors when using upscale, such as that below:
   
   ![Factorio Sprite Resolution Error](https://user-images.githubusercontent.com/45295229/95661099-dd0cc400-0b2c-11eb-8ddd-6bc7c613e119.png)
   
	> Feel free to report other errors than this related to texture scaling on the discord @ [https://discord.gg/kC53xn2](https://discord.gg/kC53xn2), but beware these errors are likely caused by restrictions imposed by the Factorio dev team, and are not a mod error.

<br/>
<br/>
<br/>

**Setting Attribute Examples**

- **A Simple Example of Using the \_\_settings\_\_ Attribute:**
	```lua
	data = {
		base = {
			graphics = {
				entity = {
					__settings__ = {
						exclude_names = {"*shadow*", "*reflection*", "*mask*"},
					},
					
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
					character = { },
					car = { },
				},
			},
		},
	}
	```
   1. The .png, .jpg and .ogg contents of *data/base/graphics/entity/accumulator/* are retextured at 2x original resolution as long as their file name doesn't include "shadow", "reflection" or "mask".
   2. The contents of *data/base/graphics/entity/character/* and *data/base/graphics/entity/car/* are retextured at normal resolution as long as their file name doesn't include "shadow", "reflection" or "mask".
	
<br/>

- **A Sophisticated Example of Using the \_\_settings\_\_ Attribute**
	```lua
	data = {
		__settings__ = {
			exclude_names = {"*shadow*", "*reflection*"},
		},
		
		base = {
			graphics = {
				entity = {
					__settings__ = {
						exclude_names = {"*shadow*", "*charge*"}
					},
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
					["acid-projectile"] = {
						["hr-acid-projectile-head.png"] = {
							__settings__ = {
								upscale = 3,
							},
						},
					},
					beacon = {
						
					},
						
					car = {
						
					},		
				},
				terrain = {
						
				},
				technology = {
					
				},
			},
		},
		boblogistics = {
			graphics = {
				
			},
		},
	}
	```

   **No reason to panic; lets walk through this step by step.**
   1. **We are retexturing all .png, .jpg and .ogg files in *data/base/graphics/entity/accumulator/*.**
	  All images retextured that are within the *data/* folder, should not contain "shadow" or "relection" in their name (given in the format of "\<filename\>.\<format\>").
	  However, the *data/base/graphics/entity/* overrides the exlude_names setting, so within *data/base/graphics/entity/* files that include "shadow" or "charge" are excluded.
	  Inside the *data/base/graphics/entity/accumulator/* folder, the upscale setting is set to 2.
	  This means that the textures in *\_\_texturepackfolder\_\_/data/base/graphics/entity/accumulator/* are twice the resolution of those in *factorio/data/base/graphics/entity/accumulator/*, and need to be handled by factorio as such.
	  Therefore, we are retexturing all images in *data/base/graphics/entity/accumulator/*, apart from those including "shadow" or "charge" in their name (in this case *accumulator-charge.png, accumulator-discharge.png, hr-accumulator-charge.png, hr-accumulator-discharge.png, accumulator-shadow.png and hr-accumulator-shadow.png), at 2x the resolution of the images' originals.
   2. **We are also retexturing *data/base/graphics/entity/acid-projectile/hr-acid-projectile-head.png*.**
	  Once again the exclusion of "shadow" and "reflection" for all files in the *data/* folder is overwritten for files in the *data/base/graphics/entity/* folder to exclude files with "shadow" or "charge" in their names.
	  From the folder *data/base/graphics/entity/acid-projectile/* we are retexturing *hr-acid-projectile-head.png*. This file has an upscale of 3 set in its settings (settings in the table of an image, only apply to that image).
	  Since *hr-acid-projectile-head.png* does not include the strings "shadow" or "charge", it is retextured, at 3x original resolution.
   3. **We are also retexturing all .png, .jpg and .ogg files in *data/base/graphics/entity/beacon/* and *data/base/graphics/entity/car/*.**
	  Once again, the exclusion of files containing the strings "shadow" and "reflection" within *data/* is overwritten in *data/base/graphics/* so instead files including "shadow" or "charge" are excluded.
	  Therefore all .png, .jpg and .ogg files, apart from those with "shadow" or "charge" in their name, in *data/base/graphics/entity/beacon/* and *data/base/graphics/entity/car/* are retextured.
	  The upscale setting has not been specified, so the files have their same resolution as their originals.
   4. **We are also retexturing all .png, .jpg and .ogg files in *data/base/graphics/terrain/* and *data/base/graphics/technology/*.**
	  All files in *data/* including strings "shadow" and "reflection" are excluded from those being retextured.
	  The exclude_names setting is not overwritten in a subdirectory in the path of *data/base/graphics/terrain/* or *data/base/graphics/technology/*, so all files from *data/base/graphics/terrain/* and *data/base/graphics/technology/* are retextured apart from those including "shadow" or "reflection" in their name.
   5. **We are also retexturing all .png, .jpg and .ogg files in *data/boblogistics/graphics/*.**
	  All files in *data/* including strings "shadow" and "reflection" are excluded from those being retextured.
	  This is not overwritten, so all contents of *data/boblogistics/graphics/* are retextured that do not include *shadow* or *reflection* in their name.

**[Back To Top](#texturebase)**

---

### Wild Cards (\*)

**This is not necessary to get your texturepack working**. I recommend reading up on this however if you are interested in what other things TextureBase can do for you (such as Wild Cards in directory/fiile names in config.lua data table).<br/>
If you are making your first texturepack, I recommend you **[SKIP THIS SECTION](#youre-done)**.<br/>
<br/>
**Wild Cards increase your flexibility in defining folders to be retextured in the config.lua data table**<br/>

- Wild Cards allow for parts of a string to be unknown, which is denoted by an \* (asterix)<br/>
- Here are some wild card examples:<br/>
    ```lua
    "*" -- the whole name can be anything; all strings are included
    "character*" -- the name must start with "character" and end with an unknown string (which may just be "")
    "*.png" -- the name must end with ".png" with an unknown string before that
    "circuit*-*.png" -- the name must start with "circuit" and end with ".png" in between these, "-" must also be in the name
    "*rocket*1*" -- the "rocket" must be in the name. "1" must also be in the name after rocket
    "water.png" -- just kidding; there is no wild card here. The entire name is known
    ```
- **One Rule:** You **CANNOT** use wild cards in the selection of mod name level directories in the config.lua data table e.g. *data = {\["base\*"] = {}}* is **NOT** allowed<br/>

<br/>
<br/>
<br/>

**Use Cases**

- **Say You Wanted to Retexture all of the Contents of *data/base/graphics/entity/*, but only Upscale the Contents of *data/base/graphics/entity/accumulator*.**
	```lua
	data = {
		base = {
			graphics = {
				entity = {
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
					["*"] = { },
				},
			},
		},
	}
	```
   The above example of default_include does that exact thing!<br/>
   However, as is you would have to write out every folder in *data/base/graphics/entity/* to then specify in *data/base/graphics/entity/accumulator* upscale its contents (with a settings attribute).<br/>
   <br/>
   **See Below the Unpractical Nature of this Approach!**
	```lua
	data = {
		base = {
			graphics = {
				entity = {
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
					["acid-projectile"] = { },
					["acid-splash"] = { },
					["acid-sticker"] = { },
					["artillery-cannon-muzzle-flash"] = { },
					["artillery-projectile"] = { },
					["artillery-turret"] = { },
					["artillery-wagon"] = { },
					["assembling-machine-1"] = { },
					["assembling-machine-2"] = { },
					["assembling-machine-3"] = { },
					beacon = { },
					beam = { },
					["bigass-explosion"] = { },
					["big-electric-pole"] = { },
					["big-explosion"] = { },
					biter = { },
					["blue-beam"] = { },
					["blue-laser"] = { },
					boiler = { },
					bullet = { },
					["burner-inserter"] = { },
					["burner-mining-drill"] = { },
					car = { },
					["cargo-wagon"] = { },
					centrifuge = { },
					character = { },
					["chemical-plant"] = { },
					
					etc -- 'etc' is not valid syntax; this list is just continues for longer and looks reeeaaally unsightly.
					
					
				},
			},
		},
	}
	```
  > the 'etc' is not actual lua syntax; there are many more folders in *data/base/graphics/entity/* that would need to be listed, but the list would be too unsightly.

<br/>
<br/>
<br/>

**Syntax & Examples**

- **Order of Wild Cards in a Table affects How and Which Images are have their Paths Changed to their Retextured Versions<br/>**
	The below example...
	```lua
	data = {
		base = {
			graphics = {
				entity = {					
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
					["*"] = { },
				},
			},
		},
	}
	```
	is **NOT** the same as ...
	```lua
	data = {
		base = {
			graphics = {
				entity = {
				
					["*"] = { },
					
					accumulator = {
						__settings__ = {
							upscale = 2,
						},
					},
				},
			},
		},
	}
	```
	This is because Wild cards sort objects in the order in which they are written in the config.lua data table.<br/>
	
	- **In the first of the 2 code snippets**, when an image in data.raw is found whose path is inside *data/base/graphics/entity/*, the path is checked that the next dirctory down is the *accumulator/* dirctory. If so, the file's path is changed to the retextured file, and data.raw settings are changed to allow the replacement picture to be 1.5x the resolution of the original. Else if the next directory down the path has a name (wild card of "\*" represents an unspecified part of a string), which all directories do, it is loaded without the upscale applied.
	- **In the second of the 2 code snippets**, when an image in data.raw is found whose path is inside *data/base/graphics/entity/*, the path is checked that the next dirctory down has a name (wild card of "\*" represents an unspecified part of a string), which all directories do, it is loaded without the upscale applied. Even files inside the *accumulator/* folder are not upscaled, as the folder name "accumulator" these files are located in matches the "\*" wild card, which in example 2 is queried before the "accumulator" folder.
<br/>

- **A Slightly More Complex Example Involving Wild Cards**
	```lua
	data = {
		base = {
			graphics = {
				achievement = {
					__settings__ = {
						exclude_names = {"*circuit-veteran*", "*computer-age*"},
						upscale = 2,
					},
					["iron-throne-*.png"] = {
						__settings__ = {
							upscale = 1,
						},
					},
					["*"] = {},
				},
				entity = {
					biter = {
						["biter-attack-01.png"] = {
							__settings__ = {
								upscale = 1.5,
							},
						},
						["*"] = {},
					},
					["*"] = {
						__settings__ = {
							upscale = 2,
						},
					},
				},
				["*"] = {},
			},
		},
	}
	```
   **Here the following is happening:**
   1. We are retexturing all the .png, .jpg and .ogg files in *data/base/graphics/*, except from those in *data/base/graphics/achievement/* whose names contain "circuit-veteran" or "computer-age".
   2. All .png, .jpg and .ogg files other than those matching the "iron-throne-\*.png" wildcard in *data/base/graphics/achievement/* are retextured at 2x original resolution.
   3. *data/base/graphics/entity/biter/biter-attack-01.png* is retextured at 1.5x original resolution, whilst all other .png, .jpg and .ogg files in *data/base/graphics/entity/biter/* are retextured at normal resolution.
   4. All .png, .jpg and .ogg in *data/base/graphics/entity/* but not in *data/base/graphics/entity/biter/* are retexture at 2x original resolution. All .png, .jpg and .ogg in *data/base/graphics/* and not in *data/base/graphics/achievement/* or *data/base/graphics/entity/* are retextured at normal resolution.

**[Back To Top](#texturebase)**


---

## You're done!!!

- Congrats! you have created a factorio resource pack with TextureBase!
- There is no obligation to do this, but I would be soooo happy if you spread the word & include e.g. "made with TextureBase @ https://mods.factorio.com/mod/texturebase" in your resource pack description :)
- You might also consider removing / modifying this README.md file along with other github files such as LICENSE from your texturepack.
- If you haven't already, exchange the default thumbnail.png with a texturepack icon of your own (144x144 resolution).
- Next Steps:
	- Upload your creation. You might have to use Gdrive for this, as GitHub and [https://mods.factorio.com/](https://mods.factorio.com/) do not allow uploading a bigger texturepack than 100Mb. You'll likely have to create a placeholder mod on [https://mods.factorio.com/](https://mods.factorio.com/) with a texturepack download link. 
	- Let me check out your texturepack by contacting me via my modding discord @ [https://discord.gg/kC53xn2](https://discord.gg/kC53xn2), or on the dedicated Discussion channel on the TextureBase mod page @ [https://mods.factorio.com/mod/texturebase](https://mods.factorio.com/mod/texturebase)
	- Start over! You can make more than one texturepack (though they can't be loaded at the same time) ;)

**[Back To Top](#texturebase)**

---

## Still having Issues, Bugfixes, Feature Requests

If no error is thrown on startup but your textures have not appeared in-game, first insure your texturepack is enabled in the factorio mod list *cough cough...*.
If so, check the factorio log files (*%AppData%/Roaming/Factorio/factorio-current.log*). If your textures are not in-game & no error is thrown when the game starts, the reason of this is likely logged by your texturepack!

If you are still having issues creating your resourcepack, download my example resourcepacks:
- Shadow World @ [https://drive.google.com/file/d/1bN3yiFb1y8rMiTiCTyGbhklPDw5AfF1K/view?usp=sharing](https://drive.google.com/file/d/1bN3yiFb1y8rMiTiCTyGbhklPDw5AfF1K/view?usp=sharing)
- Hologram World @ [https://drive.google.com/file/d/1jZhFcircOzxt0ejexdXds5Khsw75Vaby/view?usp=sharing](https://drive.google.com/file/d/1jZhFcircOzxt0ejexdXds5Khsw75Vaby/view?usp=sharing)
- Pixel Perfect @ [https://drive.google.com/file/d/14dEJA84MVQ3Z4UhZfryU5rCKtoEiw2hr/view?usp=sharing](https://drive.google.com/file/d/14dEJA84MVQ3Z4UhZfryU5rCKtoEiw2hr/view?usp=sharing)

I tried uploading them to https://mods.factorio.com/ but a 100Mb mod size limit prevented this. Google Drive comes for the rescue!

Should you have skipped the optional sections (*[Wild Cards (\*)](#wild-cards-)* and *[Attributes](#attributes)*) you might want to read up on those.

Also check out my discord @ [https://discord.gg/kC53xn2](https://discord.gg/kC53xn2). Here you can get further help, report bugs, request features and find people to play with!

**[Back To Top](#texturebase)**

---

# License

MIT License

Copyright (c) 2020 Zangeti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**[Back To Top](#texturebase)**
