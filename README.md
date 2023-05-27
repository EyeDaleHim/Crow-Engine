Crow Engine
======

![Size](https://img.shields.io/github/repo-size/EyeDaleHim/Crow-Engine?style=flat-square)
[![Contributor Covenant](https://img.shields.io/twitter/url?label=Crow%20Engine&style=social&url=https%3A%2F%2Ftwitter.com%2FCrow-Engine)](https://twitter.com/CrowEngineFNF)

![Crow Engine](crow_engine_logo.png)

## Info

Crow Engine is a modified version of the game Friday Night Funkin' that has been rebuilt to include comprehensive documentation for modding and to introduce new features. The primary goal of this project is to facilitate a clearer understanding of modding for players and developers.

### Mods currently using Crow Engine

* Chill-Sides
* Undertale Mix Mod (Hypno's Lullaby Cover Mod)
* Mechanics Mod (partially)

## Notes

The only official websites for Crow Engine are [GitHub](https://github.com/EyeDaleHim/Crow-Engine), [GameBanana](https://gamebanana.com/mods/431880), and [Twitter](https://twitter.com/CrowEngineFNF).

## Credits

The following have contributed to Crow Engine.

* [EyeDaleHim](https://linktr.ee/eyedalehim) - Lead Maintainer & Owner of Crow Engine

* [SwickTheGreat](https://weldedflap.carrd.co/) - Major Contributor

* [AmeliaTheSharmi](https://www.youtube.com/@AmeliaTheSharmi) - Logo Artist

### Honorable Mentions
* [Rapper GF](https://twitter.com/Rapper_GF_Dev) - Circular Buffer Suggestion

* **Cherry** - Circular Buffer improvements

<details>
    <summary><h2>Building Instructions</h2></summary>
    <p>Select the platform you want to compile on and follow the instructions.</p>
<details>
    <summary><h3>Windows</h3></summary>

1. Install the latest version of [Haxe](https://haxe.org/download/).
2. Download the [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe).
3. Wait for the installer to install any necessary information.
4. Once everything has installed, select the `Individual components` tab.
5. Select these two components:
    - MSVC v142 - VS 2019 C++ x64/x86 build tools (v14.29-16.11)
    - Windows 10/11 SDK (Any Version)
6. Hit install and wait for the components to install. Once finished, close out of the build tools.
7. Download and install [Git SCM](https://git-scm.com/download/win). Do not change any installation options, just leave them as is.
8. Navigate to and open your Crow Engine folder. Once in the folder, double-click the `update.bat` file to open it and install the necessary libraries to compile the engine.
9. After the libraries have been installed, the command prompt should close. Next, click the `File` button at the top-left of your screen. Select `Open Windows PowerShell`.
10. In the PowerShell window, type `lime build windows` and hit enter. This will start building the game. This will also take a bit of time if you are compiling for the first time.
11. Navigate to `export/release/windows/bin` to find and open the executable.
    - If you want to save yourself some time, run `lime test windows` in the prompt to open the game right after compilation.
</details>

<details>
    <summary><h3>MacOS</h3></summary>

1. Install the latest version of [Haxe](https://haxe.org/download/).
2. Download and install [Xcode](https://developer.apple.com/xcode/).
3. Download and install [Git SCM](https://git-scm.com/download/mac). Do not change any installation options, just leave them as is.
4. Navigate to and open your Crow Engine folder. Once in the folder, double-click the `update.sh` file to open it and install the necessary libraries to compile the engine.
5. After the libraries have been installed, the terminal should close. Open a new terminal and set the directory to your Crow Engine folder. This can be done by entering `cd [CROW ENGINE FOLDER PATH]`.
6. Once you have set the directory to your Crow Engine folder, type `lime build mac` and hit enter. This will start building the game. This will also take a bit of time if you are compiling for the first time.
7. Navigate to `export/release/mac/bin` to find and open the application.
    - If you want to save yourself some time, run `lime test mac` in the prompt to open the game right after compilation.
</details>

<details>
    <summary><h3>Linux</h3></summary>

1. Install the latest version of [Haxe](https://haxe.org/download/).
2. Install `G++`. If you already have it on your device, you can skip this step.
    - There are many tutorials online and the installion should not be too hard.
3. Download and install [Git SCM](https://git-scm.com/download/linux). Do not change any installation options, just leave them as is.
4. Navigate to and open your Crow Engine folder. Once in the folder, double-click the `update.sh` file to open it and install the necessary libraries to compile the engine.
5. After the libraries have been installed, the terminal should close. Open a new terminal and set the directory to your Crow Engine folder. This can be done by entering `cd [CROW ENGINE FOLDER PATH]`.
6. Once you have set the directory to your Crow Engine folder, type `lime build linux` and hit enter. This will start building the game. This will also take a bit of time if you are compiling for the first time.
7. Navigate to `export/release/linux/bin` to find and open the application.
    - If you want to save yourself some time, run `lime test linux` in the prompt to open the game right after compilation.
</details>
</details>