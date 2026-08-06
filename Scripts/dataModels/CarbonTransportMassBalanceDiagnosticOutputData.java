import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("carbon-transport-mass-balance-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CarbonTransportMassBalanceDiagnosticOutputData implements Serializable {
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

	@JsonProperty(value = "day", index = 9)
	@JsonPropertyDescription("Legacy simulation day value retained from the carbon-transport diagnostic.")
	@Tags("Timing")
	public int day;

	@JsonProperty(value = "hour", index = 10)
	@JsonPropertyDescription("Legacy simulation hour value retained from the carbon-transport diagnostic.")
	@Tags("Timing")
	public int hour;

	@JsonProperty(value = "useCPStyleCTResponse", index = 11)
	@JsonPropertyDescription("Whether the carbon-potential response formulation was used.")
	@Tags("Solver diagnostics")
	public boolean useCPStyleCTResponse;

	@JsonProperty(value = "iterationCount", index = 12)
	@JsonPropertyDescription("Number of iterations completed by the carbon-transport solve.")
	@Tags("Solver diagnostics")
	public int iterationCount;

	@JsonProperty(value = "convergenceError", index = 13)
	@JsonPropertyDescription("Final summed absolute carbon-flux convergence error.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double convergenceError;

	@JsonProperty(value = "totalLoading", index = 14)
	@JsonPropertyDescription("Absolute sum of solved source-loading fluxes for the plant.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double totalLoading;

	@JsonProperty(value = "totalUnloading", index = 15)
	@JsonPropertyDescription("Sum of solved sink-unloading fluxes for the plant.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double totalUnloading;

	@JsonProperty(value = "netFluxResidual", index = 16)
	@JsonPropertyDescription("Total loading minus total unloading for the solved plant.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double netFluxResidual;

	@JsonProperty(value = "relativeFluxResidual", index = 17)
	@JsonPropertyDescription("Absolute net-flux residual relative to the larger loading or unloading magnitude.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double relativeFluxResidual;

	@JsonProperty(value = "minCp", index = 18)
	@JsonPropertyDescription("Minimum organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double minCp;

	@JsonProperty(value = "maxCp", index = 19)
	@JsonPropertyDescription("Maximum organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double maxCp;

	@JsonProperty(value = "meanCp", index = 20)
	@JsonPropertyDescription("Mean organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double meanCp;

	@JsonProperty(value = "minSugar", index = 21)
	@JsonPropertyDescription("Sugar concentration transformed from the minimum organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double minSugar;

	@JsonProperty(value = "maxSugar", index = 22)
	@JsonPropertyDescription("Sugar concentration transformed from the maximum organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double maxSugar;

	@JsonProperty(value = "meanSugar", index = 23)
	@JsonPropertyDescription("Sugar concentration transformed from the mean organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double meanSugar;

	@JsonProperty(value = "ctPlantBaseFallbackUsed", index = 24)
	@JsonPropertyDescription("Whether the current PlantBase boundary retained a previous potential or used the numerical floor.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackUsed;

	@JsonProperty(value = "ctPlantBaseFallbackReason", index = 25)
	@JsonPropertyDescription("PlantBase boundary outcome code: 0 accepted root; 1 non-finite coefficient; 2 zero or near-zero denominator; 3 invalid candidate; 4 invalid transformed sugar.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackReason;

	@JsonProperty(value = "ctPlantBaseFallbackCount", index = 26)
	@JsonPropertyDescription("Cumulative number of guarded PlantBase boundary fallbacks for the plant.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackCount;

	@JsonProperty(value = "ctPlantBaseResidual", index = 27)
	@JsonPropertyDescription("Folded boundary residual A + B Phi at the accepted or retained PlantBase potential.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double ctPlantBaseResidual;

	@JsonProperty(value = "ctPlantBaseDenominator", index = 28)
	@JsonPropertyDescription("Folded PlantBase B coefficient used to assess and solve the zero-net-flow boundary.")
	@Unit("g C/h/((g C/cm3)^2)")
	@Tags("Solver diagnostics")
	public double ctPlantBaseDenominator;
}

