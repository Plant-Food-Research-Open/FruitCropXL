# Functional-structural-fruit-crop model

Corresponding and main author: Junqi Zhu, junqi.zhu@plantandfood.co.nz
Contributors: James Bristow, Ou-An Chuang, Xiumei Yang, Anand Rampadarath, Francisco Rojo,Stephen Bell,
			Jochem Evers, Zhanwu Dai, Philippe Vivin, Gregory A. Gambetta, Michael Henke, 
			Ella Johnson, Alla Seleznyova, Aarthy Badrakalimuthu,Gaetan Charles Valère Heidsieck, 
			Damian Martin, Stewart Field


FruitCropXL, a generic functional–structural model tailored for Fruit Crops, was developed using the latest GroIMP modelling platform (ongoing development) based on the eXtended L-system and relational growth grammar language (Hemmerling et al., 2008; Kniemeyer, 2008). FruitCropXL conceptualizes plants as collections of objects including buds, flowers, fruits, leaves, internodes, fine roots, and structural roots, complemented by classes such as Phenology, Environment, and Resource Arbitrator (Zhu et al., 2018). Users can freely configure which objects to use and add into the initial condition.


### Model Execution Sequence

1. **Initiation**: Begins by loading the model options file, along with all corresponding parameters and initial objects and their conditions.
2. **State Variable Update**: Updates state variables of the objects through the execution of various methods, reflecting changes in environmental and physiological conditions.
3. **Organ Development**: If dynamic growth is enabled, the model progresses by developing new organs as specified by the growth parameters.

### Physiological Processes

- **Radiation Interception**: The GroIMP platform's radiation model simulates light distribution and absorption based on the optical properties of plant organs (Hemmerling et al., 2008). This model considers the number, placement, and intensity of light sources, as well as the direction, absorption, reflection, and transmission of light rays across plant organs. Radiation interception is computed once per simulation step, capturing local absorption by all plant organs in the scene. Users can select from various light types, including spectral, directional, spotlight, and customizable physical light sources. In this model, an array of 72 directional lights represents diffuse radiation, and a moving directional light source simulates direct sunlight, with its position adjusted for day length, azimuth, and solar angle based on Reda and Andreas's (2004) solar positioning algorithm using the Java solar position package (Brunner, 2024). Clear-sky direct, diffuse, and near-infrared intensities are calculated using the REST-2 model (Gueymard, 2008), with diffuse radiation fractions refined by the hourly global-to-theoretical clear-sky radiation ratio (Erbs, 1982). The platform provides both CPU- and GPU-based light models, enabling spectral simulations and allowing the representation of near-infrared light as the green channel for enhanced wavelength differentiation.
  
- **Leaf Gas Exchange and Water Transport**: The model integrates an extended Farquhar, von Caemmerer, and Berry (FvCB) module for calculating potential photosynthesis, transpiration, leaf temperature, and stomatal conductance under various atmospheric conditions (Yin and Struik, 2009), along with a Tardieu–Davies water transport module. This transport model simulates water movement from soil to roots, through the xylem, and along internodes to leaves, using an electrical resistance analogy and variable hydraulic conductance to calculate water potential across organs (Tardieu et al., 2015; Zhu et al., 2021). The modules are dynamically integrated: the FvCB module provides the Tardieu–Davies module with potential stomatal conductance and transpiration. In turn, the Tardieu–Davies module supplies the FvCB module with adjusted stomatal conductance and transpiration rates, calculated via a numerical solver balancing water flux with adjusted leaf transpiration. Users can choose stomatal conductance adjustments based solely on leaf water potential or additionally on xylem ABA concentration. This feedback allows recalculation of leaf temperature and photosynthesis based on actual transpiration rates.
  
- **Carbon Allocation**: The model includes two carbon allocation approaches: a common assimilate pool model and a phloem carbohydrate transport model (Zhu et al., 2021). In the assimilate pool model, carbohydrates from leaves, stems, and roots are loaded into the phloem and translocated to sink organs based on unloading capacities, assuming an equilibrium of loading and unloading rates for each time step (Baldazzi et al., 2013). The phloem/xylem coupled carbon transport mechanism, implemented in FruitCropXL, combines analytical and computational techniques, modeling plant structure at the metamer level with internodes as conduits and lateral organs as sources and sinks. This approach allows detailed carbon transport simulations, with transport equations solved analytically and iteratively refined to account for concentration-dependent sink and source activity (Seleznyova and Hanan, 2018).

- **Organ Development**: The model uses the phytomer—comprising an internode, leaf, flower or fruit, and lateral buds—as the basic shoot architecture unit. Developmental processes vary by species, such as apple and grape, and are customized to their growth patterns. In FruitCropXL, buds initiate various shoot apexes based on bud type and environmental triggers for bud break, leading to the development of flowers, rosette leaves, or lateral shoots. Flowers and early fruitlets are grouped post-flowering to optimize carbohydrate tracking and transfer efficiency during cell division (Genard and Fishman, 1998). After a set period, flowers reclassify as fruit organs, activating the virtual fruit model to perform hourly sugar and water uptake calculations.
  
- **Organ Growth**: Organ growth can be controlled by several options: temerature, water potential and carbohydrate. Nitrogen effect is under development.

[![Validation testing](https://github.com/PlantandFoodResearch/functional-structural-fruit-crop-model/actions/workflows/validation-test.yml/badge.svg)](https://github.com/PlantandFoodResearch/functional-structural-fruit-crop-model/actions/workflows/validation-test.yml)

## model documentation

Documentation for the model can be found in the confluence page. This contains the description of each main module following the ODD (Overview, Design concepts, Details) protocol for agent-based models, model input preparation, model output variables, and general  instructions for running the model:
<https://plantandfood.atlassian.net/wiki/spaces/MAS/pages/2608988221/Model+documents>

In addition, more details of the code structure, classes and methods can be found at auto-generated documentation:
<https://ubiquitous-memory-3f497b35.pages.github.io/inherits.html>

## Updating Model Settings and Simulation Scenarios

This section guides you through selecting and applying simulation scenarios in the `globalParameters.rgg` file to adapt the model to various growth conditions and functionalities.

### Selecting a Scenario File

Begin by choosing an appropriate scenario file for your simulation:

- **Pre-exploration**: Prior to selection, you may wish to review the scenario file's contents with a text editor. This preliminary step enables an understanding of the different functionalities available for simulation.

## FruitCropXL Enhancements

Over time, we have enhanced **FruitCropXL** with a robust modularization framework that enables toggling between different species (e.g., grapevine and apple), module versions (simple or complex for roots and other components), and functionalities such as advanced light interception and carbon transport. This flexible framework allows users to customize simulations ranging from a single organ to an entire plant, and from an hour to an entire season, all through a single configuration file. The model supports both static and dynamic canopy architecture scenarios, accommodating various canopy and root architectures. These can be integrated either through CSV files from our newly developed shoot and root architecture generators or directly coded types within the model itself.

### Understanding the Scenario File

**FruitCropXL** has undergone extensive enhancements to support a wider range of growth conditions and functionalities. Users now have the flexibility to simulate with:

# Module Configuration

### Special Scenarios

Configure and manage specialized simulation setups. Options include:

- **Fruit-only simulations**: Simulate a fruit population without plant architecture.
- **Custom plant architecture**: Design and test unique plant structures.
- **Single-element focus**: Isolate and simulate individual elements like a single leaf or root system.

### Species-Specific Modules

Load tailored modules designed for specific species, such as complex berry or virtual fruit modules, to enhance simulation accuracy for each type of plant or crop.

### Initiation Methods

Configure initial setups based on specific training systems, plant species, planting densities, and growth scenarios to ensure realistic starting conditions for simulations.

### File-Based Configuration

Use configuration files to specify initial conditions and parameters:

- **Plant parameters**: Base characteristics for the plant model.
- **Soil parameters** (optional): Set up soil conditions when using soil-based modules.

# Module Choices

### Fruit Model Options

- **UseComplexBerry**: Determines the complexity of the fruit model.
  - **True**: Activates the complex fruit module.
  - **False**: Uses the simple fruit module.
- **UseVirtualFruit**: Sub-option of `UseComplexBerry` (only relevant if `UseComplexBerry` is set to true).
  - **True**: Uses the Virtual Fruit jar package within the complex fruit model.
  - **False**: Employs a customized fruit module.

### Soil Model Configuration

- **UseComplexSoil**: Controls soil model complexity.
  - **True**: Activates a detailed 3D soil grid.
  - **False**: Uses a simpler, layered soil representation.

### Root Architecture Options

- **UseComplexRoot**: Determines the root model complexity.
  - **True**: Activates a complex 3D root architecture.
  - **False**: Uses simple layered root objects.

### Leaf Structure Options

- **UseComplexLeaf**: Sets the complexity of leaf representation.
  - **True**: Utilizes a multi-facet leaf structure where several facets form a whole leaf.
  - **False**: Uses a single, large individual leaf in a 3D shape.

# Model Functionality

### Thermal Units

Determine different thermal time calculations, such as growing degree days or thermal optimal days.

### Potential Growth

Calculate potential organ growth based on thermal time increments without considering carbon and water limitations.

### Light Interception

Toggle light interception calculations. Calculate light interception dynamically, considering direct and diffuse radiation effects. Users can choose either CPU or GPU light models:

- **GPU light model**: Simulates different light spectra separately.
- **CPU light model**: Simulates red, blue, and green channels, allowing customization for various wavelengths (e.g., using the green channel to represent near-infrared light). The CPU model can calculate ratios between red and infrared channels at different canopy depths.

**Note**: Light interception is a prerequisite for photosynthesis and water flux calculations.

### Clamping Shading Factor

- **useShadingFactor**: Controls whether a canopy-level shading factor is applied.
  - **True**: Applies a predefined shading factor to single-tree cases in validation tests, scaling light interception.
  - **False**: Disables shading factors and uses explicit grid clones to represent inter-tree shading.
- **Default**: If no shading factor file is provided, the value is set to `1.0`, corresponding to an isolated tree without additional shading.

 
### Photosynthesis and Transpiration

- **Potential Photosynthesis and Transpiration**: Calculate rates of photosynthesis and transpiration under ideal conditions, with no water stress.
- **Actual Photosynthesis and Transpiration**: Include actual rates, factoring in water stress conditions.

### Carbon Allocation

Model the dynamics of carbon allocation and carbohydrate reserves. This includes organ growth in weight or size, provided primary and secondary growth phases are active.

### Plant Development

Enable dynamic plant architecture and development when `staticArchitecture` is set to `false` or `usePotentialGrowth` is set to `true`, allowing continuous growth over time.

### Environmental Conditions

Input detailed environmental parameters (e.g., temperature, humidity, light, soil water potential or content) that dynamically influence plant growth.

### Structural Variations

Incorporate or exclude architectural variations to customize modeling scenarios.

### Phenology and Yield Estimation

Simulate phenological stages and estimate potential yields by integrating environmental and developmental impacts on yield components over time.

# Additional Features

### Visualization and Output Options

Generate detailed output tables and visualizations for individual fruits, leaves, and internodes.

### Adaptive Growth Responses

Manage growth responses such as leaf angle optimization and shoot positioning for optimal light absorption and plant health.

### Simulation Customization

Customize start times, growth cycles, and harvest schedules to match specific research needs or agricultural practices.

### Auto-documentation

Following Java-style documentation, use an external tool such as **Doxygen** (van Heesch, 2008) to generate web-based documentation for the model’s code structure, classes, and methods.

#### Defining Scenarios

- Scenarios are outlined within an Excel file located in `Scenario_file_generation/1_scenario_and_parameters_excels`.
- Utilize the `2_excel_to_json_python` script to convert the Excel scenario file into a JSON format, ready for simulation use.

## Model Folder Structure Overview

The overall directory is categorized into two main groups: folders essential for model execution and folders that serve complementary purposes. Essential folders include those necessary for direct model operation and additional resources required when running through an Apptainer image. Complementary folders provide support through utilities, documentation, calibration tools, and more.

### Essential Folders

- **Scripts**: Central hub for the model's source code, organized for easy navigation and modification.
  - **main**: Contains scripts for the main loop control, update sequence, development rules, and configuration of output tables and charts, serving as the centralized execution logic and results visualization.
  - **organs**: Houses definitions for all organ types and abstract organs, including an organ factory for selecting among different versions specified in the `alterModules` folder.
  - **config**: Houses the the configurations for globalParameters, modelInput, plant parameters, intiation, architReconstruction, simRun.
  - **environment**: contains the code for the setting climate and soil conditions
  - **alterModules**: contains the code for all alternative modules
  - **images**: contains the images for texture shaders
  - **management**: contains the code for management actions
  - **physioFunctions**: contains the code for physio functions
  - **utilis**: contains the code for extra tools and utilities that can be used

- **Model_input**: Stores all model input files, separating data from code to facilitate input adjustments and configuration testing.

- **Model_scenario**: Contains files for various modeling scenarios, each specifying unique conditions or parameters for simulation, enabling exploration of different outcomes without altering the model's core structure.

- **ext**: Contains extra java packages for loading into GroIMP, extending the model's functionality with additional features, customizations, or integrations.
- **images**: Contains the apptainer image for running the application in a isolated system environment. The image is quite large, thus it is recommended to directly commit the image in github. It is stored in the github container, and can be pulled to the local drive through the apptainer_pull.sh in the bash script folder.

### Complementary Folders

- **bash_scripts**: Includes bash scripts for headless GroIMP model execution and batch processing in environments like power plants, crucial for automation in high-performance computing settings or extensive scenario analysis.

- **build**: Essential for building a docker image for large GitHub actions on power plant.

- **Model_calibration**, **Model_documents**, **Model_visualization**, **Scenario_file_generation**, **statistical_model**, **tests**, and **Utils**: These folders provide support in various aspects such as model calibration, documentation, visualization, scenario generation, statistical modeling, testing, and utilities.

By organizing the folder structure into these categories, the model facilitates both core execution and extensive support for customization, calibration, and visualization, making it adaptable for a wide range of scenarios and environments.

## Installation on local computer

Follow these instructions to set up the model for execution on your local machine.

### Prerequisites

- Ensure Java 17 and GroIMP 2.0 (or later versions) are installed to run the model.

### Setup for running on local installation

- **External Libraries**: Place the `ext` library into the GroIMP installation folder.

  - **Linux**:
    - Copy all files from the `ext_linux` folder into the `ext` folder within your GroIMP installation directory (commonly found in `C/program files/GroIMP 1.6`).

  - **Windows**:
    - Copy all `.dll` files from the `ext_windows` folder into the `ext` folder.
    - Additionally, copy the `.jar` files from the `ext_linux` folder into the same `ext` folder.

- **Configuration File**:
  - Locate the `config.properties.txt` file in the `Util` folder and place it into your GroIMP folder.
  - Modify the path in the `.txt` file to reflect the location of your model. (Upon running GroIMP, the model generates a file with a default address; however, you'll need to update this address to match your specific path.) Without this file, the model cannot be opened.

### Setup for running through apptainer image in the Windows sub-linux system

- see details in the: <https://plantandfood.atlassian.net/wiki/spaces/MAS/pages/2629304347/Running+GroIMP+using+Apptainer>

### Opening the Model

- Launch the GroIMP interface.
- Navigate to `File` > `Open` to select the `project.cs` file from the `scripts` folder.
- To initialize, click `Save` or `Reset`. To view results from reading digitization data, click `Run once`.

### Archiving the Model

- Launch the GroIMP interface
- Open the model
- Navigate to `File` > `Save As`
- Select `Project Archive (*.gsz)` as the `Files of Type`


