import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("leaf-expansion-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LeafExpansionDiagnosticOutputData implements Serializable {
	private static final long serialVersionUID = 1L;

	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Simulation time stamp in ISO 8601 format.")
	@Tags("Timing")
	public String timestamp;

	@JsonProperty(value = "step", index = 1)
	@JsonPropertyDescription("Simulation step at which the leaf diagnostic was sampled.")
	@Tags("Timing")
	public int step;

	@JsonProperty(value = "year", index = 2)
	@JsonPropertyDescription("Simulation year.")
	@Tags("Timing")
	public int year;

	@JsonProperty(value = "dayOfYear", index = 3)
	@JsonPropertyDescription("Simulation day of year.")
	@Tags("Timing")
	public int dayOfYear;

	@JsonProperty(value = "hourOfDay", index = 4)
	@JsonPropertyDescription("Simulation hour of day.")
	@Tags("Timing")
	public int hourOfDay;

	@JsonProperty(value = "scenario", index = 5)
	@JsonPropertyDescription("Internal scenario number for the simulation.")
	@Tags("Identifiers")
	public int scenario;

	@JsonProperty(value = "simuuid", index = 6)
	@JsonPropertyDescription("Unique simulation UUID assigned to the run.")
	@Tags("Identifiers")
	public String simuuid;

	@JsonProperty(value = "plantNumber", index = 7)
	@JsonPropertyDescription("Plant identifier associated with the leaf.")
	@Tags("Identifiers")
	public int plantNumber;

	@JsonProperty(value = "fieldInstanceId", index = 8)
	@JsonPropertyDescription("Field-instance identifier associated with the leaf.")
	@Tags("Identifiers")
	public int fieldInstanceId;

	@JsonProperty(value = "cordonNumber", index = 9)
	@JsonPropertyDescription("Cordon identifier recorded on the leaf.")
	@Tags("Architecture")
	public long cordonNumber;

	@JsonProperty(value = "nodeNumber", index = 10)
	@JsonPropertyDescription("Node number recorded on the leaf.")
	@Tags("Architecture")
	public long nodeNumber;

	@JsonProperty(value = "rank", index = 11)
	@JsonPropertyDescription("Leaf rank on its axis.")
	@Tags("Architecture")
	public long rank;

	@JsonProperty(value = "leafId", index = 12)
	@JsonPropertyDescription("Graph identifier of the leaf.")
	@Tags("Identifiers")
	public long leafId;

	@JsonProperty(value = "appleLeafDevelopmentClass", index = 13)
	@JsonPropertyDescription("Apple leaf-development class assigned by the active development module.")
	@Tags("Development state")
	public String appleLeafDevelopmentClass;

	@JsonProperty(value = "fastEarlyExpansionLeaf", index = 14)
	@JsonPropertyDescription("Whether the leaf uses the fast early-expansion timing pathway.")
	@Tags("Development state")
	public boolean fastEarlyExpansionLeaf;

	@JsonProperty(value = "rosetteExpansionScaleUsed", index = 15)
	@JsonPropertyDescription("Rosette timing scale applied to leaf expansion.")
	@Unit("-")
	@Tags("Development state")
	public double rosetteExpansionScaleUsed;

	@JsonProperty(value = "debugValid", index = 16)
	@JsonPropertyDescription("Whether the decomposition values were refreshed during this simulation step.")
	@Tags("Development state")
	public boolean debugValid;

	@JsonProperty(value = "dbg_validStep", index = 17)
	@JsonPropertyDescription("Simulation step when the expansion decomposition was last refreshed.")
	@Tags("Timing")
	public int dbg_validStep;

	@JsonProperty(value = "age", index = 18)
	@JsonPropertyDescription("Current leaf age in the active model thermal-time scale.")
	@Tags("Development state")
	public double age;

	@JsonProperty(value = "isGrowing", index = 19)
	@JsonPropertyDescription("Whether leaf age is below its expansion end time.")
	@Tags("Development state")
	public boolean isGrowing;

	@JsonProperty(value = "dbg_growthActive", index = 20)
	@JsonPropertyDescription("Stored expansion-window activity flag for the sampled step.")
	@Tags("Development state")
	public int dbg_growthActive;

	@JsonProperty(value = "length", index = 21)
	@JsonPropertyDescription("Current leaf length.")
	@Unit("m")
	@Tags("Architecture")
	public double length;

	@JsonProperty(value = "area", index = 22)
	@JsonPropertyDescription("Current leaf area.")
	@Unit("m2")
	@Tags("Architecture")
	public double area;

	@JsonProperty(value = "potentialFinalSize", index = 23)
	@JsonPropertyDescription("Potential final leaf area before realization constraints.")
	@Unit("m2")
	@Tags("Development state")
	public double potentialFinalSize;

	@JsonProperty(value = "realizedFinalSize", index = 24)
	@JsonPropertyDescription("Realized final leaf-area target after initialization constraints.")
	@Unit("m2")
	@Tags("Development state")
	public double realizedFinalSize;

	@JsonProperty(value = "profileFinalSizeLocked", index = 25)
	@JsonPropertyDescription("Whether a profile-derived final-size target is locked against replacement.")
	@Tags("Development state")
	public boolean profileFinalSizeLocked;

	@JsonProperty(value = "currentAreaToRealizedFinalRatio", index = 26)
	@JsonPropertyDescription("Current leaf area divided by the realized final-area target.")
	@Unit("-")
	@Tags("Development state")
	public double currentAreaToRealizedFinalRatio;

	@JsonProperty(value = "maxLength", index = 27)
	@JsonPropertyDescription("Configured maximum leaf length.")
	@Unit("m")
	@Tags("Development state")
	public double maxLength;

	@JsonProperty(value = "potLength", index = 28)
	@JsonPropertyDescription("Potential leaf length before water and carbon limitations.")
	@Unit("m")
	@Tags("Development state")
	public double potLength;

	@JsonProperty(value = "tm", index = 29)
	@JsonPropertyDescription("Leaf expansion timing parameter tm in the active thermal-time scale.")
	@Tags("Development state")
	public double tm;

	@JsonProperty(value = "te", index = 30)
	@JsonPropertyDescription("Leaf expansion end time in the active thermal-time scale.")
	@Tags("Development state")
	public double te;

	@JsonProperty(value = "parentID", index = 31)
	@JsonPropertyDescription("Stored graph identifier of the parent organ.")
	@Tags("Architecture")
	public long parentID;

	@JsonProperty(value = "plantBaseID", index = 32)
	@JsonPropertyDescription("Stored graph identifier of the owning PlantBase.")
	@Tags("Identifiers")
	public long plantBaseID;

	@JsonProperty(value = "earlyLeafFallbackUsedThisStep", index = 33)
	@JsonPropertyDescription("Whether the early-leaf light fallback was used during this step.")
	@Tags("Development state")
	public boolean earlyLeafFallbackUsedThisStep;

	@JsonProperty(value = "hasValidLeafLightForPhotosynthesis", index = 34)
	@JsonPropertyDescription("Whether the leaf has a finite positive light result suitable for photosynthesis.")
	@Tags("Development state")
	public boolean hasValidLeafLightForPhotosynthesis;

	@JsonProperty(value = "incPARm2", index = 35)
	@JsonPropertyDescription("Incident photosynthetically active radiation per leaf area.")
	@Unit("umol/m2/s")
	@Tags("Light")
	public double incPARm2;

	@JsonProperty(value = "absm2", index = 36)
	@JsonPropertyDescription("Total absorbed radiation per leaf area.")
	@Unit("umol/m2/s")
	@Tags("Light")
	public double absm2;

	@JsonProperty(value = "absPAR", index = 37)
	@JsonPropertyDescription("Total photosynthetically active radiation absorbed by the leaf.")
	@Unit("umol/s")
	@Tags("Light")
	public double absPAR;

	@JsonProperty(value = "PAnet", index = 38)
	@JsonPropertyDescription("Potential net leaf photosynthesis before hydraulic limitation.")
	@Unit("umol CO2/m2/s")
	@Tags("Carbon")
	public double PAnet;

	@JsonProperty(value = "Anet", index = 39)
	@JsonPropertyDescription("Realized net leaf photosynthesis.")
	@Unit("umol CO2/m2/s")
	@Tags("Carbon")
	public double Anet;

	@JsonProperty(value = "waterFluxPotential", index = 40)
	@JsonPropertyDescription("Potential leaf water flux used by the hydraulic calculation.")
	@Unit("mg/leaf/s")
	@Tags("Water")
	public double waterFluxPotential;

	@JsonProperty(value = "Lpot", index = 41)
	@JsonPropertyDescription("Potential elongation increment before stress multipliers.")
	@Unit("m")
	@Tags("Development state")
	public double Lpot;

	@JsonProperty(value = "fw", index = 42)
	@JsonPropertyDescription("Water-stress multiplier on leaf elongation.")
	@Unit("-")
	@Tags("Water")
	public double fw;

	@JsonProperty(value = "fc", index = 43)
	@JsonPropertyDescription("Carbon-stress multiplier on leaf elongation.")
	@Unit("-")
	@Tags("Carbon")
	public double fc;

	@JsonProperty(value = "dL_pot", index = 44)
	@JsonPropertyDescription("Leaf elongation increment at the potential stage.")
	@Unit("m")
	@Tags("Development state")
	public double dL_pot;

	@JsonProperty(value = "dL_w", index = 45)
	@JsonPropertyDescription("Leaf elongation increment after water limitation.")
	@Unit("m")
	@Tags("Water")
	public double dL_w;

	@JsonProperty(value = "dL_final", index = 46)
	@JsonPropertyDescription("Leaf elongation increment after water and carbon limitation.")
	@Unit("m")
	@Tags("Development state")
	public double dL_final;

	@JsonProperty(value = "dA_pot", index = 47)
	@JsonPropertyDescription("Leaf-area increment at the potential stage.")
	@Unit("m2")
	@Tags("Development state")
	public double dA_pot;

	@JsonProperty(value = "dA_w", index = 48)
	@JsonPropertyDescription("Leaf-area increment after water limitation.")
	@Unit("m2")
	@Tags("Water")
	public double dA_w;

	@JsonProperty(value = "dA_final", index = 49)
	@JsonPropertyDescription("Leaf-area increment after water and carbon limitation.")
	@Unit("m2")
	@Tags("Development state")
	public double dA_final;

	@JsonProperty(value = "waterPotential", index = 50)
	@JsonPropertyDescription("Committed leaf water potential.")
	@Unit("MPa")
	@Tags("Water")
	public double waterPotential;

	@JsonProperty(value = "sugarConcentration_phloem", index = 51)
	@JsonPropertyDescription("Phloem sugar concentration used for leaf sink unloading.")
	@Tags("Carbon")
	public double sugarConcentration_phloem;

	@JsonProperty(value = "structureDM_PRI_PT", index = 52)
	@JsonPropertyDescription("Potential primary structural carbon demand of the leaf.")
	@Unit("mg C")
	@Tags("Carbon")
	public double structureDM_PRI_PT;

	@JsonProperty(value = "structureDM", index = 53)
	@JsonPropertyDescription("Realized structural carbon allocation to the leaf.")
	@Unit("mg C")
	@Tags("Carbon")
	public double structureDM;

	@JsonProperty(value = "unloading", index = 54)
	@JsonPropertyDescription("Carbon unloaded from the phloem to the leaf during the step.")
	@Unit("mg C")
	@Tags("Carbon")
	public double unloading;

	@JsonProperty(value = "carbon_nonStructure", index = 55)
	@JsonPropertyDescription("Leaf non-structural carbon pool.")
	@Unit("mg C")
	@Tags("Carbon")
	public double carbon_nonStructure;

	@JsonProperty(value = "fNSC", index = 56)
	@JsonPropertyDescription("Fraction of leaf total carbon held as non-structural carbon.")
	@Unit("-")
	@Tags("Carbon")
	public double fNSC;

	@JsonProperty(value = "loading", index = 57)
	@JsonPropertyDescription("Carbon loaded from the leaf into the phloem during the step.")
	@Unit("mg C")
	@Tags("Carbon")
	public double loading;

	@JsonProperty(value = "carbonAssimilation", index = 58)
	@JsonPropertyDescription("Carbon assimilated by the leaf during the step.")
	@Unit("mg C")
	@Tags("Carbon")
	public double carbonAssimilation;

	@JsonProperty(value = "maintenanceDM", index = 59)
	@JsonPropertyDescription("Realized leaf maintenance-respiration carbon cost.")
	@Unit("mg C/h")
	@Tags("Carbon")
	public double maintenanceDM;
}


