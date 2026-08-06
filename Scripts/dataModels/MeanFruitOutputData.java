import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;

@JsonRootName("fruit")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class MeanFruitOutputData implements Serializable {
	
	
	
	/****** Time and identifier ******/
	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Time-stamp in ISO 8601 format")
	@Tags("Time and identifier")
	public String timestamp;
	
	@JsonProperty(value = "year", index = 1)
	@JsonPropertyDescription("Year of the simulation")
	@Tags("Time and identifier")
	public int year;
	
	@JsonProperty(value = "dayOfYear", index = 2)
	@JsonPropertyDescription("Day of year")
	@Tags("Time and identifier")
	public int dayOfYear;
	
	@JsonProperty(value = "hourOfDay", index = 3)
	@JsonPropertyDescription("Hour of day")
	@Tags("Time and identifier")
	public int hourOfDay;
	
	@JsonProperty(value = "scenario", index = 4)
	@JsonPropertyDescription("Internal scenario number for configuring different simulations")
	@Tags("Time and identifier")
	public int scenario;
	
	@JsonProperty(value = "fruitAge_h", index = 5)
	@JsonPropertyDescription("Fruit age in hours")
	@Tags("Time and identifier")
	public double fruitAge_h;
	
	/** Mean fruit dry, fresh weight and sugar concentrations */
	@JsonProperty(value = "totalFruitNumber", index = 6)
	@JsonPropertyDescription("Total number of fruits present on the plant, representing the cumulative count of all fruits.")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public int totalFruitNumber;
	
	@JsonProperty(value = "meanFruitFW", index = 7)
	@JsonPropertyDescription("Average fresh weight of fruits on the plant, measured in milligrams.")
	@Unit("mg")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitFW;
	
	@JsonProperty(value = "meanFruitFW_sd", index = 8)
	@JsonPropertyDescription("Standard deviation of the fresh weight of fruits, indicating variability in fruit size, measured in milligrams.")
	@Unit("mg")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitFW_sd;
	
	@JsonProperty(value = "meanFruitDW", index = 9)
	@JsonPropertyDescription("Average dry weight of fruits on the plant, measured in milligrams.")
	@Unit("mg")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitDW;
	
	@JsonProperty(value = "meanFruitDW_sd", index = 10)
	@JsonPropertyDescription("Standard deviation of the dry weight of fruits, indicating variability in fruit dry mass, measured in milligrams.")
	@Unit("mg")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitDW_sd;
	
	@JsonProperty(value = "meanFruitSc", index = 11)
	@JsonPropertyDescription("Average sugar concentration in fruits, measured as a ratio of sugar mass to fruit mass.")
	@Unit("g/g")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitSc;
	
	@JsonProperty(value = "meanFruitSc_sd", index = 12)
	@JsonPropertyDescription("Standard deviation of the sugar concentration in fruits, indicating variability in sugar content.")
	@Unit("g/g")
	@Tags("Mean fruit dry, fresh weight and sugar concentrations")
	public float meanFruitSc_sd;
	
	/** Fruit diameter and volume */
	@JsonProperty(value = "diameter", index = 13)
	@JsonPropertyDescription("mean fruit diameter in cm")
	@Unit("cm")
	@Tags("Fruit diameter and volume")
	public float diameter;
	
	@JsonProperty(value = "vol", index = 14)
	@JsonPropertyDescription("Standard deviation of the sugar concentration in fruits, indicating variability in sugar content.")
	@Unit("cm^3")
	@Tags("Fruit diameter and volume")
	public float vol;
	
	@JsonProperty(value = "Afruit", index = 15)
	@JsonPropertyDescription("Fruit surface area in cm2")
	@Unit("cm^2")
	@Tags("Fruit diameter and volume")
	public float Afruit;
	
	
	/** Fruit Sugar Uptake */
	@JsonProperty(value = "unloadingPerFruit", index = 16)
	@JsonPropertyDescription(
		"Mean amount of carbon unloaded from phloem, measured in mg of carbon. The sugar format may change between sucrose and sorbitol."
	)
	@Unit("mgC")
	@Tags("Fruit Sugar Uptake")
	public double unloadingPerFruit;
	
	@JsonProperty(value = "sugarUptake_active", index = 17)
	@JsonPropertyDescription(
		"Mean rate of sucrose/other sugar actively taken up by each fruit, measured in mg of sugar."
	)
	@Unit("mgSugar")
	@Tags("Fruit Sugar Uptake")
	public float sugarUptake_active;
	
	@JsonProperty(value = "sugarUptake_passive", index = 18)
	@JsonPropertyDescription(
		"Mean rate of sucrose passively taken up by each fruit, measured in mg of sucrose."
	)
	@Unit("mgSugar")
	@Tags("Fruit Sugar Uptake")
	public double sugarUptake_passive;
	
	@JsonProperty(value = "sugarUptake_massflow", index = 19)
	@JsonPropertyDescription(
		"Mean rate of sucrose delivered to each fruit through mass flow, measured in mg of sucrose."
	)
	@Unit("mgSugar")
	@Tags("Fruit Sugar Uptake")
	public double sugarUptake_massflow;
	
	
	@JsonProperty(value = "maintenanceDM", index = 20)
	@JsonPropertyDescription(
	  "Carbon cost associated with maintaining the fruit metabolism, measured in mg/hour."
	)
	@Unit("mgC")
	@Tags("Fruit Sugar Uptake")
	public double maintenanceDM;
	
	@JsonProperty(value = "growthCost", index = 21)
	@JsonPropertyDescription(
	  "Carbon cost associated with growth of the fruit, measured in mg/hour."
	)
	@Unit("mgC")
	@Tags("Fruit Sugar Uptake")
	public double growthCost;
	
	
	/** Fruit Water Balance */
	@JsonProperty(value = "waterUptake", index = 22)
	@JsonPropertyDescription(
		"Total amount of water taken up by the fruit, measured in grams."
	)
	@Unit("g")
	@Tags("Fruit Water Balance")
	public double waterUptake;
	
	@JsonProperty(value = "waterUptake_xylem", index = 23)
	@JsonPropertyDescription(
		"Total amount of water taken up from xylem by the fruit, measured in grams."
	)
	@Unit("g")
	@Tags("Fruit Water Balance")
	public double waterUptake_xylem;
	
	@JsonProperty(value = "waterUptake_phloem", index = 24)
	@JsonPropertyDescription(
		"Total amount of water taken up from phloem by the fruit, measured in grams."
	)
	@Unit("g")
	@Tags("Fruit Water Balance")
	public double waterUptake_phloem;
	

	
	@JsonProperty(value = "transpirationLost", index = 25)
	@JsonPropertyDescription(
		"Amount of water lost from the plant via transpiration, measured in grams."
	)
	@Unit("g")
	@Tags("Fruit Water Balance")
	public double transpirationLost;
	
	
	/** Fruit Pressure Dynamics */
	@JsonProperty(value = "osmoticWaterPotential_fruit", index = 26)
	@JsonPropertyDescription(
		"Osmotic potential of water in the fruit, influencing water movement, measured in bar."
	)
	@Unit("bar")
	@Tags("Fruit Pressure Dynamics")
	public double osmoticWaterPotential_fruit;
	
	@JsonProperty(value = "turgorPressure_fruit", index = 27)
	@JsonPropertyDescription(
		"Pressure within fruit cells due to water uptake, measured in bar."
	)
	@Unit("bar")
	@Tags("Fruit Pressure Dynamics")
	public double turgorPressure_fruit;
	
	@JsonProperty(value = "waterPotential_fruit", index = 28)
	@JsonPropertyDescription(
		"Energy state of water within the fruit, measured in bar."
	)
	@Unit("bar")
	@Tags("Fruit Pressure Dynamics")
	public double waterPotential_fruit;
	
	/** Phloem Hydraulic Properties */
	@JsonProperty(value = "osmoticWaterPotential_phloem", index = 29)
	@JsonPropertyDescription(
		"Osmotic potential of water in the phloem, influencing sap flow, measured in bar."
	)
	@Unit("bar")
	@Tags("Phloem Hydraulic Properties")
	public double osmoticWaterPotential_phloem;
	
	@JsonProperty(value = "meanCpm", index = 30)
	@JsonPropertyDescription("Mean phloem sugar concentration mol/L.")
	@Unit("mol/L")
	@Tags("Customizable fruit output based on height input")
	public float fruit_cpm;
	
	@JsonProperty(value = "turgorPressure_phloem", index = 31)
	@JsonPropertyDescription(
		"Pressure within phloem cells due to water uptake, measured in bar."
	)
	@Unit("bar")
	@Tags("Phloem Hydraulic Properties")
	public double turgorPressure_phloem;
	
	@JsonProperty(value = "waterPotential_phloem", index = 32)
	@JsonPropertyDescription(
		"Energy state of water within the phloem, measured in bar."
	)
	@Unit("bar")
	@Tags("Phloem Hydraulic Properties")
	public double waterPotential_phloem;
	
	@JsonProperty(value = "Lphloem", index = 33)
	@JsonPropertyDescription(
		"Rate of water flow through the fruit phloem, measured in grams per square centimeter per bar per hour."
	)
	@Unit("g/cm²/bar/h")
	@Tags("Phloem Hydraulic Properties")
	public double Lphloem;
	
	@JsonProperty(value = "Lxylem", index = 34)
	@JsonPropertyDescription(
		"Rate of water flow through the fruit xylem, measured in grams per square centimeter per bar per hour."
	)
	@Unit("g/cm²/bar/h")
	@Tags("Phloem Hydraulic Properties")
	public double Lxylem;

	/** Osmotic Water Potential Partial Contribution */
	@JsonProperty(value = "osmoticWaterPotential_partialContribution", index = 35)
	@JsonPropertyDescription(
		"Partial contribution of osmotic water potential."
	)
	@Unit("bar")
	@Tags("Water Potential Properties")
	public double osmoticWaterPotential_partialContribution;
	
	/** Cell Wall Extensibility */
	@JsonProperty(value = "cellWallExtensibility", index = 36)
	@JsonPropertyDescription(
		"Cell wall extensibility, measured in per bar per hour."
	)
	@Unit("per.bar.h")
	@Tags("Cell Wall Properties")
	public double cellWallExtensibility;
	
	/** Elastic Modulus */
	@JsonProperty(value = "elasticModulus", index = 37)
	@JsonPropertyDescription(
		"Elastic modulus of the fruit, measured in bar."
	)
	@Unit("bar")
	@Tags("Elasticity Properties")
	public double elasticModulus;
	
	/** Skin Conductance (Ro) */
	@JsonProperty(value = "ro", index = 38)
	@JsonPropertyDescription(
		"Skin water flow resistance, measured in cm per hour."
	)
	@Unit("cm/h")
	@Tags("Skin Conductance")
	public double ro;
	
	/** Malic Acid Content */
	@JsonProperty(value = "malicAcid", index = 39)
	@JsonPropertyDescription(
		"Total malic acid content in the fruit, measured in mg."
	)
	@Unit("mg")
	@Tags("Acid Properties")
	public double malicAcid;
	
	/** Tartaric Acid Content */
	@JsonProperty(value = "tartaricAcid", index = 40)
	@JsonPropertyDescription(
		"Total tartaric acid content in the fruit, measured in mg."
	)
	@Unit("mg")
	@Tags("Acid Properties")
	public double tartaricAcid;
	
	/** Malic Acid Concentration in Fruit */
	@JsonProperty(value = "malicConcentration_fruit", index = 41)
	@JsonPropertyDescription(
		"Concentration of malic acid in fruit, measured in g/g."
	)
	@Unit("g/g")
	@Tags("Acid Properties")
	public double malicConcentration_fruit;
	
	/** Tartaric Acid Concentration in Fruit */
	@JsonProperty(value = "tartaricConcentration_fruit", index = 42)
	@JsonPropertyDescription(
		"Concentration of tartaric acid in fruit, measured in g/g."
	)
	@Unit("g/g")
	@Tags("Acid Properties")
	public double tartaricConcentration_fruit;

	/** Fruit Light Interception */
	@JsonProperty(value = "fruitIncidentPAR", index = 43)
	@JsonPropertyDescription(
		"Mean incident PAR at fruit surface area, measured in micromole per square meter per second."
	)
	@Unit("umol/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitIncidentPAR;

	@JsonProperty(value = "fruitAbsorbedPAR", index = 44)
	@JsonPropertyDescription(
		"Mean absorbed PAR by fruit, measured in micromole per second."
	)
	@Unit("umol/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedPAR;

	@JsonProperty(value = "fruitAbsorbedRadiation", index = 45)
	@JsonPropertyDescription(
		"Mean absorbed total radiation by fruit in the model radiation unit, measured per second."
	)
	@Unit("model_rad/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation;

	@JsonProperty(value = "fruitAbsorbedRadiation_m2", index = 46)
	@JsonPropertyDescription(
		"Mean absorbed total radiation by fruit per unit area in the model radiation unit."
	)
	@Unit("model_rad/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation_m2;

	@JsonProperty(value = "fruitLightArea_m2", index = 47)
	@JsonPropertyDescription(
		"Mean effective fruit area used in light interception calculations."
	)
	@Unit("m^2")
	@Tags("Fruit Light Interception")
	public double fruitLightArea_m2;

	@JsonProperty(value = "fruitBerryCountEffective", index = 48)
	@JsonPropertyDescription(
		"Mean effective berry count used in fruit light-area scaling."
	)
	@Tags("Fruit Light Interception")
	public double fruitBerryCountEffective;

	
	/** Customizable Fruit Metrics Based on Height */
	@JsonProperty(value = "totalFruitNumber_1", index = 49)
	@JsonPropertyDescription("Total number of fruits in zone 1 of the plant canopy.")
	@Tags("Customizable fruit output based on height input")
	public int totalFruitNumber_1;
	
	@JsonProperty(value = "totalFruitNumber_2", index = 50)
	@JsonPropertyDescription("Total number of fruits in zone 2 of the plant canopy.")
	@Tags("Customizable fruit output based on height input")
	public int totalFruitNumber_2;
	
	@JsonProperty(value = "totalFruitNumber_3", index = 51)
	@JsonPropertyDescription("Total number of fruits in zone 3 of the plant canopy.")
	@Tags("Customizable fruit output based on height input")
	public int totalFruitNumber_3;
	
	@JsonProperty(value = "totalFruitNumber_4", index = 52)
	@JsonPropertyDescription("Total number of fruits in zone 4 of the plant canopy.")
	@Tags("Customizable fruit output based on height input")
	public int totalFruitNumber_4;
	
	/** Customizable Mean Fresh Weight */
	@JsonProperty(value = "meanFruitFW_1", index = 53)
	@JsonPropertyDescription("Mean fresh weight of fruits in zone 1, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitFW_1;
	
	@JsonProperty(value = "meanFruitFW_2", index = 54)
	@JsonPropertyDescription("Mean fresh weight of fruits in zone 2, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitFW_2;
	
	@JsonProperty(value = "meanFruitFW_3", index = 55)
	@JsonPropertyDescription("Mean fresh weight of fruits in zone 3, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitFW_3;
	
	@JsonProperty(value = "meanFruitFW_4", index = 56)
	@JsonPropertyDescription("Mean fresh weight of fruits in zone 4, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitFW_4;
	
	/** Customizable Mean Dry Weight */
	@JsonProperty(value = "meanFruitDW_1", index = 57)
	@JsonPropertyDescription("Mean dry weight of fruits in zone 1, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitDW_1;
	
	@JsonProperty(value = "meanFruitDW_2", index = 58)
	@JsonPropertyDescription("Mean dry weight of fruits in zone 2, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitDW_2;
	
	@JsonProperty(value = "meanFruitDW_3", index = 59)
	@JsonPropertyDescription("Mean dry weight of fruits in zone 3, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitDW_3;
	
	@JsonProperty(value = "meanFruitDW_4", index = 60)
	@JsonPropertyDescription("Mean dry weight of fruits in zone 4, measured in mg.")
	@Unit("mg")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitDW_4;
	
	/** Customizable Mean Sugar Concentration */
	@JsonProperty(value = "meanFruitSc_1", index = 61)
	@JsonPropertyDescription("Mean sugar concentration of fruits in zone 1, measured in g/g.")
	@Unit("g/g")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitSc_1;
	
	@JsonProperty(value = "meanFruitSc_2", index = 62)
	@JsonPropertyDescription("Mean sugar concentration of fruits in zone 2, measured in g/g.")
	@Unit("g/g")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitSc_2;
	
	@JsonProperty(value = "meanFruitSc_3", index = 63)
	@JsonPropertyDescription("Mean sugar concentration of fruits in zone 3, measured in g/g.")
	@Unit("g/g")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitSc_3;
	
	@JsonProperty(value = "meanFruitSc_4", index = 64)
	@JsonPropertyDescription("Mean sugar concentration of fruits in zone 4, measured in g/g.")
	@Unit("g/g")
	@Tags("Customizable fruit output based on height input")
	public float meanFruitSc_4;
	
	
	@JsonProperty(value = "simuuid", index = 65)
	@JsonPropertyDescription("The unique simulation UUID assigned to each simulation run.")
	@Tags("Time and identifier")
	public String simuuid;

	/** Height-banded fruit light interception outputs */
	@JsonProperty(value = "fruitIncidentPAR_mean_1", index = 66)
	@JsonPropertyDescription("Mean incident fruit PAR in zone 1, measured in umol/m2/s.")
	@Unit("umol/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitIncidentPAR_mean_1;

	@JsonProperty(value = "fruitIncidentPAR_mean_2", index = 67)
	@JsonPropertyDescription("Mean incident fruit PAR in zone 2, measured in umol/m2/s.")
	@Unit("umol/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitIncidentPAR_mean_2;

	@JsonProperty(value = "fruitIncidentPAR_mean_3", index = 68)
	@JsonPropertyDescription("Mean incident fruit PAR in zone 3, measured in umol/m2/s.")
	@Unit("umol/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitIncidentPAR_mean_3;

	@JsonProperty(value = "fruitIncidentPAR_mean_4", index = 69)
	@JsonPropertyDescription("Mean incident fruit PAR in zone 4, measured in umol/m2/s.")
	@Unit("umol/m^2/s")
	@Tags("Fruit Light Interception")
	public double fruitIncidentPAR_mean_4;

	@JsonProperty(value = "fruitAbsorbedPAR_sum_1", index = 70)
	@JsonPropertyDescription("Sum of absorbed fruit PAR in zone 1, measured in umol/s.")
	@Unit("umol/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedPAR_sum_1;

	@JsonProperty(value = "fruitAbsorbedPAR_sum_2", index = 71)
	@JsonPropertyDescription("Sum of absorbed fruit PAR in zone 2, measured in umol/s.")
	@Unit("umol/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedPAR_sum_2;

	@JsonProperty(value = "fruitAbsorbedPAR_sum_3", index = 72)
	@JsonPropertyDescription("Sum of absorbed fruit PAR in zone 3, measured in umol/s.")
	@Unit("umol/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedPAR_sum_3;

	@JsonProperty(value = "fruitAbsorbedPAR_sum_4", index = 73)
	@JsonPropertyDescription("Sum of absorbed fruit PAR in zone 4, measured in umol/s.")
	@Unit("umol/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedPAR_sum_4;

	@JsonProperty(value = "fruitAbsorbedRadiation_sum_1", index = 74)
	@JsonPropertyDescription("Sum of absorbed total fruit radiation in zone 1.")
	@Unit("model_rad/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation_sum_1;

	@JsonProperty(value = "fruitAbsorbedRadiation_sum_2", index = 75)
	@JsonPropertyDescription("Sum of absorbed total fruit radiation in zone 2.")
	@Unit("model_rad/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation_sum_2;

	@JsonProperty(value = "fruitAbsorbedRadiation_sum_3", index = 76)
	@JsonPropertyDescription("Sum of absorbed total fruit radiation in zone 3.")
	@Unit("model_rad/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation_sum_3;

	@JsonProperty(value = "fruitAbsorbedRadiation_sum_4", index = 77)
	@JsonPropertyDescription("Sum of absorbed total fruit radiation in zone 4.")
	@Unit("model_rad/s")
	@Tags("Fruit Light Interception")
	public double fruitAbsorbedRadiation_sum_4;

	@JsonProperty(value = "fruitCount_1", index = 78)
	@JsonPropertyDescription("Number of fruit objects included in zone 1.")
	@Tags("Fruit Light Interception")
	public int fruitCount_1;

	@JsonProperty(value = "fruitCount_2", index = 79)
	@JsonPropertyDescription("Number of fruit objects included in zone 2.")
	@Tags("Fruit Light Interception")
	public int fruitCount_2;

	@JsonProperty(value = "fruitCount_3", index = 80)
	@JsonPropertyDescription("Number of fruit objects included in zone 3.")
	@Tags("Fruit Light Interception")
	public int fruitCount_3;

	@JsonProperty(value = "fruitCount_4", index = 81)
	@JsonPropertyDescription("Number of fruit objects included in zone 4.")
	@Tags("Fruit Light Interception")
	public int fruitCount_4;

	@JsonProperty(value = "fruitLightArea_sum_1", index = 82)
	@JsonPropertyDescription("Sum of effective fruit light area in zone 1.")
	@Unit("m^2")
	@Tags("Fruit Light Interception")
	public double fruitLightArea_sum_1;

	@JsonProperty(value = "fruitLightArea_sum_2", index = 83)
	@JsonPropertyDescription("Sum of effective fruit light area in zone 2.")
	@Unit("m^2")
	@Tags("Fruit Light Interception")
	public double fruitLightArea_sum_2;

	@JsonProperty(value = "fruitLightArea_sum_3", index = 84)
	@JsonPropertyDescription("Sum of effective fruit light area in zone 3.")
	@Unit("m^2")
	@Tags("Fruit Light Interception")
	public double fruitLightArea_sum_3;

	@JsonProperty(value = "fruitLightArea_sum_4", index = 85)
	@JsonPropertyDescription("Sum of effective fruit light area in zone 4.")
	@Unit("m^2")
	@Tags("Fruit Light Interception")
	public double fruitLightArea_sum_4;

	/** Mean fruit sugar-component carbon pools */
	@JsonProperty(value = "mSuc", index = 86)
	@JsonPropertyDescription("Mean sucrose carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mSuc;

	@JsonProperty(value = "mSor", index = 87)
	@JsonPropertyDescription("Mean sorbitol carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mSor;

	@JsonProperty(value = "mGlu", index = 88)
	@JsonPropertyDescription("Mean glucose carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mGlu;

	@JsonProperty(value = "mFru", index = 89)
	@JsonPropertyDescription("Mean fructose carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mFru;

	@JsonProperty(value = "mSta", index = 90)
	@JsonPropertyDescription("Mean starch carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mSta;

	@JsonProperty(value = "mSyn", index = 91)
	@JsonPropertyDescription("Mean other synthesized carbon mass per fruit, measured in grams of carbon.")
	@Unit("gC")
	@Tags("Fruit Sugar Components")
	public double mSyn;
		

}
