# FishEnv

Fishshell implementation of the [Virtualenvwrapper](https://virtualenvwrapper.readthedocs.org/en/latest/).

With tab completion!


#### Requisites

* [virtualenv](https://pypi.python.org/pypi/virtualenv)


#### How to install
First download the script to your pc.
````bash
wget https://raw.githubusercontent.com/mbodock/FishEnv/master/fishenv.fish
````
Then source the [file](FishEnv/fishenv.fish) in you config.fish.
That's it.


### Functions

* `mkvirtualenv <env>` Creates a virtualenv in ~/.fishenvs/ which will points to the current directory.
* `rmvirtualenv <env>` Deletes a virtualenv
* `workon <env>` this command will activate the virtualenv and switch to the projects directory.
* `workon_dir <arg>` Changes the directory of the working env or <arg> env.
* `deactivate` Deactivates the current virtualenv.


### Working with Python 3

If you want your VirtualEnv with python 3 just pass the optinal argument `--python=/usr/bin/python3`.
