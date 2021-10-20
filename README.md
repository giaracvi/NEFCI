# Neuro-inspired edge feature fusion using Choquet integrals (NEFCI)

This repository contains all the code and results of the paper entitled "Neuro-inspired edge feature fusion using Choquet integrals" published in the journal Information Sciences.

Paper link to [Publisher site](https://www.sciencedirect.com/science/article/pii/S0020025521010240?via%3Dihub).

authored by

C. Marco-Detchart, G. Lucca, C. Lopez-Molina, L. De Miguel, G. P. Dimuro and H. Bustince.

Corresponding author: Cedric Marco-Detchart (cedric.marco@unavarra.es)

--------------------------------------------------------------------------------

The article can be found in PDF format here, as the file **"Neuro-inspired-edge-feature-fusion-using-Choquet-integrals.pdf"**.

--------------------------------------------------------------------------------

## Source code

**Prerequisites**: The KITT (Kermit Image Toolkit) collection is needed for this project to work. The folders needed are loaded in **"setup.m"** file, where paths can be configured. Please download the files from [KITT repository](https://github.com/giaracvi/KITT).

To execute the experiment, run the file **"superLauncher.m"** where the OS (win, mac, linux) must be chosen in order to build the correct path syntax.

The parameters configuration is located in the file **"infoMaker.m"**. The source and data paths must also be configured according to your folders location.

Each one of the phases of the experiment is located in one file, as follows:

- **"smMaker.m"** contains the procedure to apply a smoothing technique to an image, taking all the parameters from configuration file.

- **"ftMaker.m"** is responsible for extracting the feature images based on given parameters.

- **"bdryMaker.m"** takes a feature image and extracts boundary image so that they can be compared to ground truth.

- **"cpMaker.m"** computes the comparison of a boundary image with its ground truth giving statistical results (Prec, Rec and F_0.5 measure).

- **"cpCollecter.m"** takes individual statistical results and collects them all in order to have a global result of the dataset

- **"aioMakerClassic.m"** contains all of the instructions of the previous files in order to process the dataset images with the classical methods to whom we compare.

- **"aioMaker.m"** contains all of the instructions of the previous files in one script.

- **"aioMakerSelection.m"** permit to execute the experiment all at once with a selected list of specific parameters.

- **"README.md"** this file.

--------------------------------------------------------------------------------

## Results

You will find the file **"Results-Choquet-generalizations-edges.xlsx"** containing the complete experimental results done for testing our proposal. The file presents the Choquet generalization used, with its corresponding function/s along with the exponent of the power measure. For each combination a series of statistical results is shown (Prec, Rec and F_0.5 measure).

## Citation

If you use this code and/or article in your research, please cite as:

```bibtex
@article{MARCODETCHART2021,
    title = {Neuro-inspired edge feature fusion using Choquet integrals},
    journal = {Information Sciences},
    volume = {581},
    pages = {740-754},
    year = {2021},
    issn = {0020-0255},
    doi = {https://doi.org/10.1016/j.ins.2021.10.016},
    url = {https://www.sciencedirect.com/science/article/pii/S0020025521010240},
    author = {Cedric Marco-Detchart and Giancarlo Lucca and Carlos Lopez-Molina and Laura De Miguel and Graçaliz Pereira Dimuro and Humberto Bustince},
}
```
