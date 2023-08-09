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
<!--
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
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>
-->


<!-- ABOUT THE PROJECT -->
## About The Project

<!--[![Product Name Screen Shot][product-screenshot]](https://example.com)-->

Palia Steam Helper is a set of scripts designed to make it as easy as possible to get Palia running on the Steam Deck and Linux.

Why do we need to make it easier?  Well, as of the creation of this project, Palia is currently in Beta, and only officially available for Windows.  However, thanks to the hard work over many years of the Wine and Proton teams, we can still get Palia running on systems that run Linux OS, the Steam Deck is one such system.  Unfortunately, getting games running through Wine/Proton can be a challenge, and getting that working on the Steam Deck and running in Game Mode is a whole extra challenge.

But don't worry, "we got ya fam"(I think thats what the kids are saying these days).

Just head down below, and follow the steps to get playing.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!--
### Built With

* [![Next][Next.js]][Next-url]
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>
-->


<!-- GETTING STARTED -->
## Getting Started

The easiest way to get going is to use the convenient one line command below.

<!--
### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* npm
  ```sh
  curl -L https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main/install_palia.sh | bash
  ```
-->
### Installation

1. Open a terminal in the path you want the game installed to, paste the command below in to a terminal, and execute it.
   ```sh
   curl -L https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main/install_palia.sh | bash
   ```
2. The game should either automatically be added to Steam as palia_steam_helper.sh, or a window will open in Steam to let you manually add the script.
3. Once added to Steam, you need to edit the game, and set it to use "Proton Experimental" as the Compatability tool.
4. Finally, run the game to complete the install process.
https://github.com/t3nk3y/palia_steam_helper/assets/26716328/ed70e830-fea6-4421-80dd-20fdd2b20c8a
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
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/madalee
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com
