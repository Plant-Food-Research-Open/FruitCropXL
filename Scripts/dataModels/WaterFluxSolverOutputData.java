import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;

@JsonRootName("water-flux-solver-debug")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PlantWaterFluxSolverDebugOutputData implements Serializable {
	private static final long serialVersionUID = 1L;

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
	@JsonPropertyDescription("Internal scenario number for configuring the simulation")
	@Tags("Time and identifier")
	public int scenario;

	@JsonProperty(value = "simuuid", index = 5)
	@JsonPropertyDescription("Unique simulation UUID assigned to the run")
	@Tags("Time and identifier")
	public String simuuid;

	@JsonProperty(value = "plantNumber", index = 6)
	@JsonPropertyDescription("Plant identifier within the field instance")
	@Tags("Time and identifier")
	public int plantNumber;

	@JsonProperty(value = "fieldInstanceId", index = 7)
	@JsonPropertyDescription("Field-instance identifier for the plant")
	@Tags("Time and identifier")
	public int fieldInstanceId;

	@JsonProperty(value = "waterFluxSolverResidual", index = 8)
	@JsonPropertyDescription("Residual of the accepted plant water-flux solve: requested plant flux minus summed leaf flux.")
	@Unit("mg/plant/s")
	@Tags("Water flux solver diagnostics")
	public double waterFluxSolverResidual;

	@JsonProperty(value = "waterFluxSolverFallbackUsed", index = 9)
	@JsonPropertyDescription("Flag indicating that the solver used a fallback candidate after bracketing failure.")
	@Tags("Water flux solver diagnostics")
	public int waterFluxSolverFallbackUsed;

	@JsonProperty(value = "waterFluxSolverAccepted", index = 10)
	@JsonPropertyDescription("Flag indicating that the solver accepted a bracketed or deterministic solution.")
	@Tags("Water flux solver diagnostics")
	public int waterFluxSolverAccepted;

	@JsonProperty(value = "meanLeafWaterPotential_solver", index = 11)
	@JsonPropertyDescription("Mean candidate leaf water potential at the accepted solution.")
	@Unit("MPa")
	@Tags("Water flux solver diagnostics")
	public double meanLeafWaterPotential_solver;

	@JsonProperty(value = "minLeafWaterPotential_solver", index = 12)
	@JsonPropertyDescription("Minimum candidate leaf water potential at the accepted solution.")
	@Unit("MPa")
	@Tags("Water flux solver diagnostics")
	public double minLeafWaterPotential_solver;

	@JsonProperty(value = "maxLeafWaterPotential_solver", index = 13)
	@JsonPropertyDescription("Maximum candidate leaf water potential at the accepted solution.")
	@Unit("MPa")
	@Tags("Water flux solver diagnostics")
	public double maxLeafWaterPotential_solver;

	@JsonProperty(value = "meanPLC_leaf_solver", index = 14)
	@JsonPropertyDescription("Mean candidate leaf fractional loss of conductivity at the accepted solution.")
	@Unit("-")
	@Tags("Water flux solver diagnostics")
	public double meanPLC_leaf_solver;

	@JsonProperty(value = "meanGs_solver", index = 15)
	@JsonPropertyDescription("Mean candidate stomatal conductance at the accepted solution.")
	@Unit("mol/m2/s")
	@Tags("Water flux solver diagnostics")
	public double meanGs_solver;

	@JsonProperty(value = "waterFluxSolverLowerBound", index = 16)
	@JsonPropertyDescription("Lower plant water-flux bound used for the accepted solve attempt.")
	@Unit("mg/plant/s")
	@Tags("Water flux solver diagnostics")
	public double waterFluxSolverLowerBound;

	@JsonProperty(value = "waterFluxSolverUpperBound", index = 17)
	@JsonPropertyDescription("Upper plant water-flux bound used for the accepted solve attempt.")
	@Unit("mg/plant/s")
	@Tags("Water flux solver diagnostics")
	public double waterFluxSolverUpperBound;

	@JsonProperty(value = "waterFluxSolverLeafSum", index = 18)
	@JsonPropertyDescription("Summed leaf water flux evaluated at the accepted solution.")
	@Unit("mg/plant/s")
	@Tags("Water flux solver diagnostics")
	public double waterFluxSolverLeafSum;

	@JsonProperty(value = "waterFluxSolverRepeatedResidualDelta", index = 19)
	@JsonPropertyDescription("Absolute difference between repeated residual evaluations of the same candidate.")
	@Unit("mg/plant/s")
	@Tags("Water flux solver diagnostics")
	public double waterFluxSolverRepeatedResidualDelta;

	@JsonProperty(value = "waterFluxSolverEvalCount", index = 20)
	@JsonPropertyDescription("Number of candidate residual evaluations made during the water-flux solve.")
	@Tags("Water flux solver diagnostics")
	public int waterFluxSolverEvalCount;
}
