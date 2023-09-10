<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
<!--[![MIT License][license-shield]][license-url]-->
![](https://dcbadge.vercel.app/api/shield/272600091901165569)



<!-- PROJECT LOGO -->
<br />
<div align="center">
<!--
  <a href="https://github.com/t3nk3y/palia_steam_helper">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>
  -->

<h3 align="center">Palia Steam Helper</h3>

  <p align="center">
    Let's make it easy to play Palia on the Steam Deck(and Linux)
    <!--
    <br />
    <a href="https://github.com/t3nk3y/palia_steam_helper"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/t3nk3y/palia_steam_helper">View Demo</a>
    ·-->
    <a href="https://github.com/t3nk3y/palia_steam_helper/issues">Report Bug</a>
    ·
    <a href="https://github.com/t3nk3y/palia_steam_helper/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <!--<li><a href="#acknowledgments">Acknowledgments</a></li>-->
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## About The Project

<!--[![Product Name Screen Shot][product-screenshot]](https://example.com)-->

Palia Steam Helper is a set of scripts designed to make it as easy as possible to get Palia running on the Steam Deck and Linux.

Why do we need to make it easier?  Well, as of the creation of this project, Palia is currently in Beta, and only officially available for Windows.  However, thanks to the hard work over many years of the Wine and Proton teams, we can still get Palia running on systems that run Linux OS, the Steam Deck is one such system.  Unfortunately, getting games running through Wine/Proton can be a challenge, and getting that working on the Steam Deck and running in Game Mode is a whole extra challenge.

But don't worry, "we got ya fam"(I think thats what the kids are saying these days).

Just head down below, and follow the steps to get playing.
<br>(**You don't need to download anything from this Github page, the command in the installation section will do that for you.**)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

The easiest way to get going is to use the convenient one line command below.
<br>**Note: You don't need to download anything from Github.**  The command below will handle that for you.

### Installation

1. Open a terminal in the path you want the game installed to, paste the command below in to a terminal, and execute it.
<br>(**You don't need to download anything from this Github page, the below command will do that for you.**)
    ```sh
    curl -L https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main/install_palia.sh | bash
    
    ```
    <details>
    <h4>Experimental</h4>
    <summary>The experimental version of the installer has been merged in to the main script.</summary>
    </details>

2. The game should either automatically be added to Steam as palia_steam_helper.sh, or a window will open in Steam to let you manually add the script.
3. Once added to Steam, you need to edit the game, and set it to use "Proton Experimental" as the Compatability tool.
4. Finally, run the game to complete the install process.

https://user-images.githubusercontent.com/t3nk3y/palia_steam_helper/assets/26716328/ed70e830-fea6-4421-80dd-20fdd2b20c8a.mp4

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
<!--
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>
-->


<!-- ROADMAP -->
## Roadmap

- [x] Single, simple, pasteable command to perform the setup process.
- [x] Single script to add to Steam with very minor user intervention required.
- [x] Only use tools that come with the Steam Runtime environment.
- [x] Automatically prepare game requirements in the Wine/Proton environment.
- [x] Provide a GUI to show install progress.
- [x] Skip EULA screen to workaround extremely glitchy issues when accepting EULA.
- [x] GUI screen to tell user they must agree to the EULA and TOS if they use the script.
- [x] Install all game files to the same path as the script, to simplify location selection.
- [x] Provide some graphics assets for Steam to use.
- [ ] Text/gif tutorial for install.
- [ ] Text/gif tutorial for setting images manually.
- [x] Create basic demo video.
- [ ] Create basic how-to video.
- [ ] Create detailed how-to video, including explaination of entering desktop mode and using deck controls.
#### Stretch goals
- [ ] Improve installer so it can automatically:
    - [ ] Add the game to steam.
    - [ ] Set the game's compatability tool.
    - [ ] Set the game's name.
    - [ ] Set all of the images for the game.
    - [ ] Import a custom controller scheme.
- [ ] Create a flatpak and add to flathub so users can simply install from Discover.
- [ ] Make everything more robust

See the [open issues](https://github.com/t3nk3y/palia_steam_helper/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License
¯\\_(ツ)_/¯
Don't sell it, I guess.  Abide by the EULA and TOS provided by Singularity 6 for Palia.
<!--Distributed under the MIT License. See `LICENSE.txt` for more information.-->

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Madalee - [discord](https://discordapp.com/users/madalee)

Project Link: [https://github.com/t3nk3y/palia_steam_helper](https://github.com/t3nk3y/palia_steam_helper)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Further Details

Below is a, potentially overly, in-depth explaination of everything these scripts do.
<br>It's intended for anyone who is interested in the nitty-gritty, and isn't needed for anyone who just wants to play the game.

The entire process consistes of a few commands/scripts

- a single bash command:
  ```bash
  curl -L https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main/install_palia.sh | bash
  ```
  This uses curl(a command line based http downloader) to download the install_palia.sh script and passes the content of the file to bash(a command interpreter, one of the most common used in linux)
  
- install_palia.sh
  <br>This bash script does a few things:
  - Checks to see if it's in your home directly, if so, it tells you not to run it from your home directory and quits
  - Checks if you already have palia_steam_helper:
    - if you do, it updates it to the latest version, then quits
    - If you dont, it downloads it, then tries to add it to Steam as a non-steam game for you, by using the xdg-open(tell X-windows environments to open a webpage in the default browser) command combined with a steam:// URL.  However, as this feature of Steam seems to be broken in the newer versions, it will likely just open the "Add a non-steam game" for you.
    - If it fails to even get the "Add a non-steam game" to open, it will let you know
  - Walks you through selecting the right file in steam, renaming the shortcut, and setting it to use the right Proton mode.
  
- palia_steam_helper.sh
  <br>This is the main script, and the one you run from Steam, each time.  Even though it ends in .sh, it's actually a Python script.  It only ends in .sh because Steam will not show it by default if it doesn't end in an extension it's expecting.
  <br>It does the following:
  - Changes the location of where the Proton prefix will be placed so it gets put in the same directory as the script, in a subdirectory called "steam".  This simplifies the process of letting the user decide where they want the game installed(such as on the main drive vs SD card), and makes it a lot easier to find the game files in the future, vs being stored deep, in a hidden folder under steams stuff in the users home directory under some random numbered folder.
  - Sets several Proton/Wine/DXVK/GPU environment variables intended to improve performance.(mostly related to shader caching)
    - DXVK_CONFIG_FILE - Set to script directory/dxvk.conf for convenience
    - DXVK_HUD - Set to show "Compiling Shaders" message when doing so(maybe it doesnt work with DX12)
    - DXVK_STATE_CACHE_PATH - Set DXVK state cache to subdirectory of script directory
    - VKD3D_SHADER_CACHE_PATH - Set VKD3D shader cache to subdirectory of script directory
    - __GL_SHADER_DISK_CACHE_PATH - Set GL shader cache to subdirectory of script directory
    - __GL_SHADER_DISK_CACHE - Enable GL Shader disk cache(likely on by default anyway)
    - __GL_SHADER_DISK_CACHE_SKIP_CLEANUP - Keep the GL shader cache between launches
    - STAGING_SHARED_MEMORY - Enable staging shared memory
    - DXVK_ASYNC - Enable DXVK async shader compile (may be default, and deprecated)
    - RADV_PERFTEST - Enable Radeon shader cache and async shader compile
    - mesa_glthread - Enable mesa based async shader compile (Intel only I think)
    - PROTON_NO_FSYNC - Disable FSYNC, it seems to mess things up
    - If this is a SteamDeck:
      - Put the shader caches on the root drive(not the current directory) as it should be the fastest drive in the system
      <br>Placed in /home/user/.cache/Palia
  - Checks if the PaliaLauncher.exe is already installed in the right place
    <br>(We are assuming if the file is there, Palia is already fully installed):
    - If it isn't, do the following for initial install:
      - Download the latest Palia patch manifest, and get the following from it:
        - What is the newest patch version
        - What is the URL for the base game zip
      - Download VCRedist 2022 (required by Palia)
      - Download PaliaLauncher.exe
      - Download base Palia game zip
      - Make a steam folder under the same folder as a the script
      - Make a pfx folder for the Wine/Proton prefix under the steam folder
      - Make the full folder structure for Palia up to drive_c/users/steamuser/AppData/Local/Palia/Client
      - Extract the base Palia zip to the Client folder
      - Create a registry file to tell Palia that UE and Palia are installed in the correct paths
      - Create a bat file to import the registry file and to query the registry to make sure the changes stick
      - Run the bat file
        <br>This step is what actually initializes the prefix
      - Install VCRedist 2022 in the prefix
      - Cleanup all temp files(eg, registry, batch script, zip files, etc...)
      - Make the Palia Downloads folder next to the Client folder, as it is requires for PalaiaLauncher.exe to run
      - Place PaliaLauncher.exe where it belongs
        <br>drive_c/users/steamuser/AppData/Local/Palia/Launcher/PaliaLauncher.exe
  - Launch PaliaLauncher.exe 
  


<!-- ACKNOWLEDGMENTS -->
<!--
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>
-->


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/t3nk3y/palia_steam_helper.svg?style=for-the-badge
[contributors-url]: https://github.com/t3nk3y/palia_steam_helper/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/t3nk3y/palia_steam_helper.svg?style=for-the-badge
[forks-url]: https://github.com/t3nk3y/palia_steam_helper/network/members
[stars-shield]: https://img.shields.io/github/stars/t3nk3y/palia_steam_helper.svg?style=for-the-badge
[stars-url]: https://github.com/t3nk3y/palia_steam_helper/stargazers
[issues-shield]: https://img.shields.io/github/issues/t3nk3y/palia_steam_helper.svg?style=for-the-badge
[issues-url]: https://github.com/t3nk3y/palia_steam_helper/issues
[license-shield]: https://img.shields.io/github/license/t3nk3y/palia_steam_helper.svg?style=for-the-badge
[license-url]: https://github.com/t3nk3y/palia_steam_helper/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png
