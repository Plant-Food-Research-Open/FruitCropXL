import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("apple-leaf-axis-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppleLeafAxisDiagnosticOutputData implements Serializable {
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

	@JsonProperty(value = "plantId", index = 9)
	@JsonPropertyDescription("Legacy plant identifier retained from the leaf-axis diagnostic.")
	@Tags("Identifiers")
	public int plantId;

	@JsonProperty(value = "apexId", index = 10)
	@JsonPropertyDescription("Graph identifier of the emitting apex.")
	@Tags("Architecture")
	public long apexId;

	@JsonProperty(value = "parentAxisApexId", index = 11)
	@JsonPropertyDescription("Graph identifier of the parent-axis apex.")
	@Tags("Architecture")
	public long parentAxisApexId;

	@JsonProperty(value = "sourceBudId", index = 12)
	@JsonPropertyDescription("Graph identifier of the source bud.")
	@Tags("Architecture")
	public long sourceBudId;

	@JsonProperty(value = "axisRole", index = 13)
	@JsonPropertyDescription("Resolved role of the axis that emitted the leaf.")
	@Tags("Architecture")
	public String axisRole;

	@JsonProperty(value = "shootType", index = 14)
	@JsonPropertyDescription("Shoot type of the emitting apex.")
	@Tags("Architecture")
	public String shootType;

	@JsonProperty(value = "order", index = 15)
	@JsonPropertyDescription("Branching order of the emitting apex.")
	@Tags("Architecture")
	public int order;

	@JsonProperty(value = "localRank", index = 16)
	@JsonPropertyDescription("Local rank associated with the leaf event.")
	@Tags("Architecture")
	public int localRank;

	@JsonProperty(value = "parentInternodeId", index = 17)
	@JsonPropertyDescription("Graph identifier of the parent internode.")
	@Tags("Architecture")
	public long parentInternodeId;

	@JsonProperty(value = "event", index = 18)
	@JsonPropertyDescription("Leaf-axis creation event name.")
	@Tags("Development state")
	public String event;
}
