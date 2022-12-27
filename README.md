# Friday Night Funkin' Burst Engine

## What's going on here?
Pretty much nothing. I'm just making an engine for my own personal use.  
If you want to use it, that's cool. However, I'd suggest just sticking with Psych.

## Can I contribute?
Sure, I suppose so.  
I'll warn you though, I'm a bit territorial, so I may not be so fast to accept any pull requests.

## Why did I make this?
Cause I got bored of Psych and wanted to test myself.

## What's with the name?
Because...

# EVWA
                                                      |
                                                     /|
                                                   ,' |
                                                  .   |
                                                    | |
                                                 ' '| |
                                                / / | |
                       _,.-""--._              / /  | |
                     ,'          `.           | '   ' '
                   ,'              `.         ||   / ,                         ___..--,
                  /                  \        ' `.'`.-.,-".  .       _..---""'' __, ,'
                 /                    \        \` ."`      `"'\   ,'"_..--''"""'.'.'
                .                      .      .'-'             \,' ,'         ,','
                |                      |      ,`               ' .`         .' /
                |                      |     /          ,"`.  ' `-. _____.-' .'
                '                      |..---.|,".      | | .  .-'""   __.,-'
                 .                   ,'       ||,|      |.' |    |""`'"
                  `-._   `._.._____  |        || |      `._,'    |
                      `.   .       `".     ,'"| "  `'           ,+.
                        \  '         |    '   |  ^..~..^       .'  `.
                         .'          '     \  ".  \___/       ,'     \
                                   ,'      |    `..        _,'      /
                                  .        |,      `'----''         |
                                  |      ,"j  /                   | '
                                  `     |  | .                 | `,'
                                   .    |  `.|                 |/
                                    `-..'   ,'                .'
                                            | \             ,''
                                            |  `,'.      _,' /
                                            |    | ^.  .'   /
                                             `-'.' |` V    /
                                                   |      /
                                                   |     /
                                                   |   ,'
                                                    `""
(Burst was my Eevee ^~^)

# Setting up the engine
Set up is pretty much the same as the Base Engine, but with a few exclusions since Newgrounds isn't a concern. You can follow along belong below or with his. It shouldn't matter.

## Dependencies
You'll want to [Install Haxe 4.2.0](https://haxe.org/download/version/4.2.5/) or higher (I'm not sure what was wrong with the Base Engine, but it probably had to do with Polymod, which I don't currently have in use).

After Haxe is up and ready, you'll need to [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/). Just do as that single page says and don't worry about the rest unless you'd like to learn about HaxeFlixel.

Finally, you'll just need to install a few additional libraries. These being:
```
flixel-addons
flixel-ui
hscript
```

To install these, simply open a command line and enter `haxelib install [library]`. For example: `haxelib install flixel-addons`.

Almost there! We just need to download a few git related libraries. There's only a couple steps to do this:
1. Download [git-scm](https://git-scm.com/downloads) and follow their instructions for installation
2. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` in a command line to install Discord RPC

## Ignored Files
For those of you familiar with Ninjamuffin's guide, he required a file called `APIStuff.hx`, but we're not connecting to Newgrounds, so that won't be necessary.

## Compiling the Game
Once all of those dependencies are installed, just open up a command line in the project's directory, run `lime test [target]`, and you're good to go! ... if you're not compiling to desktop, that is.

For that, there's a bit of variation depending on your OS.

**For Linux:** You'll simply need to add `lime test linux`. Pretty straight forward.

**For Windows:** You'll need to install Visual Studio Community 2019. While installing VSC, ignore the options to install any workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
After that is complete, simply run `lime test windows` to compile the game.

**For Mac:** `lime test mac` should work. If not, the internet is your friend.

*Note*: I personally compile to Windows, so as I program, I may create a bit that causes other targets to fail. If you come across an error like this, it would be super helpful if you could report it so that it can be resolved.

# Using the Engine
Right now, I wouldn't suggest using this engine as it's still sort of janky. Once I've got it figured out, I'll make a guide.
