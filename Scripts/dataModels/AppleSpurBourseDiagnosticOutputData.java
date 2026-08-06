import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("apple-spur-bourse-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppleSpurBourseDiagnosticOutputData implements Serializable {
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
	@JsonPropertyDescription("Spur or bourse diagnostic record type.")
	@Tags("Development state")
	public String recordType;

	@JsonProperty(value = "plantId", index = 10)
	@JsonPropertyDescription("Legacy plant identifier retained from the spur/bourse diagnostic.")
	@Tags("Identifiers")
	public int plantId;

	@JsonProperty(value = "budId", index = 11)
	@JsonPropertyDescription("Graph identifier recorded in the legacy bud-id column.")
	@Tags("Architecture")
	public long budId;

	@JsonProperty(value = "budType", index = 12)
	@JsonPropertyDescription("Bud type associated with the planned leaf.")
	@Tags("Development state")
	public String budType;

	@JsonProperty(value = "nSpurLeaves", index = 13)
	@JsonPropertyDescription("Number of spur leaves planned for the mixed bud.")
	@Tags("Development state")
	public int nSpurLeaves;

	@JsonProperty(value = "nBourseShoots", index = 14)
	@JsonPropertyDescription("Number of bourse shoots planned for the mixed bud.")
	@Tags("Development state")
	public int nBourseShoots;

	@JsonProperty(value = "leafType", index = 15)
	@JsonPropertyDescription("Planned leaf type.")
	@Tags("Development state")
	public String leafType;

	@JsonProperty(value = "leafRank", index = 16)
	@JsonPropertyDescription("Rank of the planned leaf.")
	@Tags("Architecture")
	public int leafRank;

	@JsonProperty(value = "potentialArea", index = 17)
	@JsonPropertyDescription("Potential final area of the planned leaf.")
	@Unit("m2")
	@Tags("Development state")
	public double potentialArea;

	@JsonProperty(value = "realizedArea", index = 18)
	@JsonPropertyDescription("Realized final-area target of the planned leaf.")
	@Unit("m2")
	@Tags("Development state")
	public double realizedArea;

	@JsonProperty(value = "carbonStressFactor", index = 19)
	@JsonPropertyDescription("Carbon-stress factor used for the leaf plan.")
	@Unit("-")
	@Tags("Carbon")
	public double carbonStressFactor;

	@JsonProperty(value = "DAFB", index = 20)
	@JsonPropertyDescription("Apex age minus FLOWERING_TARGET in the active thermal-time scale.")
	@Tags("Timing")
	public double DAFB;

	@JsonProperty(value = "stage", index = 21)
	@JsonPropertyDescription("Development stage assigned to the planned leaf.")
	@Tags("Development state")
	public String stage;

	@JsonProperty(value = "bourseExporterFlag", index = 22)
	@JsonPropertyDescription("Whether the event was at or after the bourse-export timing threshold.")
	@Tags("Development state")
	public boolean bourseExporterFlag;
}


