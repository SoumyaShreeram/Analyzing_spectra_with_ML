## Guide for remomtely connecting to lesta with a graphical interface for running Jupyter Notebooks

1. x2go client, for setup visit [here](https://www.astro.unige.ch/wiki/IT/doc/astroge/connection#Connecting_with_the_X2Go_desktop). *(Note: you will get access to this link with your EPFL username and password)*
2. Open the terminal and type:

	`ssh -XY username@lesta02`

4. For the first time setup, visit [here]() for step-by-step instructions on setting up you Jupyter notebook remotely.

5. For other times, you may proceed as follows:
	* Go to the directory of your notebook

		`cd Code/`

	* Activate your project environment
	
		`source my_project_env/bin/activate`	

	* Lastly, type
	
		`jupyter notebook`	

	  and your good to go!