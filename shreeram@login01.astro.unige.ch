{
  "cells": [
    {
      "cell_type": "markdown",
      "source": [
        "# SDSS eBOSS Data \n",
        "## Script on reading and pre-processing data, and generation of a catalogue of desirable galaxy types\n",
        "\n",
        "This script extracts useful data from the spPlate and spAll_redrock fits files, and generates the required training data set.\n",
        "\n",
        "1. **Defining input parameters**\n",
        "2. **Reading and pre-processing the data**\n",
        "3. **Applying selection cuts**\n",
        "5. **Generating the training data set**\n",
        "\n",
        "**Data**: 14th Oct, 2019. <br>\n",
        "**Author**: Soumya Shreeram <br>\n",
        "**Supervised by**: Anand Raichoor <br>\n",
        "**Script adapted from**: S. Ben Nejma\n"
      ],
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    },
    {
      "cell_type": "markdown",
      "source": [
        "## 1. Defining input parameters"
      ],
      "metadata": {}
    },
    {
      "cell_type": "code",
      "source": [
        "# data directory on lesta with all the spAll_redrock files\n",
        "spPlate_dir = r'/hpcstorage/raichoor/spplatelist_v5_13_0/spPlate'\n",
        "spAll_redrock_dir = r'/hpcstorage/raichoor/Catalogs/' \\\n",
        "            'spall_redrock_v5_13_0.valid.fits'"
      ],
      "outputs": [],
      "execution_count": null,
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    },
    {
      "cell_type": "markdown",
      "source": [
        "## 2. Reading the data"
      ],
      "metadata": {}
    },
    {
      "cell_type": "code",
      "source": [
        "def setName(data_dir, plate_mjd):\n",
        "    file_name = '-'+str(plate_mjd)+'.fits'\n",
        "    data_file = os.path.join(data_dir, file_name)\n",
        "    return data_file\n",
        "\n",
        "def readFile(filename):\n",
        "    \"\"\"\n",
        "    Function opens the file\n",
        "    @input filename :: name of the file\n",
        "    \"\"\"\n",
        "    hdu = fits.open(filename)\n",
        "    data = hdu[1].data\n",
        "    hdu.close()        \n",
        "    return data\n",
        "\n",
        "def plateMJD(data):\n",
        "    # defining the PLATE number, p, and MJD, m for all the files\n",
        "    pms = np.array([str(p)+'-'+ str(m) for p, m in zip(data['PLATE'],\n",
        "data['MJD'])])\n",
        "    return pms\n",
        "\n",
        "def uniquePmsProgramme(pms, data):\n",
        "    # selecting only the unique plates-mjd, and find their programmes\n",
        "    pms_unique, idx = np.unique(pms, return_index=True)\n",
        "    prog_unique = data['programname'][idx]\n",
        "    return pms_unique, prog_unique\n",
        "\n",
        "def readSpPlate(data_dir, plate_mjd):\n",
        "    \"\"\"\n",
        "    Function to read the useful headers and data from spPlate fits file\n",
        "    @param place :: 4-digit plate number\n",
        "    @param mjd :: 5-digit MJD\n",
        "    \n",
        "    @returns wavelength, bunit, flux, ivar (refer comments for individual meanings)\n",
        "    \"\"\"\n",
        "    # opens the file\n",
        "    hdu     = fits.open(setName(data_dir, plate_mjd))        \n",
        "    \n",
        "    c0      = hdu[0].header['coeff0']   # Central wavelength (log10) of first pixel\n",
        "    c1      = hdu[0].header['coeff1']   # Log10 dispersion per pixel\n",
        "    npix    = hdu[0].header['naxis1']   # WIDTH (TOTAL!\n",
        "    wavelength    = 10.**(c0 + c1 * np.arange(npix))\n",
        "    bunit   = hdu[0].header['bunit']    # Units of flux\n",
        "\n",
        "    flux    = hdu[0].data               # Flux in units of 10^-17^ erg/s/cm^2^/Ang\n",
        "    ivar    = hdu[1].data               # Inverse variance (1/sigma^2^) for HDU 0\n",
        "    hdu.close()\n",
        "    return wavelength, bunit, flux, ivar"
      ],
      "outputs": [],
      "execution_count": null,
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    },
    {
      "cell_type": "code",
      "source": [
        "# reads the file spAll_redrock and generates arrays of unique plate-MJD and programs\n",
        "data = readFile(filename)\n",
        "pms = plateMJD(data)"
      ],
      "outputs": [],
      "execution_count": null,
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    },
    {
      "cell_type": "markdown",
      "source": [
        "## 3. Applying selection cuts\n",
        "\n",
        "The functions below implement various selection cuts to obtain the desired data. They are summarized below:\n",
        "* Select plates that observe **E**mission-**L**ine type **G**alaxies (ELGs), LRGs, and QSOs\n",
        "* Select wavelength that are common to all plates\n",
        "* Removing sky spectra and certain configurations\n",
        "* Select redshift range (Zspec fibres)"
      ],
      "metadata": {}
    },
    {
      "cell_type": "code",
      "source": [
        "def galaxyType(pms_unique, prog_unique, names, gal_type, num_p):\n",
        "    \"\"\"\n",
        "    Function chooses the file name based of desired galaxy type\n",
        "    @params pms_unique, prog_unique :: unique array of plate nos.-MJD & programmes\n",
        "    @param names :: array of names of the galaxies/programmes to select/de-select\n",
        "    @param gal_type :: string to distinguish the desired operations\n",
        "    @param num_p :: number of plates of each galaxy to select\n",
        "    \n",
        "    @returns sub_plates :: array names of selected plates \n",
        "    \"\"\"\n",
        "    if gal_type == 'ELG': # select ELG plates\n",
        "        sub_plates = np.random.choice(pms_unique[(prog_unique==names[0]) | \\\n",
        "                                    (prog_unique==names[1])],size=num_p).tolist()\n",
        "    elif gal_type == 'LRG+QSO': # select LRG+QSO plates\n",
        "         sub_plates = np.random.choice(pms_unique[(prog_unique==names[0]) & \\\n",
        "                                            (prog_unique!=names[1]) & \\\n",
        "                                            (prog_unique!=names[2])],size=num_p).tolist()\n",
        "    else: # select boss plates\n",
        "        sub_plates = np.random.choice(pms_unique[(prog_unique==names[0])],size=num_p).tolist()\n",
        "    return sub_plates\n",
        " \n",
        "def selectPlates(pms_unique, prog_unique, num_pl):\n",
        "    \"\"\"\n",
        "    Function the selects plates containing ELGs, LRG+QSOs, and some random.\n",
        "    @param pms_unique :: arroy of plate nos. and MJDs\n",
        "    @param prog_unique :: list of unique programmes (eBoss/Boss)\n",
        "    @param num_pl :: number of plates of each category to select\n",
        "    \n",
        "    @returns selected_plates :: array of the file names containing desired galaxies\n",
        "    \"\"\"\n",
        "    selected_plates = []\n",
        "    \n",
        "    # select 4 eboss ELG plates\n",
        "    names_elg = ['ELG_NGC', 'ELG_SGC']\n",
        "    selected_plates += galaxyType(pms_unique, prog_unique, names_elg, 'ELG', num_pl)\n",
        "    \n",
        "    # select 4 eboss LRG+QSO plates\n",
        "    names_lrgQso = ['eboss', 'ELG_NGC', 'ELG_SGC']\n",
        "    selected_plates += galaxyType(pms_unique, prog_unique, names_lrgQso, 'LRG+QSO', num_pl)\n",
        "    \n",
        "    # select 4 random boss plates\n",
        "    names_boss = ['boss']\n",
        "    selected_plates += galaxyType(pms_unique, prog_unique, names_boss, 'boss plates', num_pl)\n",
        "    \n",
        "    return selected_plates\n",
        "\n",
        "def writeToFile(pms, outfilename, selected_plates):\n",
        "    \"\"\"\n",
        "    Function extracts the info from desired files and writes to a new file\n",
        "    @param pms :: complete array of plate nos. and MJD\n",
        "    @param outfilename :: output file name\n",
        "    @param selected_plates :: array of all the selected plates\n",
        "    \"\"\"    \n",
        "    # extract those plate-mjd files\n",
        "    extract_files = np.in1d(pms, selected_plates)\n",
        "    \n",
        "    # write info to new fits file\n",
        "    hdu[1].data = hdu[1].data[extract_files]\n",
        "    return hdu.writeto(outfilename, overwrite=True)\n",
        "\n",
        "def discardSkySpectra(data):\n",
        "    data = data[(data['ZWARN'] == 0) & \\\n",
        "                (data['OBJTYPE'] != 'SKY') & \\\n",
        "                (data['CHI2']/data['NPIXELS'].astype(float) > 0.4) & \\\n",
        "                (data['DELTACHI2']/data['NPIXELS'].astype(float) > 0.0025)]\n",
        "    print('ZWARN != 0, Sky and other factors taken out')\n",
        "    return data\n",
        "\n",
        "def selectWavelengths(pms_unique, spPlate_dir, plate_mjd):\n",
        "    wavelength_idx = [];\n",
        "    \n",
        "    for idx, pm in enumerate(pms_unique)\n",
        "        wavelength = readSpPlate(spPlate_dir, pm)[0]        \n",
        "        \n",
        "        if idx = 0: # for the first spPlate file\n",
        "            wavelength_idx.append(np.arrange(len(wavelength)))\n",
        "        else: \n",
        "            intersection, idx1, idx2 = np.intersect1d(wavelengths, wave, \\\n",
        "                                                      return_indices=True)\n",
        "        \n",
        "    return"
      ],
      "outputs": [],
      "execution_count": 10,
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    },
    {
      "cell_type": "code",
      "source": [
        "# sky spectra and other factors taken out\n",
        "data_i = discardSkySpectra(data)\n",
        "pms_i = plateMJD(data_i)\n",
        "\n",
        "# find unique pms, programmes\n",
        "pms_unique, prog_unique = uniquePmsProgramme(pms_i, data_i)\n",
        "\n",
        "# select plates containing ELGs, LRGs, QSOs, and some boss plates\n",
        "selected_plates = selectPlates(pms_unique, prog_unique, num_pl)\n",
        "\n",
        "# write the info to a new file\n",
        "writeToFile(pms, outfilename, selected_plates)\n",
        "\n# wavelength file"
      ],
      "outputs": [],
      "execution_count": null,
      "metadata": {
        "collapsed": false,
        "outputHidden": false,
        "inputHidden": false
      }
    }
  ],
  "metadata": {
    "kernel_info": {
      "name": "python3"
    },
    "language_info": {
      "name": "python",
      "version": "3.7.0",
      "mimetype": "text/x-python",
      "codemirror_mode": {
        "name": "ipython",
        "version": 3
      },
      "pygments_lexer": "ipython3",
      "nbconvert_exporter": "python",
      "file_extension": ".py"
    },
    "kernelspec": {
      "name": "python3",
      "language": "python",
      "display_name": "Python 3"
    },
    "nteract": {
      "version": "0.12.3"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 4
}