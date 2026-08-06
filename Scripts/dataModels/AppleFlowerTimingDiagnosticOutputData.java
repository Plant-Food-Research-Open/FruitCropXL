import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("apple-flower-timing-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppleFlowerTimingDiagnosticOutputData implements Serializable {
	private static final long serialVersionUID = 1L;

	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Simulation time stamp in ISO 8601 format.")
	@Tags("Timing")
	public String timestamp;

	@JsonProperty(value = "step", index = 1)
	@JsonPropertyDescription("Simulation step represented by the diagnostic row.")
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
	@JsonPropertyDescription("Plant identifier associated with the diagnostic row.")
	@Tags("Identifiers")
	public int plantNumber;

	@JsonProperty(value = "fieldInstanceId", index = 8)
	@JsonPropertyDescription("Field-instance identifier associated with the diagnostic row.")
	@Tags("Identifiers")
	public int fieldInstanceId;

	@JsonProperty(value = "recordType", index = 9)
	@JsonPropertyDescription("Flower-timing event type.")
	@Tags("Development state")
	public String recordType;

	@JsonProperty(value = "sourceApexID", index = 10)
	@JsonPropertyDescription("Graph identifier of the source apex.")
	@Tags("Architecture")
	public long sourceApexID;

	@JsonProperty(value = "flowerId", index = 11)
	@JsonPropertyDescription("Graph identifier of the flower.")
	@Tags("Architecture")
	public long flowerId;

	@JsonProperty(value = "sourceRosetteTarget", index = 12)
	@JsonPropertyDescription("Target number of source-rosette leaves.")
	@Tags("Development state")
	public int sourceRosetteTarget;

	@JsonProperty(value = "sourceRosetteAppearanceRank", index = 13)
	@JsonPropertyDescription("Source-rosette rank at flower appearance.")
	@Tags("Development state")
	public int sourceRosetteAppearanceRank;

	@JsonProperty(value = "apexBirthAge", index = 14)
	@JsonPropertyDescription("Source-apex age at birth in the active thermal-time scale.")
	@Tags("Timing")
	public double apexBirthAge;

	@JsonProperty(value = "apexBirthAgeD", index = 15)
	@JsonPropertyDescription("Source-apex day-age marker at birth.")
	@Unit("d")
	@Tags("Timing")
	public double apexBirthAgeD;

	@JsonProperty(value = "apexBirthAgeGdd", index = 16)
	@JsonPropertyDescription("Source-apex growing-degree-day marker at birth.")
	@Unit("degree d")
	@Tags("Timing")
	public double apexBirthAgeGdd;

	@JsonProperty(value = "apexAppearanceAge", index = 17)
	@JsonPropertyDescription("Source-apex age at flower appearance in the active thermal-time scale.")
	@Tags("Timing")
	public double apexAppearanceAge;

	@JsonProperty(value = "apexAppearanceAgeD", index = 18)
	@JsonPropertyDescription("Source-apex day-age marker at flower appearance.")
	@Unit("d")
	@Tags("Timing")
	public double apexAppearanceAgeD;

	@JsonProperty(value = "apexAppearanceAgeGdd", index = 19)
	@JsonPropertyDescription("Source-apex growing-degree-day marker at flower appearance.")
	@Unit("degree d")
	@Tags("Timing")
	public double apexAppearanceAgeGdd;

	@JsonProperty(value = "apexThermalSinceBudBurstAtAppearance", index = 20)
	@JsonPropertyDescription("Source-apex thermal time since bud burst at flower appearance.")
	@Tags("Timing")
	public double apexThermalSinceBudBurstAtAppearance;

	@JsonProperty(value = "currentApexThermalSinceBudBurst", index = 21)
	@JsonPropertyDescription("Current source-apex thermal time since bud burst.")
	@Tags("Timing")
	public double currentApexThermalSinceBudBurst;

	@JsonProperty(value = "floweringTDFromBudBurst", index = 22)
	@JsonPropertyDescription("Configured flowering thermal-time delay from bud burst.")
	@Tags("Development state")
	public double floweringTDFromBudBurst;

	@JsonProperty(value = "flowerLocalAge", index = 23)
	@JsonPropertyDescription("Local flower age in the active thermal-time scale.")
	@Tags("Timing")
	public double flowerLocalAge;

	@JsonProperty(value = "flowerLocalAgeD", index = 24)
	@JsonPropertyDescription("Local flower age in days.")
	@Unit("d")
	@Tags("Timing")
	public double flowerLocalAgeD;

	@JsonProperty(value = "hasFlowered", index = 25)
	@JsonPropertyDescription("Whether the flower has reached flowering.")
	@Tags("Development state")
	public boolean hasFlowered;

	@JsonProperty(value = "ageDAtFlowering", index = 26)
	@JsonPropertyDescription("Flower day-age recorded at flowering.")
	@Unit("d")
	@Tags("Timing")
	public double ageDAtFlowering;

	@JsonProperty(value = "daysAfterBloom", index = 27)
	@JsonPropertyDescription("Elapsed days since the recorded flowering age.")
	@Unit("d")
	@Tags("Timing")
	public double daysAfterBloom;

	@JsonProperty(value = "fruitingDaysAfterBloom", index = 28)
	@JsonPropertyDescription("Configured days after bloom required for fruit conversion.")
	@Unit("d")
	@Tags("Development state")
	public double fruitingDaysAfterBloom;
}


