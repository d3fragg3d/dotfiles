# Dotfiles

This repository will contain my dotfiles I use on daily. It is new so I will be adding to this over time.

## Installation

Clone the repo to start.

```bash
git clone git@github.com:d3fragg3d/dotfiles.git
```

## Usage
This repository is using stow to handle the placement of the config
So this needs to be installed as a pre-requisite.

```bash
sudo apt install stow
stow -t ~ emacs
```

To remove
```bash
stow -D emacs -t ~
```

## Dependencies
```bash
M-x package-install RET use-package
npm install -g typescript-language-server
```

## Contributing

Pull requests are welcome.

## License

[MIT](https://choosealicense.com/licenses/mit/)
