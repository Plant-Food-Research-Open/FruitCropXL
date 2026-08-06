import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import java.util.HashMap;
import java.util.Map;
import com.fasterxml.jackson.module.jsonSchema.jakarta.JsonSchema;
import com.fasterxml.jackson.module.jsonSchema.jakarta.factories.ObjectVisitor;
import com.fasterxml.jackson.module.jsonSchema.jakarta.factories.ObjectVisitorDecorator;
import com.fasterxml.jackson.module.jsonSchema.jakarta.factories.SchemaFactoryWrapper;
import com.fasterxml.jackson.module.jsonSchema.jakarta.factories.VisitorContext;
import com.fasterxml.jackson.module.jsonSchema.jakarta.factories.WrapperFactory;
import com.fasterxml.jackson.module.jsonSchema.jakarta.types.ArraySchema;
import com.fasterxml.jackson.module.jsonSchema.jakarta.types.NumberSchema;
import com.fasterxml.jackson.module.jsonSchema.jakarta.types.ObjectSchema;
import com.fasterxml.jackson.module.jsonSchema.jakarta.types.StringSchema;
import com.fasterxml.jackson.module.jsonSchema.jakarta.validation.AnnotationConstraintResolver;
import com.fasterxml.jackson.module.jsonSchema.jakarta.validation.ValidationConstraintResolver;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;

@JsonRootName("plant-level")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PlantLevelOutputData implements Serializable {
	// Keep backward compatibility with previously serialized project graphs.
	private static final long serialVersionUID = -1942705293061994938L;

	/****** Time identifier ******/
	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Time-stamp in ISO 8601 format")
	@Tags("Time identifier")
	public String timestamp;

	@JsonProperty(value = "year", index = 1)
	@JsonPropertyDescription("year")
	@Tags("Time identifier")
	public int year;

	@JsonProperty(value = "dayOfYear", index = 2)
	@JsonPropertyDescription("Day of year ")
	@Tags("Time identifier")
	public int dayOfYear;

	@JsonProperty(value = "hourOfDay", index = 3)
	@JsonPropertyDescription("Hour of day")
	@Tags("Time identifier")
	public int hourOfDay;

	@JsonProperty(value = "scenario", index = 4)
	@JsonPropertyDescription("Internal scenario number for configure different simulations")
	@Tags("Time identifier")
	public int scenario;

	@JsonProperty(value = "simuuid", index = 5)
	@JsonPropertyDescription("The unique simulation UUID assigned to each simulation run.")
	@Tags("Time identifier")
	public String simuuid;

	@JsonProperty(value = "plantAge_days", index = 6)
	@JsonPropertyDescription("Plant age in days")
	@Tags("Time identifier")
	public double plantAge_days;

	@JsonProperty(value = "plantAge_Td", index = 7)
	@JsonPropertyDescription("Plant age in thermal days")
	@Unit("thermal day")
	@Tags("Time identifier")
	public double plantAge_Td;

	@JsonProperty(value = "degreeDay", index = 8)
	@JsonPropertyDescription("Elapsed time in growing degree days")
	@Tags("Time identifier")
	public double degreeDay;

	/****** Weather conditions ******/
	@JsonProperty(value = "Ta", index = 9)
	@JsonPropertyDescription("Ambient air temperature around the plant, measured in degrees.")
	@Unit("degree")
	@Tags("Weather conditions")
	public float Ta;

	@JsonProperty(value = "rh", index = 10)
	@JsonPropertyDescription("Relative humidity surrounding the plant, expressed as a percentage.")
	@Tags("Weather conditions")
	public double rh;

	@JsonProperty(value = "incomingRadiation", index = 11)
	@JsonPropertyDescription("Rate of solar radiation received per unit area, measured in micromoles of photons per square meter per second.")
	@Unit("umol/m²/s")
	@Tags("Weather conditions")
	public double incomingRadiation;

	@JsonProperty(value = "cca", index = 12)
	@JsonPropertyDescription("Co2 concentration in air")
	@Unit("ppm")
	@Tags("Weather conditions")
	public float cca;

	@JsonProperty(value = "wind", index = 13)
	@JsonPropertyDescription("wind speed in air")
	@Unit("m/s")
	@Tags("Weather conditions")
	public float wind;

	@JsonProperty(value = "rainfall", index = 14)
	@JsonPropertyDescription("wind speed in air")
	@Unit("mm")
	@Tags("Weather conditions")
	public float rainfall;

	/** Soil conditions */
	@JsonProperty(value = "soilWaterContent", index = 15)
	@JsonPropertyDescription("Water mass content in the soil, expressed as a mass ratio (kg of water per kg of dry soil).")
	@Unit("g/g")
	@Tags("Soil conditions")
	public String soilWaterContent;

	@JsonProperty(value = "soilWaterPotential", index = 16)
	@JsonPropertyDescription("Water potential of different soil layers, influencing water availability to the plant.")
	@Unit("MPa")
	@Tags("Soil conditions")
	public String soilWaterPotential;

	@JsonProperty(value = "meanSoilWaterPotential", index = 17)
	@JsonPropertyDescription("Mean energy state of water in the soil, which affects its movement and availability to the plant, measured in MPa.")
	@Unit("MPa")
	@Tags("Soil conditions")
	public double meanSoilWaterPotential;

	@JsonProperty(value = "totalSoilAvailableWater", index = 18)
	@JsonPropertyDescription("Total amount of water available in the soil for plant uptake, measured in kilograms.")
	@Unit("kg")
	@Tags("Soil conditions")
	public double totalSoilAvailableWater;

	@JsonProperty(value = "soilNContent", index = 19)
	@JsonPropertyDescription("The concentration of nitrogen in the soil, expressed in grams per cubic meter.")
	@Unit("g/m³")
	@Tags("Soil conditions")
	public float soilNContent;

	/** Leaf area and fruit number */
	@JsonProperty(value = "leafArea", index = 20)
	@JsonPropertyDescription("Total surface area of leaves on the plant, measured in square meters.")
	@Unit("m²")
	@Tags("Leaf area and fruit number")
	public double leafArea;

	@JsonProperty(value = "leafNumber", index = 21)
	@JsonPropertyDescription("Total number of leaves on the plant, representing the cumulative count of all leaves.")
	@Tags("Leaf area and fruit number")
	public int leafNumber;

	@JsonProperty(value = "totalFruitNumber", index = 22)
	@JsonPropertyDescription("Total number of fruits present on the plant, representing the cumulative count of all fruits.")
	@Tags("Leaf area and fruit number")
	public int totalFruitNumber;

	/**
	 * Radiation absorption and distribution at 1/3, 2/3, and 3/3 of the canopy.
	 * The actual height of the calculation changes with canopy height
	 */
	@JsonProperty(value = "AbsorbedTotRad", index = 23)
	@JsonPropertyDescription("Total radiation absorbed by the plant, measured in micromoles per plant per second.")
	@Unit("umol/plant/s")
	@Tags("Radiation absorption and distribution at 1/3, 2/3, and 3/3 of the canopy. The actual height of the calculation changes with canopy height")
	public double AbsorbedTotRad;

	@JsonProperty(value = "AbsorbedPAR", index = 24)
	@JsonPropertyDescription("Photosynthetically active radiation (PAR) absorbed by the plant, measured in micromoles per plant per second.")
	@Unit("umol/plant/s")
	@Tags("Radiation absorption and distribution at 1/3, 2/3, and 3/3 of the canopy. The actual height of the calculation changes with canopy height")
	public double AbsorbedPAR;

	@JsonProperty(value = "fabsTotRad", index = 25)
	@JsonPropertyDescription("Fraction of absorbed radiation of global radiation per square meter.")
	@Tags("Radiation absorption and distribution at 1/3, 2/3, and 3/3 of the canopy. The actual height of the calculation changes with canopy height")
	public double fabsTotRad;

	@JsonProperty(value = "fabsPAR", index = 26)
	@JsonPropertyDescription("Fraction of absorbed PAR per square meter. This has been scaled by dens FPAR. it is slightly differently from fPARLow, mid and up, which are PAR penetrated to the canopy")
	@Tags("Radiation absorption and distribution at 1/3, 2/3, and 3/3 of the canopy. The actual height of the calculation changes with canopy height")
	public double fabsPAR;

	@JsonProperty(value = "fPARLow", index = 27)
	@JsonPropertyDescription("Relative PAR irradiance in the lower canopy layer: mean incident PAR on leaf surfaces within the lower stratum, "
			+ "normalized by above-canopy incident PAR. The lower stratum spans from trunk height to 1/3 of the canopy height.")
	@Tags("Radiation distribution: normalized mean leaf irradiance by canopy strata (lower/middle/upper); strata bounds scale with canopy height.")
	public double fPARLow_1_3;

	@JsonProperty(value = "fPARMid", index = 28)
	@JsonPropertyDescription("Relative PAR irradiance in the middle canopy layer: mean incident PAR on leaf surfaces within the middle stratum, "
			+ "normalized by above-canopy incident PAR. The middle stratum spans from 1/3 to 2/3 of the canopy height.")
	@Tags("Radiation distribution: normalized mean leaf irradiance by canopy strata (lower/middle/upper); strata bounds scale with canopy height.")
	public double fPARMid_2_3;

	@JsonProperty(value = "fPARUp", index = 29)
	@JsonPropertyDescription("Relative PAR irradiance in the upper canopy layer: mean incident PAR on leaf surfaces within the upper stratum, "
			+ "normalized by above-canopy incident PAR. The upper stratum spans from 2/3 of the canopy height to the top of the canopy.")
	@Tags("Radiation distribution: normalized mean leaf irradiance by canopy strata (lower/middle/upper); strata bounds scale with canopy height.")
	public double fPARUp_3_3;

	/** Photosynthesis and water flux */
	@JsonProperty(value = "meanPAnet", index = 30)
	@JsonPropertyDescription("Average potential rate of photosynthesis across the plant, measured in micromoles of CO2 per square meter per second.")
	@Unit("umolco2/m²/s¹")
	@Tags("Photosynthesis and water flux")
	public double meanPAnet;

	@JsonProperty(value = "meanAnet", index = 31)
	@JsonPropertyDescription("Average rate of actual net photosynthesis across the plant, measured in umol of CO2 per square meter per second.")
	@Unit("umolco2/m²/s")
	@Tags("Photosynthesis and water flux")
	public double meanAnet;

	@JsonProperty(value = "carbonAssimilation", index = 32)
	@JsonPropertyDescription("Rate at which carbon is assimilated by the plant, measured in milligrams per plant per hour. Note this is carbon per hour")
	@Unit("mgC/plant/hour")
	@Tags("Photosynthesis and water flux")
	public double carbonAssimilation;

	@JsonProperty(value = "waterFlux_optimized", index = 33)
	@JsonPropertyDescription("Rate of water transport within the plant, measured in milligrams per plant per second.")
	@Unit("mg/plant/s")
	@Tags("Photosynthesis and water flux")
	public double waterFlux_optimized;

	@JsonProperty(value = "WUE", index = 34)
	@JsonPropertyDescription("Water use efficiency of the plant, measured as mg of carbon assimilated per mg of water transpired.")
	@Unit("mgC/mgH2O")
	@Tags("Photosynthesis and water flux")
	public double WUE;

	@JsonProperty(value = "waterFluxPotential", index = 35)
	@JsonPropertyDescription("Potential rate of water flux through the plant, measured in milligrams per second.")
	@Unit("mg/s")
	@Tags("Photosynthesis and water flux")
	public double waterFluxPotential;

	@JsonProperty(value = "xylemWaterPotential", index = 36)
	@JsonPropertyDescription("Water potential within the xylem, indicating the energy state of water in the plant, measured in MPa.")
	@Unit("MPa")
	@Tags("Photosynthesis and water flux")
	public double xylemWaterPotential;

	@JsonProperty(value = "leaf_waterPotential", index = 37)
	@JsonPropertyDescription("leaf water potential for middle layers")
	@Unit("Mpa")
	@Tags("Photosynthesis and water flux")
	public float leaf_waterPotential;

	@JsonProperty(value = "potentialSupplyDemandRatio", index = 38)
	@JsonPropertyDescription("the ratio of potential supply of biomass vs potential demand from all growing organs of the plant.")
	@Unit("mgC/mgH2O")
	@Tags("Carbon transport")
	public double potentialSupplyDemandRatio;

	@JsonProperty(value = "phloemSugarConcentration", index = 39)
	@JsonPropertyDescription("Concentration of sugar in the phloem, measured in mg of sugar per mg of solution.")
	@Unit("mgSugar/mgSolution")
	@Tags("Carbon transport")
	public double phloemSugarConcentration;

	/** Biomass of different components. Flower, petiole */
	@JsonProperty(value = "biomassPlant", index = 40)
	@JsonPropertyDescription("Total biomass of the plant including all organs and reserves, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassPlant;

	@JsonProperty(value = "biomassLeaf", index = 41)
	@JsonPropertyDescription("Total biomass of leaves on the plant, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassLeaf;

	@JsonProperty(value = "biomassInternode", index = 42)
	@JsonPropertyDescription("Total biomass of internodes of the plant, measured in mg. This includes trunk and cordon as they extend the internode class.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassInternode;

	@JsonProperty(value = "biomassFlower", index = 43)
	@JsonPropertyDescription("Total biomass of all flower on the plant, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassFlower;

	@JsonProperty(value = "biomassFruit", index = 44)
	@JsonPropertyDescription("Total biomass of all fruits on the plant, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassFruit;

	@JsonProperty(value = "biomassFineRoot", index = 45)
	@JsonPropertyDescription("Total biomass of fine roots within the plant system, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassFineRoot;

	@JsonProperty(value = "biomassStructuralRoot", index = 46)
	@JsonPropertyDescription("Total biomass of structural roots of the plant, measured in mg.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassStructuralRoot;

	@JsonProperty(value = "biomassCordon", index = 47)
	@JsonPropertyDescription("Total biomass of cordon of the plant, measured in mg. Internode that larger than one year old.")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassCordon;

	@JsonProperty(value = "biomassTrunk", index = 48)
	@JsonPropertyDescription("Total biomass of trunk of the plant, measured in mg. the main axis of the stem")
	@Unit("mg/plant")
	@Tags("Biomass of different components")
	public double biomassTrunk;

	/** Nonstructural carbon concentrations in different parts */
	@JsonProperty(value = "leafNSC", index = 49)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in leaves (NSC in all leaves), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double leafNSC;

	@JsonProperty(value = "fineRootNSC", index = 50)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in fine roots (NSC in all fine roots), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double fineRootNSC;

	@JsonProperty(value = "structuralRootNSC", index = 51)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in structural roots (NSC in all structural roots), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double structuralRootNSC;

	@JsonProperty(value = "internodeNSC", index = 52)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in internodes (NSC in all internodes), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double internodeNSC;

	@JsonProperty(value = "cordonNSC", index = 53)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in cordons (NSC in all cordons), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double cordonNSC;

	@JsonProperty(value = "trunkNSC", index = 54)
	@JsonPropertyDescription("Amount of non-structural carbohydrates stored in trunk (NSC in all trunk tissues), measured in mg per plant.")
	@Unit("mg/plant")
	@Tags("Nonstructural carbon concentrations in different parts")
	public double trunkNSC;

	/** Fraction of unloadings */
	@JsonProperty(value = "totalUnloading", index = 55)
	@JsonPropertyDescription("Total carbon unloaded from the phloem into all sink organs (sum of all unloading), in mgC per plant.")
	@Unit("mgC/plant")
	@Tags("Fraction of unloadings")
	public float totalUnloading;

	@JsonProperty(value = "fraction_leafUnloading", index = 56)
	@JsonPropertyDescription("Proportion of total carbon unloaded into the leaves (fraction of total unloading to leaves).")
	@Tags("Fraction of unloadings")
	public float fraction_leafUnloading;

	@JsonProperty(value = "fraction_fruitUnloading", index = 57)
	@JsonPropertyDescription("Proportion of total carbon unloaded into the fruits (fraction of total unloading to fruits).")
	@Tags("Fraction of unloadings")
	public float fraction_fruitUnloading;

	@JsonProperty(value = "fraction_fineRootUnloading", index = 58)
	@JsonPropertyDescription("Proportion of total carbon unloaded into fine roots (fraction of total unloading to fine roots).")
	@Tags("Fraction of unloadings")
	public float fraction_fineRootUnloading;

	@JsonProperty(value = "fraction_structuralRootUnloading", index = 59)
	@JsonPropertyDescription("Proportion of total carbon unloaded into structural roots (fraction of total unloading to structural roots).")
	@Tags("Fraction of unloadings")
	public float fraction_structuralRootUnloading;

	@JsonProperty(value = "fraction_internodeUnloading", index = 60)
	@JsonPropertyDescription("Proportion of total carbon unloaded into the stems, including all internodes, cordon, and trunk.")
	@Tags("Fraction of unloadings")
	public float fraction_internodeUnloading;

	@JsonProperty(value = "fraction_perennielWoodUnloading", index = 61)
	@JsonPropertyDescription("Proportion of total carbon unloaded into perennial woods, including trunk and cordon.")
	@Tags("Fraction of unloadings")
	public float fraction_perennielWoodUnloading;

	@JsonProperty(value = "fraction_flowerUnloading", index = 62)
	@JsonPropertyDescription("Proportion of total carbon unloaded into flowers.")
	@Tags("Fraction of unloadings")
	public float fraction_flowerUnloading;

	@JsonProperty(value = "fraction_petioleUnloading", index = 63)
	@JsonPropertyDescription("Proportion of total carbon unloaded into petioles.")
	@Tags("Fraction of unloadings")
	public float fraction_petioleUnloading;

	/** Fraction of loadings */
	@JsonProperty(value = "fraction_leafLoading", index = 64)
	@JsonPropertyDescription("Proportion of total carbon loaded from the leaves.")
	@Tags("Fraction of loadings")
	public float fraction_leafLoading;

	@JsonProperty(value = "fraction_internodeLoading", index = 65)
	@JsonPropertyDescription("Proportion of total carbon loaded from the stems, including all internodes, cordon, and trunk.")
	@Tags("Fraction of loadings")
	public float fraction_internodeLoading;

	@JsonProperty(value = "fraction_perennielWoodLoading", index = 66)
	@JsonPropertyDescription("Proportion of total carbon loaded from the perennial stems.")
	@Tags("Fraction of loadings")
	public float fraction_perennielWoodLoading;

	@JsonProperty(value = "fraction_fineRootLoading", index = 67)
	@JsonPropertyDescription("Proportion of total carbon loaded from fine roots.")
	@Tags("Fraction of loadings")
	public float fraction_fineRootLoading;

	@JsonProperty(value = "fraction_structuralRootLoading", index = 68)
	@JsonPropertyDescription("Proportion of total carbon loaded from structural roots.")
	@Tags("Fraction of loadings")
	public float fraction_structuralRootLoading;

	/** Carbon leakage during transport */
	@JsonProperty(value = "totalLeakage", index = 69)
	@JsonPropertyDescription("Total carbon leakage during transport.")
	@Unit("mgC/plant")
	@Tags("Carbon leakage during transport")
	public float totalLeakage;

	@JsonProperty(value = "internodeLeakage", index = 70)
	@JsonPropertyDescription("Amount of carbon leaked into stems, measured in mgC.")
	@Unit("mgC")
	@Tags("Carbon leakage during transport")
	public float internodeLeakage;

	@JsonProperty(value = "structuralRootLeakage", index = 71)
	@JsonPropertyDescription("Amount of carbon leaked into structural roots, measured in mgC.")
	@Unit("mgC")
	@Tags("Carbon leakage during transport")
	public double structuralRootLeakage;

	/** Maintenance cost */
	@JsonProperty(value = "maintenanceDM", index = 72)
	@JsonPropertyDescription("Cost of maintaining dry matter, typically energy or substrates used, measured in mg/hour.")
	@Unit("mg/plant/h")
	@Tags("Maintenance cost")
	public double maintenanceDM;

	@JsonProperty(value = "maintenanceLeaf", index = 73)
	@JsonPropertyDescription("Cost associated with maintaining leaves, typically energy or substrates used, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Maintenance cost")
	public double maintenanceLeaf;

	@JsonProperty(value = "maintenanceInternode", index = 74)
	@JsonPropertyDescription("Cost associated with maintaining internodes, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Maintenance cost")
	public double maintenanceInternode;

	@JsonProperty(value = "maintenanceFruit", index = 75)
	@JsonPropertyDescription("Total cost associated with maintaining all fruits, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Maintenance cost")
	public double maintenanceFruit;

	@JsonProperty(value = "maintenanceFineRoot", index = 76)
	@JsonPropertyDescription("Cost associated with maintaining fine roots, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Maintenance cost")
	public double maintenanceFineRoot;

	@JsonProperty(value = "maintenanceStructuralRoot", index = 77)
	@JsonPropertyDescription("Carbon cost associated with maintaining structural roots, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Maintenance cost")
	public double maintenanceStructuralRoot;

	/** Growth cost */
	@JsonProperty(value = "growthCost", index = 78)
	@JsonPropertyDescription("Energy or substrate cost associated with growth processes, measured in mg/hour.")
	@Unit("mg/plant")
	@Tags("Growth cost")
	public double growthCost;

	@JsonProperty(value = "growthCostLeaf", index = 79)
	@JsonPropertyDescription("Cost associated with growth of leaves, typically energy or substrates used, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Growth cost")
	public double growthCostLeaf;

	@JsonProperty(value = "growthCostInternode", index = 80)
	@JsonPropertyDescription("Cost associated with growth of internodes, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Growth cost")
	public double growthCostInternode;

	@JsonProperty(value = "growthCostFruit", index = 81)
	@JsonPropertyDescription("Total cost associated with the growth of all fruits, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Growth cost")
	public double growthCostFruit;

	@JsonProperty(value = "growthCostFineRoot", index = 82)
	@JsonPropertyDescription("Cost associated with growth of fine roots, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Growth cost")
	public double growthCostFineRoot;

	@JsonProperty(value = "growthCostStructuralRoot", index = 83)
	@JsonPropertyDescription("Carbon cost associated with growth of structural roots, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Growth cost")
	public double growthCostStructuralRoot;

	/** Carbon balance and perennial-structure carbon costs */
	@JsonProperty(value = "previousDailyNetCarbonBalance", index = 84)
	@JsonPropertyDescription("Previous complete day's net carbon balance: assimilation plus flower self-assimilation minus growth and maintenance costs.")
	@Unit("mgC/plant/day")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double previousDailyNetCarbonBalance;

	@JsonProperty(value = "cordonStructureDM_SEC", index = 85)
	@JsonPropertyDescription("Absolute secondary structural growth demand for cordons.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double cordonStructureDM_SEC;

	@JsonProperty(value = "trunkStructureDM_SEC", index = 86)
	@JsonPropertyDescription("Absolute secondary structural growth demand for trunks.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double trunkStructureDM_SEC;

	@JsonProperty(value = "perennielWoodStructureDM_SEC", index = 87)
	@JsonPropertyDescription("Absolute secondary structural growth demand for cordon plus trunk.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double perennielWoodStructureDM_SEC;

	@JsonProperty(value = "structuralRootStructureDM_SEC", index = 88)
	@JsonPropertyDescription("Absolute secondary structural growth demand for structural roots.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double structuralRootStructureDM_SEC;

	@JsonProperty(value = "cordonMaintenanceDM", index = 89)
	@JsonPropertyDescription("Absolute maintenance demand for cordons.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double cordonMaintenanceDM;

	@JsonProperty(value = "trunkMaintenanceDM", index = 90)
	@JsonPropertyDescription("Absolute maintenance demand for trunks.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double trunkMaintenanceDM;

	@JsonProperty(value = "perennielWoodMaintenanceDM", index = 91)
	@JsonPropertyDescription("Absolute maintenance demand for cordon plus trunk.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double perennielWoodMaintenanceDM;

	@JsonProperty(value = "structuralRootMaintenanceDM", index = 92)
	@JsonPropertyDescription("Absolute maintenance demand for structural roots.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double structuralRootMaintenanceDM;

	@JsonProperty(value = "cordonReserveDM", index = 93)
	@JsonPropertyDescription("Absolute reserve synthesis demand for cordons.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double cordonReserveDM;

	@JsonProperty(value = "trunkReserveDM", index = 94)
	@JsonPropertyDescription("Absolute reserve synthesis demand for trunks.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double trunkReserveDM;

	@JsonProperty(value = "perennielWoodReserveDM", index = 95)
	@JsonPropertyDescription("Absolute reserve synthesis demand for cordon plus trunk.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double perennielWoodReserveDM;

	@JsonProperty(value = "structuralRootReserveDM", index = 96)
	@JsonPropertyDescription("Absolute reserve synthesis demand for structural roots.")
	@Unit("mg C h-1")
	@Tags("Carbon balance and perennial-structure carbon costs")
	public double structuralRootReserveDM;

	/** Root base information */
	@JsonProperty(value = "sumRootConductance", index = 97)
	@JsonPropertyDescription("Rate at which roots conduct water under a unit pressure gradient, measured in mg per MPa per second.")
	@Unit("mg/MPa/s")
	@Tags("Root base information")
	public float sumRootConductance;

	@JsonProperty(value = "sumNuptakeCostRoot", index = 98)
	@JsonPropertyDescription("Cost associated with nitrogen uptake by the roots, measured in mg/hour.")
	@Unit("mgC")
	@Tags("Root base information")
	public double sumNuptakeCostRoot;

	/** Nitrogen information */
	@JsonProperty(value = "totalNitrogen", index = 99)
	@JsonPropertyDescription("Total amount of nitrogen present in the entire plant including mobile and nonmobile, measured in milligrams.")
	@Unit("mg/plant")
	@Tags("Nitrogen information")
	public double totalNitrogen;

	@JsonProperty(value = "plantNitrogenCommonPool", index = 100)
	@JsonPropertyDescription("Total amount of nitrogen available across the plant, measured in milligrams.")
	@Unit("mg")
	@Tags("Nitrogen information")
	public double plantNitrogenCommonPool;

	@JsonProperty(value = "plantNitrogenContent", index = 101)
	@JsonPropertyDescription("Nitrogen content relative to plant mass, measured in mg per mg.")
	@Unit("mg/mg")
	@Tags("Nitrogen information")
	public double plantNitrogenContent;

	@JsonProperty(value = "meanLeafNcontent", index = 102)
	@JsonPropertyDescription("Average nitrogen content across all leaves, measured as a ratio of nitrogen to leaf mass.")
	@Unit("mg/mg")
	@Tags("Nitrogen information")
	public double meanLeafNcontent;

	@JsonProperty(value = "NDegradation", index = 103)
	@JsonPropertyDescription("Amount of nitrogen degraded in the growing organ, measured in milligrams.")
	@Unit("mg")
	@Tags("Nitrogen information")
	public double Ndegradation;

	@JsonProperty(value = "NSynthesis", index = 104)
	@JsonPropertyDescription("Amount of nitrogen synthesized in all growing organs, measured in milligrams.")
	@Unit("mg")
	@Tags("Nitrogen information")
	public double Nsynthesis;

	@JsonProperty(value = "Nuptake", index = 105)
	@JsonPropertyDescription("Amount of nitrogen taken up by the fine roots, measured in milligrams.")
	@Unit("mg")
	@Tags("Nitrogen information")
	public double Nuptake;

	/** Customizable output based on height input */
	@JsonProperty(value = "fPAR_1", index = 106)
	@JsonPropertyDescription("Relative PAR irradiance for canopy zone 1: mean incident PAR on leaf surfaces within the first user-defined height band, "
			+ "normalized by above-canopy incident PAR. Zone bounds are defined by output_height[0]–output_height[1].")
	@Tags("Radiation distribution: normalized mean leaf irradiance in user-defined height bands (output_height).")
	public double fPAR_1;

	@JsonProperty(value = "fPAR_2", index = 107)
	@JsonPropertyDescription("Relative PAR irradiance for canopy zone 2: mean incident PAR on leaf surfaces within the second user-defined height band, "
			+ "normalized by above-canopy incident PAR. Zone bounds are defined by output_height[1]–output_height[2].")
	@Tags("Radiation distribution: normalized mean leaf irradiance in user-defined height bands (output_height).")
	public double fPAR_2;

	@JsonProperty(value = "fPAR_3", index = 108)
	@JsonPropertyDescription("Relative PAR irradiance for canopy zone 3: mean incident PAR on leaf surfaces within the third user-defined height band, "
			+ "normalized by above-canopy incident PAR. Zone bounds are defined by output_height[2]–output_height[3].")
	@Tags("Radiation distribution: normalized mean leaf irradiance in user-defined height bands (output_height).")
	public double fPAR_3;

	@JsonProperty(value = "fPAR_4", index = 109)
	@JsonPropertyDescription("Relative PAR irradiance for canopy zone 4: mean incident PAR on leaf surfaces within the fourth user-defined height band, "
			+ "normalized by above-canopy incident PAR. Zone bounds are defined by output_height[3]–output_height[4] (or to canopy top for the last band).")
	@Tags("Radiation distribution: normalized mean leaf irradiance in user-defined height bands (output_height).")
	public double fPAR_4;

	@JsonProperty(value = "fs_1", index = 110)
	@JsonPropertyDescription("Fraction of PAR in zone 1 by light sensors if used")
	@Tags("Customizable output based on height input")
	public float fs_1;

	@JsonProperty(value = "fs_2", index = 111)
	@JsonPropertyDescription("Fraction of PAR in zone 2 by light sensors if used")
	@Tags("Customizable output based on height input")
	public float fs_2;

	@JsonProperty(value = "fs_3", index = 112)
	@JsonPropertyDescription("Fraction of PAR in zone 3 by light sensors if used")
	@Tags("Customizable output based on height input")
	public float fs_3;

	@JsonProperty(value = "fs_4", index = 113)
	@JsonPropertyDescription("Fraction of PAR in zone 4 by light sensors if used")
	@Tags("Customizable output based on height input")
	public float fs_4;

	@JsonProperty(value = "cumLAI_1", index = 114)
	@JsonPropertyDescription("Cumulative leaf area index above a specific threshold, representing leaf density or coverage in zone 1.")
	@Tags("Customizable output based on height input")
	public double cumLAI_1;

	@JsonProperty(value = "cumLAI_2", index = 115)
	@JsonPropertyDescription("Cumulative leaf area index above a specific threshold, representing leaf density or coverage in zone 2.")
	@Tags("Customizable output based on height input")
	public double cumLAI_2;

	@JsonProperty(value = "cumLAI_3", index = 116)
	@JsonPropertyDescription("Cumulative leaf area index above a specific threshold, representing leaf density or coverage in zone 3.")
	@Tags("Customizable output based on height input")
	public double cumLAI_3;

	@JsonProperty(value = "cumLAI_4", index = 117)
	@JsonPropertyDescription("Cumulative leaf area index above a specific threshold, representing leaf density or coverage in zone 4.")
	@Tags("Customizable output based on height input")
	public double cumLAI_4;

	@JsonProperty(value = "intWaterPotential_1", index = 118)
	@JsonPropertyDescription("Internode Water Potential in zone 1")
	@Tags("Customizable output based on height input")
	public float intWaterPotential_1;

	@JsonProperty(value = "intWaterPotential_2", index = 119)
	@JsonPropertyDescription("Internode Water Potential in zone 2")
	@Tags("Customizable output based on height input")
	public float intWaterPotential_2;

	@JsonProperty(value = "intWaterPotential_3", index = 120)
	@JsonPropertyDescription("Internode Water Potential in zone 3")
	@Tags("Customizable output based on height input")
	public float intWaterPotential_3;

	@JsonProperty(value = "intWaterPotential_4", index = 121)
	@JsonPropertyDescription("Internode Water Potential in zone 4")
	@Tags("Customizable output based on height input")
	public float intWaterPotential_4;

	@JsonProperty(value = "meanAnet_1", index = 122)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.AlimActual values for leaves with z in [output_height[0], output_height[1]).")
	@Unit("umol CO2/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanAnet_1;

	@JsonProperty(value = "meanAnet_2", index = 123)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.AlimActual values for leaves with z in [output_height[1], output_height[2]).")
	@Unit("umol CO2/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanAnet_2;

	@JsonProperty(value = "meanAnet_3", index = 124)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.AlimActual values for leaves with z in [output_height[2], output_height[3]).")
	@Unit("umol CO2/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanAnet_3;

	@JsonProperty(value = "meanAnet_4", index = 125)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.AlimActual values for leaves with z >= output_height[3]; this final band is unbounded above.")
	@Unit("umol CO2/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanAnet_4;

	@JsonProperty(value = "meanLeafWaterPotential_1", index = 126)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.waterPotential values for leaves with z in [output_height[0], output_height[1]).")
	@Unit("MPa")
	@Tags("Canopy-zone physiology")
	public double meanLeafWaterPotential_1;

	@JsonProperty(value = "meanLeafWaterPotential_2", index = 127)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.waterPotential values for leaves with z in [output_height[1], output_height[2]).")
	@Unit("MPa")
	@Tags("Canopy-zone physiology")
	public double meanLeafWaterPotential_2;

	@JsonProperty(value = "meanLeafWaterPotential_3", index = 128)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.waterPotential values for leaves with z in [output_height[2], output_height[3]).")
	@Unit("MPa")
	@Tags("Canopy-zone physiology")
	public double meanLeafWaterPotential_3;

	@JsonProperty(value = "meanLeafWaterPotential_4", index = 129)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.waterPotential values for leaves with z >= output_height[3]; this final band is unbounded above.")
	@Unit("MPa")
	@Tags("Canopy-zone physiology")
	public double meanLeafWaterPotential_4;

	@JsonProperty(value = "meanGs_1", index = 130)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.gs values for leaves with z in [output_height[0], output_height[1]).")
	@Unit("mol/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanGs_1;

	@JsonProperty(value = "meanGs_2", index = 131)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.gs values for leaves with z in [output_height[1], output_height[2]).")
	@Unit("mol/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanGs_2;

	@JsonProperty(value = "meanGs_3", index = 132)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.gs values for leaves with z in [output_height[2], output_height[3]).")
	@Unit("mol/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanGs_3;

	@JsonProperty(value = "meanGs_4", index = 133)
	@JsonPropertyDescription("Arithmetic mean of finite Leaf.gs values for leaves with z >= output_height[3]; this final band is unbounded above.")
	@Unit("mol/m2/s")
	@Tags("Canopy-zone physiology")
	public double meanGs_4;

	@JsonProperty(value = "sugarConcentration_1", index = 134)
	@JsonPropertyDescription("Phloem sugar concentration in zone 1")
	@Tags("Customizable output based on height input")
	public float sugarConcentration_1;

	@JsonProperty(value = "sugarConcentration_2", index = 135)
	@JsonPropertyDescription("Phloem sugar concentration in zone 2")
	@Tags("Customizable output based on height input")
	public float sugarConcentration_2;

	@JsonProperty(value = "sugarConcentration_3", index = 136)
	@JsonPropertyDescription("Phloem sugar concentration in zone 3")
	@Tags("Customizable output based on height input")
	public float sugarConcentration_3;

	@JsonProperty(value = "sugarConcentration_4", index = 137)
	@JsonPropertyDescription("Phloem sugar concentration in zone 4")
	@Tags("Customizable output based on height input")
	public float sugarConcentration_4;

	/** pruning outputs */
	@JsonProperty(value = "pruneFlowersRemoved", index = 138)
	@JsonPropertyDescription("Number of flowers removed")
	@Tags("Pruning outputs")
	public float pruneFlowersRemoved;

	@JsonProperty(value = "pruneFruitsRemoved", index = 139)
	@JsonPropertyDescription("Number of fruit removed")
	@Tags("Pruning outputs")
	public float pruneFruitsRemoved;

	@JsonProperty(value = "pruneFruitBiomassRemoved", index = 140)
	@JsonPropertyDescription("Flowr and Fruit biomass removed")
	@Tags("Pruning outputs")
	public float pruneFruitBiomassRemoved;

	/** Leaf pruning outputs */
	@JsonProperty(value = "pruneLeafAreaRemoved", index = 141)
	@JsonPropertyDescription("Total leaf area removed during pruning (m2)")
	@Tags("Pruning outputs")
	public float pruneLeafAreaRemoved;

	@JsonProperty(value = "pruneLeafBiomassRemoved", index = 142)
	@JsonPropertyDescription("Leaf biomass removed during pruning")
	@Tags("Pruning outputs")
	public float pruneLeafBiomassRemoved;

	@JsonProperty(value = "pruneInternodeBiomassRemoved", index = 143)
	@JsonPropertyDescription("Internode biomass removed with vegetative shoot pruning")
	@Tags("Pruning outputs")
	public float pruneInternodeBiomassRemoved;

	/** Fruit light interception (total + 4 height bands) */
	@JsonProperty(value = "fruitCount_b1", index = 144)
	@JsonPropertyDescription("Fruit object count in band 1.")
	@Tags("Fruit light interception")
	public int fruitCount_b1;

	@JsonProperty(value = "fruitCount_b2", index = 145)
	@JsonPropertyDescription("Fruit object count in band 2.")
	@Tags("Fruit light interception")
	public int fruitCount_b2;

	@JsonProperty(value = "fruitCount_b3", index = 146)
	@JsonPropertyDescription("Fruit object count in band 3.")
	@Tags("Fruit light interception")
	public int fruitCount_b3;

	@JsonProperty(value = "fruitCount_b4", index = 147)
	@JsonPropertyDescription("Fruit object count in band 4.")
	@Tags("Fruit light interception")
	public int fruitCount_b4;

	@JsonProperty(value = "fruitIncidentPAR_mean_b1_umol_m2_s", index = 148)
	@JsonPropertyDescription("Mean incident fruit PAR in band 1.")
	@Unit("umol/m^2/s")
	@Tags("Fruit light interception")
	public double fruitIncidentPAR_mean_b1_umol_m2_s;

	@JsonProperty(value = "fruitIncidentPAR_mean_b2_umol_m2_s", index = 149)
	@JsonPropertyDescription("Mean incident fruit PAR in band 2.")
	@Unit("umol/m^2/s")
	@Tags("Fruit light interception")
	public double fruitIncidentPAR_mean_b2_umol_m2_s;

	@JsonProperty(value = "fruitIncidentPAR_mean_b3_umol_m2_s", index = 150)
	@JsonPropertyDescription("Mean incident fruit PAR in band 3.")
	@Unit("umol/m^2/s")
	@Tags("Fruit light interception")
	public double fruitIncidentPAR_mean_b3_umol_m2_s;

	@JsonProperty(value = "fruitIncidentPAR_mean_b4_umol_m2_s", index = 151)
	@JsonPropertyDescription("Mean incident fruit PAR in band 4.")
	@Unit("umol/m^2/s")
	@Tags("Fruit light interception")
	public double fruitIncidentPAR_mean_b4_umol_m2_s;

	@JsonProperty(value = "flowerSelfAssimC", index = 152)
	@JsonPropertyDescription("Flower self-assimilation carbon contribution")
	@Unit("mg C h-1")
	@Tags("Carbon allocation diagnostics")
	public double flowerSelfAssimC;

	@JsonProperty(value = "droppedFlowerCount", index = 153)
	@JsonPropertyDescription("Dropped flower count under carbon limitation")
	@Tags("Carbon allocation diagnostics")
	public int droppedFlowerCount;

	@JsonProperty(value = "totalFlowerCount", index = 154)
	@JsonPropertyDescription("Total flower count")
	@Tags("Carbon allocation diagnostics")
	public int totalFlowerCount;

	@JsonProperty(value = "reserveSeasonBeta", index = 155)
	@JsonPropertyDescription("Shared seasonal index for reserve KM and hydrolysis; 0 is early remobilization and 1 is late rebuilding.")
	@Unit("-")
	@Tags("Reserve turnover diagnostics")
	public double reserveSeasonBeta;

	@JsonProperty(value = "effectiveHydRate", index = 156)
	@JsonPropertyDescription("NSC-weighted effective reserve hydrolysis rate across annual internodes, cordons, trunks, and structural roots.")
	@Unit("h-1")
	@Tags("Reserve turnover diagnostics")
	public double effectiveHydRate;

	@JsonProperty(value = "reserveHydrolysisFlux", index = 157)
	@JsonPropertyDescription("Actual woody reserve hydrolysis flux loaded to the phloem from annual internodes, cordons, trunks, and structural roots.")
	@Unit("mg C h-1")
	@Tags("Reserve turnover diagnostics")
	public double reserveHydrolysisFlux;

	@JsonProperty(value = "reserveSynthesisFlux", index = 158)
	@JsonPropertyDescription("Actual woody reserve synthesis flux stored in annual internodes, cordons, trunks, and structural roots.")
	@Unit("mg C h-1")
	@Tags("Reserve turnover diagnostics")
	public double reserveSynthesisFlux;

	@JsonProperty(value = "netReserveChange", index = 159)
	@JsonPropertyDescription("Net actual woody reserve change: reserveSynthesisFlux minus reserveHydrolysisFlux.")
	@Unit("mg C h-1")
	@Tags("Reserve turnover diagnostics")
	public double netReserveChange;

}
