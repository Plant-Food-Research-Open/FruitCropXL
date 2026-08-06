import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("actual-leaf-summary-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ActualLeafSummaryDiagnosticOutputData implements Serializable {
	private static final long serialVersionUID = 1L;

	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Simulation time stamp in ISO 8601 format.")
	@Tags("Timing")
	public String timestamp;

	@JsonProperty(value = "step", index = 1)
	@JsonPropertyDescription("Simulation step represented by the summary.")
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
	@JsonPropertyDescription("Plant identifier represented by the summary.")
	@Tags("Identifiers")
	public int plantNumber;

	@JsonProperty(value = "fieldInstanceId", index = 8)
	@JsonPropertyDescription("Field-instance identifier represented by the summary.")
	@Tags("Identifiers")
	public int fieldInstanceId;

	@JsonProperty(value = "actualLeafCount", index = 9)
	@JsonPropertyDescription("Number of current leaf objects for the plant.")
	@Tags("Architecture")
	public int actualLeafCount;

	@JsonProperty(value = "actualLeafAreaSum", index = 10)
	@JsonPropertyDescription("Sum of current areas across leaf objects.")
	@Unit("m2")
	@Tags("Architecture")
	public double actualLeafAreaSum;

	@JsonProperty(value = "actualPotentialFinalSizeSum", index = 11)
	@JsonPropertyDescription("Sum of potential final-area targets across leaf objects.")
	@Unit("m2")
	@Tags("Development state")
	public double actualPotentialFinalSizeSum;

	@JsonProperty(value = "actualRealizedFinalSizeSum", index = 12)
	@JsonPropertyDescription("Sum of realized final-area targets across leaf objects.")
	@Unit("m2")
	@Tags("Development state")
	public double actualRealizedFinalSizeSum;

	@JsonProperty(value = "actualProfileLockedLeafCount", index = 13)
	@JsonPropertyDescription("Number of leaves with locked profile-derived final-size targets.")
	@Tags("Development state")
	public int actualProfileLockedLeafCount;

	@JsonProperty(value = "actualCurrentAreaToRealizedMean", index = 14)
	@JsonPropertyDescription("Mean current-area to realized-final-area ratio across leaves.")
	@Unit("-")
	@Tags("Development state")
	public double actualCurrentAreaToRealizedMean;

	@JsonProperty(value = "actualRosetteLeafCount", index = 15)
	@JsonPropertyDescription("Number of current leaves classified as rosette leaves.")
	@Tags("Architecture")
	public int actualRosetteLeafCount;

	@JsonProperty(value = "actualBourseLeafCount", index = 16)
	@JsonPropertyDescription("Number of current leaves classified as bourse leaves.")
	@Tags("Architecture")
	public int actualBourseLeafCount;

	@JsonProperty(value = "actualVegetativeLeafCount", index = 17)
	@JsonPropertyDescription("Number of current leaves classified as vegetative leaves.")
	@Tags("Architecture")
	public int actualVegetativeLeafCount;

	@JsonProperty(value = "activeGrowingLeafCount", index = 18)
	@JsonPropertyDescription("Number of leaves within their active expansion window.")
	@Tags("Development state")
	public int activeGrowingLeafCount;

	@JsonProperty(value = "matureLeafCount", index = 19)
	@JsonPropertyDescription("Number of leaves outside their active expansion window.")
	@Tags("Development state")
	public int matureLeafCount;

	@JsonProperty(value = "meanLeafAge", index = 20)
	@JsonPropertyDescription("Mean leaf age in the active model thermal-time scale.")
	@Tags("Development state")
	public double meanLeafAge;

	@JsonProperty(value = "meanLeafTe", index = 21)
	@JsonPropertyDescription("Mean leaf expansion end time in the active model thermal-time scale.")
	@Tags("Development state")
	public double meanLeafTe;

	@JsonProperty(value = "meanLeafFc", index = 22)
	@JsonPropertyDescription("Mean leaf carbon-stress multiplier.")
	@Unit("-")
	@Tags("Carbon")
	public double meanLeafFc;

	@JsonProperty(value = "meanLeafFw", index = 23)
	@JsonPropertyDescription("Mean leaf water-stress multiplier.")
	@Unit("-")
	@Tags("Water")
	public double meanLeafFw;

	@JsonProperty(value = "meanLeafLpot", index = 24)
	@JsonPropertyDescription("Mean potential leaf elongation increment before stress multipliers.")
	@Unit("m")
	@Tags("Development state")
	public double meanLeafLpot;

	@JsonProperty(value = "plannedProfileLeafRows", index = 25)
	@JsonPropertyDescription("Number of recorded Apple profile-plan leaf rows.")
	@Tags("Solver diagnostics")
	public int plannedProfileLeafRows;

	@JsonProperty(value = "emittedLeafEvents", index = 26)
	@JsonPropertyDescription("Number of recorded Apple leaf-axis emission events.")
	@Tags("Solver diagnostics")
	public int emittedLeafEvents;

	@JsonProperty(value = "currentActualLeafObjects", index = 27)
	@JsonPropertyDescription("Current count of leaf graph objects, retained from the legacy summary.")
	@Tags("Architecture")
	public int currentActualLeafObjects;

	@JsonProperty(value = "profileRowsNotYetEmitted", index = 28)
	@JsonPropertyDescription("Profile-plan row count minus the current actual leaf-object count.")
	@Tags("Solver diagnostics")
	public int profileRowsNotYetEmitted;
}


