
// ##############################################//
// 	Imports
// ##############################################//
import java.io.*;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.StringTokenizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import java.util.Arrays;
import java.lang.Math;
import java.util.stream.IntStream;
import com.fasterxml.jackson.databind.JsonNode;
import org.apache.commons.math3.distribution.*;
import de.grogra.gpuflux.tracer.FluxLightModelTracer.MeasureMode;
import de.grogra.graph.impl.GraphManager;
import de.grogra.graph.impl.Edge;
import de.grogra.graph.Graph;
import de.grogra.imp.IMPWorkbench;
import de.grogra.imp3d.View3D;
import de.grogra.persistence.Transaction;
import de.grogra.pf.ui.Context;
import de.grogra.pf.ui.util.LockProtectedCommand;
import de.grogra.pf.ui.JobManager;
import de.grogra.pf.ui.Command;
import de.grogra.pf.registry.Item;
import de.grogra.pf.registry.Registry;
import de.grogra.pf.ui.Workbench;
import de.grogra.pf.ui.JobManager;

import de.grogra.util.Lock;
import de.grogra.util.Utils;

//import dhs platform packages
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;


import plantBase.*;
import rootSystem.*;
import fieldBase.*;
import outputTables.*;

import cache.dhs.*;
import cache.dhs.Value;
import cache.dhs.Metadata;
import cache.dhs.Cache;
import cache.dhs.CacheResult;
import static globalParameters.*;
import static modelOptions.*;

/**************************************
 * Example code from functional testsuite
 * Reference<int> sv_int = new Reference<int>("fspm-apple", CSHARP_OWNER,
 * "test-category-csharp", "test-int-csharp");
 * Value int_initial_value = new Value(42, "m/s");
 * Metadata int_sv_metadata = new Metadata("description");
 * Cache.Register(sv_int, SV_DEST, CSHARP_OWNER, int_sv_metadata,
 * int_initial_value);
 * 
 * Value int_step_1_val = new Value(43, "m/s");
 * Cache.Write(sv_int, "1", int_step_1_val, CSHARP_OWNER);
 * 
 * var result = Cache.ReadArray<int>(ReferenceType.Statevariable, sv_int,
 * SV_DEST, "all");h
 ***************************************/

/**
 * CacheManager class for managing the state variables related to water uptake
 * in FruitCropXL.
 */

public class CacheManager {
	// static String FruitCropXL_water_OID = "2.999.1000.1.9.2.1.1.4";
	//System.out.println("cache-output-table: " + RequestHandler.hourly_results);
	static String ModelName = "FruitCropXL";
	static String FruitCropXL_water_OID = RequestHandler.hourly_results;
	static String Simulation_artifacts = RequestHandler.hourly_results + ".1";

	// Series oids for simulation artifacts
	static String xeg_series  = Simulation_artifacts + ".1";
	static String plant_level_series  = Simulation_artifacts + ".2";
	static String field_level_series  = Simulation_artifacts + ".3";
	static String visualisation_series  = Simulation_artifacts + ".4";

	static Metadata WU_Meta = new Metadata("Amount of water uptake from the soil layer, mm"); // converted from mg to mm
	static String WU_Unit = "mm";
	static Value WU_Val = new Value(0.1, WU_Unit); // converting water flux into mm
	public static double waterUptake_1;
	public static double waterUptake_2;
	public static double waterUptake_3;
	public static double waterUptake_4;
	static Reference wu_ref_1 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "water_uptake_L1");
	static Reference wu_ref_2 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "water_uptake_L2");
	static Reference wu_ref_3 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "water_uptake_L3");
	static Reference wu_ref_4 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "water_uptake_L4");

	static Metadata soluteNO3Uptake_Meta = new Metadata("Amount of NO3 uptake from the soil layer, kgha");
	static String soluteNO3Uptake_Unit = "kgha";
	static Value soluteNO3Uptake_Val = new Value(0.1, soluteNO3Uptake_Unit);
	public static double soluteNO3Uptake_1;
	public static double soluteNO3Uptake_2;
	public static double soluteNO3Uptake_3;
	public static double soluteNO3Uptake_4;
	static Reference soluteNO3Uptake_ref_1 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "NO3_uptake_L1");
	static Reference soluteNO3Uptake_ref_2 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "NO3_uptake_L2");
	static Reference soluteNO3Uptake_ref_3 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "NO3_uptake_L3");
	static Reference soluteNO3Uptake_ref_4 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "NO3_uptake_L4");

	static Metadata rootTurnover_Meta = new Metadata("Amount of root turnover at the soil layer, mg");
	static String rootTurnover_Unit = "mg";
	static Value rootTurnover_Val = new Value(0.1, rootTurnover_Unit);
	public static double rootTurnover_1;
	public static double rootTurnover_2;
	public static double rootTurnover_3;
	public static double rootTurnover_4;
	static Reference rootTurnover_ref_1 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_turnover_L1");
	static Reference rootTurnover_ref_2 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_turnover_L2");
	static Reference rootTurnover_ref_3 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_turnover_L3");
	static Reference rootTurnover_ref_4 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_turnover_L4");

	static Metadata rootCarbonExudation_Meta = new Metadata("Amount of root carbon exudation at the soil layer, mg");
	static String rootCarbonExudation_Unit = "mg";
	static Value rootCarbonExudation_Val = new Value(0.1, rootCarbonExudation_Unit);
	public static double rootCarbonExudation_1;
	public static double rootCarbonExudation_2;
	public static double rootCarbonExudation_3;
	public static double rootCarbonExudation_4;
	static Reference rootCarbonExudation_ref_1 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_carbon_exudation_L1");
	static Reference rootCarbonExudation_ref_2 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_carbon_exudation_L2");
	static Reference rootCarbonExudation_ref_3 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_carbon_exudation_L3");
	static Reference rootCarbonExudation_ref_4 = new Reference(Cache.ValueType.DOUBLE, ModelName, "soil", "root", "root_carbon_exudation_L4");

	// simulation time
	static Metadata timestamp_Meta = new Metadata("Timestamp for current simulation step");
	static Reference pb_timestamp_ref  = new Reference(Cache.ValueType.STRING, ModelName, "simulation", "time", "timestamp");
	static Value     timestamp_Val  = new Value("", "timestamp");
	
	static Metadata doy_Meta = new Metadata("Day-of-year for current simulation step");
	static Reference pb_doy_ref  = new Reference(Cache.ValueType.INT, ModelName, "simulation", "time", "day-of-year");
	static Value     doy_Val  = new Value(0, "doy");
	
	
	// -- plant properties --
	static Reference pb_carbon_leaf_loading_ref      = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "carbon", "leaf-loading");
	static Reference pb_carbon_internode_loading_ref = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "carbon", "internode-loading");
	static Reference pb_carbon_sroot_loading_ref     = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "carbon", "sroot-loading");

	static Reference pb_carbon_internode_unloading_ref = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "carbon", "internode-unloading");
	static Reference pb_carbon_sroot_unloading_ref     = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "carbon", "sroot-unloading");

	static Metadata biomass_leaf_Meta = new Metadata("Plant level Leaf biomass");
	static Metadata biomass_fruit_Meta = new Metadata("Plant level fruit biomass");
	static Reference pb_biomass_leaf_ref     = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "biomass", "leaf-biomass");
	static Reference pb_biomass_fruit_ref     = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "biomass", "fruit-biomass");
	static Value     initial_biomass_Val  = new Value(0, "g"); 

	static Metadata leaf_area_Meta = new Metadata("Plant level leaf area");
	static Value leaf_area_Val = new Value(0.1, "cm^2");
	static Reference pb_leaf_area_ref = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "structure", "leaf-area");
	
	static Metadata plant_height_Meta = new Metadata("Plant height");
	static Value plant_height_Val = new Value(0.1, "m");
	static Reference pb_plant_height_ref = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "structure", "plant-height");

	// -- sugar --
	static Metadata phloemSugarConc_Meta = new Metadata(" ");
	static Value phloemSugarConc_Val = new Value(0.1, "g_sugar/g_solution");
	static Reference pb_phloem_sugar_ref = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "phloem", "sugar_conc");
	
	// fruit properties
	static Metadata meanFruitDW_Meta = new Metadata("mean fruit DW (g)");
	static Value meanFruitDW_Val = new Value(0.0, "g");
	static Reference meanFruitDW_ref   = new Reference(Cache.ValueType.DOUBLE,  ModelName, "plant", "fruit", "meanFruitDW");


    // -- Surface radiation --
	static Metadata parGround_Meta = new Metadata("Amount of PAR that reaches the ground, Î¼mol photons m-2 s-1");
	static String parGround_Unit = "Î¼mol photons m-2 s-1";
	static Value parGround_Val = new Value(0.1, parGround_Unit);
	public static double parGround;
	static Reference parGround_ref = new Reference(Cache.ValueType.DOUBLE, ModelName, "ground_surface", "physical", "par_ground");



	static Reference swc_ref_1 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "water", "soilpatch_swc_L1");
	static Reference swc_ref_2 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "water", "soilpatch_swc_L2");
	static Reference swc_ref_3 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "water", "soilpatch_swc_L3");
	static Reference swc_ref_4 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "water", "soilpatch_swc_L4");

	static Reference soluteNO3_ref_1 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "nutrient", "soilpatch_soluteNO3_L1");
	static Reference soluteNO3_ref_2 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "nutrient", "soilpatch_soluteNO3_L2");
	static Reference soluteNO3_ref_3 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "nutrient", "soilpatch_soluteNO3_L3");
	static Reference soluteNO3_ref_4 = new Reference(Cache.ValueType.DOUBLE, "SoilPatch", "soil", "nutrient", "soilpatch_soluteNO3_L4");

	static Reference soilTemp_ref_1 = new Reference(Cache.ValueType.DOUBLE, "SoilTemp", "soil", "physical", "soiltemp_soil_L1");
	static Reference soilTemp_ref_2 = new Reference(Cache.ValueType.DOUBLE, "SoilTemp", "soil", "physical", "soiltemp_soil_L2");
	static Reference soilTemp_ref_3 = new Reference(Cache.ValueType.DOUBLE, "SoilTemp", "soil", "physical", "soiltemp_soil_L3");
	static Reference soilTemp_ref_4 = new Reference(Cache.ValueType.DOUBLE, "SoilTemp", "soil", "physical", "soiltemp_soil_L4");


    

	/**
	 * Registers state variables with the Cache system.
	 * This should be called once before the simulation begins to set up the initial
	 * state.
	 */
	public static void registerStateVariables() {
		Cache.Register(wu_ref_1, FruitCropXL_water_OID, ModelName, WU_Meta, WU_Val);
		Cache.Register(wu_ref_2, FruitCropXL_water_OID, ModelName, WU_Meta, WU_Val);
		Cache.Register(wu_ref_3, FruitCropXL_water_OID, ModelName, WU_Meta, WU_Val);
		Cache.Register(wu_ref_4, FruitCropXL_water_OID, ModelName, WU_Meta, WU_Val);

		Cache.Register(soluteNO3Uptake_ref_1, FruitCropXL_water_OID, ModelName, soluteNO3Uptake_Meta, soluteNO3Uptake_Val);
		Cache.Register(soluteNO3Uptake_ref_2, FruitCropXL_water_OID, ModelName, soluteNO3Uptake_Meta, soluteNO3Uptake_Val);
		Cache.Register(soluteNO3Uptake_ref_3, FruitCropXL_water_OID, ModelName, soluteNO3Uptake_Meta, soluteNO3Uptake_Val);
		Cache.Register(soluteNO3Uptake_ref_4, FruitCropXL_water_OID, ModelName, soluteNO3Uptake_Meta, soluteNO3Uptake_Val);

		Cache.Register(rootTurnover_ref_1, FruitCropXL_water_OID, ModelName, rootTurnover_Meta, rootTurnover_Val);
		Cache.Register(rootTurnover_ref_2, FruitCropXL_water_OID, ModelName, rootTurnover_Meta, rootTurnover_Val);
		Cache.Register(rootTurnover_ref_3, FruitCropXL_water_OID, ModelName, rootTurnover_Meta, rootTurnover_Val);
		Cache.Register(rootTurnover_ref_4, FruitCropXL_water_OID, ModelName, rootTurnover_Meta, rootTurnover_Val);		

		Cache.Register(rootCarbonExudation_ref_1, FruitCropXL_water_OID, ModelName, rootCarbonExudation_Meta, rootCarbonExudation_Val);
		Cache.Register(rootCarbonExudation_ref_2, FruitCropXL_water_OID, ModelName, rootCarbonExudation_Meta, rootCarbonExudation_Val);
		Cache.Register(rootCarbonExudation_ref_3, FruitCropXL_water_OID, ModelName, rootCarbonExudation_Meta, rootCarbonExudation_Val);
		Cache.Register(rootCarbonExudation_ref_4, FruitCropXL_water_OID, ModelName, rootCarbonExudation_Meta, rootCarbonExudation_Val);

		Cache.Register(pb_phloem_sugar_ref, FruitCropXL_water_OID, ModelName, phloemSugarConc_Meta, phloemSugarConc_Val);
		Cache.Register(parGround_ref, FruitCropXL_water_OID, ModelName, parGround_Meta, parGround_Val);
		
		Cache.Register(pb_timestamp_ref, FruitCropXL_water_OID, ModelName, timestamp_Meta, timestamp_Val);
		Cache.Register(pb_doy_ref, FruitCropXL_water_OID, ModelName, doy_Meta, doy_Val);

		Cache.Register(pb_biomass_leaf_ref, FruitCropXL_water_OID, ModelName, biomass_leaf_Meta, initial_biomass_Val);
		Cache.Register(pb_biomass_fruit_ref, FruitCropXL_water_OID, ModelName, biomass_fruit_Meta, initial_biomass_Val);

		Cache.Register(pb_leaf_area_ref, FruitCropXL_water_OID, ModelName, leaf_area_Meta, leaf_area_Val);
		Cache.Register(pb_plant_height_ref, FruitCropXL_water_OID, ModelName, plant_height_Meta, plant_height_Val);

		Cache.Register(meanFruitDW_ref, FruitCropXL_water_OID, ModelName, meanFruitDW_Meta, meanFruitDW_Val);
	}

	/**
	 * Writes the state variables for water uptake at a specific simulation step.
	 * 
	 * @param step      The simulation step at which the state variables are being
	 *                  recorded.
	 * @param waterUptake_mm The array of water flux values for different layers to be
	 *                  written.
	 */
	public static void writeWaterUptake(int step, double[] waterUptake_mm) {
		// Write state variables, replace with actual step logic if necessary
		Cache.Write(wu_ref_1, String.valueOf(step), new Value(waterUptake_mm[0], WU_Unit), ModelName);
		Cache.Write(wu_ref_2, String.valueOf(step), new Value(waterUptake_mm[1], WU_Unit), ModelName);
		Cache.Write(wu_ref_3, String.valueOf(step), new Value(waterUptake_mm[2], WU_Unit), ModelName);
		Cache.Write(wu_ref_4, String.valueOf(step), new Value(waterUptake_mm[3], WU_Unit), ModelName);
	}

	/**
	 * Reads the state variables for water uptake from the cache for a given
	 * simulation step.
	 * 
	 * @param step The simulation step for which the state variables should be read.
	 */
	public static void readWaterUptake(int step) {
		// ReadArray() does not work properbly in GroIMP
		// Read state variables

		// Water uptake
		waterUptake_1 = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, wu_ref_1, FruitCropXL_water_OID, String.valueOf(step)), 2);
		waterUptake_2 = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, wu_ref_2, FruitCropXL_water_OID, String.valueOf(step)), 2);
		waterUptake_3 = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, wu_ref_3, FruitCropXL_water_OID, String.valueOf(step)), 2);
		waterUptake_4 = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, wu_ref_4, FruitCropXL_water_OID, String.valueOf(step)), 2);
	}

	/**
	 * Writes the state variables for NO3 uptake at a specific simulation step.
	 * 
	 * @param step      The simulation step at which the state variables are being
	 *                  recorded.
	 * @param soluteNO3Uptake The array of NO3 uptake values for different layers to be
	 *                  written.
	 */
	public static void writeSolubleNitrogenUptake(int step, double[] soluteNO3Uptake) {
		Cache.Write(soluteNO3Uptake_ref_1, String.valueOf(step), new Value(soluteNO3Uptake[0], soluteNO3Uptake_Unit), ModelName);
		Cache.Write(soluteNO3Uptake_ref_2, String.valueOf(step), new Value(soluteNO3Uptake[1], soluteNO3Uptake_Unit), ModelName);
		Cache.Write(soluteNO3Uptake_ref_3, String.valueOf(step), new Value(soluteNO3Uptake[2], soluteNO3Uptake_Unit), ModelName);
		Cache.Write(soluteNO3Uptake_ref_4, String.valueOf(step), new Value(soluteNO3Uptake[3], soluteNO3Uptake_Unit), ModelName);
	}

	/**
	 * Writes the state variables for root turnover at a specific simulation step.
	 * 
	 * @param step      The simulation step at which the state variables are being
	 *                  recorded.
	 * @param soluteNO3Uptake The array of NO3 uptake values for different layers to be
	 *                  written.
	 */
	public static void writeRootTurnover(int step, double[] rootTurnover) {
		Cache.Write(rootTurnover_ref_1, String.valueOf(step), new Value(rootTurnover[0], rootTurnover_Unit), ModelName);
		Cache.Write(rootTurnover_ref_2, String.valueOf(step), new Value(rootTurnover[1], rootTurnover_Unit), ModelName);
		Cache.Write(rootTurnover_ref_3, String.valueOf(step), new Value(rootTurnover[2], rootTurnover_Unit), ModelName);
		Cache.Write(rootTurnover_ref_4, String.valueOf(step), new Value(rootTurnover[3], rootTurnover_Unit), ModelName);
	}

	/**
	 * Writes the state variables for root carbon exudation at a specific simulation step.
	 * 
	 * @param step      The simulation step at which the state variables are being
	 *                  recorded.
	 * @param soluteNO3Uptake The array of NO3 uptake values for different layers to be
	 *                  written.
	 */
	public static void writeRootCarbonExudation(int step, double[] rootCarbonExudation) {
		Cache.Write(rootCarbonExudation_ref_1, String.valueOf(step), new Value(rootCarbonExudation[0], rootCarbonExudation_Unit), ModelName);
		Cache.Write(rootCarbonExudation_ref_2, String.valueOf(step), new Value(rootCarbonExudation[1], rootCarbonExudation_Unit), ModelName);
		Cache.Write(rootCarbonExudation_ref_3, String.valueOf(step), new Value(rootCarbonExudation[2], rootCarbonExudation_Unit), ModelName);
		Cache.Write(rootCarbonExudation_ref_4, String.valueOf(step), new Value(rootCarbonExudation[3], rootCarbonExudation_Unit), ModelName);
	}


	/**
	 * Writes the state variables for PAR that reaches the ground at a specific simulation step.
	 * 
	 * @param step      The simulation step at which the state variables are being
	 *                  recorded.
	 * @param soluteNO3Uptake The array of NO3 uptake values for different layers to be
	 *                  written.
	 */
	public static void writeRootCarbonExudation(int step, double parGround) {
		// TODO incomingRadiation * fPARGlobal * fparGround
		Cache.Write(parGround_ref, String.valueOf(step), new Value(parGround, parGround_Unit), ModelName);
	}


	/**
	 * TODO:
	 * See how to best structure methods for ordering when cache reads occur during run phase.
	 * For example, separate out waterUptake and soilWaterContent cache reads into a separate class which provides these reading methods
	 * to be called on demand.
	 */
	public static void readSoilWaterContent(int step) {
		soilWaterContentArray[0] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, swc_ref_1, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilWaterContentArray[1] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, swc_ref_2, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilWaterContentArray[2] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, swc_ref_3, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilWaterContentArray[3] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, swc_ref_4, FruitCropXL_water_OID, String.valueOf(step)), 2);
	}

	public static void readSoilSolubleNitrogenContent(int step) {
		soilSoluteNO3ContentArray[0] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soluteNO3_ref_1, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilSoluteNO3ContentArray[1] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soluteNO3_ref_2, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilSoluteNO3ContentArray[2] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soluteNO3_ref_3, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilSoluteNO3ContentArray[3] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soluteNO3_ref_4, FruitCropXL_water_OID, String.valueOf(step)), 2);
	}

	public static void readSoilTemperature(int step) {
		soilTempContentArray[0] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soilTemp_ref_1, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilTempContentArray[1] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soilTemp_ref_2, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilTempContentArray[2] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soilTemp_ref_3, FruitCropXL_water_OID, String.valueOf(step)), 2);
		soilTempContentArray[3] = (Double) handleCacheResult(Cache.Read(Cache.ReferenceType.STATEVARIABLE, soilTemp_ref_4, FruitCropXL_water_OID, String.valueOf(step)), 2);
	}

	/**
	 * Handles the result from a cache query and casts it to the desired type.
	 * 
	 * @param result     The CacheResult returned from a cache read operation.
	 * @param resultType An integer indicating the expected return type: 1 for
	 *                   Integer, 2 for Double.
	 * @return The data object cast to the specified type, or null if an error
	 *         occurs.
	 */
	private static Object handleCacheResult(CacheResult result, int resultType) {
		System.out.println("status code: " + result.getStatusCode());
		Object res = null;
		try {
			if (resultType == 1) {
				// Assuming getData() is properly returning an Object that can be cast to
				res = (Integer) result.getData();
			} else if (resultType == 2) {
				// Assuming getData() is properly returning an Object that can be cast to
				res = (Double) result.getData();
			}
		} catch (ClassCastException e) {
			System.err.println("Failed to cast result data for type: " + resultType);
		} catch (NullPointerException e) {
			System.err.println("Received null data for type: " + resultType);
		}
		return res;
	}
	
	public static String getVisualisationSeries(String outputFormat) {
		String oid_series;
		int i, result;
		
		String[] mappedFormats = {"unknown", "ply", "sty", "obj", "xeg", "dxf", "x3d", "mtg", "tex", "webgl"};
		result = 0;
		for ( i=0; i < mappedFormats.length; i++) {
			if (outputFormat == mappedFormats[i]) {
				result = i;
				System.out.println("*** found format" + i + " " + mappedFormats[i]);
				break;
			}
		}
		oid_series = CacheManager.visualisation_series + "." + Integer.toString(result);
		return oid_series;
	}
	
	public static void write_pb_variables(int step, PlantBase pb) {
		String step_s = Integer.toString(step);
		

		// write registered plantbase state-variables to cache
		Cache.Write(pb_timestamp_ref, step_s, new Value(globalParameters.timestamp, "timestamp"), ModelName);
		Cache.Write(pb_doy_ref, step_s, new Value(globalParameters.dayOfYear, "doy"), ModelName);
		Cache.Write(pb_phloem_sugar_ref, step_s, new Value(pb.sugarConcentration_phloem, "g_sugar/g_solution"), ModelName);
		Cache.Write(pb_biomass_leaf_ref, step_s, new Value(pb.biomassLeaf, "g"), ModelName);
		Cache.Write(pb_biomass_fruit_ref, step_s, new Value(pb.biomassFruit, "g"), ModelName);
		Cache.Write(pb_leaf_area_ref, step_s, new Value(pb.leafArea, "cm^2"), ModelName);
		Cache.Write(pb_plant_height_ref, step_s, new Value(pb.plantHeight, "m"), ModelName);
		
	}

	public static void write_rb_variables(int step, RootBase rb) {
		String step_s = Integer.toString(step);
		
		// write registered rootbase state-variables to cache
	}

	public static void write_fb_variables(int step, FieldBase fb) {
		String step_s = Integer.toString(step);
		
		// write registered fieldbase state-variables to cache
	}

	public static void write_misc_outputs(int step) {
		String step_s = Integer.toString(step);
		// double dw_mean = outputTables.dw_mean;

		// write various globally defined outputs to cache
		Cache.Write(meanFruitDW_ref, step_s, new Value((double)outputTables.dw_mean, "g"), ModelName);
	}
	
}
