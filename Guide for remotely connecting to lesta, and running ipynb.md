## Guide for remomtely running Jupyter Notebooks on lesta

1. ssh into your login01.astro.unige.ch account

2. In the terminal and type:

	`ssh -XY lesta01`

3.  Go to the directory of your .ipynb notebooks, in my case:

	`cd Code/`

4.  You will need to create a virtual environment to get rights to download python packages. You can look up online on how to create a virtual environment (here, called `my_project_env`). The packages required to run notebook 02, include *astropy, matplotlib, numpy* that can be installed using pip **after** activating your virtual environment:
	
	`source my_project_env/bin/activate`	

5. Lastly, your jupyter notebook will open in the browser of your `lesta01` account, so type

	`firefox`

	This will pop up a firefox browser. We now want to run the notebook in the same session so **press Ctrl+z** to put firefox into the backgroound and type

	`bg %1 `

6.  Finally, type

	`jupyter notebook`	

	This will generate a localhost/ip link that you can copy-paste in the firefox browser and your directory, with the notebooks that it contains, will show up.


### Copying your remotely generated data files locally

* For copying a file from remote -> local:

	`scp username@login01.astro.unige.ch:/home/epfl/username/ /path/on/local/computer/filename`

	Note: if it is an entire directory add **`-r`** after the `scp`.

* If you are uploading a file from your local computer onto the remote desktop:

	`scp /path/on/local/computer/filename username@login01.astro.unige.ch:/home/epfl/username/path/ ` 

* If it is a file from local to remote desktop, reverse the order.	